
extends Node


# =============================================================================
# CHAT 07 — RECIPE INPUT ACCEPTANCE REGRESSION TEST
# =============================================================================

# Verifies that input eligibility is determined by the
# active manufacturing recipe.
#
# No world buildings or active game inventories are modified.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: INPUT ACCEPTANCE TEST =====")

	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var test_ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var original_recipe: ProductionRecipe = load(
		"res://data/recipes/test_smelting.tres"
	) as ProductionRecipe

	assert(test_ore != null)
	assert(test_ingot != null)
	assert(original_recipe != null)

	var producer: ProducerComponent = ProducerComponent.new()

	# =============================================================================
	# TEST A — NO RECIPE
	# =============================================================================

	assert(not producer.accepts_input_item(test_ore))

	print("PASS A: Missing recipe rejects inputs")

	# =============================================================================
	# TEST B — REQUIRED INGREDIENT ACCEPTED
	# =============================================================================

	producer.recipe = original_recipe

	assert(producer.accepts_input_item(test_ore))

	print("PASS B: Required ingredient accepted")

	# =============================================================================
	# TEST C — UNRELATED AND NULL ITEMS REJECTED
	# =============================================================================

	assert(not producer.accepts_input_item(test_ingot))
	assert(not producer.accepts_input_item(null))

	print("PASS C: Invalid item types rejected")

	# =============================================================================
	# TEST D — INVALID INGREDIENT REJECTED
	# =============================================================================

	var invalid_recipe: ProductionRecipe = ProductionRecipe.new()

	var invalid_input: ItemAmount = ItemAmount.new()
	invalid_input.item = test_ore
	invalid_input.amount = 0

	invalid_recipe.inputs.append(invalid_input)

	producer.recipe = invalid_recipe

	assert(not producer.accepts_input_item(test_ore))

	print("PASS D: Invalid ingredient quantity rejected")

	# =============================================================================
	# CREATE TEMPORARY ALTERNATIVE RECIPE
	# =============================================================================

	# This is only a test recipe.
	# It verifies that a different selected recipe changes
	# which item types the machine accepts.

	var alternative: ProductionRecipe = ProductionRecipe.new()
	alternative.recipe_id = &"input_acceptance_test"
	alternative.display_name = "Input Acceptance Test"
	alternative.production_time = 2.0

	var ingot_input: ItemAmount = ItemAmount.new()
	ingot_input.item = test_ingot
	ingot_input.amount = 2

	var ore_output: ItemAmount = ItemAmount.new()
	ore_output.item = test_ore
	ore_output.amount = 1

	alternative.inputs.append(ingot_input)
	alternative.outputs.append(ore_output)

	# =============================================================================
	# TEST E — CHANGING RECIPES CHANGES ACCEPTED ITEMS
	# =============================================================================

	producer.input_inventory = InventoryComponent.new()
	producer.output_inventory = InventoryComponent.new()

	producer.available_recipes.append(original_recipe)
	producer.available_recipes.append(alternative)

	producer.recipe = original_recipe

	assert(producer.select_recipe(alternative))

	assert(producer.accepts_input_item(test_ingot))
	assert(not producer.accepts_input_item(test_ore))

	print("PASS E: Recipe selection changes input eligibility")

	# =============================================================================
	# TEST F — ACCEPTANCE CHECK DOES NOT MODIFY INVENTORY
	# =============================================================================

	assert(producer.input_inventory.add_item(test_ingot, 3) == 3)
	assert(producer.output_inventory.add_item(test_ore, 4) == 4)

	producer.production_progress = 0.5

	assert(producer.accepts_input_item(test_ingot))
	assert(not producer.accepts_input_item(test_ore))

	assert(producer.input_inventory.get_amount(test_ingot) == 3)
	assert(producer.output_inventory.get_amount(test_ore) == 4)
	assert(producer.production_progress == 0.5)
	assert(producer.recipe == alternative)

	print("PASS F: Input checks do not modify production state")

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 6 INPUT ACCEPTANCE TESTS PASSED")
	print("==========================================")
