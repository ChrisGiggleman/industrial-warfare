extends Node3D

# =============================================================================
# E3C3B — FACTORY-WIDE NAMED BLUEPRINT PORT ACTIVATION
# =============================================================================
# Isolated test world: no Main-scene flags, mouse raycasts, or sandbox cheats.
# Tests all named ports, exclusive claims, completion in both orders,
# reciprocal real links, and final claim cleanup.

const BUILDINGS: Array[Dictionary] = [
	{"path": "res://data/buildings/test_extractor.tres", "in": 0, "out": 1},
	{"path": "res://data/buildings/test_storage.tres", "in": 1, "out": 1},
	{"path": "res://data/buildings/test_smelter.tres", "in": 1, "out": 1},
	{"path": "res://data/buildings/conveyor_merger.tres", "in": 3, "out": 1},
	{"path": "res://data/buildings/conveyor_splitter.tres", "in": 1, "out": 3},
	{"path": "res://data/buildings/prototype_ammunition_press.tres", "in": 1, "out": 1},
	{"path": "res://data/buildings/prototype_defensive_turret.tres", "in": 1, "out": 0}
]


func _site(
	root: Node3D, definition: BuildingDefinition, placement: Transform3D
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	root.add_child(site)
	site.global_transform = placement
	site.set_process(false)
	return site


func _complete(site: ConstructionSite) -> Node3D:
	var completed: Array[Node3D] = []
	site.building_completed.connect(
		func(entity: Node3D) -> void: completed.append(entity)
	)
	assert(site.job.authorize())
	assert(site.job.set_availability(true, true, true))
	site._process(site.target_definition.construction_seconds)
	assert(completed.size() == 1)
	var built: Node3D = completed[0]
	if built is ConveyorSegment:
		var timer := built.get_node_or_null(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer
		if timer != null:
			timer.set_process(false)
	return built


func _ready() -> void:
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(belt_def != null)
	var root := Node3D.new()
	add_child(root)
	var broker := PlannedEndpointClaimBroker.new()
	add_child(broker)
	var registry := PlannedBuildingPortReservations.new()
	add_child(registry)
	assert(registry.set_claim_broker(broker))
	var activator := PlannedBuildingPortActivator.new()
	add_child(activator)
	assert(activator.bind_registry(registry))
	var committed: Array[int] = []
	activator.connection_committed.connect(
		func(id: int, _building: Node3D, _belt: ConveyorSegment, _input: bool) -> void:
			committed.append(id)
	)
	print("PASS A: Named building ports share one exclusive claim broker")

	var total_ports: int = 0
	for case_index: int in range(BUILDINGS.size()):
		var spec: Dictionary = BUILDINGS[case_index]
		var definition := load(spec["path"]) as BuildingDefinition
		assert(definition != null)
		var building_site := _site(
			root, definition,
			Transform3D(Basis.IDENTITY, Vector3(float(case_index) * 30.0, 0, 0))
		)
		var names: Array[StringName] = building_site.get_planned_port_names(true)
		names.append_array(building_site.get_planned_port_names(false))
		assert(names.size() == int(spec["in"]) + int(spec["out"]))
		var pending: Array[Dictionary] = []

		for name: StringName in names:
			var input_side: bool = str(name).begins_with("InputPort")
			var preview := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
			assert(preview != null)
			root.add_child(preview)
			preview.add_to_group("construction_preview")
			preview.process_mode = Node.PROCESS_MODE_DISABLED
			var proposal: Dictionary = building_site.get_planned_belt_transform_named(
				preview, name
			)
			assert(proposal.has("transform"))
			preview.free()
			var belt_site := _site(root, belt_def, proposal["transform"])
			var reservation_id: int = registry.reserve_pair(
				building_site, belt_site, input_side, name
			)
			assert(reservation_id > 0)
			assert(registry.has_building_claim(building_site, input_side, name))
			assert(registry.reserve_pair(
				building_site, belt_site, input_side, name
			) == 0)
			pending.append({
				"name": name,
				"input_side": input_side,
				"belt_site": belt_site,
				"id": reservation_id
			})
			total_ports += 1

		assert(broker.claim_count() == pending.size() * 2)
		print("PASS B: ", definition.display_name,
			" independently reserves ", pending.size(), " named ports")

		var built_belts: Dictionary = {}
		var built_building: Node3D
		# Alternate completion order per building: even = building first.
		if case_index % 2 == 0:
			built_building = _complete(building_site)
			for item: Dictionary in pending:
				built_belts[item["name"]] = _complete(item["belt_site"])
		else:
			for item: Dictionary in pending:
				built_belts[item["name"]] = _complete(item["belt_site"])
			built_building = _complete(building_site)

		for item: Dictionary in pending:
			var port := built_building.get_node(
				str(item["name"])
			) as ItemPortComponent
			var belt := built_belts[item["name"]] as ConveyorSegment
			assert(port != null and belt != null)
			assert(port.connected_conveyor == belt)
			if item["input_side"]:
				assert(belt.output_building_port == port)
			else:
				assert(belt.input_building_port == port)
			assert(committed.count(int(item["id"])) == 1)
			assert(not registry.is_reserved(int(item["id"])))
			print("PASS LINK: ", definition.display_name, " / ", item["name"])
		assert(broker.claim_count() == 0)
		assert(registry.claim_count() == 0)
		print("PASS C: ", definition.display_name,
			" construction order preserves all reciprocal links")

	assert(total_ports == 16)
	assert(committed.size() == 16)
	print("ALL 16 E3C3B FACTORY BLUEPRINT CONNECTIONS ACTIVATED")
