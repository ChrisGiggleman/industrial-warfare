extends Node

# =============================================================================
# CONTROLLED DESTRUCTION — BUILDING AND BELT REGRESSION
# =============================================================================

# Runs the actual DestructionTransaction against isolated real scenes.
# No combat hooks or Build Mode demolition behavior change in this step.


func _belt(parent: Node3D) -> ConveyorSegment:
	var segment := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(segment != null)
	parent.add_child(segment)

	var timer := segment.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	return segment


func _ready() -> void:
	print("\n===== CONTROLLED DESTRUCTION TRANSACTION =====")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var press_scene := load(
		"res://scenes/buildings/prototype_ammunition_press.tscn"
	) as PackedScene
	assert(
		ore != null and ingot != null and ammo != null
		and storage_scene != null and press_scene != null
	)

	var world := Node3D.new()
	add_child(world)
	var recovery := InventoryComponent.new()
	recovery.name = "TestRecoveredSalvage"
	recovery.max_capacity = 0
	world.add_child(recovery)

	var arbitrary := Node3D.new()
	world.add_child(arbitrary)
	assert(not DestructionTransaction.can_destroy(arbitrary, recovery))
	assert(not DestructionTransaction.try_destroy(arbitrary, recovery))
	assert(not DestructionTransaction.try_destroy(null, recovery))
	var ghost := storage_scene.instantiate() as Node3D
	ghost.add_to_group("construction_preview")
	world.add_child(ghost)
	assert(not DestructionTransaction.can_destroy(ghost, recovery))
	assert(not ghost.is_queued_for_deletion())
	assert(recovery.get_total_amount() == 0)
	print("PASS A: Invalid nodes and construction ghosts cannot be destroyed")

	var storage := storage_scene.instantiate() as Node3D
	assert(storage != null)
	world.add_child(storage)
	var inventory := storage.get_node(
		"InventoryComponent"
	) as InventoryComponent
	assert(inventory.add_item(ore, 7) == 7)
	assert(inventory.add_item(ammo, 4) == 4)
	var limited := InventoryComponent.new()
	limited.max_capacity = 10
	world.add_child(limited)
	assert(not DestructionTransaction.can_destroy(storage, limited))
	assert(not DestructionTransaction.try_destroy(storage, limited))
	assert(not storage.is_queued_for_deletion())
	assert(inventory.get_total_amount() == 11)
	assert(limited.get_total_amount() == 0)
	print("PASS B: Insufficient recovery capacity prevents source removal")

	var first := _belt(world)
	var second := _belt(world)
	var port := storage.get_node("OutputPort") as ItemPortComponent
	var snap := ConveyorBuildingSnap.get_preview_transform(port, first)
	assert(snap.has("transform"))
	first.global_transform = snap["transform"]
	assert(first.try_connect_building_port(port))
	var next_snap := second.get_snap_preview_transform_after(first)
	assert(next_snap.has("transform"))
	second.global_transform = next_snap["transform"]
	assert(first.try_connect_to(second))
	var first_cargo := first.get_node("CargoInventory") as InventoryComponent
	var second_cargo := second.get_node("CargoInventory") as InventoryComponent
	assert(first_cargo.add_item(ingot, 1) == 1)
	assert(second_cargo.add_item(ammo, 1) == 1)
	assert(port.connected_conveyor == first)
	assert(first.next_segment == second)
	assert(second.previous_segment == first)
	print("PASS C: Real Storage port and adjacent occupied conveyors are linked")

	assert(DestructionTransaction.can_destroy(storage, recovery))
	assert(DestructionTransaction.try_destroy(storage, recovery))
	assert(storage.is_queued_for_deletion())
	assert(inventory.get_total_amount() == 0)
	assert(recovery.get_amount(ore) == 7)
	assert(recovery.get_amount(ammo) == 4)
	assert(not is_instance_valid(first.input_building_port))
	assert(not is_instance_valid(port.connected_conveyor))
	assert(first.next_segment == second)
	assert(second.previous_segment == first)
	print("PASS D: Destruction recovers Storage and immediately unlinks its port")

	assert(not DestructionTransaction.try_destroy(storage, recovery))
	assert(recovery.get_total_amount() == 11)
	await get_tree().process_frame
	assert(not is_instance_valid(storage))
	assert(first.is_inside_tree() and second.is_inside_tree())
	assert(first.next_segment == second)
	assert(second.previous_segment == first)
	assert(first_cargo.get_amount(ingot) == 1)
	assert(second_cargo.get_amount(ammo) == 1)
	print("PASS E: Repeat removal is refused; surviving conveyors keep their cargo")

	assert(DestructionTransaction.can_destroy(first, recovery))
	assert(DestructionTransaction.try_destroy(first, recovery))
	assert(first.is_queued_for_deletion())
	assert(first_cargo.get_total_amount() == 0)
	assert(second.previous_segment == null)
	assert(second_cargo.get_amount(ammo) == 1)
	assert(recovery.get_amount(ingot) == 1)
	print("PASS F: Destroying one occupied belt immediately severs only its links")

	await get_tree().process_frame
	assert(not is_instance_valid(first))
	assert(second.is_inside_tree())
	assert(second_cargo.get_amount(ammo) == 1)
	assert(DestructionTransaction.try_destroy(second, recovery))
	assert(recovery.get_amount(ammo) == 5)
	await get_tree().process_frame
	assert(not is_instance_valid(second))
	assert(recovery.get_total_amount() == 13)
	print("PASS G: Second belt recovers independently; no cargo disappears")

	var press := press_scene.instantiate() as Node3D
	assert(press != null)
	world.add_child(press)
	var input := press.get_node("InputInventory") as InventoryComponent
	var finished := press.get_node("OutputInventory") as InventoryComponent
	var producer := press.get_node("ProducerComponent") as ProducerComponent
	assert(producer != null)
	producer.set_process(false)
	assert(input.add_item(ingot, 2) == 2)
	assert(finished.add_item(ammo, 4) == 4)
	assert(DestructionCargoRecovery.collect_inventories(press).size() == 2)
	print("PASS H: Multi-inventory ammunition factory is eligible for recovery")

	input.items["invalid_key"] = 1
	assert(not DestructionTransaction.can_destroy(press, recovery))
	assert(not DestructionTransaction.try_destroy(press, recovery))
	assert(not press.is_queued_for_deletion())
	assert(input.get_amount(ingot) == 2)
	assert(finished.get_amount(ammo) == 4)
	assert(recovery.get_amount(ingot) == 1)
	input.items.erase("invalid_key")
	print("PASS I: Invalid inventory contents prevent removal without partial transfer")

	assert(DestructionTransaction.try_destroy(press, recovery))
	assert(input.get_total_amount() == 0)
	assert(finished.get_total_amount() == 0)
	assert(recovery.get_amount(ingot) == 3)
	assert(recovery.get_amount(ammo) == 9)
	await get_tree().process_frame
	assert(not is_instance_valid(press))
	assert(recovery.get_total_amount() == 19)
	print("PASS J: Manufacturer removal recovers both input and output buffers")

	var empty_storage := storage_scene.instantiate() as Node3D
	assert(empty_storage != null)
	world.add_child(empty_storage)
	assert(DestructionTransaction.can_destroy(empty_storage, recovery))
	assert(DestructionTransaction.try_destroy(empty_storage, recovery))
	assert(not DestructionTransaction.try_destroy(empty_storage, recovery))
	assert(recovery.get_total_amount() == 19)
	await get_tree().process_frame
	assert(not is_instance_valid(empty_storage))
	print("PASS K: Empty structures are safely removed without duplicating salvage")

	assert(ghost.is_inside_tree())
	assert(arbitrary.is_inside_tree())
	assert(recovery.get_amount(ore) == 7)
	assert(recovery.get_amount(ingot) == 3)
	assert(recovery.get_amount(ammo) == 9)
	assert(recovery.get_total_amount() == 19)
	print("PASS L: All 19 source items remain in salvage; unrelated nodes survive")

	world.queue_free()
	print("================================================")
	print("ALL 12 CONTROLLED DESTRUCTION TRANSACTION TESTS PASSED")
	print("================================================")
