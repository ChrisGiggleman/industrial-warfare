extends Node
class_name ConveyorHealthComponent

# =============================================================================
# CONVEYOR HEALTH — DAMAGEABLE STRAIGHT AND CORNER SEGMENTS
# =============================================================================

# Each belt shape takes damage independently. In Main, a depleted
# conveyor can enter the tested cargo recovery and destruction service.
# Standalone worlds without a service remain non-destructive.

@export_range(1, 100000, 1) var max_health: int = 50

# =============================================================================
# CONVEYOR HEALTH — RUNTIME STATE
# =============================================================================

var current_health: int = 0
var total_damage_taken: int = 0

signal health_depleted


func _ready() -> void:
	current_health = max_health
	_connect_world_destruction()


# =============================================================================
# WORLD DESTRUCTION — OPTIONAL CONVEYOR DEPLETION LISTENER
# =============================================================================

func _connect_world_destruction() -> void:
	var source := get_parent() as ConveyorSegment
	if not is_instance_valid(source):
		return
	if not source.is_in_group("player_built"):
		return
	if source.is_in_group("construction_preview"):
		return

	var ancestor: Node = source.get_parent()
	while is_instance_valid(ancestor):
		var service := ancestor.get_node_or_null(
			"WorldDestructionService"
		) as WorldDestructionService
		if is_instance_valid(service):
			health_depleted.connect(
				service._on_conveyor_health_depleted.bind(source)
			)
			return

		ancestor = ancestor.get_parent()


# =============================================================================
# CONVEYOR DAMAGE — CLAMPED AND REPEAT-SAFE
# =============================================================================

func is_intact() -> bool:
	return current_health > 0 and not is_queued_for_deletion()


func take_damage(amount: int) -> int:
	if amount <= 0 or not is_intact():
		return 0

	var actual: int = mini(current_health, amount)
	current_health -= actual
	total_damage_taken += actual

	if current_health == 0:
		health_depleted.emit()

	return actual
