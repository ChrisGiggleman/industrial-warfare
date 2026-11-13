extends Node3D

# =============================================================================
# E3D5C4S — PHYSICAL BELT -> OWNED BUFFER -> ESCROW -> JOB READINESS
# =============================================================================
# Isolated F6 fixture: real item-port connections and timed conveyor travel.
# Uses a test-seeded ingot supply, not mining or smelting provenance.
# Only the fixture sets a finite worker slot and prototype nameplate power.
# It never installs an automated coordinator in either playable scene.
# Each construction tick is explicitly advanced, not automatic.

func _ready() -> void:
	call_deferred("_run_checks")


func _structure(path: String, at: Vector3) -> PrototypePowerStructure:
	var scene := load(path) as PackedScene
	assert(scene != null)
	var structure := scene.instantiate() as PrototypePowerStructure
	assert(structure != null)
	add_child(structure)
	structure.global_position = at
	return structure


func _deliver(
	timer: ConveyorTransportTimer,
	transport: ConveyorTransportComponent,
	ingot: ItemDefinition
) -> void:
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(0.4))
	assert(timer.advance_transport(0.61))
	assert(transport.get_held_item() == null)


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var bill: Dictionary = ConstructionMaterialBill.get_costs(definition)
	assert(bill.size() == 1 and int(bill.get(ingot, 0)) == 3)

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	add_child(registry)
	add_child(coordinator)
	assert(not registry.enable_isolated_site_registry)
	assert(not coordinator.enable_isolated_owned_staging)
	assert(not coordinator.configure_owned_staging(registry))
	assert(coordinator.reconcile() == 0)
	print("PASS A: Site-owned readiness is OFF without deliberate fixture opt-ins")

	var site := ConstructionSite.new()
	site.name = "BeltdeliveredStorageBlueprint"
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = Vector3(6, 0, 0)
	site.set_process(false)
	var marker := site.get_planned_port_named(&"InputPort")
	assert(marker != null and marker.is_inside_tree())
	assert(not marker is ItemPortComponent)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Planned Storage provides non-operational geometric input")

	var source := Node3D.new()
	source.name = "ExplicitTestStockBuilding"
	add_child(source)
	var supply := InventoryComponent.new()
	supply.max_capacity = 16
	source.add_child(supply)
	assert(supply.add_item(ingot, 4) == 4)
	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.show_port_label = false
	output.inventory = supply
	source.add_child(output)
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(supply, definition, 3))
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)
	print("PASS C: Explicit four-ingot test source and separate empty staging exist")

	var receiver := Node3D.new()
	receiver.name = "IndependentOwnedReceiver"
	add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver.add_child(port)
	registry.enable_isolated_site_registry = true
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(not port.attach_to_authorized_site(site, staging, registry))
	assert(registry.claim_count() == 0)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS D: High priority cannot authorize a receiver or start construction")

	assert(site.job.authorize())
	assert(port.attach_to_authorized_site(site, staging, registry))
	assert(port.matches_attached_site())
	assert(port.global_transform.is_equal_approx(marker.global_transform))
	assert(registry.inventory_for_site(site) == buffer)
	assert(registry.claim_count() == 1)
	print("PASS E: Explicitly authorized site owns its aligned input and buffer")

	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene
	assert(belt_scene != null)
	var belt := belt_scene.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	assert(timer != null and transport != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	var input_marker := belt.get_node("InputEndpoint") as Marker3D
	assert(input_marker != null)
	source.global_transform = Transform3D(
		input_marker.global_transform.basis * Basis(Vector3.UP, PI),
		input_marker.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		output, input_marker, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(output))
	assert(belt.input_building_port == output)
	assert(belt.output_building_port == port)
	assert(port.connected_conveyor == belt)
	print("PASS F: Real conveyor has reciprocal source and site input connections")

	var warehouse := InventoryComponent.new()
	warehouse.max_capacity = 20
	add_child(warehouse)
	assert(warehouse.add_item(ingot, 9) == 9)
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	for service: Node in [queue, scheduler, escrow, network, power]:
		add_child(service)
	assert(power.configure(network))
	var hub := _structure(
		"res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO
	)
	var pole := _structure(
		"res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0)
	)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	assert(coordinator.configure(queue, scheduler, escrow, power, warehouse, 1))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(coordinator.track_site(site, 7))
	print("PASS G: Finite prototype power and one worker track an owned site")

	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(escrow.held_count() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS H: Empty staging cannot spend unrelated warehouse stock")

	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 1)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(site.job.get_progress() == 0.0)
	print("PASS I: First timed conveyor delivery is insufficient for reservation")

	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 2)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS J: Second physical delivery cannot prematurely start work")

	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 3)
	assert(timer.successful_transfers == 3)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	print("PASS K: Third ingot fills exclusive staging but never auto-authorizes")

	assert(coordinator.reconcile() == 1)
	var reservation: int = escrow.reservation_for(site)
	assert(reservation > 0 and escrow.held_materials(reservation) == bill)
	assert(buffer.get_amount(ingot) == 0)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1)
	assert(warehouse.get_amount(ingot) == 9)
	assert(registry.matches_owned_inventory(site, buffer))
	print("PASS L: Full owned bill is escrowed and verified power/worker start job")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	assert(buffer.get_total_amount() == 0)
	assert(not port.matches_attached_site())
	assert(not port.can_accept_item(ingot))
	print("PASS M: Fourth ingot stays in belt cargo after receiver leaves QUEUED")

	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.has_reservation(reservation))
	site.job.advance(5.0)
	assert(site.job.get_progress() == 0.0)
	print("PASS N: Generator outage pauses construction without losing escrow")

	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(escrow.has_reservation(reservation))
	assert(not timer.advance_transport(0.01))
	site.job.advance(4.0)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	print("PASS O: Power restoration resumes only verified job; held cargo stays blocked")

	site.job.advance(6.0)
	assert(site.job.state == ConstructionJob.State.COMPLETE)
	assert(site.is_completed())
	assert(not escrow.has_reservation(reservation))
	assert(coordinator.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	var recovery := InventoryComponent.new()
	add_child(recovery)
	assert(transport.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.get_amount(ingot) == 1)
	assert(supply.get_amount(ingot) == 0)
	assert(buffer.get_amount(ingot) == 0)
	assert(warehouse.get_amount(ingot) == 9)
	assert(registry.claim_count() == 1)
	assert(not registry.matches_owned_inventory(site, buffer))
	assert(not port.can_accept_item(ingot))
	# Four test-source ingots = three used + one recovered belt item.
	assert(3 + recovery.get_amount(ingot) == 4)
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSiteStagingRegistry") == null)
	main.free()
	sandbox.free()
	print("PASS P: Build commits three ingots; fourth recovered; scenes opted out")

	print("ALL 16 E3D5C4S CONVEYOR-TO-OWNED-READINESS TESTS PASSED")
	print("TEST ONLY: Explicit seeded stock, prototype power and a synthetic slot; no live worker or save/load.")
