extends Node
class_name ConveyorMergerComponent

# =============================================================================
# THREE INPUT LANES TO ONE PHYSICAL OUTPUT
# =============================================================================

# Three isolated input buffers and one bounded output buffer.
# Alternates among available inputs without removing any item unless
# the output can accept it. An unavailable input is skipped fairly.
# All external transfers still use ItemPortComponent and conveyors.

@export var input_a: InventoryComponent
@export var input_b: InventoryComponent
@export var input_c: InventoryComponent
@export var output_inventory: InventoryComponent
@export_range(0.05, 10.0, 0.05) var merge_interval: float = 0.25

var elapsed: float = 0.0
var next_lane: int = 0
var completed_merges: int = 0
var completed_from_a: int = 0
var completed_from_b: int = 0
var completed_from_c: int = 0


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
		or not is_instance_valid(input_c)
		or not is_instance_valid(output_inventory)
	):
		return false

	if output_inventory.get_available_space() == 0:
		return false

	var lanes: Array[InventoryComponent] = [input_a, input_b, input_c]
	for offset: int in range(lanes.size()):
		var lane: int = (next_lane + offset) % lanes.size()
		var inventory: InventoryComponent = lanes[lane]

		for key in inventory.items.keys():
			var item: ItemDefinition = key as ItemDefinition
			if item == null or not inventory.has_amount(item, 1):
				continue
			if inventory.transfer_to(output_inventory, item, 1) != 1:
				continue

			next_lane = (lane + 1) % lanes.size()
			completed_merges += 1
			match lane:
				0:
					completed_from_a += 1
				1:
					completed_from_b += 1
				2:
					completed_from_c += 1
			return true

	return false
