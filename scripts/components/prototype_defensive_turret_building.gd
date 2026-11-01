extends "res://scripts/selectable_object.gd"

# =============================================================================
# DEFENSIVE TURRET — SAFE DEMOLITION
# =============================================================================

# Prevent player demolition from silently deleting stored ammunition.
# A future combat-destruction path will need a separate salvage policy.

func can_demolish_safely() -> bool:
	var inventory := get_node_or_null("AmmunitionInventory") as InventoryComponent
	if not is_instance_valid(inventory):
		return false
	return inventory.get_total_amount() == 0


# =============================================================================
# DEFENSIVE TURRET — PORT CLEANUP
# =============================================================================

func _exit_tree() -> void:
	var port := get_node_or_null("InputPort") as ItemPortComponent
	if (
		is_instance_valid(port)
		and is_instance_valid(port.connected_conveyor)
	):
		port.connected_conveyor.disconnect_building_port(port)
