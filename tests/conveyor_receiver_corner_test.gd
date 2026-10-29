
extends Node


# =============================================================================
# CHAT 08.3G — RECEIVER CORNER REGRESSION
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(belt != null)
	parent.add_child(belt)

	(
		belt.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	).set_process(false)

	return belt


func _ready() -> void:

	print("\n===== CHAT 08.3G: RECEIVER CORNER TEST =====")

	var root := Node3D.new()
	add_child(root)

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(ore != null)

	# =============================================================================
	# A — EXISTING DOWNSTREAM CONNECTION
	# =============================================================================

	var source := _make_belt(root)
	var receiver := _make_belt(root)
	var downstream := _make_belt(root)

	source.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3.ZERO
	)

	receiver.global_position = Vector3(1, 0, 0)
	downstream.global_position = Vector3(1, 0, -1)

	assert(receiver.try_connect_to(downstream))

	print("PASS A: Existing downstream line initialized")

	# =============================================================================
	# B — DISCOVERY DOES NOT MODIFY FACTORY
	# =============================================================================

	var original_transform := receiver.global_transform
	var original_output := (
		receiver.get_node("OutputEndpoint") as Marker3D
	).transform

	var candidate := (
		ConveyorReceiverCornerConnection.get_candidate(
			source,
			receiver
		)
	)

	assert(not candidate.is_empty())
	assert(
		candidate["turn"] == ConveyorTurnIntent.Turn.LEFT
	)

	assert(receiver.global_transform == original_transform)
	assert(receiver.next_segment == downstream)
	assert(source.next_segment == null)

	print("PASS B: Receiver corner discovered without mutation")

	# =============================================================================
	# C — CONVERT RECEIVER AND PRESERVE DOWNSTREAM
	# =============================================================================

	assert(
		ConveyorReceiverCornerConnection.try_connect(
			source,
			receiver
		)
	)

	assert(source.next_segment == receiver)
	assert(receiver.previous_segment == source)
	assert(receiver.next_segment == downstream)
	assert(downstream.previous_segment == receiver)

	assert(receiver.global_transform == original_transform)

	assert(
		(
			receiver.get_node("OutputEndpoint") as Marker3D
		).transform.is_equal_approx(original_output)
	)

	print("PASS C: Receiver converted, downstream preserved")

	# =============================================================================
	# D — ITEMS MOVE THROUGH CONVERTED RECEIVER
	# =============================================================================

	var source_inventory := (
		source.get_node("CargoInventory") as InventoryComponent
	)

	var receiver_inventory := (
		receiver.get_node("CargoInventory") as InventoryComponent
	)

	assert(source_inventory.add_item(ore, 1) == 1)

	assert(ConveyorTransportLink.try_transfer_forward(source))

	assert(source_inventory.get_amount(ore) == 0)
	assert(receiver_inventory.get_amount(ore) == 1)

	print("PASS D: Item transported through new corner")

	# =============================================================================
	# E — OPPOSITE INCOMING CORNER
	# =============================================================================

	var left_source := _make_belt(root)
	var left_receiver := _make_belt(root)

	left_source.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0),
		Vector3(10, 0, 0)
	)

	left_receiver.global_position = Vector3(9, 0, 0)

	assert(
		ConveyorReceiverCornerConnection.try_connect(
			left_source,
			left_receiver
		)
	)

	assert(left_source.next_segment == left_receiver)
	assert(left_receiver.previous_segment == left_source)

	print("PASS E: Opposite receiver corner connected")

	# =============================================================================
	# F — REJECT WRONG SPACING
	# =============================================================================

	var bad_source := _make_belt(root)
	var bad_receiver := _make_belt(root)

	bad_source.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3(20, 0, 0)
	)

	bad_receiver.global_position = Vector3(21.25, 0, 0)

	assert(
		not ConveyorReceiverCornerConnection.try_connect(
			bad_source,
			bad_receiver
		)
	)

	assert(bad_source.next_segment == null)
	assert(bad_receiver.previous_segment == null)

	print("PASS F: Incorrect spacing rejected")

	# =============================================================================
	# G — REJECT DUPLICATE CONNECTIONS
	# =============================================================================

	assert(
		not ConveyorReceiverCornerConnection.try_connect(
			source,
			receiver
		)
	)

	assert(receiver.next_segment == downstream)
	assert(receiver_inventory.get_amount(ore) == 1)

	print("PASS G: Occupied endpoints and cargo protected")

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	root.queue_free()

	print("==============================================")
	print("ALL 7 RECEIVER CORNER TESTS PASSED")
	print("==============================================")
