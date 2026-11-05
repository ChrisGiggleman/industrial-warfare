extends Node

# =============================================================================
# CONFIGURABLE BUILD HOTBAR — LIVE NUMBER KEYS AND HUD REGRESSION
# =============================================================================

# Uses the real Main/WorldInteraction, the original InputMap for 1–5,
# physical keys 6–9 and the actual BuildHUD. All changes are made to
# a local runtime configuration: no saved player preferences or Build
# Catalog UI are introduced in this checkpoint.


func _press_build_key(controller: Node, key: Key) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.echo = false
	event.keycode = key
	event.physical_keycode = key
	controller.call("_unhandled_input", event)


func _slot_label(hud: Node, slot_number: int) -> Label:
	return hud.get_node(
		"BuildPanel/PanelMargin/BuildInfo/Building"
		+ str(slot_number) + "Label"
	) as Label


func _ready() -> void:
	print("\n===== CONFIGURABLE BUILD HOTBAR KEYBOARD INTEGRATION =====")

	var scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(scene != null)
	var world := scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	var hud = world.get_node("BuildHUD")
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	assert(controller != null and hud != null and zombie != null)
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)

	var hotbar: BuildHotbarConfiguration = controller.build_hotbar
	var definitions: Array[BuildingDefinition] = controller.buildable_definitions
	assert(hotbar != null and definitions.size() == 9)
	for slot_index: int in range(9):
		assert(hotbar.get_definition(slot_index) == definitions[slot_index])
	assert(hotbar.get_id(4) == &"conveyor_belt")
	assert(hotbar.get_id(8) == &"prototype_defensive_turret")
	print("PASS A: Main initializes nine legacy-compatible assignments")

	controller._toggle_placement_mode()
	assert(controller.placement_mode_active)
	assert(_slot_label(hud, 1).text == "> [1] Test Extractor")
	assert(_slot_label(hud, 8).text == "  [8] Ammunition Press")
	assert(_slot_label(hud, 9).text == "  [9] Defensive Turret")
	assert(_slot_label(hud, 1).modulate == hud.selected_color)
	print("PASS B: Dynamic HUD retains familiar names, markers and default order")

	_press_build_key(controller, KEY_5)
	assert(controller.selected_building_index == 4)
	assert(controller._is_conveyor_selected())
	assert(controller.placement_ghost is ConveyorSegment)
	assert(_slot_label(hud, 5).text == "> [5] Conveyor Belt")
	assert(_slot_label(hud, 5).modulate == hud.selected_color)
	print("PASS C: Existing key 5 selects Conveyor Belt and highlights slot 5")

	_press_build_key(controller, KEY_9)
	assert(controller.selected_building_index == 8)
	assert(not controller._is_conveyor_selected())
	assert(controller.placement_ghost.name.begins_with("PrototypeDefensiveTurret"))
	assert(_slot_label(hud, 9).text == "> [9] Defensive Turret")
	print("PASS D: Existing key 9 selects Defensive Turret with correct ghost")

	assert(controller.assign_hotbar_slot(0, &"prototype_defensive_turret"))
	assert(hotbar.get_id(0) == &"prototype_defensive_turret")
	assert(hotbar.get_id(8) == &"test_extractor")
	assert(_slot_label(hud, 1).text == "> [1] Defensive Turret")
	assert(_slot_label(hud, 9).text == "  [9] Test Extractor")
	assert(controller.selected_building_index == 8)
	print("PASS E: Assigning Turret to 1 swaps Extractor to 9 without ghost damage")

	_press_build_key(controller, KEY_1)
	assert(controller.selected_building_index == 8)
	assert(controller._get_selected_building_definition().building_id == &"prototype_defensive_turret")
	assert(controller.placement_ghost.name.begins_with("PrototypeDefensiveTurret"))
	assert(_slot_label(hud, 1).modulate == hud.selected_color)
	print("PASS F: Actual key 1 now selects Turret through its stable ID")

	assert(controller.assign_hotbar_slot(8, &"test_storage"))
	assert(hotbar.get_id(8) == &"test_storage")
	assert(hotbar.get_id(2) == &"test_extractor")
	_press_build_key(controller, KEY_9)
	assert(controller.selected_building_index == 2)
	assert(controller._get_selected_building_definition().building_id == &"test_storage")
	assert(_slot_label(hud, 9).text == "> [9] Test Storage")
	assert(_slot_label(hud, 3).text == "  [3] Test Extractor")
	assert(not controller.placement_ghost is ConveyorSegment)
	print("PASS G: Actual key 9 selects Storage and swapped Extractor moves to 3")

	assert(controller.assign_hotbar_slot(3, &"conveyor_belt"))
	assert(hotbar.get_id(3) == &"conveyor_belt")
	assert(hotbar.get_id(4) == &"test_smelter")
	_press_build_key(controller, KEY_4)
	assert(controller.selected_building_index == 4)
	assert(controller._is_conveyor_selected())
	assert(controller.placement_ghost is ConveyorSegment)
	assert(_slot_label(hud, 4).text == "> [4] Conveyor Belt")
	controller._create_placement_ghost(
		ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(controller.conveyor_preview_scene == ConveyorPieceSelector.RIGHT_CORNER_SCENE)
	controller._create_placement_ghost(
		ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	assert(controller.conveyor_preview_scene == ConveyorPieceSelector.LEFT_CORNER_SCENE)
	print("PASS H: Conveyor on key 4 retains straight and both corner previews")

	_press_build_key(controller, KEY_5)
	assert(controller.selected_building_index == 3)
	assert(not controller._is_conveyor_selected())
	assert(controller.placement_ghost is Node3D)
	assert(not controller.placement_ghost is ConveyorSegment)
	assert(_slot_label(hud, 5).text == "> [5] Test Smelter")
	controller._create_placement_ghost(
		ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(not controller.placement_ghost is ConveyorSegment)
	assert(controller.conveyor_preview_scene == null)
	print("PASS I: Former belt key 5 now selects Smelter and rejects belt overrides")

	assert(controller.clear_hotbar_slot(3))
	assert(hotbar.get_definition(3) == null)
	assert(_slot_label(hud, 4).text == "  [4] Empty")
	var prior_selection: int = controller.selected_building_index
	_press_build_key(controller, KEY_4)
	assert(controller.selected_building_index == prior_selection)
	assert(_slot_label(hud, 5).text == "> [5] Test Smelter")
	assert(not controller._is_conveyor_selected())
	print("PASS J: Empty key 4 is inert and its HUD label explicitly says Empty")

	assert(controller.set_hotbar_unlocked(&"test_storage", false))
	assert(not hotbar.is_unlocked(&"test_storage"))
	assert(hotbar.get_id(8) == &"")
	assert(_slot_label(hud, 9).text == "  [9] Empty")
	assert(not controller.assign_hotbar_slot(8, &"test_storage"))
	_press_build_key(controller, KEY_9)
	assert(controller.selected_building_index == prior_selection)
	assert(controller.set_hotbar_unlocked(&"test_storage", true))
	assert(controller.assign_hotbar_slot(8, &"test_storage"))
	_press_build_key(controller, KEY_9)
	assert(controller._get_selected_building_definition().building_id == &"test_storage")
	assert(_slot_label(hud, 9).text == "> [9] Test Storage")
	print("PASS K: Locked building disappears from slot and cannot be selected")

	hotbar.reset_to_default()
	controller._on_hotbar_assignment_changed()
	_press_build_key(controller, KEY_5)
	assert(hotbar.get_id(4) == &"conveyor_belt")
	assert(controller.selected_building_index == 4)
	assert(controller._is_conveyor_selected())
	assert(_slot_label(hud, 5).text == "> [5] Conveyor Belt")
	_press_build_key(controller, KEY_8)
	assert(controller.selected_building_index == 7)
	assert(_slot_label(hud, 8).text == "> [8] Ammunition Press")
	_press_build_key(controller, KEY_9)
	assert(controller.selected_building_index == 8)
	assert(_slot_label(hud, 9).text == "> [9] Defensive Turret")
	controller._toggle_placement_mode()
	assert(not controller.placement_mode_active)
	assert(not is_instance_valid(controller.placement_ghost))
	print("PASS L: Default restoration preserves legacy 5, 8, 9 and mode cleanup")

	world.queue_free()
	print("================================================")
	print("ALL 12 BUILD HOTBAR KEYBOARD INTEGRATION TESTS PASSED")
	print("================================================")
