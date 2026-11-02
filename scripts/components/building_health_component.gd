extends Node
class_name BuildingHealthComponent

# =============================================================================
# BUILDING HEALTH — PROTOTYPE SETTINGS
# =============================================================================

# A zero-health building stays in the scene. Combat destruction,
# inventory recovery and salvage must be designed before removal.

@export_range(1, 100000, 1) var max_health: int = 100

# =============================================================================
# BUILDING HEALTH — RUNTIME STATE
# =============================================================================

var current_health: int = 0
var total_damage_taken: int = 0

signal health_depleted


func _ready() -> void:
	current_health = max_health


# =============================================================================
# BUILDING DAMAGE — GUARDED, NON-DESTRUCTIVE TRANSACTION
# =============================================================================

func is_intact() -> bool:
	return current_health > 0 and not is_queued_for_deletion()


func take_damage(amount: int) -> int:
	if amount <= 0 or not is_intact():
		return 0

	var applied: int = mini(amount, current_health)
	current_health -= applied
	total_damage_taken += applied

	if current_health == 0:
		health_depleted.emit()

	return applied
