extends Node

# E3d5c5q: one merger to one splitter, isolated reverse composite proof.
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


func _cargo(belt: ConveyorSegment) -> ConveyorTransportComponent:
	return belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent


func _arrival(entry: ConveyorSegment, middle: ConveyorSegment, merger: ConveyorMergerComponent) -> void:
	_feed(entry)
	assert(merger.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(middle))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))


func _branch(splitter: ConveyorSplitterComponent, belt: ConveyorSegment) -> ConveyorTransportComponent:
	assert(splitter.advance_split())
	assert(ConveyorBuildingTransfer.try_load_into_belt(belt))
	return _cargo(belt)


func _matches(cargo: ConveyorTransportComponent, origin: ItemPortComponent, item: ItemDefinition,
	merger: ConveyorMergerComponent, entry: ConveyorSegment, merge_input: ItemPortComponent,
	merge_output: ItemPortComponent, middle: ConveyorSegment, splitter: ConveyorSplitterComponent,
	split_input: ItemPortComponent, split_output: ItemPortComponent) -> bool:
	var proof: Dictionary = cargo.reverse_composite_snapshot()
	if proof.is_empty() or proof.get("item") != item:
		return false
	var first: Dictionary = proof["merger_crossing"]
	var expected: Dictionary = {"port": origin, "splitter": splitter, "input_belt": middle,
		"input_port": split_input, "output_port": split_output}
	var previous: Dictionary = {"port": origin, "merger": merger, "input_belt": entry,
		"input_port": merge_input, "output_port": merge_output}
	for key: String in expected:
		if (proof[key] as WeakRef).get_ref() != expected[key]:
			return false
	for key: String in previous:
		if (first[key] as WeakRef).get_ref() != previous[key]:
			return false
	return true


