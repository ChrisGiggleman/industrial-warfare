extends Node3D

# E3d5c4y isolated explicit worker release and charged second assignment.
# No automatic dispatch/reconciliation. No live factory scene integration.

func _ready() -> void:
	call_deferred("_checks")


func _site(definition: BuildingDefinition, label: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _stage(site: ConstructionSite, definition: BuildingDefinition,
	item: ItemDefinition, quantity: int,
	registry: BlueprintConstructionSiteStagingRegistry
) -> BlueprintConstructionMaterialStaging:
	var source := InventoryComponent.new()
	source.max_capacity = 10
	add_child(source)
	assert(source.add_item(item, quantity) == quantity)
	var stage := BlueprintConstructionMaterialStaging.new()
	stage.enable_isolated_staging = true
	add_child(stage)
	assert(stage.configure(source, definition, 3))
	var receiver := Node3D.new()
	add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.enable_isolated_input = true
	port.show_port_label = false
	receiver.add_child(port)
	assert(port.attach_to_authorized_site(site, stage, registry))
	return stage


func _power(path: String, at: Vector3) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var structure := packed.instantiate() as PrototypePowerStructure
	assert(structure != null)
	add_child(structure)
	structure.global_position = at
	return structure


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var fleet := PrototypeConstructionDroneFleet.new()
	for node: Node in [queue, scheduler, fleet]:
		add_child(node)
	assert(not fleet.enable_isolated_reuse)
	assert(fleet.dispatch_waiting() == 0)
	print("PASS A: Reuse defaults OFF and cannot dispatch automatically")

	var first := _site(definition, "First", Vector3(6, 0, 0))
	var second := _site(definition, "Second", Vector3(8, 0, 0))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.authorize())
	assert(second.job.authorize())
	print("PASS B: Both sites need deliberate authorization before worker admission")

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)
	var stage_a := _stage(first, definition, ingot, 6, registry)
	var stage_b := _stage(second, definition, ingot, 3, registry)
	assert(registry.claim_count() == 2)
	assert(registry.inventory_for_site(first) != registry.inventory_for_site(second))
	print("PASS C: Independent construction inventories have permanent receiver claims")

	var warehouse := InventoryComponent.new()
	warehouse.max_capacity = 15
	add_child(warehouse)
	assert(warehouse.add_item(ingot, 9) == 9)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	for node: Node in [escrow, network, power, coordinator]:
		add_child(node)
	assert(power.configure(network))
	var hub := _power("res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO)
	var pole := _power("res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0))
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.configure(queue, scheduler, escrow, power, warehouse, 1))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(coordinator.track_site(first, 7))
	assert(not scheduler.is_tracking_site(second))
	print("PASS D: One-worker coordinator tracks first site; warehouse is disconnected")

	fleet.enable_isolated_fleet = true
	assert(fleet.configure(queue, scheduler, 2.0, 2.0))
	var drone := PrototypeConstructionWorkerDrone.new()
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	add_child(drone)
	assert(drone.configure_battery(40.0, 16.0, 1.0, 4.0))
	assert(fleet.register_drone(drone))
	assert(not drone.enable_isolated_reuse)
	assert(fleet.registered_count() == 1)
	print("PASS E: A single battery-equipped worker is registered with reuse OFF")

	assert(fleet.dispatch_waiting() == 1)
	assert(fleet.get_drone_for_site(first) == drone)
	assert(fleet.get_drone_for_site(second) == null)
	assert(not drone.is_at_site())
	print("PASS F: Only first authorized and tracked blueprint receives flight")

	assert(coordinator.reconcile() == 0)
	assert(stage_a.receive_item(ingot, 3) == 3)
	assert(coordinator.reconcile() == 0)
	var hold_a: int = escrow.reservation_for(first)
	assert(hold_a > 0 and escrow.held_count() == 1)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS G: First material escrow is reserved but flight has not arrived")

	assert(drone.advance_flight(10.0))
	assert(drone.is_at_site())
	assert(coordinator.reconcile() == 1)
	first.job.advance(3.0)
	assert(is_equal_approx(first.job.get_progress(), 0.3))
	print("PASS H: Arrival, power and owned escrow allow thirty percent progress")

	assert(stage_a.receive_item(ingot, 3) == 3)
	assert(first.job.cancel())
	assert(escrow.needs_recovery(hold_a))
	assert(escrow.has_reservation(hold_a))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	print("PASS I: Cancellation with full buffer preserves unresolved material escrow")

	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.battery_units() < drone.battery_capacity())
	assert(drone.battery_units() > 0.0)
	print("PASS J: The first worker physically docks with depleted energy")

	assert(not fleet.recycle_docked_worker(drone, escrow))
	assert(not drone.release_docked_assignment(escrow, scheduler))
	print("PASS K: Default-OFF worker release rejects even a docked drone")

	drone.enable_isolated_reuse = true
	fleet.enable_isolated_reuse = true
	assert(scheduler.has_drone_binding(drone))
	assert(not fleet.recycle_docked_worker(drone, escrow))
	print("PASS L: Stale scheduler worker binding blocks premature release")

	assert(coordinator.reconcile() == 0)
	assert(not scheduler.has_drone_binding(drone))
	assert(not fleet.recycle_docked_worker(drone, escrow))
	assert(escrow.held_count() == 1)
	print("PASS M: Unresolved escrow blocks reuse after scheduler cleanup")

	var recovered := InventoryComponent.new()
	recovered.max_capacity = 10
	add_child(recovered)
	assert(escrow.recover_to(hold_a, recovered))
	assert(recovered.get_amount(ingot) == 3)
	assert(escrow.held_count() == 0)
	assert(not fleet.recycle_docked_worker(drone, escrow))
	print("PASS N: Recovery alone cannot bypass depleted charge")

	assert(not drone.charge_at_home(1.0, false))
	assert(drone.charge_at_home(10.0, true))
	assert(is_equal_approx(drone.battery_units(), 40.0))
	print("PASS O: Verified powered home charging restores full capacity")

	assert(fleet.recycle_docked_worker(drone, escrow))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(drone.completed_rearms() == 1)
	assert(fleet.idle_count() == 1)
	assert(fleet.get_drone_for_site(first) == null)
	assert(not fleet.recycle_docked_worker(drone, escrow))
	assert(registry.claim_count() == 2)
	print("PASS P: Explicit rearm clears worker only; material claims stay locked")

	assert(coordinator.track_site(second, 7))
	assert(fleet.dispatch_waiting() == 1)
	assert(drone.is_bound_to_site(second))
	assert(not drone.is_bound_to_site(first))
	assert(fleet.get_drone_for_site(second) == drone)
	print("PASS Q: One recharged worker accepts a distinct authorized next job")

	assert(stage_b.receive_item(ingot, 3) == 3)
	assert(coordinator.reconcile() == 0)
	var hold_b: int = escrow.reservation_for(second)
	assert(hold_b > 0 and hold_b != hold_a)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(drone.advance_flight(10.0))
	assert(drone.is_at_site())
	assert(coordinator.reconcile() == 1)
	assert(second.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS R: Second job again requires own escrow, power and physical arrival")

	second.job.advance(10.0)
	assert(second.job.state == ConstructionJob.State.COMPLETE)
	assert(second.is_completed())
	assert(not escrow.has_reservation(hold_b))
	assert(coordinator.reconcile() == 0)
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	print("PASS S: Second building commits once; drone docks without automatic rearm")

	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(recovered.get_amount(ingot) == 3)
	assert(stage_b.get_staged_inventory().get_amount(ingot) == 0)
	assert(warehouse.get_amount(ingot) == 9)
	assert(registry.claim_count() == 2)
	assert(fleet.assigned_count() == 2)
	assert(fleet.registered_count() == 1 and fleet.idle_count() == 0)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeConstructionDroneFleet") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneFleet") == null)
	main.free()
	sandbox.free()
	print("PASS T: Old input claims survive, factory stock conserved and Main unchanged")

	print("ALL 20 E3D5C4Y SAFE CONSTRUCTION DRONE REUSE TESTS PASSED")
	print("TEST ONLY: Global empty escrow barrier, one full battery, manual release and dispatch.")
