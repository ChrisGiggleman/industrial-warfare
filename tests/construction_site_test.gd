extends Node

# =============================================================================
# CONSTRUCTION SITE — REAL STORAGE ACTIVATION REGRESSION
# =============================================================================

func _ready() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	assert(site.setup(definition, 10.0))
	site.position = Vector3(4.0, 0.0, 2.0)
	site.rotation_degrees.y = 90.0
	add_child(site)
	site.set_process(false)
	assert(site.is_in_group("construction_sites"))
	assert(site.get_node_or_null("ReservedFootprint/CollisionShape3D") != null)
	assert(site.get_node_or_null("ConstructionPlaceholder") != null)
	assert(not site.is_completed())
	print("PASS A: Construction site reserves footprint without activating storage")

	assert(site.lifecycle.state == ConstructionLifecycle.State.CONSTRUCTING)
	site.lifecycle.advance(4.0)
	assert(is_equal_approx(site.get_progress(), 0.4))
	assert(not site.is_completed())
	print("PASS B: Unfinished construction advances without spawning an active building")

	var created: Array[Node3D] = []
	site.building_completed.connect(func(building: Node3D) -> void: created.append(building))
	site.lifecycle.advance(6.0)
	assert(created.size() == 1)
	var building := created[0]
	assert(is_instance_valid(building))
	assert(building.get_node_or_null("InventoryComponent") is InventoryComponent)
	var runtime := building.get_node_or_null("BuildingRuntime") as BuildingRuntime
	assert(runtime != null and runtime.building_definition == definition)
	assert(building.global_position.distance_to(Vector3(4, 0, 2)) < 0.01)
	assert(is_equal_approx(building.rotation_degrees.y, 90.0))
	print("PASS C: Completion spawns real Storage with definition, position and rotation")

	assert(site.is_queued_for_deletion())
	assert(not building.is_queued_for_deletion())
	assert(building.get_node_or_null("InputPort") != null)
	assert(building.get_node_or_null("OutputPort") != null)
	print("PASS D: Construction site is retired; completed building has real ports")

	print("ALL 4 CONSTRUCTION SITE REGRESSION CHECKS PASSED")
