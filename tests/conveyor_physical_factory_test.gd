
extends Node


# =============================================================================
# PHYSICAL FACTORY INTEGRATION TEST
# =============================================================================

# Validates a complete physical production route:
#
# Extractor Inventory
#   -> Conveyor A
#   -> Conveyor B
#   -> Conveyor C
#   -> Smelter InputInventory
#   -> ProducerComponent
#   -> Smelter OutputInventory
#
# Uses actual building and conveyor scenes.
#
# Existing proximity logistics is disabled for this test.
# Conveyor timers and manufacturing are advanced manually
# to make the test deterministic.


# =============================================================================
# CREATE TEST CONVEYOR
# =============================================================================

func _make_belt(
	parent: Node3D,
	scene: PackedScene
) -> ConveyorSegment:

	var belt := scene.instantiate() as ConveyorSegment

	assert(belt != null)

	parent.add_child(belt)

	# Disable frame updates so this test can
	# advance the conveyor timers explicitly.

	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	assert(timer != null)

	timer.set_process(false)
	timer.travel_interval = 1.0

	var visual := belt.get_node_or_null(
		"CargoVisual"
	) as ConveyorCargoVisual

	assert(visual != null)
	visual.set_process(false)

	return belt


# =============================================================================
# RUN PHYSICAL FACTORY TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.3F-1: PHYSICAL FACTORY TEST =====")

	# =============================================================================
	# LOAD REAL FACTORY SCENES
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

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot := load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	assert(extractor_scene != null)
	assert(smelter_scene != null)
	assert(belt_scene != null)
	assert(ore != null)
	assert(ingot != null)

	# =============================================================================
	# CREATE ISOLATED FACTORY
	# =============================================================================

	var root := Node3D.new()
	add_child(root)

	var extractor := extractor_scene.instantiate() as Node3D
	var smelter := smelter_scene.instantiate() as Node3D

	assert(extractor != null)
	assert(smelter != null)

	root.add_child(extractor)
	root.add_child(smelter)

	var belt_a := _make_belt(root, belt_scene)
	var belt_b := _make_belt(root, belt_scene)
	var belt_c := _make_belt(root, belt_scene)

	# =============================================================================
	# GET BUILDING COMPONENTS
	# =============================================================================

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	var extractor_port := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var smelter_input := smelter.get_node(
		"InputInventory"
	) as InventoryComponent

	var smelter_output := smelter.get_node(
		"OutputInventory"
	) as InventoryComponent

	var smelter_port := smelter.get_node(
		"InputPort"
	) as ItemPortComponent

	var producer := smelter.get_node(
		"ProducerComponent"
	) as ProducerComponent

	assert(extractor_inventory != null)
	assert(extractor_port != null)
	assert(smelter_input != null)
	assert(smelter_output != null)
	assert(smelter_port != null)
	assert(producer != null)

	# =============================================================================
	# DISABLE LEGACY PROXIMITY LOGISTICS
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
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	).set_process(false)

	# We advance production manually in this test.

	producer.set_process(false)

	# =============================================================================
	# GET CONVEYOR COMPONENTS
	# =============================================================================

	var transport_a := belt_a.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var transport_b := belt_b.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var transport_c := belt_c.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var timer_a := belt_a.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	var timer_b := belt_b.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	var timer_c := belt_c.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	var visual_a := belt_a.get_node(
		"CargoVisual"
	) as ConveyorCargoVisual

	# =============================================================================
	# TEST A — INITIAL FACTORY STATE
	# =============================================================================

	assert(extractor_inventory.get_total_amount() == 0)
	assert(smelter_input.get_total_amount() == 0)
	assert(smelter_output.get_total_amount() == 0)

	assert(producer.recipe != null)
	assert(producer.accepts_input_item(ore))
	assert(not producer.accepts_input_item(ingot))

	print("PASS A: Factory components initialized")

	# =============================================================================
	# POSITION THE FIRST CONVEYOR AT EXTRACTOR OUTPUT
	# =============================================================================

	var preview := ConveyorBuildingSnap.get_preview_transform(
		extractor_port,
		belt_a
	)

	assert(preview.has("transform"))

	belt_a.global_transform = preview["transform"]

	# =============================================================================
	# POSITION SECOND AND THIRD CONVEYORS
	# =============================================================================

	# All three belts form a straight, directed line.

	belt_b.global_transform = Transform3D(
		belt_a.global_transform.basis,
		belt_a.global_position
		+ belt_a.global_transform.basis * Vector3.FORWARD
	)

	belt_c.global_transform = Transform3D(
		belt_b.global_transform.basis,
		belt_b.global_position
		+ belt_b.global_transform.basis * Vector3.FORWARD
	)

	# =============================================================================
	# ALIGN SMELTER INPUT TO LAST CONVEYOR OUTPUT
	# =============================================================================

	# Rotate the Smelter so its input faces the
	# conveyor's output direction.

	smelter.rotation_degrees.y = 90.0

	var last_output := belt_c.get_node(
		"OutputEndpoint"
	) as Marker3D

	# Calculate building origin from its input port.
	# This avoids relying on a manually guessed offset.

	smelter.global_position = (
		last_output.global_position
		- smelter.global_transform.basis * smelter_port.position
	)

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			last_output,
			smelter_port,
			ConveyorSegment.CONNECTION_GAP
		)
	)

	# =============================================================================
	# TEST B — ESTABLISH ALL PHYSICAL CONNECTIONS
	# =============================================================================

	assert(belt_a.try_connect_building_port(extractor_port))
	assert(belt_a.try_connect_to(belt_b))
	assert(belt_b.try_connect_to(belt_c))
	assert(belt_c.try_connect_building_port(smelter_port))

	assert(extractor_port.connected_conveyor == belt_a)
	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)
	assert(belt_b.next_segment == belt_c)
	assert(belt_c.previous_segment == belt_b)
	assert(smelter_port.connected_conveyor == belt_c)

	print("PASS B: Extractor-to-Smelter physical route connected")

	# =============================================================================
	# TEST C — PREPARE EXTRACTOR INVENTORY
	# =============================================================================

	# Seed two ore into the real Extractor inventory.
	# Mining from a deposit will be tested separately.

	assert(extractor_inventory.add_item(ore, 2) == 2)

	assert(extractor_port.can_provide_item(ore, 2))
	assert(smelter_port.can_accept_item(ore, 1))

	print("PASS C: Extractor contains two available ore")

	# =============================================================================
	# TEST D — AUTOMATICALLY LOAD FIRST ORE
	# =============================================================================

	timer_a._process(0.01)

	assert(extractor_inventory.get_amount(ore) == 1)
	assert(transport_a.get_held_item() == ore)
	assert(timer_a.elapsed_seconds == 0.0)

	# Confirm the item is represented visually.

	visual_a.refresh_visual()

	assert(visual_a.visible)
	assert(visual_a.displayed_item == ore)

	print("PASS D: First ore automatically loaded and displayed")

	# =============================================================================
	# TEST E — FIRST ORE TRAVELS THROUGH NETWORK
	# =============================================================================

	# First, confirm the item must complete travel time.

	timer_a._process(0.4)

	assert(transport_a.get_held_item() == ore)
	assert(transport_b.get_held_item() == null)

	# Complete Belt A's travel interval.

	timer_a._process(0.61)

	assert(transport_a.get_held_item() == null)
	assert(transport_b.get_held_item() == ore)

	# Continue through Belt B.

	timer_b._process(1.0)

	assert(transport_b.get_held_item() == null)
	assert(transport_c.get_held_item() == ore)

	# Deliver from Belt C into the Smelter.

	timer_c._process(1.0)

	assert(transport_c.get_held_item() == null)
	assert(smelter_input.get_amount(ore) == 1)

	visual_a.refresh_visual()
	assert(not visual_a.visible)

	print("PASS E: First ore delivered across three belts")

	# =============================================================================
	# TEST F — PRODUCTION WAITS FOR SECOND ORE
	# =============================================================================

	# The test recipe requires two ore for one ingot.

	assert(not producer.has_required_inputs())

	producer._process(2.0)

	assert(smelter_input.get_amount(ore) == 1)
	assert(smelter_output.get_amount(ingot) == 0)
	assert(producer.production_progress == 0.0)

	print("PASS F: Smelter waits for required ingredients")

	# =============================================================================
	# TEST G — AUTOMATICALLY DELIVER SECOND ORE
	# =============================================================================

	timer_a._process(0.01)

	assert(transport_a.get_held_item() == ore)
	assert(extractor_inventory.get_amount(ore) == 0)

	timer_a._process(1.0)

	assert(transport_b.get_held_item() == ore)

	timer_b._process(1.0)

	assert(transport_c.get_held_item() == ore)

	timer_c._process(1.0)

	assert(smelter_input.get_amount(ore) == 2)
	assert(producer.has_required_inputs())

	print("PASS G: Second ore delivered automatically")

	# =============================================================================
	# TEST H — COMPLETE MANUFACTURING CYCLE
	# =============================================================================

	# Advance the real ProducerComponent.
	# The recipe requires 2 seconds for one ingot.

	producer._process(1.0)

	assert(smelter_output.get_amount(ingot) == 0)
	assert(smelter_input.get_amount(ore) == 2)

	producer._process(1.01)

	assert(smelter_input.get_amount(ore) == 0)
	assert(smelter_output.get_amount(ingot) == 1)

	print("PASS H: Two transported ore manufactured into one ingot")

	# =============================================================================
	# TEST I — FINAL RESOURCE ACCOUNTING
	# =============================================================================

	# Check the quantities at every transport stage.

	var remaining_ore: int = (
		extractor_inventory.get_amount(ore)
		+ transport_a.cargo_inventory.get_amount(ore)
		+ transport_b.cargo_inventory.get_amount(ore)
		+ transport_c.cargo_inventory.get_amount(ore)
		+ smelter_input.get_amount(ore)
	)

	var finished_ingots: int = (
		smelter_output.get_amount(ingot)
	)

	# This particular recipe consumes 2 ore per ingot.
	# Convert products back to ore-equivalent units
	# for the final manufacturing accounting check.

	assert(remaining_ore + finished_ingots * 2 == 2)

	assert(extractor_inventory.get_total_amount() == 0)
	assert(transport_a.get_held_item() == null)
	assert(transport_b.get_held_item() == null)
	assert(transport_c.get_held_item() == null)

	print("PASS I: Physical transport and manufacturing conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 9 PHYSICAL FACTORY TESTS PASSED")
	print("==========================================")
