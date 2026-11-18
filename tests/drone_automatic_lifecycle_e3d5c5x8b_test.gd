extends Node3D

const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")


func _ready() -> void:
	call_deferred("_checks")


func _storage(at: Vector3, stock: int) -> PrototypeDroneStorageDock:
	var building := STORAGE.building_scene.instantiate() as Node3D
	add_child(building)
	building.global_position = at
	(building.get_node("BuildingRuntime") as BuildingRuntime).initialize(STORAGE)
	var inventory := building.get_node("InventoryComponent") as InventoryComponent
	inventory.enable_isolated_drone_claims = true
	inventory.enable_isolated_drone_return_claims = true
	inventory.max_capacity = 20
	assert(inventory.add_item(INGOT, stock) == stock)
	var dock := PrototypeDroneStorageDock.new()
	building.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	return dock


func _stock(dock: PrototypeDroneStorageDock) -> InventoryComponent:
	return dock.get_parent().get_node("InventoryComponent") as InventoryComponent


func _drone() -> PrototypeConstructionWorkerDrone:
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	drone.global_position = Vector3(0, 2, 0)
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	assert(drone.configure_battery(40.0, 40.0, 1.0, 4.0))
	return drone


func _site(at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(STORAGE))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _buffer(registry: BlueprintConstructionSiteStagingRegistry, site: ConstructionSite, source: InventoryComponent) -> InventoryComponent:
	var staging := BlueprintConstructionMaterialStaging.new()
	add_child(staging)
	staging.enable_isolated_staging = true
	assert(staging.configure(source, STORAGE, 6))
	var root := Node3D.new()
	add_child(root)
	var port := BlueprintConstructionStagingInputPort.new()
	root.add_child(port)
	port.show_port_label = false
	port.enable_isolated_input = true
	assert(port.bind_staging(staging))
	assert(registry.claim_site(site, staging, port))
	return staging.get_staged_inventory()


func _structure(path: String, at: Vector3) -> PrototypePowerStructure:
	var building := (load(path) as PackedScene).instantiate() as PrototypePowerStructure
	add_child(building)
	building.global_position = at
	return building




func _queue_site(registry: BlueprintConstructionSiteStagingRegistry, coordinator: BlueprintConstructionReadinessCoordinator, stock: InventoryComponent, priority: int) -> Dictionary:
	var site := _site(Vector3(6, 0, 0))
	assert(site.job.set_priority(priority) and site.job.authorize())
	var buffer := _buffer(registry, site, stock)
	assert(coordinator.track_site(site, 7))
	return {"site": site, "job": site.job, "buffer": buffer}


func _step(dispatch: PrototypeDroneAutomaticDispatch, expected: StringName, delta: float = 10.0) -> void:
	var result: Dictionary = dispatch.tick(delta)
	assert(result["action"] == expected, "Expected %s, got %s" % [expected, result])


func _launch(dispatch: PrototypeDroneAutomaticDispatch, site: ConstructionSite) -> void:
	var result: Dictionary = dispatch.tick(1.0)
	assert(result["action"] == &"launched" and result["selection"]["site"] == site)


func _deliver(dispatch: PrototypeDroneAutomaticDispatch) -> void:
	_step(dispatch, &"pickup_flight")
	_step(dispatch, &"collected")
	_step(dispatch, &"delivery_started")
	_step(dispatch, &"delivery_flight")
	_step(dispatch, &"unloaded")


func _rearm(dispatch: PrototypeDroneAutomaticDispatch, drone: PrototypeConstructionWorkerDrone) -> void:
	for i: int in range(30):
		if not dispatch.has_lifecycle_assignment():
			break
		dispatch.tick(10.0)
	assert(not dispatch.has_lifecycle_assignment())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(drone.battery_units() == drone.battery_capacity())


