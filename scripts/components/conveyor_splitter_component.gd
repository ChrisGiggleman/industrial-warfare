extends Node
class_name ConveyorSplitterComponent

# =============================================================================
# CHAT 08.3G-3K — ONE INPUT TO THREE PHYSICAL OUTPUTS
# =============================================================================

# The input is one bounded InventoryComponent; each output uses a separate
# one-unit buffer. Items are distributed round-robin only to connected
# outputs with room. A full output is skipped, and when all three are
# unavailable the input retains its item. No inventory is modified unless
# InventoryComponent.transfer_to() succeeds.

@export var input_inventory: InventoryComponent
@export var output_a: InventoryComponent
@export var output_b: InventoryComponent
@export var output_c: InventoryComponent
@export var output_port_a: ItemPortComponent
@export var output_port_b: ItemPortComponent
@export var output_port_c: ItemPortComponent
@export_range(0.05, 10.0, 0.05) var split_interval: float = 0.25

var elapsed: float = 0.0
var next_lane: int = 0
var completed_splits: int = 0
var completed_to_a: int = 0
var completed_to_b: int = 0
var completed_to_c: int = 0


func _process(delta: float) -> void:
	if split_interval <= 0.0:
		return
	elapsed += delta
	if elapsed < split_interval:
		return
	elapsed = minf(elapsed - split_interval, split_interval)
	advance_split()


func advance_split() -> bool:
	if not is_instance_valid(input_inventory):
		return false
	if input_inventory.get_total_amount() <= 0:
		return false

	var outputs: Array[InventoryComponent] = [output_a, output_b, output_c]
	var ports: Array[ItemPortComponent] = [
		output_port_a, output_port_b, output_port_c
	]

	for offset: int in range(outputs.size()):
		var lane: int = (next_lane + offset) % outputs.size()
		var inventory: InventoryComponent = outputs[lane]
		var port: ItemPortComponent = ports[lane]

		if not is_instance_valid(inventory) or not is_instance_valid(port):
			continue
		if not is_instance_valid(port.connected_conveyor):
			continue
		if port.connected_conveyor.input_building_port != port:
			continue
		if inventory.get_available_space() == 0:
			continue

		for key in input_inventory.items.keys():
			var item: ItemDefinition = key as ItemDefinition
			if item == null or not input_inventory.has_amount(item, 1):
				continue
			if input_inventory.transfer_to(inventory, item, 1) != 1:
				continue

			next_lane = (lane + 1) % outputs.size()
			completed_splits += 1
			match lane:
				0:
					completed_to_a += 1
				1:
					completed_to_b += 1
				2:
					completed_to_c += 1
			return true

	return false
