extends Node3D

# =============================================================================
# E3D3B — ISOLATED L-ROUTE GEOMETRY AND EXISTING CORNER RESERVATIONS
# =============================================================================
# The three-point player control is a later step. This test proves the
# geometry and existing corner ownership before touching mouse placement.

func _ready() -> void:
	var forward: Array[Vector3] = [
		Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT
	]
	var orientation_cases: int = 0
	for entering: Vector3 in forward:
		for side: int in [-1, 1]:
			var leaving := Vector3(
				-entering.z * float(side), 0.0,
				entering.x * float(side)
			)
			var start := Vector3(12, 0, 12)
			var pivot: Vector3 = start + entering * 3.0
			var finish: Vector3 = pivot + leaving * 3.0
			var route: Array[Transform3D] = BlueprintLRoute.get_tiles(
				start, pivot, finish
			)
			assert(route.size() == 7)
			assert(route[0].origin.is_equal_approx(start))
			assert(route[3].origin.is_equal_approx(pivot))
			assert(route[6].origin.is_equal_approx(finish))
			assert((route[3].basis * Vector3.FORWARD).is_equal_approx(
				entering
			))
			assert((route[4].basis * Vector3.FORWARD).is_equal_approx(
				leaving
			))
			for i: int in range(1, route.size()):
				assert(route[i].origin.distance_to(
					route[i - 1].origin
				) < 1.001)
			orientation_cases += 1
	assert(orientation_cases == 8)
	print("PASS A: Eight left/right routes preserve ordered unique corner tiles")

	var start := Vector3(0, 0, 0)
	var pivot := Vector3(0, 0, -3)
	assert(BlueprintLRoute.get_tiles(start, pivot, pivot).is_empty())
	assert(BlueprintLRoute.get_tiles(start, start, Vector3(3, 0, 0)).is_empty())
	assert(BlueprintLRoute.get_tiles(
		start, pivot, Vector3(0, 0, -6)
	).is_empty())
	assert(BlueprintLRoute.get_tiles(
		start, pivot, Vector3(1, 0, -2)
	).is_empty())
	print("PASS B: Missing, straight-through and diagonal turns reject safely")

	assert(BlueprintLRoute.get_tiles(
		start, Vector3(0, 0, -15), Vector3(16, 0, -15)
	).size() == 32)
	assert(BlueprintLRoute.get_tiles(
		start, Vector3(0, 0, -15), Vector3(17, 0, -15)
	).is_empty())
	assert(BlueprintLRoute.get_tiles(
		start, Vector3(0, 0, -1), Vector3(1, 0, -1), 2
	).is_empty())
	print("PASS C: Shared 32-tile limit includes the corner only once")

	assert(BlueprintLRoute.get_tiles(
		start, Vector3(0.5, 0, -3), Vector3(3, 0, -3)
	).is_empty())
	assert(BlueprintLRoute.get_tiles(
		start, Vector3(0, 1, -3), Vector3(3, 1, -3)
	).is_empty())
	print("PASS D: Off-grid and mismatched-elevation corners reject safely")

	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(belt_def != null)
	var parent := Node3D.new()
	add_child(parent)
	var coordinator := BlueprintConveyorRouteCoordinator.new()
	parent.add_child(coordinator)
	var test_route: Array[Transform3D] = BlueprintLRoute.get_tiles(
		Vector3(7, 0, 4), Vector3(7, 0, 2), Vector3(8, 0, 2)
	)
	assert(test_route.size() == 4)
	var sites: Array[ConstructionSite] = []
	for transform: Transform3D in test_route:
		var site := ConstructionSite.new()
		assert(site.setup_with_definition_job(belt_def))
		parent.add_child(site)
		site.global_transform = transform
		site.set_process(false)
		coordinator.register_new_site(site)
		sites.append(site)
	assert(coordinator.registry.claim_count() == 6)
	assert(sites[2].has_meta("planned_conveyor_turn"))
	assert(int(sites[2].get_meta("planned_conveyor_turn")) ==
		ConveyorTurnIntent.Turn.RIGHT)
	print("PASS E: Existing route coordinator reserves three links and right corner")

	assert(sites[3].job.cancel())
	assert(coordinator.registry.claim_count() == 4)
	assert(not sites[2].has_meta("planned_conveyor_turn"))
	print("PASS F: Cancelling the outgoing leg releases the corner reservation")

	var defaults: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(not bool(defaults.get("enable_blueprint_route_tool")))
	defaults.free()
	print("PASS G: Main has no enabled route editing by default")

	print("ALL 7 E3D3B L-ROUTE GEOMETRY AND CORNER RESERVATION CHECKS PASSED")
