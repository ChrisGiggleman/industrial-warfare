extends Node3D

# =============================================================================
# DEFINITION-DRIVEN CONSTRUCTION DURATION REGRESSION
# =============================================================================
# Tests durations in BuildingDefinition resources and the opt-in job-driven
# construction path. Does not change gameplay Build Mode or live power state.

func _ready() -> void:
	var expected_seconds: Dictionary = {
		"conveyor_belt": 2.0,
		"conveyor_merger": 5.0,
		"conveyor_splitter": 5.0,
		"prototype_ammunition_press": 18.0,
		"prototype_defensive_turret": 15.0,
		"test_building_large": 20.0,
		"test_extractor": 12.0,
		"test_smelter": 16.0,
		"test_storage": 10.0
	}
	var definitions: Dictionary = {}
	for identity: String in expected_seconds:
		var definition := load(
			"res://data/buildings/" + identity + ".tres"
		) as BuildingDefinition
		assert(is_instance_valid(definition))
		assert(definition.building_id == StringName(identity))
		assert(is_instance_valid(definition.building_scene))
		assert(is_finite(definition.construction_seconds))
		assert(is_equal_approx(
			definition.construction_seconds,
			float(expected_seconds[identity])
		))
		definitions[identity] = definition
	print("PASS A: All nine buildable definitions have positive independent durations")

	var default_definition := BuildingDefinition.new()
	assert(is_equal_approx(default_definition.construction_seconds, 10.0))
	var invalid := (definitions["test_storage"] as BuildingDefinition).duplicate() as BuildingDefinition
	assert(invalid != null)
	invalid.construction_seconds = 0.0
	var rejected := ConstructionSite.new()
	assert(not rejected.setup_with_definition_job(invalid))
	invalid.construction_seconds = -2.0
	assert(not rejected.setup_with_definition_job(invalid))
	rejected.free()
	print("PASS B: Default duration is safe; nonpositive definition times are rejected")

	var storage := definitions["test_storage"] as BuildingDefinition
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(storage))
	site.position = Vector3(5.0, 0.0, 4.0)
	site.rotation_degrees.y = 90.0
	add_child(site)
	site.set_process(false)
	assert(site.job != null)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(is_equal_approx(site.job.get_remaining_seconds(), 10.0))
	assert(is_equal_approx(site.construction_duration, storage.construction_seconds))
	assert(site.get_node_or_null("ReservedFootprint/CollisionShape3D") != null)
	assert(site.get_planned_port(true) != null)
	assert(site.get_node_or_null("InventoryComponent") == null)
	print("PASS C: Storage blueprint reads 10-second definition and stays inactive")

	assert(site.job.set_availability(false, true, true))
	assert(site.job.authorize())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_wait_reasons() == [&"power"])
	site._process(50.0)
	assert(is_zero_approx(site.get_progress()))
	print("PASS D: Unpowered authorized Storage cannot advance its timer")

	assert(site.job.set_availability(true, true, true))
	site._process(4.0)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(site.get_progress(), 0.4))
	assert(is_equal_approx(site.job.get_remaining_seconds(), 6.0))
	print("PASS E: Storage builds for its own configured duration")

	assert(site.job.set_availability(false, true, true))
	site._process(100.0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(site.get_progress(), 0.4))
	assert(site.get_node_or_null("InventoryComponent") == null)
	print("PASS F: Power pause preserves progress and inactive footprint")

	var completed: Array[Node3D] = []
	site.building_completed.connect(
		func(building: Node3D) -> void: completed.append(building)
	)
	assert(site.job.set_availability(true, true, true))
	site._process(6.0)
	assert(completed.size() == 1)
	assert(site.is_queued_for_deletion())
	var building := completed[0]
	assert(building.get_node_or_null("InventoryComponent") is InventoryComponent)
	assert(building.get_node_or_null("InputPort") is ItemPortComponent)
	assert(building.global_position.distance_to(Vector3(5.0, 0.0, 4.0)) < 0.01)
	assert(is_equal_approx(building.rotation_degrees.y, 90.0))
	var runtime := building.get_node("BuildingRuntime") as BuildingRuntime
	assert(runtime != null and runtime.building_definition == storage)
	print("PASS G: Storage activates once at 10 seconds with its true runtime")

	var belt_definition := definitions["conveyor_belt"] as BuildingDefinition
	var belt_site := ConstructionSite.new()
	assert(belt_site.setup_with_definition_job(
		belt_definition, false, false, false
	))
	belt_site.position = Vector3(-6.0, 0.0, 3.0)
	add_child(belt_site)
	belt_site.set_process(false)
	assert(is_equal_approx(belt_site.job.get_remaining_seconds(), 2.0))
	assert(belt_site.get_node_or_null("PlannedInputEndpoint") is Marker3D)
	assert(belt_site.get_node_or_null("PlannedOutputEndpoint") is Marker3D)
	assert(belt_site.get_node_or_null("CargoInventory") == null)
	assert(belt_site.get_node_or_null("ConveyorTransportTimer") == null)
	print("PASS H: Two-second belt blueprint exposes markers without active transport")

	var completed_belts: Array[Node3D] = []
	belt_site.building_completed.connect(
		func(entity: Node3D) -> void: completed_belts.append(entity)
	)
	assert(belt_site.job.authorize())
	belt_site._process(1.0)
	assert(is_equal_approx(belt_site.get_progress(), 0.5))
	assert(completed_belts.is_empty())
	belt_site._process(1.0)
	assert(completed_belts.size() == 1)
	var belt := completed_belts[0] as ConveyorSegment
	assert(belt != null)
	assert(belt.get_node_or_null("CargoInventory") is InventoryComponent)
	assert(belt.get_node_or_null("ConveyorTransportTimer") is ConveyorTransportTimer)
	assert(belt.can_demolish_safely())
	print("PASS I: Conveyor activates cargo and timers after its two-second build")

	for identity: String in ["conveyor_merger", "conveyor_splitter"]:
		var definition := definitions[identity] as BuildingDefinition
		var port_site := ConstructionSite.new()
		assert(port_site.setup_with_definition_job(definition))
		port_site.position = Vector3(10.0 if identity == "conveyor_merger" else 15.0, 0.0, -5.0)
		add_child(port_site)
		port_site.set_process(false)
		assert(is_equal_approx(port_site.job.get_remaining_seconds(), 5.0))
		assert(port_site.get_node_or_null("BuildingRuntime") == null)
		assert(port_site.get_node_or_null("PlannedInputPort") is Marker3D
			or port_site.get_node_or_null("PlannedInputPortA") is Marker3D)
		assert(port_site.job.cancel())
		assert(port_site.is_queued_for_deletion())
	print("PASS J: Splitter and merger use separate five-second nonoperational plans")

	var press_definition := definitions["prototype_ammunition_press"] as BuildingDefinition
	var press_site := ConstructionSite.new()
	assert(press_site.setup_with_definition_job(press_definition))
	add_child(press_site)
	press_site.set_process(false)
	assert(is_equal_approx(press_site.job.get_remaining_seconds(), 18.0))
	assert(press_site.get_node_or_null("ProducerComponent") == null)
	assert(press_site.job.authorize())
	assert(press_site.job.set_availability(true, true, false))
	press_site._process(50.0)
	assert(is_zero_approx(press_site.get_progress()))
	assert(press_site.job.cancel())
	print("PASS K: Ammunition production stays inactive until a worker is available")

	var legacy := ConstructionSite.new()
	assert(legacy.setup(storage, 3.0))
	add_child(legacy)
	legacy.set_process(false)
	assert(legacy.job == null)
	assert(is_equal_approx(legacy.construction_duration, 3.0))
	assert(legacy.lifecycle.state == ConstructionLifecycle.State.CONSTRUCTING)
	var legacy_completed: Array[Node3D] = []
	legacy.building_completed.connect(
		func(entity: Node3D) -> void: legacy_completed.append(entity)
	)
	legacy.lifecycle.advance(3.0)
	assert(legacy_completed.size() == 1)
	assert(legacy.is_queued_for_deletion())
	print("PASS L: Existing manual-duration Storage construction remains unchanged")

	print("ALL 12 BUILDING CONSTRUCTION DURATION TESTS PASSED")
