extends Node3D

# =============================================================================
# E3D5C4T — MINED ORE -> REAL BELTS -> OWNED SITE -> TIMED BUILD
# =============================================================================
# Isolated merger of the previously verified E3d5c4g mined-ore chain and
# E3d5c4s exclusive site-owned readiness. Four physically connected belts
# move eight real mined ore into four smelted ingots. Three ingots fund the
# actual job; the fourth remains in held cargo for explicit recovery.
# Never seed factory inventory. A separate prototype nameplate generator and
# synthetic finite worker slot are fixture-only, NOT playable-world services.
# The ConstructionSite timer is advanced only by explicit test calls.
# Main and Factory Testing Sandbox remain unchanged.


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


func _mine_one_to_storage(
	extraction: ExtractorComponent,
	mined_inventory: InventoryComponent,
	belt: ConveyorSegment,
	storage_inventory: InventoryComponent,
	resource_runtime: ResourceNodeRuntime,
	ore: ItemDefinition
) -> void:
	var before_ore: int = storage_inventory.get_amount(ore)
	var before_deposit: int = resource_runtime.remaining_amount
	assert(mined_inventory.get_amount(ore) == 0)
	extraction._process(1.0)
	assert(mined_inventory.get_amount(ore) == 1)
	assert(resource_runtime.remaining_amount == before_deposit - 1)
	var timer: ConveyorTransportTimer = _timer(belt)
	timer._process(0.01)
	assert(_transport(belt).get_held_item() == ore)
	assert(mined_inventory.get_amount(ore) == 0)
	assert(timer.elapsed_seconds == 0.0)
	assert(timer.advance_transport(1.0))
	assert(storage_inventory.get_amount(ore) == before_ore + 1)
	assert(_transport(belt).get_held_item() == null)


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


