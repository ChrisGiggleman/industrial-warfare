extends Node

# =============================================================================
# CHAT 08.3G-3G — TWO-INPUT MERGER REGRESSION
# =============================================================================

func _new_belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _connect_port(
	belt: ConveyorSegment,
	port: ItemPortComponent
) -> bool:
	var preview := ConveyorBuildingSnap.get_preview_transform(port, belt)
	if preview.is_empty():
		return false
	belt.global_transform = preview["transform"]
	return belt.try_connect_building_port(port)


func _ready() -> void:
	print("\n===== CHAT 08.3G-3G: TWO-INPUT MERGER =====")
	var root := Node3D.new()
	add_child(root)
	var packed := load("res://scenes/buildings/conveyor_merger.tscn") as PackedScene
	assert(packed != null)
	var merger := packed.instantiate() as Node3D
	assert(merger != null)
	root.add_child(merger)

	var input_a := merger.get_node("InputPortA") as ItemPortComponent
	var input_b := merger.get_node("InputPortB") as ItemPortComponent
	var output := merger.get_node("OutputPort") as ItemPortComponent
	var a_inventory := merger.get_node("InputAInventory") as InventoryComponent
	var b_inventory := merger.get_node("InputBInventory") as InventoryComponent
	var out_inventory := merger.get_node("OutputInventory") as InventoryComponent
	var component := merger.get_node("MergerComponent") as ConveyorMergerComponent
	component.set_process(false)
	assert(input_a != input_b)
	assert(input_a.direction == ItemPortComponent.PortDirection.INPUT)
	assert(input_b.direction == ItemPortComponent.PortDirection.INPUT)
	assert(output.direction == ItemPortComponent.PortDirection.OUTPUT)
	assert(input_a.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	assert(input_b.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	print("PASS A: Two independent input ports and one output port configured")

	var belt_a := _new_belt(root)
	var belt_b := _new_belt(root)
	var belt_out := _new_belt(root)
	assert(_connect_port(belt_a, input_a))
	assert(_connect_port(belt_b, input_b))
	assert(_connect_port(belt_out, output))
	assert(input_a.connected_conveyor == belt_a)
	assert(input_b.connected_conveyor == belt_b)
	assert(output.connected_conveyor == belt_out)
	print("PASS B: All three distinct physical conveyor connections align")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	var cargo_a := belt_a.get_node("CargoInventory") as InventoryComponent
	var cargo_b := belt_b.get_node("CargoInventory") as InventoryComponent
	var cargo_out := belt_out.get_node("CargoInventory") as InventoryComponent
	assert(cargo_a.add_item(ore, 1) == 1)
	assert(cargo_b.add_item(ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(belt_a))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(belt_b))
	assert(a_inventory.get_amount(ore) == 1)
	assert(b_inventory.get_amount(ingot) == 1)
	assert(cargo_a.get_total_amount() == 0)
	assert(cargo_b.get_total_amount() == 0)
	print("PASS C: Two incoming cargo types delivered independently")

	assert(component.advance_merge())
	assert(out_inventory.get_amount(ore) == 1)
	assert(a_inventory.get_total_amount() == 0)
	assert(b_inventory.get_amount(ingot) == 1)
	print("PASS D: First lane transferred one item into output buffer")

	assert(not component.advance_merge())
	assert(out_inventory.get_total_amount() == 1)
	assert(b_inventory.get_amount(ingot) == 1)
	print("PASS E: Full output applies backpressure without item loss")

	assert(ConveyorBuildingTransfer.try_load_into_belt(belt_out))
	assert(cargo_out.get_amount(ore) == 1)
	assert(out_inventory.get_total_amount() == 0)
	assert(component.advance_merge())
	assert(out_inventory.get_amount(ingot) == 1)
	assert(b_inventory.get_amount(ingot) == 0)
	print("PASS F: Output unload allows round-robin second lane")

	assert(component.completed_merges == 2)
	assert(component.next_lane == 0)
	assert(cargo_out.get_amount(ore) == 1)
	assert(out_inventory.get_amount(ingot) == 1)
	print("PASS G: Deterministic alternating lane arbitration")

	assert(not merger.can_demolish_safely())
	print("PASS H: Merger cannot be demolished while it stores cargo")

	var output_cargo := belt_out.get_node("CargoInventory") as InventoryComponent
	assert(output_cargo.remove_item(ore, 1))
	assert(ConveyorBuildingTransfer.try_load_into_belt(belt_out))
	assert(output_cargo.get_amount(ingot) == 1)
	assert(out_inventory.get_total_amount() == 0)
	assert(merger.can_demolish_safely())
	print("PASS I: Both item types leave through the physical output belt")

	assert(input_a.connected_conveyor == belt_a)
	assert(input_b.connected_conveyor == belt_b)
	assert(output.connected_conveyor == belt_out)
	assert(belt_a.output_building_port == input_a)
	assert(belt_b.output_building_port == input_b)
	assert(belt_out.input_building_port == output)
	print("PASS J: Merger kept all three persistent building links")

	merger.free()
	assert(belt_a.output_building_port == null)
	assert(belt_b.output_building_port == null)
	assert(belt_out.input_building_port == null)
	print("PASS K: Removing empty merger disconnects all ports")

	root.queue_free()
	print("================================================")
	print("ALL 11 MERGER TESTS PASSED")
	print("================================================")
