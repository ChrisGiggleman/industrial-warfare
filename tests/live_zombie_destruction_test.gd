extends Node

# =============================================================================
# LIVE ZOMBIE DESTRUCTION — SALVAGE AND TARGETING REGRESSION
# =============================================================================

# Runs the real Main scene and its moving zombie with manual physics.
# BuildingHealthComponent signals the world destruction service on
# zero HP; salvage must outlive the destroyed structure.
#
# Conveyor HP and zombie attacks on conveyor belts are a later step.


func _make_storage(
	world: Node3D,
	definition: BuildingDefinition,
	at_position: Vector3
) -> Node3D:
	var storage := definition.building_scene.instantiate() as Node3D
	assert(storage != null)
	world.add_child(storage)
	storage.global_position = at_position
	var runtime := storage.get_node("BuildingRuntime") as BuildingRuntime
	assert(runtime != null)
	runtime.initialize(definition)
	return storage


func _make_belt(world: Node3D) -> ConveyorSegment:
	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(belt != null)
	world.add_child(belt)
	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	return belt


func _ready() -> void:
	print("\n===== LIVE ZOMBIE BUILDING DESTRUCTION =====")

	var world_scene := load("res://scenes/core/main.tscn") as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(world_scene != null and ore != null and ingot != null and ammo != null)

	var world := world_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)
	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	var moving := world.get_node("PrototypeMovingZombie") as Node3D
	var movement := moving.get_node(
		"MovementComponent"
	) as ZombieApproachComponent
	var melee := moving.get_node("MeleeComponent") as ZombieMeleeComponent
	var interaction := world.get_node("WorldInteraction")
	var hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	assert(
		service != null and service.destroy_on_zero_hp
		and moving != null and movement != null and melee != null
		and hud != null and interaction != null
	)
	movement.set_physics_process(false)
	# Preserve building-only targeting for this historical regression.
	movement.target_conveyors = false
	melee.set_physics_process(false)
	print("PASS A: Main enables the real health-depletion destruction service")

	melee._physics_process(0.1)
	assert(movement.find_nearest_structure() == null)
	assert(service.successful_destructions == 0)
	assert(get_tree().get_nodes_in_group("salvage_caches").is_empty())
	print("PASS B: Empty world does not create salvage or damage anything")

	var controller = world.get_node("WorldInteraction")
	var definitions: Array[BuildingDefinition] = controller.buildable_definitions
	assert(definitions.size() == 9)
	var ghost := definitions[2].building_scene.instantiate() as Node3D
	ghost.add_to_group("construction_preview")
	world.add_child(ghost)
	ghost.global_position = Vector3(8, 0, -6)
	var ghost_hp := ghost.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	assert(ghost_hp != null)
	assert(ghost_hp.take_damage(100) == 100)
	assert(ghost.is_inside_tree() and not ghost.is_queued_for_deletion())
	assert(get_tree().get_nodes_in_group("salvage_caches").is_empty())
	assert(movement.find_nearest_structure() == null)
	print("PASS C: Damaged construction previews remain safe and untargetable")

	var storage := _make_storage(
		world, definitions[2], Vector3(8, 0, -2)
	)
	var stored := storage.get_node(
		"InventoryComponent"
	) as InventoryComponent
	var health := storage.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	assert(health != null and health.current_health == 100)
	assert(stored.add_item(ore, 5) == 5)
	assert(stored.add_item(ammo, 2) == 2)

	var first := _make_belt(world)
	var second := _make_belt(world)
	var port := storage.get_node("OutputPort") as ItemPortComponent
	var snap := ConveyorBuildingSnap.get_preview_transform(port, first)
	assert(snap.has("transform"))
	first.global_transform = snap["transform"]
	assert(first.try_connect_building_port(port))
	var second_snap := second.get_snap_preview_transform_after(first)
	assert(second_snap.has("transform"))
	second.global_transform = second_snap["transform"]
	assert(first.try_connect_to(second))
	var first_items := first.get_node(
		"CargoInventory"
	) as InventoryComponent
	var second_items := second.get_node(
		"CargoInventory"
	) as InventoryComponent
	assert(first_items.add_item(ingot, 1) == 1)
	assert(second_items.add_item(ammo, 1) == 1)
	assert(first.next_segment == second and second.previous_segment == first)
	print("PASS D: Real Storage holds seven items beside two stocked connected belts")

	interaction.call("_select_object", storage)
	assert(interaction.get("selected_object") == storage)
	assert(hud.selected_building == storage)
	assert(movement.find_nearest_structure() == storage)
	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(0.01)
	assert(health.current_health == 90)
	assert(melee.attacks_landed == 1)
	assert(service.successful_destructions == 0)
	assert(hud.selected_building == storage)
	print("PASS E: Live zombie attacks selected Storage without early deletion")

	for expected_hp: int in [80, 70, 60, 50, 40, 30, 20, 10]:
		melee._physics_process(1.01)
		assert(health.current_health == expected_hp)
	assert(melee.attacks_landed == 9)
	assert(service.successful_destructions == 0)
	assert(stored.get_total_amount() == 7)
	assert(first.input_building_port == port)
	print("PASS F: Nine authorized attacks leave ten HP and all cargo intact")

	var storage_position := storage.global_position
	melee._physics_process(1.01)
	assert(melee.attacks_landed == 10)
	assert(melee.total_damage_dealt == 100)
	assert(health.current_health == 0)
	assert(storage.is_queued_for_deletion())
	assert(storage.process_mode == Node.PROCESS_MODE_DISABLED)
	assert(service.successful_destructions == 1)
	assert(stored.get_total_amount() == 0)
	print("PASS G: Tenth zombie attack queues real building removal at zero HP")

	var caches := get_tree().get_nodes_in_group("salvage_caches")
	assert(caches.size() == 1)
	var first_cache := caches[0] as WorldSalvageCache
	assert(first_cache != null)
	assert(first_cache.global_position == storage_position)
	assert(first_cache.inventory.get_amount(ore) == 5)
	assert(first_cache.inventory.get_amount(ammo) == 2)
	assert(first_cache.status_label.text == "SALVAGE: 7")
	assert(interaction.get("selected_object") == null)
	assert(hud.selected_building == null)
	print("PASS H: World wreckage saves seven items and clears selected-building HUD")

	assert(port.connected_conveyor == null)
	assert(first.input_building_port == null)
	assert(first.next_segment == second)
	assert(second.previous_segment == first)
	assert(first_items.get_amount(ingot) == 1)
	assert(second_items.get_amount(ammo) == 1)
	assert(service.try_destroy_with_salvage(storage) == null)
	assert(service.successful_destructions == 1)
	await get_tree().process_frame
	assert(not is_instance_valid(storage))
	assert(first.is_inside_tree() and second.is_inside_tree())
	assert(first_cache.is_inside_tree())
	print("PASS I: Removed Storage leaves neighboring belt cargo and links intact")

	movement._physics_process(0.1)
	assert(movement.current_target == null)
	var backup := _make_storage(
		world, definitions[2], Vector3(13, 0, -2)
	)
	var backup_hp := backup.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var backup_stock := backup.get_node(
		"InventoryComponent"
	) as InventoryComponent
	assert(backup_stock.add_item(ingot, 3) == 3)
	movement._physics_process(0.1)
	assert(movement.current_target == backup)
	assert(movement.movement_status == "Approaching")
	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(1.01)
	assert(backup_hp.current_health == 90)
	assert(melee.attacks_landed == 11)
	print("PASS J: Zombie reacquires and damages a second healthy building")

	assert(backup_hp.take_damage(90) == 90)
	assert(backup.is_queued_for_deletion())
	assert(service.successful_destructions == 2)
	assert(backup_stock.get_total_amount() == 0)
	await get_tree().process_frame
	assert(not is_instance_valid(backup))
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 2)
	print("PASS K: Another damage source triggers the same lossless destruction")

	var invalid := _make_storage(
		world, definitions[2], Vector3(16, 0, -2)
	)
	var invalid_hp := invalid.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var invalid_stock := invalid.get_node(
		"InventoryComponent"
	) as InventoryComponent
	assert(invalid_stock.add_item(ammo, 2) == 2)
	invalid_stock.items["bad_key"] = 1
	assert(invalid_hp.take_damage(100) == 100)
	assert(service.failed_health_destructions == 1)
	assert(invalid.is_inside_tree() and not invalid.is_queued_for_deletion())
	assert(invalid_stock.get_amount(ammo) == 2)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 2)
	invalid_stock.items.erase("bad_key")
	var recovered := service.try_destroy_with_salvage(invalid)
	assert(recovered != null and recovered.inventory.get_amount(ammo) == 2)
	await get_tree().process_frame
	assert(not is_instance_valid(invalid))
	assert(service.successful_destructions == 3)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 3)

	var total: int = 0
	for node: Node in get_tree().get_nodes_in_group("salvage_caches"):
		var wreckage := node as WorldSalvageCache
		assert(wreckage != null and wreckage.get_parent() == world)
		total += wreckage.inventory.get_total_amount()
	assert(total == 12)
	assert(first_items.get_total_amount() + second_items.get_total_amount() == 2)
	print("PASS L: Failed salvage remains retryable; 12 cached and 2 belt items preserved")

	world.queue_free()
	print("================================================")
	print("ALL 12 LIVE ZOMBIE DESTRUCTION TESTS PASSED")
	print("================================================")
