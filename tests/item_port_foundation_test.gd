
extends Node


# =============================================================================
# CHAT 07 — ITEM PORT FOUNDATION REGRESSION TEST
# =============================================================================

# Tests ingredient rules, inventory capacity, general
# storage acceptance, output availability, and non-mutation.
#
# No active game buildings are modified.


func _ready() -> void:

	print("\n===== CHAT 07: ITEM PORT TEST =====")

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var recipe: ProductionRecipe = load(
		"res://data/recipes/test_smelting.tres"
	) as ProductionRecipe

	assert(ore != null)
	assert(ingot != null)
	assert(recipe != null)

	# =============================================================================
	# CREATE TEST COMPONENTS
	# =============================================================================

	var producer := ProducerComponent.new()
	var input_inventory := InventoryComponent.new()
	var output_inventory := InventoryComponent.new()

	input_inventory.max_capacity = 5
	output_inventory.max_capacity = 5

	producer.recipe = recipe
	producer.input_inventory = input_inventory
	producer.output_inventory = output_inventory

	var input_port := ItemPortComponent.new()

	# =============================================================================
	# TEST A — MISSING REFERENCES REJECT INPUT
	# =============================================================================

	assert(not input_port.can_accept_item(ore))

	input_port.inventory = input_inventory
	assert(not input_port.can_accept_item(ore))

	print("PASS A: Missing references rejected")

	# =============================================================================
	# TEST B — ACTIVE RECIPE CONTROLS INPUT
	# =============================================================================

	input_port.producer_component = producer

	assert(input_port.can_accept_item(ore, 2))
	assert(not input_port.can_accept_item(ingot))
	assert(not input_port.can_accept_item(null))
	assert(not input_port.can_accept_item(ore, 0))

	print("PASS B: Recipe ingredient rules respected")

	# =============================================================================
	# TEST C — CAPACITY LIMITS
	# =============================================================================

	assert(input_inventory.add_item(ore, 4) == 4)

	assert(input_port.can_accept_item(ore, 1))
	assert(not input_port.can_accept_item(ore, 2))

	print("PASS C: Full transfer quantity checked")

	# =============================================================================
	# TEST D — WRONG INVENTORY REJECTED
	# =============================================================================

	input_port.inventory = output_inventory

	assert(not input_port.can_accept_item(ore))

	input_port.inventory = input_inventory

	print("PASS D: Incorrect inventory reference rejected")

	# =============================================================================
	# TEST E — GENERAL STORAGE ACCEPTS ALL ITEMS
	# =============================================================================

	var storage_inventory := InventoryComponent.new()
	storage_inventory.max_capacity = 2

	var storage_port := ItemPortComponent.new()

	storage_port.inventory = storage_inventory
	storage_port.input_policy = ItemPortComponent.InputPolicy.ANY_ITEM

	assert(storage_port.can_accept_item(ore))
	assert(storage_port.can_accept_item(ingot, 2))
	assert(not storage_port.can_accept_item(ingot, 3))

	assert(storage_inventory.add_item(ingot, 2) == 2)
	assert(not storage_port.can_accept_item(ore))

	print("PASS E: Universal storage respects capacity")

	# =============================================================================
	# TEST F — OUTPUT PORT PROVIDES EXISTING ITEMS
	# =============================================================================

	var output_port := ItemPortComponent.new()

	output_port.direction = ItemPortComponent.PortDirection.OUTPUT
	output_port.inventory = output_inventory
	output_port.producer_component = producer

	assert(output_inventory.add_item(ingot, 3) == 3)

	assert(output_port.can_provide_item(ingot, 2))
	assert(not output_port.can_provide_item(ingot, 4))
	assert(not output_port.can_accept_item(ore))
	assert(not input_port.can_provide_item(ore))

	print("PASS F: Output availability and direction validated")

	# =============================================================================
	# TEST G — ALL CHECKS ARE READ-ONLY
	# =============================================================================

	assert(input_inventory.get_amount(ore) == 4)
	assert(output_inventory.get_amount(ingot) == 3)
	assert(storage_inventory.get_amount(ingot) == 2)

	print("PASS G: Inventory quantities unchanged")

	# =============================================================================
	# TEST CLEANUP
	# =============================================================================

	# These temporary nodes were never added to the scene.
	# Free them explicitly after all tests finish.

	input_port.free()
	output_port.free()
	storage_port.free()
	producer.free()
	input_inventory.free()
	output_inventory.free()
	storage_inventory.free()

	print("======================================")
	print("ALL 7 ITEM PORT TESTS PASSED")
	print("======================================")
