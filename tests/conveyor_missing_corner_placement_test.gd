
extends Node


# =============================================================================
# MISSING CORNER PLACEMENT TEST
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

	print("\n===== CHAT 08.3G-3D-2: CORNER PLACEMENT TEST =====")

	var root := Node3D.new()
	add_child(root)

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(ore != null)

	# =============================================================================
	# A — CREATE TWO INDEPENDENT LINES
	# =============================================================================

	var upstream := _make_belt(root)
	var source := _make_belt(root)
	var destination := _make_belt(root)
	var downstream := _make_belt(root)

	var right_basis := Basis(Vector3.UP, deg_to_rad(270.0))
	var down_basis := Basis(Vector3.UP, PI)

	upstream.global_transform = Transform3D(
		right_basis, Vector3(-6, 0, 2)
	)

	source.global_transform = Transform3D(
		right_basis, Vector3(-5, 0, 2)
	)

	destination.global_transform = Transform3D(
		down_basis, Vector3(-4, 0, 3)
	)

	downstream.global_transform = Transform3D(
		down_basis, Vector3(-4, 0, 4)
	)

	assert(upstream.try_connect_to(source))
	assert(destination.try_connect_to(downstream))

	print("PASS A: Independent conveyor lines initialized")

	# =============================================================================
	# B — FIND MISSING CORNER
	# =============================================================================

	var candidate := ConveyorMissingCornerPreview.preview_for_pair(
		source,
		destination,
		ConveyorTurnIntent.Turn.RIGHT
	)

	assert(not candidate.is_empty())

	assert(
		(candidate["transform"] as Transform3D)
		.origin.is_equal_approx(Vector3(-4, 0, 2))
	)

	print("PASS B: Missing corner discovered correctly")

	# =============================================================================
	# C — PERMANENT CORNER CONNECTS BOTH LINES
	# =============================================================================

	var source_original := source.global_transform
	var destination_original := destination.global_transform

	var corner := ConveyorMissingCornerPlacement.try_place(
		root,
		candidate
	)

	assert(is_instance_valid(corner))

	(
		corner.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	).set_process(false)

	assert(source.next_segment == corner)
	assert(corner.previous_segment == source)
	assert(corner.next_segment == destination)
	assert(destination.previous_segment == corner)

	print("PASS C: Corner placed and both ends connected")

	# =============================================================================
	# D — CORNER RETAINS TRANSPORT AND SELECTION COMPONENTS
	# =============================================================================

	assert(
		corner.get_node_or_null("CargoInventory")
		is InventoryComponent
	)

	assert(
		corner.get_node_or_null("ConveyorTransportComponent")
		is ConveyorTransportComponent
	)

	assert(
		corner.get_node_or_null("ConveyorTransportTimer")
		is ConveyorTransportTimer
	)

	assert(corner.selection_mesh != null)
	assert(corner.has_meta("conveyor_turn"))

	var corner_mesh := corner.get_node("BeltMesh") as MeshInstance3D
	assert(corner_mesh.mesh is ArrayMesh)

	print("PASS D: Inventory, transport and visuals preserved")

	# =============================================================================
	# E — ITEM TRAVELS THROUGH BOTH CORNER CONNECTIONS
	# =============================================================================

	var source_cargo := (
		source.get_node("CargoInventory") as InventoryComponent
	)

	var corner_cargo := (
		corner.get_node("CargoInventory") as InventoryComponent
	)

	var destination_cargo := (
		destination.get_node("CargoInventory") as InventoryComponent
	)

	assert(source_cargo.add_item(ore, 1) == 1)

	assert(ConveyorTransportLink.try_transfer_forward(source))
	assert(source_cargo.get_amount(ore) == 0)
	assert(corner_cargo.get_amount(ore) == 1)

	assert(ConveyorTransportLink.try_transfer_forward(corner))
	assert(corner_cargo.get_amount(ore) == 0)
	assert(destination_cargo.get_amount(ore) == 1)

	print("PASS E: Item travels across both connections")

	# =============================================================================
	# F — EXISTING NETWORK AND TRANSFORMS REMAIN UNCHANGED
	# =============================================================================

	assert(upstream.next_segment == source)
	assert(source.previous_segment == upstream)

	assert(destination.next_segment == downstream)
	assert(downstream.previous_segment == destination)

	assert(source.global_transform == source_original)
	assert(destination.global_transform == destination_original)

	assert(destination_cargo.get_amount(ore) == 1)

	print("PASS F: Existing connections and cargo preserved")

	# =============================================================================
	# G — DUPLICATE CORNER REJECTED
	# =============================================================================

	var duplicate := ConveyorMissingCornerPlacement.try_place(
		root,
		candidate
	)

	assert(duplicate == null)
	assert(source.next_segment == corner)
	assert(corner.next_segment == destination)

	print("PASS G: Duplicate corner rejected safely")

	# =============================================================================
	# H — STALE CORNER CANDIDATE REJECTED
	# =============================================================================

	var stale_source := _make_belt(root)
	var stale_destination := _make_belt(root)

	stale_source.global_transform = Transform3D(
		right_basis, Vector3(20, 0, 0)
	)

	stale_destination.global_transform = Transform3D(
		down_basis, Vector3(21, 0, 1)
	)

	var stale := ConveyorMissingCornerPreview.preview_for_pair(
		stale_source,
		stale_destination,
		ConveyorTurnIntent.Turn.RIGHT
	)

	assert(not stale.is_empty())

	stale_destination.global_position.x += 0.25

	assert(
		ConveyorMissingCornerPlacement.try_place(root, stale)
		== null
	)

	assert(stale_source.next_segment == null)
	assert(stale_destination.previous_segment == null)

	print("PASS H: Stale preview leaves network unchanged")

	# =============================================================================
	# I — LEFT TURN PLACEMENT
	# =============================================================================

	var left_source := _make_belt(root)
	var left_destination := _make_belt(root)

	left_source.global_transform = Transform3D(
		right_basis, Vector3(10, 0, 0)
	)

	left_destination.global_transform = Transform3D(
		Basis.IDENTITY, Vector3(11, 0, -1)
	)

	var left_preview := ConveyorMissingCornerPreview.preview_for_pair(
		left_source,
		left_destination,
		ConveyorTurnIntent.Turn.LEFT
	)

	assert(not left_preview.is_empty())

	var left_corner := ConveyorMissingCornerPlacement.try_place(
		root,
		left_preview
	)

	assert(is_instance_valid(left_corner))
	assert(left_source.next_segment == left_corner)
	assert(left_corner.next_segment == left_destination)

	print("PASS I: Left missing corner placed successfully")

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	root.queue_free()

	print("==============================================")
	print("ALL 9 MISSING CORNER PLACEMENT TESTS PASSED")
	print("==============================================")
