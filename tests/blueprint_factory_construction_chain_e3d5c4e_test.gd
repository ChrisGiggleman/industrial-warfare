extends Node3D

# =============================================================================
# E3D5C4E — REAL SMELTER RECIPE -> CONNECTED CONVEYORS -> STAGING
# =============================================================================
# Test-only fixture. Real Storage, Smelter, bill-filtered input and three
# connected ConveyorSegments are used. Initial Test Ore is explicitly seeded
# into real Storage; ingots come ONLY from the actual Smelter recipe.
# No power generator, construction worker, production scene adapter or
# automatic construction timer advancement is installed.


func _ready() -> void:
	call_deferred("_run_checks")


func _make_belt() -> ConveyorSegment:
	var packed := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene
	assert(packed != null)
	var belt := packed.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	return belt


func _transport(belt: ConveyorSegment) -> ConveyorTransportComponent:
	return belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent


func _timer(belt: ConveyorSegment) -> ConveyorTransportTimer:
	return belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer


func _deliver_ore(
	belt: ConveyorSegment,
	inventory: InventoryComponent,
	source: InventoryComponent,
	ore: ItemDefinition
) -> void:
	var transport := _transport(belt)
	var timer := _timer(belt)
	var before: int = inventory.get_amount(ore)
	timer._process(0.01)
	assert(transport.get_held_item() == ore)
	assert(timer.elapsed_seconds == 0.0)
	assert(timer.advance_transport(1.0))
	assert(inventory.get_amount(ore) == before + 1)
	assert(transport.get_held_item() == null)
	assert(source.get_amount(ore) >= 0)


func _deliver_ingot(
	first: ConveyorSegment,
	second: ConveyorSegment,
	staged: InventoryComponent,
	ingot: ItemDefinition
) -> void:
	var first_timer := _timer(first)
	var second_timer := _timer(second)
	var before: int = staged.get_amount(ingot)
	first_timer._process(0.01)
	assert(_transport(first).get_held_item() == ingot)
	assert(not first_timer.advance_transport(0.4))
	assert(_transport(second).get_held_item() == null)
	assert(first_timer.advance_transport(0.61))
	assert(_transport(first).get_held_item() == null)
	assert(_transport(second).get_held_item() == ingot)
	assert(not second_timer.advance_transport(0.4))
	assert(staged.get_amount(ingot) == before)
	assert(second_timer.advance_transport(0.61))
	assert(_transport(second).get_held_item() == null)
	assert(staged.get_amount(ingot) == before + 1)


