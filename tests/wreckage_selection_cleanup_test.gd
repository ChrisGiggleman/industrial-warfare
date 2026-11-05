extends Node

# =============================================================================
# WRECKAGE INTERACTION — INSPECTION AND LOSSLESS CLEANUP REGRESSION
# =============================================================================

# Uses Main's real world salvage service, selection/HUD and controlled
# demolition. The test moves stocked wreckage into an independent
# InventoryComponent before clearing it; this is NOT a player pickup
# mechanism and does not modify physical conveyor transport.


func _ready() -> void:
	print("\n===== WRECKAGE SELECTION AND CLEANUP REGRESSION =====")

	var world_scene := load("res://scenes/core/main.tscn") as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(
		world_scene != null and storage_scene != null
		and ore != null and ammo != null
	)

	var world := world_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	var controller = world.get_node("WorldInteraction")
	var hud := world.get_node(
		"ProductionDebugHUD"
	) as ProductionDebugHUD
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	assert(
		service != null and controller != null
		and hud != null and zombie != null
	)
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	print("PASS A: Main offers world salvage, selection and the production HUD")

	var empty_source := storage_scene.instantiate() as Node3D
	world.add_child(empty_source)
	empty_source.global_position = Vector3(30, 0, 30)
	var empty_cache := service.try_destroy_with_salvage(empty_source)
	assert(empty_cache != null)
	assert(empty_cache.get_parent() == world)
	assert(empty_cache.is_in_group("salvage_caches"))
	assert(empty_cache.is_in_group("selectable"))
	assert(not empty_cache.is_in_group("player_built"))
	assert(empty_cache.inventory.get_total_amount() == 0)
	assert(empty_cache.status_label.text == "WRECKAGE")
	assert(empty_cache.can_clear_safely())
	print("PASS B: Empty wreckage exists independently and is selectable")

	var body := empty_cache.get_node("SelectableBody") as StaticBody3D
	var shape := empty_cache.get_node(
		"SelectableBody/CollisionShape3D"
	) as CollisionShape3D
	assert(body != null and shape != null)
	assert(body.collision_layer == 2)
	assert(body.collision_mask == 0)
	assert(not shape.disabled)
	assert(is_instance_valid(empty_cache.selection_mesh))
	print("PASS C: Wreckage has a selection-only Layer-2 collision box")

	# Wait for the actual physics shape to register, then raycast from
	# above the remote empty wreckage, like the existing mouse selector.
	await get_tree().physics_frame
	var at: Vector3 = empty_cache.global_position
	var query := PhysicsRayQueryParameters3D.create(
		at + Vector3(0, 3, 0),
		at + Vector3(0, -1, 0)
	)
	query.collision_mask = 2
	query.collide_with_areas = true
	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)
	assert(not hit.is_empty())
	var collider: Node = hit["collider"]
	var owner: Node = collider
	while is_instance_valid(owner) and not owner.is_in_group("selectable"):
		owner = owner.get_parent()
	assert(owner == empty_cache)
	print("PASS D: Selection ray reaches wreckage through its physical hitbox")

	controller._select_object(empty_cache)
	assert(controller.selected_object == empty_cache)
	assert(hud.selected_building == empty_cache)
	assert(empty_cache.is_selected)
	assert(
		empty_cache.selection_mesh.material_override
		== empty_cache._selection_material
	)
	hud._process(0.0)
	assert(hud.info_label.text.contains("Object: Wreckage"))
	assert(hud.info_label.text.contains("Total Items: 0"))
	print("PASS E: Clicking wreckage highlights it and opens the shared info HUD")

	assert(hud.info_label.text.contains("Empty: can remove in Demolition Mode"))
	assert(not hud.activity_progress_bar.visible)
	empty_cache.set_demolition_hover(true)
	assert(empty_cache.is_demolition_hovered)
	assert(
		empty_cache.selection_mesh.material_override
		== empty_cache._clearable_material
	)
	empty_cache.set_demolition_hover(false)
	assert(empty_cache.is_selected)
	assert(
		empty_cache.selection_mesh.material_override
		== empty_cache._selection_material
	)
	print("PASS F: Empty wreckage gets demolition hover and restores selection")

	assert(controller._try_clear_salvage_cache(empty_cache))
	assert(empty_cache.is_queued_for_deletion())
	assert(controller.selected_object == null)
	assert(hud.selected_building == null)
	assert(hud.info_label.text.contains("No object selected"))
	assert(not controller._try_clear_salvage_cache(empty_cache))
	await get_tree().process_frame
	assert(not is_instance_valid(empty_cache))
	assert(service.successful_destructions == 1)
	print("PASS G: Clearing empty wreckage removes only it and clears selection")

	var loaded_source := storage_scene.instantiate() as Node3D
	world.add_child(loaded_source)
	loaded_source.global_position = Vector3(32, 0, 30)
	var loaded_stock := loaded_source.get_node(
		"InventoryComponent"
	) as InventoryComponent
	assert(loaded_stock.add_item(ore, 6) == 6)
	assert(loaded_stock.add_item(ammo, 4) == 4)
	var loaded_cache := service.try_destroy_with_salvage(loaded_source)
	assert(loaded_cache != null)
	assert(loaded_cache.inventory.get_amount(ore) == 6)
	assert(loaded_cache.inventory.get_amount(ammo) == 4)
	assert(loaded_cache.inventory.get_total_amount() == 10)
	assert(loaded_cache.status_label.text == "SALVAGE: 10")
	assert(not loaded_cache.can_clear_safely())
	print("PASS H: Destroyed stocked Storage preserves ten materials in salvage")

	controller._select_object(loaded_cache)
	hud._process(0.0)
	assert(loaded_cache.is_selected)
	assert(hud.info_label.text.contains("Contains Resources"))
	assert(hud.info_label.text.contains("Total Items: 10"))
	assert(hud.info_label.text.contains(ore.display_name + ": 6"))
	assert(hud.info_label.text.contains(ammo.display_name + ": 4"))
	assert(hud.info_label.text.contains("Protected: recover contents"))
	print("PASS I: Selected stocked wreckage lists actual item names and counts")

	loaded_cache.set_demolition_hover(true)
	assert(
		loaded_cache.selection_mesh.material_override
		== loaded_cache._protected_material
	)
	assert(not controller._try_clear_salvage_cache(loaded_cache))
	assert(not loaded_cache.is_queued_for_deletion())
	assert(loaded_cache.inventory.get_total_amount() == 10)
	assert(hud.selected_building == loaded_cache)
	assert(service.successful_destructions == 2)
	print("PASS J: Protected salvage cannot be demolished or lose its contents")

	# Simulate a later collection implementation by transferring to an
	# independently owned inventory via the existing lossless API.
	var recovered := InventoryComponent.new()
	recovered.name = "TestRecoveryDestination"
	recovered.max_capacity = 0
	world.add_child(recovered)
	assert(loaded_cache.inventory.transfer_to(recovered, ore, 6) == 6)
	assert(loaded_cache.inventory.transfer_to(recovered, ammo, 4) == 4)
	assert(recovered.get_total_amount() == 10)
	assert(loaded_cache.inventory.items.is_empty())

	# Invalid dictionary keys still prevent wreckage cleanup.
	loaded_cache.inventory.items["invalid_key"] = 1
	assert(not loaded_cache.can_clear_safely())
	assert(not controller._try_clear_salvage_cache(loaded_cache))
	loaded_cache.inventory.items.erase("invalid_key")
	loaded_cache.refresh_display()
	hud._process(0.0)
	assert(loaded_cache.status_label.text == "WRECKAGE")
	assert(loaded_cache.can_clear_safely())
	assert(hud.info_label.text.contains("Empty: can remove in Demolition Mode"))
	print("PASS K: After safe resource transfer, empty wreckage becomes clearable")

	assert(controller._try_clear_salvage_cache(loaded_cache))
	assert(loaded_cache.is_queued_for_deletion())
	assert(controller.selected_object == null)
	assert(hud.selected_building == null)
	await get_tree().process_frame
	assert(not is_instance_valid(loaded_cache))
	assert(recovered.get_amount(ore) == 6)
	assert(recovered.get_amount(ammo) == 4)
	assert(recovered.get_total_amount() == 10)
	assert(world.is_inside_tree() and zombie.is_inside_tree())
	assert(get_tree().get_nodes_in_group("salvage_caches").is_empty())
	print("PASS L: Cleanup preserves ten transferred resources and the rest of Main")

	world.queue_free()
	print("================================================")
	print("ALL 12 WRECKAGE SELECTION AND CLEANUP TESTS PASSED")
	print("================================================")
