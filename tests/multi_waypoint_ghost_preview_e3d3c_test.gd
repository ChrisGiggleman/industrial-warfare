extends Node3D

# =============================================================================
# E3D3C — LIVE MULTI-WAYPOINT GHOST PREVIEW REGRESSION
# =============================================================================
# Preview is pure presentation: pooled meshes and arrows, no physics,
# no sites or claims until Enter commits the route.

func _ready() -> void:
	var visual := BlueprintWaypointGhostPreview.new()
	add_child(visual)
	assert(visual.displayed_count == 0)
	assert(not visual.is_invalid_marker_visible())
	assert(visual.get_child_count() == 33)
	print("PASS A: Preview pool exists but displays nothing before planning")

	var positions: Array[Vector3] = [
		Vector3(10, 0, 10), Vector3(10, 0, 7),
		Vector3(13, 0, 7), Vector3(13, 0, 4)
	]
	var route: Array[Transform3D] = BlueprintWaypointRoute.get_tiles(
		positions
	)
	assert(route.size() == 10)
	visual.show_route(route, 7, true)
	assert(visual.displayed_count == 10)
	assert(visual.preview_valid)
	assert(not visual.is_invalid_marker_visible())
	assert(visual.get_node("PreviewTile00").visible)
	assert(not visual.get_node("PreviewTile10").visible)
	print("PASS B: Ten translucent proposed tiles display with fixed/active segments")

	var has_collision: bool = false
	for child: Node in visual.get_children():
		if child is CollisionObject3D or child is CollisionShape3D:
			has_collision = true
		for sub: Node in child.get_children():
			if sub is CollisionObject3D or sub is CollisionShape3D:
				has_collision = true
	assert(not has_collision)
	print("PASS C: Ghost previews have no collision or selectable physics")

	var first := visual.get_node("PreviewTile00") as Node3D
	var bend := visual.get_node("PreviewTile03") as Node3D
	assert(first.global_position.is_equal_approx(
		positions[0] + Vector3.UP * 0.19
	))
	assert(bend.global_position.is_equal_approx(
		positions[1] + Vector3.UP * 0.19
	))
	var arrow := bend.get_node("FlowArrow") as Label3D
	assert(arrow != null and arrow.visible)
	var heading: Vector3 = bend.global_transform.basis * (
		arrow.transform.basis * Vector3.UP
	)
	assert(heading.is_finite())
	print("PASS D: Bend tile uses a visible direction arrow above the grid")

	visual.show_route(route, 7, false, Vector3(14, 0, 4))
	assert(not visual.preview_valid)
	assert(visual.is_invalid_marker_visible())
	var invalid := visual.get_node("InvalidEndpoint") as MeshInstance3D
	assert(invalid.global_position.is_equal_approx(Vector3(14, 0.22, 4)))
	visual.clear_preview()
	assert(visual.displayed_count == 0)
	assert(not visual.is_invalid_marker_visible())
	print("PASS E: Invalid route turns red and clears without creating sites")

	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	controller._select_building(
		controller._find_definition_index(&"conveyor_belt")
	)
	assert(controller._toggle_blueprint_waypoint_route_mode())
	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-6, 0, 4)
	) == 1)
	assert(controller._show_blueprint_waypoint_preview_at(
		Vector3(-6, 0, 2)
	))
	var ghost := world.get_node(
		"WaypointRouteGhostPreview"
	) as BlueprintWaypointGhostPreview
	assert(ghost != null)
	assert(ghost.displayed_count == 3)
	assert(get_tree().get_nodes_in_group("construction_sites").is_empty())
	print("PASS F: First point shows a live three-tile leg without placing anything")

	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-6, 0, 2)
	) == 2)
	assert(controller._show_blueprint_waypoint_preview_at(
		Vector3(-4, 0, 2)
	))
	assert(ghost.displayed_count == 5)
	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-4, 0, 2)
	) == 3)
	assert(controller._show_blueprint_waypoint_preview_at(
		Vector3(-4, 0, 0)
	))
	assert(ghost.displayed_count == 7)
	assert(ghost.preview_valid)
	print("PASS G: Live preview follows each new leg through two corners")

	assert(not controller._show_blueprint_waypoint_preview_at(
		Vector3(-3, 0, 1)
	))
	assert(ghost.is_invalid_marker_visible())
	assert(get_tree().get_nodes_in_group("construction_sites").is_empty())
	print("PASS H: Diagonal next leg is visibly invalid and changes no plans")

	assert(controller._handle_blueprint_waypoint_position(
		Vector3(-4, 0, 0)
	) == 4)
	assert(controller._finalize_blueprint_waypoint_route() == 7)
	assert(ghost.displayed_count == 0)
	var coordinator := controller.get_node(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator.registry.claim_count() == 12)
	print("PASS I: Enter swaps ghost for seven real planned sites and two corners")

	assert(controller._handle_blueprint_waypoint_position(
		Vector3(3, 0, 4)
	) == 1)
	assert(controller._show_blueprint_waypoint_preview_at(
		Vector3(3, 0, 2)
	))
	controller._cancel_blueprint_waypoint_route()
	assert(ghost.displayed_count == 0)
	assert(coordinator.registry.claim_count() == 12)
	assert(not controller._toggle_blueprint_waypoint_route_mode())
	assert(ghost.displayed_count == 0)
	print("PASS J: Escape and T off remove only visuals and retain committed claims")

	var defaults: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(not bool(defaults.get("enable_blueprint_route_tool")))
	assert(defaults.get("_waypoint_ghost_preview") == null)
	defaults.free()
	print("PASS K: Main remains opted out of preview and multi-turn planning")

	print("ALL 11 E3D3C LIVE WAYPOINT GHOST PREVIEW CHECKS PASSED")
