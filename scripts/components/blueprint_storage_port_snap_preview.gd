extends RefCounted
class_name BlueprintStoragePortSnapPreview

# =============================================================================
# SANDBOX STORAGE BLUEPRINT PORT SNAPPING — READ-ONLY DISCOVERY
# =============================================================================
# Suggests a straight belt transform for an unfinished Storage input/output.
# Callers may opt into suggesting the port's correct orientation, but this
# helper never rotates the supplied ghost, creates reservations or cargo.

static func find_nearest(
	preview_belt: ConveyorSegment,
	mouse_world: Vector3,
	port_registry: PlannedBuildingPortReservations,
	search_radius: float = 0.65,
	auto_orient: bool = false
) -> Dictionary:
	if not is_instance_valid(preview_belt):
		return {}
	if not preview_belt.is_inside_tree() or preview_belt.is_queued_for_deletion():
		return {}
	if not is_instance_valid(port_registry) or search_radius <= 0.0:
		return {}

	var requested_forward := (
		preview_belt.global_transform.basis * Vector3.FORWARD
	).normalized()
	var best_distance_sq := search_radius * search_radius
	var best: Dictionary = {}

	for node: Node in preview_belt.get_tree().get_nodes_in_group(
		"construction_sites"
	):
		if not node is ConstructionSite:
			continue
		var site := node as ConstructionSite
		if site.is_queued_for_deletion() or site.job == null:
			continue
		if not site.accepts_planned_connections():
			continue
		if not is_instance_valid(site.target_definition):
			continue
		if site.target_definition.building_id != &"test_storage":
			continue

		for input_side: bool in [true, false]:
			# The new registry and legacy live-belt reservation both own
			# the future port exclusively. Neither may be overwritten.
			if port_registry.has_building_claim(site, input_side):
				continue
			if is_instance_valid(site.get_reserved_conveyor(input_side)):
				continue

			var proposed: Dictionary = site.get_planned_belt_transform(
				preview_belt, input_side
			)
			if not proposed.has("transform"):
				continue
			var candidate: Transform3D = proposed["transform"]
			var forward := (
				candidate.basis * Vector3.FORWARD
			).normalized()
			if not auto_orient and requested_forward.dot(forward) < 0.98:
				continue
			if not FactoryGrid.is_on_conveyor_grid(candidate.origin):
				continue

			var marker := site.get_planned_port(input_side)
			if marker == null:
				continue
			var center_offset := Vector2(
				mouse_world.x - candidate.origin.x,
				mouse_world.z - candidate.origin.z
			)
			var marker_offset := Vector2(
				mouse_world.x - marker.global_position.x,
				mouse_world.z - marker.global_position.z
			)
			var distance_sq := minf(
				center_offset.length_squared(),
				marker_offset.length_squared()
			)
			if distance_sq >= best_distance_sq:
				continue
			best_distance_sq = distance_sq
			best = {
				"site": site,
				"input_side": input_side,
				"transform": candidate,
				"distance_squared": distance_sq
			}
	return best
