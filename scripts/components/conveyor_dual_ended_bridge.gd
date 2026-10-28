extends RefCounted
class_name ConveyorDualEndedBridge


# =============================================================================
# CHAT 08.3F-6 — TWO-ENDED CONVEYOR BRIDGE
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
