
extends Node


# =============================================================================
# BUILDING-CONNECTED CORNER SNAP TEST
# =============================================================================


# =============================================================================
# CREATE REAL CONVEYOR
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(belt != null)
	parent.add_child(belt)

	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	timer.set_process(false)

	return belt


# =============================================================================
# CREATE REAL SMELTER
# =============================================================================

func _make_smelter(
	parent: Node3D,
	position_value: Vector3
) -> Node3D:

	var scene := load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	var smelter := scene.instantiate() as Node3D

	assert(smelter != null)
	parent.add_child(smelter)

	smelter.position = position_value

	(
		smelter.get_node("ProducerComponent")
		as ProducerComponent
	).set_process(false)

	(
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	).set_process(false)

	return smelter


# =============================================================================
# CONNECT BUILDING OUTPUT TO FIRST BELT
# =============================================================================

func _connect_output(
	building: Node3D,
	belt: ConveyorSegment
) -> ItemPortComponent:

	var port := building.get_node(
		"OutputPort"
	) as ItemPortComponent

	var preview := ConveyorBuildingSnap.get_preview_transform(
		port, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(belt.try_connect_building_port(port))

	return port


# =============================================================================
# RUN TESTS
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.3F-2C-1: CORNER SNAP TEST =====")

	var root := Node3D.new()
	add_child(root)

	var smelter := _make_smelter(
		root, Vector3(10, 0, 0)
	)

	var source := _make_belt(root)
	var receiver := _make_belt(root)

	var port := _connect_output(smelter, source)

	# =============================================================================
	# TEST A — BUILDING CONNECTION EXISTS
	# =============================================================================

	assert(source.input_building_port == port)
	assert(port.connected_conveyor == source)
	assert(source.next_segment == null)

	print("PASS A: Building-connected source initialized")

	# =============================================================================
	# TEST B — PREVIEW RIGHT TURN
	# =============================================================================

	# Rotate the receiving belt to source-local right.

	receiver.global_transform = Transform3D(
		source.global_transform.basis
		* Basis(Vector3.UP, -PI / 2.0),
		Vector3.ZERO
	)

	var original_source: Transform3D = (
		source.global_transform
	)

	var preview := (
		ConveyorCornerPlacementSnap.get_preview_transform(
			source,
			receiver,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(preview.has("transform"))

	var proposed: Transform3D = preview["transform"]

	print("PASS B: Right corner preview calculated")

	# =============================================================================
	# TEST C — EXACT FRACTIONAL PLACEMENT
	# =============================================================================

	var local_position: Vector3 = (
		source.to_local(proposed.origin)
	)

	assert(
		local_position.is_equal_approx(
			Vector3(1.0, 0.0, 0.0)
		)
	)

	# Preview must not change existing objects.

	assert(
		source.global_transform.is_equal_approx(
			original_source
		)
	)

	assert(source.next_segment == null)

	print("PASS C: Corner aligns without integer grid rounding")

	# =============================================================================
	# TEST D — INCORRECT ROTATION REJECTED
	# =============================================================================

	receiver.global_transform = Transform3D(
		source.global_transform.basis
		* Basis(Vector3.UP, PI / 2.0),
		Vector3.ZERO
	)

	assert(
		ConveyorCornerPlacementSnap.get_preview_transform(
			source, receiver,
			ConveyorTurnIntent.Turn.RIGHT
		).is_empty()
	)

	print("PASS D: Incorrect direction rejected")

	# =============================================================================
	# TEST E — COMMIT RIGHT CORNER
	# =============================================================================

	receiver.global_transform = proposed

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			source,
			receiver,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(source.input_building_port == port)
	assert(port.connected_conveyor == source)

	assert(source.next_segment == receiver)
	assert(receiver.previous_segment == source)

	print("PASS E: Right corner preserves building connection")

	# =============================================================================
	# TEST F — OCCUPIED OUTPUT REJECTED
	# =============================================================================

	assert(
		ConveyorCornerPlacementSnap.get_preview_transform(
			source, receiver,
			ConveyorTurnIntent.Turn.LEFT
		).is_empty()
	)

	print("PASS F: Occupied output cannot create another turn")

	# =============================================================================
	# TEST G — LEFT CORNER WITH ANOTHER BUILDING
	# =============================================================================

	var other_smelter := _make_smelter(
		root, Vector3(20, 0, 0)
	)

	var left_source := _make_belt(root)
	var left_receiver := _make_belt(root)

	var left_port := _connect_output(
		other_smelter, left_source
	)

	left_receiver.global_transform = Transform3D(
		left_source.global_transform.basis
		* Basis(Vector3.UP, PI / 2.0),
		Vector3.ZERO
	)

	var left_preview := (
		ConveyorCornerPlacementSnap.get_preview_transform(
			left_source,
			left_receiver,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(left_preview.has("transform"))

	left_receiver.global_transform = (
		left_preview["transform"]
	)

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			left_source,
			left_receiver,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(left_source.input_building_port == left_port)
	assert(left_port.connected_conveyor == left_source)

	print("PASS G: Left corner preserves building connection")

	# =============================================================================
	# TEST H — BUILDING INPUT IS AN OCCUPIED OUTPUT
	# =============================================================================

	var input_smelter := _make_smelter(
		root, Vector3(30, 0, 0)
	)

	var end_belt := _make_belt(root)
	var unused_receiver := _make_belt(root)

	var input_port := input_smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var input_preview := (
		ConveyorBuildingSnap.get_preview_transform(
			input_port, end_belt
		)
	)

	assert(input_preview.has("transform"))

	end_belt.global_transform = input_preview["transform"]

	assert(end_belt.try_connect_building_port(input_port))

	assert(
		ConveyorCornerPlacementSnap.get_preview_transform(
			end_belt,
			unused_receiver,
			ConveyorTurnIntent.Turn.RIGHT
		).is_empty()
	)

	print("PASS H: Building input connection protects belt output")

	# =============================================================================
	# FINAL VALIDATION
	# =============================================================================

	assert(port.connected_conveyor == source)
	assert(left_port.connected_conveyor == left_source)
	assert(input_port.connected_conveyor == end_belt)

	root.queue_free()

	print("==========================================")
	print("ALL 8 BUILDING CORNER SNAP TESTS PASSED")
	print("==========================================")
