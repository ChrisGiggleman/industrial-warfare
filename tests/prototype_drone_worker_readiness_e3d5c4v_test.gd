extends Node3D

# =============================================================================
# E3D5C4V — PHYSICAL DRONE ARRIVAL GATES FINITE CONSTRUCTION WORKERS
# =============================================================================
# Site-owned inventory is explicitly staged; an unrelated warehouse cannot
# fund it. Prototype power + scheduler are isolated to this fixture.
# No automatic movement/time stepping: always reconcile before manual work.
# Normal gameplay, pathfinding, battery, live workers and saving unaffected.

func _ready() -> void:
	call_deferred("_run_checks")


func _site(definition: BuildingDefinition, name_text: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = name_text
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _structure(path: String, at: Vector3) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var building := packed.instantiate() as PrototypePowerStructure
	assert(building != null)
	add_child(building)
	building.global_position = at
	return building


func _run_checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	assert(int(ConstructionMaterialBill.get_costs(definition).get(ingot, 0)) == 3)

	var site := _site(definition, "DroneOwnedStorage", Vector3(6, 0, 0))
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	add_child(queue)
	add_child(scheduler)
	assert(not scheduler.enable_isolated_drone_presence)
	assert(not drone.enable_isolated_drone)
	assert(not scheduler.bind_site_drone(site, drone))
	print("PASS A: Physical drone worker gate is disabled and cannot dispatch by default")

	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(not scheduler.bind_site_drone(site, drone))
	print("PASS B: Unapproved construction cannot obtain a physical worker")

	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	drone.enable_isolated_drone = true
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: High priority never auto-authorizes or launches a worker")

	assert(site.job.authorize())
	assert(drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(drone.is_bound_to_site(site))
	assert(not drone.is_at_site())
	assert(not drone.grants_worker_readiness())
	assert(site.job.get_wait_reasons().has(&"workers"))
	print("PASS D: Explicit authorization binds flight only; no worker readiness granted")

	var stock := InventoryComponent.new()
	stock.max_capacity = 10
	add_child(stock)
	assert(stock.add_item(ingot, 3) == 3)
	var warehouse := InventoryComponent.new()
	warehouse.max_capacity = 20
	add_child(warehouse)
	assert(warehouse.add_item(ingot, 9) == 9)
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(stock, definition, 3))
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)
	var receiver_root := Node3D.new()
	add_child(receiver_root)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.enable_isolated_input = true
	port.show_port_label = false
	receiver_root.add_child(port)
	assert(port.attach_to_authorized_site(site, staging, registry))
	assert(registry.inventory_for_site(site) == buffer)
	print("PASS E: Exact material claim belongs to authorized site, not the warehouse")

	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	for service: Node in [escrow, network, power, coordinator]:
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
	assert(not scheduler.bind_site_drone(site, drone))
	print("PASS F: Coordinator admits one site; disabled drone gate rejects binding")

	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(escrow.held_count() == 0 and scheduler.get_active_count() == 0)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS G: Drone gate enabled but empty staging cannot start construction")

	assert(staging.receive_item(ingot, 2) == 2)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS H: Partial site-owned material bill cannot begin work")

	assert(staging.receive_item(ingot, 1) == 1)
	assert(coordinator.reconcile() == 0)
	var reserved: int = escrow.reservation_for(site)
	assert(reserved > 0)
	assert(int(escrow.held_materials(reserved).get(ingot, 0)) == 3)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_wait_reasons().has(&"workers"))
	assert(bool(coordinator.get_status(site)["materials_reserved"]))
	assert(bool(coordinator.get_status(site)["power_allocated"]))
	assert(not bool(coordinator.get_status(site)["worker_active"]))
	print("PASS I: Full escrow and power cannot bypass missing physical worker binding")

	var wrong := _site(definition, "UnrelatedSite", Vector3(-6, 0, 0))
	assert(wrong.job.authorize())
	assert(not scheduler.bind_site_drone(wrong, drone))
	assert(scheduler.bind_site_drone(site, drone))
	assert(not scheduler.bind_site_drone(site, drone))
	assert(not drone.is_bound_to_site(wrong))
	assert(coordinator.reconcile() == 0)
	print("PASS J: Binding checks exact site identity and refuses duplicate assignments")

	assert(drone.advance_flight(1.0))
	assert(not drone.is_at_site())
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	print("PASS K: Drone in transit cannot occupy the finite worker slot")

	assert(drone.advance_flight(10.0))
	assert(drone.is_at_site())
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1)
	assert(bool(coordinator.get_status(site)["worker_active"]))
	assert(not drone.grants_worker_readiness())
	print("PASS L: Actual drone arrival unlocks scheduler worker only with power and escrow")

	site.job.advance(4.0)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	assert(escrow.has_reservation(reserved))
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS M: Timed construction progresses only after full readiness")

	scheduler.enable_isolated_drone_presence = false
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(site.job.get_wait_reasons().has(&"workers"))
	assert(scheduler.get_active_count() == 0)
	site.job.advance(100.0)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	print("PASS N: Disabling scheduler gate pauses instead of reverting to fake slots")

	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(site.job.get_progress(), 0.4))
	print("PASS O: Scheduler gate restored; verified arrival resumes saved progress")

	drone.enable_isolated_drone = false
	assert(not drone.is_at_site())
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(escrow.has_reservation(reserved))
	assert(scheduler.get_active_count() == 0)
	print("PASS P: Drone feature loss immediately revokes worker on reconcile")

	drone.enable_isolated_drone = true
	assert(drone.is_at_site())
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS Q: Drone feature restoration resumes only bound worker")

	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.has_reservation(reserved))
	print("PASS R: Even a present drone cannot work without prototype power")

	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	site.job.advance(6.0)
	assert(site.job.state == ConstructionJob.State.COMPLETE)
	assert(site.is_completed())
	assert(not escrow.has_reservation(reserved))
	assert(coordinator.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	print("PASS S: Restored power finishes once, commits three ingots and frees slot")

	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.global_position == Vector3.ZERO)
	assert(not drone.assign_to_site(wrong, Vector3.ZERO, 2.0, 2.0))
	assert(registry.claim_count() == 1)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS T: Completed site's worker docks, cannot be reassigned or release claim")

	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	assert(main.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	main.free()
	sandbox.free()
	print("PASS U: Physical worker gating remains an isolated fixture, no playable-scene changes")

	print("ALL 21 E3D5C4V PHYSICAL DRONE WORKER READINESS TESTS PASSED")
	print("TEST ONLY: Straight flight and explicit reconcile; no pathfinding, charging or live worker fleet.")
