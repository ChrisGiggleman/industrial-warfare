
extends Node


# =============================================================================
# CHAT 07 — 90 DEGREE CONVEYOR CONNECTION TEST
# =============================================================================

# Tests a physical L-shaped conveyor chain:
#
# Straight A -> Corner -> Straight B
#
# Verifies:
# - Scene loading and endpoint references
# - Both connection points align
# - A genuine 90-degree direction change
# - Directed connection state
# - Occupied endpoint rejection
# - Assembly rotation
# - Safe deletion of the corner
#
# No item transport or Build Mode changes occur.


func _ready() -> void:

	print("\n===== CHAT 07: CONVEYOR CORNER TEST =====")

	# =============================================================================
	# LOAD CONVEYOR SCENES
	# =============================================================================

	var straight_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	var corner_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_corner.tscn"
	) as PackedScene

	assert(straight_scene != null)
	assert(corner_scene != null)

	# =============================================================================
	# CREATE ISOLATED ASSEMBLY
	# =============================================================================

	var test_root := Node3D.new()
	test_root.name = "CornerTestRoot"
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
	# POSITION L-SHAPED CONVEYOR CHAIN
	# =============================================================================

	# Straight A travels toward local -Z.
	# Its output meets the corner input.

	belt_a.position = Vector3(0.0, 0.0, 1.0)

	# Corner receives from +Z and exits toward +X.

	corner.position = Vector3.ZERO

	# Straight B receives from -X and exits toward +X.
	# Rotate it -90 degrees around the Y axis.

	belt_b.position = Vector3(1.0, 0.0, 0.0)
	belt_b.rotation_degrees.y = -90.0

	# =============================================================================
	# TEST A — ENDPOINT REFERENCES
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

	print("PASS A: Straight and corner endpoints loaded")

	# =============================================================================
	# TEST B — STRAIGHT A TO CORNER
	# =============================================================================

	assert(
		a_output.global_position.distance_to(
			corner_input.global_position
		) < 0.001
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			a_output,
			corner_input,
			0.05
		)
	)

	print("PASS B: Straight A output meets corner input")

	# =============================================================================
	# TEST C — CORNER TO STRAIGHT B
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

	print("PASS C: Corner output meets Straight B input")

	# =============================================================================
	# TEST D — CONFIRM 90 DEGREE DIRECTION CHANGE
	# =============================================================================

	# The forward directions of the entering straight
	# and the corner output must be perpendicular.

	var incoming_direction: Vector3 = (
		a_output.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	var outgoing_direction: Vector3 = (
		corner_output.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	assert(
		absf(
			incoming_direction.dot(outgoing_direction)
		) < 0.001
	)

	print("PASS D: Corner changes direction by 90 degrees")

	# =============================================================================
	# TEST E — CREATE BOTH DIRECTED CONNECTIONS
	# =============================================================================

	assert(belt_a.try_connect_to(corner))
	assert(corner.try_connect_to(belt_b))

	assert(belt_a.next_segment == corner)
	assert(corner.previous_segment == belt_a)

	assert(corner.next_segment == belt_b)
	assert(belt_b.previous_segment == corner)

	print("PASS E: Complete A -> Corner -> B chain connected")

	# =============================================================================
	# TEST F — REJECT EXTRA CONNECTIONS
	# =============================================================================

	# An additional feeder cannot enter an occupied input.

	var extra_feeder: ConveyorSegment = (
		straight_scene.instantiate() as ConveyorSegment
	)

	assert(extra_feeder != null)
	test_root.add_child(extra_feeder)

	extra_feeder.position = belt_a.position

	assert(not extra_feeder.try_connect_to(corner))

	# An occupied output cannot feed another conveyor.

	var extra_receiver: ConveyorSegment = (
		straight_scene.instantiate() as ConveyorSegment
	)

	assert(extra_receiver != null)
	test_root.add_child(extra_receiver)

	extra_receiver.position = belt_b.position
	extra_receiver.rotation_degrees.y = -90.0

	assert(not corner.try_connect_to(extra_receiver))

	assert(corner.previous_segment == belt_a)
	assert(corner.next_segment == belt_b)

	print("PASS F: Occupied corner endpoints reject extra links")

	# =============================================================================
	# TEST G — ROTATE COMPLETE ASSEMBLY
	# =============================================================================

	# All three connected segments rotate together.
	# Their world-space endpoints must still align.

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

	assert(belt_a.next_segment == corner)
	assert(corner.next_segment == belt_b)

	print("PASS G: Corner connections survive assembly rotation")

	# =============================================================================
	# TEST H — REMOVE CORNER AND CLEAN BOTH LINKS
	# =============================================================================

	# Removing the center segment should clear its
	# connections from both neighboring straights.

	corner.free()

	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null)

	print("PASS H: Corner removal safely disconnects both belts")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	test_root.queue_free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 8 CONVEYOR CORNER TESTS PASSED")
	print("==========================================")
