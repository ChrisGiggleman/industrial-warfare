
extends Node


# =============================================================================
# CHAT 08.2B-2 — TIMED CONVEYOR TRANSPORT TEST
# =============================================================================

# Verifies:
# - Empty conveyor behavior
# - Travel interval enforcement
# - Connected forward transport
# - Backpressure
# - Blocked transfer recovery
# - Multiple item types
# - Disconnection safety
# - Automatic Godot processing
# - Resource conservation


# =============================================================================
# CREATE CONVEYOR CARGO COMPONENTS
# =============================================================================


func _add_transport(
	belt: ConveyorSegment
) -> ConveyorTransportComponent:

	# =============================================================================
	# REUSE EXISTING TRANSPORT COMPONENT
	# =============================================================================

	# Once real conveyor scenes contain cargo components,
	# tests should use them rather than create duplicates.

	var existing_transport: ConveyorTransportComponent = (
		belt.get_node_or_null("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)

	if is_instance_valid(existing_transport):
		assert(
			is_instance_valid(
				existing_transport.cargo_inventory
			)
		)
		assert(
			existing_transport.cargo_inventory.max_capacity == 1
		)

		return existing_transport

	# =============================================================================
	# CREATE ISOLATED TEST COMPONENTS
	# =============================================================================

	# Preserve compatibility with conveyor scenes that
	# do not yet include built-in cargo components.

	var cargo := InventoryComponent.new()
	cargo.name = "CargoInventory"
	cargo.max_capacity = 1
	belt.add_child(cargo)

	var transport := ConveyorTransportComponent.new()
	transport.name = "ConveyorTransportComponent"
	transport.cargo_inventory = cargo
	belt.add_child(transport)

	return transport



# =============================================================================
# CREATE CONVEYOR TIMER COMPONENT
# =============================================================================


func _add_timer(
	belt: ConveyorSegment
) -> ConveyorTransportTimer:

	# =============================================================================
	# REUSE EXISTING TIMER
	# =============================================================================

	var timer: ConveyorTransportTimer = (
		belt.get_node_or_null("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	# =============================================================================
	# CREATE TIMER IF MISSING
	# =============================================================================

	if not is_instance_valid(timer):

		timer = ConveyorTransportTimer.new()
		timer.name = "ConveyorTransportTimer"
		belt.add_child(timer)

	# =============================================================================
	# CONFIGURE DETERMINISTIC TESTING
	# =============================================================================

	timer.travel_interval = 1.0

	# Disable automatic frame updates until Test H.
	# This allows precise, reproducible timing assertions.

	timer.set_process(false)

	return timer



# =============================================================================
# RUN TRANSPORT TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.2B-2: TIMED TRANSPORT TEST =====")

	# =============================================================================
	# LOAD ITEM DEFINITIONS
	# =============================================================================

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot := load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	# A new item definition with no saved .tres file.
	# This verifies the transport system does not
	# require a predefined resource name or type.

	var future_item := ItemDefinition.new()
	future_item.item_id = &"test_generic_item"
	future_item.display_name = "Future Factory Component"

	assert(ore != null)
	assert(ingot != null)
	assert(future_item != null)

	# =============================================================================
	# CREATE THREE PHYSICAL CONVEYORS
	# =============================================================================

	var conveyor_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(conveyor_scene != null)

	var test_root := Node3D.new()
	add_child(test_root)

	var belt_a := conveyor_scene.instantiate() as ConveyorSegment
	var belt_b := conveyor_scene.instantiate() as ConveyorSegment
	var belt_c := conveyor_scene.instantiate() as ConveyorSegment

	assert(belt_a != null)
	assert(belt_b != null)
	assert(belt_c != null)

	test_root.add_child(belt_a)
	test_root.add_child(belt_b)
	test_root.add_child(belt_c)

	belt_a.position = Vector3.ZERO
	belt_b.position = Vector3(0, 0, -1)
	belt_c.position = Vector3(0, 0, -2)

	assert(belt_a.try_connect_to(belt_b))
	assert(belt_b.try_connect_to(belt_c))

	# =============================================================================
	# ATTACH TRANSPORT COMPONENTS
	# =============================================================================

	var transport_a := _add_transport(belt_a)
	var transport_b := _add_transport(belt_b)
	var transport_c := _add_transport(belt_c)

	var timer_a := _add_timer(belt_a)
	var timer_b := _add_timer(belt_b)
	var timer_c := _add_timer(belt_c)

	# Test source and final receiving inventory.

	var source := InventoryComponent.new()
	source.max_capacity = 10

	var destination := InventoryComponent.new()
	destination.max_capacity = 10

	assert(source.add_item(ore, 1) == 1)
	assert(source.add_item(ingot, 1) == 1)
	assert(source.add_item(future_item, 1) == 1)

	# =============================================================================
	# TEST A — EMPTY CONVEYOR
	# =============================================================================

	assert(not timer_a.advance_transport(2.0))
	assert(timer_a.transport_status == "Empty")
	assert(timer_a.elapsed_seconds == 0.0)

	print("PASS A: Empty conveyor does not accumulate time")

	# =============================================================================
	# TEST B — TRAVEL TIME
	# =============================================================================

	assert(transport_a.try_receive_from_inventory(
		source, ore
	))

	assert(not timer_a.advance_transport(0.4))
	assert(not timer_a.advance_transport(0.59))

	assert(transport_a.get_held_item() == ore)
	assert(transport_b.get_held_item() == null)

	print("PASS B: Item waits for travel interval")

	# =============================================================================
	# TEST C — TIMED FORWARD MOVEMENT
	# =============================================================================

	assert(timer_a.advance_transport(0.02))

	assert(transport_a.get_held_item() == null)
	assert(transport_b.get_held_item() == ore)

	assert(timer_b.advance_transport(1.0))

	assert(transport_b.get_held_item() == null)
	assert(transport_c.get_held_item() == ore)

	print("PASS C: Ore advances through connected belts")

	# =============================================================================
	# TEST D — BACKPRESSURE
	# =============================================================================

	# Belt C is occupied by ore.
	# Send an ingot from A to B.

	assert(transport_a.try_receive_from_inventory(
		source, ingot
	))

	assert(timer_a.advance_transport(1.0))

	assert(transport_b.get_held_item() == ingot)
	assert(transport_c.get_held_item() == ore)

	# Belt B must retain its ingot.

	assert(not timer_b.advance_transport(1.0))
	assert(timer_b.transport_status == "Blocked")

	print("PASS D: Full destination stops transportation")

	# =============================================================================
	# TEST E — RESUME AFTER BLOCKAGE
	# =============================================================================

	# Remove ore from C into a receiving inventory.

	assert(
		transport_c.cargo_inventory.transfer_to(
			destination, ore, 1
		) == 1
	)

	# B already completed its travel interval.
	# It should now transfer without starting over.

	assert(timer_b.advance_transport(0.01))

	assert(transport_b.get_held_item() == null)
	assert(transport_c.get_held_item() == ingot)

	print("PASS E: Transportation resumes after blockage")

	# =============================================================================
	# TEST F — GENERIC ITEM COMPATIBILITY
	# =============================================================================

	# Load the newly created item definition.

	assert(transport_a.try_receive_from_inventory(
		source, future_item
	))

	assert(timer_a.advance_transport(1.0))

	assert(transport_b.get_held_item() == future_item)

	# Free the final conveyor.

	assert(
		transport_c.cargo_inventory.transfer_to(
			destination, ingot, 1
		) == 1
	)

	assert(timer_b.advance_transport(1.0))
	assert(transport_c.get_held_item() == future_item)

	print("PASS F: New item type transported successfully")

	# =============================================================================
	# TEST G — DISCONNECTED CONVEYOR
	# =============================================================================

	# Empty the final belt.

	assert(
		transport_c.cargo_inventory.transfer_to(
			destination, future_item, 1
		) == 1
	)

	# Return the ingot to the source for another test.

	assert(
		destination.transfer_to(source, ingot, 1) == 1
	)

	assert(transport_a.try_receive_from_inventory(
		source, ingot
	))

	assert(belt_a.disconnect_next())

	# A disconnected belt cannot export its item.

	assert(not timer_a.advance_transport(1.0))
	assert(transport_a.get_held_item() == ingot)

	print("PASS G: Disconnection preserves the item")

	# =============================================================================
	# TEST H — AUTOMATIC GODOT PROCESSING
	# =============================================================================

	# Restore the physical link and enable the normal
	# Godot frame-driven update for Belt A.
	#
	# Use a short interval for this isolated smoke test.

	assert(belt_a.try_connect_to(belt_b))

	timer_a.elapsed_seconds = 0.0
	timer_a.travel_interval = 0.01
	timer_a.set_process(true)

	var moved_automatically: bool = false

	for frame_index in range(60):

		await get_tree().process_frame

		if transport_b.get_held_item() == ingot:
			moved_automatically = true
			break

	timer_a.set_process(false)

	assert(moved_automatically)
	assert(transport_a.get_held_item() == null)

	print("PASS H: Godot frame processing moves cargo automatically")

	# =============================================================================
	# FINAL RESOURCE CONSERVATION
	# =============================================================================

	# Every original item must still exist in exactly
	# one inventory, regardless of its location.

	for item in [ore, ingot, future_item]:

		var total: int = (
			source.get_amount(item)
			+ destination.get_amount(item)
			+ transport_a.cargo_inventory.get_amount(item)
			+ transport_b.cargo_inventory.get_amount(item)
			+ transport_c.cargo_inventory.get_amount(item)
		)

		assert(total == 1)

	print("PASS: All three different item types conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	test_root.queue_free()

	source.free()
	destination.free()

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	print("==========================================")
	print("ALL 8 TIMED TRANSPORT TESTS PASSED")
	print("==========================================")
