extends Node3D

# =============================================================================
# E3D5C3B1 — COMPLETED HUB + TIMED POWER POLE (ISOLATED)
# =============================================================================
# A prebuilt Hub supplies a limited NAMEPLATE source, not an energy budget.
# A Power Pole exists as an actual relay ONLY after construction completes.
# Synthetic test job flags are used ONLY to advance this standalone fixture.
# Main, Factory Testing Sandbox and real job dispatch stay unchanged.


func _site(label: String, location: Vector3) -> ConstructionSite:
	var definition := load(
		"res://data/buildings/prototype_power_pole.tres"
	) as BuildingDefinition
	assert(is_instance_valid(definition))
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = location
	site.set_process(false)
	return site


func _ready() -> void:
	var network := ConstructionPowerCoverageNetwork.new()
	add_child(network)
	var hub_scene := load(
		"res://scenes/buildings/prototype_main_hub.tscn"
	) as PackedScene
	assert(hub_scene != null)
	var hub := hub_scene.instantiate() as PrototypePowerStructure
	assert(hub != null)
	var hub_node: ConstructionPowerNetworkNode = hub.get_power_node()
	assert(is_instance_valid(hub_node))
	assert(not hub_node.operational)
	assert(not hub_node.source_online)
	print("PASS A: Detached Hub prototype cannot energize the network")

	add_child(hub)
	hub.global_position = Vector3.ZERO
	assert(network.register_node(hub_node))
	assert(hub.rated_generation == 12)
	assert(hub.available_nameplate_generation() == 12)
	assert(hub_node.is_source and hub_node.operational and hub_node.source_online)
	assert(network.is_energized(hub_node))
	print("PASS B: Completed prebuilt Hub owns an online rated source")

	var hub_health: BuildingHealthComponent = hub.get_health()
	assert(hub_health != null and hub_health.is_intact())
	assert(hub_node.coverage_radius == 4.5)
	assert(hub_node.link_range == 8.0)
	print("PASS C: Hub has actual structure health and bounded network reach")

	var pole_definition := load(
		"res://data/buildings/prototype_power_pole.tres"
	) as BuildingDefinition
	assert(pole_definition != null)
	assert(is_equal_approx(pole_definition.construction_seconds, 6.0))
	var pole_cost: Dictionary = ConstructionMaterialBill.get_costs(
		pole_definition
	)
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ingot != null)
	assert(pole_cost == {ingot: 2})
	print("PASS D: Pole definition carries its own timer and material bill")

	var site: ConstructionSite = _site("PlannedPowerPole", Vector3(6, 0, 0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.get_node_or_null("ConstructionPowerNetworkNode") == null)
	assert(not network.covers_site(site))
	print("PASS E: Unfinished Power Pole has no operational electrical node")

	assert(site.job.authorize())
	site.job.advance(20.0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	print("PASS F: Authorizing a Pole alone cannot bypass its construction gates")

	assert(site.job.set_availability(true, false, true))
	site.job.advance(20.0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	assert(site.job.set_availability(true, true, false))
	site.job.advance(20.0)
	assert(site.job.get_progress() == 0.0)
	print("PASS G: Missing materials or workers cannot complete a power relay")

	var built: Array[Node3D] = []
	site.building_completed.connect(
		func(building: Node3D) -> void: built.append(building)
	)
	assert(site.job.set_availability(true, true, true))
	site.job.advance(3.0)
	assert(is_equal_approx(site.job.get_progress(), 0.5))
	assert(built.is_empty())
	assert(site.get_node_or_null("ConstructionPowerNetworkNode") == null)
	print("PASS H: Half-built Pole preserves time without creating power")

	site.job.advance(3.0)
	assert(site.job.state == ConstructionJob.State.COMPLETE)
	assert(site.is_completed())
	assert(site.is_queued_for_deletion())
	assert(built.size() == 1)
	var pole := built[0] as PrototypePowerStructure
	assert(pole != null)
	var pole_node: ConstructionPowerNetworkNode = pole.get_power_node()
	assert(pole_node != null and pole_node.operational)
	assert(not pole_node.is_source and not pole_node.source_online)
	print("PASS I: Only finished construction instantiates the physical relay")

	assert(network.register_node(pole_node))
	assert(not network.is_energized(pole_node))
	assert(not network.covers_site(site))
	var remote: ConstructionSite = _site("RemoteStorage", Vector3(6, 0, 0))
	assert(not network.covers_site(remote))
	assert(network.link_nodes(hub_node, pole_node))
	assert(network.is_energized(pole_node))
	assert(network.covers_site(remote))
	print("PASS J: Completed Pole requires explicit energized Hub connection")

	assert(hub.set_generator_enabled(false))
	assert(hub.available_nameplate_generation() == 0)
	assert(not network.is_energized(pole_node))
	assert(not network.covers_site(remote))
	assert(hub.set_generator_enabled(true))
	assert(network.covers_site(remote))
	print("PASS K: Actual Hub generator switch removes/restores relay coverage")

	pole.set_service_enabled(false)
	assert(not pole_node.operational)
	assert(not network.covers_site(remote))
	pole.set_service_enabled(true)
	assert(network.covers_site(remote))
	assert(not pole.set_generator_enabled(true))
	assert(not pole_node.is_source)
	print("PASS L: Pole service switch controls relay but cannot generate energy")

	assert(remote.job.authorize())
	assert(network.covers_site(remote))
	assert(remote.job.get_wait_reasons().size() == 3)
	remote.job.advance(30.0)
	assert(remote.job.get_progress() == 0.0)
	print("PASS M: Verified structure coverage does not grant job readiness")

	var pole_health: BuildingHealthComponent = pole.get_health()
	assert(pole_health != null)
	assert(pole_health.take_damage(100) == 100)
	assert(not pole_health.is_intact())
	assert(not pole_node.operational and not pole_node.source_online)
	assert(not network.covers_site(remote))
	pole.set_service_enabled(true)
	assert(not pole_node.operational)
	print("PASS N: Destroyed Pole remains offline despite attempted restart")

	var alternate := hub_scene.instantiate() as PrototypePowerStructure
	add_child(alternate)
	alternate.global_position = Vector3(40, 0, 0)
	var alternate_node: ConstructionPowerNetworkNode = alternate.get_power_node()
	assert(network.register_node(alternate_node))
	assert(network.is_energized(alternate_node))
	alternate.queue_free()
	assert(not network.is_energized(alternate_node))
	print("PASS O: Queued-for-removal power structure loses coverage immediately")

	assert(hub_health.take_damage(100) == 100)
	assert(not hub_node.operational and not hub_node.source_online)
	assert(hub.available_nameplate_generation() == 0)
	assert(not network.is_energized(hub_node))
	hub.set_service_enabled(true)
	assert(not network.is_energized(hub_node))
	assert(remote.job.state == ConstructionJob.State.QUEUED)
	assert(remote.job.get_progress() == 0.0)
	print("PASS P: Destroyed Hub cannot restart or bypass construction requirements")

	print("ALL 16 E3D5C3B1 COMPLETED POWER STRUCTURE TESTS PASSED")
