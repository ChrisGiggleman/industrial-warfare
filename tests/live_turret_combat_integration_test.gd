extends Node

# =============================================================================
# PLAYER-WORLD TURRET AND STATIONARY TARGET INTEGRATION TEST
# =============================================================================

# Uses the actual Main scene and build slot 9's PackedScene.
# Disables timer/process callbacks for deterministic assertions.
# The standalone dummy is static, and hits are instant for this checkpoint.


func _deliver_round(
	supply: InventoryComponent,
	belt: ConveyorSegment,
	rounds: ItemDefinition
) -> void:
	var transport := (
		belt.get_node("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(transport != null and timer != null)
	assert(transport.try_receive_from_inventory(supply, rounds))
	assert(timer.advance_transport(1.01))


func _ready() -> void:
	print("\n===== LIVE TURRET COMBAT INTEGRATION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	var rounds := load("res://data/items/prototype_ammunition.tres") as ItemDefinition
	assert(main_scene != null and rounds != null)
	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var dummy := world.get_node_or_null("PrototypeZombieTarget") as Node3D
	assert(dummy != null)
	assert(dummy.is_in_group("hostile_targets"))
	assert(dummy.global_position.distance_to(Vector3(-6, 0, -6)) < 0.01)
	var health := dummy.get_node("HealthComponent") as CombatHealthComponent
	assert(health != null and health.current_health == 30)
	print("PASS A: Main world contains a stationary, 30-HP hostile dummy")

	var interaction := world.get_node("WorldInteraction")
	var definitions: Array[BuildingDefinition] = interaction.buildable_definitions
	assert(definitions.size() == 9)
	assert(definitions[8].building_id == &"prototype_defensive_turret")
	var building := definitions[8].building_scene.instantiate() as Node3D
	assert(building != null)
	world.add_child(building)
	(building.get_node("BuildingRuntime") as BuildingRuntime).initialize(
		definitions[8]
	)
	var turret := building.get_node("TurretComponent") as DefensiveTurretComponent
	var targeting := building.get_node("TargetingComponent") as TurretTargetingComponent
	var magazine := building.get_node("AmmunitionInventory") as InventoryComponent
	var port := building.get_node("InputPort") as TurretAmmunitionPort
	assert(turret != null and targeting != null and magazine != null and port != null)
	assert(targeting.turret == turret)
	assert(targeting.detection_range == 7.0)
	assert(targeting.shot_damage == 10)
	turret.set_process(false)
	targeting.set_process(false)
	assert(targeting.automatic_fire_enabled)
	print("PASS B: Slot 9 turret owns a correctly wired automatic targeting component")

	# The turret is initially at origin. Our dummy is farther than 7 units.
	targeting._process(0.01)
	assert(targeting.current_target == null)
	assert(targeting.find_nearest_target() == null)
	assert(turret.shots_fired == 0 and health.current_health == 30)
	print("PASS C: Existing factory center is safely outside dummy detection range")

	# Place the turret within four horizontal units of the dummy.
	building.global_position = Vector3(-6, 0, -2)
	assert(targeting.find_nearest_target() == dummy)
	targeting._process(0.01)
	assert(targeting.current_target == dummy)
	assert(turret.shots_fired == 0)
	assert(health.current_health == 30)
	print("PASS D: Nearby enemy is acquired but no-ammo turret cannot fire")

	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	world.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	var preview := ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))
	assert(port.connected_conveyor == belt)
	print("PASS E: A real conveyor physically attaches to the live turret input")

	var supply := InventoryComponent.new()
	supply.max_capacity = 5
	world.add_child(supply)
	assert(supply.add_item(rounds, 3) == 3)
	_deliver_round(supply, belt, rounds)
	assert(magazine.get_amount(rounds) == 1)
	targeting._process(0.01)
	assert(turret.shots_fired == 1)
	assert(health.current_health == 20)
	assert(magazine.get_amount(rounds) == 0)
	print("PASS F: Conveyor-fed turret automatically fires one round for 10 damage")

	targeting._process(0.01)
	assert(turret.shots_fired == 1)
	assert(health.current_health == 20)
	assert(targeting.confirmed_hits == 1)
	print("PASS G: Cooldown and empty magazine prevent phantom damage")

	turret._process(1.01)
	_deliver_round(supply, belt, rounds)
	targeting._process(0.01)
	assert(turret.shots_fired == 2 and health.current_health == 10)
	turret._process(1.01)
	_deliver_round(supply, belt, rounds)
	targeting._process(0.01)
	assert(turret.shots_fired == 3)
	assert(health.current_health == 0)
	assert(targeting.confirmed_hits == 3)
	assert(targeting.confirmed_kills == 1)
	assert(supply.get_amount(rounds) == 0)
	assert(magazine.get_amount(rounds) == 0)
	print("PASS H: Three delivered rounds defeat the dummy without losing ammo")

	targeting._process(0.01)
	assert(targeting.current_target == null)
	assert(targeting.find_nearest_target() == null)
	dummy.call("_process", 0.01)
	assert((dummy.get_node("HealthLabel") as Label3D).text == "TARGET DEFEATED")
	print("PASS I: Dead target is ignored and visibly marked defeated")

	var debug_hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	debug_hud.set_selected_building(building)
	var info := debug_hud.info_label
	assert(info != null)
	assert(info.text.contains("Combat: Auto targeting"))
	assert(info.text.contains("Fired Shots: 3"))
	assert(info.text.contains("Hits: 3"))
	assert(info.text.contains("Targets Defeated: 1"))
	assert(info.text.contains("Target: None"))
	print("PASS J: Main-game production HUD reports real automatic combat totals")

	assert(building.call("can_demolish_safely"))
	building.queue_free()
	await get_tree().process_frame
	assert(belt.is_inside_tree())
	assert(not is_instance_valid(belt.output_building_port))
	print("PASS K: Empty defeated-target turret removes without breaking conveyor")

	debug_hud.clear_selection()
	world.queue_free()
	print("================================================")
	print("ALL 11 LIVE TURRET COMBAT INTEGRATION TESTS PASSED")
	print("================================================")
