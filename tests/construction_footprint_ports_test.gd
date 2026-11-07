extends Node3D

# =============================================================================
# CONSTRUCTION FOOTPRINT — PHYSICS AND PORT ACTIVATION REGRESSION
# =============================================================================
# Uses the actual Godot 3D physics world to verify that an unfinished
# construction site reserves its footprint and cannot receive cargo.

func _ready() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	assert(site.setup(definition, 10.0))
	site.position = Vector3(0.0, 0.0, 0.0)
	add_child(site)
	site.set_process(false)
	await get_tree().physics_frame

	var reserved := site.get_node("ReservedFootprint") as StaticBody3D
	assert(reserved != null)
	assert(reserved.collision_layer & 4 != 0)
	var shape := site.get_node("ReservedFootprint/CollisionShape3D") as CollisionShape3D
	assert(shape != null and not shape.disabled)
	print("PASS A: Unfinished Storage reserves the placement-blocker physics layer")

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = BoxShape3D.new()
	(query.shape as BoxShape3D).size = Vector3(0.5, 0.5, 0.5)
	query.transform = Transform3D(Basis.IDENTITY, Vector3(0.0, 0.3, 0.0))
	query.collision_mask = 4
	var hits := get_world_3d().direct_space_state.intersect_shape(query, 8)
	var hit_site := false
	for result: Dictionary in hits:
		if result.get("collider") == reserved:
			hit_site = true
	assert(hit_site)
	print("PASS B: Real physics overlap query detects unfinished Storage")

	assert(site.get_node_or_null("InputPort") == null)
	assert(site.get_node_or_null("OutputPort") == null)
	assert(site.get_node_or_null("InventoryComponent") == null)
	assert(site.lifecycle.state == ConstructionLifecycle.State.CONSTRUCTING)
	print("PASS C: Unfinished site has no operational inventory or ports")

	var finished: Array[Node3D] = []
	site.building_completed.connect(func(building: Node3D) -> void: finished.append(building))
	site.lifecycle.advance(10.0)
	assert(finished.size() == 1)
	var building := finished[0]
	assert(building.get_node_or_null("InputPort") is ItemPortComponent)
	assert(building.get_node_or_null("OutputPort") is ItemPortComponent)
	assert(building.get_node_or_null("InventoryComponent") is InventoryComponent)
	assert(site.is_queued_for_deletion())
	print("PASS D: Completed Storage activates real inventory and physical ports")

	print("ALL 4 CONSTRUCTION FOOTPRINT AND PORT REGRESSION CHECKS PASSED")
