extends Node
class_name ConveyorMergerComponent

# =============================================================================
# CHAT 08.3G-3G — TWO INPUTS, ONE OUTPUT
# =============================================================================

# Each incoming port has its own bounded queue. An internal round-robin
# arbiter moves at most one item into a one-unit output queue per cycle.
# Standard ConveyorBuildingTransfer handles all physical port transfers.
# This is a real item movement; no teleport between external belts.

@export var input_a: InventoryComponent
@export var input_b: InventoryComponent
@export var output_inventory: InventoryComponent
@export_range(0.05, 10.0, 0.05) var merge_interval: float = 0.25

var elapsed: float = 0.0
var next_lane: int = 0
var completed_merges: int = 0


func _process(delta: float) -> void:
	if merge_interval <= 0.0:
		return
	elapsed += delta
	if elapsed < merge_interval:
		return
	elapsed = minf(elapsed - merge_interval, merge_interval)
	advance_merge()


func advance_merge() -> bool:
	if (
		not is_instance_valid(input_a)
		or not is_instance_valid(input_b)
		or not is_instance_valid(output_inventory)
	):
		return false
	if output_inventory.get_available_space() == 0:
		return false

	for offset: int in range(2):
		var lane: int = (next_lane + offset) % 2
		var inventory: InventoryComponent = input_a if lane == 0 else input_b
		for key in inventory.items.keys():
			var item: ItemDefinition = key as ItemDefinition
			if item == null or not inventory.has_amount(item, 1):
				continue
			if inventory.transfer_to(output_inventory, item, 1) == 1:
				next_lane = (lane + 1) % 2
				completed_merges += 1
				return true
	return false
