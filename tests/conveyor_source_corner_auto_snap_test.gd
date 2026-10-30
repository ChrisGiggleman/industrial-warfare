extends Node

# =============================================================================
# SOURCE CORNER WITH EXISTING BUILDING CONNECTIONS
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _ready() -> void:
	print("\n===== CHAT 08.3G-3F: BUILDING-SAFE SOURCE CORNER =====")
	var root := Node3D.new()
	add_child(root)

	var source := _make_belt(root)
	var destination := _make_belt(root)
	source.global_position = Vector3.ZERO
	destination.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0), Vector3(1, 0, 0)
	)

	# Simulate the physically aligned, persistent building OUTPUT port.
	# The source INPUT must not be redirected when its OUTPUT turns.
	var port := ItemPortComponent.new()
	root.add_child(port)
	var input_marker := source.get_node("InputEndpoint") as Marker3D
	port.global_transform = Transform3D(
		input_marker.global_transform.basis * Basis(Vector3.UP, PI),
		input_marker.global_position
	)
	port.direction = ItemPortComponent.PortDirection.OUTPUT
	port.connected_conveyor = source
	source.input_building_port = port
	print("PASS A: Building output remains connected to conveyor input")

	var candidate: Dictionary = (
		ConveyorSourceCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3.ZERO, 0.75
		)
	)
	assert(candidate.get("mode") == "convert_source")
	assert(candidate["source"] == source)
	assert(candidate["receiver"] == destination)
	assert(candidate["turn"] == ConveyorTurnIntent.Turn.RIGHT)
	print("PASS B: Existing building-supplied source output discovered")

	var original_root := source.global_transform
	var original_input := input_marker.transform
	var overlay := ConveyorSourceCornerBuildPreview.make_overlay(
		candidate, StandardMaterial3D.new()
	)
	assert(overlay != null)
	assert(overlay.mesh is ArrayMesh)
	assert(source.next_segment == null)
	assert(source.input_building_port == port)
	overlay.free()
	print("PASS C: Preview does not change source or its building link")

	await get_tree().physics_frame
	await get_tree().physics_frame
	assert(
		ConveyorSourceCornerBuildPreview.is_clear(
			get_viewport().world_3d, candidate, 4
		)
	)
	print("PASS D: Building-safe source corner passes clearance check")

	var blocker := StaticBody3D.new()
	blocker.collision_layer = 4
	blocker.collision_mask = 0
	root.add_child(blocker)
	blocker.global_position = source.global_position
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	shape.shape = box
	shape.position.y = 0.3
	blocker.add_child(shape)
	await get_tree().physics_frame
	assert(
		not ConveyorSourceCornerBuildPreview.is_clear(
			get_viewport().world_3d, candidate, 4
		)
	)
	assert(source.next_segment == null)
	print("PASS E: Unrelated building collision blocks conversion")
	blocker.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(ore != null)
	var source_cargo := source.get_node("CargoInventory") as InventoryComponent
	var destination_cargo := destination.get_node("CargoInventory") as InventoryComponent
	assert(source_cargo.add_item(ore, 1) == 1)
	assert(ConveyorExistingConnection.try_connect_candidate(candidate))
	assert(source.next_segment == destination)
	assert(destination.previous_segment == source)
	assert(source.input_building_port == port)
	assert(port.connected_conveyor == source)
	assert(source.global_transform == original_root)
	assert(input_marker.transform == original_input)
	assert(source_cargo.get_amount(ore) == 1)
	print("PASS F: Output turned without losing building input or cargo")

	assert(ConveyorTransportLink.try_transfer_forward(source))
	assert(source_cargo.get_amount(ore) == 0)
	assert(destination_cargo.get_amount(ore) == 1)
	print("PASS G: Transport follows the new source corner")

	assert(
		ConveyorSourceCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3.ZERO, 0.75
		).is_empty()
	)
	assert(not ConveyorExistingConnection.try_connect_candidate(candidate))
	print("PASS H: Occupied and stale connection requests rejected")

	var opposite_source := _make_belt(root)
	var opposite_target := _make_belt(root)
	opposite_source.global_position = Vector3(20, 0, 0)
	opposite_target.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0), Vector3(19, 0, 0)
	)
	var opposite := ConveyorSourceCornerAutoSnap.find_nearest_preview(
		get_tree(), Vector3(20, 0, 0), 0.75
	)
	assert(opposite.get("mode") == "convert_source")
	assert(opposite["turn"] == ConveyorTurnIntent.Turn.LEFT)
	print("PASS I: Opposite source corner discovered")

	var occupied_port := ItemPortComponent.new()
	root.add_child(occupied_port)
	opposite_source.output_building_port = occupied_port
	assert(
		ConveyorSourceCornerAutoSnap.find_nearest_preview(
			get_tree(), Vector3(20, 0, 0), 0.75
		).is_empty()
	)
	assert(opposite_source.next_segment == null)
	print("PASS J: Building-connected output cannot be redirected")

	root.queue_free()
	print("==============================================")
	print("ALL 10 BUILDING-SAFE SOURCE CORNER TESTS PASSED")
	print("==============================================")
