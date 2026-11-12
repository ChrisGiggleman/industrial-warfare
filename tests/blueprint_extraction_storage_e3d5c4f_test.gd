extends Node3D

# =============================================================================
# E3D5C4F — FINITE DEPOSIT -> REAL EXTRACTOR -> BELT -> STORAGE (TEST ONLY)
# =============================================================================
# No ore is inserted into any inventory. A real finite TestOreDeposit is
# detected by the real TestExtractor's Area3D and mined using _process().
# The existing connected ConveyorSegment and timer deliver ore to an actual
# TestStorage input port. No construction authorizations, power or workers.
#
# Extraction and cargo timer processing are manually stepped to avoid
# incidental frame timing, but real production methods are used unchanged.


func _ready() -> void:
	call_deferred("_run_checks")


func _move_one_ore(
	extractor_component: ExtractorComponent,
	extractor_inventory: InventoryComponent,
	belt: ConveyorSegment,
	storage_inventory: InventoryComponent,
	ore: ItemDefinition
) -> void:
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	var before: int = storage_inventory.get_amount(ore)
	extractor_component._process(1.0)
	assert(extractor_inventory.get_amount(ore) == 1)
	timer._process(0.01)
	assert(transport.get_held_item() == ore)
	assert(extractor_inventory.get_amount(ore) == 0)
	assert(timer.elapsed_seconds == 0.0)
	assert(timer.advance_transport(1.0))
	assert(storage_inventory.get_amount(ore) == before + 1)
	assert(transport.get_held_item() == null)


