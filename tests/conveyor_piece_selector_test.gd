
extends Node


# =============================================================================
# AUTOMATIC CONVEYOR SHAPE SELECTION TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: CONVEYOR SHAPE TEST =====")

	# =============================================================================
	# CREATE SOURCE CONVEYOR
	# =============================================================================

	var straight: ConveyorSegment = (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(straight != null)

	add_child(straight)

	var output: Marker3D = (
		straight.get_node("OutputEndpoint") as Marker3D
	)

	var center: Vector3 = output.global_position

	# =============================================================================
	# TEST A — ALL THREE SCENES EXIST
	# =============================================================================

	assert(ConveyorPieceSelector.STRAIGHT_SCENE != null)
	assert(ConveyorPieceSelector.RIGHT_CORNER_SCENE != null)
	assert(ConveyorPieceSelector.LEFT_CORNER_SCENE != null)

	print("PASS A: All conveyor scenes loaded")

	# =============================================================================
	# TEST B — STRAIGHT SELECTION
	# =============================================================================

	assert(
		ConveyorPieceSelector.get_scene_for_mouse(
			straight,
			center + Vector3(0, 0, -1)
		) == ConveyorPieceSelector.STRAIGHT_SCENE
	)

	print("PASS B: Forward cursor selects straight")

	# =============================================================================
	# TEST C — RIGHT SELECTION
	# =============================================================================

	assert(
		ConveyorPieceSelector.get_scene_for_mouse(
			straight,
			center + Vector3(1, 0, -1)
		) == ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)

	print("PASS C: Right cursor selects right corner")

	# =============================================================================
	# TEST D — LEFT SELECTION
	# =============================================================================

	assert(
		ConveyorPieceSelector.get_scene_for_mouse(
			straight,
			center + Vector3(-1, 0, -1)
		) == ConveyorPieceSelector.LEFT_CORNER_SCENE
	)

	print("PASS D: Left cursor selects left corner")

	# =============================================================================
	# TEST E — INVALID SOURCE
	# =============================================================================

	assert(
		ConveyorPieceSelector.get_scene_for_mouse(
			null,
			Vector3.ZERO
		) == null
	)

	print("PASS E: Invalid source safely rejected")

	# =============================================================================
	# TEST F — ROTATED SOURCE
	# =============================================================================

	straight.rotation_degrees.y = 90.0

	var rotated_basis: Basis = (
		output.global_transform.basis.orthonormalized()
	)

	var forward: Vector3 = (
		-rotated_basis.z
	).normalized()

	var right: Vector3 = (
		rotated_basis.x
	).normalized()

	var cursor: Vector3 = (
		output.global_position + forward + right
	)

	assert(
		ConveyorPieceSelector.get_scene_for_mouse(
			straight,
			cursor
		) == ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)

	print("PASS F: Selection follows source rotation")

	# =============================================================================
	# TEST G — INVALID TURN FALLBACK
	# =============================================================================

	assert(
		ConveyorPieceSelector.get_scene_for_turn(
			-1
		) == ConveyorPieceSelector.STRAIGHT_SCENE
	)

	print("PASS G: Unknown direction defaults to straight")

	# =============================================================================
	# TEST H — NO GAMEPLAY STATE CHANGES
	# =============================================================================

	assert(straight.previous_segment == null)
	assert(straight.next_segment == null)

	assert(
		is_equal_approx(
			straight.rotation_degrees.y,
			90.0
		)
	)

	print("PASS H: Shape selection does not alter connections")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	straight.queue_free()

	print("==========================================")
	print("ALL 8 CONVEYOR SHAPE TESTS PASSED")
	print("==========================================")
