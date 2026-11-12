extends ItemPortComponent
class_name BlueprintConstructionStagingInputPort

# =============================================================================
# E3D5C4D — TEST-ONLY CONVEYOR INPUT TO STAGED CONSTRUCTION MATERIALS
# =============================================================================
# Inherits ItemPortComponent so the EXISTING ConveyorSegment,
# ConveyorBuildingTransfer and ConveyorTransportTimer validate reciprocal
# connection, endpoint geometry, direction, travel time and cargo inventory.
#
# Its override refuses items not in the definition-owned construction bill,
# or when staging is disabled/invalid/full. The actual transfer continues
# through ConveyorBuildingTransfer and InventoryComponent.transfer_to().
# Do not add to Main or Factory Testing Sandbox until provenance, metered
# power, workers, transactional recovery and save/load are implemented.

@export var enable_isolated_input: bool = false

var _staging: BlueprintConstructionMaterialStaging = null


func bind_staging(staging: BlueprintConstructionMaterialStaging) -> bool:
	if (
		not enable_isolated_input
		or not is_inside_tree()
		or is_instance_valid(_staging)
		or not _live(staging)
		or not staging.enable_isolated_staging
	):
		return false
	var buffer: InventoryComponent = staging.get_staged_inventory()
	if not _live(buffer):
		return false
	direction = ItemPortComponent.PortDirection.INPUT
	input_policy = ItemPortComponent.InputPolicy.ANY_ITEM
	inventory = buffer
	_staging = staging
	return true


func can_accept_item(item: ItemDefinition, amount: int = 1) -> bool:
	if (
		not enable_isolated_input
		or not _live(_staging)
		or not _live(inventory)
		or inventory != _staging.get_staged_inventory()
		or not _staging.accepts_delivered_item(item, amount)
	):
		return false
	return super.can_accept_item(item, amount)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
