extends Node

# =============================================================================
# CONVEYOR DURABILITY — STRAIGHT AND CORNER FOUNDATION REGRESSION
# =============================================================================

# Durability is present on all three belt shapes. This isolated scene
# deliberately does not enable automatic health-triggered belt removal.
# The already-tested WorldDestructionService provides safe manual
# removal with wreckage; live zombie targeting comes later.


func _make_belt(
	world: Node3D,
	scene: PackedScene,
	at_position: Vector3
) -> ConveyorSegment:
	var belt := scene.instantiate() as ConveyorSegment
	assert(belt != null)
	world.add_child(belt)
	belt.global_position = at_position

	var timer := belt.get_node_or_null(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	if timer != null:
		timer.set_process(false)
	return belt


func _ready() -> void:
	print("\n===== CONVEYOR DURABILITY FOUNDATION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(
		main_scene != null and storage_scene != null
		and ore != null and ammo != null and ingot != null
	)

	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)
	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	var moving := world.get_node("PrototypeMovingZombie") as Node3D
	assert(service != null and moving != null)
	(moving.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(moving.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	print("PASS A: Main scene and existing destruction service remain available")

	var first := _make_belt(
		world, ConveyorPieceSelector.STRAIGHT_SCENE, Vector3(0, 0, 0)
	)
	var second := _make_belt(
		world, ConveyorPieceSelector.STRAIGHT_SCENE, Vector3(2, 0, 0)
	)
	var right := _make_belt(
		world, ConveyorPieceSelector.RIGHT_CORNER_SCENE, Vector3(30, 0, 0)
	)
	var left := _make_belt(
		world, ConveyorPieceSelector.LEFT_CORNER_SCENE, Vector3(35, 0, 0)
	)
	var belts: Array[ConveyorSegment] = [first, second, right, left]
	for belt: ConveyorSegment in belts:
		var hp := belt.get_node_or_null(
			"ConveyorHealthComponent"
		) as ConveyorHealthComponent
		var cargo := belt.get_node_or_null(
			"CargoInventory"
		) as InventoryComponent
		assert(hp != null and hp.max_health == 50)
		assert(hp.current_health == 50 and hp.is_intact())
		assert(hp.total_damage_taken == 0)
		assert(cargo != null and cargo.max_capacity == 1)
	print("PASS B: Straight and both corner shapes each have 50 HP and one cargo slot")

	var ghost := ConveyorPieceSelector.RIGHT_CORNER_SCENE.instantiate() as ConveyorSegment
	assert(ghost != null)
	ghost.add_to_group("construction_preview")
	world.add_child(ghost)
	var ghost_hp := ghost.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(ghost_hp.take_damage(50) == 50)
	assert(ghost.is_inside_tree() and not ghost.is_queued_for_deletion())
	assert(service.successful_destructions == 0)
	print("PASS C: Preview corner health does not cause gameplay destruction")

	var storage := storage_scene.instantiate() as Node3D
	assert(storage != null)
	world.add_child(storage)
	storage.global_position = Vector3(24, 0, 24)
	var port := storage.get_node("OutputPort") as ItemPortComponent
	var snap := ConveyorBuildingSnap.get_preview_transform(port, first)
	assert(snap.has("transform"))
	first.global_transform = snap["transform"]
	assert(first.try_connect_building_port(port))
	var next_snap := second.get_snap_preview_transform_after(first)
	assert(next_snap.has("transform"))
	second.global_transform = next_snap["transform"]
	assert(first.try_connect_to(second))
	assert(first.next_segment == second and second.previous_segment == first)
	print("PASS D: Existing Storage output and two-belt connections still work")

	var first_hp := first.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	var second_hp := second.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(first_hp.take_damage(0) == 0)
	assert(first_hp.take_damage(-15) == 0)
	assert(first_hp.current_health == 50)
	assert(second_hp.current_health == 50)
	assert(first_hp.take_damage(10) == 10)
	assert(first_hp.current_health == 40)
	assert(first_hp.total_damage_taken == 10)
	assert(first.next_segment == second)
	print("PASS E: Invalid hits are ignored and 10 damage affects only one belt")

	var depletion_events: Array[int] = []
	first_hp.health_depleted.connect(func(): depletion_events.append(1))
	assert(first_hp.take_damage(99) == 40)
	assert(first_hp.current_health == 0)
	assert(first_hp.total_damage_taken == 50)
	assert(depletion_events.size() == 1)
	assert(first_hp.take_damage(1) == 0)
	assert(depletion_events.size() == 1)
	print("PASS F: Belt overkill clamps at zero and signals depletion exactly once")

	assert(first.is_inside_tree() and not first.is_queued_for_deletion())
	assert(first.next_segment == second)
	assert(second.previous_segment == first)
	assert(second_hp.current_health == 50)
	assert(service.successful_destructions == 0)
	print("PASS G: Durability-only milestone does not auto-delete connected belts")

	var first_cargo := first.get_node("CargoInventory") as InventoryComponent
	var second_cargo := second.get_node("CargoInventory") as InventoryComponent
	assert(first_cargo.add_item(ore, 1) == 1)
	assert(second_cargo.add_item(ingot, 1) == 1)
	first_cargo.items["invalid_key"] = 1
	assert(service.try_destroy_with_salvage(first) == null)
	assert(first.is_inside_tree() and not first.is_queued_for_deletion())
	assert(first_cargo.get_amount(ore) == 1)
	assert(first.next_segment == second and second.previous_segment == first)
	assert(get_tree().get_nodes_in_group("salvage_caches").is_empty())
	first_cargo.items.erase("invalid_key")
	print("PASS H: Bad cargo rejects removal without deleting belts or resources")

	var recovered_first := service.try_destroy_with_salvage(first)
	assert(recovered_first != null)
	assert(recovered_first.inventory.get_amount(ore) == 1)
	assert(recovered_first.status_label.text == "SALVAGE: 1")
	assert(first_cargo.get_total_amount() == 0)
	assert(port.connected_conveyor == null)
	assert(second.previous_segment == null)
	assert(second_cargo.get_amount(ingot) == 1)
	await get_tree().process_frame
	assert(not is_instance_valid(first))
	assert(second.is_inside_tree())
	print("PASS I: Zero-HP straight belt can be safely removed; next cargo survives")

	var right_hp := right.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	var right_cargo := right.get_node("CargoInventory") as InventoryComponent
	assert(right_cargo.add_item(ammo, 1) == 1)
	assert(right_hp.take_damage(50) == 50)
	assert(not right_hp.is_intact())
	var recovered_right := service.try_destroy_with_salvage(right)
	assert(recovered_right != null)
	assert(recovered_right.inventory.get_amount(ammo) == 1)
	await get_tree().process_frame
	assert(not is_instance_valid(right))
	assert(second.is_inside_tree() and left.is_inside_tree())
	print("PASS J: Right corner destruction recovers cargo and leaves other belts")

	var left_hp := left.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(left_hp.take_damage(30) == 30)
	assert(left_hp.take_damage(30) == 20)
	assert(left_hp.current_health == 0)
	var recovered_left := service.try_destroy_with_salvage(left)
	assert(recovered_left != null)
	assert(recovered_left.inventory.get_total_amount() == 0)
	assert(recovered_left.status_label.text == "WRECKAGE")
	await get_tree().process_frame
	assert(not is_instance_valid(left))
	print("PASS K: Empty left corner destruction leaves an empty wreckage cache")

	assert(service.successful_destructions == 3)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 3)
	var salvage_total: int = 0
	for item: Node in get_tree().get_nodes_in_group("salvage_caches"):
		var cache := item as WorldSalvageCache
		assert(cache != null and cache.get_parent() == world)
		salvage_total += cache.inventory.get_total_amount()
	assert(salvage_total == 2)
	assert(second_cargo.get_total_amount() == 1)
	assert(second_hp.current_health == 50)
	assert(storage.is_inside_tree() and ghost.is_inside_tree())
	assert(moving.is_inside_tree())
	print("PASS L: Two recovered cargo units plus one live belt unit remain intact")

	world.queue_free()
	print("================================================")
	print("ALL 12 CONVEYOR DURABILITY FOUNDATION TESTS PASSED")
	print("================================================")
