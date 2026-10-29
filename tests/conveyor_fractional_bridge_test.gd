extends Node

# =============================================================================
# CHAT 08.3G-3F — FRACTIONAL GAP BRIDGE REGRESSION
# =============================================================================

func _belt(parent: Node3D) -> ConveyorSegment:
	var b := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(b != null)
	parent.add_child(b)
	(b.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return b


func _ready() -> void:
	print("\n===== CHAT 08.3G-3F: FRACTIONAL BRIDGE TEST =====")
	var root := Node3D.new()
	add_child(root)

	var source := _belt(root)
	var destination := _belt(root)
	source.global_position = Vector3(0, 0, 0)
	destination.global_position = Vector3(0, 0, -1.65)

	# The two outer endpoints may remain attached to buildings.
	var port_in := ItemPortComponent.new()
	var port_out := ItemPortComponent.new()
	root.add_child(port_in)
	root.add_child(port_out)
	source.input_building_port = port_in
	destination.output_building_port = port_out

	var candidate := ConveyorFractionalBridge.inspect_pair(
		source, destination
	)
	assert(not candidate.is_empty())
	assert(is_equal_approx(float(candidate["length"]), 0.65))
	assert(
		(candidate["transform"] as Transform3D).origin.is_equal_approx(
			Vector3(0, 0, -0.825)
		)
	)
	print("PASS A: 0.65-unit building-connected gap discovered")

	assert(source.next_segment == null)
	assert(destination.previous_segment == null)
	assert(source.input_building_port == port_in)
	assert(destination.output_building_port == port_out)
	print("PASS B: Preview does not modify existing endpoints")

	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(ConveyorFractionalBridge.is_clear(
		get_viewport().world_3d, candidate, 4
	))
	print("PASS C: Exact partial-length clearance validated")

	var blocker := StaticBody3D.new()
	blocker.collision_layer = 4
	blocker.collision_mask = 0
	root.add_child(blocker)
	blocker.global_position = Vector3(0, 0, -0.825)
	var collision := CollisionShape3D.new()
	var collision_box := BoxShape3D.new()
	collision_box.size = Vector3(0.2, 0.2, 0.2)
	collision.shape = collision_box
	collision.position.y = 0.3
	blocker.add_child(collision)
	await get_tree().physics_frame
	assert(not ConveyorFractionalBridge.is_clear(
		get_viewport().world_3d, candidate, 4
	))
	assert(ConveyorFractionalBridge.try_place(root, candidate) == null)
	print("PASS D: Unrelated physical obstruction blocks bridge")
	blocker.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame

	var original_source := source.global_transform
	var original_destination := destination.global_transform
	var bridge := ConveyorFractionalBridge.try_place(root, candidate)
	assert(is_instance_valid(bridge))
	(bridge.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	assert(source.next_segment == bridge)
	assert(bridge.previous_segment == source)
	assert(bridge.next_segment == destination)
	assert(destination.previous_segment == bridge)
	print("PASS E: One real short belt connects both endpoints")

	assert(bridge.get_node_or_null("CargoInventory") is InventoryComponent)
	assert(bridge.get_node_or_null("ConveyorTransportComponent") is ConveyorTransportComponent)
	assert(bridge.get_node_or_null("InteractionHitbox/InteractionHitbox") is CollisionShape3D)
	var mesh := bridge.get_node("BeltMesh") as MeshInstance3D
	var shape := bridge.get_node("ConveyorBody/ConveyorBody") as CollisionShape3D
	assert(mesh.mesh is BoxMesh)
	assert(is_equal_approx((mesh.mesh as BoxMesh).size.z, 0.65))
	assert(is_equal_approx((shape.shape as BoxShape3D).size.z, 0.55))
	print("PASS F: Cargo, selection and sized geometry preserved")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(ore != null)
	var a := source.get_node("CargoInventory") as InventoryComponent
	var b := bridge.get_node("CargoInventory") as InventoryComponent
	var c := destination.get_node("CargoInventory") as InventoryComponent
	assert(a.add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(source))
	assert(b.get_amount(ore) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(bridge))
	assert(c.get_amount(ore) == 1)
	assert(a.get_amount(ore) == 0 and b.get_amount(ore) == 0)
	print("PASS G: Ore travels through short bridge without loss")

	assert(source.global_transform == original_source)
	assert(destination.global_transform == original_destination)
	assert(source.input_building_port == port_in)
	assert(destination.output_building_port == port_out)
	print("PASS H: Both building connections and transforms preserved")

	assert(ConveyorFractionalBridge.try_place(root, candidate) == null)
	print("PASS I: Duplicate and occupied bridges rejected")

	var offset_source := _belt(root)
	var offset_dest := _belt(root)
	offset_source.global_position = Vector3(10, 0, 0)
	offset_dest.global_position = Vector3(10.3, 0, -1.65)
	assert(ConveyorFractionalBridge.inspect_pair(
		offset_source, offset_dest
	).is_empty())
	offset_dest.global_position = Vector3(10, 0, -1.65)
	offset_dest.rotation_degrees.y = 90
	assert(ConveyorFractionalBridge.inspect_pair(
		offset_source, offset_dest
	).is_empty())
	print("PASS J: Lateral misalignment and wrong facing rejected")

	root.queue_free()
	print("==============================================")
	print("ALL 10 FRACTIONAL BRIDGE TESTS PASSED")
	print("==============================================")
