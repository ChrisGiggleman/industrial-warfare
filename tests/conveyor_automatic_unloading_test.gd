
extends Node


# =============================================================================
# CHAT 08.3E-3A — AUTOMATIC BUILDING DELIVERY TEST
# =============================================================================

# Tests:
# - Empty conveyor behavior
# - Travel interval enforcement
# - Automatic delivery into Smelter
# - Recipe rejection
# - Generic item rejection
# - Full destination backpressure
# - Automatic recovery after blockage
# - Connection removal safety
# - Resource conservation


func _ready() -> void:

	print("\n===== CHAT 08.3E-3A: AUTO UNLOADING TEST =====")

	# =============================================================================
	# LOAD SCENES AND RESOURCES
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
	generic_item.item_id = &"automatic_unloading_generic"
	generic_item.display_name = "Future Factory Component"

	assert(smelter_scene != null)
	assert(belt_scene != null)
	assert(ore != null)
	assert(ingot != null)

	# =============================================================================
	# CREATE ISOLATED FACTORY COMPONENTS
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

	var input_port := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var input_inventory := smelter.get_node(
		"InputInventory"
	) as InventoryComponent

	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	assert(producer != null)
	assert(logistics != null)
	assert(input_port != null)
	assert(input_inventory != null)
	assert(transport != null)
	assert(timer != null)

	# Prevent unrelated manufacturing and proximity
	# transfers from changing test inventories.

	producer.set_process(false)
	logistics.set_process(false)
	timer.set_process(false)

	timer.travel_interval = 1.0

	# =============================================================================
	# PREPARE SOURCE AND RECEIVING INVENTORIES
	# =============================================================================

	var supply := InventoryComponent.new()
	supply.max_capacity = 10

	var drained := InventoryComponent.new()
	drained.max_capacity = 10

	assert(supply.add_item(ore, 3) == 3)
	assert(supply.add_item(ingot, 1) == 1)
	assert(supply.add_item(generic_item, 1) == 1)

	# =============================================================================
	# ESTABLISH PHYSICAL BUILDING CONNECTION
	# =============================================================================

	var preview := ConveyorBuildingSnap.get_preview_transform(
		input_port, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(belt.try_connect_building_port(input_port))

	# =============================================================================
	# TEST A — EMPTY CONVEYOR
	# =============================================================================

	assert(not timer.advance_transport(2.0))
	assert(timer.transport_status == "Empty")

	print("PASS A: Empty conveyor remains inactive")

	# =============================================================================
	# TEST B — TRAVEL TIME ENFORCEMENT
	# =============================================================================

	assert(transport.try_receive_from_inventory(
		supply, ore
	))

	assert(not timer.advance_transport(0.4))

	assert(input_inventory.get_amount(ore) == 0)
	assert(transport.get_held_item() == ore)

	print("PASS B: Cargo waits for travel interval")

	# =============================================================================
	# TEST C — AUTOMATIC DELIVERY
	# =============================================================================

	assert(timer.advance_transport(0.61))

	assert(input_inventory.get_amount(ore) == 1)
	assert(transport.get_held_item() == null)
	assert(timer.successful_transfers == 1)

	print("PASS C: Ore automatically delivered to Smelter")

	# =============================================================================
	# TEST D — RECIPE REJECTION
	# =============================================================================

	assert(transport.try_receive_from_inventory(
		supply, ingot
	))

	assert(not timer.advance_transport(1.0))

	assert(timer.transport_status == "Blocked")
	assert(transport.get_held_item() == ingot)
	assert(input_inventory.get_amount(ingot) == 0)

	print("PASS D: Incorrect recipe item safely blocked")

	# Return the test ingot to supply.

	assert(
		transport.cargo_inventory.transfer_to(
			supply, ingot, 1
		) == 1
	)

	# Reset the timer after manually emptying the belt.

	assert(not timer.advance_transport(0.01))

	# =============================================================================
	# TEST E — GENERIC ITEM REJECTION
	# =============================================================================

	assert(transport.try_receive_from_inventory(
		supply, generic_item
	))

	assert(not timer.advance_transport(1.0))

	assert(transport.get_held_item() == generic_item)
	assert(input_inventory.get_amount(generic_item) == 0)

	print("PASS E: Generic item respects recipe filtering")

	assert(
		transport.cargo_inventory.transfer_to(
			supply, generic_item, 1
		) == 1
	)

	assert(not timer.advance_transport(0.01))

	# =============================================================================
	# TEST F — FULL INPUT BACKPRESSURE
	# =============================================================================

	# Smelter holds 1 ore.
	# Add 49 more to fill its 50-unit input inventory.
	#
	# These 49 units are included in conservation.

	assert(input_inventory.max_capacity == 50)
	assert(input_inventory.add_item(ore, 49) == 49)

	assert(transport.try_receive_from_inventory(
		supply, ore
	))

	assert(not timer.advance_transport(1.0))

	assert(timer.transport_status == "Blocked")
	assert(transport.get_held_item() == ore)
	assert(input_inventory.get_amount(ore) == 50)

	print("PASS F: Full Smelter input blocks delivery")

	# =============================================================================
	# TEST G — AUTOMATIC BACKPRESSURE RECOVERY
	# =============================================================================

	assert(
		input_inventory.transfer_to(
			drained, ore, 1
		) == 1
	)

	# Cargo already completed its travel interval.
	# It can finish delivery on the next update.

	assert(timer.advance_transport(0.01))

	assert(transport.get_held_item() == null)
	assert(input_inventory.get_amount(ore) == 50)
	assert(timer.successful_transfers == 2)

	print("PASS G: Delivery resumes when capacity returns")

	# =============================================================================
	# TEST H — DISCONNECTED DESTINATION
	# =============================================================================

	# Reset the timer after the previous delivery.

	assert(not timer.advance_transport(0.01))

	assert(transport.try_receive_from_inventory(
		supply, ore
	))

	assert(belt.disconnect_building_port(input_port))

	assert(not timer.advance_transport(1.0))

	assert(timer.transport_status == "Blocked")
	assert(transport.get_held_item() == ore)
	assert(input_port.connected_conveyor == null)

	print("PASS H: Disconnection preserves transported item")

	# =============================================================================
	# TEST I — RESOURCE CONSERVATION
	# =============================================================================

	# Initial supply: 3 ore, 1 ingot, 1 generic.
	# Added capacity fixture: 49 ore.
	#
	# Total expected ore = 52.

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

	print("PASS I: All transported resources conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()
	supply.free()
	drained.free()

	print("==========================================")
	print("ALL 9 AUTOMATIC UNLOADING TESTS PASSED")
	print("==========================================")
