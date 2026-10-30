extends Node

# =============================================================================
# 1x1 THREE-OUTPUT SPLITTER REGRESSION
# =============================================================================

func _belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _connect(belt: ConveyorSegment, port: ItemPortComponent) -> bool:
	var preview: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	if preview.is_empty():
		return false
	belt.global_transform = preview["transform"]
	return belt.try_connect_building_port(port)


func _ready() -> void:
	print("\n===== CHAT 08.3G-3K: THREE-OUTPUT SPLITTER =====")
	var packed := load("res://scenes/buildings/conveyor_splitter.tscn") as PackedScene
	var definition := load("res://data/buildings/conveyor_splitter.tres") as BuildingDefinition
	assert(packed != null and definition != null)
	assert(definition.footprint_tiles == Vector2i.ONE)
	var root := Node3D.new()
	add_child(root)
	var splitter := packed.instantiate() as Node3D
	assert(splitter != null)
	root.add_child(splitter)

	var pi := splitter.get_node("InputPort") as ItemPortComponent
	var pa := splitter.get_node("OutputPortA") as ItemPortComponent
	var pb := splitter.get_node("OutputPortB") as ItemPortComponent
	var pc := splitter.get_node("OutputPortC") as ItemPortComponent
	var input_inv := splitter.get_node("InputInventory") as InventoryComponent
	var ia := splitter.get_node("OutputAInventory") as InventoryComponent
	var ib := splitter.get_node("OutputBInventory") as InventoryComponent
	var ic := splitter.get_node("OutputCInventory") as InventoryComponent
	var component := splitter.get_node("SplitterComponent") as ConveyorSplitterComponent
	component.set_process(false)

	assert(pi.direction == ItemPortComponent.PortDirection.INPUT)
	assert(pi.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	assert(pa.direction == ItemPortComponent.PortDirection.OUTPUT)
	assert(pb.direction == ItemPortComponent.PortDirection.OUTPUT)
	assert(pc.direction == ItemPortComponent.PortDirection.OUTPUT)
	print("PASS A: 1x1 splitter has 1 universal input and 3 outputs")

	var bi := _belt(root)
	var ba := _belt(root)
	var bb := _belt(root)
	var bc := _belt(root)
	assert(_connect(bi, pi))
	assert(_connect(ba, pa))
	assert(_connect(bb, pb))
	assert(_connect(bc, pc))
	assert(pi.connected_conveyor == bi)
	assert(pa.connected_conveyor == ba)
	assert(pb.connected_conveyor == bb)
	assert(pc.connected_conveyor == bc)
	print("PASS B: All four physical side ports connect")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	var cargo_in := bi.get_node("CargoInventory") as InventoryComponent
	var cargo_a := ba.get_node("CargoInventory") as InventoryComponent
	var cargo_b := bb.get_node("CargoInventory") as InventoryComponent
	var cargo_c := bc.get_node("CargoInventory") as InventoryComponent

	assert(cargo_in.add_item(ore, 1) == 1)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	assert(input_inv.get_amount(ore) == 1)
	assert(input_inv.add_item(ore, 2) == 2)
	print("PASS C: Incoming conveyor unloads to the splitter input queue")

	assert(component.advance_split())
	assert(ia.get_amount(ore) == 1)
	assert(component.advance_split())
	assert(ib.get_amount(ore) == 1)
	assert(component.advance_split())
	assert(ic.get_amount(ore) == 1)
	assert(component.completed_to_a == 1)
	assert(component.completed_to_b == 1)
	assert(component.completed_to_c == 1)
	assert(component.next_lane == 0)
	print("PASS D: Round-robin distributes one unit to each output")

	assert(input_inv.add_item(ingot, 1) == 1)
	assert(not component.advance_split())
	assert(input_inv.get_amount(ingot) == 1)
	print("PASS E: All full outputs retain incoming cargo safely")

	assert(ConveyorBuildingTransfer.try_load_into_belt(ba))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bb))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bc))
	assert(cargo_a.get_amount(ore) == 1)
	assert(cargo_b.get_amount(ore) == 1)
	assert(cargo_c.get_amount(ore) == 1)
	assert(ia.get_total_amount() == 0)
	assert(ib.get_total_amount() == 0)
	assert(ic.get_total_amount() == 0)
	print("PASS F: All three output buffers load into real conveyors")

	assert(component.advance_split())
	assert(ia.get_amount(ingot) == 1)
	assert(component.completed_to_a == 2)
	print("PASS G: A new cargo type routes after a previously blocked output")

	bb.disconnect_building_port(pb)
	assert(pb.connected_conveyor == null)
	assert(input_inv.add_item(ore, 3) == 3)
	assert(component.advance_split())
	assert(ic.get_amount(ore) == 1)
	assert(ib.get_total_amount() == 0)
	assert(not component.advance_split())
	assert(input_inv.get_amount(ore) == 2)
	print("PASS H: Disconnected output B is skipped; full outputs apply backpressure")

	var total_items: int = (
		input_inv.get_total_amount()
		+ ia.get_total_amount() + ib.get_total_amount() + ic.get_total_amount()
		+ cargo_in.get_total_amount()
		+ cargo_a.get_total_amount() + cargo_b.get_total_amount()
		+ cargo_c.get_total_amount()
	)
	assert(total_items == 7)
	assert(not bool(splitter.call("can_demolish_safely")))
	print("PASS I: Conservation and safe demolition hold under mixed congestion")

	assert(input_inv.remove_item(ore, 2))
	assert(ia.remove_item(ingot, 1))
	assert(ic.remove_item(ore, 1))
	assert(bool(splitter.call("can_demolish_safely")))
	splitter.free()
	assert(bi.output_building_port == null)
	assert(ba.input_building_port == null)
	assert(bc.input_building_port == null)
	print("PASS J: Empty splitter removes without retaining port connections")

	root.queue_free()
	print("================================================")
	print("ALL 10 THREE-OUTPUT SPLITTER TESTS PASSED")
	print("================================================")
