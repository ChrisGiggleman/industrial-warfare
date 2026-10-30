
extends Node


# =============================================================================
# RECIPE OUTPUT CAPACITY TEST
# =============================================================================

# Tests ProducerComponent.can_store_recipe_outputs().
#
# Verifies:
# - Missing or invalid production configurations.
# - Empty and nearly full output inventories.
# - Full inventory protection.
# - Recipes with multiple outputs.
# - Unlimited inventory capacity.
# - No resource consumption or generation during checking.
#
# This test does not modify the main game scene.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 06: OUTPUT CAPACITY TEST =====")

	# Load the existing Test Ore definition.
	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(test_ore != null, "Test Ore resource missing.")

	# Create a temporary processed item for testing.
	# We will create the permanent Test Ingot resource later.
	var test_ingot: ItemDefinition = ItemDefinition.new()
	test_ingot.item_id = &"temporary_test_ingot"
	test_ingot.display_name = "Temporary Test Ingot"

	# Create isolated production and inventory components.
	var producer: ProducerComponent = ProducerComponent.new()
	var output_inventory: InventoryComponent = InventoryComponent.new()

	output_inventory.max_capacity = 100
	producer.output_inventory = output_inventory


	# =============================================================================
	# TEST A — MISSING RECIPE
	# =============================================================================

	assert(
		not producer.can_store_recipe_outputs(),
		"Missing recipe should block production."
	)

	print("PASS A: Missing recipe rejected")


	# =============================================================================
	# TEST B — EMPTY RECIPE OUTPUTS
	# =============================================================================

	var test_recipe: ProductionRecipe = ProductionRecipe.new()
	producer.recipe = test_recipe

	assert(
		not producer.can_store_recipe_outputs(),
		"Recipe without outputs should be rejected."
	)

	print("PASS B: Empty recipe outputs rejected")


	# =============================================================================
	# CONFIGURE SINGLE-OUTPUT RECIPE
	# =============================================================================

	# Recipe produces one Test Ingot.
	var ingot_output: ItemAmount = ItemAmount.new()
	ingot_output.item = test_ingot
	ingot_output.amount = 1

	test_recipe.outputs.append(ingot_output)


	# =============================================================================
	# TEST C — MISSING OUTPUT INVENTORY
	# =============================================================================

	producer.output_inventory = null

	assert(
		not producer.can_store_recipe_outputs(),
		"Missing output inventory should block production."
	)

	producer.output_inventory = output_inventory

	print("PASS C: Missing output inventory rejected")


	# =============================================================================
	# TEST D — EMPTY OUTPUT INVENTORY
	# =============================================================================

	assert(
		producer.can_store_recipe_outputs(),
		"Empty output inventory should accept production."
	)

	print("PASS D: Empty output inventory accepted")


	# =============================================================================
	# TEST E — ONE FREE INVENTORY SLOT
	# =============================================================================

	# Fill 99 of the 100 available slots.
	output_inventory.add_item(test_ore, 99)

	assert(
		producer.can_store_recipe_outputs(),
		"One remaining slot should accept one ingot."
	)

	print("PASS E: One free slot accepted")


	# =============================================================================
	# TEST F — OUTPUT INVENTORY FULL
	# =============================================================================

	# Fill the final available inventory slot.
	output_inventory.add_item(test_ore, 1)

	assert(
		output_inventory.is_full(),
		"Output inventory should be full."
	)

	assert(
		not producer.can_store_recipe_outputs(),
		"Full output inventory should block production."
	)

	print("PASS F: Full output inventory blocked")


	# =============================================================================
	# TEST G — MULTIPLE OUTPUTS, INSUFFICIENT CAPACITY
	# =============================================================================

	# Free two inventory slots.
	output_inventory.remove_item(test_ore, 2)

	# Change the recipe to produce:
	# - 2 Test Ingots
	# - 1 Test Ore
	#
	# The recipe now requires three available slots.
	ingot_output.amount = 2

	var ore_output: ItemAmount = ItemAmount.new()
	ore_output.item = test_ore
	ore_output.amount = 1

	test_recipe.outputs.append(ore_output)

	assert(
		not producer.can_store_recipe_outputs(),
		"Two free slots cannot hold three output units."
	)

	print("PASS G: Multiple outputs correctly blocked")


	# =============================================================================
	# TEST H — EXACT OUTPUT CAPACITY
	# =============================================================================

	# Free one additional slot.
	# The inventory now contains 97 / 100 items.
	output_inventory.remove_item(test_ore, 1)

	assert(
		producer.can_store_recipe_outputs(),
		"Three available slots should accept three outputs."
	)

	print("PASS H: Exact output capacity accepted")


	# =============================================================================
	# TEST I — OUTPUT CHECK DOES NOT MODIFY INVENTORY
	# =============================================================================

	var stored_before: int = output_inventory.get_total_amount()

	assert(producer.can_store_recipe_outputs())

	assert(
		output_inventory.get_total_amount() == stored_before,
		"Capacity checking unexpectedly modified inventory."
	)

	assert(
		output_inventory.get_amount(test_ingot) == 0,
		"Capacity checking unexpectedly produced ingots."
	)

	print("PASS I: Inventory remains unchanged")


	# =============================================================================
	# TEST J — UNLIMITED OUTPUT CAPACITY
	# =============================================================================

	# Capacity zero represents unlimited storage.
	output_inventory.max_capacity = 0

	assert(
		producer.can_store_recipe_outputs(),
		"Unlimited inventory should accept valid outputs."
	)

	print("PASS J: Unlimited output capacity accepted")


	# =============================================================================
	# TEST K — INVALID OUTPUT ENTRY
	# =============================================================================

	# Add an output entry with no ItemDefinition.
	var invalid_output: ItemAmount = ItemAmount.new()

	test_recipe.outputs.append(invalid_output)

	assert(
		not producer.can_store_recipe_outputs(),
		"Invalid output entries must block production."
	)

	print("PASS K: Invalid output entry rejected")


	# =============================================================================
	# TEST COMPLETE
	# =============================================================================

	print("=====================================")
	print("ALL OUTPUT CAPACITY TESTS PASSED")
	print("=====================================")

	# Free temporary test nodes.
	producer.free()
	output_inventory.free()
