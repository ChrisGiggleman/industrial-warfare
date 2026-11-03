extends Node

# =============================================================================
# MOVING ZOMBIE APPROACH AND TURRET COMPATIBILITY REGRESSION
# =============================================================================

# No navigation agents, obstacle avoidance, factory damage, or spawning
# are part of this test. Motion is advanced explicitly and checked
# against existing BuildingRuntime structures and ammo-gated turret fire.


func _structure(
	parent: Node3D,
	scene: PackedScene,
	pos: Vector3,
	as_preview: bool = false
) -> Node3D:
	var building := scene.instantiate() as Node3D
	assert(building != null)
	if as_preview:
		building.add_to_group("construction_preview")
	parent.add_child(building)
	building.global_position = pos
	return building


func _ready() -> void:
	print("\n===== PROTOTYPE MOVING ZOMBIE REGRESSION =====")

	var moving_scene := load(
		"res://scenes/enemies/prototype_moving_zombie.tscn"
	) as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var turret_scene := load(
		"res://scenes/buildings/prototype_defensive_turret.tscn"
	) as PackedScene
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(
		moving_scene != null
		and storage_scene != null
		and turret_scene != null
		and ammo != null
	)

	var root := Node3D.new()
	add_child(root)
	var zombie := moving_scene.instantiate() as Node3D
	assert(zombie != null)
	root.add_child(zombie)

	var health := zombie.get_node("HealthComponent") as CombatHealthComponent
	var movement := zombie.get_node("MovementComponent") as ZombieApproachComponent
	assert(health != null and movement != null)
	movement.set_physics_process(false)
	# Preserve building-only targeting for this historical regression.
	movement.target_conveyors = false
	# This suite advances approach and turret fire manually, not melee.
	var melee := zombie.get_node("MeleeComponent") as ZombieMeleeComponent
	assert(melee != null)
	melee.set_physics_process(false)
	assert(zombie.is_in_group("hostile_targets"))
	assert(health.current_health == 30)
	assert(is_equal_approx(movement.move_speed, 2.0))
	assert(is_equal_approx(movement.stopping_distance, 1.5))
	print("PASS A: Separate moving hostile has 30 HP and walking settings")

	movement._physics_process(1.0)
	assert(zombie.global_position == Vector3.ZERO)
	assert(movement.current_target == null)
	assert(movement.movement_status == "No Target")
	print("PASS B: Without player-built structures, enemy stays stationary")

	var ghost := _structure(
		root, storage_scene, Vector3(1, 0, 0), true
	)
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	root.add_child(belt)
	belt.global_position = Vector3(0.5, 0, 0)
	assert(movement.find_nearest_structure() == null)
	movement._physics_process(1.0)
	assert(zombie.global_position == Vector3.ZERO)
	print("PASS C: Ghost buildings and conveyors cannot become targets")

	var near := _structure(root, storage_scene, Vector3(8, 0, 0))
	var far := _structure(root, storage_scene, Vector3(12, 0, 0))
	assert(movement.find_nearest_structure() == near)
	movement._physics_process(1.0)
	assert(movement.current_target == near)
	assert(zombie.global_position.distance_to(Vector3(2, 0, 0)) < 0.001)
	assert(movement.movement_status == "Approaching")
	print("PASS D: Zombie selects nearest real building and walks two units")

	movement._physics_process(10.0)
	assert(zombie.global_position.distance_to(Vector3(6.5, 0, 0)) < 0.001)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	assert(is_equal_approx(zombie.global_position.y, 0.0))
	assert(movement.current_target == near)
	print("PASS E: Large step stops 1.5 units out without overshoot")

	near.queue_free()
	await get_tree().process_frame
	movement._physics_process(1.0)
	assert(movement.current_target == far)
	assert(zombie.global_position.distance_to(Vector3(8.5, 0, 0)) < 0.001)
	movement._physics_process(10.0)
	assert(zombie.global_position.distance_to(Vector3(10.5, 0, 0)) < 0.001)
	assert(movement.movement_status == "Approaching")
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	print("PASS F: Removed target is replaced without changing altitude")

	var building := turret_scene.instantiate() as Node3D
	assert(building != null)
	root.add_child(building)
	building.global_position = Vector3(12, 0, 2)
	var turret := building.get_node("TurretComponent") as DefensiveTurretComponent
	var targeting := building.get_node("TargetingComponent") as TurretTargetingComponent
	var magazine := building.get_node("AmmunitionInventory") as InventoryComponent
	assert(turret != null and targeting != null and magazine != null)
	turret.set_process(false)
	targeting.set_process(false)
	assert(magazine.add_item(ammo, 3) == 3)
	assert(targeting.find_nearest_target() == zombie)
	targeting._process(0.01)
	assert(health.current_health == 20)
	assert(turret.shots_fired == 1)
	assert(magazine.get_amount(ammo) == 2)
	print("PASS G: Existing ammo-fed turret detects and hits the moving enemy")

	targeting._process(0.01)
	assert(health.current_health == 20)
	assert(turret.shots_fired == 1)
	for remaining_health: int in [10, 0]:
		turret._process(1.01)
		targeting._process(0.01)
		assert(health.current_health == remaining_health)
	assert(turret.shots_fired == 3)
	assert(magazine.get_amount(ammo) == 0)
	assert(targeting.confirmed_hits == 3)
	assert(targeting.confirmed_kills == 1)
	print("PASS H: Cooldown and real ammo account for all three hits")

	var stopped_at: Vector3 = zombie.global_position
	movement._physics_process(4.0)
	assert(zombie.global_position == stopped_at)
	assert(movement.current_target == null)
	assert(movement.movement_status == "Defeated")
	assert(targeting.find_nearest_target() == null)
	turret._process(2.0)
	targeting._process(0.1)
	assert(turret.shots_fired == 3)
	print("PASS I: Defeated enemy stops moving and cannot be hit again")

	root.queue_free()
	print("=================================================")
	print("ALL 9 MOVING ZOMBIE FOUNDATION TESTS PASSED")
	print("=================================================")
