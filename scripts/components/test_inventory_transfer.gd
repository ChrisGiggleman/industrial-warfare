
extends Node

# =============================================================================
# INVENTORY TRANSFER TEST
# =============================================================================

# Chat 05 - Step 4.2A
#
# Verifies that InventoryComponent.transfer_to()
# correctly handles a partially full destination.
#
# This is a temporary development test.
# It does not modify the main game scene.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	# Load our existing Test Ore item definition.
	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(test_ore != null, "Test Ore resource was not found.")

	# Create two independent inventory components.
	var source: InventoryComponent = InventoryComponent.new()
	var destination: InventoryComponent = InventoryComponent.new()

	# Apply the same capacities used in our game.
	source.max_capacity = 50
	destination.max_capacity = 200

	# Initialize the starting inventories.
	source.add_item(test_ore, 10)
	destination.add_item(test_ore, 198)

	# =============================================================================
	# EXECUTE TRANSFER TEST
	# =============================================================================

	print("===== INVENTORY TRANSFER TEST =====")

	print("Source Before: ", source.get_amount(test_ore))
	print("Destination Before: ", destination.get_amount(test_ore))

	# Attempt to transfer five units.
	# Only two should fit in the destination.
	var transferred: int = source.transfer_to(
		destination,
		test_ore,
		5
	)

	print("Transferred: ", transferred)
	print("Source After: ", source.get_amount(test_ore))
	print("Destination After: ", destination.get_amount(test_ore))

	# =============================================================================
	# VALIDATE RESULTS
	# =============================================================================

	assert(transferred == 2, "Incorrect transfer amount.")
	assert(source.get_amount(test_ore) == 8, "Incorrect source amount.")
	assert(destination.get_amount(test_ore) == 200, "Incorrect destination amount.")

	# Ensure total resources remain unchanged.
	var total: int = (
		source.get_amount(test_ore)
		+ destination.get_amount(test_ore)
	)

	assert(total == 208, "Resources were lost or duplicated.")

	print("PASS: Partial transfer and resource conservation")

	
	# =============================================================================
	# TEST B — DESTINATION INVENTORY FULL
	# =============================================================================

	# The destination already contains 200 units, which is its
	# maximum capacity.
	#
	# Attempting another transfer should:
	# - Transfer zero items.
	# - Leave the source unchanged.
	# - Leave the destination unchanged.
	# - Preserve the total number of resources.

	print("")
	print("===== FULL INVENTORY TRANSFER TEST =====")

	var source_before: int = source.get_amount(test_ore)
	var destination_before: int = destination.get_amount(test_ore)

	var full_transfer: int = source.transfer_to(
		destination,
		test_ore,
		5
	)

	print("Transferred: ", full_transfer)
	print("Source After: ", source.get_amount(test_ore))
	print("Destination After: ", destination.get_amount(test_ore))

	assert(full_transfer == 0, "Full destination accepted items.")
	assert(
		source.get_amount(test_ore) == source_before,
		"Source changed despite blocked transfer."
	)
	assert(
		destination.get_amount(test_ore) == destination_before,
		"Full destination inventory changed."
	)

	assert(
		source.get_total_amount() + destination.get_total_amount() == 208,
		"Item conservation failed."
	)

	print("PASS: Full destination correctly blocked transfer")


	# =============================================================================
	# TEST C — EMPTY SOURCE INVENTORY
	# =============================================================================

	# Verify that transferring from an empty inventory:
	# - Moves zero items.
	# - Does not change the destination.
	# - Does not create new resources.
	#
	# We create a separate empty inventory so the previous
	# test results remain unchanged.

	print("")
	print("===== EMPTY SOURCE INVENTORY TEST =====")

	var empty_source: InventoryComponent = InventoryComponent.new()
	empty_source.max_capacity = 50

	# Record the destination amount before attempting transfer.
	var destination_before_empty: int = destination.get_amount(test_ore)

	# Attempt to transfer five units from an empty inventory.
	var empty_transfer: int = empty_source.transfer_to(
		destination,
		test_ore,
		5
	)

	print("Transferred: ", empty_transfer)
	print("Empty Source After: ", empty_source.get_amount(test_ore))
	print("Destination After: ", destination.get_amount(test_ore))

	# =============================================================================
	# VALIDATE EMPTY SOURCE TEST
	# =============================================================================

	assert(empty_transfer == 0, "Empty inventory transferred items.")

	assert(
		empty_source.get_amount(test_ore) == 0,
		"Empty source inventory changed."
	)

	assert(
		destination.get_amount(test_ore) == destination_before_empty,
		"Destination changed despite empty source."
	)

	print("PASS: Empty source correctly blocked transfer")

	
	# =============================================================================
	# TEST D — INVALID TRANSFER REQUESTS
	# =============================================================================

	# Verifies that InventoryComponent rejects:
	# - Transfers to itself.
	# - Missing destination inventories.
	# - Transfers requesting zero items.
	#
	# All invalid requests must return 0 without changing
	# the existing inventory contents.

	print("")
	print("===== INVALID TRANSFER TEST =====")

	# Record current quantities before testing.
	var source_before_invalid: int = source.get_amount(test_ore)
	var destination_before_invalid: int = destination.get_amount(test_ore)

	# =============================================================================
	# TEST D1 — SELF TRANSFER
	# =============================================================================

	# An inventory must never transfer items into itself.
	var self_transfer: int = source.transfer_to(
		source,
		test_ore,
		5
	)

	print("Self Transfer: ", self_transfer)

	assert(self_transfer == 0, "Self-transfer was allowed.")

	# =============================================================================
	# TEST D2 — NULL DESTINATION
	# =============================================================================

	# A missing destination cannot accept items.
	var null_transfer: int = source.transfer_to(
		null,
		test_ore,
		5
	)

	print("Null Destination Transfer: ", null_transfer)

	assert(null_transfer == 0, "Null destination was accepted.")

	# =============================================================================
	# TEST D3 — ZERO QUANTITY
	# =============================================================================

	# Requesting zero units must not trigger a transfer.
	var zero_transfer: int = source.transfer_to(
		destination,
		test_ore,
		0
	)

	print("Zero Quantity Transfer: ", zero_transfer)

	assert(zero_transfer == 0, "Zero quantity transfer was allowed.")

	# =============================================================================
	# VERIFY RESOURCE CONSERVATION
	# =============================================================================

	# Neither inventory should change after invalid requests.
	assert(
		source.get_amount(test_ore) == source_before_invalid,
		"Source changed during invalid transfer tests."
	)

	assert(
		destination.get_amount(test_ore) == destination_before_invalid,
		"Destination changed during invalid transfer tests."
	)

	print("PASS: Invalid transfers correctly rejected")


	# Clean up the additional test inventory.
	empty_source.free()

	print("===================================")

	# Clean up the temporary test inventories.
	source.free()
	destination.free()
