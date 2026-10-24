
extends Node


# =============================================================================
# CHAT 07 — CONVEYOR SNAP PREVIEW TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: SNAP PREVIEW TEST =====")

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

	belt_a.position = Vector3(3.0, 0.0, 2.0)
	belt_b.position = Vector3(10.0, 0.0, 10.0)

	# =============================================================================
	# TEST A — INVALID SOURCES REJECTED
	# =============================================================================

	assert(
		belt_b.get_snap_preview_transform_after(null).is_empty()
	)

	assert(
		belt_b.get_snap_preview_transform_after(belt_b).is_empty()
	)

	print("PASS A: Invalid preview sources rejected")

	# =============================================================================
	# TEST B — PREVIEW DOES NOT CHANGE GAME STATE
	# =============================================================================

	var original_transform: Transform3D = (
		belt_b.global_transform
	)

	var preview: Dictionary = (
		belt_b.get_snap_preview_transform_after(belt_a)
	)

	assert(preview.has("transform"))
	assert(belt_b.global_transform == original_transform)

	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null)

	print("PASS B: Preview does not move or connect belts")

	# =============================================================================
	# TEST C — CALCULATED TRANSFORM ALIGNS ENDPOINTS
	# =============================================================================

	belt_b.global_transform = preview["transform"]

	var output_a: Marker3D = (
		belt_a.get_node("OutputEndpoint") as Marker3D
	)

	var input_b: Marker3D = (
		belt_b.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b,
			0.05
		)
	)

	assert(belt_a.next_segment == null)

	print("PASS C: Preview transform aligns endpoints")

	# =============================================================================
	# TEST D — ROTATED PREVIEW
	# =============================================================================

	belt_a.rotation_degrees.y = 90.0
	belt_b.position = Vector3(12.0, 0.0, 12.0)

	preview = belt_b.get_snap_preview_transform_after(belt_a)

	assert(preview.has("transform"))

	belt_b.global_transform = preview["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_a,
			input_b,
			0.05
		)
	)

	print("PASS D: Preview handles rotated conveyors")

	# =============================================================================
	# TEST E — OCCUPIED OUTPUT REJECTS PREVIEW
	# =============================================================================

	assert(belt_b.snap_after(belt_a))

	assert(
		belt_c.get_snap_preview_transform_after(belt_a).is_empty()
	)

	print("PASS E: Occupied output blocks snapping preview")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 5 SNAP PREVIEW TESTS PASSED")
	print("==========================================")
