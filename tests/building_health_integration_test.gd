extends Node

# =============================================================================
# PLAYER BUILDING HEALTH AND PRODUCTION HUD REGRESSION
# =============================================================================

# Uses every real Build Mode definition. The nine build slots include
# one ordinary conveyor belt (no HP) and eight durable structures.
# Zombie melee is not installed in Main during this checkpoint.


func _ready() -> void:
	print("\n===== BUILDING HEALTH INTEGRATION REGRESSION =====")

	var main := load("res://scenes/core/main.tscn") as PackedScene
	var rounds := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(main != null and rounds != null)

	var world := main.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	var hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	assert(controller != null and hud != null)
	var definitions: Array[BuildingDefinition] = controller.buildable_definitions
	assert(definitions.size() == 9)
	print("PASS A: All nine existing construction slots remain registered")

	var created: Array[Node3D] = []
	var storage: Node3D = null
	var turret: Node3D = null

	for i: int in range(definitions.size()):
		var definition := definitions[i]
		assert(definition != null and definition.building_scene != null)
		var building := definition.building_scene.instantiate() as Node3D
		assert(building != null)
		world.add_child(building)
		building.global_position = Vector3(24 + 5 * i, 0, 24)
		created.append(building)

		if i == 4:
			assert(building is ConveyorSegment)
			assert(building.get_node_or_null("BuildingHealthComponent") == null)
			continue

		var durability := building.get_node_or_null(
			"BuildingHealthComponent"
		) as BuildingHealthComponent
		var runtime := building.get_node("BuildingRuntime") as BuildingRuntime
		assert(runtime != null and durability != null)
		runtime.initialize(definition)
		assert(durability.max_health == 100)
		assert(durability.current_health == 100)
		assert(durability.total_damage_taken == 0)

		var health_count: int = 0
		for child: Node in building.get_children():
			if child is BuildingHealthComponent:
				health_count += 1
		assert(health_count == 1)

		hud.set_selected_building(building)
		assert(hud.info_label.text.contains("BUILDING DURABILITY"))
		assert(hud.info_label.text.contains("HP: 100 / 100"))
		assert(hud.info_label.text.contains("Status: Intact"))

		if i == 2:
			storage = building
		if i == 8:
			turret = building

	assert(created.size() == 9)
	print("PASS B: Every non-belt building has exactly one initialized 100-HP component")
	print("PASS C: Normal conveyors remain separate from building durability")
	print("PASS D: All eight production/debug views display intact HP correctly")

	assert(storage != null and turret != null)
	var store_hp := storage.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var inventory := storage.get_node(
		"InventoryComponent"
	) as InventoryComponent
	assert(inventory.add_item(rounds, 7) == 7)
	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(belt != null)
	world.add_child(belt)
	belt.global_position = Vector3(100, 0, 100)
	var port := storage.get_node("OutputPort") as ItemPortComponent
	var preview := ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))
	assert(port.connected_conveyor == belt)
	print("PASS E: Stocked Storage retains its normal conveyor output link")

	assert(store_hp.take_damage(10) == 10)
	assert(store_hp.current_health == 90)
	assert(store_hp.total_damage_taken == 10)
	hud.set_selected_building(storage)
	assert(hud.info_label.text.contains("HP: 90 / 100"))
	assert(hud.info_label.text.contains("Status: Intact"))
	assert(hud.info_label.text.contains("Prototype Rounds: 7"))
	print("PASS F: Damage updates Storage HP display without losing inventory data")

	assert(store_hp.take_damage(200) == 90)
	assert(store_hp.current_health == 0)
	assert(store_hp.total_damage_taken == 100)
	assert(not store_hp.is_intact())
	assert(store_hp.take_damage(1) == 0)
	assert(inventory.get_amount(rounds) == 7)
	assert(port.connected_conveyor == belt)
	assert(belt.input_building_port == port)
	assert(storage.is_inside_tree())
	hud._refresh_display()
	assert(hud.info_label.text.contains("HP: 0 / 100"))
	assert(hud.info_label.text.contains("Status: Disabled"))
	print("PASS G: Zero HP disables Storage but keeps stock and both port references")

	var zombie_scene := load(
		"res://scenes/enemies/prototype_moving_zombie.tscn"
	) as PackedScene
	assert(zombie_scene != null)
	var zombie := zombie_scene.instantiate() as Node3D
	world.add_child(zombie)
	zombie.global_position = Vector3(50, 0, 22)
	var movement := zombie.get_node("MovementComponent") as ZombieApproachComponent
	assert(movement != null)
	movement.set_physics_process(false)

	# No other building is near this zombie except the storage and turret
	# test instances; the selector must skip the disabled Storage even when
	# it is directly under the zombie.
	zombie.global_position = storage.global_position
	assert(movement.find_nearest_structure() != storage)
	print("PASS H: Zombies ignore disabled Storage when searching for another target")

	var turret_hp := turret.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var magazine := turret.get_node(
		"AmmunitionInventory"
	) as InventoryComponent
	assert(magazine.add_item(rounds, 3) == 3)
	assert(turret_hp.take_damage(50) == 50)
	hud.set_selected_building(turret)
	assert(hud.info_label.text.contains("Ammunition: 3 / 40"))
	assert(hud.info_label.text.contains("HP: 50 / 100"))
	assert(hud.info_label.text.contains("Status: Intact"))
	print("PASS I: Turret magazine and combat HUD coexist with durability data")

	assert(turret_hp.take_damage(100) == 50)
	assert(turret_hp.current_health == 0)
	assert(magazine.get_amount(rounds) == 3)
	assert(not turret.call("can_demolish_safely"))
	hud._refresh_display()
	assert(hud.info_label.text.contains("Status: Disabled"))
	print("PASS J: Disabling a loaded turret does not erase ammunition or bypass demolition safety")

	var ghost := definitions[2].building_scene.instantiate() as Node3D
	ghost.add_to_group("construction_preview")
	world.add_child(ghost)
	ghost.global_position = zombie.global_position + Vector3(0.5, 0, 0)
	assert(movement.find_nearest_structure() != ghost)
	print("PASS K: Healthy construction previews remain excluded from zombie targeting")

	hud.clear_selection()
	world.queue_free()
	print("================================================")
	print("ALL 11 BUILDING HEALTH INTEGRATION TESTS PASSED")
	print("================================================")
