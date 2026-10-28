
extends RefCounted
class_name ConveyorCornerPlacementSnap


# =============================================================================
# CHAT 08.3F-2C — BUILDING-CONNECTED CONVEYOR CORNER SNAP
# =============================================================================

# Calculates a new straight conveyor's transform when
# the existing straight must become a right or left corner.
#
# Uses actual endpoint positions, not integer grid origins.
#
# This supports building-connected conveyors positioned
# at fractional world coordinates.
#
# Does not change scenes, inventories or connections.


# =============================================================================
# CALCULATE CORNER PLACEMENT PREVIEW
# =============================================================================

static func get_preview_transform(
	source: ConveyorSegment,
	receiver: ConveyorSegment,
	turn: int
) -> Dictionary:

	# =============================================================================
	# VALIDATE CONVEYORS
	# =============================================================================

	if not is_instance_valid(source):
		return {}

	if not is_instance_valid(receiver):
		return {}

	if source == receiver:
		return {}

	if not source.is_inside_tree():
		return {}

	if not receiver.is_inside_tree():
		return {}

	if source.is_queued_for_deletion():
		return {}

	if receiver.is_queued_for_deletion():
		return {}

	# An output already feeding a belt or building
	# cannot also feed a new corner.

	if is_instance_valid(source.next_segment):
		return {}

	if is_instance_valid(source.output_building_port):
		return {}

	if is_instance_valid(receiver.previous_segment):
		return {}

	if is_instance_valid(receiver.input_building_port):
		return {}

	# =============================================================================
	# VALIDATE TURN TYPE
	# =============================================================================

	if (
		turn != ConveyorTurnIntent.Turn.RIGHT
		and turn != ConveyorTurnIntent.Turn.LEFT
	):
		return {}

	# =============================================================================
	# GET EXISTING ENDPOINTS
	# =============================================================================

	var source_output := source.get_node_or_null(
		"OutputEndpoint"
	) as Marker3D

	var receiver_input := receiver.get_node_or_null(
		"InputEndpoint"
	) as Marker3D

	var receiver_output := receiver.get_node_or_null(
		"OutputEndpoint"
	) as Marker3D

	if (
		source_output == null
		or receiver_input == null
		or receiver_output == null
	):
		return {}

	# Both pieces must still be unconverted straights.

	if not source_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	if not receiver_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	# =============================================================================
	# LOAD CORNER ENDPOINT TEMPLATE
	# =============================================================================

	var template_scene: PackedScene = (
		ConveyorPieceSelector.get_scene_for_turn(turn)
	)

	if template_scene == null:
		return {}

	var template := (
		template_scene.instantiate() as ConveyorSegment
	)

	if template == null:
		return {}

	var corner_output := template.get_node_or_null(
		"OutputEndpoint"
	) as Marker3D

	if corner_output == null:
		template.free()
		return {}

	# =============================================================================
	# PRESERVE REQUESTED CONVEYOR DIRECTION
	# =============================================================================

	var source_basis: Basis = (
		source.global_transform.basis.orthonormalized()
	)

	var receiver_basis: Basis = (
		receiver.global_transform.basis.orthonormalized()
	)

	var desired_forward: Vector3 = source_basis.x

	if turn == ConveyorTurnIntent.Turn.LEFT:
		desired_forward = -source_basis.x

	var receiver_forward: Vector3 = (
		receiver_basis * Vector3.FORWARD
	).normalized()

	if receiver_forward.dot(desired_forward) < 0.98:
		template.free()
		return {}

	# =============================================================================
	# FIND THE FUTURE CORNER OUTPUT
	# =============================================================================

	# Calculate the world transform the source output
	# will have AFTER in-place corner conversion.
	#
	# We do not actually change the source yet.

	var future_output: Transform3D = (
		source.global_transform * corner_output.transform
	)

	# =============================================================================
	# VERIFY OPPOSITE ENDPOINT FACING
	# =============================================================================

	var outgoing_forward: Vector3 = (
		future_output.basis * Vector3.FORWARD
	).normalized()

	var incoming_forward: Vector3 = (
		receiver_basis
		* receiver_input.transform.basis
		* Vector3.FORWARD
	).normalized()

	if outgoing_forward.dot(incoming_forward) > -0.98:
		template.free()
		return {}

	# =============================================================================
	# CALCULATE EXACT RECEIVER POSITION
	# =============================================================================

	# Align the new belt input with the future corner
	# output, including fractional building offsets.

	var snapped_position: Vector3 = (
		future_output.origin
		- receiver_basis * receiver_input.position
	)

	var snapped_transform := Transform3D(
		receiver_basis,
		snapped_position
	)

	template.free()

	# =============================================================================
	# RETURN PREVIEW WITHOUT MODIFYING CONNECTIONS
	# =============================================================================

	return {
		"transform": snapped_transform,
		"source": source,
		"turn": turn
	}
