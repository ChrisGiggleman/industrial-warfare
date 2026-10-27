
extends Node


# =============================================================================
# CHAT 07 — AUTOMATIC CORNER CONVERSION TEST
# =============================================================================

# Tests conversion of the preceding belt in place.
#
# No Build Mode changes.
# No item transportation.
# No original conveyor scenes are edited.


# =============================================================================
# TEST HELPER
# =============================================================================

func _make_straight(parent: Node3D) -> ConveyorSegment:

	var belt: ConveyorSegment = (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(belt != null)

	parent.add_child(belt)
	return belt


# =============================================================================
# RUN ISOLATED TESTS
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: CORNER CONVERSION TEST =====")

	var root := Node3D.new()
	add_child(root)

	# =============================================================================
	# TEST A — RIGHT-TURN CONVERSION
	# =============================================================================

	var source_right := _make_straight(root)
	var receiver_right := _make_straight(root)

	source_right.position = Vector3.ZERO

	receiver_right.position = Vector3(1, 0, 0)
	receiver_right.rotation_degrees.y = -90.0

	var original_mesh: Mesh = source_right.selection_mesh.mesh

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			source_right,
			receiver_right,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(source_right.next_segment == receiver_right)
	assert(receiver_right.previous_segment == source_right)

	assert(source_right.selection_mesh.mesh != original_mesh)

	print("PASS A: Existing straight converted to right corner")

	# =============================================================================
	# TEST B — CORNER OUTPUT ALIGNED WITH NEW STRAIGHT
	# =============================================================================

	var right_output: Marker3D = (
		source_right.get_node("OutputEndpoint") as Marker3D
	)

	var right_input: Marker3D = (
		receiver_right.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			right_output,
			right_input,
			0.05
		)
	)

	assert(
		right_output.position.is_equal_approx(
			Vector3(0.5, 0.5, 0.0)
		)
	)

	print("PASS B: Right corner output aligned")

	# =============================================================================
	# TEST C — PREVENT REPEATED CONVERSION
	# =============================================================================

	assert(
		not ConveyorCornerConversion.try_convert_and_connect(
			source_right,
			receiver_right,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(source_right.next_segment == receiver_right)

	print("PASS C: Existing connection cannot be overwritten")

	# =============================================================================
	# TEST D — INVALID GEOMETRY ROLLS BACK
	# =============================================================================

	var invalid_source := _make_straight(root)
	var invalid_receiver := _make_straight(root)

	invalid_source.position = Vector3(5, 0, 0)
	invalid_receiver.position = Vector3(6, 0, 0)

	# Incorrect receiver facing for a right turn.

	invalid_receiver.rotation_degrees.y = 90.0

	var original_output: Transform3D = (
		invalid_source.get_node("OutputEndpoint").transform
	)

	var invalid_original_mesh: Mesh = (
		invalid_source.selection_mesh.mesh
	)

	assert(
		not ConveyorCornerConversion.try_convert_and_connect(
			invalid_source,
			invalid_receiver,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(
		invalid_source.get_node("OutputEndpoint").transform
		== original_output
	)

	assert(invalid_source.selection_mesh.mesh == invalid_original_mesh)
	assert(invalid_source.next_segment == null)
	assert(invalid_receiver.previous_segment == null)

	print("PASS D: Invalid turn preserves original straight")

	# =============================================================================
	# TEST E — OCCUPIED OUTPUT REJECTS CONVERSION
	# =============================================================================

	var occupied_source := _make_straight(root)
	var occupied_target := _make_straight(root)
	var side_target := _make_straight(root)

	occupied_source.position = Vector3(10, 0, 0)
	occupied_target.position = Vector3(10, 0, -1)

	side_target.position = Vector3(11, 0, 0)
	side_target.rotation_degrees.y = -90.0

	assert(occupied_source.try_connect_to(occupied_target))

	assert(
		not ConveyorCornerConversion.try_convert_and_connect(
			occupied_source,
			side_target,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(occupied_source.next_segment == occupied_target)
	assert(side_target.previous_segment == null)

	print("PASS E: Occupied output safely rejected")

	# =============================================================================
	# TEST F — LEFT-TURN CONVERSION
	# =============================================================================

	var source_left := _make_straight(root)
	var receiver_left := _make_straight(root)

	source_left.position = Vector3(15, 0, 0)

	receiver_left.position = Vector3(14, 0, 0)
	receiver_left.rotation_degrees.y = 90.0

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			source_left,
			receiver_left,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(source_left.next_segment == receiver_left)
	assert(receiver_left.previous_segment == source_left)

	var left_output: Marker3D = (
		source_left.get_node("OutputEndpoint") as Marker3D
	)

	var left_input: Marker3D = (
		receiver_left.get_node("InputEndpoint") as Marker3D
	)

	assert(
		left_output.position.is_equal_approx(
			Vector3(-0.5, 0.5, 0.0)
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			left_output,
			left_input,
			0.05
		)
	)

	print("PASS F: Existing straight converted to left corner")

	# =============================================================================
	# TEST G — INVALID TURN TYPE REJECTED
	# =============================================================================

	var unknown_source := _make_straight(root)
	var unknown_target := _make_straight(root)

	unknown_source.position = Vector3(20, 0, 0)
	unknown_target.position = Vector3(21, 0, 0)
	unknown_target.rotation_degrees.y = -90.0

	assert(
		not ConveyorCornerConversion.try_convert_and_connect(
			unknown_source,
			unknown_target,
			-1
		)
	)

	assert(unknown_source.next_segment == null)

	print("PASS G: Unknown turn rejected")

	# =============================================================================
	# TEST H — REMOVAL CLEANS THE NEW CONNECTION
	# =============================================================================

	source_right.free()

	assert(receiver_right.previous_segment == null)

	print("PASS H: Converted corner demolition disconnects safely")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 8 CORNER CONVERSION TESTS PASSED")
	print("==========================================")
