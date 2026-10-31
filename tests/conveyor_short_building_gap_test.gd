extends Node

# =============================================================================
# SHORT BUILDING GAPS AND ADJACENT PARALLEL LANES
# =============================================================================

# Covers a one-tile bridge, two-tile building gap, precise snap
# discovery, and neighboring parallel belts that must stay separate.
# Each test uses real 1x1 Merger/Splitter ports and cargo buffers.


func _building(parent: Node3D, scene_path: String, origin: Vector3) -> Node3D:
	var scene := load(scene_path) as PackedScene
	assert(scene != null)
	var building := scene.instantiate() as Node3D
	assert(building != null)
	parent.add_child(building)
	building.global_position = origin
	var routing := building.get_node_or_null("MergerComponent")
	if routing == null:
		routing = building.get_node_or_null("SplitterComponent")
	if routing != null:
		routing.set_process(false)
	return building


func _belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	timer.set_process(false)
	return belt


func _attach(belt: ConveyorSegment, port: ItemPortComponent) -> void:
	var preview: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(not preview.is_empty())
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))


func _ready() -> void:
	print("\n===== SHORT GAP AND PARALLEL LANE REGRESSION =====")
	var root := Node3D.new()
	add_child(root)
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(ore != null)

	# One tile between two buildings: the same belt must connect both.
	var merger_a := _building(
		root, "res://scenes/buildings/conveyor_merger.tscn",
		Vector3(0.0, 0.0, 0.0)
	)
	var splitter_a := _building(
		root, "res://scenes/buildings/conveyor_splitter.tscn",
		Vector3(2.0, 0.0, 0.0)
	)
	var out_a := merger_a.get_node("OutputPort") as ItemPortComponent
	var in_a := splitter_a.get_node("InputPort") as ItemPortComponent
	var single := _belt(root)
	_attach(single, out_a)
	assert(ConveyorNearbyConnection.complete_open_ends(single) == 1)
	assert(single.input_building_port == out_a)
	assert(single.output_building_port == in_a)
	assert(out_a.connected_conveyor == single)
	assert(in_a.connected_conveyor == single)
	print("PASS A: One-tile gap connects BOTH physical building ports")

	assert(ConveyorNearbyConnection.complete_open_ends(single) == 0)
	assert(out_a.connected_conveyor == single)
	assert(in_a.connected_conveyor == single)
	print("PASS B: Repeated completion does not duplicate or steal links")

	var source_a := merger_a.get_node("OutputInventory") as InventoryComponent
	var sink_a := splitter_a.get_node("InputInventory") as InventoryComponent
	assert(source_a.add_item(ore, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(single))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(single))
	assert(source_a.get_amount(ore) == 0)
	assert(sink_a.get_amount(ore) == 1)
	print("PASS C: One-tile physical route transfers exactly one ore")

	# Two tiles between buildings: independently built end belts must meet.
	var merger_b := _building(
		root, "res://scenes/buildings/conveyor_merger.tscn",
		Vector3(0.0, 0.0, 4.0)
	)
	var splitter_b := _building(
		root, "res://scenes/buildings/conveyor_splitter.tscn",
		Vector3(3.0, 0.0, 4.0)
	)
	var out_b := merger_b.get_node("OutputPort") as ItemPortComponent
	var in_b := splitter_b.get_node("InputPort") as ItemPortComponent
	var left := _belt(root)
	_attach(left, out_b)
	assert(ConveyorNearbyConnection.complete_open_ends(left) == 0)
	var right := _belt(root)
	_attach(right, in_b)
	assert(ConveyorNearbyConnection.complete_open_ends(right) == 1)
	assert(left.next_segment == right)
	assert(right.previous_segment == left)
	assert(left.input_building_port == out_b)
	assert(right.output_building_port == in_b)
	print("PASS D: Two-tile gap joins the building-attached belts")

	var source_b := merger_b.get_node("OutputInventory") as InventoryComponent
	var sink_b := splitter_b.get_node("InputInventory") as InventoryComponent
	assert(source_b.add_item(ore, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(left))
	assert(ConveyorTransportLink.try_transfer_forward(left))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(right))
	assert(source_b.get_amount(ore) == 0)
	assert(sink_b.get_amount(ore) == 1)
	print("PASS E: Two-tile route transports ore without loss")

	# A parallel conveyor one grid tile away is NOT connected.
	var parallel := _belt(root)
	parallel.global_transform = Transform3D(
		single.global_transform.basis,
		single.global_position + Vector3(0.0, 0.0, 1.0)
	)
	assert(ConveyorNearbyConnection.complete_open_ends(parallel) == 0)
	assert(parallel.previous_segment == null)
	assert(parallel.next_segment == null)
	assert(parallel.input_building_port == null)
	assert(parallel.output_building_port == null)
	print("PASS F: Parallel neighboring conveyor stays independent")

	# Cursor over the parallel lane may not snap a full tile sideways.
	var merger_c := _building(
		root, "res://scenes/buildings/conveyor_merger.tscn",
		Vector3(0.0, 0.0, 12.0)
	)
	var out_c := merger_c.get_node("OutputPort") as ItemPortComponent
	var ghost := _belt(root)
	var expected: Dictionary = ConveyorBuildingSnap.get_preview_transform(out_c, ghost)
	assert(not expected.is_empty())
	ghost.global_transform = expected["transform"]
	var exact: Dictionary = ConveyorBuildingPortFinder.find_nearest_preview(
		ghost, ghost.global_position, 0.65
	)
	assert(exact.get("port") == out_c)
	print("PASS G: Cursor on intended tile discovers correct building port")

	var adjacent: Dictionary = ConveyorBuildingPortFinder.find_nearest_preview(
		ghost, ghost.global_position + Vector3(0.0, 0.0, 1.0), 0.65
	)
	assert(adjacent.is_empty())
	print("PASS H: Snap search rejects port one grid lane sideways")

	root.queue_free()
	print("=================================================")
	print("ALL 8 SHORT-GAP AND PARALLEL-LANE TESTS PASSED")
	print("=================================================")
