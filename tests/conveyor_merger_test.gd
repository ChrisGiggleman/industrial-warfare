extends Node

# =============================================================================
# CHAT 08.3G-3K — 1x1 THREE-INPUT MERGER REGRESSION
# =============================================================================

func _belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _connect(belt: ConveyorSegment, port: ItemPortComponent) -> bool:
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	if snap.is_empty():
		return false
	belt.global_transform = snap["transform"]
	return belt.try_connect_building_port(port)


func _ready() -> void:
	print("\n===== CHAT 08.3G-3K: THREE-INPUT MERGER =====")
	var packed := load("res://scenes/buildings/conveyor_merger.tscn") as PackedScene
	var definition := load("res://data/buildings/conveyor_merger.tres") as BuildingDefinition
	assert(packed != null and definition != null)
	assert(definition.footprint_tiles == Vector2i.ONE)
	var root := Node3D.new()
	add_child(root)
	var merger := packed.instantiate() as Node3D
	assert(merger != null)
	root.add_child(merger)

	var pa := merger.get_node("InputPortA") as ItemPortComponent
	var pb := merger.get_node("InputPortB") as ItemPortComponent
	var pc := merger.get_node("InputPortC") as ItemPortComponent
	var po := merger.get_node("OutputPort") as ItemPortComponent
	var ia := merger.get_node("InputAInventory") as InventoryComponent
	var ib := merger.get_node("InputBInventory") as InventoryComponent
	var ic := merger.get_node("InputCInventory") as InventoryComponent
	var io := merger.get_node("OutputInventory") as InventoryComponent
	var m := merger.get_node("MergerComponent") as ConveyorMergerComponent
	m.set_process(false)

	assert(pa.direction == ItemPortComponent.PortDirection.INPUT)
	assert(pb.direction == ItemPortComponent.PortDirection.INPUT)
	assert(pc.direction == ItemPortComponent.PortDirection.INPUT)
	assert(po.direction == ItemPortComponent.PortDirection.OUTPUT)
	assert(pa.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	assert(pb.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	assert(pc.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	print("PASS A: 1x1 building has 3 universal inputs and 1 output")

	var ba := _belt(root)
	var bb := _belt(root)
	var bc := _belt(root)
	var bo := _belt(root)
	assert(_connect(ba, pa))
	assert(_connect(bb, pb))
	assert(_connect(bc, pc))
	assert(_connect(bo, po))
	assert(pa.connected_conveyor == ba)
	assert(pb.connected_conveyor == bb)
	assert(pc.connected_conveyor == bc)
	assert(po.connected_conveyor == bo)
	print("PASS B: All four physical conveyor ports connect separately")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	var ca := ba.get_node("CargoInventory") as InventoryComponent
	var cb := bb.get_node("CargoInventory") as InventoryComponent
	var cc := bc.get_node("CargoInventory") as InventoryComponent
	var co := bo.get_node("CargoInventory") as InventoryComponent

	assert(ca.add_item(ore, 1) == 1)
	assert(cb.add_item(ingot, 1) == 1)
	assert(cc.add_item(ore, 1) == 1)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(ba))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bb))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bc))
	assert(ia.get_amount(ore) == 1)
	assert(ib.get_amount(ingot) == 1)
	assert(ic.get_amount(ore) == 1)
	print("PASS C: Three belts unload into three independent queues")

	assert(m.advance_merge())
	assert(io.get_amount(ore) == 1)
	assert(not m.advance_merge())
	assert(ib.get_amount(ingot) == 1 and ic.get_amount(ore) == 1)
	print("PASS D: Full shared output safely blocks further transfers")

	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(co.get_amount(ore) == 1)
	assert(m.advance_merge())
	assert(io.get_amount(ingot) == 1)
	assert(co.remove_item(ore, 1))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(co.get_amount(ingot) == 1)
	assert(m.advance_merge())
	assert(io.get_amount(ore) == 1)
	assert(m.completed_from_a == 1)
	assert(m.completed_from_b == 1)
	assert(m.completed_from_c == 1)
	assert(m.next_lane == 0)
	print("PASS E: Physical output delivers A, B, C in round-robin order")

	assert(not bool(merger.call("can_demolish_safely")))
	assert(co.remove_item(ingot, 1))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(io.get_total_amount() == 0)
	assert(bool(merger.call("can_demolish_safely")))
	print("PASS F: Stored cargo prevents demolition until fully drained")

	assert(ia.add_item(ore, 3) == 3)
	assert(ib.add_item(ingot, 3) == 3)
	assert(ic.add_item(ore, 3) == 3)
	for cycle: int in range(9):
		var expected: ItemDefinition = ingot if cycle % 3 == 1 else ore
		assert(m.advance_merge())
		assert(io.get_amount(expected) == 1)
		assert(not m.advance_merge())
		assert(io.remove_item(expected, 1))
	assert(ia.get_total_amount() == 0)
	assert(ib.get_total_amount() == 0)
	assert(ic.get_total_amount() == 0)
	assert(m.completed_from_a == 4)
	assert(m.completed_from_b == 4)
	assert(m.completed_from_c == 4)
	print("PASS G: Continuous 3-lane traffic remains fair under backpressure")

	# Leave A empty: the scheduler must skip it and still serve B and C.
	assert(ib.add_item(ingot, 1) == 1)
	assert(ic.add_item(ore, 1) == 1)
	assert(m.advance_merge())
	assert(io.get_amount(ingot) == 1)
	assert(io.remove_item(ingot, 1))
	assert(m.advance_merge())
	assert(io.get_amount(ore) == 1)
	assert(io.remove_item(ore, 1))
	print("PASS H: Empty lanes do not stall other inputs")

	assert(ba.output_building_port == pa)
	assert(bb.output_building_port == pb)
	assert(bc.output_building_port == pc)
	assert(bo.input_building_port == po)
	print("PASS I: All three inputs and output retain distinct links")

	merger.free()
	assert(ba.output_building_port == null)
	assert(bb.output_building_port == null)
	assert(bc.output_building_port == null)
	assert(bo.input_building_port == null)
	print("PASS J: Removing an empty merger disconnects all four links")

	root.queue_free()
	print("================================================")
	print("ALL 10 THREE-INPUT MERGER TESTS PASSED")
	print("================================================")
