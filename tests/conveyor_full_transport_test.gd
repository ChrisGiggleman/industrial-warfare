
extends Node


# =============================================================================
# FULL CONVEYOR TRANSPORT REGRESSION
# =============================================================================

# Tests six connected conveyor segments, including:
# - Right and left automatic corner conversion
# - Generic item definitions
# - One-item cargo capacity
# - Timed forwarding through a conveyor chain
# - Backpressure and recovery
# - Item ordering and resource conservation


# =============================================================================
# CREATE TEST CONVEYOR
# =============================================================================

func _make_belt(
	parent: Node3D,
	scene: PackedScene,
	belt_position: Vector3,
	y_rotation: float
) -> ConveyorSegment:

	var belt: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	assert(belt != null)

	parent.add_child(belt)

	belt.position = belt_position
	belt.rotation_degrees.y = y_rotation

	# Use the real built-in cargo components.

	var cargo := belt.get_node_or_null(
		"CargoInventory"
	) as InventoryComponent

	var transport := belt.get_node_or_null(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var timer := belt.get_node_or_null(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	assert(cargo != null)
	assert(cargo.max_capacity == 1)
	assert(transport != null)
	assert(transport.cargo_inventory == cargo)
	assert(timer != null)

	# Manually control timing for repeatable assertions.

	timer.set_process(false)
	timer.travel_interval = 1.0

	return belt


# =============================================================================
# GET TRANSPORT COMPONENT
# =============================================================================

func _transport(
	belt: ConveyorSegment
) -> ConveyorTransportComponent:

	return belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent


# =============================================================================
# ADVANCE THE ENTIRE CONVEYOR CHAIN
# =============================================================================

# Update from downstream to upstream.
#
# Each segment is updated exactly once per test tick.
# This prevents a newly received item from traveling
# several full segments in one simulated update.

func _tick_chain(
	belts: Array[ConveyorSegment]
) -> void:

	for index in range(
		belts.size() - 1, -1, -1
	):

		var timer := belts[index].get_node(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer

		timer.advance_transport(1.0)


# =============================================================================
# RUN FULL TRANSPORT TEST
# =============================================================================

func _ready() -> void:

	print(
		"\n===== CHAT 08.2C-1: FULL TRANSPORT TEST ====="
	)

	# =============================================================================
	# PREPARE THREE DIFFERENT ITEM TYPES
	# =============================================================================

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot := load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var ammunition := ItemDefinition.new()
	ammunition.item_id = &"test_ammunition"
	ammunition.display_name = "Test Ammunition"

	assert(ore != null)
	assert(ingot != null)

	var supply := InventoryComponent.new()
	supply.max_capacity = 10

	var destination := InventoryComponent.new()
	destination.max_capacity = 10

	assert(supply.add_item(ore, 1) == 1)
	assert(supply.add_item(ingot, 1) == 1)
	assert(supply.add_item(ammunition, 1) == 1)

	# =============================================================================
	# CREATE SIX ACTUAL CONVEYOR SEGMENTS
	# =============================================================================

	var scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	var root := Node3D.new()
	add_child(root)

	var belt_a := _make_belt(
		root, scene, Vector3(0, 0, 1), 0.0
	)

	var belt_b := _make_belt(
		root, scene, Vector3(0, 0, 0), 0.0
	)

	var belt_c := _make_belt(
		root, scene, Vector3(1, 0, 0), -90.0
	)

	var belt_d := _make_belt(
		root, scene, Vector3(2, 0, 0), -90.0
	)

	var belt_e := _make_belt(
		root, scene, Vector3(2, 0, -1), 0.0
	)

	var belt_f := _make_belt(
		root, scene, Vector3(2, 0, -2), 0.0
	)

	var belts: Array[ConveyorSegment] = [
		belt_a, belt_b, belt_c,
		belt_d, belt_e, belt_f
	]

	print("PASS A: Six real conveyor buffers initialized")

	# =============================================================================
	# CONNECT THE RIGHT AND LEFT CORNERS
	# =============================================================================

	assert(belt_a.try_connect_to(belt_b))

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			belt_b,
			belt_c,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	assert(belt_c.try_connect_to(belt_d))

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			belt_d,
			belt_e,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(belt_e.try_connect_to(belt_f))

	# Confirm every link is reciprocal.

	for index in range(belts.size() - 1):

		assert(
			belts[index].next_segment
			== belts[index + 1]
		)

		assert(
			belts[index + 1].previous_segment
			== belts[index]
		)

	print("PASS B: Right/left conveyor route connected")

	# =============================================================================
	# LOAD THREE DIFFERENT ITEM TYPES
	# =============================================================================

	assert(
		_transport(belt_a).try_receive_from_inventory(
			supply, ore
		)
	)

	assert(
		_transport(belt_b).try_receive_from_inventory(
			supply, ingot
		)
	)

	assert(
		_transport(belt_c).try_receive_from_inventory(
			supply, ammunition
		)
	)

	assert(supply.get_total_amount() == 0)

	print("PASS C: Three different items loaded")

	# =============================================================================
	# TEST FIRST TRANSPORT TICK
	# =============================================================================

	_tick_chain(belts)

	assert(_transport(belt_a).get_held_item() == null)
	assert(_transport(belt_b).get_held_item() == ore)
	assert(_transport(belt_c).get_held_item() == ingot)
	assert(_transport(belt_d).get_held_item() == ammunition)

	print("PASS D: Items move forward one segment")

	# =============================================================================
	# ADVANCE ITEMS THROUGH BOTH CORNERS
	# =============================================================================

	_tick_chain(belts)
	_tick_chain(belts)

	assert(_transport(belt_d).get_held_item() == ore)
	assert(_transport(belt_e).get_held_item() == ingot)
	assert(_transport(belt_f).get_held_item() == ammunition)

	print("PASS E: Items traverse both corners")

	# =============================================================================
	# TEST END-OF-LINE BACKPRESSURE
	# =============================================================================

	# Belt F is full and has no connected output.
	# Both preceding items must remain in place.

	_tick_chain(belts)

	assert(_transport(belt_d).get_held_item() == ore)
	assert(_transport(belt_e).get_held_item() == ingot)
	assert(_transport(belt_f).get_held_item() == ammunition)

	print("PASS F: Full output blocks upstream items")

	# =============================================================================
	# DRAIN OUTPUT AND RESUME MOVEMENT
	# =============================================================================

	assert(
		_transport(belt_f).cargo_inventory.transfer_to(
			destination, ammunition, 1
		) == 1
	)

	_tick_chain(belts)

	assert(_transport(belt_f).get_held_item() == ingot)
	assert(_transport(belt_e).get_held_item() == ore)

	assert(
		_transport(belt_f).cargo_inventory.transfer_to(
			destination, ingot, 1
		) == 1
	)

	_tick_chain(belts)

	assert(_transport(belt_f).get_held_item() == ore)

	assert(
		_transport(belt_f).cargo_inventory.transfer_to(
			destination, ore, 1
		) == 1
	)

	print("PASS G: Blocked items resume without overtaking")

	# =============================================================================
	# VERIFY COMPLETE RESOURCE CONSERVATION
	# =============================================================================

	for candidate in [ore, ingot, ammunition]:

		var item: ItemDefinition = candidate as ItemDefinition

		var total: int = (
			supply.get_amount(item)
			+ destination.get_amount(item)
		)

		for belt in belts:

			total += (
				_transport(belt).cargo_inventory.get_amount(
					item
				)
			)

		assert(total == 1)

	# Every transported resource reached the destination.

	assert(destination.get_total_amount() == 3)

	for belt in belts:
		assert(
			_transport(belt).get_held_item() == null
		)

	print("PASS H: All item types conserved and delivered")

	# =============================================================================
	# CLEANUP AND RESULTS
	# =============================================================================

	root.queue_free()

	supply.free()
	destination.free()

	print("==========================================")
	print("ALL 8 FULL TRANSPORT TESTS PASSED")
	print("==========================================")
