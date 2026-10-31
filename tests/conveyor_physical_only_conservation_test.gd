extends Node

# =============================================================================
# PHYSICAL-ONLY FACTORY CONSERVATION REGRESSION
# =============================================================================

# Tests real finite-deposit extraction, three player-style physical
# conveyor links, two warehouses and one smelter. Old proximity
# transfer components stay disabled. All machine and belt timers
# are advanced explicitly so item accounting is deterministic.

func _make_belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var visual := belt.get_node_or_null("CargoVisual") as ConveyorCargoVisual
	if visual != null:
		visual.set_process(false)
	return belt


func _attach_building_output(
	port: ItemPortComponent,
	belt: ConveyorSegment
) -> void:
	var preview: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))


# =============================================================================
# ALIGN A REAL BUILDING INPUT TO A FREE BELT OUTPUT
# =============================================================================

func _attach_building_input(
	building: Node3D,
	port: ItemPortComponent,
	belt: ConveyorSegment
) -> void:
	var endpoint := belt.get_node("OutputEndpoint") as Marker3D
	assert(endpoint != null)
	var source_forward: Vector3 = (
		endpoint.global_transform.basis * Vector3.FORWARD
	).normalized()
	var compatible: bool = false

	for quarter_turn: int in range(4):
		building.rotation_degrees.y = float(quarter_turn * 90)
		var port_forward: Vector3 = (
			port.global_transform.basis * Vector3.FORWARD
		).normalized()
		if source_forward.dot(port_forward) > -0.98:
			continue
		building.global_position = (
			endpoint.global_position
			- building.global_transform.basis * port.position
		)
		if LogisticsConnectionGeometry.are_endpoints_aligned(
			endpoint, port, ConveyorSegment.CONNECTION_GAP
		):
			compatible = true
			break

	assert(compatible)
	assert(belt.try_connect_building_port(port))


# =============================================================================
# ORE-EQUIVALENT CONSERVATION
# =============================================================================

func _total_ore_equivalent(
	deposit: ResourceNodeRuntime,
	inventories: Array[InventoryComponent],
	ore: ItemDefinition,
	ingot: ItemDefinition
) -> int:
	var total: int = deposit.remaining_amount
	for inventory: InventoryComponent in inventories:
		total += inventory.get_amount(ore)
		total += inventory.get_amount(ingot) * 2
	return total


func _send_one(
	belt: ConveyorSegment,
	expected_item: ItemDefinition
) -> void:
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var cargo := belt.get_node("CargoInventory") as InventoryComponent
	assert(timer != null and cargo != null)
	timer._process(0.01)
	assert(cargo.get_amount(expected_item) == 1)
	timer._process(1.01)
	assert(cargo.get_amount(expected_item) == 0)


# =============================================================================
# RUN THE PHYSICAL-ONLY PRODUCTION CHECK
# =============================================================================

