extends Node
class_name TurretTargetingComponent

# =============================================================================
# RANGE-LIMITED COMBAT SETTINGS
# =============================================================================

# This first combat version uses a stationary target dummy and immediate
# damage on an authorized shot. Line of sight, muzzle FX and projectiles
# will be added after deterministic range and ammo tests pass.

@export var turret: DefensiveTurretComponent
@export_range(0.5, 100.0, 0.5) var detection_range: float = 7.0
@export_range(1, 1000, 1) var shot_damage: int = 10
@export var automatic_fire_enabled: bool = true

# =============================================================================
# READ-ONLY COMBAT STATE
# =============================================================================

var current_target: Node3D = null
var confirmed_hits: int = 0
var confirmed_kills: int = 0


# =============================================================================
# FIND THE NEAREST LIVING HOSTILE IN RANGE
# =============================================================================

# The hostile_targets group identifies enemy roots. Each root must own
# a CombatHealthComponent child named HealthComponent.
# Comparison occurs in the horizontal factory plane (X/Z).

func find_nearest_target() -> Node3D:
	if not is_inside_tree() or detection_range <= 0.0:
		return null
	if not get_parent() is Node3D:
		return null

	var origin: Vector3 = (get_parent() as Node3D).global_position
	var closest_squared: float = detection_range * detection_range
	var best: Node3D = null

	for node: Node in get_tree().get_nodes_in_group("hostile_targets"):
		if not node is Node3D:
			continue

		var enemy := node as Node3D
		if (
			not is_instance_valid(enemy)
			or not enemy.is_inside_tree()
			or enemy.is_queued_for_deletion()
		):
			continue

		var health := enemy.get_node_or_null(
			"HealthComponent"
		) as CombatHealthComponent
		if not is_instance_valid(health) or not health.is_alive():
			continue

		var delta := Vector2(
			enemy.global_position.x - origin.x,
			enemy.global_position.z - origin.z
		)
		var distance_squared: float = delta.length_squared()
		if distance_squared > closest_squared:
			continue

		closest_squared = distance_squared
		best = enemy

	return best


# =============================================================================
# AUTOMATIC ATTACK UPDATE
# =============================================================================

# Only a living target currently in range can authorize a shot.
# The turret's existing try_fire() remains the sole ammo-consuming
# transaction and enforces its own cooldown.

func _process(_delta: float) -> void:
	if not automatic_fire_enabled:
		current_target = null
		return

	current_target = find_nearest_target()

	if not is_instance_valid(current_target):
		return
	if not is_instance_valid(turret) or not turret.is_ready_to_fire():
		return

	var health := current_target.get_node_or_null(
		"HealthComponent"
	) as CombatHealthComponent
	if not is_instance_valid(health) or not health.is_alive():
		return

	if not turret.try_fire():
		return

	var applied: int = health.take_damage(shot_damage)
	if applied > 0:
		confirmed_hits += 1
		if not health.is_alive():
			confirmed_kills += 1
