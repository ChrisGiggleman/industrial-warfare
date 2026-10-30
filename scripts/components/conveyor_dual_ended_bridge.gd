extends RefCounted
class_name ConveyorDualEndedBridge


# =============================================================================
# TWO-ENDED CONVEYOR BRIDGE
# =============================================================================

# Connects two already-placed conveyor lines by inserting ONE
# regular conveyor between an available source output and an
# available destination input.
#
# Directed flow: source -> bridge -> destination
#
# This helper deliberately does not:
# - Move real conveyor segments or adjust their spacing.
# - Resize a conveyor to close a partial-cell gap.
# - Bypass Build Mode collision validation.
# - Transfer or change any stored item.
# - Connect a conveyor to a building port directly.
#
# Preview is read-only. Commit revalidates all geometry and
# either establishes both links or restores the original state.


# =============================================================================
# ALIGNMENT USING WORLD ENDPOINT TRANSFORMS
# =============================================================================

# Same physical tolerance/direction rules as our established
# LogisticsConnectionGeometry.are_endpoints_aligned(), but
# accepts a *proposed* transform so preview doesn't move nodes.

static func _transforms_align(
	outgoing: Transform3D,
	incoming: Transform3D
) -> bool:

	var offset: Vector3 = incoming.origin - outgoing.origin

	if offset.length() > ConveyorSegment.CONNECTION_GAP:
		return false

	var forward_out: Vector3 = (
		outgoing.basis * Vector3.FORWARD
	).normalized()

	var forward_in: Vector3 = (
		incoming.basis * Vector3.FORWARD
	).normalized()

	if (
		forward_out.dot(forward_in)
		> -LogisticsConnectionGeometry.MIN_ALIGNMENT_DOT
	):
		return false

	if (
		offset.length_squared()
		> LogisticsConnectionGeometry.POSITION_EPSILON_SQUARED
	):

		if (
			forward_out.dot(offset.normalized())
			< LogisticsConnectionGeometry.MIN_ALIGNMENT_DOT
		):
			return false

	return true


# =============================================================================
# FIND EXACT TWO-ENDED PREVIEW
# =============================================================================

