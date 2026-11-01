extends Node

# =============================================================================
# DEFENSIVE TURRET — PLAYER BUILD MODE REGRESSION
# =============================================================================

# Exercises the real Main scene, HUD and selected-building logic.
# Simulated shots are invoked only by this test: gameplay has no
# target acquisition, projectiles or automatic firing yet.

func _press_key(controller: Node, key: Key) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.echo = false
	event.keycode = key
	event.physical_keycode = key
	controller.call("_unhandled_input", event)


func _ready() -> void:
	print("\n===== DEFENSIVE TURRET BUILD MODE REGRESSION =====")
	var scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(scene != null)
	var world := scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	var hud = world.get_node("BuildHUD")
	var debug_hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	assert(controller != null and hud != null and debug_hud != null)

	var defs: Array[BuildingDefinition] = controller.buildable_definitions
	assert(defs.size() == 9)
	assert(defs[6].building_id == &"conveyor_splitter")
	assert(defs[7].building_id == &"prototype_ammunition_press")
	assert(defs[8].building_id == &"prototype_defensive_turret")
	assert(defs[8].footprint_tiles == Vector2i.ONE)
	print("PASS A: Existing eight slots retained; defensive turret occupies slot 9")

	controller._toggle_placement_mode()
	assert(controller.placement_mode_active)
	_press_key(controller, KEY_9)
	assert(controller.selected_building_index == 8)
	assert(controller._get_selected_building_definition() == defs[8])
	assert(is_instance_valid(controller.placement_ghost))
	assert(controller.placement_ghost.name.begins_with("PrototypeDefensiveTurret"))
	print("PASS B: Key 9 selects the new defensive turret construction ghost")

	var label9 := hud.get_node(
		"BuildPanel/PanelMargin/BuildInfo/Building9Label"
	) as Label
	var label8 := hud.get_node(
		"BuildPanel/PanelMargin/BuildInfo/Building8Label"
	) as Label
	assert(label9 != null and label8 != null)
	assert(label9.text == "> [9] Defensive Turret")
	assert(label9.modulate == hud.selected_color)
	assert(label8.modulate == hud.normal_color)
	print("PASS C: HUD highlights turret slot 9 without altering slot 8")

	_press_key(controller, KEY_R)
	assert(is_equal_approx(controller.placement_rotation_degrees, 90.0))
	assert(is_equal_approx(controller.placement_ghost.rotation_degrees.y, 90.0))
	print("PASS D: Turret supports 90-degree placement rotation")

	var turret_building := defs[8].building_scene.instantiate() as Node3D
	assert(turret_building != null)
	add_child(turret_building)
	var runtime := turret_building.get_node("BuildingRuntime") as BuildingRuntime
	assert(runtime != null)
	runtime.initialize(defs[8])
	var input_port := turret_building.get_node("InputPort") as TurretAmmunitionPort
	assert(input_port != null)

	for quarter: int in range(4):
		var footprint := FactoryGrid.rotated_footprint(
			defs[8].footprint_tiles, quarter
		)
		var center := FactoryGrid.snap_building_origin(
			Vector3(2.3, 0.0, 4.6), footprint
		)
		turret_building.global_transform = Transform3D(
			Basis(Vector3.UP, quarter * PI / 2.0), center
		)
		var port_forward := (
			input_port.global_transform.basis * Vector3.FORWARD
		).normalized()
		var belt_center := (
			input_port.global_position
			+ port_forward * FactoryGrid.CELL_SIZE * 0.5
			- Vector3.UP * FactoryGrid.PORT_HEIGHT
		)
		assert(FactoryGrid.is_on_conveyor_grid(belt_center))
	print("PASS E: Turret input port remains on conveyor grid for every rotation")

	turret_building.global_transform = Transform3D.IDENTITY
	var magazine := turret_building.get_node(
		"AmmunitionInventory"
	) as InventoryComponent
	var component := turret_building.get_node(
		"TurretComponent"
	) as DefensiveTurretComponent
	var rounds := load("res://data/items/prototype_ammunition.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(magazine != null and component != null)
	assert(rounds != null and ingot != null)
	component.set_process(false)
	assert(magazine.max_capacity == 40)
	assert(input_port.can_accept_item(rounds, 1))
	assert(not input_port.can_accept_item(ingot, 1))
	assert(turret_building.call("can_demolish_safely"))
	print("PASS F: Magazine accepts only ammo and empty turret is demolishable")

	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	assert(timer != null and transport != null)
	timer.set_process(false)
	var preview := ConveyorBuildingSnap.get_preview_transform(input_port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(input_port))
	assert(belt.output_building_port == input_port)
	assert(input_port.connected_conveyor == belt)
	print("PASS G: Ordinary conveyor attaches to turret's physical ammunition port")

	var supply := InventoryComponent.new()
	supply.max_capacity = 5
	add_child(supply)
	assert(supply.add_item(rounds, 2) == 2)
	assert(transport.try_receive_from_inventory(supply, rounds))
	assert(timer.advance_transport(1.01))
	assert(magazine.get_amount(rounds) == 1)
	assert(not turret_building.call("can_demolish_safely"))
	print("PASS H: Belt delivers ammo and a loaded turret blocks demolition")

	debug_hud.set_selected_building(turret_building)
	var info := debug_hud.info_label
	assert(info != null)
	assert(info.text.contains("Defensive Turret"))
	assert(info.text.contains("Ammunition: 1 / 40"))
	assert(info.text.contains("Ammo Conveyor: Connected"))
	assert(info.text.contains("Status: Ready"))
	assert(info.text.contains("Combat: Targeting not implemented"))
	print("PASS I: Production Debug HUD shows ammo, connection, and ready state")

	assert(component.try_fire())
	debug_hud._refresh_display()
	assert(info.text.contains("Ammunition: 0 / 40"))
	assert(info.text.contains("Fired Shots: 1"))
	assert(info.text.contains("Status: Cooldown"))
	assert(magazine.get_amount(rounds) == 0)
	print("PASS J: Controlled firing consumes one round and updates turret HUD")

	turret_building.queue_free()
	await get_tree().process_frame
	assert(not is_instance_valid(belt.output_building_port))
	assert(belt.is_inside_tree())
	print("PASS K: Removing empty turret releases conveyor without deleting it")

	_press_key(controller, KEY_8)
	assert(controller.selected_building_index == 7)
	assert(label8.modulate == hud.selected_color)
	_press_key(controller, KEY_9)
	assert(controller.selected_building_index == 8)
	assert(label9.modulate == hud.selected_color)
	print("PASS L: Switching between slot 8 and slot 9 updates selections")

	debug_hud.clear_selection()
	controller._toggle_placement_mode()
	belt.queue_free()
	supply.queue_free()
	world.queue_free()
	print("================================================")
	print("ALL 12 DEFENSIVE TURRET BUILD MODE TESTS PASSED")
	print("================================================")
