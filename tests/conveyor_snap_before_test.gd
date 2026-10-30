
extends Node


# =============================================================================
# CONVEYOR SNAP BEFORE TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: SNAP BEFORE TEST =====")

	var scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	var root := Node3D.new()
	add_child(root)

	var target: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	var new_belt: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	var feeder: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	assert(target != null)
	assert(new_belt != null)
	assert(feeder != null)

	root.add_child(target)
	root.add_child(new_belt)
	root.add_child(feeder)

	target.position = Vector3(3.0, 0.0, 2.0)
	new_belt.position = Vector3(10.0, 0.0, 10.0)

	# =============================================================================
	# TEST A — INVALID TARGET
	# =============================================================================

	assert(
		new_belt.get_snap_preview_transform_before(null).is_empty()
	)

	assert(
		new_belt.get_snap_preview_transform_before(
			new_belt
		).is_empty()
	)

	print("PASS A: Invalid targets rejected")

	# =============================================================================
	# TEST B — NO PREMATURE MOVEMENT OR CONNECTION
	# =============================================================================

	var old_position: Vector3 = new_belt.global_position

	var preview: Dictionary = (
		new_belt.get_snap_preview_transform_before(target)
	)

	assert(preview.has("transform"))
	assert(new_belt.global_position == old_position)

	assert(new_belt.next_segment == null)
	assert(target.previous_segment == null)

	print("PASS B: Preview leaves connections unchanged")

	# =============================================================================
	# TEST C — OUTPUT MEETS EXISTING INPUT
	# =============================================================================

	new_belt.global_transform = preview["transform"]

	var own_output: Marker3D = (
		new_belt.get_node("OutputEndpoint") as Marker3D
	)

	var target_input: Marker3D = (
		target.get_node("InputEndpoint") as Marker3D
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			own_output,
			target_input,
			0.05
		)
	)

	print("PASS C: Output aligns with existing input")

	# =============================================================================
	# TEST D — ROTATED CONVEYOR
	# =============================================================================

	target.rotation_degrees.y = 90.0

	preview = (
		new_belt.get_snap_preview_transform_before(target)
	)

	assert(preview.has("transform"))

	new_belt.global_transform = preview["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			own_output,
			target_input,
			0.05
		)
	)

	print("PASS D: Preview supports rotation")

	# =============================================================================
	# TEST E — OCCUPIED INPUT IS REJECTED
	# =============================================================================

	target.rotation_degrees.y = 0.0
	feeder.position = Vector3(3.0, 0.0, 3.0)

	assert(feeder.try_connect_to(target))

	assert(
		new_belt.get_snap_preview_transform_before(target).is_empty()
	)

	print("PASS E: Occupied input rejects preview")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 5 SNAP BEFORE TESTS PASSED")
	print("==========================================")
