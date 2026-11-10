extends Node3D

# =============================================================================
# E3D3A — BOUNDED STRAIGHT CONVEYOR BLUEPRINT ROUTES
# =============================================================================
# Verify 4 rotations, backward/sideways rejection, 32-tile limit,
# same-frame footprint protection, and sandbox-only opt-in.

func _ready() -> void:
	var angles: Array[float] = [0.0, 90.0, 180.0, 270.0]
	var start_position := Vector3(-6, 0, 5)
	for yaw: float in angles:
		var basis := Basis(Vector3.UP, deg_to_rad(yaw))
		var start := Transform3D(basis, start_position)
		var forward: Vector3 = basis * Vector3.FORWARD
		var steps: Array[Transform3D] = BlueprintStraightRoute.get_tiles(
			start, start_position + forward * 4.0
		)
		assert(steps.size() == 5)
		for i: int in range(steps.size()):
			assert(steps[i].origin.is_equal_approx(
				start_position + forward * float(i)
			))
			assert(steps[i].basis.is_equal_approx(basis))
		print("PASS ROUTE: ", int(yaw), " degrees creates five ordered straight tiles")
	print("PASS A: All four cardinal directions produce ordered conveyor routes")

	var start := Transform3D(Basis.IDENTITY, start_position)
	assert(BlueprintStraightRoute.get_tiles(
		start, start_position + Vector3(0, 0, 1)
	).is_empty())
	assert(BlueprintStraightRoute.get_tiles(
		start, start_position + Vector3(1, 0, -3)
	).is_empty())
	assert(BlueprintStraightRoute.get_tiles(
		start, start_position + Vector3(0, 0, -32)
	).is_empty())
	assert(BlueprintStraightRoute.get_tiles(
		start, start_position + Vector3(0, 0, -31)
	).size() == 32)
	print("PASS B: Backward, diagonal, and oversized routes reject safely")

	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.enable_blueprint_route_tool)
	assert(controller.enable_blueprint_planning)
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(belt_def != null)
	var route: Array[Transform3D] = BlueprintStraightRoute.get_tiles(
		Transform3D(Basis.IDENTITY, Vector3(-6, 0, 4)),
		Vector3(-6, 0, 1)
	)
	assert(route.size() == 4)
	for tile: Transform3D in route:
		assert(ConveyorBlueprintPlacement.is_clear(
			get_tree(), get_viewport().world_3d,
			belt_def, tile, controller.PLACEMENT_BLOCKER_COLLISION_MASK
		))
	print("PASS C: Every tile of a clear sandbox route passes preflight")

	var first := controller._create_straight_conveyor_blueprint(
		belt_def, route[0]
	) as ConstructionSite
	assert(first != null)
	first.set_process(false)
	assert(not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		belt_def, route[0], controller.PLACEMENT_BLOCKER_COLLISION_MASK
	))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(controller._cancel_blueprint_site(first))
	print("PASS D: Reserved tiles reject duplicates and cancel safely")

	var defaults := (load(
		"res://scripts/world_interaction.gd"
	) as GDScript).new() as Node
	assert(not bool(defaults.get("enable_blueprint_route_tool")))
	defaults.free()
	print("PASS E: Main-scene route tool remains disabled by default")

	for yaw: float in angles:
		var basis := Basis(Vector3.UP, deg_to_rad(yaw))
		var forward: Vector3 = basis * Vector3.FORWARD
		var endpoint: Vector3 = start_position + forward * 5.0
		# No R key is needed: endpoints determine the final orientation.
		var inferred: Array[Transform3D] = (
			BlueprintStraightRoute.get_tiles_between(start_position, endpoint)
		)
		assert(inferred.size() == 6)
		assert((inferred[0].basis * Vector3.FORWARD).is_equal_approx(
			forward
		))
		assert(inferred[5].origin.is_equal_approx(endpoint))
	print("PASS F: Two-click routes auto-orient in all four cardinal directions")

	assert(BlueprintStraightRoute.get_tiles_between(
		start_position, start_position
	).is_empty())
	assert(BlueprintStraightRoute.get_tiles_between(
		start_position, start_position + Vector3(3, 0, 2)
	).is_empty())
	print("PASS G: Same-tile and diagonal clicks never create misleading routes")

	assert(BlueprintStraightRoute.get_tiles_between(
		start_position, start_position + Vector3(0, 0, -31)
	).size() == 32)
	assert(BlueprintStraightRoute.get_tiles_between(
		start_position, start_position + Vector3(0, 0, -32)
	).is_empty())
	print("PASS H: Inferred two-click routes retain the 32-tile safety limit")

	print("ALL 8 STRAIGHT BLUEPRINT ROUTE E3D3A TESTS PASSED")
