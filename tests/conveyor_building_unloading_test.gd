
extends Node


# =============================================================================
# CONVEYOR TO BUILDING UNLOADING TEST
# =============================================================================

# Checks:
# - Disconnected and visually aligned belts
# - Valid smelter input delivery
# - Recipe filtering
# - Generic item rejection
# - Destination capacity and backpressure
# - Recovery, misalignment, and disconnection
# - Resource conservation


func _ready() -> void:

	print("\n===== CHAT 08.3E-2: BUILDING UNLOADING TEST =====")

	# =============================================================================
	# LOAD TEST ASSETS
	# =============================================================================

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
	generic_item.item_id = &"future_unloading_item"
	generic_item.display_name = "Future Component"

	assert(smelter_scene != null)
	assert(belt_scene != null)
	assert(ore != null)
	assert(ingot != null)

	# =============================================================================
	# CREATE ISOLATED SMELTER AND CONVEYOR
	# =============================================================================

	var root := Node3D.new()
	add_child(root)

	var smelter := smelter_scene.instantiate() as Node3D
	var belt := belt_scene.instantiate() as ConveyorSegment

	assert(smelter != null)
	assert(belt != null)

	root.add_child(smelter)
	root.add_child(belt)

	var producer := smelter.get_node(
		"ProducerComponent"
	) as ProducerComponent

	var logistics := smelter.get_node(
		"LogisticsInputComponent"
	) as LogisticsInputComponent

	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	producer.set_process(false)
	logistics.set_process(false)
	timer.set_process(false)

	var input_port := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var input_inventory := smelter.get_node(
		"InputInventory"
	) as InventoryComponent

	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	assert(input_port != null)
	assert(input_inventory != null)
	assert(transport != null)

	# =============================================================================
	# PREPARE TEST INVENTORIES
	# =============================================================================

	var supply := InventoryComponent.new()
	supply.max_capacity = 10

	var drained := InventoryComponent.new()
	drained.max_capacity = 10

	assert(supply.add_item(ore, 3) == 3)
	assert(supply.add_item(ingot, 1) == 1)
	assert(supply.add_item(generic_item, 1) == 1)

	# =============================================================================
	# TEST A — DISCONNECTED CONVEYOR
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(supply, ore)
	)

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(transport.get_held_item() == ore)

	print("PASS A: Disconnected belt cannot unload")

	# =============================================================================
	# TEST B — ALIGNMENT ALONE IS INSUFFICIENT
	# =============================================================================

	var preview := ConveyorBuildingSnap.get_preview_transform(
		input_port, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	print("PASS B: Physical alignment alone cannot unload")

	# =============================================================================
	# TEST C — VALID SMELTER INPUT
	# =============================================================================

	assert(belt.try_connect_building_port(input_port))

	assert(
		ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(input_inventory.get_amount(ore) == 1)
	assert(transport.get_held_item() == null)

	print("PASS C: Required ore delivered to Smelter")

	# =============================================================================
	# TEST D — REJECT FINISHED INGOTS
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(supply, ingot)
	)

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(transport.get_held_item() == ingot)
	assert(input_inventory.get_amount(ingot) == 0)

	assert(
		transport.cargo_inventory.transfer_to(
			supply, ingot, 1
		) == 1
	)

	print("PASS D: Active recipe rejects incorrect item")

	# =============================================================================
	# TEST E — REJECT UNRELATED GENERIC ITEM
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(
			supply, generic_item
		)
	)

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(transport.get_held_item() == generic_item)

	assert(
		transport.cargo_inventory.transfer_to(
			supply, generic_item, 1
		) == 1
	)

	print("PASS E: Unsupported generic item remains safe")

	# =============================================================================
	# TEST F — FULL INPUT INVENTORY
	# =============================================================================

	# Smelter currently holds one ore.
	# Add 49 more to reach its capacity of 50.
	#
	# These 49 are included in the final conservation
	# check as additional test fixture resources.

	assert(input_inventory.max_capacity == 50)
	assert(input_inventory.add_item(ore, 49) == 49)

	assert(
		transport.try_receive_from_inventory(supply, ore)
	)

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(input_inventory.get_amount(ore) == 50)
	assert(transport.get_held_item() == ore)

	print("PASS F: Full input blocks delivery without loss")

	# =============================================================================
	# TEST G — RESUME AFTER FREEING SPACE
	# =============================================================================

	assert(
		input_inventory.transfer_to(
			drained, ore, 1
		) == 1
	)

	assert(
		ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(input_inventory.get_amount(ore) == 50)
	assert(transport.get_held_item() == null)

	print("PASS G: Unloading resumes when capacity returns")

	# =============================================================================
	# TEST H — MISALIGNED CONNECTION
	# =============================================================================

	# Free one slot and load the last source ore.

	assert(
		input_inventory.transfer_to(
			drained, ore, 1
		) == 1
	)

	assert(
		transport.try_receive_from_inventory(supply, ore)
	)

	# Move the belt while retaining connection references.

	belt.position.x += 1.0

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(transport.get_held_item() == ore)

	# Restore original valid geometry.

	belt.global_transform = preview["transform"]

	assert(
		ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	print("PASS H: Misalignment rejected; restoration works")

	# =============================================================================
	# TEST I — DISCONNECTION
	# =============================================================================

	# Load one conserved item back onto the belt.

	assert(
		transport.try_receive_from_inventory(drained, ore)
	)

	assert(belt.disconnect_building_port(input_port))

	assert(
		not ConveyorBuildingTransfer.try_unload_from_belt(
			belt
		)
	)

	assert(transport.get_held_item() == ore)
	assert(input_port.connected_conveyor == null)

	print("PASS I: Disconnection prevents item delivery")

	# =============================================================================
	# TEST J — RESOURCE CONSERVATION
	# =============================================================================

	# Original supply: 3 ore, 1 ingot, 1 generic.
	# Additional capacity fixture: 49 ore.
	#
	# Expected total ore: 52.

	var inventories: Array[InventoryComponent] = [
		supply,
		drained,
		input_inventory,
		transport.cargo_inventory
	]

	for candidate in [ore, ingot, generic_item]:

		var item: ItemDefinition = candidate as ItemDefinition
		var total: int = 0

		for inventory in inventories:
			total += inventory.get_amount(item)

		var expected: int = 1

		if item == ore:
			expected = 52

		assert(total == expected)

	assert(producer.production_progress == 0.0)

	print("PASS J: Every original item remains conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()
	supply.free()
	drained.free()

	print("==========================================")
	print("ALL 10 BUILDING UNLOADING TESTS PASSED")
	print("==========================================")
