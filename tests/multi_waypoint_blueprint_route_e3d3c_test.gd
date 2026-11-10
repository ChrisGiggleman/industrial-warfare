extends Node3D

# =============================================================================
# E3D3C — MULTI-WAYPOINT CONVEYOR BLUEPRINT REGRESSION
# =============================================================================
# Geometry + sandbox controller integration. No manual mouse input required.
# Main gameplay remains opted out until the route feature is validated.

func _ready() -> void:
	var points: Array[Vector3] = [
		Vector3(10, 0, 10), Vector3(10, 0, 7),
		Vector3(13, 0, 7), Vector3(13, 0, 4)
	]
	var tiles: Array[Transform3D] = BlueprintWaypointRoute.get_tiles(points)
	assert(tiles.size() == 10)
	assert(tiles[0].origin.is_equal_approx(points[0]))
	assert(tiles[3].origin.is_equal_approx(points[1]))
	assert(tiles[6].origin.is_equal_approx(points[2]))
	assert(tiles[9].origin.is_equal_approx(points[3]))
	assert(BlueprintWaypointRoute.turn_count(points) == 2)
	assert((tiles[3].basis * Vector3.FORWARD).is_equal_approx(
		Vector3.FORWARD
	))
	assert((tiles[6].basis * Vector3.FORWARD).is_equal_approx(
		Vector3.RIGHT
	))
	print("PASS A: Four waypoints make ten unique tiles with two automatic turns")

	var zigzag: Array[Vector3] = [
		Vector3(0, 0, 0), Vector3(0, 0, -2),
		Vector3(3, 0, -2), Vector3(3, 0, -5),
		Vector3(6, 0, -5)
	]
	assert(BlueprintWaypointRoute.get_tiles(zigzag).size() == 12)
	assert(BlueprintWaypointRoute.turn_count(zigzag) == 3)
	print("PASS B: Five waypoints support three distinct 90-degree turns")

	var bad_diagonal: Array[Vector3] = [
		Vector3.ZERO, Vector3(2, 0, -2)
	]
	assert(BlueprintWaypointRoute.get_tiles(bad_diagonal).is_empty())
	var reversal: Array[Vector3] = [
		Vector3.ZERO, Vector3(0, 0, -3), Vector3(0, 0, -1)
	]
	assert(BlueprintWaypointRoute.get_tiles(reversal).is_empty())
	var self_crossing: Array[Vector3] = [
		Vector3.ZERO, Vector3(0, 0, -3), Vector3(2, 0, -3),
		Vector3(2, 0, -1), Vector3(-1, 0, -1)
	]
	assert(BlueprintWaypointRoute.get_tiles(self_crossing).is_empty())
	print("PASS C: Diagonal, U-turn and crossing routes reject safely")

	var at_limit: Array[Vector3] = [
		Vector3.ZERO, Vector3(0, 0, -20),
		Vector3(11, 0, -20)
	]
	var over_limit: Array[Vector3] = [
		Vector3.ZERO, Vector3(0, 0, -20),
		Vector3(12, 0, -20)
	]
	assert(BlueprintWaypointRoute.get_tiles(at_limit).size() == 32)
	assert(BlueprintWaypointRoute.get_tiles(over_limit).is_empty())
	print("PASS D: Complete routes enforce the shared 32-tile limit")

	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.enable_blueprint_route_tool)
	assert(not controller._toggle_blueprint_waypoint_route_mode())
	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	controller._select_building(
		controller._find_definition_index(&"conveyor_belt")
	)
	assert(controller._toggle_blueprint_waypoint_route_mode())
	assert(bool(controller.get("_blueprint_waypoint_route_mode")))
	print("PASS E: T route mode is available only in sandbox conveyor Blueprint Mode")

	var start := Vector3(-6, 0, 4)
	var turn_one := Vector3(-6, 0, 2)
	var turn_two := Vector3(-4, 0, 2)
	var finish := Vector3(-4, 0, 0)
	assert(controller._handle_blueprint_waypoint_position(start) == 1)
	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-5, 0, 3)
	) == 0)
	assert((controller.get("_waypoint_route_points") as Array).size() == 1)
	assert(controller._handle_blueprint_waypoint_position(turn_one) == 2)
	controller._cancel_blueprint_waypoint_route()
	assert((controller.get("_waypoint_route_points") as Array).is_empty())
	assert(get_tree().get_nodes_in_group("construction_sites").is_empty())
	print("PASS F: Invalid click and Escape preserve the scene without a partial plan")

	assert(controller._handle_blueprint_waypoint_position(start) == 1)
	assert(controller._handle_blueprint_waypoint_position(turn_one) == 2)
	assert(controller._handle_blueprint_waypoint_position(turn_two) == 3)
	assert(controller._handle_blueprint_waypoint_position(finish) == 4)
	assert(controller._finalize_blueprint_waypoint_route() == 7)
	assert((controller.get("_waypoint_route_points") as Array).is_empty())
	var sites: Array[ConstructionSite] = []
	var turns: int = 0
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == world:
			var site := node as ConstructionSite
			site.set_process(false)
			sites.append(site)
			if site.has_meta("planned_conveyor_turn"):
				turns += 1
	assert(sites.size() == 7)
	assert(turns == 2)
	var coordinator := controller.get_node(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator.registry.claim_count() == 12)
	print("PASS G: Enter commits seven tiles and reserves both 90-degree corners")

	assert(controller._authorize_all_blueprint_sites() == 7)
	for site: ConstructionSite in sites:
		assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
		assert(site.job.get_progress() == 0.0)
	print("PASS H: Ctrl+E authorizes all route sites without skipping build time")

	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-7, 0, 3)
	) == 1)
	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-5, 0, 3)
	) == 2)
	assert(controller._finalize_blueprint_waypoint_route() == 0)
	assert((controller.get("_waypoint_route_points") as Array).size() == 2)
	controller._cancel_blueprint_waypoint_route()
	assert(coordinator.registry.claim_count() == 12)
	print("PASS I: Blocked route commits no partial sites and retains existing claims")

	for site: ConstructionSite in sites:
		assert(controller._cancel_blueprint_site(site))
	assert(coordinator.registry.claim_count() == 0)
	assert(not controller._toggle_blueprint_waypoint_route_mode())
	assert(not bool(controller.get("_blueprint_waypoint_route_mode")))
	print("PASS J: Cancelled sites free claims and T switches back to straight routes")

	var defaults: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(not bool(defaults.get("enable_blueprint_route_tool")))
	assert(not bool(defaults.get("_blueprint_waypoint_route_mode")))
	defaults.free()
	print("PASS K: Main gameplay still defaults to route planning disabled")

	print("ALL 11 E3D3C MULTI-WAYPOINT BLUEPRINT ROUTE TESTS PASSED")
