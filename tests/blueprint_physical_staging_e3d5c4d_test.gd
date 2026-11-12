extends Node3D

# =============================================================================
# E3D5C4D — ACTUAL BELT-TO-STAGING PORT & TIMED DELIVERY (TEST ONLY)
# =============================================================================
# The existing ConveyorTransportTimer and ConveyorBuildingTransfer physically
# unload a real ConveyorSegment through a reciprocal, aligned input port.
# This is not a player-placed construction receiver or production dispatch.
# All construction jobs remain QUEUED with no generator/worker permissions.


func _ready() -> void:
	call_deferred("_run_checks")


func _make_job(definition: BuildingDefinition) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = "AuthorizedStorageFixture"
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.position = Vector3(6, 0, 4)
	site.set_process(false)
	assert(site.job.authorize())
	return site


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ingot != null and ore != null)

	var source := Node3D.new()
	source.name = "TestOutputStructure"
	add_child(source)
	source.position = Vector3(0, 0, 3)
	var supply := InventoryComponent.new()
	supply.name = "ActualSourceInventory"
	supply.max_capacity = 10
	source.add_child(supply)
	assert(supply.add_item(ore, 1) == 1)

	var staging := BlueprintConstructionMaterialStaging.new()
	add_child(staging)
	assert(not staging.enable_isolated_staging)
	assert(not staging.accepts_delivered_item(ingot))
	var receiver := Node3D.new()
	receiver.name = "TestOnlyPhysicalStagingReceiver"
	add_child(receiver)
	var port := BlueprintConstructionStagingInputPort.new()
	port.name = "InputPort"
	port.show_port_label = false
	receiver.add_child(port)
	assert(not port.enable_isolated_input)
	assert(not port.bind_staging(staging))
	assert(not port.can_accept_item(ingot))
	print("PASS A: Staging and physical input default OFF and fail closed")

	staging.enable_isolated_staging = true
	assert(staging.configure(supply, definition, 3))
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer != null and buffer.max_capacity == 3)
	assert(buffer.get_total_amount() == 0)
	assert(not port.bind_staging(staging))
	print("PASS B: Empty bounded buffer alone cannot activate physical input")

	port.enable_isolated_input = true
	assert(port.bind_staging(staging))
	assert(port.inventory == buffer)
	assert(port.direction == ItemPortComponent.PortDirection.INPUT)
	assert(port.input_policy == ItemPortComponent.InputPolicy.ANY_ITEM)
	assert(not port.bind_staging(staging))
	assert(port.can_accept_item(ingot))
	assert(not port.can_accept_item(ore))
	print("PASS C: Opt-in port binds the exact buffer and filters by construction bill")

	var source_port := ItemPortComponent.new()
	source_port.name = "OutputPort"
	source_port.direction = ItemPortComponent.PortDirection.OUTPUT
	source_port.show_port_label = false
	source_port.inventory = supply
	source_port.position = Vector3(0, 0.5, 0)
	source.add_child(source_port)

	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene
	assert(belt_scene != null)
	var belt := belt_scene.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var cargo := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	assert(timer != null and cargo != null)
	timer.set_process(false)
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(
		source_port, belt
	)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(source_port))
	assert(belt.input_building_port == source_port)
	assert(source_port.connected_conveyor == belt)
	print("PASS D: Genuine source OUTPUT links to conveyor INPUT with aligned endpoints")

	var belt_output := belt.get_node("OutputEndpoint") as Marker3D
	assert(belt_output != null)
	receiver.global_transform = Transform3D(
		belt_output.global_transform.basis * Basis(Vector3.UP, PI),
		belt_output.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		belt_output, port, ConveyorSegment.CONNECTION_GAP
	))
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(belt))
	print("PASS E: Endpoint alignment alone does not permit unloading")

	timer._process(0.01)
	assert(cargo.get_held_item() == ore)
	assert(supply.get_amount(ore) == 0)
	assert(not timer.advance_transport(1.0))
	assert(buffer.get_total_amount() == 0)
	assert(timer.transport_status == "Blocked")
	print("PASS F: Source loads actual belt cargo; disconnected receiver blocks delivery")

	assert(belt.try_connect_building_port(port))
	assert(belt.output_building_port == port)
	assert(port.connected_conveyor == belt)
	assert(not port.can_accept_item(ore))
	assert(not timer.advance_transport(0.01))
	assert(cargo.get_held_item() == ore)
	assert(buffer.get_amount(ore) == 0)
	print("PASS G: Reciprocal connection cannot bypass bill-specific rejection")

	var quarantine := InventoryComponent.new()
	quarantine.name = "RejectedOreInventory"
	add_child(quarantine)
	assert(cargo.cargo_inventory.transfer_to(quarantine, ore, 1) == 1)
	assert(quarantine.get_amount(ore) == 1)
	assert(buffer.get_total_amount() == 0)
	assert(not timer.advance_transport(0.01))
	assert(supply.add_item(ingot, 4) == 4)
	print("PASS H: Rejected cargo is recovered exactly; no ore can enter staging")

	timer._process(0.01)
	assert(cargo.get_held_item() == ingot)
	assert(not timer.advance_transport(0.4))
	assert(timer.transport_status == "Moving")
	assert(buffer.get_amount(ingot) == 0)
	print("PASS I: Physical ingot must complete the belt travel interval")

	assert(timer.advance_transport(0.61))
	assert(buffer.get_amount(ingot) == 1)
	assert(supply.get_amount(ingot) == 3)
	assert(cargo.get_held_item() == null)
	assert(timer.successful_transfers == 1)
	print("PASS J: Timed conveyor unloads one ingot into the real staging buffer")

	for index: int in range(2):
		timer._process(0.01)
		assert(cargo.get_held_item() == ingot)
		assert(timer.advance_transport(1.0))
	assert(buffer.get_amount(ingot) == 3)
	assert(supply.get_amount(ingot) == 1)
	assert(timer.successful_transfers == 3)
	assert(not port.can_accept_item(ingot))
	print("PASS K: Three physical arrivals fill the definition-sized buffer")

	timer._process(0.01)
	assert(cargo.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(timer.transport_status == "Blocked")
	assert(buffer.get_amount(ingot) == 3)
	assert(supply.get_amount(ingot) == 0)
	assert(cargo.cargo_inventory.get_amount(ingot) == 1)
	print("PASS L: Fourth item remains on belt under full-buffer backpressure")

	var site := _make_job(definition)
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
	assert(coordinator.track_site(site, 7))
	assert(coordinator.reconcile() == 0)
	var reservation_id: int = escrow.reservation_for(site)
	assert(reservation_id > 0)
	assert(int(escrow.held_materials(reservation_id).get(ingot, 0)) == 3)
	assert(buffer.get_amount(ingot) == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	assert(scheduler.get_active_count() == 0)
	print("PASS M: Only physically staged ingots are escrowed; missing power blocks work")

	belt.position.x += 1.0
	assert(not timer.advance_transport(0.01))
	assert(cargo.get_held_item() == ingot)
	assert(buffer.get_amount(ingot) == 0)
	print("PASS N: Misaligned connected belt cannot unload even with free capacity")

	belt.global_transform = snap["transform"]
	assert(timer.advance_transport(0.01))
	assert(cargo.get_held_item() == null)
	assert(buffer.get_amount(ingot) == 1)
	assert(timer.successful_transfers == 4)
	assert(
		supply.get_amount(ingot) + cargo.cargo_inventory.get_amount(ingot)
		+ buffer.get_amount(ingot)
		+ int(escrow.held_materials(reservation_id).get(ingot, 0)) == 4
	)
	assert(quarantine.get_amount(ore) == 1)
	print("PASS O: Realignment restores timed delivery; all four ingots and ore conserved")

	assert(belt.disconnect_building_port(port))
	assert(belt.output_building_port == null)
	assert(port.connected_conveyor == null)
	staging.enable_isolated_staging = false
	assert(not port.can_accept_item(ingot))
	assert(not staging.accepts_delivered_item(ingot))
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	assert(scheduler.get_active_count() == 0)
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionStagingInputPort") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionStagingInputPort") == null)
	main.free()
	sandbox.free()
	print("PASS P: Disconnect/disable refuses input; Main and sandbox remain unchanged")

	print("ALL 16 E3D5C4D PHYSICAL CONVEYOR STAGING TESTS PASSED")
	print("TEST ONLY: Player build placement, real energy, workers and save/load NOT VERIFIED.")
