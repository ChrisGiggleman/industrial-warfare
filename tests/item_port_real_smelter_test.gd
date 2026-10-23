
extends Node


# =============================================================================
# CHAT 07 — REAL SMELTER PORT HANDOFF TEST
# =============================================================================

# Uses the actual Test Smelter scene and its installed ports.
#
# Ore Source -> Smelter InputPort
# Smelting -> Smelter OutputPort
# Smelter OutputPort -> General Storage
#
# Tests run without automatic production or proximity logistics.
# All transfers and manufacturing cycles are triggered manually.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: REAL SMELTER PORT TEST =====")

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var scene: PackedScene = load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	assert(ore != null)
	assert(ingot != null)
	assert(scene != null)


	# =============================================================================
	# INSTANTIATE ACTUAL TEST SMELTER
	# =============================================================================

	var smelter: Node3D = scene.instantiate() as Node3D

	assert(smelter != null)

	add_child(smelter)

	var producer: ProducerComponent = (
		smelter.get_node("ProducerComponent")
		as ProducerComponent
	)

	var logistics: LogisticsInputComponent = (
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	)

	var smelter_input: InventoryComponent = (
		smelter.get_node("InputInventory")
		as InventoryComponent
	)

	var smelter_output: InventoryComponent = (
		smelter.get_node("OutputInventory")
		as InventoryComponent
	)

	var input_port: ItemPortComponent = (
		smelter.get_node("InputPort")
		as ItemPortComponent
	)

	var output_port: ItemPortComponent = (
		smelter.get_node("OutputPort")
		as ItemPortComponent
	)

	assert(producer != null)
	assert(logistics != null)
	assert(smelter_input != null)
	assert(smelter_output != null)
	assert(input_port != null)
	assert(output_port != null)

	# Disable automatic gameplay processing.
	# The test controls every operation.

	producer.set_process(false)
	logistics.set_process(false)


	# =============================================================================
	# CREATE TEMPORARY ORE SOURCE
	# =============================================================================

	var ore_inventory := InventoryComponent.new()
	ore_inventory.max_capacity = 10

	var ore_source_port := ItemPortComponent.new()
	ore_source_port.direction = (
		ItemPortComponent.PortDirection.OUTPUT
	)
	ore_source_port.inventory = ore_inventory

	assert(ore_inventory.add_item(ore, 6) == 6)


	# =============================================================================
	# CREATE TEMPORARY GENERAL STORAGE
	# =============================================================================

	# Capacity one allows us to test output blocking
	# after the first ingot arrives.

	var storage_inventory := InventoryComponent.new()
	storage_inventory.max_capacity = 1

	var storage_input_port := ItemPortComponent.new()
	storage_input_port.direction = (
		ItemPortComponent.PortDirection.INPUT
	)
	storage_input_port.input_policy = (
		ItemPortComponent.InputPolicy.ANY_ITEM
	)
	storage_input_port.inventory = storage_inventory


	# =============================================================================
	# TEST A — ACTUAL SMELTER PORT REFERENCES
	# =============================================================================

	assert(input_port.inventory == smelter_input)
	assert(output_port.inventory == smelter_output)

	assert(input_port.producer_component == producer)
	assert(output_port.producer_component == producer)

	print("PASS A: Real smelter ports are configured")


	# =============================================================================
	# TEST B — PORT DIRECTION AND INGREDIENT RULES
	# =============================================================================

	assert(input_port.can_accept_item(ore, 2))
	assert(not input_port.can_accept_item(ingot, 1))

	assert(not output_port.can_provide_item(ingot, 1))

	# INPUT ports cannot act as transfer sources.

	assert(
		input_port.try_transfer_to_port(
			storage_input_port, ore, 1
		) == 0
	)

	print("PASS B: Direction and recipe rules enforced")


	# =============================================================================
	# TEST C — DELIVER ORE INTO REAL SMELTER
	# =============================================================================

	var moved: int = ore_source_port.try_transfer_to_port(
		input_port,
		ore,
		2
	)

	assert(moved == 2)

	assert(ore_inventory.get_amount(ore) == 4)
	assert(smelter_input.get_amount(ore) == 2)

	print("PASS C: Two ore delivered through InputPort")


	# =============================================================================
	# TEST D — MANUFACTURE FIRST INGOT
	# =============================================================================

	# Execute one existing recipe transaction manually.
	# This consumes 2 Test Ore and produces 1 Test Ingot.

	assert(producer.try_complete_recipe_cycle())

	assert(smelter_input.get_amount(ore) == 0)
	assert(smelter_output.get_amount(ingot) == 1)

	print("PASS D: Real smelter produced one ingot")


	# =============================================================================
	# TEST E — EXPORT FINISHED INGOT TO STORAGE
	# =============================================================================

	moved = output_port.try_transfer_to_port(
		storage_input_port,
		ingot,
		1
	)

	assert(moved == 1)

	assert(smelter_output.get_amount(ingot) == 0)
	assert(storage_inventory.get_amount(ingot) == 1)

	print("PASS E: Ingot exported through OutputPort")


	# =============================================================================
	# TEST F — FULL STORAGE BLOCKS OUTPUT
	# =============================================================================

	# Produce one more ingot.
	# General storage is already at 1/1 capacity.

	moved = ore_source_port.try_transfer_to_port(
		input_port,
		ore,
		2
	)

	assert(moved == 2)
	assert(producer.try_complete_recipe_cycle())

	assert(ore_inventory.get_amount(ore) == 2)
	assert(smelter_output.get_amount(ingot) == 1)

	# No storage capacity remains.
	# The finished ingot must stay in the smelter.

	moved = output_port.try_transfer_to_port(
		storage_input_port,
		ingot,
		1
	)

	assert(moved == 0)

	assert(smelter_output.get_amount(ingot) == 1)
	assert(storage_inventory.get_amount(ingot) == 1)

	print("PASS F: Full storage safely blocks export")


	# =============================================================================
	# TEST G — TOTAL RESOURCE CONSERVATION
	# =============================================================================

	# Initial resource supply: 6 Test Ore.
	#
	# Every Test Ingot represents 2 Test Ore.
	#
	# Expected final:
	# Source: 2 ore
	# Smelter input: 0 ore
	# Smelter output: 1 ingot
	# Storage: 1 ingot
	#
	# Total equivalent: 2 + (1 * 2) + (1 * 2) = 6

	var ore_equivalent_total: int = (
		ore_inventory.get_amount(ore)
		+ smelter_input.get_amount(ore)
		+ smelter_output.get_amount(ingot) * 2
		+ storage_inventory.get_amount(ingot) * 2
	)

	assert(ore_equivalent_total == 6)

	print("PASS G: All six ore equivalents conserved")


	# =============================================================================
	# TEST CLEANUP
	# =============================================================================

	# The smelter was added to the scene tree.
	# Queue it for deletion before the test ends.

	smelter.queue_free()

	# Temporary source and storage components were
	# never added to the scene tree.

	ore_source_port.free()
	storage_input_port.free()

	ore_inventory.free()
	storage_inventory.free()


	# =============================================================================
	# FINAL TEST RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 7 REAL SMELTER PORT TESTS PASSED")
	print("==========================================")
