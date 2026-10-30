
extends Node


# =============================================================================
# PERSISTENT BUILDING CONNECTION TEST
# =============================================================================

# Validates:
# - Initial connection state
# - Extractor-to-conveyor connection
# - Exclusive building-port ownership
# - Conveyor-to-Smelter connection
# - Conflicting belt connections
# - Misaligned endpoint rejection
# - Rotated building connection
# - Cleanup and inventory preservation


func _ready() -> void:

	print("\n===== CHAT 08.3C: BUILDING CONNECTION TEST =====")

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

	var belt_a := belt_scene.instantiate() as ConveyorSegment
	var belt_b := belt_scene.instantiate() as ConveyorSegment
	var belt_c := belt_scene.instantiate() as ConveyorSegment

	assert(extractor != null)
	assert(smelter != null)

	assert(belt_a != null)
	assert(belt_b != null)
	assert(belt_c != null)

	root.add_child(extractor)
	root.add_child(smelter)

	root.add_child(belt_a)
	root.add_child(belt_b)
	root.add_child(belt_c)

	smelter.position = Vector3(10, 0, 0)

	# =============================================================================
	# DISABLE AUTOMATIC GAMEPLAY PROCESSING
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

	for belt in [belt_a, belt_b, belt_c]:

		var timer := belt.get_node(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer

		timer.set_process(false)

	# =============================================================================
	# GET PORTS AND INVENTORY
	# =============================================================================

	var extractor_output := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var smelter_input := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	assert(extractor_output != null)
	assert(smelter_input != null)
	assert(extractor_inventory != null)

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var generic_item := ItemDefinition.new()
	generic_item.item_id = &"building_connection_generic"
	generic_item.display_name = "Future Factory Resource"

	assert(ore != null)

	assert(extractor_inventory.add_item(ore, 2) == 2)
	assert(extractor_inventory.add_item(generic_item, 1) == 1)

	# =============================================================================
	# TEST A — NEW CONNECTION STATE
	# =============================================================================

	assert(extractor_output.connected_conveyor == null)
	assert(smelter_input.connected_conveyor == null)

	assert(belt_a.input_building_port == null)
	assert(belt_c.output_building_port == null)

	print("PASS A: All physical connections start empty")

	# =============================================================================
	# TEST B — EXTRACTOR OUTPUT TO CONVEYOR INPUT
	# =============================================================================

	var preview := ConveyorBuildingSnap.get_preview_transform(
		extractor_output,
		belt_a
	)

	assert(preview.has("transform"))

	belt_a.global_transform = preview["transform"]

	assert(
		belt_a.try_connect_building_port(
			extractor_output
		)
	)

	assert(belt_a.input_building_port == extractor_output)
	assert(extractor_output.connected_conveyor == belt_a)

	print("PASS B: Extractor output connection established")

	# =============================================================================
	# TEST C — PREVENT DUPLICATE CONNECTIONS
	# =============================================================================

	# Position another belt at the same physical port.
	# The port must remain exclusive to Belt A.

	belt_b.global_transform = belt_a.global_transform

	assert(
		not belt_b.try_connect_building_port(
			extractor_output
		)
	)

	assert(
		not belt_a.try_connect_building_port(
			extractor_output
		)
	)

	assert(extractor_output.connected_conveyor == belt_a)

	print("PASS C: Duplicate port connections rejected")

	# =============================================================================
	# TEST D — CONVEYOR OUTPUT TO SMELTER INPUT
	# =============================================================================

	preview = ConveyorBuildingSnap.get_preview_transform(
		smelter_input,
		belt_c
	)

	assert(preview.has("transform"))

	belt_c.global_transform = preview["transform"]

	assert(
		belt_c.try_connect_building_port(
			smelter_input
		)
	)

	assert(belt_c.output_building_port == smelter_input)
	assert(smelter_input.connected_conveyor == belt_c)

	print("PASS D: Smelter input connection established")

	# =============================================================================
	# TEST E — PREVENT CONFLICTING BELT LINKS
	# =============================================================================

	var upstream := belt_scene.instantiate() as ConveyorSegment
	var downstream := belt_scene.instantiate() as ConveyorSegment

	assert(upstream != null)
	assert(downstream != null)

	root.add_child(upstream)
	root.add_child(downstream)

	# Upstream attempts to feed an already occupied
	# input on Belt A.

	upstream.global_transform = Transform3D(
		belt_a.global_transform.basis,
		belt_a.global_position
		+ belt_a.global_transform.basis * Vector3.BACK
	)

	assert(not upstream.try_connect_to(belt_a))

	# Belt C attempts to feed another conveyor while
	# its output already connects to the Smelter.

	downstream.global_transform = Transform3D(
		belt_c.global_transform.basis,
		belt_c.global_position
		+ belt_c.global_transform.basis * Vector3.FORWARD
	)

	assert(not belt_c.try_connect_to(downstream))

	print("PASS E: Conflicting conveyor links rejected")

	# =============================================================================
	# TEST F — MISALIGNED CONNECTION
	# =============================================================================

	assert(
		belt_a.disconnect_building_port(
			extractor_output
		)
	)

	assert(extractor_output.connected_conveyor == null)

	belt_a.position.z -= 1.0

	assert(
		not belt_a.try_connect_building_port(
			extractor_output
		)
	)

	belt_a.position.z += 1.0

	assert(
		belt_a.try_connect_building_port(
			extractor_output
		)
	)

	print("PASS F: Misalignment rejected and reconnection works")

	# =============================================================================
	# TEST G — ROTATED BUILDING CONNECTION
	# =============================================================================

	assert(
		belt_a.disconnect_building_port(
			extractor_output
		)
	)

	extractor.rotation_degrees.y = 90.0

	preview = ConveyorBuildingSnap.get_preview_transform(
		extractor_output,
		belt_a
	)

	assert(preview.has("transform"))

	belt_a.global_transform = preview["transform"]

	assert(
		belt_a.try_connect_building_port(
			extractor_output
		)
	)

	assert(extractor_output.connected_conveyor == belt_a)

	print("PASS G: Rotated building maintains valid connection")

	# =============================================================================
	# TEST H — CLEANUP AND RESOURCE PRESERVATION
	# =============================================================================

	assert(extractor_inventory.get_amount(ore) == 2)
	assert(extractor_inventory.get_amount(generic_item) == 1)

	# Removing a conveyor must clear the building's
	# reference to it.

	belt_a.free()

	assert(extractor_output.connected_conveyor == null)

	# Removing a building must clear the surviving
	# conveyor's reference to its input port.

	smelter.free()

	assert(belt_c.output_building_port == null)

	assert(extractor_inventory.get_amount(ore) == 2)
	assert(extractor_inventory.get_amount(generic_item) == 1)

	print("PASS H: Connection cleanup preserves resources")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	print("==========================================")
	print("ALL 8 BUILDING CONNECTION TESTS PASSED")
	print("==========================================")
