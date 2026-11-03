extends Node

# =============================================================================
# CONVEYOR TOOL IDENTITY — CUSTOM HOTBAR MIGRATION REGRESSION
# =============================================================================

# Phase 1G2: verify conveyor tools use BuildingDefinition.building_id,
# not a fixed definition array index. Catalog reordering happens ONLY
# in the temporary Main test instance, never in scenes/core/main.tscn.
# Number-key remapping and the dynamic Build HUD are later steps.


func _ready() -> void:
	print("\n===== CONVEYOR TOOL BUILDING IDENTITY REGRESSION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	assert(controller != null)
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	assert(zombie != null)
	(zombie.get_node(
		"MovementComponent"
	) as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node(
		"MeleeComponent"
	) as ZombieMeleeComponent).set_physics_process(false)

	var original: Array[BuildingDefinition] = (
		controller.buildable_definitions.duplicate()
	)
	assert(original.size() == 9)
	assert(original[4].building_id == &"conveyor_belt")
	assert(original[0].building_id == &"test_extractor")
	assert(not controller._is_conveyor_selected())
	print("PASS A: Main keeps nine stable IDs and the original default belt slot")

	controller._toggle_placement_mode()
	assert(controller.placement_mode_active)
	controller._select_building(4)
	assert(controller.selected_building_index == 4)
	assert(controller._is_conveyor_selected())
	assert(controller._get_selected_building_definition() == original[4])
	assert(controller.placement_ghost is ConveyorSegment)
	assert(
		controller.conveyor_preview_scene
		== ConveyorPieceSelector.STRAIGHT_SCENE
	)
	print("PASS B: Default key-5 definition still creates a straight belt ghost")

	controller._create_placement_ghost(
		ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(controller.placement_ghost is ConveyorSegment)
	assert(
		controller.conveyor_preview_scene
		== ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(controller.placement_ghost.is_in_group("construction_preview"))
	assert(
		controller.placement_ghost.process_mode
		== Node.PROCESS_MODE_DISABLED
	)
	print("PASS C: Conveyor identity authorizes the right-corner ghost override")

	controller._create_placement_ghost(
		ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	assert(controller.placement_ghost is ConveyorSegment)
	assert(
		controller.conveyor_preview_scene
		== ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	print("PASS D: Conveyor identity authorizes the left-corner ghost override")

	controller._select_building(8)
	assert(not controller._is_conveyor_selected())
	assert(
		controller._get_selected_building_definition().building_id
		== &"prototype_defensive_turret"
	)
	controller._create_placement_ghost(
		ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(not controller.placement_ghost is ConveyorSegment)
	assert(controller.conveyor_preview_scene == null)
	print("PASS E: Turret selection cannot inherit a belt corner override")

	for original_index: int in range(9):
		controller._select_building(original_index)
		assert(
			controller._is_conveyor_selected() == (original_index == 4)
		)
	print("PASS F: All nine original definition IDs select the proper tool")

	var configuration := BuildHotbarConfiguration.new()
	configuration.configure(original)
	configuration.reset_to_default()
	assert(configuration.get_id(4) == &"conveyor_belt")
	assert(configuration.assign(0, &"conveyor_belt"))
	assert(configuration.get_id(0) == &"conveyor_belt")
	assert(configuration.get_id(4) == &"test_extractor")
	assert(controller.buildable_definitions == original)
	print("PASS G: Standalone hotbar can move belts while Main input stays intact")

	# Simulate a future catalog reorder, without modifying the actual
	# Main scene or any saved building definitions.
	var reordered: Array[BuildingDefinition] = original.duplicate()
	reordered[0] = original[4]
	reordered[4] = original[0]
	controller.buildable_definitions = reordered
	controller._select_building(0)
	assert(controller.selected_building_index == 0)
	assert(controller._is_conveyor_selected())
	assert(
		controller._get_selected_building_definition().building_id
		== &"conveyor_belt"
	)
	assert(controller.placement_ghost is ConveyorSegment)
	assert(
		controller.conveyor_preview_scene
		== ConveyorPieceSelector.STRAIGHT_SCENE
	)
	print("PASS H: Belt selected at definition index 0 still previews straight")

	controller._create_placement_ghost(
		ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(controller._is_conveyor_selected())
	assert(
		controller.conveyor_preview_scene
		== ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	controller._create_placement_ghost(
		ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	assert(
		controller.conveyor_preview_scene
		== ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	print("PASS I: Belt moved to index 0 retains both special corner previews")

	controller._select_building(4)
	assert(controller.selected_building_index == 4)
	assert(not controller._is_conveyor_selected())
	assert(controller._get_selected_building_definition() == original[0])
	assert(not controller.placement_ghost is ConveyorSegment)
	controller._create_placement_ghost(
		ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	assert(not controller.placement_ghost is ConveyorSegment)
	assert(controller.conveyor_preview_scene == null)
	print("PASS J: Former slot 5 now contains Extractor and rejects belt tools")

	controller.selected_building_index = -1
	assert(not controller._is_conveyor_selected())
	assert(controller._get_selected_building_definition() == null)
	controller.selected_building_index = reordered.size()
	assert(not controller._is_conveyor_selected())
	assert(controller._get_selected_building_scene() == null)
	controller.selected_building_index = 4
	assert(not controller._is_conveyor_selected())
	print("PASS K: Invalid definition indices fail safely without conveyor behavior")

	controller.buildable_definitions = original
	controller._select_building(4)
	assert(controller._is_conveyor_selected())
	assert(
		controller._get_selected_building_scene()
		== original[4].building_scene
	)
	assert(controller.placement_ghost is ConveyorSegment)
	controller._toggle_placement_mode()
	assert(not controller.placement_mode_active)
	assert(not is_instance_valid(controller.placement_ghost))
	assert(controller.buildable_definitions == original)
	print("PASS L: Original catalog and placement cleanup remain unchanged")

	world.queue_free()
	print("================================================")
	print("ALL 12 CONVEYOR BUILDING IDENTITY TESTS PASSED")
	print("================================================")
