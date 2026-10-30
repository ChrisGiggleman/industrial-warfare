
extends Node


# =============================================================================
# CONVEYOR TURN INTENT TEST
# =============================================================================

# Tests automatic straight/right/left recognition.
#
# Uses actual straight and corner conveyor scenes.
# No placement logic is modified.


func _ready() -> void:

	print("\n===== CHAT 07: CONVEYOR TURN INTENT TEST =====")

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
	# CREATE TEST CONVEYORS
	# =============================================================================

	var straight: ConveyorSegment = (
		straight_scene.instantiate() as ConveyorSegment
	)

	var corner: ConveyorSegment = (
		corner_scene.instantiate() as ConveyorSegment
	)

	assert(straight != null)
	assert(corner != null)

	add_child(straight)
	add_child(corner)

	var straight_output: Marker3D = (
		straight.get_node("OutputEndpoint") as Marker3D
	)

	var corner_output: Marker3D = (
		corner.get_node("OutputEndpoint") as Marker3D
	)

	assert(straight_output != null)
	assert(corner_output != null)

	# =============================================================================
	# TEST A — INVALID OUTPUT
	# =============================================================================

	assert(
		ConveyorTurnIntent.classify(
			null,
			Vector3.ZERO
		) == ConveyorTurnIntent.Turn.STRAIGHT
	)

	print("PASS A: Invalid endpoint handled safely")

	# =============================================================================
	# TEST B — STRAIGHT AHEAD
	# =============================================================================

	var output_position: Vector3 = (
		straight_output.global_position
	)

	assert(
		ConveyorTurnIntent.classify(
			straight_output,
			output_position + Vector3(0.0, 0.0, -1.0)
		) == ConveyorTurnIntent.Turn.STRAIGHT
	)

	print("PASS B: Forward position selects straight")

	# =============================================================================
	# TEST C — RIGHT TURN
	# =============================================================================

	assert(
		ConveyorTurnIntent.classify(
			straight_output,
			output_position + Vector3(1.0, 0.0, -1.0)
		) == ConveyorTurnIntent.Turn.RIGHT
	)

	print("PASS C: Right-side position selects right turn")

	# =============================================================================
	# TEST D — LEFT TURN
	# =============================================================================

	assert(
		ConveyorTurnIntent.classify(
			straight_output,
			output_position + Vector3(-1.0, 0.0, -1.0)
		) == ConveyorTurnIntent.Turn.LEFT
	)

	print("PASS D: Left-side position selects left turn")

	# =============================================================================
	# TEST E — SMALL SIDEWAYS MOVEMENT
	# =============================================================================

	assert(
		ConveyorTurnIntent.classify(
			straight_output,
			output_position + Vector3(0.2, 0.0, -1.0)
		) == ConveyorTurnIntent.Turn.STRAIGHT
	)

	print("PASS E: Small movement remains straight")

	# =============================================================================
	# TEST F — ROTATED STRAIGHT
	# =============================================================================

	straight.rotation_degrees.y = 90.0

	var rotated_basis: Basis = (
		straight_output.global_transform.basis
	)

	var rotated_right: Vector3 = (
		rotated_basis.x.normalized()
	)

	var rotated_forward: Vector3 = (
		-rotated_basis.z
	).normalized()

	var rotated_cursor: Vector3 = (
		straight_output.global_position
		+ rotated_right
		+ rotated_forward
	)

	assert(
		ConveyorTurnIntent.classify(
			straight_output,
			rotated_cursor
		) == ConveyorTurnIntent.Turn.RIGHT
	)

	print("PASS F: Rotated straight detects local right")

	# =============================================================================
	# TEST G — CORNER OUTPUT DIRECTION
	# =============================================================================

	# The corner output faces +X rather than -Z.
	# Direction detection must follow the marker,
	# not assume all belts face world -Z.

	var corner_basis: Basis = (
		corner_output.global_transform.basis
	)

	var corner_right: Vector3 = (
		corner_basis.x.normalized()
	)

	var corner_forward: Vector3 = (
		-corner_basis.z
	).normalized()

	var corner_cursor: Vector3 = (
		corner_output.global_position
		- corner_right
		+ corner_forward
	)

	assert(
		ConveyorTurnIntent.classify(
			corner_output,
			corner_cursor
		) == ConveyorTurnIntent.Turn.LEFT
	)

	print("PASS G: Corner output detects local left")

	# =============================================================================
	# TEST H — NO GAMEPLAY STATE CHANGES
	# =============================================================================

	assert(straight.next_segment == null)
	assert(straight.previous_segment == null)

	assert(corner.next_segment == null)
	assert(corner.previous_segment == null)

	assert(
		is_equal_approx(
			straight.rotation_degrees.y,
			90.0
		)
	)

	print("PASS H: Detection leaves conveyors unchanged")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	straight.queue_free()
	corner.queue_free()

	print("==========================================")
	print("ALL 8 CONVEYOR TURN INTENT TESTS PASSED")
	print("==========================================")
