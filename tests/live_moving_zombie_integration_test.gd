extends Node

# =============================================================================
# MAIN-WORLD MOVING ZOMBIE — FACTORY APPROACH AND DEFENSE REGRESSION
# =============================================================================

# Loads the real Main scene and validates the newly placed moving enemy.
# Movement, turret cooldown, targeting and conveyor transport are advanced
# explicitly to avoid timing-sensitive assertions.
# This test does not implement pathfinding or zombie building attacks.


func _deliver_ammunition(
	source: InventoryComponent,
	belt: ConveyorSegment,
	rounds: ItemDefinition
) -> void:
	var transport := (
		belt.get_node("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(transport != null and timer != null)
	assert(transport.try_receive_from_inventory(source, rounds))
	assert(timer.advance_transport(1.01))


func _ready() -> void:
	print("\n===== LIVE MOVING ZOMBIE INTEGRATION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(main_scene != null and storage_scene != null and ammo != null)

	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)
	var moving := world.get_node_or_null("PrototypeMovingZombie") as Node3D
	var stationary := world.get_node_or_null("PrototypeZombieTarget") as Node3D
	assert(moving != null and stationary != null)
	assert(moving != stationary)
	assert(moving.is_in_group("hostile_targets"))
	assert(stationary.is_in_group("hostile_targets"))
	assert(moving.global_position.distance_to(Vector3(8, 0, -7)) < 0.01)
	assert(stationary.global_position.distance_to(Vector3(-6, 0, -6)) < 0.01)
	print("PASS A: Moving zombie added to Main; original static dummy retained")

	var movement := moving.get_node("MovementComponent") as ZombieApproachComponent
	var health := moving.get_node("HealthComponent") as CombatHealthComponent
	var static_health := (
		stationary.get_node("HealthComponent") as CombatHealthComponent
	)
	assert(movement != null and health != null and static_health != null)
	movement.set_physics_process(false)
	assert(health.current_health == 30 and static_health.current_health == 30)
	assert(movement.find_nearest_structure() == null)
	movement._physics_process(1.0)
	assert(moving.global_position.distance_to(Vector3(8, 0, -7)) < 0.001)
	assert(movement.movement_status == "No Target")
	print("PASS B: Without a built factory the moving enemy stays put")

	var preview := storage_scene.instantiate() as Node3D
	assert(preview != null)
	preview.add_to_group("construction_preview")
	world.add_child(preview)
	preview.global_position = Vector3(8, 0, -4)
	var belt_ignored := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(belt_ignored != null)
	world.add_child(belt_ignored)
	belt_ignored.global_position = Vector3(8, 0, -5)
	assert(movement.find_nearest_structure() == null)
	movement._physics_process(1.0)
	assert(moving.global_position.distance_to(Vector3(8, 0, -7)) < 0.001)
	print("PASS C: Main-scene construction ghost and loose belt are ignored")

	var storage := storage_scene.instantiate() as Node3D
	assert(storage != null)
	world.add_child(storage)
	storage.global_position = Vector3(8, 0, -2)
	assert(movement.find_nearest_structure() == storage)
	movement._physics_process(1.0)
	assert(movement.current_target == storage)
	assert(moving.global_position.distance_to(Vector3(8, 0, -5)) < 0.001)
	assert(movement.movement_status == "Approaching")
	print("PASS D: Live enemy follows the first player-built storage at 2 units/s")

	movement._physics_process(10.0)
	assert(moving.global_position.distance_to(Vector3(8, 0, -3.5)) < 0.001)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	assert(is_equal_approx(moving.global_position.y, 0.0))
	print("PASS E: Movement stops exactly 1.5 units short of storage")

	storage.queue_free()
	await get_tree().process_frame
	movement._physics_process(0.1)
	assert(movement.current_target == null)
	assert(movement.movement_status == "No Target")

	var interaction = world.get_node("WorldInteraction")
	var definitions: Array[BuildingDefinition] = interaction.buildable_definitions
	assert(definitions.size() == 9)
	var turret_building := (
		definitions[8].building_scene.instantiate() as Node3D
	)
	assert(turret_building != null)
	world.add_child(turret_building)
	turret_building.global_position = Vector3(6, 0, -3)
	(
		turret_building.get_node("BuildingRuntime") as BuildingRuntime
	).initialize(definitions[8])

	movement._physics_process(1.0)
	assert(movement.current_target == turret_building)
	assert(
		moving.global_position.distance_to(turret_building.global_position)
		<= movement.stopping_distance + 0.001
	)
	assert(movement.movement_status == "Approaching")
	print("PASS F: Enemy reacquires a placed turret after storage removal")

	var turret := (
		turret_building.get_node("TurretComponent") as DefensiveTurretComponent
	)
	var targeting := (
		turret_building.get_node("TargetingComponent") as TurretTargetingComponent
	)
	var magazine := (
		turret_building.get_node("AmmunitionInventory") as InventoryComponent
	)
	var port := (
		turret_building.get_node("InputPort") as TurretAmmunitionPort
	)
	assert(
		turret != null and targeting != null
		and magazine != null and port != null
	)
	turret.set_process(false)
	targeting.set_process(false)
	assert(targeting.find_nearest_target() == moving)
	targeting._process(0.01)
	assert(turret.shots_fired == 0 and health.current_health == 30)
	print("PASS G: Live turret finds moving hostile but cannot fire without ammo")

	var feeder := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(feeder != null)
	world.add_child(feeder)
	var feeder_timer := (
		feeder.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	)
	assert(feeder_timer != null)
	feeder_timer.set_process(false)
	var snap := ConveyorBuildingSnap.get_preview_transform(port, feeder)
	assert(snap.has("transform"))
	feeder.global_transform = snap["transform"]
	assert(feeder.try_connect_building_port(port))
	assert(port.connected_conveyor == feeder)
	print("PASS H: Physical ammunition conveyor connects to turret in Main")

	var supply := InventoryComponent.new()
	supply.max_capacity = 5
	world.add_child(supply)
	assert(supply.add_item(ammo, 3) == 3)
	_deliver_ammunition(supply, feeder, ammo)
	assert(magazine.get_amount(ammo) == 1)
	targeting._process(0.01)
	assert(turret.shots_fired == 1)
	assert(health.current_health == 20)
	assert(magazine.get_amount(ammo) == 0)
	print("PASS I: One supplied round fires and damages the moving enemy")

	targeting._process(0.01)
	assert(turret.shots_fired == 1 and health.current_health == 20)
	for expected_health: int in [10, 0]:
		turret._process(1.01)
		_deliver_ammunition(supply, feeder, ammo)
		targeting._process(0.01)
		assert(health.current_health == expected_health)
	assert(turret.shots_fired == 3 and targeting.confirmed_hits == 3)
	assert(targeting.confirmed_kills == 1)
	assert(supply.get_amount(ammo) == 0)
	assert(magazine.get_amount(ammo) == 0)
	print("PASS J: Three ammo-fed hits defeat moving enemy without duplication")

	var dead_position: Vector3 = moving.global_position
	movement._physics_process(3.0)
	assert(movement.movement_status == "Defeated")
	assert(moving.global_position == dead_position)
	assert(targeting.find_nearest_target() == null)
	moving.call("_process", 0.01)
	assert(
		(moving.get_node("HealthLabel") as Label3D).text
		== "TARGET DEFEATED"
	)
	assert(static_health.current_health == 30)
	print("PASS K: Defeated zombie stops; original stationary target is unharmed")

	var hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	hud.set_selected_building(turret_building)
	assert(hud.info_label.text.contains("Fired Shots: 3"))
	assert(hud.info_label.text.contains("Hits: 3"))
	assert(hud.info_label.text.contains("Targets Defeated: 1"))
	hud.clear_selection()
	assert(turret_building.call("can_demolish_safely"))
	turret_building.queue_free()
	await get_tree().process_frame
	assert(feeder.is_inside_tree())
	assert(not is_instance_valid(feeder.output_building_port))
	print("PASS L: Combat HUD and unloaded turret removal remain correct")

	world.queue_free()
	print("================================================")
	print("ALL 12 LIVE MOVING ZOMBIE INTEGRATION TESTS PASSED")
	print("================================================")
