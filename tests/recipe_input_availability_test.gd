
extends Node


# =============================================================================
# RECIPE INPUT AVAILABILITY TEST
# =============================================================================

# Verifies that ProducerComponent correctly checks recipe inputs.
#
# Test cases:
# A. Missing recipe
# B. Empty recipe inputs
# C. Missing input inventory
# D. Insufficient resources
# E. Exact required quantity
# F. More than required
# G. Duplicate ingredient entries
# H. Inventory remains unchanged
#
# This test does not change the main game scene.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:
	print("\n===== CHAT 06: RECIPE INPUT TEST =====")

	# Load our existing Test Ore resource.
	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(test_ore != null, "Test Ore resource missing.")

	# Create independent test components.
	var producer: ProducerComponent = ProducerComponent.new()
	var input_inventory: InventoryComponent = InventoryComponent.new()

	input_inventory.max_capacity = 50
	producer.input_inventory = input_inventory


	# =============================================================================
	# TEST A — MISSING RECIPE
	# =============================================================================

	assert(
		not producer.has_required_inputs(),
		"Missing recipe should return false."
	)

	print("PASS A: Missing recipe rejected")


	# =============================================================================
	# TEST B — EMPTY RECIPE INPUTS
	# =============================================================================

	var test_recipe: ProductionRecipe = ProductionRecipe.new()

	producer.recipe = test_recipe

	assert(
		not producer.has_required_inputs(),
		"Empty recipe inputs should return false."
	)

	print("PASS B: Empty recipe rejected")


	# =============================================================================
	# CONFIGURE TEST RECIPE
	# =============================================================================

	# Recipe requires two Test Ore.
	var ore_requirement: ItemAmount = ItemAmount.new()

	ore_requirement.item = test_ore
	ore_requirement.amount = 2

	test_recipe.inputs.append(ore_requirement)


	# =============================================================================
	# TEST C — MISSING INPUT INVENTORY
	# =============================================================================

	producer.input_inventory = null

	assert(
		not producer.has_required_inputs(),
		"Missing input inventory should return false."
	)

	producer.input_inventory = input_inventory

	print("PASS C: Missing inventory rejected")


	# =============================================================================
	# TEST D — INSUFFICIENT RESOURCES
	# =============================================================================

	# Inventory starts empty.
	assert(not producer.has_required_inputs())

	# Add only one ore.
	input_inventory.add_item(test_ore, 1)

	assert(
		not producer.has_required_inputs(),
		"One ore should not satisfy a two-ore recipe."
	)

	print("PASS D: Insufficient ore rejected")


	# =============================================================================
	# TEST E — EXACT REQUIRED QUANTITY
	# =============================================================================

	# Add another ore, bringing the total to two.
	input_inventory.add_item(test_ore, 1)

	assert(
		producer.has_required_inputs(),
		"Two ore should satisfy the recipe."
	)

	print("PASS E: Exact required quantity accepted")


	# =============================================================================
	# TEST F — EXTRA RESOURCES
	# =============================================================================

	# Increase inventory to ten ore.
	input_inventory.add_item(test_ore, 8)

	assert(
		producer.has_required_inputs(),
		"Ten ore should satisfy the recipe."
	)

	print("PASS F: Additional ore accepted")


	# =============================================================================
	# TEST G — DUPLICATE INGREDIENT ENTRIES
	# =============================================================================

	# Add another requirement for the same item.
	# Total requirement becomes 2 + 9 = 11 ore.
	var extra_requirement: ItemAmount = ItemAmount.new()

	extra_requirement.item = test_ore
	extra_requirement.amount = 9

	test_recipe.inputs.append(extra_requirement)

	# Inventory contains only ten ore.
	assert(
		not producer.has_required_inputs(),
		"Duplicate requirements must be combined."
	)

	# Adding one ore should now satisfy the recipe.
	input_inventory.add_item(test_ore, 1)

	assert(
		producer.has_required_inputs(),
		"Combined requirements should accept eleven ore."
	)

	print("PASS G: Duplicate requirements handled")


	# =============================================================================
	# TEST H — RESOURCE CONSERVATION
	# =============================================================================

	# Availability checks must never consume materials.
	assert(
		input_inventory.get_amount(test_ore) == 11,
		"Input checking unexpectedly changed inventory."
	)

	print("PASS H: Inventory unchanged")


	# =============================================================================
	# CLEANUP
	# =============================================================================

	producer.free()
	input_inventory.free()

	print("=====================================")
	print("ALL RECIPE INPUT TESTS PASSED")
	print("=====================================")
