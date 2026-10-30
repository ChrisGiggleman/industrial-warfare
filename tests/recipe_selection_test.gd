
extends Node


# =============================================================================
# RECIPE SELECTION REGRESSION TEST
# =============================================================================

# Tests ProducerComponent.select_recipe() without changing
# any resources in the active game scene.
#
# Uses the existing Test Ore, Test Ingot, and smelting recipe.
#
# Temporary recipes exist only during this test.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: RECIPE SELECTION TEST =====")

	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var test_ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var original_recipe: ProductionRecipe = load(
		"res://data/recipes/test_smelting.tres"
	) as ProductionRecipe

	assert(test_ore != null, "Test Ore missing.")
	assert(test_ingot != null, "Test Ingot missing.")
	assert(original_recipe != null, "Smelting recipe missing.")

	# =============================================================================
	# CREATE ISOLATED MANUFACTURING COMPONENTS
	# =============================================================================

	var producer: ProducerComponent = ProducerComponent.new()
	var input_inventory: InventoryComponent = InventoryComponent.new()
	var output_inventory: InventoryComponent = InventoryComponent.new()

	input_inventory.max_capacity = 50
	output_inventory.max_capacity = 100

	producer.input_inventory = input_inventory
	producer.output_inventory = output_inventory
	producer.recipe = original_recipe

	# =============================================================================
	# CREATE TEMPORARY ALTERNATIVE RECIPE
	# =============================================================================

	# This deliberately uses a different input quantity
	# to prove production follows the selected recipe.
	#
	# This is not a permanent game balance decision.

	var alternate_recipe: ProductionRecipe = ProductionRecipe.new()
	alternate_recipe.recipe_id = &"test_alternative"
	alternate_recipe.display_name = "Alternative Test Smelting"
	alternate_recipe.production_time = 3.0

	var alternate_input: ItemAmount = ItemAmount.new()
	alternate_input.item = test_ore
	alternate_input.amount = 1

	var alternate_output: ItemAmount = ItemAmount.new()
	alternate_output.item = test_ingot
	alternate_output.amount = 1

	alternate_recipe.inputs.append(alternate_input)
	alternate_recipe.outputs.append(alternate_output)

	# =============================================================================
	# CREATE INVALID AND UNSUPPORTED RECIPES
	# =============================================================================

	var unsupported_recipe: ProductionRecipe = ProductionRecipe.new()
	unsupported_recipe.inputs.append(alternate_input)
	unsupported_recipe.outputs.append(alternate_output)

	var empty_recipe: ProductionRecipe = ProductionRecipe.new()

	var zero_time_recipe: ProductionRecipe = ProductionRecipe.new()
	zero_time_recipe.production_time = 0.0
	zero_time_recipe.inputs.append(alternate_input)
	zero_time_recipe.outputs.append(alternate_output)

	# Register supported recipes, including two deliberately
	# invalid ones, to test recipe validation.

	producer.available_recipes.append(original_recipe)
	producer.available_recipes.append(alternate_recipe)
	producer.available_recipes.append(empty_recipe)
	producer.available_recipes.append(zero_time_recipe)

	# =============================================================================
	# TEST A — CURRENT RECIPE ACCEPTED
	# =============================================================================

	assert(producer.select_recipe(original_recipe))
	assert(producer.recipe == original_recipe)

	print("PASS A: Current recipe accepted")

	# =============================================================================
	# TEST B — NULL RECIPE REJECTED
	# =============================================================================

	assert(not producer.select_recipe(null))
	assert(producer.recipe == original_recipe)

	print("PASS B: Null recipe rejected")

	# =============================================================================
	# TEST C — UNSUPPORTED RECIPE REJECTED
	# =============================================================================

	assert(not producer.select_recipe(unsupported_recipe))
	assert(producer.recipe == original_recipe)

	print("PASS C: Unsupported recipe rejected")

	# =============================================================================
	# TEST D — EMPTY RECIPE REJECTED
	# =============================================================================

	assert(not producer.select_recipe(empty_recipe))
	assert(producer.recipe == original_recipe)

	print("PASS D: Empty recipe rejected")

	# =============================================================================
	# TEST E — INVALID PRODUCTION TIME REJECTED
	# =============================================================================

	assert(not producer.select_recipe(zero_time_recipe))
	assert(producer.recipe == original_recipe)

	print("PASS E: Invalid production time rejected")

	# =============================================================================
	# TEST F — STORED INPUT MATERIALS BLOCK RECIPE CHANGE
	# =============================================================================

	assert(input_inventory.add_item(test_ore, 3) == 3)

	producer.production_progress = 0.75

	assert(not producer.select_recipe(alternate_recipe))
	assert(producer.recipe == original_recipe)
	assert(input_inventory.get_amount(test_ore) == 3)
	assert(producer.production_progress == 0.75)

	print("PASS F: Stored ingredients protected")

	# =============================================================================
	# TEST G — VALID RECIPE SWITCH PRESERVES FINISHED PRODUCTS
	# =============================================================================

	# Clear the previous ingredients safely.
	assert(input_inventory.remove_item(test_ore, 3))

	# Store finished products from the previous recipe.
	assert(output_inventory.add_item(test_ingot, 2) == 2)

	producer.production_progress = 1.5

	assert(producer.select_recipe(alternate_recipe))
	assert(producer.recipe == alternate_recipe)
	assert(producer.production_progress == 0.0)
	assert(producer.production_status == "Recipe Changed")
	assert(input_inventory.get_total_amount() == 0)
	assert(output_inventory.get_amount(test_ingot) == 2)

	print("PASS G: Recipe switched without item loss")

	# =============================================================================
	# TEST H — NEW RECIPE CONTROLS MANUFACTURING
	# =============================================================================

	# Alternative test recipe consumes only 1 ore.
	assert(input_inventory.add_item(test_ore, 1) == 1)
	assert(producer.try_complete_recipe_cycle())

	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 3)

	print("PASS H: New recipe manufactured correctly")

	# =============================================================================
	# TEST I — SWITCH BACK TO ORIGINAL RECIPE
	# =============================================================================

	assert(producer.select_recipe(original_recipe))
	assert(producer.recipe == original_recipe)
	assert(output_inventory.get_amount(test_ingot) == 3)

	print("PASS I: Original recipe restored")

	# =============================================================================
	# TEST J — ORIGINAL MANUFACTURING STILL WORKS
	# =============================================================================

	# The original recipe must still consume 2 ore.
	assert(input_inventory.add_item(test_ore, 2) == 2)
	assert(producer.try_complete_recipe_cycle())

	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 4)

	print("PASS J: Original manufacturing preserved")

	# =============================================================================
	# FINAL TEST RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 10 RECIPE SELECTION TESTS PASSED")
	print("==========================================")
