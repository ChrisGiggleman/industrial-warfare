
extends Node


# =============================================================================
# CHAT 07 — CORNER SNAP PREVIEW FOUNDATION TEST
# =============================================================================

# Confirms that our existing snapping method can position
# a ConveyorCorner after a straight conveyor.
#
# Also verifies:
# - No premature connection during preview
# - Both ends of an L-shaped chain align
# - The corner survives parent rotation
# - Occupied outputs reject new previews
#
# No changes to Build Mode or inventory transport.


func _ready() -> void:

	print("\n===== CHAT 07: CORNER SNAP PREVIEW TEST =====")

	# =============================================================================
	# LOAD THE TWO INDEPENDENT CONVEYOR SCENES
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

	belt_a.position = Vector3(2.0, 0.0, 3.0)
	corner.position = Vector3(10.0, 0.0, 10.0)

	# =============================================================================
	# TEST A — CALCULATE CORNER SNAP POSITION
	# =============================================================================

	var preview: Dictionary = (
		corner.get_snap_preview_transform_after(belt_a)
	)

	assert(preview.has("transform"))

	print("PASS A: Corner snap transform calculated")

	# =============================================================================
	# TEST B — PREVIEW DOES NOT MODIFY CONNECTIONS
	# =============================================================================

	assert(corner.position == Vector3(10.0, 0.0, 10.0))
	assert(belt_a.next_segment == null)
	assert(corner.previous_segment == null)

	print("PASS B: Preview leaves gameplay state unchanged")

	# =============================================================================
	# TEST C — APPLY PREVIEW AND VALIDATE INPUT
	# =============================================================================

	# Simulate the placement ghost accepting the
	# proposed transform without creating a connection.

	corner.global_transform = preview["transform"]

	var a_output: Marker3D = (
		belt_a.get_node("OutputEndpoint") as Marker3D
	)

	var corner_input: Marker3D = (
		corner.get_node("InputEndpoint") as Marker3D
	)

	var corner_output: Marker3D = (
		corner.get_node("OutputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			a_output,
			corner_input,
			0.05
		)
	)

	assert(
		corner.global_position.distance_to(
			Vector3(2.0, 0.0, 2.0)
		) < 0.001
	)

	print("PASS C: Corner input snaps to existing output")

	# =============================================================================
	# TEST D — CORNER OUTPUT SUPPORTS A TURNED STRAIGHT
	# =============================================================================

	# The corner outputs toward +X.
	#
	# Rotate the receiving straight -90 degrees
	# so its input faces back toward the corner.

	belt_b.position = Vector3(3.0, 0.0, 2.0)
	belt_b.rotation_degrees.y = -90.0

	var b_input: Marker3D = (
		belt_b.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			corner_output,
			b_input,
			0.05
		)
	)

	print("PASS D: Corner output aligns with turned straight")

	# =============================================================================
	# TEST E — ROTATED ASSEMBLY REMAINS ALIGNED
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

	print("PASS E: L-shaped preview geometry survives rotation")

	# =============================================================================
	# TEST F — OCCUPIED SOURCE REJECTS ANOTHER CORNER
	# =============================================================================

	# Make the first connection permanent for this test.

	assert(belt_a.try_connect_to(corner))

	var second_corner: ConveyorSegment = (
		corner_scene.instantiate() as ConveyorSegment
	)

	assert(second_corner != null)

	test_root.add_child(second_corner)

	second_corner.position = Vector3(20.0, 0.0, 20.0)

	assert(
		second_corner.get_snap_preview_transform_after(
			belt_a
		).is_empty()
	)

	assert(
		second_corner.position == Vector3(20.0, 0.0, 20.0)
	)

	print("PASS F: Occupied output rejects corner preview")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	test_root.queue_free()

	print("==========================================")
	print("ALL 6 CORNER SNAP PREVIEW TESTS PASSED")
	print("==========================================")
