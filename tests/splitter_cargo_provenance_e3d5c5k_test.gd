extends Node

# E3d5c5k: actual splitter input, round-robin distribution and first
# outgoing belt. Explicit ticks, seeded material, no construction authority.

func _belt(parent_node: Node3D, port: ItemPortComponent) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent_node.add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	var preview: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))
	return belt


func _cargo(belt: ConveyorSegment) -> ConveyorTransportComponent:
	return belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent


func _ready() -> void:
	var root := Node3D.new()
	add_child(root)
	var packed := load("res://scenes/buildings/conveyor_splitter.tscn") as PackedScene
	var splitter := packed.instantiate() as Node3D
	root.add_child(splitter)
	var component := splitter.get_node("SplitterComponent") as ConveyorSplitterComponent
	component.set_process(false)
	var pi := splitter.get_node("InputPort") as ItemPortComponent
	var pa := splitter.get_node("OutputPortA") as ItemPortComponent
	var pb := splitter.get_node("OutputPortB") as ItemPortComponent
	var pc := splitter.get_node("OutputPortC") as ItemPortComponent
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	assert(not component.enable_isolated_splitter_provenance)
	assert(not component.uses_splitter_provenance())
	assert(not component.configure_splitter_provenance())
	print("PASS A: Existing splitter defaults to ordinary untracked distribution")

	var bi := _belt(root, pi)
	var ba := _belt(root, pa)
	var bb := _belt(root, pb)
	var bc := _belt(root, pc)
	var source := (load("res://scenes/buildings/test_storage.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(source)
	var output := source.get_node("OutputPort") as ItemPortComponent
	var stock := output.inventory
	var endpoint := bi.get_node("InputEndpoint") as Marker3D
	var desired := endpoint.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	source.global_transform = desired * output.transform.affine_inverse()
	assert(bi.try_connect_building_port(output))
	assert(stock.add_item(ingot, 7) == 7)
	assert(stock.add_item(ore, 2) == 2)
	print("PASS B: Real Storage output and four splitter belts are physically connected")

	var ci := _cargo(bi)
	var ca := _cargo(ba)
	var cb := _cargo(bb)
	var cc := _cargo(bc)
	var incoming := component.input_inventory
	component.enable_isolated_splitter_provenance = true
	assert(stock.transfer_to(incoming, ingot, 1) == 1)
	assert(not component.configure_splitter_provenance())
	assert(incoming.transfer_to(stock, ingot, 1) == 1)
	assert(component.configure_splitter_provenance())
	assert(not component.configure_splitter_provenance())
	print("PASS C: Tracking binds only once to an empty actual splitter")

	for i: int in range(3):
		assert(ConveyorBuildingTransfer.try_load_into_belt(bi))
		assert(ci.has_physical_building_load(output, ingot))
		assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	assert(incoming.get_amount(ingot) == 3)
	assert(stock.get_amount(ingot) == 4)
	print("PASS D: Three real incoming loads reach the shared queue")

	for i: int in range(3):
		assert(component.advance_split())
	assert(component.output_a.get_amount(ingot) == 1)
	assert(component.output_b.get_amount(ingot) == 1)
	assert(component.output_c.get_amount(ingot) == 1)
	assert(component.next_lane == 0)
	print("PASS E: Original round-robin sends one unit to each branch")

	assert(ConveyorBuildingTransfer.try_load_into_belt(bi))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	assert(not component.advance_split())
	assert(incoming.get_amount(ingot) == 1)
	print("PASS F: Full output buffers preserve queued cargo under backpressure")

	assert(ConveyorBuildingTransfer.try_load_into_belt(ba))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bb))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bc))
	assert(ca.has_verified_splitter_load(output, ingot, component, bi, pa))
	assert(cb.has_verified_splitter_load(output, ingot, component, bi, pb))
	assert(cc.has_verified_splitter_load(output, ingot, component, bi, pc))
	assert(not ca.has_verified_splitter_load(output, ingot, component, bi, pb))
	print("PASS G: All branches retain original supplier and their distinct output identity")

	assert(not ca.has_physical_building_load(pa, ingot))
	assert(not ca.has_physical_building_load(output, ingot))
	assert(ca.physical_origin_snapshot().is_empty())
	var linear: Array[ConveyorSegment] = [bi, ba]
	assert(not ca.has_verified_physical_route(output, ingot, linear))
	print("PASS H: Splitter proof cannot masquerade as a direct or linear receiver proof")

	assert(component.advance_split())
	assert(component.output_a.get_amount(ingot) == 1)
	assert(not ConveyorBuildingTransfer.try_load_into_belt(ba))
	assert(component.output_a.get_amount(ingot) == 1)
	print("PASS I: Occupied outgoing belt retains both its cargo and next output item")

	var recovery := InventoryComponent.new()
	root.add_child(recovery)
	assert(ca.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(ba))
	assert(ca.has_verified_splitter_load(output, ingot, component, bi, pa))
	print("PASS J: Backpressure recovery preserves the waiting item's original proof")

	assert(cb.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(cc.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ca.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.get_amount(ingot) == 4)
	assert(stock.transfer_to(incoming, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bi))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	assert(incoming.get_amount(ingot) == 2)
	assert(component.advance_split())
	assert(component.advance_split())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bb))
	assert(ConveyorBuildingTransfer.try_load_into_belt(bc))
	assert(not cb.has_verified_splitter_load(output, ingot, component, bi, pb))
	assert(cc.has_verified_splitter_load(output, ingot, component, bi, pc))
	print("PASS K: Untracked same-type queue item cannot steal following item's proof")

	assert(cb.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(cc.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bi))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	assert(component.advance_split())
	assert(component.output_a.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.transfer_to(component.output_a, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(ba))
	assert(not ca.has_verified_splitter_load(output, ingot, component, bi, pa))
	assert(not ca.has_physical_building_load(pa, ingot))
	print("PASS L: API replacement in an output buffer invalidates old proof without destroying cargo")

	assert(ca.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.get_amount(ingot) == 7)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bi))
	assert(ci.get_held_item() == ore)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	assert(component.advance_split())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bb))
	assert(cb.has_verified_splitter_load(output, ore, component, bi, pb))
	assert(not cb.has_verified_splitter_load(output, ingot, component, bi, pb))
	print("PASS M: A second real item type retains its own proof")

	assert(cb.cargo_inventory.transfer_to(recovery, ore, 1) == 1)
	assert(recovery.transfer_to(cb.cargo_inventory, ore, 1) == 1)
	assert(not cb.has_verified_splitter_load(output, ore, component, bi, pb))
	assert(cb.cargo_inventory.transfer_to(recovery, ore, 1) == 1)
	print("PASS N: Same-item outgoing cargo replacement invalidates the observation")

	assert(ConveyorBuildingTransfer.try_load_into_belt(bi))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(bi))
	component.enable_isolated_splitter_provenance = false
	assert(component.uses_splitter_provenance())
	assert(component.advance_split())
	component.enable_isolated_splitter_provenance = true
	assert(ConveyorBuildingTransfer.try_load_into_belt(bc))
	assert(not cc.has_verified_splitter_load(output, ore, component, bi, pc))
	assert(not cc.has_physical_building_load(pc, ore))
	assert(cc.cargo_inventory.transfer_to(recovery, ore, 1) == 1)
	print("PASS O: Opt-out during distribution cannot reissue cargo as a new source")

	assert(stock.get_total_amount() == 0)
	assert(incoming.get_total_amount() == 0)
	assert(component.output_a.get_total_amount() == 0)
	assert(component.output_b.get_total_amount() == 0)
	assert(component.output_c.get_total_amount() == 0)
	assert(recovery.get_amount(ingot) == 7 and recovery.get_amount(ore) == 2)
	assert(bool(splitter.call("can_demolish_safely")))
	print("PASS P: All nine original materials conserved, empty splitter safe to remove")

	print("ALL 16 E3D5C5K SPLITTER CARGO PROVENANCE TESTS PASSED")
	print("TEST ONLY: One splitter crossing to first outgoing belts; no branch receiver admission or save/load.")
