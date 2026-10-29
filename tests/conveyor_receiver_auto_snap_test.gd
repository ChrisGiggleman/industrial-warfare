extends Node


# =============================================================================
# CHAT 08.3G-3E — AUTOMATIC RECEIVER CORNER BUILD MODE TEST
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:
	var belt: ConveyorSegment = (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	)
	assert(belt != null)
	parent.add_child(belt)
	var timer: ConveyorTransportTimer = (
		belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	)
	timer.set_process(false)
	return belt


func _ready() -> void:
	print("\n===== CHAT 08.3G-3E: RECEIVER AUTO SNAP =====")

	var root := Node3D.new()
	add_child(root)

	var source := _make_belt(root)
	var receiver := _make_belt(root)
	var downstream := _make_belt(root)

	source.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3(0, 0, 0)
	)
	receiver.global_position = Vector3(1, 0, 0)
	downstream.global_position = Vector3(1, 0, -1)
	assert(receiver.try_connect_to(downstream))
	print("PASS A: Independent incoming line and downstream line initialized")

	# Mouse must hover over the occupied receiver tile, not an empty gap.
	var candidate: Dictionary = (
		ConveyorReceiverCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3(1, 0, 0), 0.75
		)
	)
	assert(candidate.get("mode") == "convert_receiver")
	assert(candidate["source"] == source)
	assert(candidate["receiver"] == receiver)
	assert(candidate["turn"] == ConveyorTurnIntent.Turn.LEFT)
	print("PASS B: Free receiver input automatically discovered")

	assert(
		ConveyorReceiverCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3(0, 0, 0), 0.75
		).is_empty()
	)
	print("PASS C: No automatic conversion on the source tile")

	var original_transform: Transform3D = receiver.global_transform
	var original_output: Transform3D = (
		receiver.get_node("OutputEndpoint") as Marker3D
	).transform

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.2, 1.0, 0.2, 0.5)
	var overlay: MeshInstance3D = (
		ConveyorReceiverCornerBuildPreview.make_overlay(candidate, material)
	)
	assert(overlay != null)
	assert(overlay.mesh is ArrayMesh)
	assert(overlay.material_override == material)
	assert(receiver.global_transform == original_transform)
	assert(receiver.previous_segment == null)
	assert(receiver.next_segment == downstream)
	overlay.free()
	print("PASS D: Preview geometry does not modify real conveyors")

	# Wait for collision bodies to register before shape queries.
	await get_tree().physics_frame
	await get_tree().physics_frame

	assert(
		ConveyorReceiverCornerBuildPreview.is_clear(
			get_viewport().world_3d, candidate, 4
		)
	)
	print("PASS E: Valid existing receiver corner passes collision check")

	var blocker := StaticBody3D.new()
	blocker.collision_layer = 4
	blocker.collision_mask = 0
	root.add_child(blocker)
	blocker.global_position = receiver.global_position
	var blocker_collision := CollisionShape3D.new()
	var blocker_shape := BoxShape3D.new()
	blocker_shape.size = Vector3(0.3, 0.2, 0.3)
	blocker_collision.shape = blocker_shape
	blocker_collision.position.y = 0.3
	blocker.add_child(blocker_collision)
	await get_tree().physics_frame

	assert(
		not ConveyorReceiverCornerBuildPreview.is_clear(
			get_viewport().world_3d, candidate, 4
		)
	)
	assert(source.next_segment == null)
	assert(receiver.previous_segment == null)
	print("PASS F: Unrelated collision blocker prevents conversion")

	blocker.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(ore != null)
	var source_cargo := source.get_node("CargoInventory") as InventoryComponent
	var receiver_cargo := receiver.get_node("CargoInventory") as InventoryComponent
	assert(source_cargo.add_item(ore, 1) == 1)

	assert(
		ConveyorExistingConnection.try_connect_candidate(candidate)
	)
	assert(source.next_segment == receiver)
	assert(receiver.previous_segment == source)
	assert(receiver.next_segment == downstream)
	assert(downstream.previous_segment == receiver)
	assert(receiver.global_transform == original_transform)
	var current_output: Transform3D = (
		(receiver.get_node("OutputEndpoint") as Marker3D).transform
	)
	assert(current_output.is_equal_approx(original_output))
	assert(source_cargo.get_amount(ore) == 1)
	print("PASS G: One-click commit preserves downstream, position and cargo")

	assert(ConveyorTransportLink.try_transfer_forward(source))
	assert(source_cargo.get_amount(ore) == 0)
	assert(receiver_cargo.get_amount(ore) == 1)
	print("PASS H: Resource passes through converted receiver")

	assert(
		ConveyorReceiverCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3(1, 0, 0), 0.75
		).is_empty()
	)
	assert(
		not ConveyorExistingConnection.try_connect_candidate(candidate)
	)
	print("PASS I: Duplicate and stale connection prevented")

	var opposite_source := _make_belt(root)
	var opposite_receiver := _make_belt(root)
	opposite_source.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0),
		Vector3(20, 0, 0)
	)
	opposite_receiver.global_position = Vector3(19, 0, 0)
	var opposite: Dictionary = (
		ConveyorReceiverCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3(19, 0, 0), 0.75
		)
	)
	assert(opposite.get("mode") == "convert_receiver")
	assert(opposite["turn"] == ConveyorTurnIntent.Turn.RIGHT)
	print("PASS J: Opposite corner direction discovered")

	# The occupied input is protected before any permanent mutation.
	opposite_receiver.previous_segment = opposite_source
	assert(
		ConveyorReceiverCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3(19, 0, 0), 0.75
		).is_empty()
	)
	opposite_receiver.previous_segment = null
	print("PASS K: Occupied receiver input rejected")

	root.queue_free()

	print("================================================")
	print("ALL 11 RECEIVER AUTO SNAP TESTS PASSED")
	print("================================================")
