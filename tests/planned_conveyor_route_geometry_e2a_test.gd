extends Node3D

# =============================================================================
# PLANNED CONVEYOR ROUTE GEOMETRY — PHASE E2A REGRESSION
# =============================================================================
# Discovers direct and corner intent without changing a blueprint's scene,
# connecting belts, creating cargo or spending construction resources.

func _make_site(
	root: Node3D,
	definition: BuildingDefinition,
	at_position: Vector3,
	yaw_degrees: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	root.add_child(site)
	site.set_process(false)
	site.position = at_position
	site.rotation_degrees.y = yaw_degrees
	return site


func _ready() -> void:
	var belt := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	var storage := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(belt != null and storage != null)
	var root := Node3D.new()
	add_child(root)

	var direct_source := _make_site(root, belt, Vector3(0, 0, 0))
	var direct_receiver := _make_site(root, belt, Vector3(0, 0, -1))
	var direct := PlannedConveyorRouteGeometry.inspect_pair(
		direct_source, direct_receiver
	)
	assert(direct.get("mode") == "direct")
	assert(direct.get("turn") == ConveyorTurnIntent.Turn.STRAIGHT)
	assert(direct.get("source") == direct_source)
	assert(direct.get("receiver") == direct_receiver)
	print("PASS A: Adjacent matching blueprints discover a direct forward link")

	assert(direct_source.job.state == ConstructionJob.State.PLANNED)
	assert(direct_receiver.job.state == ConstructionJob.State.PLANNED)
	assert(direct_source.get_node_or_null("CargoInventory") == null)
	assert(direct_receiver.get_node_or_null("CargoInventory") == null)
	assert(not direct_source.has_meta("planned_conveyor_turn"))
	assert(not direct_receiver.has_meta("planned_conveyor_turn"))
	print("PASS B: Discovery leaves both sites non-operational and unchanged")

	var right_source := _make_site(root, belt, Vector3(5, 0, 0))
	var right_receiver := _make_site(root, belt, Vector3(6, 0, 0), -90)
	var source_marker := (
		right_source.get_node("PlannedOutputEndpoint") as Marker3D
	)
	var straight_marker_transform := source_marker.transform
	var right := PlannedConveyorRouteGeometry.inspect_pair(
		right_source, right_receiver
	)
	assert(right.get("mode") == "convert_source")
	assert(right.get("turn") == ConveyorTurnIntent.Turn.RIGHT)
	assert(source_marker.transform.is_equal_approx(straight_marker_transform))
	print("PASS C: Perpendicular right turn is detected without converting the site")

	var right_template := (
		ConveyorPieceSelector.RIGHT_CORNER_SCENE.instantiate() as ConveyorSegment
	)
	assert(right_template != null)
	var expected_right_output := (
		right_source.global_transform
		* (right_template.get_node("OutputEndpoint") as Marker3D).transform
	)
	var proposed_junction: Vector3 = right["junction"]
	assert(proposed_junction.distance_to(
		expected_right_output.origin
	) < 0.001)
	right_template.free()
	print("PASS D: Proposed right junction matches the existing corner template")

	var left_source := _make_site(root, belt, Vector3(11, 0, 0))
	var left_receiver := _make_site(root, belt, Vector3(10, 0, 0), 90)
	var left := PlannedConveyorRouteGeometry.inspect_pair(
		left_source, left_receiver
	)
	assert(left.get("mode") == "convert_source")
	assert(left.get("turn") == ConveyorTurnIntent.Turn.LEFT)
	print("PASS E: Mirrored perpendicular blueprints discover the left turn")

	var rotated_root := Node3D.new()
	root.add_child(rotated_root)
	rotated_root.position = Vector3(0, 0, 13)
	rotated_root.rotation_degrees.y = 90
	var rotated_source := _make_site(rotated_root, belt, Vector3.ZERO)
	var rotated_receiver := _make_site(
		rotated_root, belt, Vector3(1, 0, 0), -90
	)
	var rotated := PlannedConveyorRouteGeometry.inspect_pair(
		rotated_source, rotated_receiver
	)
	assert(rotated.get("mode") == "convert_source")
	assert(rotated.get("turn") == ConveyorTurnIntent.Turn.RIGHT)
	print("PASS F: Rotating the complete layout preserves intended turn geometry")

	var wrong_facing := _make_site(root, belt, Vector3(18, 0, 0))
	var wrong_receiver := _make_site(root, belt, Vector3(19, 0, 0), 90)
	assert(PlannedConveyorRouteGeometry.inspect_pair(
		wrong_facing, wrong_receiver
	).is_empty())
	print("PASS G: Incorrect receiving conveyor direction is rejected")

	var far_source := _make_site(root, belt, Vector3(24, 0, 0))
	var far_receiver := _make_site(root, belt, Vector3(26, 0, 0), -90)
	assert(PlannedConveyorRouteGeometry.inspect_pair(
		far_source, far_receiver
	).is_empty())
	print("PASS H: A misplaced or overly distant junction cannot be reserved")

	assert(PlannedConveyorRouteGeometry.inspect_pair(
		direct_source, direct_source
	).is_empty())
	var storage_site := _make_site(root, storage, Vector3(-8, 0, 0))
	assert(PlannedConveyorRouteGeometry.inspect_pair(
		storage_site, direct_receiver
	).is_empty())
	assert(PlannedConveyorRouteGeometry.inspect_pair(
		direct_source, storage_site
	).is_empty())
	print("PASS I: Self-links and non-conveyor sites are rejected")

	assert(direct_source.job.authorize())
	assert(direct_source.job.state == ConstructionJob.State.QUEUED)
	assert(not PlannedConveyorRouteGeometry.inspect_pair(
		direct_source, direct_receiver
	).is_empty())
	assert(direct_source.job.set_availability(true, true, true))
	direct_source.job.advance(1.0)
	assert(direct_source.job.set_availability(false, true, true))
	assert(direct_source.job.state == ConstructionJob.State.PAUSED)
	assert(not PlannedConveyorRouteGeometry.inspect_pair(
		direct_source, direct_receiver
	).is_empty())
	print("PASS J: Queued or paused unfinished sites retain geometric intent")

	assert(right_receiver.job.cancel())
	assert(right_receiver.is_queued_for_deletion())
	assert(PlannedConveyorRouteGeometry.inspect_pair(
		right_source, right_receiver
	).is_empty())
	print("PASS K: Cancelled sites are not eligible connection targets")

	assert(direct_source.job.set_availability(true, true, true))
	direct_source.job.advance(1.0)
	assert(direct_source.job.is_complete())
	assert(direct_source.is_queued_for_deletion())
	assert(PlannedConveyorRouteGeometry.inspect_pair(
		direct_source, direct_receiver
	).is_empty())
	print("PASS L: Completed sites require operational endpoint handling instead")

	root.queue_free()
	print("ALL 12 PLANNED CONVEYOR ROUTE GEOMETRY E2A TESTS PASSED")
