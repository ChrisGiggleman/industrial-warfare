extends Node

# E3d5c5o: one splitter to one merger, isolated composite proof.
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


func _split_load(entry: ConveyorSegment, middle: ConveyorSegment, s: ConveyorSplitterComponent) -> void:
	_feed(entry)
	assert(s.advance_split())
	assert(ConveyorBuildingTransfer.try_load_into_belt(middle))


func _merge_load(m: ConveyorMergerComponent, out_belt: ConveyorSegment) -> void:
	assert(m.advance_merge())
	assert(ConveyorBuildingTransfer.try_load_into_belt(out_belt))


func _ready() -> void:
	var root := Node3D.new()
	add_child(root)
	var mb := (load("res://scenes/buildings/conveyor_merger.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(mb)
	var m := mb.get_node("MergerComponent") as ConveyorMergerComponent
	m.set_process(false)
	var ma := mb.get_node("InputPortA") as ItemPortComponent
	var mpb := mb.get_node("InputPortB") as ItemPortComponent
	var mo := mb.get_node("OutputPort") as ItemPortComponent
	var middle := _belt(root, ma)
	var foreign := _belt(root, mpb)
	var out_belt := _belt(root, mo)
	var sb := (load("res://scenes/buildings/conveyor_splitter.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(sb)
	var s := sb.get_node("SplitterComponent") as ConveyorSplitterComponent
	s.set_process(false)
	var si := sb.get_node("InputPort") as ItemPortComponent
	var sa := sb.get_node("OutputPortA") as ItemPortComponent
	var other := sb.get_node("OutputPortB") as ItemPortComponent
	var marker := middle.get_node("InputEndpoint") as Marker3D
	var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	sb.global_transform = desired * sa.transform.affine_inverse()
	assert(middle.try_connect_building_port(sa))
	var entry := _belt(root, si)
	var origin := _source(root, entry)
	var direct := _source(root, foreign)
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var recovery := InventoryComponent.new()
	root.add_child(recovery)
	var out := _cargo(out_belt)
	assert(not m.enable_isolated_splitter_merger_provenance)
	assert(not s.enable_isolated_splitter_provenance and not m.enable_isolated_merger_provenance)
	print("PASS A: Both junctions and composite mode default OFF")
	assert(origin.inventory.add_item(ingot, 4) == 4)
	assert(direct.inventory.add_item(ingot, 2) == 2)
	print("PASS B: Two actual suppliers and four straight belts contain six original ingots; ore seeded separately")
	s.enable_isolated_splitter_provenance = true
	m.enable_isolated_merger_provenance = true
	assert(s.configure_splitter_provenance() and m.configure_merger_provenance())
	print("PASS C: Independent provenance binds both empty junctions")

	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(out.composite_forward_snapshot().is_empty())
	assert(out.merger_forward_snapshot().is_empty())
	assert(out.physical_origin_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(origin.inventory, ingot, 1) == 1)
	print("PASS D: Composite disabled means crossing stays movable but unverified")

	m.enable_isolated_splitter_merger_provenance = true
	_split_load(entry, middle, s)
	assert(_cargo(middle).has_verified_splitter_load(origin, ingot, s, entry, sa))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_feed(foreign)
	_merge_load(m, out_belt)
	# Previous A merge leaves B next.
	assert(out.has_verified_merger_load(direct, ingot, m, foreign, mpb, mo))
	assert(out.composite_forward_snapshot().is_empty())
	print("PASS E: Ordinary B supplier retains single-merger proof even with composite enabled")

	assert(m.advance_merge())
	assert(not ConveyorBuildingTransfer.try_load_into_belt(out_belt))
	assert(not m.advance_merge())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(out_belt))
	var proof: Dictionary = out.composite_forward_snapshot()
	assert(not proof.is_empty())
	print("PASS F: Buffered composite observation survives output backpressure")
	var first: Dictionary = proof["splitter_crossing"]
	assert((proof["port"] as WeakRef).get_ref() == origin)
	assert((first["port"] as WeakRef).get_ref() == origin)
	assert((first["splitter"] as WeakRef).get_ref() == s)
	assert((first["input_port"] as WeakRef).get_ref() == si)
	assert((first["output_port"] as WeakRef).get_ref() == sa)
	assert((first["input_belt"] as WeakRef).get_ref() == entry)
	assert((first["downstream"][0] as WeakRef).get_ref() == middle)
	assert((proof["merger"] as WeakRef).get_ref() == m)
	assert((proof["input_port"] as WeakRef).get_ref() == ma)
	assert((proof["output_port"] as WeakRef).get_ref() == mo)
	assert((proof["input_belt"] as WeakRef).get_ref() == middle)
	assert(proof["item"] == ingot)
	print("PASS G: Original source and ordered splitter then merger identities preserved")
	assert((first["output_port"] as WeakRef).get_ref() != other)
	assert((proof["input_port"] as WeakRef).get_ref() != mpb)
	assert((proof["port"] as WeakRef).get_ref() != direct)
	assert(out.merger_forward_snapshot().is_empty())
	assert(out.splitter_forward_snapshot().is_empty())
	assert(out.physical_origin_snapshot().is_empty())
	assert(not out.has_verified_merger_load(origin, ingot, m, middle, ma, mo))
	var route: Array[ConveyorSegment] = [out_belt]
	assert(not out.has_verified_merger_route(origin, ingot, m, middle, ma, mo, route))
	print("PASS H: Composite cannot masquerade as any existing protected route")
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)

	# Unknown item inserted directly into the inter-junction belt.
	assert(origin.inventory.transfer_to(_cargo(middle).cargo_inventory, ingot, 1) == 1)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(out.composite_forward_snapshot().is_empty() and out.merger_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(origin.inventory, ingot, 1) == 1)
	print("PASS I: Unstamped inter-junction cargo cannot gain a composite identity")

	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	s.enable_isolated_splitter_provenance = false
	s.enable_isolated_splitter_provenance = true
	_merge_load(m, out_belt)
	assert(out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(origin.inventory, ingot, 1) == 1)
	print("PASS J: Splitter off-on invalidates queued composite history")

	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(not out.composite_forward_snapshot().is_empty())
	m.enable_isolated_splitter_merger_provenance = false
	m.enable_isolated_splitter_merger_provenance = true
	assert(out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(origin.inventory, ingot, 1) == 1)
	print("PASS K: Composite off-on invalidates issued proof without movement")

	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(not out.composite_forward_snapshot().is_empty())
	m.enable_isolated_merger_provenance = false
	m.enable_isolated_merger_provenance = true
	assert(out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(origin.inventory, ingot, 1) == 1)
	print("PASS L: Merger epoch invalidates issued composite proof")

	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(not out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.transfer_to(out.cargo_inventory, ingot, 1) == 1)
	assert(out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS M: Same-type outgoing replacement cannot inherit composite proof")

	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(not out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	_split_load(entry, middle, s)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(not out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(origin.inventory.get_amount(ingot) == 0)
	print("PASS N: Fresh same-type arrivals after toggles acquire valid independent observations")

	assert(origin.inventory.add_item(ore, 1) == 1)
	_split_load(entry, middle, s)
	assert(_cargo(middle).get_held_item() == ore)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(middle))
	_merge_load(m, out_belt)
	assert(out.composite_forward_snapshot().get("item") == ore)
	assert(out.cargo_inventory.transfer_to(recovery, ore, 1) == 1)
	print("PASS O: Different material retains the composite history")

	_feed(foreign)
	_merge_load(m, out_belt)
	assert(out.has_verified_merger_load(direct, ingot, m, foreign, mpb, mo))
	assert(out.composite_forward_snapshot().is_empty())
	assert(out.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	print("PASS P: Foreign direct supplier never inherits prior composite proof")

	assert(origin.inventory.get_total_amount() == 0 and direct.inventory.get_total_amount() == 0)
	assert(s.input_inventory.get_total_amount() == 0 and s.output_a.get_total_amount() == 0)
	assert(s.output_b.get_total_amount() == 0 and s.output_c.get_total_amount() == 0)
	assert(m.input_a.get_total_amount() == 0 and m.input_b.get_total_amount() == 0)
	assert(m.input_c.get_total_amount() == 0 and m.output_inventory.get_total_amount() == 0)
	assert(_cargo(entry).get_held_item() == null and _cargo(middle).get_held_item() == null)
	assert(_cargo(foreign).get_held_item() == null and out.get_held_item() == null)
	assert(recovery.get_amount(ingot) == 6 and recovery.get_amount(ore) == 1)
	print("PASS Q: All six original ingots and one ore conserved exactly")
	assert(bool(sb.call("can_demolish_safely")) and bool(mb.call("can_demolish_safely")))
	sb.free()
	mb.free()
	assert(entry.output_building_port == null and middle.input_building_port == null)
	assert(middle.output_building_port == null and foreign.output_building_port == null and out_belt.input_building_port == null)
	print("PASS R: Both empty junctions safely disconnect every attached belt")
	print("ALL 18 E3D5C5O SPLITTER MERGER COMPOSITE PROVENANCE TESTS PASSED")
	print("TEST ONLY: one splitter then one merger, first output belt; no composite receiver or save.")
