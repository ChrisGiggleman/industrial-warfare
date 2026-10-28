
extends Node


# =============================================================================
# CHAT 08.3F-2E-1 — REVERSE BUILDING SNAP TEST
# =============================================================================

# Validates:
# A. Invalid requests
# B. Smelter input discovery
# C. Exact alignment without mutation
# D. Incorrect building rotation
# E. Search radius
# F. Occupied conveyor output
# G. Rotated Extractor output
# H. Persistent links and inventory preservation


func _ready() -> void:

	print("\n===== CHAT 08.3F-2E-1: BUILDING PLACEMENT SNAP =====")

	# =============================================================================
	# LOAD REAL FACTORY SCENES
	# =============================================================================

	var smelter_scene := load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	var extractor_scene := load(
		"res://scenes/buildings/test_extractor.tscn"
	) as PackedScene

	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(smelter_scene != null)
	assert(extractor_scene != null)
	assert(belt_scene != null)
	assert(ore != null)

	# =============================================================================
	# CREATE TEST ENVIRONMENT
	# =============================================================================

	var root := Node3D.new()
	add_child(root)

	var smelter := smelter_scene.instantiate() as Node3D
	var extractor := extractor_scene.instantiate() as Node3D

	var belt_a := belt_scene.instantiate() as ConveyorSegment
	var belt_b := belt_scene.instantiate() as ConveyorSegment

	root.add_child(smelter)
	root.add_child(extractor)
	root.add_child(belt_a)
	root.add_child(belt_b)

	# =============================================================================
	# DISABLE UNRELATED PROCESSING
	# =============================================================================

	(
		smelter.get_node("ProducerComponent")
		as ProducerComponent
	).set_process(false)

	(
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	).set_process(false)

	(
		extractor.get_node("ExtractorComponent")
		as ExtractorComponent
	).set_process(false)

	(
		extractor.get_node("LogisticsTransferComponent")
		as LogisticsTransferComponent
	).set_process(false)

	for belt: ConveyorSegment in [belt_a, belt_b]:

		(
			belt.get_node("ConveyorTransportTimer")
			as ConveyorTransportTimer
		).set_process(false)

	# =============================================================================
	# GET PORTS AND INVENTORIES
	# =============================================================================

	var smelter_input := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var extractor_output := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	assert(smelter_input != null)
	assert(extractor_output != null)

	# =============================================================================
	# TEST A — INVALID REQUESTS
	# =============================================================================

	assert(
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			null, Vector3.ZERO
		).is_empty()
	)

	assert(
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			smelter, Vector3.ZERO, 0.0
		).is_empty()
	)

	print("PASS A: Invalid placement requests rejected")

	# =============================================================================
	# PREPARE A BELT END FOR SMELTER INPUT
	# =============================================================================

	smelter.position = Vector3(10, 0, 10)

	var intended_transform: Transform3D = (
		smelter.global_transform
	)

	var belt_preview := ConveyorBuildingSnap.get_preview_transform(
		smelter_input, belt_a
	)

	assert(belt_preview.has("transform"))

	belt_a.global_transform = belt_preview["transform"]

	# Move the unplaced building away from its destination.
	# The reverse finder should recover its intended transform.

	smelter.position += Vector3(3, 0, 4)

	var original_transform: Transform3D = (
		smelter.global_transform
	)

	# =============================================================================
	# TEST B — SMELTER INPUT DISCOVERY
	# =============================================================================

	var result := (
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			smelter,
			intended_transform.origin
		)
	)

	assert(result.has("port"))
	assert(result.has("belt"))
	assert(result["port"] == smelter_input)
	assert(result["belt"] == belt_a)

	print("PASS B: Existing belt discovers Smelter input")

	# =============================================================================
	# TEST C — READ-ONLY ALIGNMENT
	# =============================================================================

	assert(
		smelter.global_transform.is_equal_approx(
			original_transform
		)
	)

	smelter.global_transform = result["transform"]

	assert(
		smelter.global_transform.is_equal_approx(
			intended_transform
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			belt_a.get_node("OutputEndpoint") as Marker3D,
			smelter_input,
			ConveyorSegment.CONNECTION_GAP
		)
	)

	assert(smelter_input.connected_conveyor == null)

	print("PASS C: Preview aligns without creating connections")

	# =============================================================================
	# TEST D — INCORRECT ROTATION
	# =============================================================================

	smelter.rotation_degrees.y = 90.0

	assert(
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			smelter,
			intended_transform.origin
		).is_empty()
	)

	smelter.global_transform = intended_transform

	print("PASS D: Incorrect building rotation rejected")

	# =============================================================================
	# TEST E — SEARCH RADIUS
	# =============================================================================

	assert(
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			smelter,
			Vector3(100, 0, 100)
		).is_empty()
	)

	print("PASS E: Distant conveyor endpoint rejected")

	# =============================================================================
	# TEST F — OCCUPIED CONVEYOR END
	# =============================================================================

	belt_a.next_segment = belt_b

	assert(
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			smelter,
			intended_transform.origin
		).is_empty()
	)

	belt_a.next_segment = null

	print("PASS F: Occupied conveyor output rejected")

	# =============================================================================
	# TEST G — ROTATED EXTRACTOR OUTPUT
	# =============================================================================

	extractor.position = Vector3(30, 0, 10)
	extractor.rotation_degrees.y = 90.0

	var extractor_intended: Transform3D = (
		extractor.global_transform
	)

	var extractor_belt_preview := (
		ConveyorBuildingSnap.get_preview_transform(
			extractor_output, belt_b
		)
	)

	assert(extractor_belt_preview.has("transform"))

	belt_b.global_transform = (
		extractor_belt_preview["transform"]
	)

	extractor.position += Vector3(4, 0, 3)

	result = (
		ConveyorBuildingPlacementSnap.find_nearest_preview(
			extractor,
			extractor_intended.origin
		)
	)

	assert(result.has("port"))
	assert(result["port"] == extractor_output)
	assert(result["belt"] == belt_b)

	extractor.global_transform = result["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			extractor_output,
			belt_b.get_node("InputEndpoint") as Marker3D,
			ConveyorSegment.CONNECTION_GAP
		)
	)

	print("PASS G: Rotated Extractor output snapping correct")

	# =============================================================================
	# TEST H — CONNECTION AND INVENTORY PRESERVATION
	# =============================================================================

	assert(extractor_inventory.add_item(ore, 2) == 2)

	assert(
		belt_a.try_connect_building_port(smelter_input)
	)

	assert(
		belt_b.try_connect_building_port(extractor_output)
	)

	assert(belt_a.output_building_port == smelter_input)
	assert(belt_b.input_building_port == extractor_output)

	assert(smelter_input.connected_conveyor == belt_a)
	assert(extractor_output.connected_conveyor == belt_b)

	assert(extractor_inventory.get_amount(ore) == 2)

	# Disconnect both connections.

	assert(belt_a.disconnect_building_port(smelter_input))
	assert(belt_b.disconnect_building_port(extractor_output))

	assert(smelter_input.connected_conveyor == null)
	assert(extractor_output.connected_conveyor == null)

	assert(extractor_inventory.get_amount(ore) == 2)

	print("PASS H: Connection cleanup preserves inventory")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 8 BUILDING PLACEMENT SNAP TESTS PASSED")
	print("==========================================")
