extends Node
class_name BlueprintConstructionMaterialStaging

# =============================================================================
# E3D5C4C — ISOLATED BOUNDED CONSTRUCTION MATERIAL STAGING
# =============================================================================
# Explicit inventory-to-inventory transfer into a separate buffer, WITHOUT
# pretending a conveyor or construction drone actually delivered that item.
# A future physical input-port adapter must prove connectivity, directions,
# transport completion, and source ownership before calling receive_item().
#
# No job authorization, availability, escrow, power, workers, or timer changes
# occur here. This test-only component is not installed in playable scenes.

@export var enable_isolated_staging: bool = false

var _source: InventoryComponent = null
var _buffer: InventoryComponent = null
var _bill: Dictionary = {}


func configure(
	source: InventoryComponent,
	definition: BuildingDefinition,
	buffer_capacity: int
) -> bool:
	if (
		not enable_isolated_staging
		or not is_inside_tree()
		or is_instance_valid(_buffer)
		or not _live(source)
		or not is_instance_valid(definition)
		or buffer_capacity < 1
		or buffer_capacity > 100000
	):
		return false
	var costs: Dictionary = ConstructionMaterialBill.get_costs(definition)
	if costs.is_empty():
		return false
	var required: int = 0
	for key: Variant in costs.keys():
		required += int(costs[key])
	if buffer_capacity < required:
		return false

	var buffer := InventoryComponent.new()
	buffer.name = "ConstructionStagingInventory"
	buffer.max_capacity = buffer_capacity
	add_child(buffer)
	_source = source
	_buffer = buffer
	_bill = costs.duplicate()
	return true


# Test-only receiver entry point. Reuses the current inventory conservation
# and partial-capacity rules. It is NOT an attached physical conveyor port.
func receive_item(item: ItemDefinition, count: int) -> int:
	if (
		not enable_isolated_staging
		or not _live(_source)
		or not _live(_buffer)
		or not is_instance_valid(item)
		or not _bill.has(item)
		or count <= 0
	):
		return 0
	# Prevent moving inventory into itself or from an invalid source.
	if _source == _buffer:
		return 0
	return _source.transfer_to(_buffer, item, count)


# Read-only gate for a future physical input receiver. The existing isolated
# receive_item() path remains separately testable. This check never transfers.
func accepts_delivered_item(item: ItemDefinition, count: int = 1) -> bool:
	if (
		not enable_isolated_staging
		or not _live(_source)
		or not _live(_buffer)
		or not is_instance_valid(item)
		or not _bill.has(item)
		or count <= 0
	):
		return false
	var space: int = _buffer.get_available_space()
	return space < 0 or space >= count


# The coordinator may receive this inventory only in an isolated fixture.
# A valid buffer does NOT prove physical construction delivery or readiness.
func get_staged_inventory() -> InventoryComponent:
	if not _live(_buffer):
		return null
	return _buffer


func missing_for_bill() -> Dictionary:
	var missing: Dictionary = {}
	if not _live(_buffer):
		return missing
	for key: Variant in _bill.keys():
		var item: ItemDefinition = key as ItemDefinition
		var count: int = maxi(0, int(_bill[key]) - _buffer.get_amount(item))
		if count > 0:
			missing[item] = count
	return missing


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
