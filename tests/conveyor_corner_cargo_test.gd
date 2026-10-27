
extends Node


# =============================================================================
# CHAT 08.2B-3C — CORNER CARGO PRESERVATION TEST
# =============================================================================

# Tests cargo movement through automatic conveyor corners.
#
# Validates:
# - Built-in transport components
# - Cargo preservation during corner conversion
# - Original node identity and timer preservation
# - Timed movement through right and left corners
# - Destination backpressure and recovery
# - Universal item compatibility
# - Resource conservation


# =============================================================================
# CREATE TEST CONVEYOR
# =============================================================================

func _make_belt(
	parent: Node3D,
	scene: PackedScene
) -> ConveyorSegment:

	var belt: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	assert(belt != null)

	parent.add_child(belt)

	# Disable automatic updates for deterministic testing.

	var timer: ConveyorTransportTimer = (
		belt.get_node_or_null("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	assert(timer != null)

	timer.set_process(false)
	timer.travel_interval = 1.0

	return belt


# =============================================================================
# GET EXISTING CARGO COMPONENT
# =============================================================================

func _get_transport(
	belt: ConveyorSegment
) -> ConveyorTransportComponent:

	var transport: ConveyorTransportComponent = (
		belt.get_node_or_null("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)

	assert(transport != null)

	assert(
		is_instance_valid(transport.cargo_inventory)
	)

	assert(
		transport.cargo_inventory.max_capacity == 1
	)

	assert(
		transport.cargo_inventory
		== belt.get_node_or_null("CargoInventory")
	)

	return transport


# =============================================================================
# RUN CORNER CARGO TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.2B-3C: CORNER CARGO TEST =====")

	# =============================================================================
	# LOAD GENERIC ITEM DEFINITIONS
	# =============================================================================

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var future_item := ItemDefinition.new()
	future_item.item_id = &"test_corner_generic"
	future_item.display_name = "Future Factory Item"

	assert(ore != null)
	assert(ingot != null)

	# =============================================================================
	# CREATE TEST INVENTORIES
	# =============================================================================

	var supply := InventoryComponent.new()
	supply.max_capacity = 10

	var destination := InventoryComponent.new()
	destination.max_capacity = 10

	assert(supply.add_item(ore, 1) == 1)
	assert(supply.add_item(ingot, 1) == 1)
	assert(supply.add_item(future_item, 1) == 1)

	# =============================================================================
	# LOAD CONVEYOR SCENE
	# =============================================================================

	var conveyor_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(conveyor_scene != null)

	# =============================================================================
	# CREATE RIGHT-CORNER ASSEMBLY
	# =============================================================================

	var right_root := Node3D.new()
	add_child(right_root)

	var incoming := _make_belt(
		right_root, conveyor_scene
	)

	var corner := _make_belt(
		right_root, conveyor_scene
	)

	var receiver := _make_belt(
		right_root, conveyor_scene
	)

	incoming.position = Vector3(0, 0, 1)
	corner.position = Vector3.ZERO

	receiver.position = Vector3(1, 0, 0)
	receiver.rotation_degrees.y = -90.0

	# =============================================================================
	# TEST A — BUILT-IN COMPONENTS
	# =============================================================================

	var corner_transport := _get_transport(corner)
	var receiver_transport := _get_transport(receiver)

	var corner_timer: ConveyorTransportTimer = (
		corner.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	assert(corner_timer != null)

	print("PASS A: Real conveyors contain transport components")

	# =============================================================================
	# TEST B — LOAD CARGO BEFORE CONVERSION
	# =============================================================================

	assert(incoming.try_connect_to(corner))

	assert(
		corner_transport.try_receive_from_inventory(
			supply, ore
		)
	)

	assert(corner_transport.get_held_item() == ore)

	# Partially advance the original straight belt.

	assert(
		not corner_timer.advance_transport(0.4)
	)

	assert(
		is_equal_approx(
			corner_timer.elapsed_seconds, 0.4
		)
	)

	print("PASS B: Original straight stores cargo and progress")

	# =============================================================================
	# TEST C — PRESERVE CARGO DURING RIGHT CONVERSION
	# =============================================================================

	var original_id: int = corner.get_instance_id()

	var original_inventory: InventoryComponent = (
		corner_transport.cargo_inventory
	)

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			corner,
			receiver,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(corner.get_instance_id() == original_id)

	assert(
		_get_transport(corner) == corner_transport
	)

	assert(
		corner_transport.cargo_inventory
		== original_inventory
	)

	assert(
		corner.get_node("ConveyorTransportTimer")
		== corner_timer
	)

	assert(corner_transport.get_held_item() == ore)

	assert(
		is_equal_approx(
			corner_timer.elapsed_seconds, 0.4
		)
	)

	assert(incoming.next_segment == corner)
	assert(corner.previous_segment == incoming)

	assert(corner.next_segment == receiver)
	assert(receiver.previous_segment == corner)

	print("PASS C: Right conversion preserves cargo and timer")

	# =============================================================================
	# TEST D — TIMED MOVEMENT THROUGH RIGHT CORNER
	# =============================================================================

	# The item already traveled 0.4 seconds.
	# Another 0.61 seconds completes its journey.

	assert(corner_timer.advance_transport(0.61))

	assert(corner_transport.get_held_item() == null)

	assert(receiver_transport.get_held_item() == ore)

	print("PASS D: Ore travels through right corner")

	# =============================================================================
	# TEST E — BLOCKED CORNER OUTPUT
	# =============================================================================

	# Receiver still contains the ore.
	# Load an ingot into the corner.

	assert(
		corner_transport.try_receive_from_inventory(
			supply, ingot
		)
	)

	assert(
		not corner_timer.advance_transport(1.0)
	)

	assert(corner_timer.transport_status == "Blocked")

	assert(corner_transport.get_held_item() == ingot)

	assert(receiver_transport.get_held_item() == ore)

	print("PASS E: Occupied output safely blocks cargo")

	# =============================================================================
	# TEST F — RESUME WHEN OUTPUT BECOMES AVAILABLE
	# =============================================================================

	assert(
		receiver_transport.cargo_inventory.transfer_to(
			destination, ore, 1
		) == 1
	)

	assert(corner_timer.advance_transport(0.01))

	assert(corner_transport.get_held_item() == null)

	assert(receiver_transport.get_held_item() == ingot)

	print("PASS F: Blocked corner resumes without item loss")

	# =============================================================================
	# CREATE ROTATED LEFT-CORNER ASSEMBLY
	# =============================================================================

	var left_root := Node3D.new()
	add_child(left_root)

	var left_incoming := _make_belt(
		left_root, conveyor_scene
	)

	var left_corner := _make_belt(
		left_root, conveyor_scene
	)

	var left_receiver := _make_belt(
		left_root, conveyor_scene
	)

	left_incoming.position = Vector3(5, 0, 1)
	left_corner.position = Vector3(5, 0, 0)

	left_receiver.position = Vector3(4, 0, 0)
	left_receiver.rotation_degrees.y = 90.0

	left_root.rotation_degrees.y = 90.0

	# =============================================================================
	# TEST G — GENERIC ITEM THROUGH LEFT CORNER
	# =============================================================================

	var left_transport := _get_transport(left_corner)
	var left_destination := _get_transport(left_receiver)

	var left_timer: ConveyorTransportTimer = (
		left_corner.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	assert(left_incoming.try_connect_to(left_corner))

	# Load an item created only for this test.

	assert(
		left_transport.try_receive_from_inventory(
			supply, future_item
		)
	)

	var left_original_id: int = (
		left_corner.get_instance_id()
	)

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			left_corner,
			left_receiver,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(
		left_corner.get_instance_id() == left_original_id
	)

	assert(
		left_transport.get_held_item() == future_item
	)

	assert(left_timer.advance_transport(1.0))

	assert(
		left_destination.get_held_item() == future_item
	)

	print("PASS G: Rotated left corner transports generic item")

	# =============================================================================
	# TEST H — RESOURCE CONSERVATION
	# =============================================================================

	# Check every original item across every inventory.
	# Each distinct item was created with quantity 1.

	var all_belts: Array[ConveyorSegment] = [
		incoming,
		corner,
		receiver,
		left_incoming,
		left_corner,
		left_receiver
	]

	for candidate in [ore, ingot, future_item]:

		var item: ItemDefinition = (
			candidate as ItemDefinition
		)

		var total: int = (
			supply.get_amount(item)
			+ destination.get_amount(item)
		)

		for belt in all_belts:

			var cargo := _get_transport(belt)

			total += cargo.cargo_inventory.get_amount(
				item
			)

		assert(total == 1)

	print("PASS H: All three item types conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	right_root.queue_free()
	left_root.queue_free()

	supply.free()
	destination.free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 8 CORNER CARGO TESTS PASSED")
	print("==========================================")