func _run_checks() -> void:
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var extractor_scene := load(
		"res://scenes/buildings/test_extractor.tscn"
	) as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene
	var deposit_scene := load(
		"res://scenes/resource_nodes/TestOreDeposit.tscn"
	) as PackedScene
	assert(ore != null and extractor_scene != null)
	assert(storage_scene != null and belt_scene != null)
	assert(deposit_scene != null)

	var extractor := extractor_scene.instantiate() as Node3D
	var storage := storage_scene.instantiate() as Node3D
	var belt := belt_scene.instantiate() as ConveyorSegment
	assert(extractor != null and storage != null and belt != null)
	add_child(extractor)
	add_child(storage)
	add_child(belt)

	var extraction := extractor.get_node(
		"ExtractorComponent"
	) as ExtractorComponent
	var logistics := extractor.get_node(
		"LogisticsTransferComponent"
	) as LogisticsTransferComponent
	var source := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent
	var output_port := extractor.get_node("OutputPort") as ItemPortComponent
	var destination := storage.get_node(
		"InventoryComponent"
	) as InventoryComponent
	var input_port := storage.get_node("InputPort") as ItemPortComponent
	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	assert(extraction != null and logistics != null and source != null)
	assert(output_port != null and destination != null and input_port != null)
	assert(timer != null and transport != null)

	extraction.set_process(false)
	logistics.set_process(false)
	timer.set_process(false)
	timer.travel_interval = 1.0
	destination.max_capacity = 3

	assert(source.get_amount(ore) == 0)
	assert(destination.get_amount(ore) == 0)
	assert(extraction.resource_node == null)
	extraction._process(1.0)
	assert(source.get_amount(ore) == 0)
	assert(extraction.extraction_status == "No Resource In Range")
	print("PASS A: Real Extractor has zero ore and cannot mine without a deposit")

	var deposit := deposit_scene.instantiate() as Node3D
	assert(deposit != null)
	deposit.global_position = extractor.global_position
	add_child(deposit)
	var runtime := deposit.get_node(
		"ResourceNodeRuntime"
	) as ResourceNodeRuntime
	assert(runtime != null and runtime.definition != null)
	assert(runtime.definition.resource_item == ore)
	assert(not runtime.definition.infinite_resource)
	assert(runtime.remaining_amount == 500)
	# Physics overlap must be observed by the real extractor area.
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	extraction._scan_for_resource_node()
	assert(extraction.resource_node == runtime)
	print("PASS B: Extractor physics discovers the real finite TestOreDeposit")

	extraction._process(0.5)
	assert(source.get_amount(ore) == 0)
	assert(runtime.remaining_amount == 500)
	extraction._process(0.5)
	assert(source.get_amount(ore) == 1)
	assert(runtime.remaining_amount == 499)
	assert(source.get_amount(ore) + runtime.remaining_amount == 500)
	print("PASS C: Timed extraction mines exactly one ore from the finite deposit")

	assert(output_port.direction == ItemPortComponent.PortDirection.OUTPUT)
	assert(output_port.inventory == source)
	assert(input_port.direction == ItemPortComponent.PortDirection.INPUT)
	assert(input_port.inventory == destination)
	assert(not input_port.can_accept_item(null))
	var snapped := ConveyorBuildingSnap.get_preview_transform(output_port, belt)
	assert(snapped.has("transform"))
	belt.global_transform = snapped["transform"]
	assert(belt.try_connect_building_port(output_port))
	assert(belt.input_building_port == output_port)
	assert(output_port.connected_conveyor == belt)
	print("PASS D: Real Extractor OUTPUT connects to physically aligned belt INPUT")

	var endpoint := belt.get_node("OutputEndpoint") as Marker3D
	var storage_basis := belt.global_transform.basis.orthonormalized()
	storage.global_transform = Transform3D(
		storage_basis,
		endpoint.global_position - storage_basis * input_port.position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		endpoint, input_port, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(input_port))
	assert(belt.output_building_port == input_port)
	assert(input_port.connected_conveyor == belt)
	assert(destination.max_capacity == 3)
	print("PASS E: Real Storage INPUT connects reciprocally to belt OUTPUT")

	timer._process(0.01)
	assert(transport.get_held_item() == ore)
	assert(source.get_amount(ore) == 0)
	assert(runtime.remaining_amount == 499)
	assert(timer.elapsed_seconds == 0.0)
	assert(destination.get_amount(ore) == 0)
	print("PASS F: Real extracted ore loads onto the connected cargo buffer")

	assert(not timer.advance_transport(0.4))
	assert(destination.get_amount(ore) == 0)
	assert(transport.get_held_item() == ore)
	assert(timer.advance_transport(0.61))
	assert(destination.get_amount(ore) == 1)
	assert(transport.get_held_item() == null)
	assert(timer.successful_transfers == 1)
	print("PASS G: Ore only reaches real Storage after full belt travel time")

	_move_one_ore(extraction, source, belt, destination, ore)
	_move_one_ore(extraction, source, belt, destination, ore)
	assert(destination.get_amount(ore) == 3)
	assert(source.get_amount(ore) == 0)
	assert(runtime.remaining_amount == 497)
	assert(timer.successful_transfers == 3)
	print("PASS H: Three mined ore are delivered, filling bounded Storage")

	extraction._process(1.0)
	assert(source.get_amount(ore) == 1)
	assert(runtime.remaining_amount == 496)
	timer._process(0.01)
	assert(transport.get_held_item() == ore)
	assert(not timer.advance_transport(1.0))
	assert(timer.transport_status == "Blocked")
	assert(destination.get_amount(ore) == 3)
	assert(transport.cargo_inventory.get_amount(ore) == 1)
	print("PASS I: Full destination backpressure retains fourth mined ore on belt")

	assert(belt.disconnect_building_port(input_port))
	assert(input_port.connected_conveyor == null)
	assert(not timer.advance_transport(0.01))
	assert(transport.get_held_item() == ore)
	assert(destination.get_amount(ore) == 3)
	print("PASS J: Physically disconnected storage cannot receive held cargo")

	var drained := InventoryComponent.new()
	drained.name = "TestDrainForBackpressure"
	drained.max_capacity = 3
	add_child(drained)
	assert(destination.transfer_to(drained, ore, 1) == 1)
	assert(destination.get_amount(ore) == 2)
	assert(drained.get_amount(ore) == 1)
	assert(not timer.advance_transport(0.01))
	assert(transport.get_held_item() == ore)
	print("PASS K: Freeing storage space cannot bypass a disconnected input")

	assert(belt.try_connect_building_port(input_port))
	assert(timer.advance_transport(0.01))
	assert(destination.get_amount(ore) == 3)
	assert(transport.get_held_item() == null)
	assert(source.get_amount(ore) == 0)
	assert(runtime.remaining_amount == 496)
	assert(timer.successful_transfers == 4)
	assert(
		runtime.remaining_amount + source.get_amount(ore)
		+ transport.cargo_inventory.get_amount(ore)
		+ destination.get_amount(ore) + drained.get_amount(ore) == 500
	)
	assert(destination.get_amount(ore) + drained.get_amount(ore) == 4)
	print("PASS L: Reconnection delivers fourth mined ore; deposit and cargo conserved")

	print("ALL 12 E3D5C4F FINITE EXTRACTION AND STORAGE LOGISTICS TESTS PASSED")
	print("TEST ONLY: No full smelter-to-staging link, delivered power, workers or save/load.")
