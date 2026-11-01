extends Node

# =============================================================================
# DEFENSIVE TURRET — RANGE, AMMO AND DAMAGE REGRESSION
# =============================================================================

# The live turret's targeting component is not attached yet.
# This test advances both components explicitly to prove deterministic,
# ammo-conserving target selection and damage before gameplay integration.

func _make_target(
	parent: Node3D,
	scene: PackedScene,
	position: Vector3
) -> Node3D:
	var target := scene.instantiate() as Node3D
	assert(target != null)
	parent.add_child(target)
	target.global_position = position
	return target


func _ready() -> void:
	print("\n===== DEFENSIVE TURRET TARGETING REGRESSION =====")
	var ammo := load("res://data/items/prototype_ammunition.tres") as ItemDefinition
	var turret_scene := load(
		"res://scenes/buildings/prototype_defensive_turret.tscn"
	) as PackedScene
	var target_scene := load(
		"res://scenes/enemies/prototype_zombie_target.tscn"
	) as PackedScene
	assert(ammo != null and turret_scene != null and target_scene != null)

	var root := Node3D.new()
	add_child(root)
	var building := turret_scene.instantiate() as Node3D
	assert(building != null)
	root.add_child(building)

	var turret := building.get_node("TurretComponent") as DefensiveTurretComponent
	var magazine := building.get_node("AmmunitionInventory") as InventoryComponent
	assert(turret != null and magazine != null)
	turret.set_process(false)
	assert(magazine.add_item(ammo, 5) == 5)

	var targeting := TurretTargetingComponent.new()
	building.add_child(targeting)
	targeting.turret = turret
	targeting.detection_range = 7.0
	targeting.shot_damage = 10
	targeting.set_process(false)
	assert(targeting.automatic_fire_enabled)
	assert(turret.shots_fired == 0)
	print("PASS A: Five rounds loaded; automatic targeting configured")

	targeting._process(0.1)
	assert(targeting.current_target == null)
	assert(magazine.get_amount(ammo) == 5)
	assert(turret.shots_fired == 0)
	print("PASS B: With no hostile targets, ammunition is not consumed")

	var far := _make_target(root, target_scene, Vector3(11, 0, 0))
	targeting._process(0.1)
	assert(targeting.find_nearest_target() == null)
	assert(magazine.get_amount(ammo) == 5)
	assert(
		(far.get_node("HealthComponent") as CombatHealthComponent).current_health == 30
	)
	print("PASS C: Outside-range hostile is ignored without firing")

	var friendly := _make_target(root, target_scene, Vector3(1, 0, 0))
	friendly.remove_from_group("hostile_targets")
	targeting._process(0.1)
	assert(targeting.find_nearest_target() == null)
	assert(magazine.get_amount(ammo) == 5)
	print("PASS D: Ungrouped nearby friendly target is never eligible")

	var near := _make_target(root, target_scene, Vector3(3, 0, 0))
	var second := _make_target(root, target_scene, Vector3(5, 0, 0))
	var near_hp := near.get_node("HealthComponent") as CombatHealthComponent
	var second_hp := second.get_node("HealthComponent") as CombatHealthComponent
	var friendly_hp := friendly.get_node("HealthComponent") as CombatHealthComponent
	assert(targeting.find_nearest_target() == near)
	targeting._process(0.1)
	assert(targeting.current_target == near)
	assert(near_hp.current_health == 20)
	assert(second_hp.current_health == 30)
	assert(magazine.get_amount(ammo) == 4)
	assert(turret.shots_fired == 1)
	print("PASS E: Nearest hostile is hit and one real round is consumed")

	targeting._process(0.1)
	assert(near_hp.current_health == 20)
	assert(turret.shots_fired == 1)
	turret._process(0.5)
	targeting._process(0.1)
	assert(turret.shots_fired == 1)
	assert(magazine.get_amount(ammo) == 4)
	print("PASS F: Firing cooldown prevents duplicate hits and ammo loss")

	turret._process(0.5)
	targeting._process(0.1)
	assert(near_hp.current_health == 10)
	assert(turret.shots_fired == 2)
	turret._process(1.0)
	targeting._process(0.1)
	assert(not near_hp.is_alive())
	assert(near_hp.current_health == 0)
	assert(near_hp.total_damage_taken == 30)
	assert(turret.shots_fired == 3)
	assert(targeting.confirmed_kills == 1)
	assert(magazine.get_amount(ammo) == 2)
	print("PASS G: Three valid shots defeat the 30-HP target with no overdamage")

	assert(targeting.find_nearest_target() == second)
	turret._process(1.0)
	targeting._process(0.1)
	assert(targeting.current_target == second)
	assert(second_hp.current_health == 20)
	assert(magazine.get_amount(ammo) == 1)
	print("PASS H: Defeated target is skipped and next living target is acquired")

	turret._process(1.0)
	targeting._process(0.1)
	assert(second_hp.current_health == 10)
	assert(turret.shots_fired == 5)
	assert(magazine.get_amount(ammo) == 0)
	turret._process(1.0)
	targeting._process(0.1)
	assert(turret.shots_fired == 5)
	assert(second_hp.current_health == 10)
	assert(targeting.confirmed_hits == 5)
	print("PASS I: Empty magazine prevents firing or phantom damage")

	assert(magazine.add_item(ammo, 1) == 1)
	second.global_position = Vector3(12, 0, 0)
	targeting._process(0.1)
	assert(targeting.find_nearest_target() == null)
	assert(magazine.get_amount(ammo) == 1)
	assert(second_hp.current_health == 10)
	print("PASS J: Moving the remaining enemy out of range preserves ammo")

	second.global_position = Vector3(4, 0, 0)
	assert(targeting.find_nearest_target() == second)
	targeting._process(0.1)
	assert(second_hp.current_health == 0)
	assert(targeting.confirmed_kills == 2)
	assert(targeting.confirmed_hits == 6)
	assert(turret.shots_fired == 6)
	assert(magazine.get_amount(ammo) == 0)
	print("PASS K: Returning hostile is defeated by one authorized round")

	turret._process(1.0)
	targeting._process(0.1)
	assert(targeting.find_nearest_target() == null)
	assert(friendly_hp.current_health == 30)
	assert((far.get_node("HealthComponent") as CombatHealthComponent).current_health == 30)
	assert(not targeting.current_target)
	assert(turret.shots_fired == targeting.confirmed_hits)
	print("PASS L: No dead/friendly/distant target is hit; six shots conserved")

	root.queue_free()
	print("====================================================")
	print("ALL 12 DEFENSIVE TURRET TARGETING TESTS PASSED")
	print("====================================================")
