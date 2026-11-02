extends Node
class_name BuildingHealthComponent

# =============================================================================
# BUILDING HEALTH — PROTOTYPE SETTINGS
# =============================================================================

# The owning Main scene can enable automatic destruction on zero HP.
# Isolated health tests without that service remain non-destructive.
# Never delete the owning building directly from this component.

@export_range(1, 100000, 1) var max_health: int = 100

# =============================================================================
# BUILDING HEALTH — RUNTIME STATE
# =============================================================================

var current_health: int = 0
var total_damage_taken: int = 0

signal health_depleted


func _ready() -> void:
	current_health = max_health
	_connect_world_destruction()


# =============================================================================
# WORLD DESTRUCTION — OPTIONAL HEALTH-DEPLETION LISTENER
# =============================================================================

# Connected once when this building enters a Main world. The listener
# owns the recovery transaction and is responsible for safe removal;
# isolated test worlds without a service retain their original behavior.

func _connect_world_destruction() -> void:
	var source := get_parent() as Node3D
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
				service._on_building_health_depleted.bind(source)
			)
			return

		ancestor = ancestor.get_parent()


# =============================================================================
# BUILDING DAMAGE — GUARDED TRANSACTION AND DEPLETION SIGNAL
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
