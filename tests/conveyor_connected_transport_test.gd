
extends Node


# =============================================================================
# CONNECTED CONVEYOR TRANSPORT TEST
# =============================================================================

# Verifies:
# - Disconnected conveyors cannot transfer items.
# - Valid directed connections permit transfers.
# - Full destination buffers block transfers.
# - Reverse-direction transfers are rejected.
# - Misaligned connections cannot transfer.
# - Disconnection stops item movement.
# - All items remain accounted for.


# =============================================================================
# CREATE TEST CARGO COMPONENT
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
# RUN CONNECTED TRANSPORT TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.2B-1: CONNECTED TRANSPORT TEST =====")

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(ore != null)

	var conveyor_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(conveyor_scene != null)

	# =============================================================================
	# CREATE TWO PHYSICAL CONVEYORS
	# =============================================================================

	var test_root := Node3D.new()
	add_child(test_root)

	var belt_a := conveyor_scene.instantiate() as ConveyorSegment
	var belt_b := conveyor_scene.instantiate() as ConveyorSegment

	assert(belt_a != null)
	assert(belt_b != null)

	test_root.add_child(belt_a)
	test_root.add_child(belt_b)

	belt_a.position = Vector3.ZERO
	belt_b.position = Vector3(0, 0, -1)

	var transport_a := _add_transport(belt_a)
	var transport_b := _add_transport(belt_b)

	var source_inventory := InventoryComponent.new()
	source_inventory.max_capacity = 10

	assert(source_inventory.add_item(ore, 3) == 3)
	assert(transport_a.try_receive_from_inventory(
		source_inventory, ore
	))

	# =============================================================================
	# TEST A — DISCONNECTED CONVEYORS
	# =============================================================================

	assert(not ConveyorTransportLink.try_transfer_forward(belt_a))

	print("PASS A: Disconnected transfer rejected")

	# =============================================================================
	# TEST B — PHYSICAL CONNECTION
	# =============================================================================

	assert(belt_a.try_connect_to(belt_b))
	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)

	print("PASS B: Physical directed connection established")

	# =============================================================================
	# TEST C — SUCCESSFUL FORWARD TRANSPORT
	# =============================================================================

	assert(ConveyorTransportLink.try_transfer_forward(belt_a))

	assert(transport_a.get_held_item() == null)
	assert(transport_b.get_held_item() == ore)

	print("PASS C: Ore moved forward to Belt B")

	# =============================================================================
	# TEST D — BACKPRESSURE
	# =============================================================================

	assert(transport_a.try_receive_from_inventory(
		source_inventory, ore
	))

	assert(not ConveyorTransportLink.try_transfer_forward(belt_a))

	assert(transport_a.get_held_item() == ore)
	assert(transport_b.get_held_item() == ore)

	print("PASS D: Full destination blocks transfer")

	# =============================================================================
	# TEST E — WRONG DIRECTION
	# =============================================================================

	assert(not ConveyorTransportLink.try_transfer_forward(belt_b))

	print("PASS E: Reverse transport rejected")

	# =============================================================================
	# TEST F — PHYSICAL MISALIGNMENT
	# =============================================================================

	# Return Belt B's item to the test source
	# so destination capacity does not hide
	# a potential geometry-validation failure.

	assert(
		transport_b.cargo_inventory.transfer_to(
			source_inventory, ore, 1
		) == 1
	)

	belt_b.position = Vector3(0, 0, -2)

	assert(not ConveyorTransportLink.try_transfer_forward(belt_a))

	# Restore the original valid placement.

	belt_b.position = Vector3(0, 0, -1)

	assert(ConveyorTransportLink.try_transfer_forward(belt_a))

	print("PASS F: Misaligned endpoints reject transfer")

	# =============================================================================
	# TEST G — DISCONNECTION
	# =============================================================================

	assert(belt_a.disconnect_next())

	assert(transport_a.try_receive_from_inventory(
		source_inventory, ore
	))

	assert(not ConveyorTransportLink.try_transfer_forward(belt_a))

	print("PASS G: Disconnection prevents item transfer")

	# =============================================================================
	# RESOURCE CONSERVATION
	# =============================================================================

	var remaining_total: int = (
		source_inventory.get_amount(ore)
		+ transport_a.cargo_inventory.get_amount(ore)
		+ transport_b.cargo_inventory.get_amount(ore)
	)

	assert(remaining_total == 3)

	print("PASS: All 3 original ore units conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	test_root.queue_free()
	source_inventory.free()

	print("==========================================")
	print("ALL 7 CONNECTED TRANSPORT TESTS PASSED")
	print("==========================================")
