extends RefCounted
class_name PlannedConveyorPortFinder

# =============================================================================
# PLANNED CONVEYOR PORT DISCOVERY — PREVIEW ONLY
# =============================================================================
# Finds non-operational construction-site port markers, using the same
# facing-direction and mouse-distance constraints as real building snaps.
# Never moves belts, creates connections, or changes inventories.

static func find_nearest_preview(
	preview_belt: ConveyorSegment,
	mouse_world_position: Vector3,
	search_radius: float = 0.65
) -> Dictionary:
	if not is_instance_valid(preview_belt):
		return {}
	if not preview_belt.is_inside_tree() or preview_belt.is_queued_for_deletion():
		return {}
	if search_radius <= 0.0:
		return {}

	var requested_forward: Vector3 = (
		preview_belt.global_transform.basis * Vector3.FORWARD
	).normalized()
	var best_distance_squared: float = search_radius * search_radius
	var best: Dictionary = {}

	for node: Node in preview_belt.get_tree().get_nodes_in_group(
		"construction_sites"
	):
		var site := node as ConstructionSite
		if site == null or site.is_queued_for_deletion():
			continue
		# Legacy sites remain eligible only while constructing. Job-driven
		# blueprints may reserve geometry while planned, queued or paused.
		if not site.accepts_planned_connections():
			continue

		for input_side: bool in [true, false]:
			if is_instance_valid(site.get_reserved_conveyor(input_side)):
				continue
			if (
				site.get_reserved_conveyor(input_side) != null
			):
				continue
			var proposed: Dictionary = site.get_planned_belt_transform(
				preview_belt, input_side
			)
			if not proposed.has("transform"):
				continue
			var target: Transform3D = proposed["transform"]
			var proposed_forward: Vector3 = (
				target.basis * Vector3.FORWARD
			).normalized()
			if requested_forward.dot(proposed_forward) < 0.98:
				continue
			# Accept either the intended belt center or its planned port.
			# Players naturally aim at the visible building endpoint, which
			# may be a full belt-length away from the new belt's origin.
			# Keep the same tight radius and heading check to avoid
			# attracting unrelated neighboring conveyor lanes.
			var marker := site.get_planned_port(input_side)
			if marker == null:
				continue
			var to_origin := Vector2(
				mouse_world_position.x - target.origin.x,
				mouse_world_position.z - target.origin.z
			)
			var to_port := Vector2(
				mouse_world_position.x - marker.global_position.x,
				mouse_world_position.z - marker.global_position.z
			)
			var distance_squared: float = minf(
				to_origin.length_squared(), to_port.length_squared()
			)
			if distance_squared >= best_distance_squared:
				continue
			best_distance_squared = distance_squared
			best = {
				"site": site,
				"input_side": input_side,
				"transform": target,
				"distance_squared": distance_squared
			}
	return best
