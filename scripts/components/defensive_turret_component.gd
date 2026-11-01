extends Node
class_name DefensiveTurretComponent

# =============================================================================
# DEFENSIVE TURRET AMMUNITION SETTINGS
# =============================================================================

# Future enemy detection and projectile effects will trigger try_fire().
# No automatic target selection or damage is implemented in this checkpoint.

@export var ammunition_inventory: InventoryComponent
@export var ammunition_item: ItemDefinition
@export_range(0.05, 30.0, 0.05) var fire_interval: float = 1.0

# =============================================================================
# TURRET RUNTIME STATE
# =============================================================================

var cooldown_remaining: float = 0.0
var shots_fired: int = 0
var firing_status: String = "Initializing"


# =============================================================================
# PASSIVE RELOAD COOLDOWN UPDATE
# =============================================================================

func _process(delta: float) -> void:
	if delta <= 0.0:
		return
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	_refresh_status()


# =============================================================================
# READ-ONLY AMMUNITION AND READINESS
# =============================================================================

func stored_ammunition() -> int:
	if not is_instance_valid(ammunition_inventory):
		return 0
	if not is_instance_valid(ammunition_item):
		return 0
	return ammunition_inventory.get_amount(ammunition_item)


func is_ready_to_fire() -> bool:
	return (
		is_instance_valid(ammunition_inventory)
		and is_instance_valid(ammunition_item)
		and fire_interval > 0.0
		and cooldown_remaining <= 0.0
		and stored_ammunition() > 0
	)


func _refresh_status() -> void:
	if (
		not is_instance_valid(ammunition_inventory)
		or not is_instance_valid(ammunition_item)
		or fire_interval <= 0.0
	):
		firing_status = "Invalid Setup"
	elif cooldown_remaining > 0.0:
		firing_status = "Cooldown"
	elif stored_ammunition() <= 0:
		firing_status = "Out of Ammo"
	else:
		firing_status = "Ready"


# =============================================================================
# GUARDED ONE-ROUND FIRING TRANSACTION
# =============================================================================

# This method represents one successful shot: it consumes exactly one
# round only when the turret is ready. Enemy/projectile logic will be added
# later and must call this only after a valid shot has been authorized.

func try_fire() -> bool:
	if not is_ready_to_fire():
		_refresh_status()
		return false

	if not ammunition_inventory.remove_item(ammunition_item, 1):
		_refresh_status()
		return false

	shots_fired += 1
	cooldown_remaining = fire_interval
	firing_status = "Fired"
	return true
