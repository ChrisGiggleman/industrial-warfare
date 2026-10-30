
extends Node


# =============================================================================
# EXTRACTOR OUTPUT PORT TEST
# =============================================================================

# Validates:
# - Existing Extractor scene port configuration
# - Correct inventory reference
# - Output direction and resource availability
# - Generic item support
# - Physical alignment with a conveyor input
# - Building rotation
# - No inventory modification during checks


func _ready() -> void:

	print("\n===== CHAT 08.3A: EXTRACTOR PORT TEST =====")

	# =============================================================================
	# LOAD TEST ASSETS
	# =============================================================================

	var extractor_scene: PackedScene = load(
		"res://scenes/buildings/test_extractor.tscn"
	)

	var conveyor_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	)

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	)

	assert(extractor_scene != null)
	assert(conveyor_scene != null)
	assert(ore != null)

	var generic_item := ItemDefinition.new()
	generic_item.item_id = &"test_future_resource"
	generic_item.display_name = "Future Resource"

	# =============================================================================
	# CREATE ISOLATED BUILDING AND BELT
	# =============================================================================

	var root := Node3D.new()
	add_child(root)

	var extractor := extractor_scene.instantiate() as Node3D
	var belt := conveyor_scene.instantiate() as ConveyorSegment

	assert(extractor != null)
	assert(belt != null)

	root.add_child(extractor)
	root.add_child(belt)

	var extraction := extractor.get_node(
		"ExtractorComponent"
	) as ExtractorComponent

	var logistics := extractor.get_node(
		"LogisticsTransferComponent"
	) as LogisticsTransferComponent

	# Keep the test independent of automatic extraction.

	extraction.set_process(false)
	logistics.set_process(false)

	var inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	var output_port := extractor.get_node_or_null(
		"OutputPort"
	) as ItemPortComponent

	var belt_input := belt.get_node(
		"InputEndpoint"
	) as Marker3D

	# =============================================================================
	# TEST A — PORT AND INVENTORY EXIST
	# =============================================================================

	assert(output_port != null)
	assert(inventory != null)
	assert(output_port.inventory == inventory)

	print("PASS A: Extractor output references inventory")

	# =============================================================================
	# TEST B — OUTPUT DIRECTION
	# =============================================================================

	assert(
		output_port.direction
		== ItemPortComponent.PortDirection.OUTPUT
	)

	assert(
		output_port.position.is_equal_approx(
			Vector3(0.0, 0.5, -1.0)
		)
	)

	assert(
		output_port.rotation.is_equal_approx(
			Vector3.ZERO
		)
	)

	assert(not output_port.can_accept_item(ore, 1))

	print("PASS B: Output port configured correctly")

	# =============================================================================
	# TEST C — EMPTY INVENTORY
	# =============================================================================

	assert(not output_port.can_provide_item(ore, 1))

	print("PASS C: Empty extractor cannot provide items")

	# =============================================================================
	# TEST D — ITEM AVAILABILITY
	# =============================================================================

	assert(inventory.add_item(ore, 3) == 3)

	assert(output_port.can_provide_item(ore, 1))
	assert(output_port.can_provide_item(ore, 3))
	assert(not output_port.can_provide_item(ore, 4))

	print("PASS D: Output validates available quantity")

	# =============================================================================
	# TEST E — GENERIC RESOURCE SUPPORT
	# =============================================================================

	assert(inventory.add_item(generic_item, 1) == 1)

	assert(output_port.can_provide_item(generic_item, 1))
	assert(not output_port.can_provide_item(null, 1))

	print("PASS E: Output accepts generic item definitions")

	# =============================================================================
	# TEST F — CONVEYOR ENDPOINT ALIGNMENT
	# =============================================================================

	# Temporary test positioning.
	# No permanent gameplay snapping is created yet.

	belt.position = Vector3(0.0, 0.0, -1.5)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_port,
			belt_input,
			0.05
		)
	)

	# Moving the belt away must reject alignment.

	belt.position.z = -2.5

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			output_port,
			belt_input,
			0.05
		)
	)

	print("PASS F: Physical output alignment validated")

	# =============================================================================
	# TEST G — ROTATED BUILDING CONNECTION
	# =============================================================================

	extractor.rotation_degrees.y = 90.0

	belt.position = Vector3(-1.5, 0.0, 0.0)
	belt.rotation_degrees.y = 90.0

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			output_port,
			belt_input,
			0.05
		)
	)

	# Port checks must never consume stored items.

	assert(inventory.get_amount(ore) == 3)
	assert(inventory.get_amount(generic_item) == 1)

	print("PASS G: Rotated port aligns and conserves items")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 7 EXTRACTOR OUTPUT PORT TESTS PASSED")
	print("==========================================")
