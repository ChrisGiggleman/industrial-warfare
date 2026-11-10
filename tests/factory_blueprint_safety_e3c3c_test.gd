extends Node3D

# =============================================================================
# E3C3C — FACTORY BLUEPRINT PORT ROTATION AND CANCELLATION SAFETY
# =============================================================================
# Isolated reservation tests: no Main scene, placement raycasts, or cargo.
# E3c3b verifies finished connections; E3c2a verifies actual ore flow.

const CASES: Array[Dictionary] = [
	{"path": "res://data/buildings/test_extractor.tres", "count": 1},
	{"path": "res://data/buildings/test_storage.tres", "count": 2},
	{"path": "res://data/buildings/test_smelter.tres", "count": 2},
	{"path": "res://data/buildings/conveyor_merger.tres", "count": 4},
	{"path": "res://data/buildings/conveyor_splitter.tres", "count": 4},
	{"path": "res://data/buildings/prototype_ammunition_press.tres", "count": 2},
	{"path": "res://data/buildings/prototype_defensive_turret.tres", "count": 1}
]


func _site(
	parent: Node3D, definition: BuildingDefinition, placement: Transform3D
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	parent.add_child(site)
	site.global_transform = placement
	site.set_process(false)
	return site


func _belt_at_port(
	root: Node3D, building: ConstructionSite,
	belt_definition: BuildingDefinition, port_name: StringName
) -> ConstructionSite:
	var preview := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(preview != null)
	root.add_child(preview)
	preview.process_mode = Node.PROCESS_MODE_DISABLED
	var proposal: Dictionary = building.get_planned_belt_transform_named(
		preview, port_name
	)
	assert(proposal.has("transform"))
	var placement: Transform3D = proposal["transform"]
	preview.free()
	return _site(root, belt_definition, placement)


func _ready() -> void:
	var belt_definition := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(belt_definition != null)
	var root := Node3D.new()
	add_child(root)
	var broker := PlannedEndpointClaimBroker.new()
	add_child(broker)
	var ports := PlannedBuildingPortReservations.new()
	add_child(ports)
	assert(ports.set_claim_broker(broker))
	print("PASS A: E3c3c isolated reservations use one shared broker")

	var rotation_checks: int = 0
	for case_index: int in range(CASES.size()):
		var case_data: Dictionary = CASES[case_index]
		var definition := load(case_data["path"]) as BuildingDefinition
		assert(definition != null)
		for turn: int in range(4):
			var angle: float = float(turn) * 90.0
			var placement := Transform3D(
				Basis(Vector3.UP, deg_to_rad(angle)),
				Vector3(float(case_index) * 30.0, 0, float(turn) * 30.0)
			)
			var building := _site(root, definition, placement)
			var names: Array[StringName] = building.get_planned_port_names(true)
			names.append_array(building.get_planned_port_names(false))
			assert(names.size() == int(case_data["count"]))
			for name: StringName in names:
				var input_side: bool = str(name).begins_with("InputPort")
				var belt := _belt_at_port(root, building, belt_definition, name)
				var claim: int = ports.reserve_pair(
					building, belt, input_side, name
				)
				assert(claim > 0)
				assert(ports.has_building_claim(building, input_side, name))
				assert(ports.reserve_pair(building, belt, input_side, name) == 0)
				assert(ports.release(claim))
				assert(not ports.has_building_claim(building, input_side, name))
				assert(broker.claim_count() == 0)
				assert(belt.job.cancel())
				rotation_checks += 1
			assert(building.job.cancel())
			await get_tree().process_frame
			assert(ports.claim_count() == 0)
			assert(broker.claim_count() == 0)
		print("PASS ROTATION: ", definition.display_name,
			" has safe port claims at 0, 90, 180, 270 degrees")

	assert(rotation_checks == 64)
	print("PASS B: All 64 rotated factory port claims are exclusive and reversible")

	# The 3-in/1-out merger and 1-in/3-out splitter must never
	# release unrelated named ports when one belt is cancelled.
	for resource_path: String in [
		"res://data/buildings/conveyor_merger.tres",
		"res://data/buildings/conveyor_splitter.tres"
	]:
		var definition := load(resource_path) as BuildingDefinition
		var building := _site(root, definition, Transform3D.IDENTITY)
		var names: Array[StringName] = building.get_planned_port_names(true)
		names.append_array(building.get_planned_port_names(false))
		assert(names.size() == 4)
		var pairs: Array[Dictionary] = []
		for name: StringName in names:
			var input_side: bool = str(name).begins_with("InputPort")
			var belt := _belt_at_port(root, building, belt_definition, name)
			var claim: int = ports.reserve_pair(building, belt, input_side, name)
			assert(claim > 0)
			pairs.append({
				"port_name": name,
				"input_side": input_side,
				"belt": belt,
				"claim": claim
			})
		assert(ports.claim_count() == 8)
		assert(broker.claim_count() == 8)
		var first: Dictionary = pairs[0]
		assert((first["belt"] as ConstructionSite).job.cancel())
		assert(not ports.is_reserved(int(first["claim"])))
		for i: int in range(1, pairs.size()):
			var pair: Dictionary = pairs[i]
			assert(ports.has_building_claim(
					building, bool(pair["input_side"]), pair["port_name"]
			))
		assert(ports.claim_count() == 6)
		assert(broker.claim_count() == 6)
		assert(building.job.cancel())
		assert(ports.claim_count() == 0)
		assert(broker.claim_count() == 0)
		await get_tree().process_frame
		print("PASS MULTIPORT: ", definition.display_name,
			" cancellation preserves other ports and clears on building cancel")

	print("ALL 64 E3C3C ROTATION CHECKS AND 2 MULTIPORT CANCELLATION CASES PASSED")
