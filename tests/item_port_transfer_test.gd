
extends Node


# =============================================================================
# SAFE PORT TRANSFER REGRESSION TEST
# =============================================================================

# Tests guarded item movement between an output port
# and an input port, including universal storage.
#
# Uses isolated inventories with no gameplay automation.


func _ready() -> void:

	print("\n===== CHAT 07: SAFE PORT TRANSFER TEST =====")

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var smelting_recipe: ProductionRecipe = load(
		"res://data/recipes/test_smelting.tres"
	) as ProductionRecipe

	assert(ore != null)
	assert(ingot != null)
	assert(smelting_recipe != null)

	# =============================================================================
	# CREATE SOURCE MACHINE
	# =============================================================================

	var source_inventory := InventoryComponent.new()
	source_inventory.max_capacity = 10

	var source_producer := ProducerComponent.new()
	source_producer.recipe = smelting_recipe
	source_producer.output_inventory = source_inventory

	var source_port := ItemPortComponent.new()
	source_port.direction = ItemPortComponent.PortDirection.OUTPUT
	source_port.inventory = source_inventory
	source_port.producer_component = source_producer

	assert(source_inventory.add_item(ingot, 5) == 5)

	# =============================================================================
	# CREATE RECEIVING MACHINE
	# =============================================================================

	# Temporary recipe that accepts Test Ingots.
	# No permanent game recipe file is changed.

	var receiving_recipe := ProductionRecipe.new()
	receiving_recipe.production_time = 2.0

	var ingredient := ItemAmount.new()
	ingredient.item = ingot
	ingredient.amount = 1
	receiving_recipe.inputs.append(ingredient)

	var product := ItemAmount.new()
	product.item = ore
	product.amount = 1
	receiving_recipe.outputs.append(product)

	var destination_inventory := InventoryComponent.new()
	destination_inventory.max_capacity = 3

	var destination_producer := ProducerComponent.new()
	destination_producer.recipe = receiving_recipe
	destination_producer.input_inventory = destination_inventory

	var destination_port := ItemPortComponent.new()
	destination_port.direction = ItemPortComponent.PortDirection.INPUT
	destination_port.inventory = destination_inventory
	destination_port.producer_component = destination_producer

	# =============================================================================
	# TEST A — INVALID REQUESTS
	# =============================================================================

	assert(
		source_port.try_transfer_to_port(
			null, ingot, 1
		) == 0
	)

	assert(
		source_port.try_transfer_to_port(
			destination_port, null, 1
		) == 0
	)

	assert(
		source_port.try_transfer_to_port(
			destination_port, ingot, 0
		) == 0
	)

	print("PASS A: Invalid transfers rejected")

	# =============================================================================
	# TEST B — PORT DIRECTION
	# =============================================================================

	assert(
		destination_port.try_transfer_to_port(
			source_port, ingot, 1
		) == 0
	)

	assert(
		source_port.try_transfer_to_port(
			source_port, ingot, 1
		) == 0
	)

	print("PASS B: Incorrect port directions rejected")

	# =============================================================================
	# TEST C — RECIPE ACCEPTANCE
	# =============================================================================

	# Temporarily use an ore-consuming recipe.
	# The destination must reject ingots.

	destination_producer.recipe = smelting_recipe

	assert(
		source_port.try_transfer_to_port(
			destination_port, ingot, 1
		) == 0
	)

	assert(source_inventory.get_amount(ingot) == 5)
	assert(destination_inventory.get_amount(ingot) == 0)

	destination_producer.recipe = receiving_recipe

	print("PASS C: Incorrect recipe ingredients rejected")

	# =============================================================================
	# TEST D — SUCCESSFUL TRANSFER
	# =============================================================================

	var moved: int = source_port.try_transfer_to_port(
		destination_port, ingot, 2
	)

	assert(moved == 2)
	assert(source_inventory.get_amount(ingot) == 3)
	assert(destination_inventory.get_amount(ingot) == 2)

	print("PASS D: Two ingots transferred successfully")

	# =============================================================================
	# TEST E — DESTINATION CAPACITY
	# =============================================================================

	# Destination capacity is 3, with 2 already stored.
	# A request for 2 must be rejected in full.

	moved = source_port.try_transfer_to_port(
		destination_port, ingot, 2
	)

	assert(moved == 0)
	assert(source_inventory.get_amount(ingot) == 3)
	assert(destination_inventory.get_amount(ingot) == 2)

	# One more ingot fits.

	moved = source_port.try_transfer_to_port(
		destination_port, ingot, 1
	)

	assert(moved == 1)
	assert(source_inventory.get_amount(ingot) == 2)
	assert(destination_inventory.get_amount(ingot) == 3)

	print("PASS E: Capacity and full-request limits enforced")

	# =============================================================================
	# TEST F — INSUFFICIENT SOURCE / SAME INVENTORY
	# =============================================================================

	assert(
		source_port.try_transfer_to_port(
			destination_port, ingot, 3
		) == 0
	)

	# General storage port referencing the source
	# inventory itself must never accept a self-transfer.

	var same_inventory_port := ItemPortComponent.new()
	same_inventory_port.input_policy = (
		ItemPortComponent.InputPolicy.ANY_ITEM
	)
	same_inventory_port.inventory = source_inventory

	assert(
		source_port.try_transfer_to_port(
			same_inventory_port, ingot, 1
		) == 0
	)

	print("PASS F: Insufficient supply and self-transfer blocked")

	# =============================================================================
	# TEST G — TRANSFER INTO UNIVERSAL STORAGE
	# =============================================================================

	var storage_inventory := InventoryComponent.new()
	storage_inventory.max_capacity = 5

	var storage_port := ItemPortComponent.new()
	storage_port.input_policy = (
		ItemPortComponent.InputPolicy.ANY_ITEM
	)
	storage_port.inventory = storage_inventory

	moved = source_port.try_transfer_to_port(
		storage_port, ingot, 2
	)

	assert(moved == 2)

	assert(source_inventory.get_amount(ingot) == 0)
	assert(destination_inventory.get_amount(ingot) == 3)
	assert(storage_inventory.get_amount(ingot) == 2)

	# Total inventory must still contain all 5 ingots.
	assert(
		source_inventory.get_amount(ingot)
		+ destination_inventory.get_amount(ingot)
		+ storage_inventory.get_amount(ingot)
		== 5
	)

	print("PASS G: Universal storage transfer conserves items")

	# =============================================================================
	# CLEAN UP TEMPORARY COMPONENTS
	# =============================================================================

	source_port.free()
	destination_port.free()
	same_inventory_port.free()
	storage_port.free()

	source_producer.free()
	destination_producer.free()

	source_inventory.free()
	destination_inventory.free()
	storage_inventory.free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 7 SAFE PORT TRANSFER TESTS PASSED")
	print("==========================================")
