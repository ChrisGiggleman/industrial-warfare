
extends Node


# =============================================================================
# CHAT 08.3F-2A — BUILDING PORT DISCOVERY TEST
# =============================================================================

# Verifies:
# A. Invalid requests are rejected.
# B. Extractor output discovery.
# C. Physical alignment and read-only preview.
# D. Incorrect rotation rejection.
# E. Search radius enforcement.
# F. Occupied port rejection and recovery.
# G. Smelter input discovery.
# H. Rotated building support and state preservation.


func _ready() -> void:

	print("\n===== CHAT 08.3F-2A: PORT DISCOVERY TEST =====")

	# =============================================================================
	# LOAD EXISTING FACTORY SCENES
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

	# =============================================================================
	# CREATE TEST OBJECTS
	# =============================================================================

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

	smelter.position = Vector3(10.0, 0.0, 0.0)

	# =============================================================================
	# DISABLE UNRELATED GAMEPLAY PROCESSING
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

	# =============================================================================
	# GET PORTS AND INVENTORIES
	# =============================================================================

	var extractor_port := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var smelter_port := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	var smelter_inventory := smelter.get_node(
		"InputInventory"
	) as InventoryComponent

	var belt_input := belt.get_node(
		"InputEndpoint"
	) as Marker3D

	var belt_output := belt.get_node(
		"OutputEndpoint"
	) as Marker3D

	assert(extractor_port != null)
	assert(smelter_port != null)

	# =============================================================================
	# TEST A — INVALID REQUESTS
	# =============================================================================

	assert(
		ConveyorBuildingPortFinder.find_nearest_preview(
			null,
			Vector3.ZERO
		).is_empty()
	)

	assert(
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			Vector3.ZERO,
			0.0
		).is_empty()
	)

	print("PASS A: Invalid discovery requests rejected")

	# =============================================================================
	# TEST B — FIND EXTRACTOR OUTPUT PORT
	# =============================================================================

	belt.rotation_degrees.y = 0.0

	var mouse_position := Vector3(0.0, 0.0, -1.5)

	var original_transform: Transform3D = (
		belt.global_transform
	)

	var result := (
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			mouse_position
		)
	)

	assert(result.has("port"))
	assert(result.has("transform"))
	assert(result["port"] == extractor_port)

	print("PASS B: Nearby Extractor output discovered")

	# =============================================================================
	# TEST C — ALIGNMENT WITHOUT MUTATION
	# =============================================================================

	# Discovery must not move the original conveyor.

	assert(
		belt.global_transform.is_equal_approx(
			original_transform
		)
	)

	# Temporarily apply the suggested position
	# to independently inspect physical alignment.

	belt.global_transform = result["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			extractor_port,
			belt_input,
			ConveyorSegment.CONNECTION_GAP
		)
	)

	assert(extractor_port.connected_conveyor == null)

	# Restore the original belt transform.

	belt.global_transform = original_transform

	print("PASS C: Preview alignment is read-only")

	# =============================================================================
	# TEST D — REJECT INCORRECT BELT ROTATION
	# =============================================================================

	belt.rotation_degrees.y = 180.0

	result = (
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			mouse_position
		)
	)

	assert(result.is_empty())

	print("PASS D: Incorrect conveyor direction rejected")

	# =============================================================================
	# TEST E — SEARCH RADIUS
	# =============================================================================

	belt.rotation_degrees.y = 0.0

	result = (
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			Vector3(100.0, 0.0, 100.0)
		)
	)

	assert(result.is_empty())

	print("PASS E: Distant ports rejected")

	# =============================================================================
	# TEST F — OCCUPIED PORT AND RECOVERY
	# =============================================================================

	result = (
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			mouse_position
		)
	)

	assert(result.has("transform"))

	belt.global_transform = result["transform"]

	assert(belt.try_connect_building_port(extractor_port))

	assert(
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			mouse_position
		).is_empty()
	)

	assert(belt.disconnect_building_port(extractor_port))

	assert(
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			mouse_position
		).has("port")
	)

	print("PASS F: Occupied port rejected; disconnect restores")

	# =============================================================================
	# TEST G — FIND SMELTER INPUT PORT
	# =============================================================================

	# Use the existing snap helper to identify the
	# Smelter input's proposed conveyor position.

	var smelter_preview := (
		ConveyorBuildingSnap.get_preview_transform(
			smelter_port,
			belt
		)
	)

	assert(smelter_preview.has("transform"))

	var smelter_transform: Transform3D = (
		smelter_preview["transform"]
	)

	# This Smelter's input requires a -90-degree
	# conveyor root rotation.

	belt.rotation_degrees.y = -90.0

	result = (
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			smelter_transform.origin
		)
	)

	assert(result.has("port"))
	assert(result["port"] == smelter_port)

	belt.global_transform = result["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			belt_output,
			smelter_port,
			ConveyorSegment.CONNECTION_GAP
		)
	)

	print("PASS G: Compatible Smelter input discovered")

	# =============================================================================
	# TEST H — ROTATED EXTRACTOR
	# =============================================================================

	extractor.position = Vector3(4.0, 0.0, 5.0)
	extractor.rotation_degrees.y = 90.0

	belt.rotation_degrees.y = 90.0

	var rotated_preview := (
		ConveyorBuildingSnap.get_preview_transform(
			extractor_port,
			belt
		)
	)

	assert(rotated_preview.has("transform"))

	var rotated_transform: Transform3D = (
		rotated_preview["transform"]
	)

	result = (
		ConveyorBuildingPortFinder.find_nearest_preview(
			belt,
			rotated_transform.origin
		)
	)

	assert(result.has("port"))
	assert(result["port"] == extractor_port)

	belt.global_transform = result["transform"]

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			extractor_port,
			belt_input,
			ConveyorSegment.CONNECTION_GAP
		)
	)

	# Discovery and placement calculations must
	# not move inventory resources or create links.

	assert(extractor_inventory.get_total_amount() == 0)
	assert(smelter_inventory.get_total_amount() == 0)

	assert(extractor_port.connected_conveyor == null)
	assert(smelter_port.connected_conveyor == null)

	print("PASS H: Rotated port and inventory preserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 8 BUILDING PORT DISCOVERY TESTS PASSED")
	print("==========================================")
