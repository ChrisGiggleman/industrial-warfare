extends Node
class_name InventoryComponent



# =============================================================================
# INVENTORY SETTINGS
# =============================================================================

# Maximum number of item units this inventory can hold.
#
# A value of 0 means unlimited capacity.
# This preserves compatibility with existing buildings until
# capacity limits are explicitly configured.
#
# Capacity is shared between all item types.
# Example: 30 Iron Ore + 20 Copper Ore = 50 total units.

@export_range(0, 100000, 1) var max_capacity: int = 0


# =============================================================================
# INVENTORY STATE
# =============================================================================

# Stores ItemDefinition resources and their current quantities.
#
# Key   = ItemDefinition
# Value = integer quantity

var items: Dictionary = {}



# =============================================================================
# ADD ITEMS
# =============================================================================

# Attempts to add the requested quantity of an item.
#
# Returns the number of units actually accepted.
#
# If the inventory has limited capacity, only the amount that fits
# will be added. Remaining units are rejected.
#
# Examples:
# - Capacity 50, stored 48, add 5 -> accepts 2
# - Capacity 50, stored 50, add 5 -> accepts 0
# - Unlimited inventory, add 5 -> accepts 5

func add_item(item: ItemDefinition, amount: int) -> int:
	if item == null:
		return 0

	if amount <= 0:
		return 0

	var accepted_amount: int = amount
	var available_space: int = get_available_space()

	# A value of -1 means the inventory has unlimited capacity.
	if available_space >= 0:
		accepted_amount = mini(amount, available_space)

	# No space remains, so reject the incoming items.
	if accepted_amount <= 0:
		return 0

	var current_amount: int = get_amount(item)

	items[item] = current_amount + accepted_amount

	return accepted_amount


# =============================================================================
# REMOVE ITEMS
# =============================================================================

# Removes the requested quantity when enough of the item is available.
# Returns true when the removal succeeds.

func remove_item(item: ItemDefinition, amount: int) -> bool:
	if item == null:
		return false

	if amount <= 0:
		return false

	var current_amount: int = get_amount(item)

	if current_amount < amount:
		return false

	var remaining_amount: int = current_amount - amount

	if remaining_amount == 0:
		items.erase(item)
	else:
		items[item] = remaining_amount

	return true


# =============================================================================
# ITEM QUANTITY
# =============================================================================

# Returns the current quantity of the requested item.

func get_amount(item: ItemDefinition) -> int:
	if item == null:
		return 0

	return int(items.get(item, 0))


# =============================================================================
# INVENTORY CHECK
# =============================================================================

# Returns true when the inventory contains at least the requested quantity.

func has_amount(item: ItemDefinition, amount: int) -> bool:
	if item == null:
		return false

	if amount <= 0:
		return false

	return get_amount(item) >= amount


# =============================================================================
# TOTAL INVENTORY AMOUNT
# =============================================================================

# Returns the combined quantity of all items in this inventory.
# This value is used to calculate total occupied capacity.

func get_total_amount() -> int:
	var total: int = 0

	for item in items.keys():
		total += int(items[item])

	return total


# =============================================================================
# AVAILABLE INVENTORY SPACE
# =============================================================================

# Returns the number of additional item units that can fit.
#
# A return value of -1 means unlimited capacity.

func get_available_space() -> int:
	if max_capacity == 0:
		return -1

	return maxi(0, max_capacity - get_total_amount())


# =============================================================================
# INVENTORY FULL CHECK
# =============================================================================

# Returns true when an inventory with a capacity limit is full.
# Unlimited inventories never report themselves as full.

func is_full() -> bool:
	if max_capacity == 0:
		return false

	return get_total_amount() >= max_capacity


# =============================================================================
# INVENTORY TRANSFER
# =============================================================================

# Transfers items from this inventory into another InventoryComponent.
#
# This function handles:
# - Source inventory availability.
# - Destination inventory capacity.
# - Partial transfers when the destination is nearly full.
# - Prevention of transfers to the same inventory.
# - Returning the number of units successfully transferred.
#
# Example:
# Source contains 50 Iron Ore.
# Destination has only 3 free spaces.
# Requesting 5 Iron Ore transfers only 3.
#
# Returns 0 when the transfer cannot occur.
#
# Future logistics systems will call this function without needing
# to implement inventory accounting themselves.

func transfer_to(
	destination: InventoryComponent,
	item: ItemDefinition,
	amount: int
) -> int:

	# =============================================================================
	# VALIDATE TRANSFER
	# =============================================================================

	# Reject missing, deleted, or identical destination inventories.
	if not is_instance_valid(destination):
		return 0

	if destination == self:
		return 0

	# Reject invalid items or quantities.
	if item == null or amount <= 0:
		return 0

	# =============================================================================
	# CALCULATE TRANSFER QUANTITY
	# =============================================================================

	# Never transfer more items than the source actually contains.
	var transferable_amount: int = mini(
		amount,
		get_amount(item)
	)

	# Respect the destination's available capacity.
	# -1 represents unlimited storage.
	var destination_space: int = destination.get_available_space()

	if destination_space >= 0:
		transferable_amount = mini(
			transferable_amount,
			destination_space
		)

	# Nothing can be transferred.
	if transferable_amount <= 0:
		return 0

	# =============================================================================
	# EXECUTE TRANSFER
	# =============================================================================

	# Remove items from the source inventory.
	if not remove_item(item, transferable_amount):
		return 0

	# Add the removed items to the destination inventory.
	var accepted_amount: int = destination.add_item(
		item,
		transferable_amount
	)

	# =============================================================================
	# RESTORE UNACCEPTED ITEMS
	# =============================================================================

	# If the destination accepts fewer items than requested,
	# return the difference to the source to prevent item loss.
	var rejected_amount: int = transferable_amount - accepted_amount

	if rejected_amount > 0:
		add_item(item, rejected_amount)

	# Return the number of items actually moved.
	return accepted_amount
