
extends Node


# =============================================================================
# MISSING CORNER PREVIEW TEST
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(belt != null)

	parent.add_child(belt)

	var timer := (
		belt.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	timer.set_process(false)

	return belt


func _ready() -> void:

	print("\n===== CHAT 08.3G-3D: MISSING CORNER TEST =====")

	var root := Node3D.new()
	add_child(root)

	# =============================================================================
	# A — DISCOVER RIGHT CORNER IN ONE EMPTY TILE
	# =============================================================================

	var source := _make_belt(root)
	var destination := _make_belt(root)

	source.global_transform = Transform3D(
		Basis(Vector3.UP, deg_to_rad(270.0)),
		Vector3(-5, 0, 2)
	)

	destination.global_transform = Transform3D(
		Basis(Vector3.UP, PI),
		Vector3(-4, 0, 3)
	)

	var preview := (
		ConveyorMissingCornerPreview.preview_for_pair(
			source,
			destination,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(not preview.is_empty())
	assert(preview["turn"] == ConveyorTurnIntent.Turn.RIGHT)

	var corner_transform: Transform3D = preview["transform"]

	assert(
		corner_transform.origin.is_equal_approx(
			Vector3(-4, 0, 2)
		)
	)

	print("PASS A: Right corner found in missing tile")

	# =============================================================================
	# B — DISCOVERY DOES NOT MODIFY EXISTING BELTS
	# =============================================================================

	var source_transform := source.global_transform
	var destination_transform := destination.global_transform

	preview = ConveyorMissingCornerPreview.preview_for_pair(
		source,
		destination,
		ConveyorTurnIntent.Turn.RIGHT
	)

	assert(source.global_transform == source_transform)
	assert(destination.global_transform == destination_transform)
	assert(source.next_segment == null)
	assert(destination.previous_segment == null)

	print("PASS B: Preview does not modify existing belts")

	# =============================================================================
	# C — DISCOVER LEFT CORNER
	# =============================================================================

	var left_source := _make_belt(root)
	var left_destination := _make_belt(root)

	left_source.global_transform = Transform3D(
		Basis(Vector3.UP, deg_to_rad(270.0)),
		Vector3(10, 0, 0)
	)

	left_destination.global_transform = Transform3D(
		Basis.IDENTITY,
		Vector3(11, 0, -1)
	)

	preview = ConveyorMissingCornerPreview.preview_for_pair(
		left_source,
		left_destination,
		ConveyorTurnIntent.Turn.LEFT
	)

	assert(not preview.is_empty())
	assert(preview["turn"] == ConveyorTurnIntent.Turn.LEFT)

	assert(
		(preview["transform"] as Transform3D).origin.is_equal_approx(
			Vector3(11, 0, 0)
		)
	)

	print("PASS C: Left corner discovered")

	# =============================================================================
	# D — REJECT INCORRECT SPACING
	# =============================================================================

	left_destination.global_position.x += 0.25

	assert(
		ConveyorMissingCornerPreview.preview_for_pair(
			left_source,
			left_destination,
			ConveyorTurnIntent.Turn.LEFT
		).is_empty()
	)

	print("PASS D: Incorrect spacing rejected")

	# =============================================================================
	# E — PROTECT OCCUPIED CONNECTIONS
	# =============================================================================

	source.next_segment = destination

	assert(
		ConveyorMissingCornerPreview.preview_for_pair(
			source,
			destination,
			ConveyorTurnIntent.Turn.RIGHT
		).is_empty()
	)

	source.next_segment = null
	destination.previous_segment = source

	assert(
		ConveyorMissingCornerPreview.preview_for_pair(
			source,
			destination,
			ConveyorTurnIntent.Turn.RIGHT
		).is_empty()
	)

	destination.previous_segment = null

	print("PASS E: Occupied endpoints rejected")

	# =============================================================================
	# F — MOUSE DISCOVERY USES ACTUAL CORNER TILE
	# =============================================================================

	preview = ConveyorMissingCornerPreview.find_nearest(
		get_tree(),
		Vector3(-4, 0, 2),
		0.75
	)

	assert(not preview.is_empty())
	assert(preview["source"] == source)
	assert(preview["destination"] == destination)

	print("PASS F: Mouse discovers missing corner")

	# =============================================================================
	# G — NO CONNECTION OUTSIDE SEARCH RADIUS
	# =============================================================================

	preview = ConveyorMissingCornerPreview.find_nearest(
		get_tree(),
		Vector3(-4, 0, -5),
		0.5
	)

	assert(preview.is_empty())

	print("PASS G: Distant corner not selected")

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	root.queue_free()

	print("==============================================")
	print("ALL 7 MISSING CORNER PREVIEW TESTS PASSED")
	print("==============================================")
