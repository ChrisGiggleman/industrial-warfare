extends Node

# =============================================================================
# WORLD SALVAGE — MAIN-SCENE DESTRUCTION REGRESSION
# =============================================================================

# Uses Main's live WorldDestructionService. Damage-to-destruction is
# not connected yet. Items must reside in real world-owned caches,
# even AFTER a building or conveyor is removed from the scene.


func _belt(world: Node3D) -> ConveyorSegment:
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
	print("\n===== MAIN-WORLD DESTRUCTION AND SALVAGE =====")

	var world_scene := load("res://scenes/core/main.tscn") as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var press_scene := load(
		"res://scenes/buildings/prototype_ammunition_press.tscn"
	) as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(
		world_scene != null and storage_scene != null
		and press_scene != null and ore != null
		and ingot != null and ammo != null
	)

	var world := world_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)
	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	var static_target := world.get_node("PrototypeZombieTarget") as Node3D
	var camera := world.get_node("CameraRig") as Node3D
	assert(
		service != null and zombie != null
		and static_target != null and camera != null
	)
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	assert(service.successful_destructions == 0)
	assert(get_tree().get_nodes_in_group("salvage_caches").is_empty())
	print("PASS A: Main owns its destruction service without changing enemy setup")

	var irrelevant := Node3D.new()
	world.add_child(irrelevant)
	assert(service.try_destroy_with_salvage(irrelevant) == null)
	var ghost := storage_scene.instantiate() as Node3D
	ghost.add_to_group("construction_preview")
	world.add_child(ghost)
	assert(service.try_destroy_with_salvage(ghost) == null)
	assert(service.successful_destructions == 0)
	assert(get_tree().get_nodes_in_group("salvage_caches").is_empty())
	print("PASS B: Invalid objects and construction previews make no salvage")

	var storage := storage_scene.instantiate() as Node3D
	world.add_child(storage)
	storage.global_position = Vector3(25, 0, 25)
	var storage_position: Vector3 = storage.global_position
	var stock := storage.get_node("InventoryComponent") as InventoryComponent
	assert(stock.add_item(ore, 5) == 5)
	assert(stock.add_item(ammo, 2) == 2)

	var first := _belt(world)
	var second := _belt(world)
	var port := storage.get_node("OutputPort") as ItemPortComponent
	var snap := ConveyorBuildingSnap.get_preview_transform(port, first)
	assert(snap.has("transform"))
	first.global_transform = snap["transform"]
	assert(first.try_connect_building_port(port))
	var second_snap := second.get_snap_preview_transform_after(first)
	assert(second_snap.has("transform"))
	second.global_transform = second_snap["transform"]
	assert(first.try_connect_to(second))
	var first_stock := first.get_node("CargoInventory") as InventoryComponent
	var second_stock := second.get_node("CargoInventory") as InventoryComponent
	assert(first_stock.add_item(ingot, 1) == 1)
	assert(second_stock.add_item(ammo, 1) == 1)
	assert(first.next_segment == second and second.previous_segment == first)
	print("PASS C: Stocked warehouse has two linked cargo-bearing conveyors")

	var cache_storage := service.try_destroy_with_salvage(storage)
	assert(cache_storage != null)
	assert(cache_storage.is_inside_tree())
	assert(cache_storage.get_parent() == world)
	assert(cache_storage.is_in_group("salvage_caches"))
	assert(not cache_storage.is_in_group("player_built"))
	assert(cache_storage.global_position == storage_position)
	assert(cache_storage.inventory.get_amount(ore) == 5)
	assert(cache_storage.inventory.get_amount(ammo) == 2)
	assert(cache_storage.status_label.text == "SALVAGE: 7")
	assert(stock.get_total_amount() == 0)
	assert(storage.is_queued_for_deletion())
	assert(service.successful_destructions == 1)
	print("PASS D: Main-world wreckage owns seven recovered items at the old site")

	assert(service.try_destroy_with_salvage(storage) == null)
	assert(service.successful_destructions == 1)
	assert(not is_instance_valid(port.connected_conveyor))
	assert(not is_instance_valid(first.input_building_port))
	assert(first.next_segment == second)
	assert(second.previous_segment == first)
	await get_tree().process_frame
	assert(not is_instance_valid(storage))
	assert(first.is_inside_tree() and second.is_inside_tree())
	assert(first_stock.get_amount(ingot) == 1)
	assert(second_stock.get_amount(ammo) == 1)
	print("PASS E: Repeat destruction is refused; adjacent belts keep their cargo")

	var press := press_scene.instantiate() as Node3D
	world.add_child(press)
	press.global_position = Vector3(30, 0, 30)
	var raw := press.get_node("InputInventory") as InventoryComponent
	var made := press.get_node("OutputInventory") as InventoryComponent
	(press.get_node("ProducerComponent") as ProducerComponent).set_process(false)
	assert(raw.add_item(ingot, 2) == 2)
	assert(made.add_item(ammo, 4) == 4)
	raw.items["invalid_key"] = 1
	assert(service.try_destroy_with_salvage(press) == null)
	assert(not press.is_queued_for_deletion())
	assert(raw.get_amount(ingot) == 2)
	assert(made.get_amount(ammo) == 4)
	assert(service.successful_destructions == 1)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 1)
	raw.items.erase("invalid_key")
	print("PASS F: Failed manufacturer recovery leaves no duplicate salvage cache")

	var cache_press := service.try_destroy_with_salvage(press)
	assert(cache_press != null)
	assert(cache_press.inventory.get_amount(ingot) == 2)
	assert(cache_press.inventory.get_amount(ammo) == 4)
	assert(cache_press.status_label.text == "SALVAGE: 6")
	assert(raw.get_total_amount() == 0 and made.get_total_amount() == 0)
	await get_tree().process_frame
	assert(not is_instance_valid(press))
	assert(cache_press.is_inside_tree() and cache_press.get_parent() == world)
	print("PASS G: Two independent manufacturer inventories remain in world salvage")

	var first_position: Vector3 = first.global_position
	var first_cache := service.try_destroy_with_salvage(first)
	assert(first_cache != null)
	assert(first_cache.global_position == first_position)
	assert(first_cache.inventory.get_amount(ingot) == 1)
	assert(first_stock.get_total_amount() == 0)
	assert(second.previous_segment == null)
	assert(second_stock.get_amount(ammo) == 1)
	await get_tree().process_frame
	assert(not is_instance_valid(first))
	assert(second.is_inside_tree())
	print("PASS H: Destroying first belt saves its cargo and spares next belt")

	var second_cache := service.try_destroy_with_salvage(second)
	assert(second_cache != null)
	assert(second_cache.inventory.get_amount(ammo) == 1)
	assert(second_stock.get_total_amount() == 0)
	await get_tree().process_frame
	assert(not is_instance_valid(second))
	assert(second_cache.is_inside_tree())
	print("PASS I: Second belt receives a separate surviving salvage cache")

	var empty_storage := storage_scene.instantiate() as Node3D
	world.add_child(empty_storage)
	empty_storage.global_position = Vector3(31, 0, 31)
	var empty_cache := service.try_destroy_with_salvage(empty_storage)
	assert(empty_cache != null)
	assert(empty_cache.inventory.get_total_amount() == 0)
	assert(empty_cache.status_label.text == "WRECKAGE")
	await get_tree().process_frame
	assert(not is_instance_valid(empty_storage))
	assert(empty_cache.is_inside_tree())
	print("PASS J: Empty destroyed building leaves only a wreckage placeholder")

	assert(service.successful_destructions == 5)
	assert(get_tree().get_nodes_in_group("salvage_caches").size() == 5)
	var total: int = 0
	var total_ore: int = 0
	var total_ingot: int = 0
	var total_ammo: int = 0
	for node: Node in get_tree().get_nodes_in_group("salvage_caches"):
		var cache := node as WorldSalvageCache
		assert(cache != null and cache.get_parent() == world)
		assert(cache.inventory.max_capacity == 0)
		total += cache.inventory.get_total_amount()
		total_ore += cache.inventory.get_amount(ore)
		total_ingot += cache.inventory.get_amount(ingot)
		total_ammo += cache.inventory.get_amount(ammo)
	assert(total_ore == 5 and total_ingot == 3 and total_ammo == 7)
	assert(total == 15)
	print("PASS K: Five world-owned caches conserve all 15 original item units")

	assert(irrelevant.is_inside_tree() and ghost.is_inside_tree())
	assert(zombie.is_inside_tree() and static_target.is_inside_tree())
	assert(camera.is_inside_tree())
	assert(service.try_destroy_with_salvage(static_target) == null)
	assert(service.try_destroy_with_salvage(cache_storage) == null)
	assert(service.successful_destructions == 5)
	assert(cache_storage.inventory.get_total_amount() == 7)
	print("PASS L: Remaining world, enemy and salvage are never destruction targets")

	world.queue_free()
	print("================================================")
	print("ALL 12 MAIN-WORLD SALVAGE DESTRUCTION TESTS PASSED")
	print("================================================")
