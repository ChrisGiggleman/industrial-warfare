extends Node

# E3d5c5m: one merger, three real Storage suppliers, first outgoing belt.
# Explicit transfers and seeded stock; no protected receiver admission.

func _belt(parent_node: Node3D, port: ItemPortComponent) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	parent_node.add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	return belt


func _source(root: Node3D, belt: ConveyorSegment) -> ItemPortComponent:
	var building := (load("res://scenes/buildings/test_storage.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(building)
	var port := building.get_node("OutputPort") as ItemPortComponent
	var marker := belt.get_node("InputEndpoint") as Marker3D
	var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	building.global_transform = desired * port.transform.affine_inverse()
	assert(belt.try_connect_building_port(port))
	return port


func _feed(belt: ConveyorSegment) -> void:
	assert(ConveyorBuildingTransfer.try_load_into_belt(belt))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(belt))


func _ready() -> void:
	var root := Node3D.new()
	add_child(root)
	var building := (load("res://scenes/buildings/conveyor_merger.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(building)
	var m := building.get_node("MergerComponent") as ConveyorMergerComponent
	m.set_process(false)
	var pa := building.get_node("InputPortA") as ItemPortComponent
	var pb := building.get_node("InputPortB") as ItemPortComponent
	var pc := building.get_node("InputPortC") as ItemPortComponent
	var po := building.get_node("OutputPort") as ItemPortComponent
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(ingot != null and ore != null)
	assert(not m.enable_isolated_merger_provenance)
	assert(not m.uses_merger_provenance())
	assert(not m.configure_merger_provenance())
	print("PASS A: Ordinary merger defaults to untracked distribution")

	var ba := _belt(root, pa)
	var bb := _belt(root, pb)
	var bc := _belt(root, pc)
	var bo := _belt(root, po)
	var sa := _source(root, ba)
	var sb := _source(root, bb)
	var sc := _source(root, bc)
	assert(sa.inventory.add_item(ingot, 3) == 3)
	assert(sb.inventory.add_item(ingot, 3) == 3)
	assert(sc.inventory.add_item(ingot, 2) == 2)
	assert(sc.inventory.add_item(ore, 1) == 1)
	var out := bo.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var recovery := InventoryComponent.new()
	root.add_child(recovery)
	print("PASS B: Three distinct real suppliers and four physical belts hold nine original units")

	m.enable_isolated_merger_provenance = true
	assert(sa.inventory.transfer_to(m.input_a, ingot, 1) == 1)
	assert(not m.configure_merger_provenance())
	assert(m.input_a.transfer_to(sa.inventory, ingot, 1) == 1)
	assert(m.configure_merger_provenance())
	assert(not m.configure_merger_provenance())
	print("PASS C: Opt-in binds once to empty original independent queues")

	_feed(ba)
	_feed(bb)
	_feed(bc)
	assert(m.input_a.get_amount(ingot) == 1)
	assert(m.input_b.get_amount(ingot) == 1)
	assert(m.input_c.get_amount(ingot) == 1)
	print("PASS D: Identical ingots enter three independent physical queues")

	assert(m.advance_merge())
	assert(not m.advance_merge())
	assert(m.input_b.get_amount(ingot) == 1 and m.input_c.get_amount(ingot) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sa, ingot, m, ba, pa, po))
	assert(not out.has_verified_merger_load(sb, ingot, m, ba, pa, po))
	assert(not out.has_verified_merger_load(sa, ingot, m, bb, pb, po))
	print("PASS E: Lane A retains exact origin and blocks false source or lane attribution")

	assert(m.advance_merge())
	assert(not ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(m.output_inventory.get_amount(ingot) == 1)
	assert(not m.advance_merge())
	assert(out.has_verified_merger_load(sa, ingot, m, ba, pa, po))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sb, ingot, m, bb, pb, po))
	print("PASS F: Backpressure preserves distinct same-type cargo from lane B")

	assert(m.advance_merge())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sc, ingot, m, bc, pc, po))
	assert(m.completed_from_a == 1 and m.completed_from_b == 1 and m.completed_from_c == 1)
	assert(m.next_lane == 0)
	print("PASS G: A B C round-robin preserves three distinct supplier identities")

	assert(not out.has_physical_building_load(po, ingot))
	assert(not out.has_physical_building_load(sc, ingot))
	assert(out.physical_origin_snapshot().is_empty())
	assert(out.splitter_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS H: Merger proof is separate from direct linear and splitter proof")

	# Unknown item first in A, followed by one physically observed identical item.
	assert(sa.inventory.transfer_to(m.input_a, ingot, 1) == 1)
	_feed(ba)
	_feed(bb)
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(not out.has_verified_merger_load(sa, ingot, m, ba, pa, po))
	assert(not out.has_physical_building_load(po, ingot))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS I: Unknown queue unit cannot steal following same-item proof")

	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sb, ingot, m, bb, pb, po))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sa, ingot, m, ba, pa, po))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(m.completed_from_a == 3 and m.completed_from_b == 2)
	print("PASS J: Empty lane skipped; later verified same-type item retains its identity")

	_feed(bb)
	assert(m.advance_merge())
	assert(m.output_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.transfer_to(m.output_inventory, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(not out.has_verified_merger_load(sb, ingot, m, bb, pb, po))
	assert(not out.has_physical_building_load(po, ingot))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS K: Output inventory API replacement invalidates origin evidence")

	_feed(bc)
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sc, ingot, m, bc, pc, po))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.transfer_to(out.cargo_inventory, ingot, 1) == 1)
	assert(not out.has_verified_merger_load(sc, ingot, m, bc, pc, po))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS L: Same-item outgoing belt replacement also invalidates evidence")

	_feed(bc)
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sc, ore, m, bc, pc, po))
	assert(not out.has_verified_merger_load(sc, ingot, m, bc, pc, po))
	print("PASS M: A second material type remains independently verifiable")

	m.enable_isolated_merger_provenance = false
	assert(m.uses_merger_provenance())
	m.enable_isolated_merger_provenance = true
	assert(not out.has_verified_merger_load(sc, ore, m, bc, pc, po))
	assert(out.cargo_inventory.transfer_to(recovery, ore, 1) == 1)
	print("PASS N: Off-on toggle invalidates old outgoing observation without any transfer")

	# Recycle a known unit into the real source for a queue toggle challenge.
	assert(recovery.transfer_to(sa.inventory, ingot, 1) == 1)
	_feed(ba)
	m.enable_isolated_merger_provenance = false
	m.enable_isolated_merger_provenance = true
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(not out.has_verified_merger_load(sa, ingot, m, ba, pa, po))
	assert(not out.has_physical_building_load(po, ingot))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS O: Off-on toggle also invalidates queued proof; cargo remains movable")

	assert(recovery.transfer_to(sb.inventory, ingot, 1) == 1)
	_feed(bb)
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(bo))
	assert(out.has_verified_merger_load(sb, ingot, m, bb, pb, po))
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS P: New physical loads after opt-in receive fresh valid observations")

	assert(not m.advance_merge())
	assert(m.input_a.get_total_amount() == 0 and m.input_b.get_total_amount() == 0)
	assert(m.input_c.get_total_amount() == 0 and m.output_inventory.get_total_amount() == 0)
	assert(sa.inventory.get_total_amount() == 0 and sb.inventory.get_total_amount() == 0 and sc.inventory.get_total_amount() == 0)
	assert(recovery.get_amount(ingot) == 8 and recovery.get_amount(ore) == 1)
	print("PASS Q: All eight original ingots and one ore conserved exactly")

	assert(bool(building.call("can_demolish_safely")))
	building.free()
	assert(ba.output_building_port == null and bb.output_building_port == null)
	assert(bc.output_building_port == null and bo.input_building_port == null)
	print("PASS R: Empty tracked merger safely removes all four physical connections")

	print("ALL 18 E3D5C5M MERGER CARGO PROVENANCE TESTS PASSED")
	print("TEST ONLY: One merger crossing to first outgoing belt; no protected receiver admission or save/load.")
