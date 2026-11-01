extends "res://scripts/selectable_object.gd"

# =============================================================================
# AMMUNITION PRESS — SAFE DEMOLITION AND PORT CLEANUP
# =============================================================================

# Never destroy stored ingredients or completed ammunition through the
# player demolition tool. Clear physical port links during scene removal.

func can_demolish_safely() -> bool:
	for name: String in ["InputInventory", "OutputInventory"]:
		var inventory := get_node_or_null(name) as InventoryComponent
		if not is_instance_valid(inventory):
			return false
		if inventory.get_total_amount() > 0:
			return false
	return true


func _exit_tree() -> void:
	for name: String in ["InputPort", "OutputPort"]:
		var port := get_node_or_null(name) as ItemPortComponent
		if (
			is_instance_valid(port)
			and is_instance_valid(port.connected_conveyor)
		):
			port.connected_conveyor.disconnect_building_port(port)
