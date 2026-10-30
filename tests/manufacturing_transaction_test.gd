
extends Node


# =============================================================================
# MANUFACTURING TRANSACTION REGRESSION TEST
# =============================================================================

# Tests ProducerComponent.try_complete_recipe_cycle().
#
# Tests:
# A. Missing recipe
# B. Insufficient inputs
# C. Successful manufacturing
# D. Repeated production and resource conservation
# E. Full output inventory
# F. Duplicate input requirements
# G. Multiple output entries and capacity
# H. Shared input/output inventory rejection
# I. Invalid output entry
#
# All tests use isolated inventories and do not change
# the main game scene.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 06: MANUFACTURING TEST =====")

	# Load the existing ore item definition.
	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(test_ore != null, "Test Ore resource missing.")

	# Create a temporary ingot definition.
	# The permanent Test Ingot resource comes later.
	var test_ingot: ItemDefinition = ItemDefinition.new()

	test_ingot.item_id = &"temporary_test_ingot"
	test_ingot.display_name = "Temporary Test Ingot"

	# Create the manufacturing components.
	var producer: ProducerComponent = ProducerComponent.new()

	var input_inventory: InventoryComponent = InventoryComponent.new()
	var output_inventory: InventoryComponent = InventoryComponent.new()

	# Separate capacities as agreed in our architecture.
	input_inventory.max_capacity = 50
	output_inventory.max_capacity = 100

	producer.input_inventory = input_inventory
	producer.output_inventory = output_inventory


	# =============================================================================
	# TEST A — MISSING RECIPE
	# =============================================================================

	assert(
		not producer.try_complete_recipe_cycle(),
		"Manufacturing should reject a missing recipe."
	)

	print("PASS A: Missing recipe rejected")


	# =============================================================================
	# CONFIGURE MANUFACTURING RECIPE
	# =============================================================================

	# Create the recipe:
	# 2 Test Ore -> 1 Test Ingot

	var test_recipe: ProductionRecipe = ProductionRecipe.new()

	test_recipe.recipe_id = &"test_smelting"
	test_recipe.display_name = "Test Ore Smelting"
	test_recipe.production_time = 2.0

	var ore_input: ItemAmount = ItemAmount.new()
	ore_input.item = test_ore
	ore_input.amount = 2

	var ingot_output: ItemAmount = ItemAmount.new()
	ingot_output.item = test_ingot
	ingot_output.amount = 1

	test_recipe.inputs.append(ore_input)
	test_recipe.outputs.append(ingot_output)

	producer.recipe = test_recipe


	# =============================================================================
	# TEST B — INSUFFICIENT INPUTS
	# =============================================================================

	# Provide only one ore for a two-ore recipe.
	input_inventory.add_item(test_ore, 1)

	assert(
		not producer.try_complete_recipe_cycle(),
		"Production should reject insufficient ore."
	)

	assert(input_inventory.get_amount(test_ore) == 1)
	assert(output_inventory.get_amount(test_ingot) == 0)

	print("PASS B: Insufficient inputs blocked")


	# =============================================================================
	# TEST C — SUCCESSFUL MANUFACTURING
	# =============================================================================

	# Add one more ore, giving us exactly two.
	input_inventory.add_item(test_ore, 1)

	assert(
		producer.try_complete_recipe_cycle(),
		"Valid manufacturing cycle failed."
	)

	# Two ore should have been consumed.
	assert(input_inventory.get_amount(test_ore) == 0)

	# One ingot should have been produced.
	assert(output_inventory.get_amount(test_ingot) == 1)

	print("PASS C: Two ore converted into one ingot")


	# =============================================================================
	# TEST D — REPEATED PRODUCTION AND CONSERVATION
	# =============================================================================

	# Supply another eight ore.
	# Four additional smelting cycles should succeed.
	input_inventory.add_item(test_ore, 8)

	for cycle in range(4):
		assert(
			producer.try_complete_recipe_cycle(),
			"Repeated manufacturing cycle failed."
		)

	# Total ore supplied:
	# 2 from Test C + 8 from Test D = 10.
	#
	# Five ingots should now exist.
	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 5)

	# Another cycle must fail because no ore remains.
	assert(not producer.try_complete_recipe_cycle())

	# Resource conservation:
	# Remaining Ore + (Ingots * 2) = Original Ore
	var ore_equivalent: int = (
		input_inventory.get_amount(test_ore)
		+ output_inventory.get_amount(test_ingot) * 2
	)

	assert(
		ore_equivalent == 10,
		"Manufacturing resource conservation failed."
	)

	print("PASS D: Repeated production and conservation")


	# =============================================================================
	# TEST E — FULL OUTPUT INVENTORY
	# =============================================================================

	# Five ingots currently exist.
	# Reduce capacity to five to simulate full storage.
	output_inventory.max_capacity = 5

	# Provide enough ore for another cycle.
	input_inventory.add_item(test_ore, 2)

	assert(
		not producer.try_complete_recipe_cycle(),
		"Full output inventory should block production."
	)

	# The blocked cycle must not consume ore.
	assert(input_inventory.get_amount(test_ore) == 2)
	assert(output_inventory.get_amount(test_ingot) == 5)

	# Restore output capacity.
	output_inventory.max_capacity = 100

	print("PASS E: Full output blocked without resource loss")


	# =============================================================================
	# TEST F — DUPLICATE INPUT REQUIREMENTS
	# =============================================================================

	# Add another Test Ore input requirement of two.
	#
	# The recipe now requires four ore total.
	var additional_input: ItemAmount = ItemAmount.new()

	additional_input.item = test_ore
	additional_input.amount = 2

	test_recipe.inputs.append(additional_input)

	# Only two ore are currently available.
	assert(
		not producer.try_complete_recipe_cycle(),
		"Duplicate input amounts were not combined."
	)

	# Supply two additional ore.
	input_inventory.add_item(test_ore, 2)

	assert(
		producer.try_complete_recipe_cycle(),
		"Combined input requirements should succeed."
	)

	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 6)

	# Restore the original two-ore recipe.
	test_recipe.inputs.remove_at(1)

	print("PASS F: Duplicate input requirements handled")


	# =============================================================================
	# TEST G — MULTIPLE OUTPUT ENTRIES
	# =============================================================================

	# Add another output entry producing two ingots.
	#
	# Total output requirement:
	# 1 ingot + 2 ingots = 3 units.
	var additional_output: ItemAmount = ItemAmount.new()

	additional_output.item = test_ingot
	additional_output.amount = 2

	test_recipe.outputs.append(additional_output)

	# Six ingots are already stored.
	# Capacity seven leaves only one free slot.
	output_inventory.max_capacity = 7

	input_inventory.add_item(test_ore, 2)

	assert(
		not producer.try_complete_recipe_cycle(),
		"Insufficient multi-output capacity was accepted."
	)

	assert(input_inventory.get_amount(test_ore) == 2)
	assert(output_inventory.get_amount(test_ingot) == 6)

	# Increase capacity to nine.
	# There are now exactly three free spaces.
	output_inventory.max_capacity = 9

	assert(
		producer.try_complete_recipe_cycle(),
		"Exact multi-output capacity should succeed."
	)

	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 9)

	# Restore the original one-ingot recipe.
	test_recipe.outputs.remove_at(1)
	output_inventory.max_capacity = 100

	print("PASS G: Multiple outputs respect capacity")


	# =============================================================================
	# TEST H — SHARED INVENTORY REJECTION
	# =============================================================================

	# The smelter must never use the exact same inventory
	# for both input materials and finished outputs.

	input_inventory.add_item(test_ore, 2)

	producer.output_inventory = input_inventory

	assert(
		not producer.try_complete_recipe_cycle(),
		"Shared input/output inventory should be rejected."
	)

	assert(input_inventory.get_amount(test_ore) == 2)
	assert(output_inventory.get_amount(test_ingot) == 9)

	# Restore the proper output inventory reference.
	producer.output_inventory = output_inventory

	print("PASS H: Shared inventory rejected")


	# =============================================================================
	# TEST I — INVALID OUTPUT ENTRY
	# =============================================================================

	# Add an invalid output entry with no item.
	var invalid_output: ItemAmount = ItemAmount.new()

	test_recipe.outputs.append(invalid_output)

	assert(
		not producer.try_complete_recipe_cycle(),
		"Invalid output entry should block manufacturing."
	)

	# Verify nothing was consumed or produced.
	assert(input_inventory.get_amount(test_ore) == 2)
	assert(output_inventory.get_amount(test_ingot) == 9)

	print("PASS I: Invalid output blocked safely")


	# =============================================================================
	# TEST COMPLETE
	# =============================================================================

	print("=====================================")
	print("ALL MANUFACTURING TRANSACTION TESTS PASSED")
	print("=====================================")

	# Clean up temporary nodes.
	producer.free()
	input_inventory.free()
	output_inventory.free()
