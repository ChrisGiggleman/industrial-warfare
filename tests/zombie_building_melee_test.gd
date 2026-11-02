extends Node

# =============================================================================
# BUILDING HEALTH AND ISOLATED ZOMBIE MELEE REGRESSION
# =============================================================================

# Uses real Storage and moving-zombie scenes with test-only components.
# Main-game structures and zombies do not receive melee damage yet.

func _storage(
	parent: Node3D,
	scene: PackedScene,
	position: Vector3,
	hit_points: int = 0
) -> Node3D:
	var building := scene.instantiate() as Node3D
	assert(building != null)
	if hit_points > 0:
		var durability := BuildingHealthComponent.new()
		durability.name = "BuildingHealthComponent"
		durability.max_health = hit_points
		building.add_child(durability)
	parent.add_child(building)
	building.global_position = position
	return building


func _ready() -> void:
	print("\n===== ISOLATED ZOMBIE MELEE AND BUILDING HEALTH =====")

	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var zombie_scene := load(
		"res://scenes/enemies/prototype_moving_zombie.tscn"
	) as PackedScene
	var ammo := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(storage_scene != null and zombie_scene != null and ammo != null)

	var root := Node3D.new()
	add_child(root)
	var zombie := zombie_scene.instantiate() as Node3D
	assert(zombie != null)
	var movement := zombie.get_node("MovementComponent") as ZombieApproachComponent
	var zombie_health := zombie.get_node("HealthComponent") as CombatHealthComponent
	var melee := ZombieMeleeComponent.new()
	melee.name = "MeleeComponent"
	melee.movement = movement
	zombie.add_child(melee)
	root.add_child(zombie)
	movement.set_physics_process(false)
	melee.set_physics_process(false)

	assert(zombie_health.current_health == 30)
	assert(melee.attacks_landed == 0)
	assert(is_equal_approx(melee.attack_range, 1.55))
	assert(melee.attack_damage == 10)
	print("PASS A: Zombie melee is isolated and has guarded attack settings")

	melee._physics_process(1.0)
	assert(melee.attack_status == "No Structure")
	assert(melee.attacks_landed == 0)
	print("PASS B: A zombie without a structure cannot deal damage")

	var old_storage := _storage(root, storage_scene, Vector3(2, 0, 0))
	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(movement.current_target == old_storage)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(1.0)
	assert(melee.attack_status == "Undamageable")
	assert(melee.attacks_landed == 0)
	print("PASS C: A structure without BuildingHealth is never damaged")

	old_storage.add_to_group("construction_preview")
	movement.current_target = null
	zombie.global_position = Vector3.ZERO
	var ghost := _storage(root, storage_scene, Vector3(1, 0, 0), 10)
	ghost.add_to_group("construction_preview")
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	root.add_child(belt)
	belt.global_position = Vector3(0.5, 0, 0)
	assert(movement.find_nearest_structure() == null)
	print("PASS D: Construction ghosts and conveyor belts cannot be melee targets")

	var near := _storage(root, storage_scene, Vector3(8, 0, 0), 25)
	var far := _storage(root, storage_scene, Vector3(12, 0, 0), 30)
	var near_health := near.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var far_health := far.get_node(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	var stored := near.get_node("InventoryComponent") as InventoryComponent
	assert(near_health.current_health == 25 and far_health.current_health == 30)
	assert(stored.add_item(ammo, 3) == 3)
	assert(near_health.take_damage(0) == 0)
	assert(near_health.take_damage(-5) == 0)
	assert(movement.find_nearest_structure() == near)
	print("PASS E: Healthy building is selected; invalid damage changes nothing")

	movement._physics_process(1.0)
	melee._physics_process(1.0)
	assert(zombie.global_position.distance_to(Vector3(2, 0, 0)) < 0.001)
	assert(melee.attack_status == "Approaching")
	assert(near_health.current_health == 25)
	print("PASS F: Zombie moving toward storage cannot strike early")

	movement._physics_process(10.0)
	movement._physics_process(0.1)
	assert(zombie.global_position.distance_to(Vector3(6.5, 0, 0)) < 0.001)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(0.01)
	assert(near_health.current_health == 15)
	assert(near_health.total_damage_taken == 10)
	assert(melee.attacks_landed == 1)
	assert(melee.total_damage_dealt == 10)
	print("PASS G: Arrival authorizes one melee hit for 10 building HP")

	melee._physics_process(0.1)
	melee._physics_process(0.4)
	assert(near_health.current_health == 15)
	assert(melee.attacks_landed == 1)
	assert(melee.attack_status == "Cooldown")
	print("PASS H: Attack cooldown prevents duplicate structure damage")

	melee._physics_process(0.6)
	assert(near_health.current_health == 5)
	assert(melee.attacks_landed == 2)
	melee._physics_process(1.01)
	assert(not near_health.is_intact())
	assert(near_health.current_health == 0)
	assert(near_health.total_damage_taken == 25)
	assert(melee.total_damage_dealt == 25)
	assert(melee.attacks_landed == 3)
	assert(near_health.take_damage(10) == 0)
	print("PASS I: Overkill clamps at zero HP and counts exact dealt damage")

	assert(near.is_inside_tree())
	assert(stored.get_amount(ammo) == 3)
	assert(stored.get_total_amount() == 3)
	assert(near.is_in_group("player_built"))
	print("PASS J: Disabled building remains present with its ammo intact")

	movement._physics_process(0.1)
	assert(movement.current_target == far)
	assert(movement.find_nearest_structure() == far)
	assert(near_health.current_health == 0)
	assert(far_health.current_health == 30)
	assert(melee.total_damage_dealt == 25)
	print("PASS K: Zombie ignores disabled building and reacquires an intact one")

	# Reposition into the next structure's melee range without
	# changing its health, ensuring this enemy can attack again.
	zombie.global_position = Vector3(10.5, 0, 0)
	movement._physics_process(0.1)
	assert(movement.movement_status == "At Structure")
	melee._physics_process(1.1)
	assert(far_health.current_health == 20)
	assert(melee.attacks_landed == 4)
	assert(melee.total_damage_dealt == 35)

	var before_death: Vector3 = zombie.global_position
	assert(zombie_health.take_damage(30) == 30)
	melee._physics_process(3.0)
	movement._physics_process(3.0)
	assert(melee.attack_status == "Defeated")
	assert(movement.movement_status == "Defeated")
	assert(far_health.current_health == 20)
	assert(zombie.global_position == before_death)
	print("PASS L: A defeated zombie cannot move or attack another structure")

	root.queue_free()
	print("======================================================")
	print("ALL 12 ISOLATED BUILDING HEALTH AND MELEE TESTS PASSED")
	print("======================================================")
