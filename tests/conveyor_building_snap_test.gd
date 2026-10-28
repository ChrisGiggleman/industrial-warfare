
extends Node


# =============================================================================
# CHAT 08.3B — BUILDING CONVEYOR SNAP FOUNDATION TEST
# =============================================================================

# Validates:
# - Missing port rejection
# - Extractor output snapping
# - Rotated extractor snapping
# - Smelter input snapping
# - Rotated smelter snapping
# - Occupied endpoint protection
# - Inventory preservation


func _ready() -> void:

	print("\n===== CHAT 08.3B: BUILDING SNAP TEST =====")

	# =============================================================================
	# LOAD SCENES
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

	assert(extractor_scene != null)
	assert(smelter_scene != null)
	assert(belt_scene != null)

	var root := Node3D.new()
	add_child(root)

	var extractor := extractor_scene.instantiate() as Node3D
	var smelter := smelter_scene.instantiate() as Node3D
	var belt := belt_scene.instantiate() as ConveyorSegment

	assert(extractor != null)
	assert(smelter != null)
	assert(belt != null)

	root.add_child(extractor)
	root.add_child(smelter)
	root.add_child(belt)

	# =============================================================================
	# DISABLE UNRELATED PRODUCTION AND LOGISTICS
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

	(
		belt.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	).set_process(false)

	var extractor_output := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var smelter_input := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var belt_input := belt.get_node(
		"InputEndpoint"
	) as Marker3D

	var belt_output := belt.get_node(
		"OutputEndpoint"
	) as Marker3D

	assert(extractor_output != null)
	assert(smelter_input != null)

	# =============================================================================
	# TEST A — INVALID PORT
	# =============================================================================

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			null, belt
		).is_empty()
	)

	print("PASS A: Invalid port rejected")

	# =============================================================================
	# TEST B — EXTRACTOR OUTPUT SNAPPING
	# =============================================================================

	var original_transform: Transform3D = belt.global_transform

	var preview := ConveyorBuildingSnap.get_preview_transform(
		extractor_output, belt
	)

	assert(preview.has("transform"))

	# Preview must not move the belt.

	assert(
		belt.global_transform.is_equal_approx(
			original_transform
		)
	)

	belt.global_transform = preview["transform"]

	assert(
		belt.global_position.is_equal_approx(
			Vector3(0.0, 0.0, -1.5)
		)
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			extractor_output,
			belt_input,
			0.05
		)
	)

	print("PASS B: Extractor output snaps to belt input")

	# =============================================================================
	# TEST C — ROTATED EXTRACTOR
	# =============================================================================

	extractor.position = Vector3(8, 0, 4)
	extractor.rotation_degrees.y = 90.0

	preview = ConveyorBuildingSnap.get_preview_transform(
		extractor_output, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			extractor_output,
			belt_input,
			0.05
		)
	)

	assert(
		belt.global_position.is_equal_approx(
			Vector3(6.5, 0.0, 4.0)
		)
	)

	print("PASS C: Rotated extractor snapping correct")

	# =============================================================================
	# TEST D — SMELTER INPUT SNAPPING
	# =============================================================================

	smelter.position = Vector3(0, 0, 0)
	smelter.rotation_degrees.y = 0.0

	preview = ConveyorBuildingSnap.get_preview_transform(
		smelter_input, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			belt_output,
			smelter_input,
			0.05
		)
	)

	print("PASS D: Conveyor output snaps to smelter input")

	# =============================================================================
	# TEST E — ROTATED SMELTER
	# =============================================================================

	smelter.position = Vector3(12, 0, 6)
	smelter.rotation_degrees.y = 90.0

	preview = ConveyorBuildingSnap.get_preview_transform(
		smelter_input, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			belt_output,
			smelter_input,
			0.05
		)
	)

	print("PASS E: Rotated smelter input snapping correct")

	# =============================================================================
	# TEST F — OCCUPIED CONVEYOR ENDPOINT
	# =============================================================================

	var blocker := belt_scene.instantiate() as ConveyorSegment

	assert(blocker != null)
	root.add_child(blocker)

	belt.previous_segment = blocker

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			extractor_output, belt
		).is_empty()
	)

	belt.previous_segment = null
	belt.next_segment = blocker

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			smelter_input, belt
		).is_empty()
	)

	belt.next_segment = null

	print("PASS F: Occupied endpoints reject snapping")

	# =============================================================================
	# TEST G — INVENTORY PRESERVATION
	# =============================================================================

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	var smelter_inventory := smelter.get_node(
		"InputInventory"
	) as InventoryComponent

	assert(extractor_inventory.get_total_amount() == 0)
	assert(smelter_inventory.get_total_amount() == 0)

	print("PASS G: Preview does not transfer resources")

	# =============================================================================
	# TEST H — OCCUPIED EXTRACTOR OUTPUT PORT
	# =============================================================================

	preview = ConveyorBuildingSnap.get_preview_transform(
		extractor_output, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(
		belt.try_connect_building_port(
			extractor_output
		)
	)

	# The same port must not offer new snap previews,
	# whether for its current belt or a different belt.

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			extractor_output, belt
		).is_empty()
	)

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			extractor_output, blocker
		).is_empty()
	)

	print("PASS H: Occupied Extractor output rejects snapping")

	# =============================================================================
	# TEST I — OCCUPIED SMELTER INPUT PORT
	# =============================================================================

	assert(
		belt.disconnect_building_port(
			extractor_output
		)
	)

	preview = ConveyorBuildingSnap.get_preview_transform(
		smelter_input, belt
	)

	assert(preview.has("transform"))

	belt.global_transform = preview["transform"]

	assert(
		belt.try_connect_building_port(
			smelter_input
		)
	)

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			smelter_input, belt
		).is_empty()
	)

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			smelter_input, blocker
		).is_empty()
	)

	print("PASS I: Occupied Smelter input rejects snapping")

	# =============================================================================
	# TEST J — DISCONNECTION RESTORES SNAP AVAILABILITY
	# =============================================================================

	assert(
		belt.disconnect_building_port(
			smelter_input
		)
	)

	assert(smelter_input.connected_conveyor == null)

	assert(belt.output_building_port == null)

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			smelter_input, belt
		).has("transform")
	)

	assert(
		ConveyorBuildingSnap.get_preview_transform(
			extractor_output, belt
		).has("transform")
	)

	print("PASS J: Disconnecting restores snap availability")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 10 BUILDING SNAP TESTS PASSED")
	print("==========================================")
