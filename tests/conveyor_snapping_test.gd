
extends Node


# =============================================================================
# AUTOMATIC STRAIGHT CONVEYOR SNAPPING TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: CONVEYOR SNAPPING TEST =====")

	var scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	var root := Node3D.new()
	add_child(root)

	var belt_a: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	var belt_b: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	var belt_c: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	assert(belt_a != null)
	assert(belt_b != null)
	assert(belt_c != null)

	root.add_child(belt_a)
	root.add_child(belt_b)
	root.add_child(belt_c)

	# =============================================================================
	# TEST A — SNAP TO EXISTING BELT
	# =============================================================================

	belt_a.position = Vector3(3.0, 0.0, 2.0)
	belt_b.position = Vector3(10.0, 0.0, 10.0)

	assert(belt_b.snap_after(belt_a))

	assert(
		belt_b.global_position.distance_to(
			Vector3(3.0, 0.0, 1.0)
		) < 0.001
	)

	print("PASS A: New belt snaps behind existing output")

	# =============================================================================
	# TEST B — CONNECTION ESTABLISHED
	# =============================================================================

	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)

	print("PASS B: Snapped belts are connected")

	# =============================================================================
	# TEST C — OCCUPIED CONNECTION REJECTED
	# =============================================================================

	belt_c.position = Vector3(20.0, 0.0, 20.0)

	var original_position: Vector3 = belt_c.global_position

	assert(not belt_c.snap_after(belt_a))

	assert(
		belt_c.global_position.distance_to(
			original_position
		) < 0.001
	)

	print("PASS C: Occupied output rejects another belt")

	# =============================================================================
	# TEST D — INVALID SELF CONNECTION
	# =============================================================================

	assert(not belt_a.snap_after(belt_a))
	assert(not belt_c.snap_after(null))

	print("PASS D: Invalid snapping requests rejected")

	# =============================================================================
	# TEST E — SNAPPING AFTER ROTATION
	# =============================================================================

	assert(belt_a.disconnect_next())

	# Rotate the source and verify world-space snapping
	# still aligns the connection markers.

	belt_a.rotation_degrees.y = 90.0

	belt_b.position = Vector3(12.0, 0.0, 12.0)

	assert(belt_b.snap_after(belt_a))

	var source_output: Marker3D = (
		belt_a.get_node("OutputEndpoint") as Marker3D
	)

	var target_input: Marker3D = (
		belt_b.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			source_output,
			target_input,
			0.05
		)
	)

	print("PASS E: Rotated conveyor snapping works")

	# =============================================================================
	# TEST CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 5 CONVEYOR SNAPPING TESTS PASSED")
	print("==========================================")
