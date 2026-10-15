extends Node
class_name InventoryComponent


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

# Adds the requested quantity of an item to the inventory.

func add_item(item: ItemDefinition, amount: int) -> void:
	if item == null:
		return

	if amount <= 0:
		return

	var current_amount: int = int(items.get(item, 0))
	items[item] = current_amount + amount


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
