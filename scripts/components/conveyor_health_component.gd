extends Node
class_name ConveyorHealthComponent

# =============================================================================
# CONVEYOR HEALTH — DAMAGEABLE STRAIGHT AND CORNER SEGMENTS
# =============================================================================

# All belt shapes can take damage independently. Live zombie targeting
# and automatic zero-HP belt destruction are enabled in a later step,
# after cargo preservation and neighbor disconnection are tested.

@export_range(1, 100000, 1) var max_health: int = 50

# =============================================================================
# CONVEYOR HEALTH — RUNTIME STATE
# =============================================================================

var current_health: int = 0
var total_damage_taken: int = 0

signal health_depleted


func _ready() -> void:
	current_health = max_health


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