func _structure(path: String, at: Vector3) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var structure := packed.instantiate() as PrototypePowerStructure
	assert(structure != null)
	add_child(structure)
	structure.global_position = at
	return structure


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

	# New combined-source leg: existing Extractor OUTPUT -> real conveyor
	# -> existing Storage INPUT. Nothing is seeded into an inventory.
	var storage_input_port := storage.get_node("InputPort") as ItemPortComponent
	var extractor_scene := load(
		"res://scenes/buildings/test_extractor.tscn"
	) as PackedScene
	var deposit_scene := load(
		"res://scenes/resource_nodes/TestOreDeposit.tscn"
	) as PackedScene
	assert(extractor_scene != null and deposit_scene != null)
	var extractor := extractor_scene.instantiate() as Node3D
	assert(extractor != null)
	add_child(extractor)
	var extraction := extractor.get_node("ExtractorComponent") as ExtractorComponent
	var extractor_logistics := extractor.get_node(
		"LogisticsTransferComponent"
	) as LogisticsTransferComponent
	var mined_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent
	var extractor_output_port := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent
	assert(extraction != null and extractor_logistics != null)
	assert(mined_inventory != null and extractor_output_port != null)
	extraction.set_process(false)
	extractor_logistics.set_process(false)
	assert(storage_input_port != null and storage_input_port.connected_conveyor == null)
	assert(storage_input_port.inventory == storage_inventory)
	assert(mined_inventory.get_total_amount() == 0)

	var mine_belt := _make_belt()
	var mine_snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(
		storage_input_port, mine_belt
	)
	assert(mine_snap.has("transform"))
	mine_belt.global_transform = mine_snap["transform"]
	assert(mine_belt.try_connect_building_port(storage_input_port))
	var mine_marker := mine_belt.get_node("InputEndpoint") as Marker3D
	assert(mine_marker != null)
	var mine_basis: Basis = mine_belt.global_transform.basis.orthonormalized()
	extractor.global_transform = Transform3D(
		mine_basis,
		mine_marker.global_position - mine_basis * extractor_output_port.position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		extractor_output_port, mine_marker, ConveyorSegment.CONNECTION_GAP
	))
	assert(mine_belt.try_connect_building_port(extractor_output_port))
	assert(mine_belt.input_building_port == extractor_output_port)
	assert(mine_belt.output_building_port == storage_input_port)
	assert(extractor_output_port.connected_conveyor == mine_belt)
	assert(storage_input_port.connected_conveyor == mine_belt)
	print("PASS D: Real Extractor and Storage connect over an independently timed belt")

	extraction._process(1.0)
	assert(mined_inventory.get_amount(ore) == 0)
	var deposit := deposit_scene.instantiate() as Node3D
	assert(deposit != null)
	deposit.global_position = extractor.global_position
	add_child(deposit)
	var deposit_runtime := deposit.get_node(
		"ResourceNodeRuntime"
	) as ResourceNodeRuntime
	assert(deposit_runtime != null and deposit_runtime.definition != null)
	assert(deposit_runtime.definition.resource_item == ore)
	assert(not deposit_runtime.definition.infinite_resource)
	assert(deposit_runtime.remaining_amount == 500)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	extraction._scan_for_resource_node()
	assert(extraction.resource_node == deposit_runtime)
	assert(mined_inventory.get_total_amount() == 0)
	assert(storage_inventory.get_total_amount() == 0)
	print("PASS E: Finite deposit physics discovery works; no ore was injected")



	# Before ANY factory delivery, establish one actual authorization-owned site.
	var site := ConstructionSite.new()
	site.name = "MinedResourceOwnedStorage"
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.set_process(false)
	var planned: Marker3D = site.get_planned_port_named(&"InputPort")
	assert(planned != null and planned.is_inside_tree())
	assert(not planned is ItemPortComponent)
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)

	var staged_supply := BlueprintConstructionMaterialStaging.new()
	staged_supply.enable_isolated_staging = true
	add_child(staged_supply)
	assert(staged_supply.configure(storage_inventory, definition, 3))
	var buffer: InventoryComponent = staged_supply.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)

	var receiver := Node3D.new()
	receiver.name = "IndependentSiteReceiver"
	add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver.add_child(port)
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(not port.attach_to_authorized_site(site, staged_supply, registry))
	assert(registry.claim_count() == 0)
	assert(buffer.get_total_amount() == 0)
	print("PASS F: Planned High-priority site owns no receiver before explicit E-style authorization")


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

	# Place the REAL blueprint so its geometric PlannedInputPort overlaps the
	# existing output conveyor endpoint; no magic material transfer.
	var target_input := Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	site.global_transform = target_input * planned.transform.affine_inverse()
	assert(planned.global_transform.is_equal_approx(target_input))
	assert(site.job.authorize())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(port.attach_to_authorized_site(site, staged_supply, registry))
	assert(port.matches_attached_site())
	assert(registry.inventory_for_site(site) == buffer)
	assert(registry.claim_count() == 1)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		endpoint, port, ConveyorSegment.CONNECTION_GAP
	))
	assert(output_b.try_connect_building_port(port))
	assert(output_b.output_building_port == port)
	assert(port.connected_conveyor == output_b)

	# These fixture-only resources are deliberately configured BEFORE mining.
	# They must not grant readiness until the connected conveyor delivers
	# this site's complete material bill to its uniquely claimed inventory.
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	var unused_warehouse := InventoryComponent.new()
	for service: Node in [
		queue, scheduler, escrow, network, power, coordinator, unused_warehouse
	]:
		add_child(service)
	assert(power.configure(network))
	var hub := _structure(
		"res://scenes/buildings/prototype_main_hub.tscn",
		site.global_position + Vector3(-6, 0, 0)
	)
	var pole := _structure(
		"res://scenes/buildings/prototype_power_pole.tscn",
		site.global_position
	)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	assert(coordinator.configure(
		queue, scheduler, escrow, power, unused_warehouse, 1
	))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(coordinator.track_site(site, 7))
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS G: Two ingot belts feed one owned site; empty staging gives no job authority")

	# Fail closed before stock arrives; do not fabricate factory output.
	producer._process(10.0)
	_timer(ore_belt)._process(0.01)
	_timer(output_a)._process(0.01)
	assert(smelt_input.get_total_amount() == 0)
	assert(smelt_output.get_total_amount() == 0)
	assert(buffer.get_total_amount() == 0)
	assert(_transport(output_a).get_held_item() == null)
	print("PASS H: Empty factory cannot produce or deliver a phantom ingot")

	assert(storage_inventory.get_amount(ore) == 0)
	assert(storage_inventory.get_amount(ingot) == 0)
	assert(staged_supply.receive_item(ore, 1) == 0)
	assert(buffer.get_total_amount() == 0)
	for mining_index: int in range(8):
		_mine_one_to_storage(
			extraction, mined_inventory, mine_belt,
			storage_inventory, deposit_runtime, ore
		)
	assert(storage_inventory.get_amount(ore) == 8)
	assert(mined_inventory.get_amount(ore) == 0)
	assert(_transport(mine_belt).get_held_item() == null)
	assert(deposit_runtime.remaining_amount == 492)
	assert(_timer(mine_belt).successful_transfers == 8)
	print("PASS I: Eight real mined ore arrive in Storage; finite deposit now 492")

	_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
	assert(smelt_input.get_amount(ore) == 1)
	producer._process(10.0)
	assert(smelt_output.get_amount(ingot) == 0)
	assert(producer.production_status == "Waiting for Inputs")
	_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
	assert(smelt_input.get_amount(ore) == 2)
	print("PASS J: Ore must traverse the actual source belt before Smelter may run")

	producer._process(1.0)
	assert(smelt_output.get_amount(ingot) == 0)
	producer._process(1.0)
	assert(smelt_input.get_amount(ore) == 0)
	assert(smelt_output.get_amount(ingot) == 1)
	assert(storage_inventory.get_amount(ore) == 6)
	print("PASS K: Two physically delivered ore become one ingot after real recipe time")

	_deliver_ingot(output_a, output_b, buffer, ingot)
	assert(smelt_output.get_amount(ingot) == 0)
	assert(buffer.get_amount(ingot) == 1)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(_timer(output_a).successful_transfers == 1)
	assert(_timer(output_b).successful_transfers == 1)
	print("PASS L: Manufactured ingot travels both timed belts into bill-filtered staging")

	for cycle: int in range(2):
		_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
		_deliver_ore(ore_belt, smelt_input, storage_inventory, ore)
		assert(smelt_input.get_amount(ore) == 2)
		producer._process(2.0)
		assert(smelt_output.get_amount(ingot) == 1)
		_deliver_ingot(output_a, output_b, buffer, ingot)
	assert(buffer.get_amount(ingot) == 3)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	assert(storage_inventory.get_amount(ore) == 2)
	assert(smelt_input.get_amount(ore) == 0)
	assert(smelt_output.get_total_amount() == 0)
	assert(not port.can_accept_item(ingot))
	print("PASS M: Three recipe-produced ingots fill bounded staging; six ore consumed")

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
	print("PASS N: Fourth real ingot remains on last belt while staging is full")


	assert(coordinator.reconcile() == 1)
	var held: int = escrow.reservation_for(site)
	assert(held > 0 and escrow.held_materials(held) == ConstructionMaterialBill.get_costs(definition))
	assert(buffer.get_total_amount() == 0)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1)
	assert(unused_warehouse.get_total_amount() == 0)
	assert(not port.can_accept_item(ingot))
	print("PASS O: Only three truly mined-and-smelted ingots fund the owned construction job")

	# A fourth ingot is still held in the last conveyor's cargo buffer.
	assert(not _timer(output_b).advance_transport(0.01))
	assert(_transport(output_b).cargo_inventory.get_amount(ingot) == 1)
	assert(not port.matches_attached_site())
	assert(escrow.held_count() == 1)
	print("PASS P: Active construction rejects extra inbound cargo; claim stays locked")

	site.job.advance(4.0)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.has_reservation(held))
	site.job.advance(100.0)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	print("PASS Q: Prototype power outage pauses timed build with no item loss")

	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	assert(not _timer(output_b).advance_transport(0.01))
	assert(_transport(output_b).cargo_inventory.get_amount(ingot) == 1)
	print("PASS R: Restored power resumes saved progress, never drops belt cargo")

	site.job.advance(6.0)
	assert(site.job.state == ConstructionJob.State.COMPLETE)
	assert(site.is_completed())
	assert(not escrow.has_reservation(held))
	assert(coordinator.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(registry.claim_count() == 1)
	assert(not port.can_accept_item(ingot))
	print("PASS S: Timed construction completes and commits exact three-ingot escrow once")

	var recovered := InventoryComponent.new()
	add_child(recovered)
	assert(_transport(output_b).cargo_inventory.transfer_to(recovered, ingot, 1) == 1)
	assert(recovered.get_amount(ingot) == 1)
	assert(_transport(output_b).get_held_item() == null)
	assert(_transport(output_a).get_held_item() == null)
	assert(_transport(ore_belt).get_held_item() == null)
	assert(_transport(mine_belt).get_held_item() == null)
	assert(mined_inventory.get_total_amount() == 0)
	assert(storage_inventory.get_total_amount() == 0)
	assert(smelt_input.get_total_amount() == 0)
	assert(smelt_output.get_total_amount() == 0)
	assert(buffer.get_total_amount() == 0)
	assert(escrow.held_count() == 0)
	assert(unused_warehouse.get_total_amount() == 0)
	print("PASS T: Fourth physical ingot recovered; no stranded cargo, shared debit or escrow")

	assert(deposit_runtime.remaining_amount == 492)
	# The only eight mined ore are four ingots: three consumed in the building,
	# one retained in explicitly recovered inventory. Nothing was created.
	assert(deposit_runtime.remaining_amount + 2 * (3 + recovered.get_amount(ingot)) == 500)
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSiteStagingRegistry") == null)
	assert(main.get_node_or_null("BlueprintConstructionSiteStagingRegistry") == null)
	main.free()
	sandbox.free()
	print("PASS U: Eight-ore conservation proof holds; both playable scenes remain untouched")

	print("ALL 21 E3D5C4T MINED-ORE-TO-OWNED-CONSTRUCTION TESTS PASSED")
	print("TEST ONLY: Real mine/smelter/belts; prototype nameplate power and simulated worker slot.")

