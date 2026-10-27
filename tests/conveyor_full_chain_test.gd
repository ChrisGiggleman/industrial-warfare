
extends Node


# =============================================================================
# CHAT 07 — FULL CONVEYOR CHAIN REGRESSION TEST
# =============================================================================

# Tests the new automatic corner-conversion foundation.
#
# Verifies:
# - Existing incoming connections survive conversion.
# - The original corner node remains the same object.
# - New outgoing conveyors connect correctly.
# - Rotation preserves endpoint alignment.
# - Demolition cleans up references.
# - Left turns also work in a rotated assembly.
#
# This test does not modify Build Mode or move items.


# =============================================================================
# CREATE STRAIGHT TEST CONVEYOR
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:

	var belt: ConveyorSegment = (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(belt != null)

	parent.add_child(belt)

	return belt


# =============================================================================
# RUN FULL CHAIN TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: FULL CONVEYOR CHAIN TEST =====")

	var test_root := Node3D.new()
	add_child(test_root)

	# =============================================================================
	# CREATE FOUR-SEGMENT RIGHT-TURN CHAIN
	# =============================================================================

	var incoming := _make_belt(test_root)
	var corner_source := _make_belt(test_root)
	var receiver := _make_belt(test_root)
	var downstream := _make_belt(test_root)

	incoming.position = Vector3(0, 0, 1)
	corner_source.position = Vector3.ZERO

	receiver.position = Vector3(1, 0, 0)
	receiver.rotation_degrees.y = -90.0

	downstream.position = Vector3(2, 0, 0)
	downstream.rotation_degrees.y = -90.0

	# =============================================================================
	# TEST A — ESTABLISH ORIGINAL INCOMING CONNECTION
	# =============================================================================

	assert(incoming.try_connect_to(corner_source))
	assert(incoming.next_segment == corner_source)
	assert(corner_source.previous_segment == incoming)

	print("PASS A: Original incoming connection established")

	# =============================================================================
	# TEST B — CONVERSION PRESERVES INCOMING CONNECTION
	# =============================================================================

	var original_id: int = corner_source.get_instance_id()

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			corner_source,
			receiver,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(corner_source.get_instance_id() == original_id)
	assert(incoming.next_segment == corner_source)
	assert(corner_source.previous_segment == incoming)

	assert(corner_source.next_segment == receiver)
	assert(receiver.previous_segment == corner_source)

	print("PASS B: Right conversion preserves identity and incoming link")

	# =============================================================================
	# TEST C — BOTH CORNER ENDPOINTS REMAIN ALIGNED
	# =============================================================================

	var incoming_output: Marker3D = (
		incoming.get_node("OutputEndpoint") as Marker3D
	)

	var corner_input: Marker3D = (
		corner_source.get_node("InputEndpoint") as Marker3D
	)

	var corner_output: Marker3D = (
		corner_source.get_node("OutputEndpoint") as Marker3D
	)

	var receiver_input: Marker3D = (
		receiver.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			incoming_output,
			corner_input,
			0.05
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			corner_output,
			receiver_input,
			0.05
		)
	)

	print("PASS C: Both corner connections are physically aligned")

	# =============================================================================
	# TEST D — EXTEND CHAIN AFTER THE CORNER
	# =============================================================================

	assert(receiver.try_connect_to(downstream))

	assert(receiver.next_segment == downstream)
	assert(downstream.previous_segment == receiver)

	print("PASS D: Straight conveyor extends after corner")

	# =============================================================================
	# TEST E — ROTATE COMPLETE CHAIN
	# =============================================================================

	test_root.rotation_degrees.y = 90.0

	var receiver_output: Marker3D = (
		receiver.get_node("OutputEndpoint") as Marker3D
	)

	var downstream_input: Marker3D = (
		downstream.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			incoming_output,
			corner_input,
			0.05
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			corner_output,
			receiver_input,
			0.05
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			receiver_output,
			downstream_input,
			0.05
		)
	)

	print("PASS E: Complete conveyor chain survives rotation")

	# =============================================================================
	# TEST F — DEMOLISH THE CORNER
	# =============================================================================

	corner_source.free()

	assert(incoming.next_segment == null)
	assert(receiver.previous_segment == null)

	print("PASS F: Corner demolition clears both neighboring links")

	# =============================================================================
	# TEST G — OTHER CONNECTIONS SURVIVE DEMOLITION
	# =============================================================================

	assert(receiver.next_segment == downstream)
	assert(downstream.previous_segment == receiver)

	assert(receiver.disconnect_next())
	assert(downstream.previous_segment == null)

	print("PASS G: Unrelated downstream connection remains safe")

	# =============================================================================
	# TEST H — LEFT CORNER WITH ROTATED PARENT
	# =============================================================================

	var left_root := Node3D.new()
	add_child(left_root)

	var left_incoming := _make_belt(left_root)
	var left_source := _make_belt(left_root)
	var left_receiver := _make_belt(left_root)

	left_incoming.position = Vector3(5, 0, 1)
	left_source.position = Vector3(5, 0, 0)

	left_receiver.position = Vector3(4, 0, 0)
	left_receiver.rotation_degrees.y = 90.0

	left_root.rotation_degrees.y = 90.0

	assert(left_incoming.try_connect_to(left_source))

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			left_source,
			left_receiver,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(left_incoming.next_segment == left_source)
	assert(left_source.previous_segment == left_incoming)

	assert(left_source.next_segment == left_receiver)
	assert(left_receiver.previous_segment == left_source)

	print("PASS H: Rotated left-turn chain preserves incoming connection")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	test_root.queue_free()
	left_root.queue_free()

	print("==========================================")
	print("ALL 8 FULL CONVEYOR CHAIN TESTS PASSED")
	print("==========================================")
