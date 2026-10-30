
extends Node


# =============================================================================
# BUILDING TO CONVEYOR LOADING TEST
# =============================================================================

# Verifies:
# - No physical connection means no transfer
# - Geometry alone does not authorize transfer
# - Extractor loading works
# - Occupied conveyor blocks loading
# - Misaligned endpoints reject loading
# - Generic items can be loaded
# - Disconnection prevents loading
# - Smelter outputs use the same system
# - Resources remain conserved


func _ready() -> void:

	print("\n===== CHAT 08.3E-1: BUILDING LOADING TEST =====")

	# =============================================================================
	# LOAD SCENES AND ITEM DEFINITIONS
	# =============================================================================

	var extractor_scene := load(
		"res://scenes/buildings/test_extractor.tscn"
	) as PackedScene

	var smelter_scene := load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot := load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var generic_item := ItemDefinition.new()
	generic_item.item_id = &"future_building_output"
	generic_item.display_name = "Future Factory Product"

	assert(extractor_scene != null)
	assert(smelter_scene != null)
	assert(belt_scene != null)
	assert(ore != null)
	assert(ingot != null)

	# =============================================================================
	# CREATE ISOLATED TEST OBJECTS
	# =============================================================================

	var root := Node3D.new()
	add_child(root)

	var extractor := extractor_scene.instantiate() as Node3D
	var smelter := smelter_scene.instantiate() as Node3D

	var belt_a := belt_scene.instantiate() as ConveyorSegment
	var belt_b := belt_scene.instantiate() as ConveyorSegment

	root.add_child(extractor)
	root.add_child(smelter)
	root.add_child(belt_a)
	root.add_child(belt_b)

	smelter.position = Vector3(8, 0, 0)

	# =============================================================================
	# DISABLE UNRELATED AUTOMATIC PROCESSING
	# =============================================================================

	(
		extractor.get_node("ExtractorComponent")
		as ExtractorComponent
	).set_process(false)

	(
		extractor.get_node("LogisticsTransferComponent")
		as LogisticsTransferComponent
	).set_process(false)

	(
		smelter.get_node("ProducerComponent")
		as ProducerComponent
	).set_process(false)

	(
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	).set_process(false)

	for belt in [belt_a, belt_b]:

		var timer := belt.get_node(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer

		timer.set_process(false)

	# =============================================================================
	# GET PORTS AND INVENTORIES
	# =============================================================================

	var extractor_port := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	var smelter_port := smelter.get_node(
		"OutputPort"
	) as ItemPortComponent

	var smelter_inventory := smelter.get_node(
		"OutputInventory"
	) as InventoryComponent

	var transport_a := belt_a.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var transport_b := belt_b.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	assert(extractor_port != null)
	assert(extractor_inventory != null)
	assert(smelter_port != null)
	assert(smelter_inventory != null)
	assert(transport_a != null)
	assert(transport_b != null)

	# Prepare initial resources.

	assert(extractor_inventory.add_item(ore, 1) == 1)
	assert(smelter_inventory.add_item(ingot, 1) == 1)

	var receiving_inventory := InventoryComponent.new()
	receiving_inventory.max_capacity = 10

	# =============================================================================
	# TEST A — NO CONNECTION
	# =============================================================================

	assert(
		not ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	assert(extractor_inventory.get_amount(ore) == 1)

	print("PASS A: Disconnected conveyor cannot load cargo")

	# =============================================================================
	# TEST B — ALIGNMENT WITHOUT CONNECTION
	# =============================================================================

	var preview := ConveyorBuildingSnap.get_preview_transform(
		extractor_port,
		belt_a
	)

	assert(preview.has("transform"))

	belt_a.global_transform = preview["transform"]

	assert(
		not ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	print("PASS B: Alignment alone cannot transfer items")

	# =============================================================================
	# TEST C — EXTRACTOR OUTPUT LOADING
	# =============================================================================

	assert(
		belt_a.try_connect_building_port(
			extractor_port
		)
	)

	assert(
		ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	assert(extractor_inventory.get_amount(ore) == 0)
	assert(transport_a.get_held_item() == ore)

	print("PASS C: Extractor loads one ore onto conveyor")

	# =============================================================================
	# TEST D — FULL CONVEYOR BLOCKS LOADING
	# =============================================================================

	# Add another item type while Belt A is occupied.

	assert(
		extractor_inventory.add_item(
			generic_item, 1
		) == 1
	)

	assert(
		not ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	assert(extractor_inventory.get_amount(generic_item) == 1)

	print("PASS D: Occupied belt blocks additional cargo")

	# =============================================================================
	# TEST E — MISALIGNED CONNECTION
	# =============================================================================

	# Unload the ore into the test receiving inventory.

	assert(
		transport_a.cargo_inventory.transfer_to(
			receiving_inventory, ore, 1
		) == 1
	)

	# Keep the stored connection references but
	# physically move the belt out of alignment.

	belt_a.position.x += 1.0

	assert(
		not ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	assert(extractor_inventory.get_amount(generic_item) == 1)

	# Restore physical alignment.

	belt_a.global_transform = preview["transform"]

	print("PASS E: Misaligned connection rejects loading")

	# =============================================================================
	# TEST F — GENERIC ITEM LOADING
	# =============================================================================

	assert(
		ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	assert(transport_a.get_held_item() == generic_item)
	assert(extractor_inventory.get_amount(generic_item) == 0)

	print("PASS F: Generic item loaded without hardcoding")

	# =============================================================================
	# TEST G — DISCONNECTION PREVENTS LOADING
	# =============================================================================

	assert(
		transport_a.cargo_inventory.transfer_to(
			receiving_inventory,
			generic_item,
			1
		) == 1
	)

	assert(
		belt_a.disconnect_building_port(
			extractor_port
		)
	)

	# Add another ore after disconnection.

	assert(extractor_inventory.add_item(ore, 1) == 1)

	assert(
		not ConveyorBuildingTransfer.try_load_into_belt(
			belt_a
		)
	)

	assert(extractor_inventory.get_amount(ore) == 1)

	print("PASS G: Disconnection blocks additional loading")

	# =============================================================================
	# TEST H — SMELTER OUTPUT USES SAME LOGIC
	# =============================================================================

	var smelter_preview := (
		ConveyorBuildingSnap.get_preview_transform(
			smelter_port,
			belt_b
		)
	)

	assert(smelter_preview.has("transform"))

	belt_b.global_transform = smelter_preview["transform"]

	assert(
		belt_b.try_connect_building_port(
			smelter_port
		)
	)

	assert(
		ConveyorBuildingTransfer.try_load_into_belt(
			belt_b
		)
	)

	assert(smelter_inventory.get_amount(ingot) == 0)
	assert(transport_b.get_held_item() == ingot)

	print("PASS H: Smelter ingot loads using same helper")

	# =============================================================================
	# TEST I — RESOURCE CONSERVATION
	# =============================================================================

	# Two ore units were added during this test.
	# One generic item and one ingot were also added.

	var inventories: Array[InventoryComponent] = [
		extractor_inventory,
		smelter_inventory,
		receiving_inventory,
		transport_a.cargo_inventory,
		transport_b.cargo_inventory
	]

	for candidate in [ore, generic_item, ingot]:

		var item: ItemDefinition = candidate as ItemDefinition
		var total: int = 0

		for inventory in inventories:
			total += inventory.get_amount(item)

		var expected: int = 1

		if item == ore:
			expected = 2

		assert(total == expected)

	print("PASS I: All resources conserved across transfers")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()
	receiving_inventory.free()

	print("==========================================")
	print("ALL 9 BUILDING LOADING TESTS PASSED")
	print("==========================================")
