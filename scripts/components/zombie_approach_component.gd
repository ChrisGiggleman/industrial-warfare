extends Node
class_name ZombieApproachComponent

# =============================================================================
# MOVING ZOMBIE — APPROACH SETTINGS
# =============================================================================

# Early movement prototype: direct motion on the X/Z factory plane.
# This does not pathfind around walls, machines or conveyor lines.

@export_range(0.1, 20.0, 0.1) var move_speed: float = 2.0
@export_range(0.25, 5.0, 0.05) var stopping_distance: float = 1.5
@export var automatic_target_selection: bool = true

# =============================================================================
# MOVEMENT STATE
# =============================================================================

var current_target: Node3D = null
var movement_status: String = "Idle"


# =============================================================================
# FIND NEAREST BUILT STRUCTURE
# =============================================================================

# Intentionally ignores:
# - conveyor segments and their transport cargo
# - preview ghosts
# - non-buildings, such as resource deposits
# - deleted or unfinished structures

func find_nearest_structure() -> Node3D:
	if not is_inside_tree() or not get_parent() is Node3D:
		return null

	var mover := get_parent() as Node3D
	var closest_squared: float = INF
	var closest: Node3D = null

	for node: Node in get_tree().get_nodes_in_group("player_built"):
		if not node is Node3D:
			continue

		var structure := node as Node3D
		if (
			structure == mover
			or not structure.is_inside_tree()
			or structure.is_queued_for_deletion()
			or structure.is_in_group("construction_preview")
			or structure is ConveyorSegment
		):
			continue

		var runtime := structure.get_node_or_null(
			"BuildingRuntime"
		) as BuildingRuntime
		if not is_instance_valid(runtime):
			continue

		var distance_squared: float = Vector2(
			structure.global_position.x - mover.global_position.x,
			structure.global_position.z - mover.global_position.z
		).length_squared()

		if distance_squared < closest_squared:
			closest_squared = distance_squared
			closest = structure

	return closest


# =============================================================================
# ADVANCE TOWARD TARGET WITHOUT OVERSHOOTING
# =============================================================================

func _physics_process(delta: float) -> void:
	var mover := get_parent() as Node3D
	if not is_instance_valid(mover):
		movement_status = "Invalid Mover"
		return

	var health := mover.get_node_or_null(
		"HealthComponent"
	) as CombatHealthComponent
	if not is_instance_valid(health) or not health.is_alive():
		movement_status = "Defeated"
		current_target = null
		return

	if delta <= 0.0:
		return

	if (
		not is_instance_valid(current_target)
		or not current_target.is_inside_tree()
		or current_target.is_queued_for_deletion()
	):
		current_target = null

	if current_target == null and automatic_target_selection:
		current_target = find_nearest_structure()

	if current_target == null:
		movement_status = "No Target"
		return

	var direction := Vector3(
		current_target.global_position.x - mover.global_position.x,
		0.0,
		current_target.global_position.z - mover.global_position.z
	)
	var distance: float = direction.length()

	if distance <= stopping_distance:
		movement_status = "At Structure"
		return

	if move_speed <= 0.0:
		movement_status = "Stopped"
		return

	# Clamp movement to the configured stopping distance. Large physics
	# steps cannot teleport the zombie through its target building.
	var step: float = minf(
		move_speed * delta,
		distance - stopping_distance
	)
	mover.global_position += direction.normalized() * step
	movement_status = "Approaching"
