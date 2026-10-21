
extends Node


# =============================================================================
# CHAT 06 — TIMED MANUFACTURING REGRESSION TEST
# =============================================================================

# Tests ProducerComponent's manufacturing timer.
#
# This test manually simulates frame updates.
# The producer is NOT added to the scene tree, preventing
# Godot from advancing its timer automatically.
#
# Test cases:
# A. Production starts with valid inputs.
# B. No output before the cycle completes.
# C. Completed cycle consumes ore and creates an ingot.
# D. Missing inputs stop production.
# E. Production resumes when inputs become available.
# F. Full output inventory interrupts production.
# G. Production resumes after output space is freed.
# H. Total resource conservation.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 06: TIMED MANUFACTURING TEST =====")

	# Load our existing ore definition.
	var test_ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(test_ore != null, "Test Ore resource missing.")

	# Create a temporary ingot item for isolated testing.
	var test_ingot: ItemDefinition = ItemDefinition.new()

	test_ingot.item_id = &"timed_test_ingot"
	test_ingot.display_name = "Timed Test Ingot"

	# Create separate inventories.
	var input_inventory: InventoryComponent = InventoryComponent.new()
	var output_inventory: InventoryComponent = InventoryComponent.new()

	input_inventory.max_capacity = 50
	output_inventory.max_capacity = 100

	# Create a test recipe.
	var recipe: ProductionRecipe = ProductionRecipe.new()

	recipe.recipe_id = &"timed_test_smelting"
	recipe.display_name = "Timed Test Smelting"
	recipe.production_time = 2.0

	# Two ore required per cycle.
	var ore_input: ItemAmount = ItemAmount.new()
	ore_input.item = test_ore
	ore_input.amount = 2

	# One ingot produced per cycle.
	var ingot_output: ItemAmount = ItemAmount.new()
	ingot_output.item = test_ingot
	ingot_output.amount = 1

	recipe.inputs.append(ore_input)
	recipe.outputs.append(ingot_output)

	# Configure the producer.
	var producer: ProducerComponent = ProducerComponent.new()

	producer.recipe = recipe
	producer.input_inventory = input_inventory
	producer.output_inventory = output_inventory

	# Supply two ore for the first cycle.
	input_inventory.add_item(test_ore, 2)


	# =============================================================================
	# TEST A — PRODUCTION STARTS
	# =============================================================================

	# Simulate half a second of production.
	producer._process(0.5)

	assert(producer.production_status == "Producing")

	assert(
		is_equal_approx(producer.production_progress, 0.5),
		"Production progress should equal 0.5 seconds."
	)

	assert(input_inventory.get_amount(test_ore) == 2)
	assert(output_inventory.get_amount(test_ingot) == 0)

	print("PASS A: Manufacturing timer started")


	# =============================================================================
	# TEST B — NO EARLY PRODUCTION
	# =============================================================================

	# Advance another second.
	# Total elapsed production time is now 1.5 seconds.
	producer._process(1.0)

	assert(
		is_equal_approx(producer.production_progress, 1.5),
		"Production progress should equal 1.5 seconds."
	)

	assert(input_inventory.get_amount(test_ore) == 2)
	assert(output_inventory.get_amount(test_ingot) == 0)

	print("PASS B: No manufacturing before cycle completion")


	# =============================================================================
	# TEST C — MANUFACTURING CYCLE COMPLETES
	# =============================================================================

	# Advance another half second.
	# Total elapsed time reaches two seconds.
	producer._process(0.5)

	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 1)

	assert(
		is_zero_approx(producer.production_progress),
		"Progress should reset after manufacturing."
	)

	print("PASS C: Two ore converted into one ingot")


	# =============================================================================
	# TEST D — MISSING INPUTS STOP PRODUCTION
	# =============================================================================

	# The previous cycle consumed all available ore.
	producer._process(0.25)

	assert(producer.production_status == "Waiting for Inputs")

	assert(
		is_zero_approx(producer.production_progress),
		"Progress should remain zero without inputs."
	)

	assert(output_inventory.get_amount(test_ingot) == 1)

	print("PASS D: Missing inputs stop manufacturing")


	# =============================================================================
	# TEST E — PRODUCTION RESUMES
	# =============================================================================

	# Add enough ore for another complete cycle.
	input_inventory.add_item(test_ore, 2)

	producer._process(0.5)

	assert(producer.production_status == "Producing")

	assert(
		is_equal_approx(producer.production_progress, 0.5),
		"Production failed to resume."
	)

	print("PASS E: Manufacturing resumes when ore arrives")


	# =============================================================================
	# TEST F — OUTPUT INVENTORY BECOMES FULL
	# =============================================================================

	# One ingot is currently stored.
	# Set capacity to one, making the output inventory full.
	output_inventory.max_capacity = 1

	# Attempt to continue manufacturing.
	producer._process(0.5)

	assert(producer.production_status == "Output Blocked")

	assert(
		is_zero_approx(producer.production_progress),
		"Blocked production should reset progress."
	)

	# No ore may be consumed.
	assert(input_inventory.get_amount(test_ore) == 2)

	# No additional ingot may be created.
	assert(output_inventory.get_amount(test_ingot) == 1)

	print("PASS F: Full output blocks manufacturing safely")


	# =============================================================================
	# TEST G — PRODUCTION RESUMES AFTER CAPACITY RETURNS
	# =============================================================================

	# Restore the normal output inventory capacity.
	output_inventory.max_capacity = 100

	# The interrupted cycle should restart from zero.
	producer._process(1.0)

	assert(producer.production_status == "Producing")
	assert(output_inventory.get_amount(test_ingot) == 1)

	# Complete the second second of manufacturing.
	producer._process(1.0)

	assert(input_inventory.get_amount(test_ore) == 0)
	assert(output_inventory.get_amount(test_ingot) == 2)

	assert(
		is_zero_approx(producer.production_progress),
		"Progress did not reset after the second cycle."
	)

	print("PASS G: Manufacturing resumes and completes")


	# =============================================================================
	# TEST H — RESOURCE CONSERVATION
	# =============================================================================

	# Total ore supplied during testing:
	# First supply:  2
	# Second supply: 2
	# Total:         4
	#
	# Recipe conversion:
	# 2 Test Ore -> 1 Test Ingot
	#
	# Remaining ore + (ingots * 2) must equal four.

	var ore_equivalent: int = (
		input_inventory.get_amount(test_ore)
		+ output_inventory.get_amount(test_ingot) * 2
	)

	assert(
		ore_equivalent == 4,
		"Timed manufacturing resource conservation failed."
	)

	print("PASS H: Timed manufacturing conserves resources")


	# =============================================================================
	# TEST COMPLETE
	# =============================================================================

	print("=====================================")
	print("ALL TIMED MANUFACTURING TESTS PASSED")
	print("=====================================")

	# Clean up our isolated test nodes.
	producer.free()
	input_inventory.free()
	output_inventory.free()
