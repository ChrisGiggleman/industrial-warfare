extends Node3D

# =============================================================================
# E3D5C3A — EXPLICIT POWER NETWORK / COVERAGE (ISOLATED F6)
# =============================================================================
# Manual fixture flags simulate future actual Hub/Power Pole conditions.
# These flags NEVER grant worker slots or ConstructionJob availability.


func _node(
	label: String, location: Vector3, root: bool = false,
	coverage: float = 3.0, reach: float = 5.0
) -> ConstructionPowerNetworkNode:
	var node := ConstructionPowerNetworkNode.new()
	node.name = label
	node.is_source = root
	node.coverage_radius = coverage
	node.link_range = reach
	add_child(node)
	node.global_position = location
	return node


func _site(label: String, location: Vector3) -> ConstructionSite:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
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
	var site: ConstructionSite = _site("NearPole", Vector3(4, 0, 0))
	assert(not network.covers_site(site))
	assert(network.get_energized_nodes().is_empty())
	print("PASS A: No registered source means no construction power")

	assert(not network.register_node(null))
	var invalid := ConstructionPowerNetworkNode.new()
	invalid.coverage_radius = 0.0
	add_child(invalid)
	assert(not network.register_node(invalid))
	invalid.free()
	print("PASS B: Missing and invalid power nodes cannot register")

	var hub: ConstructionPowerNetworkNode = _node(
		"TestHub", Vector3.ZERO, true
	)
	var pole: ConstructionPowerNetworkNode = _node(
		"RelayA", Vector3(4, 0, 0)
	)
	assert(network.register_node(hub))
	assert(network.register_node(pole))
	assert(not network.register_node(pole))
	assert(not network.is_energized(hub))
	print("PASS C: Registered sources and poles begin inactive")

	hub.operational = true
	hub.source_online = true
	pole.operational = true
	assert(network.is_energized(hub))
	assert(not network.is_energized(pole))
	assert(not network.covers_site(site))
	print("PASS D: Pole coverage overlap cannot invent a network link")

	hub.source_online = false
	assert(network.link_nodes(hub, pole))
	assert(not network.link_nodes(hub, pole))
	assert(not network.is_energized(pole))
	assert(not network.covers_site(site))
	print("PASS E: An explicit link without generation is not powered")

	hub.source_online = true
	assert(network.is_energized(hub))
	assert(network.is_energized(pole))
	assert(network.covers_site(site))
	print("PASS F: Connected operational pole covers the complete site")

	var too_far: ConstructionSite = _site(
		"FootprintOutside", Vector3(6.8, 0, 0)
	)
	assert(not network.covers_site(too_far))
	print("PASS G: Partial-footprint coverage cannot enable construction")

	var rotated: ConstructionSite = _site(
		"RotationCoverage", Vector3(5.8, 0, 0)
	)
	assert(network.covers_site(rotated))
	rotated.rotation.y = PI * 0.5
	assert(not network.covers_site(rotated))
	print("PASS H: Rotated Storage footprint uses the real world-space corners")

	var distant: ConstructionPowerNetworkNode = _node(
		"TooFarToLink", Vector3(30, 0, 0)
	)
	distant.operational = true
	assert(network.register_node(distant))
	assert(not network.link_nodes(hub, distant))
	assert(not network.is_energized(distant))
	print("PASS I: Relays beyond explicit link range cannot join the network")

	var second: ConstructionPowerNetworkNode = _node(
		"RelayB", Vector3(8, 0, 0), false, 2.5
	)
	second.operational = true
	assert(network.register_node(second))
	assert(network.link_nodes(pole, second))
	var frontier: ConstructionSite = _site(
		"SecondPoleCoverage", Vector3(8, 0, 0)
	)
	assert(network.is_energized(second))
	assert(network.covers_site(frontier))
	print("PASS J: Connected relay chains can extend construction coverage")

	pole.operational = false
	assert(not network.is_energized(pole))
	assert(not network.is_energized(second))
	assert(not network.covers_site(frontier))
	pole.operational = true
	assert(network.covers_site(frontier))
	print("PASS K: Disabled intermediate relay cuts its downstream power")

	second.global_position = Vector3(20, 0, 0)
	assert(not network.is_energized(second))
	assert(not network.covers_site(frontier))
	second.global_position = Vector3(8, 0, 0)
	assert(network.covers_site(frontier))
	print("PASS L: Moving a relay beyond its link range breaks coverage")

	hub.source_online = false
	assert(not network.is_energized(hub))
	assert(not network.covers_site(frontier))
	hub.source_online = true
	assert(network.covers_site(frontier))
	print("PASS M: Source outage removes coverage and restoration rebuilds it")

	assert(network.unlink_nodes(pole, second))
	assert(not network.unlink_nodes(pole, second))
	assert(not network.covers_site(frontier))
	assert(network.link_nodes(pole, second))
	print("PASS N: Explicit disconnect releases the downstream relay")

	var isolated: ConstructionPowerNetworkNode = _node(
		"NearbyDisconnected", Vector3(13, 0, 0), false, 3.0
	)
	isolated.operational = true
	assert(network.register_node(isolated))
	var isolated_site: ConstructionSite = _site(
		"DisconnectedFootprint", Vector3(13, 0, 0)
	)
	assert(not network.covers_site(isolated_site))
	assert(network.link_nodes(second, isolated))
	assert(network.covers_site(isolated_site))
	isolated.free()
	assert(not network.covers_site(isolated_site))
	print("PASS O: Disconnected/destroyed poles never create phantom coverage")

	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.job.authorize())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(network.covers_site(site))
	assert(site.job.get_wait_reasons().size() == 3)
	assert(site.job.get_progress() == 0.0)
	site.job.advance(100.0)
	assert(site.job.get_progress() == 0.0)
	print("PASS P: Coverage inspection cannot grant materials, workers or time")

	print("ALL 16 E3D5C3A POWER COVERAGE NETWORK TESTS PASSED")
