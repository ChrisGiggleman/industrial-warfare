extends Node

# =============================================================================
# TIMED STORAGE PLACEMENT — OPT-IN WORLD INTEGRATION
# =============================================================================
# Tests the WorldInteraction construction-site entry point without changing
# the default Main scene or specialized conveyor snapping behavior.

func _ready() -> void:
	var packed := load("res://scenes/core/main.tscn") as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller = world.get_node("WorldInteraction")
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	await get_tree().process_frame

	assert(not controller.enable_timed_storage_construction)
	assert(controller.build_hotbar.get_id(2) == &"test_storage")
	print("PASS A: Existing world defaults to instant placement")

	controller.enable_timed_storage_construction = true
	controller.storage_construction_seconds = 10.0
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var transform := Transform3D(
		Basis(Vector3.UP, deg_to_rad(90.0)),
		Vector3(3.0, 0.0, 1.0)
	)
	var site: ConstructionSite = controller._place_timed_storage_site(
		definition, transform
	)
	assert(is_instance_valid(site))
	site.set_process(false)
	assert(site.get_parent() == world)
	assert(site.is_in_group("construction_sites"))
	assert(site.get_node_or_null("ReservedFootprint/CollisionShape3D") != null)
	assert(site.global_transform.is_equal_approx(transform))
	assert(not site.is_completed())
	print("PASS B: Controller places a reserved nonoperational Storage site")

	var created: Array[Node3D] = []
	site.building_completed.connect(
		func(building: Node3D) -> void: created.append(building)
	)
	site.lifecycle.advance(5.0)
	assert(is_equal_approx(site.get_progress(), 0.5))
	assert(created.is_empty())
	site.lifecycle.advance(5.0)
	assert(created.size() == 1)
	var building := created[0]
	assert(building.get_parent() == world)
	assert(building.global_transform.is_equal_approx(transform))
	assert(building.get_node_or_null("InventoryComponent") is InventoryComponent)
	assert((building.get_node_or_null("BuildingRuntime") as BuildingRuntime).building_definition == definition)
	assert(site.is_queued_for_deletion())
	print("PASS C: Construction completes and activates real Storage only at 100%")

	assert(controller._place_timed_storage_site(null, transform) == null)
	var other := load("res://data/buildings/test_smelter.tres") as BuildingDefinition
	assert(controller._place_timed_storage_site(other, transform) == null)
	assert(controller.build_hotbar.get_id(4) == &"conveyor_belt")
	print("PASS D: Entry point rejects invalid definitions and leaves belt identity intact")

	world.queue_free()
	print("ALL 4 TIMED STORAGE WORLD INTEGRATION CHECKS PASSED")
