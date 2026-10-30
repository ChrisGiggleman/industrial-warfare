
extends Node


# =============================================================================
# LEFT CORNER CONNECTION REGRESSION TEST
# =============================================================================

# Verifies:
# Straight A -> Left Corner -> Straight B
#
# Tests physical alignment, turn direction, connection
# ownership, rotation, and demolition cleanup.
#
# No inventory movement or Build Mode changes.


func _ready() -> void:

	print("\n===== CHAT 07: LEFT CORNER TEST =====")

	# =============================================================================
	# LOAD CONVEYOR SCENES
	# =============================================================================

	var straight_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	var corner_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_corner_left.tscn"
	) as PackedScene

	assert(straight_scene != null)
	assert(corner_scene != null)

	# =============================================================================
	# CREATE ISOLATED TEST ASSEMBLY
	# =============================================================================

	var test_root := Node3D.new()
	add_child(test_root)

	var belt_a: ConveyorSegment = (
		straight_scene.instantiate() as ConveyorSegment
	)

	var corner: ConveyorSegment = (
		corner_scene.instantiate() as ConveyorSegment
	)

	var belt_b: ConveyorSegment = (
		straight_scene.instantiate() as ConveyorSegment
	)

	assert(belt_a != null)
	assert(corner != null)
	assert(belt_b != null)

	test_root.add_child(belt_a)
	test_root.add_child(corner)
	test_root.add_child(belt_b)

	# =============================================================================
	# POSITION LEFT-TURN CHAIN
	# =============================================================================

	# Belt A travels toward -Z.
	# Corner receives from +Z and outputs toward -X.
	# Belt B must travel toward -X.

	belt_a.position = Vector3(0.0, 0.0, 1.0)

	corner.position = Vector3.ZERO

	belt_b.position = Vector3(-1.0, 0.0, 0.0)
	belt_b.rotation_degrees.y = 90.0

	# =============================================================================
	# TEST A — ENDPOINTS EXIST
	# =============================================================================

	var a_output: Marker3D = (
		belt_a.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var corner_input: Marker3D = (
		corner.get_node_or_null("InputEndpoint") as Marker3D
	)

	var corner_output: Marker3D = (
		corner.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var b_input: Marker3D = (
		belt_b.get_node_or_null("InputEndpoint") as Marker3D
	)

	assert(a_output != null)
	assert(corner_input != null)
	assert(corner_output != null)
	assert(b_input != null)

	print("PASS A: All left-turn endpoints exist")

	# =============================================================================
	# TEST B — BELT A TO LEFT CORNER
	# =============================================================================

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			a_output,
			corner_input,
			0.05
		)
	)

	print("PASS B: Straight A connects to left corner input")

	# =============================================================================
	# TEST C — LEFT CORNER TO BELT B
	# =============================================================================

	assert(
		corner_output.global_position.distance_to(
			b_input.global_position
		) < 0.001
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			corner_output,
			b_input,
			0.05
		)
	)

	print("PASS C: Left corner connects to Straight B")

	# =============================================================================
	# TEST D — CORRECT LEFT-TURN DIRECTION
	# =============================================================================

	var incoming_direction: Vector3 = (
		-a_output.global_transform.basis.z
	).normalized()

	var outgoing_direction: Vector3 = (
		-corner_output.global_transform.basis.z
	).normalized()

	# Input and output directions are perpendicular.

	assert(
		absf(
			incoming_direction.dot(outgoing_direction)
		) < 0.001
	)

	# Unrotated left corner must output toward world -X.

	assert(
		outgoing_direction.dot(Vector3.LEFT) > 0.999
	)

	print("PASS D: Corner makes a genuine left turn")

	# =============================================================================
	# TEST E — INCORRECT RECEIVER ROTATION REJECTED
	# =============================================================================

	belt_b.rotation_degrees.y = -90.0

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			corner_output,
			b_input,
			0.05
		)
	)

	# Restore valid receiver orientation.

	belt_b.rotation_degrees.y = 90.0

	print("PASS E: Incorrect receiving direction rejected")

	# =============================================================================
	# TEST F — ESTABLISH DIRECTED CONNECTIONS
	# =============================================================================

	assert(belt_a.try_connect_to(corner))
	assert(corner.try_connect_to(belt_b))

	assert(belt_a.next_segment == corner)
	assert(corner.previous_segment == belt_a)

	assert(corner.next_segment == belt_b)
	assert(belt_b.previous_segment == corner)

	print("PASS F: A -> Left Corner -> B connected")

	# =============================================================================
	# TEST G — ROTATE COMPLETE ASSEMBLY
	# =============================================================================

	test_root.rotation_degrees.y = 90.0

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			a_output,
			corner_input,
			0.05
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			corner_output,
			b_input,
			0.05
		)
	)

	print("PASS G: Left-turn chain survives rotation")

	# =============================================================================
	# TEST H — REMOVE CORNER SAFELY
	# =============================================================================

	corner.free()

	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null)

	print("PASS H: Removing corner clears both connections")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	test_root.queue_free()

	print("==========================================")
	print("ALL 8 LEFT CORNER TESTS PASSED")
	print("==========================================")