func _checks() -> void:
	var discovery := PrototypeDroneStorageDiscovery.new()
	var claims := PrototypeDroneSupplierReservations.new()
	var returns := PrototypeDroneReturnReservations.new()
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	var charging := PrototypeDroneHubCharging.new()
	var dispatch := PrototypeDroneAutomaticDispatch.new()
	for service: Node in [discovery, claims, returns, registry, escrow, queue, scheduler, network, power, coordinator, charging, dispatch]:
		add_child(service)
	discovery.enable_isolated_discovery = true
	claims.enable_isolated_reservations = true
	returns.enable_isolated_reservations = true
	returns.enable_isolated_cargo_recovery = true
	assert(claims.configure(discovery) and returns.configure(discovery))
	var dock := _storage(Vector3(3, 0, 0), 15)
	var stock := _stock(dock)
	assert(discovery.register_dock(dock))
	registry.enable_isolated_site_registry = true
	assert(power.configure(network))
	var hub := _structure("res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO)
	var pole := _structure("res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0))
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(coordinator.configure(queue, scheduler, escrow, power, stock, 1))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	scheduler.enable_isolated_drone_presence = true
	charging.enable_isolated_charging = true
	assert(charging.configure(hub, power))
	var drone := _drone()
	drone.enable_isolated_finite_charging = true
	drone.enable_isolated_cargo_pickup = true
	drone.enable_isolated_cargo_delivery = true
	drone.enable_isolated_delivered_worker = true
	drone.enable_isolated_cargo_recovery = true
	drone.enable_isolated_cargo_reuse = true
	drone.enable_isolated_pre_pickup_rearm = true
	drone.enable_isolated_post_delivery_rearm = true
	drone.enable_isolated_lost_site_rearm = true
	assert(charging.register_drone(drone))

	assert(not dispatch.enable_isolated_lifecycle)
	dispatch.enable_isolated_dispatch = true
	assert(dispatch.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	assert(not dispatch.configure_lifecycle(charging))
	_step(dispatch, &"blocked")
	dispatch.enable_isolated_lifecycle = true
	var foreign := PrototypeDroneHubCharging.new()
	add_child(foreign)
	assert(not dispatch.configure_lifecycle(foreign))
	foreign.free()
	assert(dispatch.configure_lifecycle(charging) and not dispatch.configure_lifecycle(charging))
	_step(dispatch, &"blocked", -1.0)
	_step(dispatch, &"blocked", INF)
	assert(dispatch.dispatch_next()["reason"] == &"lifecycle_owns_dispatch")
	print("PASS A: Separate default-off lifecycle, exact charging identity and delta gate")
	var planned := _site(Vector3(6, 0, 0))
	assert(planned.job.set_priority(ConstructionJob.Priority.HIGH))
	_step(dispatch, &"waiting")
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	var low: Dictionary = _queue_site(registry, coordinator, stock, ConstructionJob.Priority.LOW)
	var high: Dictionary = _queue_site(registry, coordinator, stock, ConstructionJob.Priority.HIGH)
	var equal: Dictionary = _queue_site(registry, coordinator, stock, ConstructionJob.Priority.HIGH)
	var first: ConstructionSite = high["site"]
	var first_job: ConstructionJob = high["job"]
	first.set_process(true)
	assert(dispatch.inspect_next()["site"] == equal["site"])
	first.set_process(false)
	_launch(dispatch, first)
	assert(claims.reservation_count() == 1 and drone.cargo_amount() == 0 and drone.battery_units() == 40.0)
	assert(stock.get_amount(INGOT) == 15 and stock.get_reserved_amount(INGOT) == 3)
	print("PASS B: Authorized High FIFO wins; external site timer excluded; launch alone reserves stock")
	dispatch.enable_isolated_lifecycle = false
	_step(dispatch, &"blocked")
	assert(drone.battery_units() == 40.0 and claims.reservation_count() == 1)
	dispatch.enable_isolated_lifecycle = true
	_step(dispatch, &"pickup_flight", 0.5)
	assert(drone.battery_units() == 39.0 and drone.cargo_amount() == 0)
	_step(dispatch, &"pickup_flight")
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP)
	assert(stock.get_amount(INGOT) == 15)
	print("PASS C: Opt-out freezes tick; metered pickup arrival does not debit stock")
	_step(dispatch, &"collected")
	assert(stock.get_amount(INGOT) == 12 and drone.cargo_amount() == 3 and claims.reservation_count() == 0)
	assert(high["buffer"].get_total_amount() == 0 and escrow.held_count() == 0)
	_step(dispatch, &"delivery_started")
	_step(dispatch, &"delivery_flight")
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_DELIVERY and drone.cargo_amount() == 3)
	_step(dispatch, &"unloaded")
	assert(high["buffer"].get_amount(INGOT) == 3 and drone.cargo_amount() == 0)
	assert(first_job.get_progress() == 0.0 and escrow.held_count() == 0)
	print("PASS D: Physical collection and delivery are separate conserved phases")
	pole.get_power_node().operational = false
	_step(dispatch, &"admitted")
	assert(escrow.held_count() == 1 and high["buffer"].get_total_amount() == 0)
	assert(first_job.state == ConstructionJob.State.QUEUED and scheduler.get_active_count() == 0)
	_step(dispatch, &"construction_wait", 2.0)
	assert(first_job.get_progress() == 0.0)
	pole.get_power_node().operational = true
	_step(dispatch, &"construction", 1.0)
	assert(first_job.state == ConstructionJob.State.CONSTRUCTING and is_equal_approx(first_job.get_progress(), 0.1))
	print("PASS E: Escrow and delivered worker do not bypass power; one second advances exactly once")
	pole.get_power_node().operational = false
	_step(dispatch, &"construction_wait", 3.0)
	assert(first_job.state == ConstructionJob.State.PAUSED and is_equal_approx(first_job.get_progress(), 0.1))
	pole.get_power_node().operational = true
	_step(dispatch, &"construction", 2.0)
	assert(is_equal_approx(first_job.get_progress(), 0.3))
	assert(equal["job"].get_progress() == 0.0 and low["job"].get_progress() == 0.0)
	print("PASS F: Power loss pauses and resumes same job without preemption or duplicate time")
	_step(dispatch, &"construction")
	assert(first_job.state == ConstructionJob.State.COMPLETE and escrow.held_count() == 0)
	assert(high["buffer"].get_total_amount() == 0 and stock.get_amount(INGOT) == 12)
	for i: int in range(3):
		if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			break
		dispatch.tick(10.0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.battery_units() == 28.0)
	print("PASS G: Completion commits cost exactly once and returns on actual battery")
	charging.enable_isolated_charging = false
	_step(dispatch, &"dock_wait")
	assert(drone.battery_units() == 28.0 and dispatch.has_lifecycle_assignment())
	charging.enable_isolated_charging = true
	_step(dispatch, &"charged", 1.0)
	assert(drone.battery_units() == 32.0 and drone.completed_rearms() == 0)
	_step(dispatch, &"charged", 10.0)
	assert(drone.battery_units() == 40.0 and drone.completed_rearms() == 0)
	_step(dispatch, &"rearmed")
	assert(drone.completed_rearms() == 1 and not dispatch.has_lifecycle_assignment())
	print("PASS H: Real finite charge and separate guarded rearm before next dispatch")
	_launch(dispatch, equal["site"])
	_deliver(dispatch)
	_step(dispatch, &"admitted")
	_step(dispatch, &"construction")
	assert(equal["job"].state == ConstructionJob.State.COMPLETE)
	_rearm(dispatch, drone)
	assert(drone.completed_rearms() == 2 and stock.get_amount(INGOT) == 9)
	print("PASS I: Equal-priority successor completes automatically on same drone")
	_launch(dispatch, low["site"])
	assert(low["job"].cancel())
	assert(claims.reservation_count() == 0 and stock.get_amount(INGOT) == 9)
	_rearm(dispatch, drone)
	assert(drone.completed_rearms() == 3)
	print("PASS J: Pre-pickup cancellation returns unpicked stock and reuses only after cleanup")
	var lost: Dictionary = _queue_site(registry, coordinator, stock, ConstructionJob.Priority.HIGH)
	_launch(dispatch, lost["site"])
	_step(dispatch, &"pickup_flight")
	_step(dispatch, &"collected")
	assert(stock.get_amount(INGOT) == 6 and drone.cargo_amount() == 3)
	var lost_site: ConstructionSite = lost["site"]
	remove_child(lost_site)
	_step(dispatch, &"receiver_wait")
	assert(drone.cargo_amount() == 3 and returns.reservation_count() == 0)
	lost_site.free()
	dock.allow_returns = false
	_step(dispatch, &"recovery_wait")
	assert(drone.cargo_amount() == 3 and returns.reservation_count() == 0)
	dock.allow_returns = true
	_rearm(dispatch, drone)
	assert(drone.completed_rearms() == 4 and stock.get_amount(INGOT) == 9 and drone.cargo_amount() == 0)
	print("PASS K: Detached original not lost; freed loaded site recovers via actual reserved return")
	var cancelled: Dictionary = _queue_site(registry, coordinator, stock, ConstructionJob.Priority.NORMAL)
	_launch(dispatch, cancelled["site"])
	_deliver(dispatch)
	assert(cancelled["buffer"].get_amount(INGOT) == 3 and cancelled["job"].cancel())
	_step(dispatch, &"cancelled_return")
	_rearm(dispatch, drone)
	assert(drone.completed_rearms() == 5 and cancelled["buffer"].get_amount(INGOT) == 3 and stock.get_amount(INGOT) == 6)
	print("PASS L: Post-delivery cancellation preserves original staging and returns empty")
	var worker: Dictionary = _queue_site(registry, coordinator, stock, ConstructionJob.Priority.NORMAL)
	_launch(dispatch, worker["site"])
	_deliver(dispatch)
	_step(dispatch, &"admitted")
	_step(dispatch, &"construction", 1.0)
	assert(worker["job"].cancel())
	_rearm(dispatch, drone)
	assert(worker["buffer"].get_amount(INGOT) == 3 and drone.completed_rearms() == 6)
	print("PASS M: Cancellation during work refunds exact escrow into original buffer")
	_step(dispatch, &"waiting")
	assert(stock.get_amount(INGOT) == 3 and stock.get_amount(INGOT) + cancelled["buffer"].get_amount(INGOT) + worker["buffer"].get_amount(INGOT) + 6 == 15)
	assert(claims.reservation_count() == 0 and returns.reservation_count() == 0 and escrow.held_count() == 0)
	assert(drone.cargo_amount() == 0 and scheduler.get_active_count() == 0 and not scheduler.has_drone_binding(drone))
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	print("PASS N: Six automated assignments conserve all 15 ingots; no unauthorized work")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneAutomaticDispatch") == null and sandbox.get_node_or_null("PrototypeDroneAutomaticDispatch") == null)
	main.free()
	sandbox.free()
	print("PASS O: Normal scenes remain opted out")
	print("ALL 15 E3D5C5X8B AUTOMATIC LIFECYCLE TESTS PASSED")