func _ready() -> void:
	print("\n===== PHYSICAL-ONLY FACTORY CONSERVATION =====")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var deposit_scene := load(
		"res://scenes/resource_nodes/TestOreDeposit.tscn"
	) as PackedScene
	var extractor_scene := load(
		"res://scenes/buildings/test_extractor.tscn"
	) as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var smelter_scene := load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene
	assert(
		ore != null and ingot != null and deposit_scene != null
		and extractor_scene != null and storage_scene != null
		and smelter_scene != null
	)

	var root := Node3D.new()
	add_child(root)
	var deposit := deposit_scene.instantiate() as Node3D
	var extractor := extractor_scene.instantiate() as Node3D
	var warehouse_a := storage_scene.instantiate() as Node3D
	var smelter := smelter_scene.instantiate() as Node3D
	var warehouse_b := storage_scene.instantiate() as Node3D
	for building: Node3D in [
		deposit, extractor, warehouse_a, smelter, warehouse_b
	]:
		assert(building != null)
		root.add_child(building)

	warehouse_a.global_position = Vector3(20, 0, 0)
	smelter.global_position = Vector3(40, 0, 0)
	warehouse_b.global_position = Vector3(60, 0, 0)

	var deposit_runtime := deposit.get_node("ResourceNodeRuntime") as ResourceNodeRuntime
	var extractor_component := extractor.get_node("ExtractorComponent") as ExtractorComponent
	var legacy_out := (
		extractor.get_node("LogisticsTransferComponent") as LogisticsTransferComponent
	)
	var legacy_in := (
		smelter.get_node("LogisticsInputComponent") as LogisticsInputComponent
	)
	var producer := smelter.get_node("ProducerComponent") as ProducerComponent
	assert(deposit_runtime != null and extractor_component != null)
	assert(legacy_out != null and legacy_in != null and producer != null)

	legacy_out.set_process(false)
	legacy_in.set_process(false)
	extractor_component.set_process(false)
	producer.set_process(false)

	var extract_inventory := (
		extractor.get_node("InventoryComponent") as InventoryComponent
	)
	var storage_a := (
		warehouse_a.get_node("InventoryComponent") as InventoryComponent
	)
	var smelter_input := (
		smelter.get_node("InputInventory") as InventoryComponent
	)
	var smelter_output := (
		smelter.get_node("OutputInventory") as InventoryComponent
	)
	var storage_b := (
		warehouse_b.get_node("InventoryComponent") as InventoryComponent
	)

	var belt_a := _make_belt(root)
	var belt_b := _make_belt(root)
	var belt_c := _make_belt(root)
	var all_inventories: Array[InventoryComponent] = [
		extract_inventory, storage_a, smelter_input,
		smelter_output, storage_b,
		belt_a.get_node("CargoInventory") as InventoryComponent,
		belt_b.get_node("CargoInventory") as InventoryComponent,
		belt_c.get_node("CargoInventory") as InventoryComponent
	]

	# Let the existing deferred deposit scan complete, then explicitly
	# assign the real finite deposit runtime used by this isolated test.
	await get_tree().physics_frame
	await get_tree().physics_frame
	extractor_component.resource_node = deposit_runtime
	assert(deposit_runtime.remaining_amount == 500)
	assert(not legacy_out.is_processing())
	assert(not legacy_in.is_processing())
	assert(_total_ore_equivalent(
		deposit_runtime, all_inventories, ore, ingot
	) == 500)
	print("PASS A: Finite deposit has 500 ore and legacy transfers are disabled")

	# =============================================================================
	# CONSTRUCT PHYSICAL ROUTE
	# =============================================================================

	_attach_building_output(
		extractor.get_node("OutputPort") as ItemPortComponent, belt_a
	)
	_attach_building_input(
		warehouse_a,
		warehouse_a.get_node("InputPort") as ItemPortComponent,
		belt_a
	)
	_attach_building_output(
		warehouse_a.get_node("OutputPort") as ItemPortComponent, belt_b
	)
	_attach_building_input(
		smelter,
		smelter.get_node("InputPort") as ItemPortComponent,
		belt_b
	)
	_attach_building_output(
		smelter.get_node("OutputPort") as ItemPortComponent, belt_c
	)
	_attach_building_input(
		warehouse_b,
		warehouse_b.get_node("InputPort") as ItemPortComponent,
		belt_c
	)
	print("PASS B: Extractor -> Storage -> Smelter -> Storage physically linked")

	# =============================================================================
	# MINE AND DELIVER TWO ORE
	# =============================================================================

	extractor_component._process(1.0)
	extractor_component._process(1.0)
	assert(deposit_runtime.remaining_amount == 498)
	assert(extract_inventory.get_amount(ore) == 2)
	assert(_total_ore_equivalent(
		deposit_runtime, all_inventories, ore, ingot
	) == 500)
	print("PASS C: Two ore extracted from real finite deposit without loss")

	_send_one(belt_a, ore)
	assert(storage_a.get_amount(ore) == 1)
	assert(_total_ore_equivalent(
		deposit_runtime, all_inventories, ore, ingot
	) == 500)
	print("PASS D: First ore delivered through physical warehouse input")

	_send_one(belt_b, ore)
	assert(smelter_input.get_amount(ore) == 1)
	assert(not producer.has_required_inputs())
	assert(_total_ore_equivalent(
		deposit_runtime, all_inventories, ore, ingot
	) == 500)
	print("PASS E: Warehouse physically feeds recipe-controlled smelter")

	_send_one(belt_a, ore)
	_send_one(belt_b, ore)
	assert(extract_inventory.get_amount(ore) == 0)
	assert(storage_a.get_amount(ore) == 0)
	assert(smelter_input.get_amount(ore) == 2)
	print("PASS F: Second ore delivered; no proximity bypass needed")

	# =============================================================================
	# MANUFACTURE AND EXPORT INGOT
	# =============================================================================

	producer._process(2.01)
	assert(smelter_input.get_amount(ore) == 0)
	assert(smelter_output.get_amount(ingot) == 1)
	assert(_total_ore_equivalent(
		deposit_runtime, all_inventories, ore, ingot
	) == 500)
	print("PASS G: Two ore manufactured into one ingot, accounting preserved")

	_send_one(belt_c, ingot)
	assert(smelter_output.get_amount(ingot) == 0)
	assert(storage_b.get_amount(ingot) == 1)
	assert(_total_ore_equivalent(
		deposit_runtime, all_inventories, ore, ingot
	) == 500)
	print("PASS H: Manufactured ingot exported physically to final warehouse")

	assert(not legacy_out.is_processing() and not legacy_in.is_processing())
	assert(storage_a.get_total_amount() == 0)
	assert(extract_inventory.get_total_amount() == 0)
	assert(smelter_input.get_total_amount() == 0)
	assert(smelter_output.get_total_amount() == 0)
	assert(storage_b.get_amount(ingot) == 1)
	assert(deposit_runtime.remaining_amount + storage_b.get_amount(ingot) * 2 == 500)
	print("PASS I: Final physical-only conservation: 498 ore + 1 ingot = 500 ore equivalents")

	root.queue_free()
	print("=====================================================")
	print("ALL 9 PHYSICAL-ONLY CONSERVATION TESTS PASSED")
	print("=====================================================")
