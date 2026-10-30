
extends Node


# =============================================================================
# RECIPE-AWARE LOGISTICS REGRESSION TEST
# =============================================================================

# Tests that LogisticsInputComponent respects the active recipe.
#
# The test creates isolated smelter and storage instances.
# It does not modify the main game scene or permanent recipes.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: RECIPE LOGISTICS TEST =====")

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var smelter_scene: PackedScene = load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	var storage_scene: PackedScene = load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene

	assert(ore != null)
	assert(ingot != null)
	assert(smelter_scene != null)
	assert(storage_scene != null)

	# =============================================================================
	# CREATE ISOLATED BUILDINGS
	# =============================================================================

	var smelter: Node3D = smelter_scene.instantiate() as Node3D
	var storage: Node3D = storage_scene.instantiate() as Node3D

	assert(smelter != null)
	assert(storage != null)

	var producer: ProducerComponent = (
		smelter.get_node("ProducerComponent") as ProducerComponent
	)

	var logistics: LogisticsInputComponent = (
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	)

	var input_inventory: InventoryComponent = (
		smelter.get_node("InputInventory") as InventoryComponent
	)

	var storage_inventory: InventoryComponent = (
		storage.get_node("InventoryComponent") as InventoryComponent
	)

	assert(producer != null)
	assert(logistics != null)
	assert(input_inventory != null)
	assert(storage_inventory != null)

	# Prevent automatic logistics processing during the test.
	# Transfer attempts will be triggered manually.

	smelter.position = Vector3.ZERO
	storage.position = Vector3(2, 0, 0)

	add_child(smelter)
	add_child(storage)

	# =============================================================================
	#DISABLE AUTOMATIC TEST BUILDING PROCESSING
	# =============================================================================

	# Stop automatic logistics and manufacturing updates.
	#
	# The test manually invokes logistics._process() to
	# control exactly when transfers occur.
	#
	# Disabling processing after the nodes enter the scene
	# prevents normal gameplay updates from interfering.

	logistics.set_process(false)
	producer.set_process(false)

	assert(storage_inventory.add_item(ore, 12) == 12)

	# =============================================================================
	# TEST A — PRODUCER REFERENCE CONFIGURED
	# =============================================================================

	assert(logistics.producer_component == producer)
	assert(logistics.transfer_item == ore)

	print("PASS A: Recipe reference configured")

	# =============================================================================
	# TEST B — MISSING PRODUCER BLOCKS TRANSFER
	# =============================================================================

	logistics.producer_component = null

	logistics._process(1.1)

	assert(logistics.logistics_status == "Producer Missing")
	assert(logistics.last_transfer_amount == 0)
	assert(storage_inventory.get_amount(ore) == 12)
	assert(input_inventory.get_amount(ore) == 0)

	print("PASS B: Missing producer blocks transfer")

	logistics.producer_component = producer

	# =============================================================================
	# CREATE AN ALTERNATIVE TEST RECIPE
	# =============================================================================

	# This recipe requires ingots, not ore.
	# It exists only to test input acceptance.

	var alternative: ProductionRecipe = ProductionRecipe.new()

	alternative.recipe_id = &"logistics_test"
	alternative.display_name = "Logistics Acceptance Test"
	alternative.production_time = 2.0

	var ingredient: ItemAmount = ItemAmount.new()
	ingredient.item = ingot
	ingredient.amount = 1

	var result: ItemAmount = ItemAmount.new()
	result.item = ore
	result.amount = 1

	alternative.inputs.append(ingredient)
	alternative.outputs.append(result)

	var original_recipe: ProductionRecipe = producer.recipe

	producer.available_recipes.append(alternative)

	assert(producer.select_recipe(alternative))

	# =============================================================================
	# TEST C — INCOMPATIBLE ITEM BLOCKED
	# =============================================================================

	logistics._process(1.1)

	assert(
		logistics.logistics_status == "Item Not Required by Recipe"
	)

	assert(logistics.last_transfer_amount == 0)

	print("PASS C: Incompatible ingredient blocked")

	# =============================================================================
	# TEST D — BLOCKED TRANSFER PRESERVES RESOURCES
	# =============================================================================

	assert(storage_inventory.get_amount(ore) == 12)
	assert(input_inventory.get_amount(ore) == 0)

	print("PASS D: Blocked transfer preserves resources")

	# =============================================================================
	# TEST E — RESTORED RECIPE ALLOWS NORMAL TRANSFER
	# =============================================================================

	assert(producer.select_recipe(original_recipe))

	logistics._process(1.1)

	assert(logistics.last_transfer_amount == 5)
	assert(storage_inventory.get_amount(ore) == 7)
	assert(input_inventory.get_amount(ore) == 5)

	print("PASS E: Correct recipe transfers 5 ore")

# =============================================================================
# CLEAN UP TEST BUILDINGS
# =============================================================================

# Remove temporary test buildings after all assertions.
# This prevents test logistics from continuing to operate.

	smelter.queue_free()
	storage.queue_free()
	
	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 5 RECIPE LOGISTICS TESTS PASSED")
	print("==========================================")
