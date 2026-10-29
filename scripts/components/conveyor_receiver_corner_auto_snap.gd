extends RefCounted
class_name ConveyorReceiverCornerAutoSnap


# =============================================================================
# CHAT 08.3G-3E — AUTOMATIC EXISTING RECEIVER CORNER DISCOVERY
# =============================================================================

# Read-only Build Mode search for connecting an existing conveyor's free
# INPUT to another conveyor's free OUTPUT by turning the receiver in place.
#
# The player's mouse must be near the RECEIVER'S OCCUPIED TILE.
# This is intentionally distinct from an empty one-tile missing corner.
#
# Scans player-built belts once, then checks only nearby pairs rather than
# examining every pair in a large factory every preview frame.


static func find_nearest_preview(
	tree: SceneTree,
	mouse_world_position: Vector3,
	search_radius: float = 0.75
) -> Dictionary:

	if tree == null or search_radius <= 0.0:
		return {}

	var nearby: Array[ConveyorSegment] = []
	var receivers: Array[ConveyorSegment] = []
	var outer_radius: float = search_radius + 2.0
	var outer_radius_squared: float = outer_radius * outer_radius
	var search_radius_squared: float = search_radius * search_radius

	for node: Node in tree.get_nodes_in_group("player_built"):
		if not node is ConveyorSegment:
			continue

		var belt: ConveyorSegment = node as ConveyorSegment
		if not belt.is_inside_tree():
			continue
		if belt.is_queued_for_deletion():
			continue
		if belt.is_in_group("construction_preview"):
			continue

		var mouse_offset := Vector2(
			belt.global_position.x - mouse_world_position.x,
			belt.global_position.z - mouse_world_position.z
		)
		var mouse_distance_squared: float = mouse_offset.length_squared()

		if mouse_distance_squared <= outer_radius_squared:
			nearby.append(belt)

		if (
			mouse_distance_squared <= search_radius_squared
			and not is_instance_valid(belt.previous_segment)
			and not is_instance_valid(belt.input_building_port)
			and not belt.has_meta("conveyor_turn")
		):
			receivers.append(belt)

	var nearest: Dictionary = {}
	var nearest_distance_squared: float = search_radius_squared

	for receiver: ConveyorSegment in receivers:
		var mouse_offset := Vector2(
			receiver.global_position.x - mouse_world_position.x,
			receiver.global_position.z - mouse_world_position.z
		)
		var distance_squared: float = mouse_offset.length_squared()

		for source: ConveyorSegment in nearby:
			if source == receiver:
				continue
			if is_instance_valid(source.next_segment):
				continue
			if is_instance_valid(source.output_building_port):
				continue

			# A valid adjacent corner is one tile away; allow the small
			# fractional offsets used by building-connected conveyors.
			var source_offset := Vector2(
				source.global_position.x - receiver.global_position.x,
				source.global_position.z - receiver.global_position.z
			)
			if source_offset.length_squared() > 3.0625:
				continue

			var candidate: Dictionary = (
				ConveyorExistingEndpointFinder.inspect_pair(
					source,
					receiver
				)
			)

			if candidate.get("mode", "") != "convert_receiver":
				continue

			if distance_squared > nearest_distance_squared:
				continue

			nearest = candidate
			nearest_distance_squared = distance_squared

	return nearest
