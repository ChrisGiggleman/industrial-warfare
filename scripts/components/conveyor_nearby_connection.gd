extends RefCounted
class_name ConveyorNearbyConnection


# =============================================================================
# COMPLETE ADJACENT PHYSICAL CONVEYOR CONNECTIONS
# =============================================================================

# A newly placed conveyor may touch TWO already-existing endpoints:
# one building port and one other building port/conveyor.
# Ordinary Build Mode snapping connects only its selected first end.
#
# Complete any uniquely matching free opposite endpoint without shifting
# the placed belt, moving a building or changing stored cargo.
# Alignment uses the same strict physical rules as normal connections.
# A side-by-side lane has no matching endpoint and stays independent.


# =============================================================================
# FIND UNIQUE MATCH FOR A FREE ENDPOINT
# =============================================================================

static func _find_unique_neighbor(
	belt: ConveyorSegment,
	input_side: bool
) -> Dictionary:
	if not is_instance_valid(belt) or not belt.is_inside_tree():
		return {}

	var marker := belt.get_node_or_null(
		"InputEndpoint" if input_side else "OutputEndpoint"
	) as Marker3D
	if not is_instance_valid(marker):
		return {}

	var matches: Array[Dictionary] = []

	for node: Node in belt.get_tree().get_nodes_in_group("player_built"):
		if node == belt or node.is_queued_for_deletion():
			continue
		if node.is_in_group("construction_preview"):
			continue

		if node is ConveyorSegment:
			var other := node as ConveyorSegment
			if not other.is_inside_tree():
				continue

			var other_endpoint: Marker3D = null
			if input_side:
				if (
					is_instance_valid(other.next_segment)
					or is_instance_valid(other.output_building_port)
				):
					continue
				other_endpoint = other.get_node_or_null("OutputEndpoint") as Marker3D
			else:
				if (
					is_instance_valid(other.previous_segment)
					or is_instance_valid(other.input_building_port)
				):
					continue
				other_endpoint = other.get_node_or_null("InputEndpoint") as Marker3D

			if not is_instance_valid(other_endpoint):
				continue

			var outgoing: Transform3D = (
				other_endpoint.global_transform
				if input_side else marker.global_transform
			)
			var incoming: Transform3D = (
				marker.global_transform
				if input_side else other_endpoint.global_transform
			)
			if ConveyorDualEndedBridge._transforms_align(outgoing, incoming):
				matches.append({"belt": other})
			continue

		# Item ports belong directly to the root building scene.
		if not node is Node3D:
			continue
		for child: Node in node.get_children():
			if not child is ItemPortComponent:
				continue
			var port := child as ItemPortComponent
			if (
				not port.is_inside_tree()
				or not is_instance_valid(port.inventory)
				or is_instance_valid(port.connected_conveyor)
			):
				continue
			if input_side and port.direction != ItemPortComponent.PortDirection.OUTPUT:
				continue
			if not input_side and port.direction != ItemPortComponent.PortDirection.INPUT:
				continue

			var outgoing: Transform3D = (
				port.global_transform
				if input_side else marker.global_transform
			)
			var incoming: Transform3D = (
				marker.global_transform
				if input_side else port.global_transform
			)
			if ConveyorDualEndedBridge._transforms_align(outgoing, incoming):
				matches.append({"port": port})

	# More than one possible physical target is ambiguous.
	# Never choose arbitrarily or overwrite an occupied connection.
	if matches.size() != 1:
		return {}
	return matches[0]


# =============================================================================
# COMPLETE FREE INPUT AND OUTPUT CONNECTIONS
# =============================================================================

static func complete_open_ends(belt: ConveyorSegment) -> int:
	if not is_instance_valid(belt) or not belt.is_inside_tree():
		return 0
	if belt.is_queued_for_deletion() or belt.is_in_group("construction_preview"):
		return 0

	var completed: int = 0
	if (
		not is_instance_valid(belt.previous_segment)
		and not is_instance_valid(belt.input_building_port)
	):
		var upstream: Dictionary = _find_unique_neighbor(belt, true)
		if upstream.has("port"):
			if belt.try_connect_building_port(upstream["port"] as ItemPortComponent):
				completed += 1
		elif upstream.has("belt"):
			if (upstream["belt"] as ConveyorSegment).try_connect_to(belt):
				completed += 1

	if (
		not is_instance_valid(belt.next_segment)
		and not is_instance_valid(belt.output_building_port)
	):
		var downstream: Dictionary = _find_unique_neighbor(belt, false)
		if downstream.has("port"):
			if belt.try_connect_building_port(downstream["port"] as ItemPortComponent):
				completed += 1
		elif downstream.has("belt"):
			if belt.try_connect_to(downstream["belt"] as ConveyorSegment):
				completed += 1

	return completed
