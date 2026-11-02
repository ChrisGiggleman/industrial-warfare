extends Node
class_name ZombieMeleeComponent

# =============================================================================
# ZOMBIE MELEE — PROTOTYPE SETTINGS
# =============================================================================

# Attached to the prototype moving zombie in the playable world.
# Targeting follows ZombieApproachComponent and only affects
# structures carrying an explicit BuildingHealthComponent.
# In Main, zero-HP buildings can enter the guarded destruction and
# world-salvage flow. Isolated test worlds may still keep them in place.

@export var movement: ZombieApproachComponent
@export_range(0.25, 5.0, 0.05) var attack_range: float = 1.55
@export_range(1, 1000, 1) var attack_damage: int = 10
@export_range(0.1, 30.0, 0.1) var attack_interval: float = 1.0

# =============================================================================
# ZOMBIE MELEE — RUNTIME STATE
# =============================================================================

var cooldown_remaining: float = 0.0
var attacks_landed: int = 0
var total_damage_dealt: int = 0
var attack_status: String = "Idle"


# =============================================================================
# ATTACK UPDATE
# =============================================================================

func _physics_process(delta: float) -> void:
	if delta <= 0.0:
		return

	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)

	var mover := get_parent() as Node3D
	if not is_instance_valid(mover):
		attack_status = "Invalid Attacker"
		return

	var zombie_health := mover.get_node_or_null(
		"HealthComponent"
	) as CombatHealthComponent
	if not is_instance_valid(zombie_health) or not zombie_health.is_alive():
		attack_status = "Defeated"
		return

	if not is_instance_valid(movement):
		attack_status = "No Movement"
		return

	var target: Node3D = movement.current_target
	if (
		not is_instance_valid(target)
		or not target.is_inside_tree()
		or target.is_queued_for_deletion()
		or not target.is_in_group("player_built")
		or target.is_in_group("construction_preview")
		or target is ConveyorSegment
	):
		attack_status = "No Structure"
		return

	if movement.movement_status != "At Structure":
		attack_status = "Approaching"
		return

	var runtime := target.get_node_or_null("BuildingRuntime") as BuildingRuntime
	var health := target.get_node_or_null(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	if not is_instance_valid(runtime) or not is_instance_valid(health):
		attack_status = "Undamageable"
		return
	if not health.is_intact():
		attack_status = "Structure Disabled"
		return

	var offset := Vector2(
		target.global_position.x - mover.global_position.x,
		target.global_position.z - mover.global_position.z
	)
	if offset.length_squared() > attack_range * attack_range:
		attack_status = "Out of Range"
		return

	if attack_damage <= 0 or attack_interval <= 0.0:
		attack_status = "Invalid Attack"
		return

	if cooldown_remaining > 0.0:
		attack_status = "Cooldown"
		return

	# The health component decides how much damage actually applies.
	# It never frees the building or its stored materials.
	var dealt: int = health.take_damage(attack_damage)
	if dealt <= 0:
		attack_status = "Structure Disabled"
		return

	attacks_landed += 1
	total_damage_dealt += dealt
	cooldown_remaining = attack_interval
	attack_status = "Hit"
