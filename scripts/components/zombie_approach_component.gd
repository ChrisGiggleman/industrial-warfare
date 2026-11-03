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
@export var target_conveyors: bool = false

# A snapped approach can land a fraction of a millimeter beyond the
# stopping boundary because Vector3 arithmetic uses floating point.
# Treat that position as arrived without changing how far the zombie walks.
const ARRIVAL_EPSILON: float = 0.001

# =============================================================================
# MOVEMENT STATE
# =============================================================================

var current_target: Node3D = null
var movement_status: String = "Idle"


# =============================================================================
# FIND NEAREST BUILT STRUCTURE
# =============================================================================

# Targets healthy player-built structures and (when explicitly enabled)
# healthy conveyor segments. Ignores previews, resource deposits,
# deleted objects and depleted structures. Existing isolated movement
# regressions keep target_conveyors disabled.

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
		):
			continue

		if structure is ConveyorSegment:
			if not target_conveyors:
				continue
			var belt_health := structure.get_node_or_null(
				"ConveyorHealthComponent"
			) as ConveyorHealthComponent
			if not is_instance_valid(belt_health) or not belt_health.is_intact():
				continue
		else:
			var runtime := structure.get_node_or_null(
				"BuildingRuntime"
			) as BuildingRuntime
			if not is_instance_valid(runtime):
				continue

			# If recovery preflight fails, a zero-HP building may remain
			# temporarily in place; never attack it again.
			var durability := structure.get_node_or_null(
				"BuildingHealthComponent"
			) as BuildingHealthComponent
			if is_instance_valid(durability) and not durability.is_intact():
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

	# Discard targets deleted by salvage or left at zero HP after
	# a failed recovery, including conveyor segments.
	if is_instance_valid(current_target):
		if current_target is ConveyorSegment:
			var belt_health := current_target.get_node_or_null(
				"ConveyorHealthComponent"
			) as ConveyorHealthComponent
			if (
				not target_conveyors
				or not is_instance_valid(belt_health)
				or not belt_health.is_intact()
			):
				current_target = null
		else:
			var target_health := current_target.get_node_or_null(
				"BuildingHealthComponent"
			) as BuildingHealthComponent
			if is_instance_valid(target_health) and not target_health.is_intact():
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

	if distance <= stopping_distance + ARRIVAL_EPSILON:
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