static func get_preview_transform(
	source: ConveyorSegment,
	bridge: ConveyorSegment,
	destination: ConveyorSegment
) -> Dictionary:

	# =============================================================================
	# VALIDATE THREE DISTINCT, ACTIVE NODES
	# =============================================================================

	if not is_instance_valid(source):
		return {}

	if not is_instance_valid(bridge):
		return {}

	if not is_instance_valid(destination):
		return {}

	if source == bridge or bridge == destination or source == destination:
		return {}

	for belt: ConveyorSegment in [source, bridge, destination]:

		if not belt.is_inside_tree():
			return {}

		if belt.is_queued_for_deletion():
			return {}

	# =============================================================================
	# REQUIRE OPEN OUTPUT -> INPUT -> OUTPUT -> INPUT
	# =============================================================================

	if is_instance_valid(source.next_segment):
		return {}

	if is_instance_valid(source.output_building_port):
		return {}

	if is_instance_valid(bridge.previous_segment):
		return {}

	if is_instance_valid(bridge.next_segment):
		return {}

	if is_instance_valid(bridge.input_building_port):
		return {}

	if is_instance_valid(bridge.output_building_port):
		return {}

	if is_instance_valid(destination.previous_segment):
		return {}

	if is_instance_valid(destination.input_building_port):
		return {}

	# =============================================================================
	# GET ENDPOINT MARKERS
	# =============================================================================

	var source_output: Marker3D = (
		source.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var bridge_input: Marker3D = (
		bridge.get_node_or_null("InputEndpoint") as Marker3D
	)

	var bridge_output: Marker3D = (
		bridge.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var destination_input: Marker3D = (
		destination.get_node_or_null("InputEndpoint") as Marker3D
	)

	if (
		source_output == null
		or bridge_input == null
		or bridge_output == null
		or destination_input == null
	):
		return {}

	# =============================================================================
	# PLACE VIRTUAL BRIDGE AFTER SOURCE
	# =============================================================================

	var first_preview: Dictionary = (
		bridge.get_snap_preview_transform_after(source)
	)

	if first_preview.is_empty():
		return {}

	var proposed: Transform3D = first_preview["transform"]

	# Don't move the ghost. Calculate where both of its
	# markers would be if placed at the proposed transform.

	var proposed_input: Transform3D = (
		proposed * bridge_input.transform
	)

	var proposed_output: Transform3D = (
		proposed * bridge_output.transform
	)

	# =============================================================================
	# BOTH ENDS MUST PHYSICALLY ALIGN
	# =============================================================================

	if not _transforms_align(
		source_output.global_transform,
		proposed_input
	):
		return {}

	if not _transforms_align(
		proposed_output,
		destination_input.global_transform
	):
		return {}

	return {
		"transform": proposed,
		"source": source,
		"destination": destination
	}


# =============================================================================
# COMMIT BOTH DIRECTED CONNECTIONS ATOMICALLY
# =============================================================================

static func try_connect(
	source: ConveyorSegment,
	bridge: ConveyorSegment,
	destination: ConveyorSegment
) -> bool:

	# Recheck all endpoint occupancy and geometry immediately
	# before placement. This must not silently move the bridge.

	var preview: Dictionary = get_preview_transform(
		source, bridge, destination
	)

	if preview.is_empty():
		return false

	var expected: Transform3D = preview["transform"]

	if not bridge.global_transform.is_equal_approx(expected):
		return false

	# =============================================================================
	# CONNECT SOURCE -> BRIDGE
	# =============================================================================

	if not source.try_connect_to(bridge):
		return false

	# =============================================================================
	# CONNECT BRIDGE -> DESTINATION OR ROLL BACK
	# =============================================================================

	if not bridge.try_connect_to(destination):

		# Only undo the newly established first link.
		# All three inventories and earlier connections stay intact.

		if source.next_segment == bridge:
			source.disconnect_next()

		return false

	return true


# =============================================================================
# DISCOVER THE NEAREST EXACT BRIDGE FROM BUILD MODE
# =============================================================================

# Called from a temporary, already-rotated conveyor ghost.
# The result is read-only: a source, destination, and exact
# placement transform, or {} if no ONE-PIECE gap can be bridged.
#
# Building-port and corner connections remain separate tools.
# Only real player-built conveyors are considered.

static func find_nearest_preview(
	preview_belt: ConveyorSegment,
	mouse_world_position: Vector3,
	search_radius: float = 1.25
) -> Dictionary:

	if not is_instance_valid(preview_belt):
		return {}

	if not preview_belt.is_inside_tree():
		return {}

	if preview_belt.is_queued_for_deletion():
		return {}

	if search_radius <= 0.0:
		return {}

	var bridge_input: Marker3D = (
		preview_belt.get_node_or_null("InputEndpoint") as Marker3D
	)

	var bridge_output: Marker3D = (
		preview_belt.get_node_or_null("OutputEndpoint") as Marker3D
	)

	if bridge_input == null or bridge_output == null:
		return {}

	# The ghost must not already own any incoming/outgoing link.

	if (
		is_instance_valid(preview_belt.previous_segment)
		or is_instance_valid(preview_belt.next_segment)
		or is_instance_valid(preview_belt.input_building_port)
		or is_instance_valid(preview_belt.output_building_port)
	):
		return {}

	var requested_forward: Vector3 = (
		preview_belt.global_transform.basis * Vector3.FORWARD
	).normalized()

	var real_belts: Array[ConveyorSegment] = []

	for node: Node in (
		preview_belt.get_tree().get_nodes_in_group("player_built")
	):

		if not node is ConveyorSegment:
			continue

		var belt: ConveyorSegment = node as ConveyorSegment

		if belt == preview_belt:
			continue

		if not belt.is_inside_tree() or belt.is_queued_for_deletion():
			continue

		# Unlike processing mode, this explicit group marks only
		# temporary build ghosts. Real disabled buildings still work.

		if belt.is_in_group("construction_preview"):
			continue

		real_belts.append(belt)

	var best_result: Dictionary = {}
	var best_distance_squared: float = search_radius * search_radius

	# =============================================================================
	# TEST FREE SOURCE OUTPUTS NEAR THE ORIGINAL MOUSE POSITION
	# =============================================================================

	for source: ConveyorSegment in real_belts:

		if is_instance_valid(source.next_segment):
			continue

		if is_instance_valid(source.output_building_port):
			continue

		var first_preview: Dictionary = (
			preview_belt.get_snap_preview_transform_after(source)
		)

		if first_preview.is_empty():
			continue

		var proposed: Transform3D = first_preview["transform"]

		# Do not rotate the ghost automatically. R controls travel direction.

		var proposed_forward: Vector3 = (
			proposed.basis * Vector3.FORWARD
		).normalized()

		if requested_forward.dot(proposed_forward) < 0.98:
			continue

		var mouse_offset := Vector2(
			mouse_world_position.x - proposed.origin.x,
			mouse_world_position.z - proposed.origin.z
		)

		var distance_squared: float = mouse_offset.length_squared()

		if distance_squared >= best_distance_squared:
			continue

		# Only destinations whose free input meets the proposed output
		# need a full two-ended geometry check.

		var expected_output: Transform3D = (
			proposed * bridge_output.transform
		)

		for destination: ConveyorSegment in real_belts:

			if source == destination:
				continue

			if is_instance_valid(destination.previous_segment):
				continue

			if is_instance_valid(destination.input_building_port):
				continue

			var destination_input: Marker3D = (
				destination.get_node_or_null("InputEndpoint") as Marker3D
			)

			if destination_input == null:
				continue

			if (
				expected_output.origin.distance_to(
					destination_input.global_position
				) > ConveyorSegment.CONNECTION_GAP
			):
				continue

			var exact_preview: Dictionary = get_preview_transform(
				source,
				preview_belt,
				destination
			)

			if exact_preview.is_empty():
				continue

			best_distance_squared = distance_squared

			best_result = {
				"source": source,
				"destination": destination,
				"transform": exact_preview["transform"],
				"distance_squared": distance_squared
			}

	return best_result
