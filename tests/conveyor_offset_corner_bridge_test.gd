extends Node

# =============================================================================
# CHAT 08.3G-3G — OFFSET CORNER BRIDGE REGRESSION
# =============================================================================

func _belt(parent: Node3D) -> ConveyorSegment:
	var b := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(b != null)
	parent.add_child(b)
	(b.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return b


func _ready() -> void:
	print("\n===== CHAT 08.3G-3G: OFFSET CORNER TEST =====")
	var root := Node3D.new()
	add_child(root)
	var source := _belt(root)
	var destination := _belt(root)
	# Extractor half-grid: west-going belt output at (-2, 5).
	# A south-going receiver INPUT at (-3, 5.5) is geometrically valid.
	source.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0), Vector3(-1.5, 0, 5)
	)
	destination.global_transform = Transform3D(
		Basis(Vector3.UP, PI), Vector3(-3, 0, 6)
	)
	var candidate := ConveyorOffsetCornerBridge.inspect_pair(source, destination)
	assert(not candidate.is_empty())
	assert(is_equal_approx(float(candidate["input_length"]), 1.0))
	assert(is_equal_approx(float(candidate["output_length"]), 0.5))
	assert(
		(candidate["transform"] as Transform3D).origin
		.is_equal_approx(Vector3(-3, 0, 5))
	)
	print("PASS A: Perpendicular half-grid gap found with exact bend")

	var discovered := ConveyorOffsetCornerBridge.find_nearest_preview(
		get_tree(), Vector3(-3, 0, 5), 0.8
	)
	assert(discovered.get("source") == source)
	assert(discovered.get("destination") == destination)
	print("PASS B: Hover can discover the missing L connector")

	var custom_mesh := ConveyorOffsetCornerBridge.make_preview_mesh(candidate)
	assert(custom_mesh is ArrayMesh)
	assert(custom_mesh.get_surface_count() > 0)
	assert(source.next_segment == null)
	assert(destination.previous_segment == null)
	print("PASS C: Preview leaves existing conveyor links unchanged")

	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(ConveyorOffsetCornerBridge.is_clear(
		get_viewport().world_3d, candidate, 4
	))
	print("PASS D: Variable-leg collision clearance accepted")

	var blocker := StaticBody3D.new()
	blocker.collision_layer = 4
	blocker.collision_mask = 0
	root.add_child(blocker)
	blocker.global_position = Vector3(-3, 0, 5)
	var block_shape := CollisionShape3D.new()
	var block_box := BoxShape3D.new()
	block_box.size = Vector3(0.2, 0.2, 0.2)
	block_shape.shape = block_box
	block_shape.position.y = 0.3
	blocker.add_child(block_shape)
	await get_tree().physics_frame
	assert(not ConveyorOffsetCornerBridge.is_clear(
		get_viewport().world_3d, candidate, 4
	))
	assert(ConveyorOffsetCornerBridge.try_place(root, candidate) == null)
	print("PASS E: Unrelated collision prevents L construction")
	blocker.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame

	var old_source := source.global_transform
	var old_destination := destination.global_transform
	var bridge := ConveyorOffsetCornerBridge.try_place(root, candidate)
	assert(is_instance_valid(bridge))
	(bridge.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	assert(source.next_segment == bridge)
	assert(bridge.previous_segment == source)
	assert(bridge.next_segment == destination)
	assert(destination.previous_segment == bridge)
	print("PASS F: Real L belt connected to both existing lines")

	assert(bridge.get_node("CargoInventory") is InventoryComponent)
	assert(bridge.get_node("ConveyorTransportComponent") is ConveyorTransportComponent)
	assert(bridge.get_node("ConveyorBody").get_child_count() >= 2)
	assert(bridge.get_node("InteractionHitbox").get_child_count() >= 2)
	assert(bridge.has_meta("offset_corner"))
	print("PASS G: Transport, collision legs and selection hitboxes preserved")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var a := source.get_node("CargoInventory") as InventoryComponent
	var b := bridge.get_node("CargoInventory") as InventoryComponent
	var c := destination.get_node("CargoInventory") as InventoryComponent
	assert(a.add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(source))
	assert(b.get_amount(ore) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(bridge))
	assert(c.get_amount(ore) == 1)
	assert(a.get_amount(ore) == 0 and b.get_amount(ore) == 0)
	print("PASS H: Item passes through variable-length L without loss")

	assert(source.global_transform == old_source)
	assert(destination.global_transform == old_destination)
	assert(ConveyorOffsetCornerBridge.try_place(root, candidate) == null)
	print("PASS I: Originals unchanged, occupied or duplicate bridge rejected")

	var invalid_source := _belt(root)
	var invalid_target := _belt(root)
	invalid_source.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0), Vector3(9.5, 0, 5)
	)
	# Input above this receiver requires reversing its direction.
	invalid_target.global_transform = Transform3D(
		Basis(Vector3.UP, PI), Vector3(8, 0, 5)
	)
	assert(
		ConveyorOffsetCornerBridge.inspect_pair(
			invalid_source, invalid_target
		).is_empty()
	)
	print("PASS J: Reversed or impossible perpendicular approach rejected")

	root.queue_free()
	print("================================================")
	print("ALL 10 OFFSET CORNER TESTS PASSED")
	print("================================================")
