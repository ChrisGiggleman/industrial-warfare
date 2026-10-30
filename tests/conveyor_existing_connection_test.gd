
extends Node


# =============================================================================
# EXISTING CONNECTION REGRESSION
# =============================================================================

# Uses real conveyor scenes with automatic transport paused.
# No Build Mode integration or gameplay scene changes.


# =============================================================================
# CREATE TEST CONVEYOR
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


# =============================================================================
# RUN TESTS
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.3G-3B: CONNECTION TEST =====")

	var root := Node3D.new()
	add_child(root)

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(ore != null)

	# =============================================================================
	# A — CONNECT TWO EXISTING STRAIGHT BELTS
	# =============================================================================

	var direct_source := _make_belt(root)
	var direct_target := _make_belt(root)

	direct_source.global_position = Vector3(-20, 0, 0)
	direct_target.global_position = Vector3(-20, 0, -1)

	var source_transform := direct_source.global_transform
	var target_transform := direct_target.global_transform

	var source_cargo := (
		direct_source.get_node("CargoInventory")
		as InventoryComponent
	)

	var target_cargo := (
		direct_target.get_node("CargoInventory")
		as InventoryComponent
	)

	assert(source_cargo.add_item(ore, 1) == 1)

	assert(
		ConveyorExistingConnection.try_connect_pair(
			direct_source,
			direct_target
		)
	)

	assert(direct_source.next_segment == direct_target)
	assert(direct_target.previous_segment == direct_source)

	assert(direct_source.global_transform == source_transform)
	assert(direct_target.global_transform == target_transform)
	assert(source_cargo.get_amount(ore) == 1)

	print("PASS A: Existing straight conveyors connected")

	# =============================================================================
	# B — ITEMS CAN TRAVEL THROUGH THE NEW CONNECTION
	# =============================================================================

	assert(
		ConveyorTransportLink.try_transfer_forward(
			direct_source
		)
	)

	assert(source_cargo.get_amount(ore) == 0)
	assert(target_cargo.get_amount(ore) == 1)

	print("PASS B: Item transferred without resource loss")

	# =============================================================================
	# C — RIGHT CORNER PRESERVES UPSTREAM CONNECTION
	# =============================================================================

	var upstream := _make_belt(root)
	var right_source := _make_belt(root)
	var right_target := _make_belt(root)

	upstream.global_position = Vector3(0, 0, 1)
	right_source.global_position = Vector3.ZERO

	right_target.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3(1, 0, 0)
	)

	assert(upstream.try_connect_to(right_source))

	var right_cargo := (
		right_source.get_node("CargoInventory")
		as InventoryComponent
	)

	assert(right_cargo.add_item(ore, 1) == 1)

	var original_id := right_source.get_instance_id()
	var original_transform := right_source.global_transform

	assert(
		ConveyorExistingConnection.try_connect_pair(
			right_source,
			right_target
		)
	)

	assert(right_source.get_instance_id() == original_id)
	assert(right_source.global_transform == original_transform)
	assert(upstream.next_segment == right_source)
	assert(right_source.previous_segment == upstream)
	assert(right_source.next_segment == right_target)
	assert(right_target.previous_segment == right_source)

	assert(
		right_source.get_meta("conveyor_turn")
		== ConveyorTurnIntent.Turn.RIGHT
	)

	assert(right_cargo.get_amount(ore) == 1)

	print("PASS C: Right corner preserves upstream and cargo")

	# =============================================================================
	# D — LEFT CORNER CONNECTS EXISTING BELTS
	# =============================================================================

	var left_source := _make_belt(root)
	var left_target := _make_belt(root)

	left_source.global_position = Vector3(10, 0, 0)

	left_target.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0),
		Vector3(9, 0, 0)
	)

	assert(
		ConveyorExistingConnection.try_connect_pair(
			left_source,
			left_target
		)
	)

	assert(left_source.next_segment == left_target)
	assert(left_target.previous_segment == left_source)

	assert(
		left_source.get_meta("conveyor_turn")
		== ConveyorTurnIntent.Turn.LEFT
	)

	print("PASS D: Left corner connected successfully")

	# =============================================================================
	# E — EXISTING CONNECTIONS CANNOT BE OVERWRITTEN
	# =============================================================================

	assert(
		not ConveyorExistingConnection.try_connect_pair(
			right_source,
			right_target
		)
	)

	assert(right_source.next_segment == right_target)
	assert(right_target.previous_segment == right_source)
	assert(right_cargo.get_amount(ore) == 1)

	print("PASS E: Duplicate connection rejected safely")

	# =============================================================================
	# F — BUILDING PORT OCCUPANCY IS PROTECTED
	# =============================================================================

	var port_source := _make_belt(root)
	var port_target := _make_belt(root)

	port_source.global_position = Vector3(40, 0, 0)
	port_target.global_position = Vector3(40, 0, -1)

	var dummy_port := ItemPortComponent.new()

	port_source.output_building_port = dummy_port

	assert(
		not ConveyorExistingConnection.try_connect_pair(
			port_source,
			port_target
		)
	)

	port_source.output_building_port = null
	port_target.input_building_port = dummy_port

	assert(
		not ConveyorExistingConnection.try_connect_pair(
			port_source,
			port_target
		)
	)

	port_target.input_building_port = null
	dummy_port.free()

	print("PASS F: Occupied building ports protected")

	# =============================================================================
	# G — INVALID SPACING AND DIRECTION REJECTED
	# =============================================================================

	var bad_source := _make_belt(root)
	var bad_target := _make_belt(root)

	bad_source.global_position = Vector3(60, 0, 0)
	bad_target.global_position = Vector3(61, 0, 0)

	assert(
		not ConveyorExistingConnection.try_connect_pair(
			bad_source,
			bad_target
		)
	)

	bad_target.rotation_degrees.y = 270.0
	bad_target.global_position += Vector3(0.25, 0, 0)

	assert(
		not ConveyorExistingConnection.try_connect_pair(
			bad_source,
			bad_target
		)
	)

	assert(bad_source.next_segment == null)
	assert(bad_target.previous_segment == null)
	assert(not bad_source.has_meta("conveyor_turn"))

	print("PASS G: Invalid geometry leaves belts unchanged")

	# =============================================================================
	# H — OUTDATED DISCOVERY CANNOT COMMIT
	# =============================================================================

	var stale_source := _make_belt(root)
	var stale_target := _make_belt(root)

	stale_source.global_position = Vector3(80, 0, 0)
	stale_target.global_position = Vector3(80, 0, -1)

	var saved_candidate := (
		ConveyorExistingEndpointFinder.inspect_pair(
			stale_source,
			stale_target
		)
	)

	assert(not saved_candidate.is_empty())

	stale_target.global_position.x += 0.25

	assert(
		not ConveyorExistingConnection.try_connect_candidate(
			saved_candidate
		)
	)

	assert(stale_source.next_segment == null)
	assert(stale_target.previous_segment == null)

	stale_target.global_position.x -= 0.25

	assert(
		ConveyorExistingConnection.try_connect_candidate(
			saved_candidate
		)
	)

	print("PASS H: Stale connections revalidated safely")

	# =============================================================================
	# I — ROTATED CORNER CONNECTION
	# =============================================================================

	var rotated_source := _make_belt(root)
	var rotated_target := _make_belt(root)

	var rotated_basis := Basis(Vector3.UP, PI / 2.0)

	rotated_source.global_transform = Transform3D(
		rotated_basis,
		Vector3(100, 0, 0)
	)

	rotated_target.global_transform = Transform3D(
		rotated_basis * Basis(Vector3.UP, -PI / 2.0),
		rotated_source.global_transform * Vector3(1, 0, 0)
	)

	assert(
		ConveyorExistingConnection.try_connect_pair(
			rotated_source,
			rotated_target
		)
	)

	assert(rotated_source.next_segment == rotated_target)
	assert(rotated_target.previous_segment == rotated_source)

	print("PASS I: Rotated factory corner connected")

	# =============================================================================
	# J — NEAREST DISCOVERED CONNECTION COMMITS
	# =============================================================================

	var nearest_source := _make_belt(root)
	var nearest_target := _make_belt(root)

	nearest_source.global_position = Vector3(120, 0, 0)

	nearest_target.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3(121, 0, 0)
	)

	var nearest := (
		ConveyorExistingEndpointFinder.find_nearest_candidate(
			get_tree(),
			Vector3(120.5, 0, 0),
			0.75
		)
	)

	assert(nearest.get("source") == nearest_source)
	assert(nearest.get("receiver") == nearest_target)

	assert(
		ConveyorExistingConnection.try_connect_candidate(
			nearest
		)
	)

	assert(nearest_source.next_segment == nearest_target)
	assert(nearest_target.previous_segment == nearest_source)

	print("PASS J: Discovered connection committed successfully")

	# =============================================================================
	# K — RECEIVER CORNER THROUGH SHARED CONNECTION SYSTEM
	# =============================================================================

	# Create an existing horizontal source and a vertical
	# receiver that already feeds another conveyor.

	var receiver_source := _make_belt(root)
	var receiver_target := _make_belt(root)
	var receiver_downstream := _make_belt(root)

	receiver_source.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3(200, 0, 0)
	)

	receiver_target.global_position = Vector3(201, 0, 0)
	receiver_downstream.global_position = Vector3(201, 0, -1)

	assert(receiver_target.try_connect_to(receiver_downstream))

	var receiver_original_transform := (
		receiver_target.global_transform
	)

	var receiver_preview: Dictionary = (
		ConveyorExistingEndpointFinder.inspect_pair(
			receiver_source,
			receiver_target
		)
	)

	# Verify that our shared finder now discovers
	# the missing incoming-corner connection.

	assert(receiver_preview.get("mode") == "convert_receiver")

	assert(receiver_target.previous_segment == null)
	assert(receiver_target.next_segment == receiver_downstream)

	# Commit using the shared connection manager.

	assert(
		ConveyorExistingConnection.try_connect_candidate(
			receiver_preview
		)
	)

	assert(receiver_source.next_segment == receiver_target)
	assert(receiver_target.previous_segment == receiver_source)
	assert(receiver_target.next_segment == receiver_downstream)
	assert(receiver_downstream.previous_segment == receiver_target)

	assert(
		receiver_target.global_transform.is_equal_approx(
			receiver_original_transform
		)
	)

	print("PASS K: Receiver corner integrated and downstream preserved")

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	assert(right_cargo.get_amount(ore) == 1)
	assert(target_cargo.get_amount(ore) == 1)

	root.queue_free()

	print("==============================================")
	print("ALL 11 EXISTING CONNECTION TESTS PASSED")
	print("==============================================")
