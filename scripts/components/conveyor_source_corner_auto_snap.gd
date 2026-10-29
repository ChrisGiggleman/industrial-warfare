extends RefCounted
class_name ConveyorSourceCornerAutoSnap

# =============================================================================
# CHAT 08.3G-3F — AUTO-DISCOVER CORNER AT AN EXISTING SOURCE OUTPUT
# =============================================================================

# Complements receiver-side discovery. The cursor must be near the
# existing SOURCE whose free output would become a corner.
# Its existing INPUT (including a building OUTPUT port) is preserved.
# Never offers an output already attached to a building.

static func find_nearest_preview(
	tree: SceneTree,
	mouse_world_position: Vector3,
	search_radius: float = 0.75
) -> Dictionary:
	if tree == null or search_radius <= 0.0:
		return {}

	var sources: Array[ConveyorSegment] = []
	var nearby: Array[ConveyorSegment] = []
	var radius_squared: float = search_radius * search_radius
	var outer_radius_squared: float = pow(search_radius + 2.0, 2)
	for node: Node in tree.get_nodes_in_group("player_built"):
		if not node is ConveyorSegment:
			continue
		var belt: ConveyorSegment = node as ConveyorSegment
		if not belt.is_inside_tree() or belt.is_queued_for_deletion():
			continue
		if belt.is_in_group("construction_preview"):
			continue
		var offset := Vector2(
			mouse_world_position.x - belt.global_position.x,
			mouse_world_position.z - belt.global_position.z
		)
		var d2: float = offset.length_squared()
		if d2 <= outer_radius_squared:
			nearby.append(belt)
		if (
			d2 <= radius_squared
			and not is_instance_valid(belt.next_segment)
			and not is_instance_valid(belt.output_building_port)
			and not belt.has_meta("conveyor_turn")
		):
			sources.append(belt)

	var best: Dictionary = {}
	var best_distance_squared: float = radius_squared

	for source: ConveyorSegment in sources:
		var mouse_offset := Vector2(
			mouse_world_position.x - source.global_position.x,
			mouse_world_position.z - source.global_position.z
		)
		var d2: float = mouse_offset.length_squared()
		for destination: ConveyorSegment in nearby:
			if source == destination:
				continue
			if is_instance_valid(destination.previous_segment):
				continue
			if is_instance_valid(destination.input_building_port):
				continue
			var candidate: Dictionary = (
				ConveyorExistingEndpointFinder.inspect_pair(
					source, destination
				)
			)
			if candidate.get("mode", "") != "convert_source":
				continue
			if d2 > best_distance_squared:
				continue
			best = candidate
			best_distance_squared = d2

	return best
