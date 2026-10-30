extends "res://scripts/selectable_object.gd"

# =============================================================================
# MERGER BUILDING — SAFE DEMOLITION AND PORT DISCONNECT
# =============================================================================

func can_demolish_safely() -> bool:
	for name: String in ["InputAInventory", "InputBInventory", "InputCInventory", "OutputInventory"]:
		var inventory := get_node_or_null(name) as InventoryComponent
		if not is_instance_valid(inventory):
			return false
		if inventory.get_total_amount() > 0:
			return false
	return true


func _exit_tree() -> void:
	for name: String in ["InputPortA", "InputPortB", "InputPortC", "OutputPort"]:
		var port := get_node_or_null(name) as ItemPortComponent
		if is_instance_valid(port) and is_instance_valid(port.connected_conveyor):
			port.connected_conveyor.disconnect_building_port(port)
