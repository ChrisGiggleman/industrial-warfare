
extends Node


# =============================================================================
# CHAT 07 — CONVEYOR ALIGNMENT REGRESSION TEST
# =============================================================================

# Tests two actual ConveyorStraight scenes using
# our existing LogisticsConnectionGeometry helper.
#
# These tests validate physical endpoint alignment.
#
# No conveyor transport or inventory movement occurs.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: CONVEYOR ALIGNMENT TEST =====")

	var conveyor_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(conveyor_scene != null)


	# =============================================================================
	# CREATE ISOLATED CONVEYOR TEST AREA
	# =============================================================================

	# One shared parent lets us test rotation of
	# an entire connected conveyor assembly.

	var test_root := Node3D.new()
	test_root.name = "ConveyorTestRoot"

	add_child(test_root)

	var belt_a: Node3D = (
		conveyor_scene.instantiate() as Node3D
	)

	var belt_b: Node3D = (
		conveyor_scene.instantiate() as Node3D
	)

	assert(belt_a != null)
	assert(belt_b != null)

	test_root.add_child(belt_a)
	test_root.add_child(belt_b)

	# Default belt flow runs from +Z toward -Z.
	#
	# Belt A occupies Z = 0.
	# Belt B occupies Z = -1.
	#
	# A's output at Z = -0.5 should meet
	# B's input at Z = -0.5.

	belt_a.position = Vector3.ZERO
	belt_b.position = Vector3(0.0, 0.0, -1.0)


	# =============================================================================
	# TEST A — CONVEYOR ENDPOINTS EXIST
	# =============================================================================

	var output_a: Marker3D = (
		belt_a.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	var input_b: Marker3D = (
		belt_b.get_node_or_null("InputEndpoint")
		as Marker3D
	)

	var input_a: Marker3D = (
		belt_a.get_node_or_null("InputEndpoint")
		as Marker3D
	)

	var output_b: Marker3D = (
		belt_b.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	assert(output_a != null)
	assert(input_b != null)
	assert(input_a != null)
	assert(output_b != null)

	print("PASS A: Both conveyor scenes and endpoints loaded")


	# =============================================================================
	# TEST B — TWO SNAPPED CONVEYORS
	# =============================================================================

	# One-unit center spacing places the endpoints
	# together at the same world position.

	assert(
		output_a.global_position.distance_to(
			input_b.global_position
		) < 0.001
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	print("PASS B: Snapped conveyor endpoints aligned")


	# =============================================================================
	# TEST C — SMALL VALID CONNECTION GAP
	# =============================================================================

	# Increase belt spacing by 0.2 world units.
	# The endpoints remain on the same axis.

	belt_b.position.z = -1.2

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	# A stricter tolerance must reject this gap.

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b,
			0.1
		)
	)

	belt_b.position.z = -1.0

	print("PASS C: Connection gap tolerance respected")


	# =============================================================================
	# TEST D — DISTANT CONVEYORS
	# =============================================================================

	belt_b.position.z = -2.0

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	belt_b.position.z = -1.0

	print("PASS D: Distant conveyors rejected")


	# =============================================================================
	# TEST E — INCORRECT FACING DIRECTION
	# =============================================================================

	# Rotate Belt B 180 degrees.
	#
	# Move its center to the origin so that its
	# input coincides with Belt A's output.
	#
	# The markers occupy the same position,
	# but now point in the SAME direction.

	belt_b.rotation_degrees.y = 180.0
	belt_b.position = Vector3.ZERO

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	belt_b.rotation_degrees.y = 0.0
	belt_b.position = Vector3(0.0, 0.0, -1.0)

	print("PASS E: Incorrect conveyor facing rejected")


	# =============================================================================
	# TEST F — SIDEWAYS MISALIGNMENT
	# =============================================================================

	belt_b.position.x = 0.5

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	belt_b.position.x = 0.0

	print("PASS F: Sideways conveyor offset rejected")


	# =============================================================================
	# TEST G — HEIGHT MISALIGNMENT
	# =============================================================================

	# Move Belt B above Belt A.
	# This first prototype supports level connections.

	belt_b.position.y = 0.4

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	belt_b.position.y = 0.0

	print("PASS G: Conveyor height mismatch rejected")


	# =============================================================================
	# TEST H — TARGET IS BEHIND SOURCE ENDPOINT
	# =============================================================================

	# Place Belt B so its input is behind Belt A's
	# output, relative to the output-facing direction.
	#
	# The distance is short and directions oppose,
	# but the relative placement is incorrect.

	belt_b.position.z = -0.75

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	belt_b.position.z = -1.0

	print("PASS H: Backward endpoint placement rejected")


	# =============================================================================
	# TEST I — ROTATE CONNECTED ASSEMBLY
	# =============================================================================

	# Rotate the common parent by 90 degrees.
	#
	# The belt endpoints must remain geometrically
	# compatible in world space after rotation.

	test_root.rotation_degrees.y = 90.0

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b
		)
	)

	assert(
		output_a.global_position.distance_to(
			input_b.global_position
		) < 0.001
	)

	print("PASS I: Aligned belts remain valid after rotation")


	# =============================================================================
	# TEST CLEANUP
	# =============================================================================

	# Remove temporary conveyor scenes.
	# The main factory and its building scenes are untouched.

	test_root.queue_free()


	# =============================================================================
	# FINAL TEST RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 9 CONVEYOR ALIGNMENT TESTS PASSED")
	print("==========================================")
