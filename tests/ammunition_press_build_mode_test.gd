extends Node

# =============================================================================
# AMMUNITION PRESS BUILD-MODE INTEGRATION REGRESSION
# =============================================================================

# Uses the real Main scene, build HUD, and building definition.
# Verifies key 8 selection, preview, grid/port alignment and safe
# demolition without modifying established conveyor algorithms.

func _press_key(controller: Node, key: Key) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.echo = false
	event.keycode = key
	event.physical_keycode = key
	controller.call("_unhandled_input", event)


func _ready() -> void:
	print("\n===== AMMUNITION PRESS BUILD MODE REGRESSION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	var hud = world.get_node("BuildHUD")
	assert(controller != null and hud != null)
	# Verify the original eight slots still work after slot 9 is added.
	assert(controller.buildable_definitions.size() == 9)

	var expected_ids: Array[StringName] = [
		&"test_extractor", &"test_building_large", &"test_storage",
		&"test_smelter", &"conveyor_belt", &"conveyor_merger",
		&"conveyor_splitter", &"prototype_ammunition_press"
	]
	for i: int in range(expected_ids.size()):
		assert(
			controller.buildable_definitions[i].building_id == expected_ids[i],
			"Unexpected building ID in construction slot %d" % (i + 1)
		)
	var press_definition: BuildingDefinition = controller.buildable_definitions[7]
	assert(press_definition.building_scene != null)
	assert(press_definition.footprint_tiles == Vector2i(2, 2))
	print("PASS A: Eight build slots registered, with ammunition press at slot 8")

	controller._toggle_placement_mode()
	assert(controller.placement_mode_active)
	_press_key(controller, KEY_8)
	assert(controller.selected_building_index == 7)
	assert(controller._get_selected_building_definition() == press_definition)
	assert(is_instance_valid(controller.placement_ghost))
	assert(controller.placement_ghost.name.begins_with("PrototypeAmmunitionPress"))
	print("PASS B: Key 8 selects the real ammunition press placement ghost")

	var building_8_label := hud.get_node(
		"BuildPanel/PanelMargin/BuildInfo/Building8Label"
	) as Label
	var building_7_label := hud.get_node(
		"BuildPanel/PanelMargin/BuildInfo/Building7Label"
	) as Label
	assert(building_8_label != null and building_7_label != null)
	assert(building_8_label.text == "> [8] Ammunition Press")
	assert(building_8_label.modulate == hud.selected_color)
	assert(building_7_label.modulate == hud.normal_color)
	print("PASS C: Build HUD highlights slot 8 and leaves slot 7 unselected")

	_press_key(controller, KEY_R)
	assert(is_equal_approx(controller.placement_rotation_degrees, 90.0))
	assert(is_equal_approx(controller.placement_ghost.rotation_degrees.y, 90.0))
	print("PASS D: Ammunition press responds to 90-degree build rotation")

	var press := press_definition.building_scene.instantiate() as Node3D
	assert(press != null)
	add_child(press)
	var runtime := press.get_node("BuildingRuntime") as BuildingRuntime
	assert(runtime != null)
	runtime.initialize(press_definition)

	for quarter: int in range(4):
		var footprint: Vector2i = FactoryGrid.rotated_footprint(
			press_definition.footprint_tiles, quarter
		)
		var origin := FactoryGrid.snap_building_origin(
			Vector3(3.4, 0.0, 5.6), footprint
		)
		press.global_transform = Transform3D(
			Basis(Vector3.UP, quarter * PI / 2.0), origin
		)
		var count: int = 0
		for child: Node in press.get_children():
			if not child is ItemPortComponent:
				continue
			var port := child as ItemPortComponent
			var forward := (
				port.global_transform.basis * Vector3.FORWARD
			).normalized()
			var belt_center := (
				port.global_position + forward * FactoryGrid.CELL_SIZE * 0.5
				- Vector3.UP * FactoryGrid.PORT_HEIGHT
			)
			assert(FactoryGrid.is_on_conveyor_grid(belt_center))
			count += 1
		assert(count == 2)
	print("PASS E: Two physical ports align with the grid at all rotations")

	press.global_transform = Transform3D.IDENTITY
	var producer := press.get_node("ProducerComponent") as ProducerComponent
	var incoming := press.get_node("InputInventory") as InventoryComponent
	var outgoing := press.get_node("OutputInventory") as InventoryComponent
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var rounds := load("res://data/items/prototype_ammunition.tres") as ItemDefinition
	assert(producer != null and ingot != null and ore != null and rounds != null)
	producer.set_process(false)
	assert(producer.accepts_input_item(ingot))
	assert(not producer.accepts_input_item(ore))
	assert(incoming != outgoing)
	assert(press.call("can_demolish_safely"))
	assert(incoming.add_item(ingot, 1) == 1)
	assert(not press.call("can_demolish_safely"))
	assert(incoming.remove_item(ingot, 1))
	assert(outgoing.add_item(rounds, 1) == 1)
	assert(not press.call("can_demolish_safely"))
	assert(outgoing.remove_item(rounds, 1))
	assert(press.call("can_demolish_safely"))
	print("PASS F: Recipe input and both inventories are protected from demolition")

	var source_belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	var destination_belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(source_belt != null and destination_belt != null)
	add_child(source_belt)
	add_child(destination_belt)
	var input_port := press.get_node("InputPort") as ItemPortComponent
	var output_port := press.get_node("OutputPort") as ItemPortComponent
	var source_preview := ConveyorBuildingSnap.get_preview_transform(
		input_port, source_belt
	)
	var destination_preview := ConveyorBuildingSnap.get_preview_transform(
		output_port, destination_belt
	)
	assert(source_preview.has("transform") and destination_preview.has("transform"))
	source_belt.global_transform = source_preview["transform"]
	destination_belt.global_transform = destination_preview["transform"]
	assert(source_belt.try_connect_building_port(input_port))
	assert(destination_belt.try_connect_building_port(output_port))
	assert(input_port.connected_conveyor == source_belt)
	assert(output_port.connected_conveyor == destination_belt)
	print("PASS G: Both ammunition press ports connect to normal conveyors")

	press.queue_free()
	await get_tree().process_frame
	assert(not is_instance_valid(source_belt.output_building_port))
	assert(not is_instance_valid(destination_belt.input_building_port))
	assert(source_belt.is_inside_tree() and destination_belt.is_inside_tree())
	print("PASS H: Removing the empty press safely releases both belt links")

	_press_key(controller, KEY_7)
	assert(controller.selected_building_index == 6)
	assert(building_7_label.modulate == hud.selected_color)
	assert(building_8_label.modulate == hud.normal_color)
	_press_key(controller, KEY_8)
	assert(controller.selected_building_index == 7)
	print("PASS I: Switching between existing slot 7 and new slot 8 works")

	controller._toggle_placement_mode()
	source_belt.queue_free()
	destination_belt.queue_free()
	world.queue_free()
	print("====================================================")
	print("ALL 9 AMMUNITION PRESS BUILD MODE TESTS PASSED")
	print("====================================================")