func _run_checks() -> void:
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(ore != null and ingot != null and definition != null)
	var smelt_scene := load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	assert(smelt_scene != null and storage_scene != null)

	var smelter := smelt_scene.instantiate() as Node3D
	var storage := storage_scene.instantiate() as Node3D
	assert(smelter != null and storage != null)
	add_child(smelter)
	add_child(storage)
	var producer := smelter.get_node("ProducerComponent") as ProducerComponent
	var smelt_input := smelter.get_node("InputInventory") as InventoryComponent
	var smelt_output := smelter.get_node("OutputInventory") as InventoryComponent
	var smelt_input_port := smelter.get_node("InputPort") as ItemPortComponent
	var smelt_output_port := smelter.get_node("OutputPort") as ItemPortComponent
	var storage_inventory := storage.get_node("InventoryComponent") as InventoryComponent
	var storage_output_port := storage.get_node("OutputPort") as ItemPortComponent
	var logistics := smelter.get_node("LogisticsInputComponent") as LogisticsInputComponent
	assert(producer != null and logistics != null)
	assert(smelt_input != null and smelt_output != null)
	assert(smelt_input_port != null and smelt_output_port != null)
	assert(storage_inventory != null and storage_output_port != null)
	producer.set_process(false)
	logistics.set_process(false)
	assert(producer.recipe.production_time == 2.0)
	assert(producer.recipe.inputs.size() == 1)
	assert(producer.recipe.outputs.size() == 1)
	assert(producer.recipe.inputs[0].item == ore)
	assert(producer.recipe.inputs[0].amount == 2)
	assert(producer.recipe.outputs[0].item == ingot)
	assert(producer.recipe.outputs[0].amount == 1)
	assert(smelt_output.get_amount(ingot) == 0)
	print("PASS A: Actual TestStorage and TestSmelter have the 2-ore-to-1-ingot recipe")

	# Place the ore belt against the actual Smelter input first.
	var ore_belt := _make_belt()
	var ore_snap := ConveyorBuildingSnap.get_preview_transform(
		smelt_input_port, ore_belt
	)
	assert(ore_snap.has("transform"))
	ore_belt.global_transform = ore_snap["transform"]
	assert(ore_belt.try_connect_building_port(smelt_input_port))
	assert(ore_belt.output_building_port == smelt_input_port)
	assert(smelt_input_port.connected_conveyor == ore_belt)
	print("PASS B: Real Smelter recipe INPUT has a reciprocal aligned ore belt")

	# Attach real Storage OUTPUT to the other end, using shared endpoint math.
	var input_marker := ore_belt.get_node("InputEndpoint") as Marker3D
	var facing: Basis = ore_belt.global_transform.basis.orthonormalized()
	storage.global_transform = Transform3D(
		facing,
		input_marker.global_position - facing * storage_output_port.position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		storage_output_port, input_marker, ConveyorSegment.CONNECTION_GAP
	))
	assert(ore_belt.try_connect_building_port(storage_output_port))
	assert(ore_belt.input_building_port == storage_output_port)
	assert(storage_output_port.connected_conveyor == ore_belt)
	print("PASS C: Real Storage OUTPUT connects physically to the ore conveyor INPUT")

	var staged_supply := BlueprintConstructionMaterialStaging.new()
	staged_supply.enable_isolated_staging = true
	add_child(staged_supply)
	assert(staged_supply.configure(storage_inventory, definition, 3))
	var buffer := staged_supply.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)
	var receiver := Node3D.new()
	receiver.name = "IsolatedConstructionReceiver"
	add_child(receiver)
	var port := BlueprintConstructionStagingInputPort.new()
	port.name = "InputPort"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver.add_child(port)
	assert(port.bind_staging(staged_supply))
	assert(port.can_accept_item(ingot))
	assert(not port.can_accept_item(ore))
	print("PASS D: Separate staging port accepts only required ingots, never ore")

	var output_a := _make_belt()
	var output_b := _make_belt()
	var output_snap := ConveyorBuildingSnap.get_preview_transform(
		smelt_output_port, output_a
	)
	assert(output_snap.has("transform"))
	output_a.global_transform = output_snap["transform"]
	assert(output_a.try_connect_building_port(smelt_output_port))
	assert(output_b.snap_after(output_a))
	assert(output_a.next_segment == output_b)
	assert(output_b.previous_segment == output_a)
	var endpoint := output_b.get_node("OutputEndpoint") as Marker3D
	receiver.global_transform = Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		endpoint, port, ConveyorSegment.CONNECTION_GAP
	))
	assert(output_b.try_connect_building_port(port))
	assert(output_b.output_building_port == port)
	assert(port.connected_conveyor == output_b)
	print("PASS E: Smelter OUTPUT -> two reciprocal belts -> construction INPUT")

	# Fail closed before stock arrives; do not fabricate factory output.
	producer._process(10.0)
	_timer(ore_belt)._process(0.01)
	_timer(output_a)._process(0.01)
	assert(smelt_input.get_total_amount() == 0)
	assert(smelt_output.get_total_amount() == 0)
	assert(buffer.get_total_amount() == 0)
	assert(_transport(output_a).get_held_item() == null)
	print("PASS F: Empty factory cannot produce or deliver a phantom ingot")

	assert(storage_inventory.add_item(ore, 8) == 8)
	assert(storage_inventory.get_amount(ingot) == 0)
	assert(staged_supply.receive_item(ore, 1) == 0)
	assert(buffer.get_total_amount() == 0)
	print("PASS G: Only eight fixture ore units enter real Storage; no ingots spawned")

	_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
	assert(smelt_input.get_amount(ore) == 1)
	producer._process(10.0)
	assert(smelt_output.get_amount(ingot) == 0)
	assert(producer.production_status == "Waiting for Inputs")
	_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
	assert(smelt_input.get_amount(ore) == 2)
	print("PASS H: Ore must traverse the actual source belt before Smelter may run")

	producer._process(1.0)
	assert(smelt_output.get_amount(ingot) == 0)
	producer._process(1.0)
	assert(smelt_input.get_amount(ore) == 0)
	assert(smelt_output.get_amount(ingot) == 1)
	assert(storage_inventory.get_amount(ore) == 6)
	print("PASS I: Two physically delivered ore become one ingot after real recipe time")

	_deliver_ingot(output_a, output_b, buffer, ingot)
	assert(smelt_output.get_amount(ingot) == 0)
	assert(buffer.get_amount(ingot) == 1)
	assert(_timer(output_a).successful_transfers == 1)
	assert(_timer(output_b).successful_transfers == 1)
	print("PASS J: Manufactured ingot travels both timed belts into bill-filtered staging")

	for cycle: int in range(2):
		_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
		_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
		assert(smelt_input.get_amount(ore) == 2)
		producer._process(2.0)
		assert(smelt_output.get_amount(ingot) == 1)
		_deliver_ingot(output_a, output_b, buffer, ingot)
	assert(buffer.get_amount(ingot) == 3)
	assert(storage_inventory.get_amount(ore) == 2)
	assert(smelt_input.get_amount(ore) == 0)
	assert(smelt_output.get_total_amount() == 0)
	assert(not port.can_accept_item(ingot))
	print("PASS K: Three recipe-produced ingots fill bounded staging; six ore consumed")

	_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
	_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
	producer._process(2.0)
	assert(storage_inventory.get_amount(ore) == 0)
	assert(smelt_output.get_amount(ingot) == 1)
	_timer(output_a)._process(0.01)
	assert(_transport(output_a).get_held_item() == ingot)
	assert(_timer(output_a).advance_transport(1.0))
	assert(_transport(output_b).get_held_item() == ingot)
	assert(not _timer(output_b).advance_transport(1.0))
	assert(_timer(output_b).transport_status == "Blocked")
	assert(buffer.get_amount(ingot) == 3)
	print("PASS L: Fourth real ingot remains on last belt while staging is full")

	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	for service: Node in [queue, scheduler, escrow, network, power, coordinator]:
		add_child(service)
	assert(power.configure(network))
	assert(coordinator.configure(queue, scheduler, escrow, power, buffer, 1))
	assert(site.job.authorize())
	assert(coordinator.track_site(site, 7))
	assert(coordinator.reconcile() == 0)
	var hold: int = escrow.reservation_for(site)
	assert(hold > 0)
	assert(int(escrow.held_materials(hold).get(ingot, 0)) == 3)
	assert(buffer.get_total_amount() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	# The full bill is reserved, so materials are ready. Only actual power
	# delivery and worker capacity remain unavailable; neither is invented.
	var wait_reasons: Array[StringName] = site.job.get_wait_reasons()
	assert(wait_reasons.size() == 2)
	assert(wait_reasons.has(&"power"))
	assert(wait_reasons.has(&"workers"))
	assert(not wait_reasons.has(&"materials"))
	assert(scheduler.get_active_count() == 0)
	assert(site.job.get_progress() == 0.0)
	print("PASS M: Real escrow clears materials wait; missing power/workers keep QUEUED")

	var original: Transform3D = output_b.global_transform
	output_b.position.x += 1.0
	assert(not _timer(output_b).advance_transport(0.01))
	assert(_transport(output_b).get_held_item() == ingot)
	assert(buffer.get_total_amount() == 0)
	output_b.global_transform = original
	assert(_timer(output_b).advance_transport(0.01))
	assert(_transport(output_b).get_held_item() == null)
	assert(buffer.get_amount(ingot) == 1)
	print("PASS N: Misalignment holds fourth ingot; realignment completes delivery")

	assert(storage_inventory.get_amount(ore) == 0)
	assert(smelt_input.get_amount(ore) == 0)
	assert(smelt_output.get_amount(ingot) == 0)
	assert(_transport(ore_belt).get_held_item() == null)
	assert(_transport(output_a).get_held_item() == null)
	assert(_transport(output_b).get_held_item() == null)
	assert(
		int(escrow.held_materials(hold).get(ingot, 0))
		+ buffer.get_amount(ingot) == 4
	)
	assert(_timer(output_a).successful_transfers == 4)
	assert(_timer(output_b).successful_transfers == 4)
	print("PASS O: Eight ore become exactly four ingots with no residual cargo")

	assert(site.job.cancel())
	# The staging buffer holds one item (capacity three); it cannot refund
	# a full three-ingot bill. The escrow must survive for safe recovery.
	assert(escrow.has_reservation(hold))
	assert(escrow.needs_recovery(hold))
	assert(buffer.get_amount(ingot) == 1)
	assert(escrow.recover_to(hold, storage_inventory))
	assert(not escrow.has_reservation(hold))
	assert(storage_inventory.get_amount(ingot) == 3)
	assert(not escrow.recover_to(hold))
	assert(site.job.get_progress() == 0.0)
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	assert(sandbox.get_node_or_null("BlueprintConstructionStagingInputPort") == null)
	assert(main.get_node_or_null("BlueprintConstructionStagingInputPort") == null)
	main.free()
	sandbox.free()
	print("PASS P: Cancellation recovers bill once; playable scenes still opted out")

	print("ALL 16 E3D5C4E FACTORY-TO-CONSTRUCTION LOGISTICS TESTS PASSED")
	print("TEST ONLY: Seeded ore, no real extractor link, delivered power, workers or save/load.")
