extends Node

# =============================================================================
# LIVE ZOMBIE CONVEYOR DESTRUCTION — PHYSICAL SUPPLY LINE REGRESSION
# =============================================================================

# Uses Main's real moving zombie, three belt shapes and world-owned
# salvage. The physical zombie approaches manually for deterministic
# melee cooldowns. The default live conveyor-targeting policy is ON.


func _make_belt(world: Node3D, scene: PackedScene) -> ConveyorSegment:
	var belt := scene.instantiate() as ConveyorSegment
	assert(belt != null)
	world.add_child(belt)
	var timer := belt.get_node_or_null(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	if is_instance_valid(timer):
		timer.set_process(false)
	return belt


func _ready() -> void:
	print("\n===== LIVE ZOMBIE CONVEYOR DESTRUCTION =====")

	var world_scene := load("res://scenes/core/main.tscn") as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var rounds := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(
		world_scene != null and storage_scene != null
		and ore != null and ingot != null and rounds != null
	)

	var world := world_scene.instantiate() as Node3D
	add_child(world)
	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	var moving := world.get_node("PrototypeMovingZombie") as Node3D
	var movement := moving.get_node(
		"MovementComponent"
	) as ZombieApproachComponent
	var melee := moving.get_node(
		"MeleeComponent"
	) as ZombieMeleeComponent
	var hud := world.get_node(
		"ProductionDebugHUD"
	) as ProductionDebugHUD
	var interaction := world.get_node("WorldInteraction")
	assert(service != null and moving != null)
	assert(movement != null and melee != null and hud != null)
	assert(movement.target_conveyors and service.destroy_conveyors_on_zero_hp)
	assert(melee.movement == movement and melee.attack_damage == 10)
	movement.set_physics_process(false)
	melee.set_physics_process(false)
	print("PASS A: Main enables belt targeting and guarded conveyor destruction")

	var ghost := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	ghost.add_to_group("construction_preview")
	world.add_child(ghost)
	ghost.global_position = moving.global_position + Vector3(1, 0, 0)
	assert(movement.find_nearest_structure() == null)
	assert(service.successful_destructions == 0)
	print("PASS B: Construction ghosts remain unattackable conveyor targets")

	var storage := storage_scene.instantiate() as Node3D
	world.add_child(storage)
	storage.global_position = Vector3(8, 0, -2)
	var store_stock := storage.get_node(
		"InventoryComponent"
	) as InventoryComponent
	assert(store_stock.add_item(ore, 3) == 3)
	var port := storage.get_node("OutputPort") as ItemPortComponent
	var first := _make_belt(world, ConveyorPieceSelector.STRAIGHT_SCENE)
	var second := _make_belt(world, ConveyorPieceSelector.STRAIGHT_SCENE)
	var snap := ConveyorBuildingSnap.get_preview_transform(port, first)
	assert(snap.has("transform"))
	first.global_transform = snap["transform"]
	assert(first.try_connect_building_port(port))
	var snap_next := second.get_snap_preview_transform_after(first)
	assert(snap_next.has("transform"))
	second.global_transform = snap_next["transform"]
	assert(first.try_connect_to(second))
	var first_stock := first.get_node(
		"CargoInventory"
	) as InventoryComponent
	var second_stock := second.get_node(
		"CargoInventory"
	) as InventoryComponent
	assert(first_stock.add_item(ore, 1) == 1)
	assert(second_stock.add_item(rounds, 1) == 1)
	assert(first.next_segment == second and second.previous_segment == first)
	print("PASS C: Stocked Storage feeds two physically linked occupied belts")

	# Side approach ensures the first belt is the nearest valid target.
	moving.global_position = first.global_position + Vector3(4, 0, 0)
	assert(movement.find_nearest_structure() == first)
	movement._physics_process(0.4)
	assert(movement.current_target == first)
	assert(movement.movement_status == "Approaching")
	melee._physics_process(0.1)
	assert(melee.attack_status == "Approaching")
	var first_hp := first.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(first_hp.current_health == 50)
	print("PASS D: Zombie chooses nearest belt, walks toward it, and cannot hit early")

	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(0.01)
	assert(first_hp.current_health == 40)
	assert(melee.attacks_landed == 1)
	assert(melee.total_damage_dealt == 10)
	print("PASS E: First authorized melee hit deals 10 conveyor HP")

	melee._physics_process(0.5)
	melee._physics_process(0.49)
	assert(melee.attack_status == "Cooldown")
	assert(first_hp.current_health == 40)
	assert(melee.attacks_landed == 1)
	print("PASS F: Belt melee shares the existing one-second attack cooldown")

	interaction.call("_select_object", first)
	assert(interaction.get("selected_object") == first)
	for expected: int in [30, 20, 10]:
		melee._physics_process(1.01)
		assert(first_hp.current_health == expected)
	assert(first_stock.get_amount(ore) == 1)
	assert(service.successful_destructions == 0)
	melee._physics_process(1.01)
	assert(first_hp.current_health == 0)
	assert(first.is_queued_for_deletion())
	assert(service.successful_destructions == 1)
	assert(melee.attacks_landed == 5)
	print("PASS G: Fifth zombie hit queues only the 50-HP belt for removal")

	var caches := get_tree().get_nodes_in_group("salvage_caches")
	assert(caches.size() == 1)
	var cache_first := caches[0] as WorldSalvageCache
	assert(cache_first.inventory.get_amount(ore) == 1)
	assert(cache_first.status_label.text == "SALVAGE: 1")
	assert(port.connected_conveyor == null)
	assert(second.previous_segment == null)
	assert(second_stock.get_amount(rounds) == 1)
	assert(store_stock.get_amount(ore) == 3)
	assert(interaction.get("selected_object") == null)
	assert(hud.selected_building == null)
	await get_tree().process_frame
	assert(not is_instance_valid(first))
	assert(second.is_inside_tree())
	print("PASS H: Broken belt leaves salvage and severed links; stock survives")

	movement._physics_process(0.1)
	assert(movement.current_target == second)
	movement._physics_process(10.0)
	# The second target approaches diagonally after the first belt
	# vanishes. Allow a few ordinary physics ticks to settle any
	# sub-millimeter floating-point drift at the stop boundary.
	for settle_tick: int in range(4):
		movement._physics_process(0.1)
		if movement.movement_status == "At Structure":
			break
	if movement.movement_status != "At Structure":
		print(
			"ARRIVAL DIAGNOSTIC | Target: ", movement.current_target,
			" | Status: ", movement.movement_status,
			" | Zombie: ", moving.global_position,
			" | Belt: ", second.global_position,
			" | Stop distance: ", movement.stopping_distance
		)
	assert(movement.current_target == second)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(1.01)
	var second_hp := second.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(second_hp.current_health == 40)
	assert(melee.attacks_landed == 6)
	print("PASS I: Zombie reacquires and attacks the next intact conveyor")

	# Broken inventory keys must not cause deletion or duplicate salvage.
	second_stock.items["invalid_key"] = 1
	for expected: int in [30, 20, 10, 0]:
		melee._physics_process(1.01)
		assert(second_hp.current_health == expected)
	assert(service.failed_health_destructions == 1)
	assert(second.is_inside_tree() and not second.is_queued_for_deletion())
	assert(second_stock.get_amount(rounds) == 1)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 1)
	second_stock.items.erase("invalid_key")
	var second_cache := service.try_destroy_with_salvage(second)
	assert(second_cache != null)
	assert(second_cache.inventory.get_amount(rounds) == 1)
	await get_tree().process_frame
	assert(not is_instance_valid(second))
	assert(service.successful_destructions == 2)
	print("PASS J: Invalid cargo blocks deletion; manual retry recovers second belt")

	var right := _make_belt(
		world, ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	var left := _make_belt(
		world, ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	right.global_position = Vector3(30, 0, 30)
	left.global_position = Vector3(40, 0, 30)
	var right_stock := right.get_node(
		"CargoInventory"
	) as InventoryComponent
	assert(right_stock.add_item(ingot, 1) == 1)
	moving.global_position = right.global_position + Vector3(-4, 0, 0)
	movement._physics_process(0.1)
	assert(movement.current_target == right)
	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	for ignored: int in range(5):
		melee._physics_process(1.01)
	assert(right.is_queued_for_deletion())
	await get_tree().process_frame
	assert(not is_instance_valid(right))
	assert(service.successful_destructions == 3)
	assert(left.is_inside_tree())
	print("PASS K: Zombie destroys cargo-bearing right corner without harming left")

	movement._physics_process(0.1)
	assert(movement.current_target == left)
	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	for ignored: int in range(5):
		melee._physics_process(1.01)
	assert(left.is_queued_for_deletion())
	await get_tree().process_frame
	assert(not is_instance_valid(left))
	assert(service.successful_destructions == 4)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 4)

	var salvaged_ore: int = 0
	var salvaged_ingot: int = 0
	var salvaged_rounds: int = 0
	for node: Node in get_tree().get_nodes_in_group("salvage_caches"):
		var cache := node as WorldSalvageCache
		assert(cache != null and cache.get_parent() == world)
		salvaged_ore += cache.inventory.get_amount(ore)
		salvaged_ingot += cache.inventory.get_amount(ingot)
		salvaged_rounds += cache.inventory.get_amount(rounds)
	assert(salvaged_ore == 1 and salvaged_ingot == 1)
	assert(salvaged_rounds == 1)
	assert(store_stock.get_amount(ore) == 3)
	assert(movement.find_nearest_structure() == storage)
	assert(ghost.is_inside_tree())
	print("PASS L: Both corners destroy safely; three salvaged plus three stored")

	world.queue_free()
	print("================================================")
	print("ALL 12 LIVE ZOMBIE CONVEYOR DESTRUCTION TESTS PASSED")
	print("================================================")
