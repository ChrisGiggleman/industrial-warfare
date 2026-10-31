extends Node

# =============================================================================
# EXISTING CONVEYOR TERMINAL CORNER INTO BUILDING INPUT
# =============================================================================

func _belt(parent: Node3D, origin: Vector3) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	belt.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0), origin
	)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _ready() -> void:
	print("\n===== TERMINAL BUILDING CORNER REGRESSION =====")
	var root := Node3D.new()
	add_child(root)
	var scene := load("res://scenes/buildings/conveyor_merger.tscn") as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(scene != null and ore != null)
	var merger := scene.instantiate() as Node3D
	assert(merger != null)
	root.add_child(merger)
	merger.global_position = Vector3.ZERO
	(merger.get_node("MergerComponent") as Node).set_process(false)
	var input := merger.get_node("InputPortC") as ItemPortComponent
	var inventory := merger.get_node("InputCInventory") as InventoryComponent
	assert(input != null and inventory != null)

	# The line travels east, one tile south of the merger.
	# Its terminal belt must bend north into the merger's south input.
	var upstream := _belt(root, Vector3(-1, 0, 1))
	var end := _belt(root, Vector3(0, 0, 1))
	assert(upstream.try_connect_to(end))
	print("PASS A: Existing straight chain established without a building link")

	assert(ConveyorTerminalBuildingCorner.inspect_pair(
		end, input, ConveyorTurnIntent.Turn.RIGHT
	).is_empty())
	var candidate := ConveyorTerminalBuildingCorner.inspect_pair(
		end, input, ConveyorTurnIntent.Turn.LEFT
	)
	assert(not candidate.is_empty())
	assert(candidate["belt"] == end and candidate["port"] == input)
	print("PASS B: Only correctly directed terminal turn matches the input")

	assert(ConveyorTerminalBuildingCorner.find_nearest(
		get_tree(), end.global_position, 0.65
	).get("belt") == end)
	assert(ConveyorTerminalBuildingCorner.find_nearest(
		get_tree(), end.global_position + Vector3(1, 0, 0), 0.65
	).is_empty())
	print("PASS C: Mouse discovers the intended tile, not a parallel lane")

	var original_input := (end.get_node("InputEndpoint") as Marker3D).transform
	var original_transform := end.global_transform
	var before_mesh := (end.get_node("BeltMesh") as MeshInstance3D).mesh
	var overlay := ConveyorTerminalBuildingCorner.make_overlay(
		candidate, StandardMaterial3D.new()
	)
	assert(overlay != null and overlay.mesh is ArrayMesh)
	overlay.free()
	assert(end.output_building_port == null)
	assert(end.next_segment == null)
	assert((end.get_node("BeltMesh") as MeshInstance3D).mesh == before_mesh)
	print("PASS D: Preview does not change the real conveyor or port")

	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(ConveyorTerminalBuildingCorner.is_clear(
		get_viewport().world_3d, candidate, 4
	))
	print("PASS E: Terminal corner fits beside the building")

	var cargo := end.get_node("CargoInventory") as InventoryComponent
	assert(cargo.add_item(ore, 1) == 1)
	assert(ConveyorTerminalBuildingCorner.try_connect(candidate))
	assert(end.output_building_port == input)
	assert(input.connected_conveyor == end)
	assert(end.previous_segment == upstream)
	assert(upstream.next_segment == end)
	assert(end.global_transform.is_equal_approx(original_transform))
	assert((end.get_node("InputEndpoint") as Marker3D).transform == original_input)
	assert(cargo.get_amount(ore) == 1)
	print("PASS F: In-place corner preserves incoming connection and cargo")

	assert(ConveyorBuildingTransfer.try_unload_from_belt(end))
	assert(cargo.get_amount(ore) == 0)
	assert(inventory.get_amount(ore) == 1)
	print("PASS G: Ore travels through the corner into building input")

	assert(not ConveyorTerminalBuildingCorner.try_connect(candidate))
	assert(ConveyorTerminalBuildingCorner.inspect_pair(
		end, input, ConveyorTurnIntent.Turn.LEFT
	).is_empty())
	assert(input.connected_conveyor == end)
	print("PASS H: Occupied port and repeated conversion rejected")

	root.queue_free()
	print("====================================================")
	print("ALL 8 TERMINAL BUILDING CORNER TESTS PASSED")
	print("====================================================")
