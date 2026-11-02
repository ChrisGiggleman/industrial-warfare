extends Node

# =============================================================================
# LIVE ZOMBIE MELEE — MAIN SCENE INTEGRATION REGRESSION
# =============================================================================

# Instantiates the real Main world with its live moving zombie and
# default 100-HP structures. Physics is advanced manually so hits,
# range and cooldown assertions remain deterministic.
# Zero HP is non-destructive: inventories and physical ports remain.


func _make_storage(
	world: Node3D,
	definition: BuildingDefinition,
	position: Vector3
) -> Node3D:
	var building := definition.building_scene.instantiate() as Node3D
	assert(building != null)
	world.add_child(building)
	building.global_position = position
	var runtime := building.get_node("BuildingRuntime") as BuildingRuntime
	assert(runtime != null)
	runtime.initialize(definition)
	return building


func _ready() -> void:
	print("\n===== LIVE ZOMBIE BUILDING MELEE INTEGRATION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	var rounds := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(main_scene != null and rounds != null)

	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)
	# Historical regression explicitly verifies the non-destructive
	# zero-HP fixture; the new live destruction path has its own suite.
	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	assert(service != null)
	service.destroy_on_zero_hp = false

	var moving := world.get_node("PrototypeMovingZombie") as Node3D
	var stationary := world.get_node("PrototypeZombieTarget") as Node3D
	assert(moving != null and stationary != null)
	var movement := moving.get_node(
		"MovementComponent"
	) as ZombieApproachComponent
	var melee := moving.get_node("MeleeComponent") as ZombieMeleeComponent
	var zombie_hp := moving.get_node(
		"HealthComponent"
	) as CombatHealthComponent
	var static_hp := stationary.get_node(
		"HealthComponent"
	) as CombatHealthComponent
	assert(
		movement != null and melee != null
		and zombie_hp != null and static_hp != null
	)
	assert(melee.movement == movement)
	assert(melee.attack_damage == 10)
	assert(is_equal_approx(melee.attack_interval, 1.0))
	assert(zombie_hp.current_health == 30)
	movement.set_physics_process(false)
	melee.set_physics_process(false)
	print("PASS A: Main zombie has correctly wired live melee; static dummy retained")

	melee._physics_process(1.0)
	assert(melee.attacks_landed == 0)
	assert(melee.attack_status == "No Structure")
	assert(movement.find_nearest_structure() == null)
	print("PASS B: Empty Main world gives zombie no attackable structure")

	var controller = world.get_node("WorldInteraction")
	var definitions: Array[BuildingDefinition] = controller.buildable_definitions
	assert(definitions.size() == 9)
	var ghost := _make_storage(
		world, definitions[2], Vector3(8, 0, -6)
	)
	ghost.add_to_group("construction_preview")
	var idle_belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(idle_belt != null)
	world.add_child(idle_belt)
	idle_belt.global_position = Vector3(8, 0, -6)
	assert(movement.find_nearest_structure() == null)
	movement._physics_process(0.25)
	melee._physics_process(0.25)
	assert(melee.attacks_landed == 0)
	print("PASS C: Construction ghost and conveyor cannot draw melee attacks")

	var storage := _make_storage(
		world, definitions[2], Vector3(8, 0, -2)
	)
	var hp := storage.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var inventory := storage.get_node(
		"InventoryComponent"
	) as InventoryComponent
	var output_port := storage.get_node(
		"OutputPort"
	) as ItemPortComponent
	assert(hp != null and inventory != null and output_port != null)
	assert(hp.current_health == 100)
	assert(inventory.add_item(rounds, 7) == 7)

	var connected_belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(connected_belt != null)
	world.add_child(connected_belt)
	var snap := ConveyorBuildingSnap.get_preview_transform(
		output_port, connected_belt
	)
	assert(snap.has("transform"))
	connected_belt.global_transform = snap["transform"]
	assert(connected_belt.try_connect_building_port(output_port))
	assert(connected_belt.input_building_port == output_port)
	assert(output_port.connected_conveyor == connected_belt)
	print("PASS D: Live 100-HP Storage holds seven rounds and a physical belt link")

	assert(movement.find_nearest_structure() == storage)
	movement._physics_process(1.0)
	assert(movement.movement_status == "Approaching")
	melee._physics_process(0.1)
	assert(melee.attack_status == "Approaching")
	assert(hp.current_health == 100)
	assert(melee.attacks_landed == 0)
	print("PASS E: Zombie approaches Storage but cannot hit outside melee range")

	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	assert(
		moving.global_position.distance_to(storage.global_position)
		<= movement.stopping_distance + 0.001
	)
	melee._physics_process(0.01)
	assert(hp.current_health == 90)
	assert(melee.attacks_landed == 1)
	assert(melee.total_damage_dealt == 10)
	print("PASS F: Zombie reaching storage deals one authorized 10-HP hit")

	melee._physics_process(0.5)
	assert(melee.attack_status == "Cooldown")
	assert(hp.current_health == 90)
	melee._physics_process(0.49)
	assert(hp.current_health == 90)
	assert(melee.attacks_landed == 1)
	print("PASS G: Melee cooldown blocks duplicate structure damage")

	# The first hit removed 10 HP; nine more exactly disable Storage.
	for remaining_health: int in [80, 70, 60, 50, 40, 30, 20, 10, 0]:
		melee._physics_process(1.01)
		assert(hp.current_health == remaining_health)
	assert(melee.attacks_landed == 10)
	assert(melee.total_damage_dealt == 100)
	assert(not hp.is_intact())
	assert(hp.take_damage(10) == 0)
	print("PASS H: Ten attacks exhaust 100 HP with no extra overkill")

	assert(storage.is_inside_tree())
	assert(inventory.get_amount(rounds) == 7)
	assert(output_port.connected_conveyor == connected_belt)
	assert(connected_belt.input_building_port == output_port)
	var hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	hud.set_selected_building(storage)
	assert(hud.info_label.text.contains("Prototype Rounds: 7"))
	assert(hud.info_label.text.contains("HP: 0 / 100"))
	assert(hud.info_label.text.contains("Status: Disabled"))
	print("PASS I: Zero-HP Storage retains items, belt links, and HUD status")

	var backup := _make_storage(
		world, definitions[2], Vector3(13, 0, -2)
	)
	var backup_hp := backup.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	assert(backup_hp.current_health == 100)
	movement._physics_process(0.1)
	assert(movement.current_target == backup)
	assert(movement.find_nearest_structure() == backup)
	assert(movement.movement_status == "Approaching")
	melee._physics_process(0.1)
	assert(backup_hp.current_health == 100)
	assert(hp.current_health == 0)
	print("PASS J: Disabled factory is skipped and second building approached")

	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(1.01)
	assert(backup_hp.current_health == 90)
	assert(melee.attacks_landed == 11)
	assert(hp.current_health == 0)
	print("PASS K: Zombie can attack a second intact factory building")

	var defeated_at: Vector3 = moving.global_position
	assert(zombie_hp.take_damage(30) == 30)
	movement._physics_process(3.0)
	melee._physics_process(3.0)
	assert(movement.movement_status == "Defeated")
	assert(melee.attack_status == "Defeated")
	assert(moving.global_position == defeated_at)
	assert(backup_hp.current_health == 90)
	assert(static_hp.current_health == 30)
	assert(melee.attacks_landed == 11)
	hud.set_selected_building(backup)
	assert(hud.info_label.text.contains("HP: 90 / 100"))
	print("PASS L: Defeated zombie stops; second structure and dummy preserved")

	hud.clear_selection()
	world.queue_free()
	print("================================================")
	print("ALL 12 LIVE ZOMBIE MELEE INTEGRATION TESTS PASSED")
	print("================================================")
