extends Node3D

# =============================================================================
# E3D5C3B2 — FINITE POWER ALLOCATION, ISOLATED F6 TEST
# =============================================================================
# Uses actual completed prototype Hub/Pole scene sources. All allocations
# are read-only observations; construction jobs are NOT automatically started,
# paused or resumed. Integration with materials/workers remains future work.


func _structure(
	path: String, label: String, location: Vector3
) -> PrototypePowerStructure:
	var scene := load(path) as PackedScene
	assert(scene != null)
	var building := scene.instantiate() as PrototypePowerStructure
	assert(building != null)
	building.name = label
	add_child(building)
	building.global_position = location
	return building


func _site(
	label: String, location: Vector3,
	authorize: bool = true
) -> ConstructionSite:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = location
	site.set_process(false)
	if authorize:
		assert(site.job.authorize())
	return site


func _ready() -> void:
	var network := ConstructionPowerCoverageNetwork.new()
	add_child(network)
	var allocator := PrototypeConstructionPowerAllocator.new()
	add_child(allocator)
	assert(not allocator.configure(null))
	assert(allocator.configure(network))
	assert(not allocator.configure(network))
	assert(allocator.get_allocations().is_empty())
	print("PASS A: Budget allocator requires one explicit topology service")

	var planned: ConstructionSite = _site(
		"Planned", Vector3(6, 0, 0), false
	)
	assert(not allocator.track_site(planned, 2))
	assert(planned.job.authorize())
	assert(not allocator.track_site(planned, 0))
	assert(not allocator.track_site(planned, -1))
	assert(not allocator.track_site(planned, 100001))
	assert(allocator.track_site(planned, 1))
	assert(not allocator.track_site(planned, 1))
	allocator.stop_tracking(planned)
	assert(allocator.get_allocated_units(planned) == 0)
	print("PASS B: Only authorized work with finite positive demand is tracked once")

	var high: ConstructionSite = _site("High", Vector3(6, 0, 0))
	var normal: ConstructionSite = _site("Normal", Vector3(6, 0, 0))
	var low: ConstructionSite = _site("Low", Vector3(6, 0, 0))
	assert(high.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(low.job.set_priority(ConstructionJob.Priority.LOW))
	assert(allocator.track_site(low, 4))
	assert(allocator.track_site(normal, 5))
	assert(allocator.track_site(high, 7))
	assert(allocator.get_allocated_units(high) == 0)
	assert(allocator.get_allocated_units(normal) == 0)
	assert(allocator.get_allocated_units(low) == 0)
	print("PASS C: No registered completed generator means zero allocation")

	var hub: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_main_hub.tscn",
		"HubA", Vector3.ZERO
	)
	var pole: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_power_pole.tscn",
		"PoleA", Vector3(6, 0, 0)
	)
	var hub_node: ConstructionPowerNetworkNode = hub.get_power_node()
	var pole_node: ConstructionPowerNetworkNode = pole.get_power_node()
	assert(network.register_node(hub_node))
	assert(network.register_node(pole_node))
	assert(hub.available_nameplate_generation() == 12)
	assert(network.is_energized(hub_node))
	assert(not network.is_energized(pole_node))
	assert(allocator.get_allocated_units(high) == 0)
	print("PASS D: Online Hub without a relay link cannot power distant work")

	assert(network.link_nodes(hub_node, pole_node))
	assert(network.covers_site(high))
	assert(allocator.get_allocated_units(high) == 7)
	assert(allocator.get_allocated_units(normal) == 5)
	assert(allocator.get_allocated_units(low) == 0)
	print("PASS E: High then Normal fit within 12; Low waits without partial grants")

	var allocations: Dictionary = allocator.get_allocations()
	assert(allocations.size() == 3)
	assert(
		int(allocations[high]) + int(allocations[normal])
		+ int(allocations[low]) == 12
	)
	assert(allocator.is_fully_allocated(high))
	assert(not allocator.is_fully_allocated(low))
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(high.job.get_progress() == 0.0)
	print("PASS F: Total assigned demand cannot exceed finite available output")

	assert(normal.job.set_availability(true, true, true))
	normal.job.advance(2.0)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	var urgent: ConstructionSite = _site("Urgent", Vector3(6, 0, 0))
	assert(urgent.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(allocator.track_site(urgent, 8))
	assert(allocator.get_allocated_units(normal) == 5)
	assert(allocator.get_allocated_units(high) == 7)
	assert(allocator.get_allocated_units(urgent) == 0)
	print("PASS G: Newly authorized High cannot preempt active Normal construction")

	assert(hub.set_generator_enabled(false))
	assert(allocator.get_allocated_units(normal) == 0)
	assert(allocator.get_allocated_units(high) == 0)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS H: Source outage clears electrical grants but never edits a job")

	assert(hub.set_generator_enabled(true))
	assert(allocator.get_allocated_units(normal) == 5)
	assert(allocator.get_allocated_units(high) == 7)
	assert(allocator.get_allocated_units(urgent) == 0)
	print("PASS I: Power restoration recomputes original bounded assignments")

	hub.rated_generation = 8
	hub.refresh_power_state()
	assert(allocator.get_allocated_units(normal) == 5)
	assert(allocator.get_allocated_units(high) == 0)
	assert(allocator.get_allocated_units(urgent) == 0)
	assert(allocator.get_allocated_units(low) == 0)
	print("PASS J: Lower generation retains active demand before waiting jobs")

	hub.rated_generation = 12
	hub.refresh_power_state()
	var second_hub: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_main_hub.tscn",
		"HubB", Vector3(12, 0, 0)
	)
	var second_node: ConstructionPowerNetworkNode = second_hub.get_power_node()
	assert(network.register_node(second_node))
	assert(network.is_energized(second_node))
	var remote: ConstructionSite = _site("OtherGrid", Vector3(12, 0, 0))
	assert(allocator.track_site(remote, 10))
	assert(allocator.get_allocated_units(remote) == 10)
	assert(allocator.get_allocated_units(urgent) == 0)
	print("PASS K: Disconnected 12-unit generator cannot subsidize another grid")

	allocator.stop_tracking(remote)
	assert(network.link_nodes(pole_node, second_node))
	assert(allocator.get_allocated_units(normal) == 5)
	assert(allocator.get_allocated_units(high) == 7)
	assert(allocator.get_allocated_units(urgent) == 8)
	assert(allocator.get_allocated_units(low) == 4)
	print("PASS L: Explicitly merged generators share 24 units without excess")

	assert(network.unlink_nodes(pole_node, second_node))
	assert(allocator.get_allocated_units(urgent) == 0)
	assert(allocator.get_allocated_units(low) == 0)
	assert(allocator.get_allocated_units(high) == 7)
	print("PASS M: Separating grids immediately restores independent budgets")

	pole.set_service_enabled(false)
	assert(allocator.get_allocated_units(high) == 0)
	assert(allocator.get_allocated_units(normal) == 0)
	pole.set_service_enabled(true)
	assert(allocator.get_allocated_units(high) == 7)
	print("PASS N: Disabled relay removes grants and restoration rechecks links")

	var edge: ConstructionSite = _site("PartiallyCovered", Vector3(6, 0, 3.2))
	assert(allocator.track_site(edge, 1))
	assert(not network.covers_site(edge))
	assert(allocator.get_allocated_units(edge) == 0)
	edge.rotation.y = PI * 0.5
	assert(allocator.get_allocated_units(edge) == 0)
	print("PASS O: Partial footprint never receives an electrical allocation")

	var synthetic := ConstructionPowerNetworkNode.new()
	synthetic.is_source = true
	synthetic.source_online = true
	synthetic.operational = true
	synthetic.coverage_radius = 4.0
	add_child(synthetic)
	synthetic.global_position = Vector3(50, 0, 0)
	assert(network.register_node(synthetic))
	var fake_site: ConstructionSite = _site("FakePower", Vector3(50, 0, 0))
	assert(allocator.track_site(fake_site, 1))
	assert(network.is_energized(synthetic))
	assert(network.covers_site(fake_site))
	assert(allocator.get_allocated_units(fake_site) == 0)
	print("PASS P: Synthetic online flags cannot contribute real Hub output")

	assert(urgent.job.cancel())
	assert(allocator.get_allocated_units(urgent) == 0)
	assert(allocator.get_allocated_units(low) == 0)
	allocator.stop_tracking(high)
	assert(allocator.get_allocated_units(low) == 4)
	low.free()
	assert(allocator.get_allocated_units(low) == 0)
	assert(allocator.track_site(high, 7))
	assert(allocator.get_allocated_units(high) == 7)
	print("PASS Q: Cancelled, untracked and freed jobs do not retain capacity")

	var health: BuildingHealthComponent = hub.get_health()
	assert(health != null)
	assert(health.take_damage(100) == 100)
	assert(hub.available_nameplate_generation() == 0)
	assert(allocator.get_allocated_units(high) == 0)
	assert(allocator.get_allocated_units(normal) == 0)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(high.job.get_progress() == 0.0)
	print("PASS R: Destroyed Hub removes power, never fabricates progress or workers")

	print("ALL 18 E3D5C3B2 FINITE CONSTRUCTION POWER TESTS PASSED")
