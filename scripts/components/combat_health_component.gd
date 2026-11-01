extends Node
class_name CombatHealthComponent

# =============================================================================
# COMBAT HEALTH SETTINGS
# =============================================================================

# Shared foundation for future zombies and other destructible targets.
# Health is initialized from the scene's configured maximum.

@export_range(1, 100000, 1) var max_health: int = 30

# =============================================================================
# COMBAT HEALTH STATE
# =============================================================================

var current_health: int = 0
var total_damage_taken: int = 0

signal health_depleted


# =============================================================================
# INITIAL HEALTH
# =============================================================================

func _ready() -> void:
	current_health = max_health


# =============================================================================
# READ-ONLY TARGET AVAILABILITY
# =============================================================================

func is_alive() -> bool:
	return current_health > 0 and not is_queued_for_deletion()


# =============================================================================
# APPLY GUARDED DAMAGE
# =============================================================================

# Returns the actual damage dealt. Extra damage past zero is discarded.
# Dead targets are left in the scene for the regression and future death FX.

func take_damage(amount: int) -> int:
	if amount <= 0 or not is_alive():
		return 0

	var applied: int = mini(amount, current_health)
	current_health -= applied
	total_damage_taken += applied

	if current_health == 0:
		health_depleted.emit()

	return applied