func _ready() -> void:
	var root := Node3D.new()
	add_child(root)
	var sb := (load("res://scenes/buildings/conveyor_splitter.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(sb)
	var s := sb.get_node("SplitterComponent") as ConveyorSplitterComponent
	s.set_process(false)
	var si := sb.get_node("InputPort") as ItemPortComponent
	var sa := sb.get_node("OutputPortA") as ItemPortComponent
	var spb := sb.get_node("OutputPortB") as ItemPortComponent
	var sc := sb.get_node("OutputPortC") as ItemPortComponent
	var middle := _belt(root, si)
	var oa := _belt(root, sa)
	var ob := _belt(root, spb)
	var oc := _belt(root, sc)
	var mb := (load("res://scenes/buildings/conveyor_merger.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(mb)
	var m := mb.get_node("MergerComponent") as ConveyorMergerComponent
	m.set_process(false)
	var ma := mb.get_node("InputPortA") as ItemPortComponent
	var mpb := mb.get_node("InputPortB") as ItemPortComponent
	var mc := mb.get_node("InputPortC") as ItemPortComponent
	var mo := mb.get_node("OutputPort") as ItemPortComponent
	var marker := middle.get_node("InputEndpoint") as Marker3D
	var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	mb.global_transform = desired * mo.transform.affine_inverse()
	assert(middle.try_connect_building_port(mo))
	var ea := _belt(root, ma)
	var eb := _belt(root, mpb)
	var ec := _belt(root, mc)
	var a := _source(root, ea)
	var b := _source(root, eb)
	var c := _source(root, ec)
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var recovery := InventoryComponent.new()
	root.add_child(recovery)
	assert(not s.enable_isolated_merger_splitter_provenance)
	assert(not s.enable_isolated_splitter_provenance and not m.enable_isolated_merger_provenance)
	print("PASS A: Reverse composite and both original modes default OFF")
	assert(a.inventory.add_item(ingot, 4) == 4)
	assert(b.inventory.add_item(ingot, 2) == 2)
	assert(c.inventory.add_item(ingot, 1) == 1)
	print("PASS B: Three suppliers, seven ingots and seven real physical belts")
	s.enable_isolated_splitter_provenance = true
	m.enable_isolated_merger_provenance = true
	assert(s.configure_splitter_provenance() and m.configure_merger_provenance())
	print("PASS C: Empty original junctions configure separately")

	_arrival(ea, middle, m)
	var ca := _branch(s, oa)
	assert(ca.reverse_composite_snapshot().is_empty())
	assert(ca.splitter_forward_snapshot().is_empty())
	assert(ca.physical_origin_snapshot().is_empty())
	assert(ca.cargo_inventory.transfer_to(a.inventory, ingot, 1) == 1)
	print("PASS D: Disabled reverse mode preserves physical movement but never issues reverse proof")

	s.enable_isolated_merger_splitter_provenance = true
	# Both round-robin counters are now at B after the opt-out trip.
	_feed(ea)
	_feed(eb)
	_feed(ec)
	for i: int in range(3):
		assert(m.advance_merge())
		assert(ConveyorBuildingTransfer.try_load_into_belt(middle))
		assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	assert(s.input_inventory.get_amount(ingot) == 3)
	assert(m.completed_from_a == 2 and m.completed_from_b == 1 and m.completed_from_c == 1)
	print("PASS E: Merger distributes B C A in its independent round-robin order")
	for i: int in range(3):
		assert(s.advance_split())
	assert(s.output_a.get_amount(ingot) == 1 and s.output_b.get_amount(ingot) == 1 and s.output_c.get_amount(ingot) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(oa))
	assert(ConveyorBuildingTransfer.try_load_into_belt(ob))
	assert(ConveyorBuildingTransfer.try_load_into_belt(oc))
	var cb := _cargo(ob)
	var cc := _cargo(oc)
	assert(_matches(cb, b, ingot, m, eb, mpb, mo, middle, s, si, spb))
	assert(_matches(cc, c, ingot, m, ec, mc, mo, middle, s, si, sc))
	assert(_matches(ca, a, ingot, m, ea, ma, mo, middle, s, si, sa))
	print("PASS F: Identical ingots retain three distinct sources and both exact lane identities")
	assert(not _matches(ca, b, ingot, m, ea, ma, mo, middle, s, si, sa))
	assert(not _matches(ca, a, ingot, m, ea, mpb, mo, middle, s, si, sa))
	assert(not _matches(ca, a, ingot, m, ea, ma, mo, middle, s, si, spb))
	print("PASS G: Incorrect supplier, merger input or splitter output attribution rejected")
	assert(ca.splitter_forward_snapshot().is_empty() and ca.merger_forward_snapshot().is_empty())
	assert(ca.composite_forward_snapshot().is_empty() and ca.physical_origin_snapshot().is_empty())
	assert(not ca.has_verified_splitter_load(a, ingot, s, middle, sa))
	var path: Array[ConveyorSegment] = [oa]
	assert(not ca.has_verified_splitter_branch(a, ingot, s, middle, si, sa, path))
	print("PASS H: Reverse proof is separate from every existing receiver proof")

	# Next splitter lane B is occupied; waiting output remains intact.
	_arrival(ea, middle, m)
	assert(s.advance_split())
	assert(s.output_b.get_amount(ingot) == 1)
	assert(not ConveyorBuildingTransfer.try_load_into_belt(ob))
	assert(cb.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(ob))
	assert(_matches(cb, a, ingot, m, ea, ma, mo, middle, s, si, spb))
	assert(ca.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(cc.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(cb.cargo_inventory.transfer_to(a.inventory, ingot, 1) == 1)
	print("PASS I: Occupied branch retains waiting cargo and recovers correct distinct proof")

	assert(a.inventory.transfer_to(_cargo(middle).cargo_inventory, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	assert(s.advance_split())
	assert(ConveyorBuildingTransfer.try_load_into_belt(oc))
	assert(cc.reverse_composite_snapshot().is_empty())
	assert(cc.splitter_forward_snapshot().is_empty())
	assert(cc.cargo_inventory.transfer_to(a.inventory, ingot, 1) == 1)
	print("PASS J: Unstamped inter-junction material cannot steal reverse provenance")

	_arrival(ea, middle, m)
	m.enable_isolated_merger_provenance = false
	m.enable_isolated_merger_provenance = true
	ca = _branch(s, oa)
	assert(ca.reverse_composite_snapshot().is_empty())
	assert(ca.cargo_inventory.transfer_to(a.inventory, ingot, 1) == 1)
	print("PASS K: Merger epoch invalidates queued reverse proof")

	_arrival(ea, middle, m)
	cb = _branch(s, ob)
	assert(not cb.reverse_composite_snapshot().is_empty())
	s.enable_isolated_splitter_provenance = false
	s.enable_isolated_splitter_provenance = true
	assert(cb.reverse_composite_snapshot().is_empty())
	assert(cb.cargo_inventory.transfer_to(a.inventory, ingot, 1) == 1)
	print("PASS L: Splitter epoch invalidates issued reverse proof")

	_arrival(ea, middle, m)
	cc = _branch(s, oc)
	assert(not cc.reverse_composite_snapshot().is_empty())
	s.enable_isolated_merger_splitter_provenance = false
	s.enable_isolated_merger_splitter_provenance = true
	assert(cc.reverse_composite_snapshot().is_empty())
	assert(cc.cargo_inventory.transfer_to(a.inventory, ingot, 1) == 1)
	print("PASS M: Reverse feature off-on invalidates issued proof without movement")

	_arrival(ea, middle, m)
	ca = _branch(s, oa)
	assert(not ca.reverse_composite_snapshot().is_empty())
	assert(ca.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.transfer_to(ca.cargo_inventory, ingot, 1) == 1)
	assert(ca.reverse_composite_snapshot().is_empty())
	assert(ca.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS N: Same-type belt replacement invalidates identity")

	_arrival(ea, middle, m)
	cb = _branch(s, ob)
	assert(_matches(cb, a, ingot, m, ea, ma, mo, middle, s, si, spb))
	assert(cb.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	_arrival(ea, middle, m)
	cc = _branch(s, oc)
	assert(_matches(cc, a, ingot, m, ea, ma, mo, middle, s, si, sc))
	assert(cc.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(a.inventory.get_total_amount() == 0)
	print("PASS O: Fresh valid loads resume after all feature toggles")

	assert(a.inventory.add_item(ore, 1) == 1)
	_arrival(ea, middle, m)
	ca = _branch(s, oa)
	assert(_matches(ca, a, ore, m, ea, ma, mo, middle, s, si, sa))
	assert(ca.cargo_inventory.transfer_to(recovery, ore, 1) == 1)
	_arrival(eb, middle, m)
	cb = _branch(s, ob)
	assert(_matches(cb, b, ingot, m, eb, mpb, mo, middle, s, si, spb))
	assert(cb.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS P: Mixed material and another original supplier remain independently verifiable")

	assert(a.inventory.get_total_amount() == 0 and b.inventory.get_total_amount() == 0 and c.inventory.get_total_amount() == 0)
	assert(s.input_inventory.get_total_amount() == 0 and s.output_a.get_total_amount() == 0)
	assert(s.output_b.get_total_amount() == 0 and s.output_c.get_total_amount() == 0)
	assert(m.input_a.get_total_amount() == 0 and m.input_b.get_total_amount() == 0)
	assert(m.input_c.get_total_amount() == 0 and m.output_inventory.get_total_amount() == 0)
	for belt: ConveyorSegment in [ea, eb, ec, middle, oa, ob, oc]:
		assert(_cargo(belt).get_held_item() == null)
	assert(recovery.get_amount(ingot) == 7 and recovery.get_amount(ore) == 1)
	print("PASS Q: All seven original ingots and one ore conserved exactly")
	assert(bool(sb.call("can_demolish_safely")) and bool(mb.call("can_demolish_safely")))
	sb.free()
	mb.free()
	assert(ea.output_building_port == null and eb.output_building_port == null and ec.output_building_port == null)
	assert(middle.input_building_port == null and middle.output_building_port == null)
	assert(oa.input_building_port == null and ob.input_building_port == null and oc.input_building_port == null)
	print("PASS R: Both empty junctions safely disconnect all seven belts")
	print("ALL 18 E3D5C5Q MERGER SPLITTER REVERSE COMPOSITE PROVENANCE TESTS PASSED")
	print("TEST ONLY: One merger then one splitter, first outgoing belts; no reverse receiver or save.")
