extends RefCounted
class_name BlueprintStoragePortSnapPreview

# =============================================================================
# SANDBOX BUILDING BLUEPRINT PORT SNAPPING — READ-ONLY DISCOVERY
# =============================================================================
# Suggests a straight belt transform for any unfinished building item port.
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
		if site.target_definition.building_id == &"conveyor_belt":
			continue

		for input_side: bool in [true, false]:
			for port_name: StringName in site.get_planned_port_names(input_side):
				var proposed: Dictionary = _inspect_port(
					site, preview_belt, port_registry, input_side,
					port_name, mouse_world, requested_forward, best_distance_sq,
					auto_orient
				)
				if proposed.is_empty():
					continue
				best_distance_sq = float(proposed["distance_squared"])
				best = proposed
	return best


static func _inspect_port(
	site: ConstructionSite,
	preview_belt: ConveyorSegment,
	port_registry: PlannedBuildingPortReservations,
	input_side: bool,
	port_name: StringName,
	mouse_world: Vector3,
	requested_forward: Vector3,
	max_distance_sq: float,
	auto_orient: bool
) -> Dictionary:
	if port_registry.has_building_claim(site, input_side, port_name):
		return {}
	if port_name in [&"InputPort", &"OutputPort"]:
		if is_instance_valid(site.get_reserved_conveyor(input_side)):
			return {}
	var proposed: Dictionary = site.get_planned_belt_transform_named(
		preview_belt, port_name
	)
	if not proposed.has("transform"):
		return {}
	var candidate: Transform3D = proposed["transform"]
	var forward: Vector3 = (
		candidate.basis * Vector3.FORWARD
	).normalized()
	if not auto_orient and requested_forward.dot(forward) < 0.98:
		return {}
	if not FactoryGrid.is_on_conveyor_grid(candidate.origin):
		return {}
	var marker := site.get_planned_port_named(port_name)
	if marker == null:
		return {}
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
	if distance_sq >= max_distance_sq:
		return {}
	return {
		"site": site,
		"input_side": input_side,
		"port_name": port_name,
		"transform": candidate,
		"distance_squared": distance_sq
	}
