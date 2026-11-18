extends Node3D

const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const ORE = preload("res://data/items/test_ore.tres")


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


func _load_existing(drone: PrototypeConstructionWorkerDrone, claims: PrototypeDroneSupplierReservations, site: ConstructionSite) -> int:
	var id: int = claims.reserve(drone, site, INGOT, 3, 5)
	assert(id > 0)
	assert(claims.begin_pickup(id, drone, 2.0))
	assert(claims.advance_pickup(id, drone, 10.0))
	assert(claims.collect_pickup(id, drone))
	return id


func _structure(path: String, at: Vector3) -> PrototypePowerStructure:
	var building := (load(path) as PackedScene).instantiate() as PrototypePowerStructure
	add_child(building)
	building.global_position = at
	return building


func _deliver(drone: PrototypeConstructionWorkerDrone, site: ConstructionSite, registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow) -> void:
	drone.enable_isolated_cargo_delivery = true
	assert(drone.begin_delivery(site, registry, escrow))
	assert(drone.advance_delivery(10.0))
	assert(drone.unload_delivery())


func _checks() -> void:
	var discovery := PrototypeDroneStorageDiscovery.new()
	add_child(discovery)
	discovery.enable_isolated_discovery = true
	var claims := PrototypeDroneSupplierReservations.new()
	var returns := PrototypeDroneReturnReservations.new()
	add_child(claims)
	add_child(returns)
	claims.enable_isolated_reservations = true
	returns.enable_isolated_reservations = true
	assert(claims.configure(discovery) and returns.configure(discovery))
	returns.enable_isolated_cargo_recovery = true
	var dock := _storage(Vector3(3, 0, 0), 15)
	var stock := _stock(dock)
	assert(discovery.register_dock(dock))
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	var charging := PrototypeDroneHubCharging.new()
	for service: Node in [registry, escrow, queue, scheduler, network, power, coordinator, charging]:
		add_child(service)
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
	assert(charging.register_drone(drone))
	assert(not drone.enable_isolated_lost_site_rearm)
	drone.enable_isolated_cargo_reuse = true
	assert(not drone.begin_lost_delivery_return())
	var legacy := _drone()
	legacy.enable_isolated_cargo_pickup = true
	legacy.enable_isolated_cargo_reuse = true
	legacy.enable_isolated_finite_charging = true
	assert(charging.register_drone(legacy))
	var legacy_site := _site(Vector3(6, 0, 0))
	assert(legacy_site.job.authorize())
	var legacy_job: ConstructionJob = legacy_site.job
	var legacy_id: int = claims.reserve(legacy, legacy_site, INGOT, 3, 5)
	assert(legacy_id > 0 and claims.begin_pickup(legacy_id, legacy, 2.0))
	legacy_site.free()
	assert(legacy_job.state == ConstructionJob.State.QUEUED)
	legacy.enable_isolated_lost_site_rearm = true
	assert(not legacy.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS A: Default-off and late opt-in cannot fabricate original-site loss provenance")
	drone.enable_isolated_lost_site_rearm = true
	var forecast := _site(Vector3(6, 0, 0))
	assert(forecast.job.authorize())
	var forecast_id: int = claims.reserve(drone, forecast, INGOT, 3, 5)
	assert(forecast_id > legacy_id)
	forecast.free()
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE and drone.completed_rearms() == 0)
	assert(stock.get_amount(INGOT) == 15)
	print("PASS B: Lost forecast-only site releases reservation without launching or rearming")
	var pre := _site(Vector3(6, 0, 0))
	assert(pre.job.authorize())
	var pre_job: ConstructionJob = pre.job
	var pre_buffer := _buffer(registry, pre, stock)
	assert(coordinator.track_site(pre, 7))
	var pre_id: int = claims.reserve(drone, pre, INGOT, 3, 5)
	assert(pre_id > forecast_id and claims.begin_pickup(pre_id, drone, 2.0))
	assert(claims.advance_pickup(pre_id, drone, 0.75))
	assert(drone.battery_units() == 38.5)
	var rev: int = stock.get_mutation_revision()
	remove_child(pre)
	assert(pre_job.state == ConstructionJob.State.QUEUED and claims.reservation_count() == 0)
	assert(not claims.collect_pickup(pre_id, drone) and stock.get_mutation_revision() == rev)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(drone.advance_flight(10.0) and drone.battery_units() == 37.0)
	assert(coordinator.reconcile() == 0 and charging.advance_charging(10.0) == 3.0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS C: Temporary detachment releases claim and returns empty but does not permit reuse")
	pre.free()
	assert(pre_job.state == ConstructionJob.State.QUEUED)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 1 and pre_buffer.get_total_amount() == 0)
	assert(stock.get_amount(INGOT) == 15 and stock.get_mutation_revision() == rev)
	print("PASS D: Actual freed original site permits exact-once pre-pickup rearm without debit")
	var loaded := _site(Vector3(6, 0, 0))
	assert(loaded.job.authorize())
	var loaded_job: ConstructionJob = loaded.job
	var loaded_buffer := _buffer(registry, loaded, stock)
	assert(coordinator.track_site(loaded, 7))
	var loaded_id: int = _load_existing(drone, claims, loaded)
	assert(loaded_id > pre_id and drone.cargo_amount() == 3)
	assert(drone.begin_delivery(loaded, registry, escrow))
	assert(drone.advance_delivery(1.0))
	assert(drone.battery_units() == 35.0)
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	remove_child(loaded)
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	assert(not drone.advance_delivery(1.0) and drone.cargo_amount() == 3)
	assert(stock.get_amount(INGOT) == 12 and loaded_buffer.get_total_amount() == 0)
	print("PASS E: Healthy or temporarily detached original cannot divert an actual load")
	loaded.free()
	assert(loaded_job.state == ConstructionJob.State.QUEUED)
	dock.allow_returns = false
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.cargo_amount() == 3 and returns.reservation_count() == 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	dock.allow_returns = true
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(returns.reservation_count() == 1)
	assert(returns.advance_cancelled_recovery(drone, 10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_RECOVERY)
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.cargo_amount() == 0 and stock.get_amount(INGOT) == 15)
	assert(returns.advance_cancelled_recovery(drone, 10.0))
	assert(drone.battery_units() == 30.0 and coordinator.reconcile() == 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS F: Lost loaded assignment waits for protected physical recovery and metered home return")
	assert(charging.advance_charging(10.0) == 10.0)
	drone.enable_isolated_lost_site_rearm = false
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	drone.enable_isolated_lost_site_rearm = true
	registry.enable_isolated_site_registry = false
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	registry.enable_isolated_site_registry = true
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 2 and loaded_buffer.get_total_amount() == 0)
	print("PASS G: Full finite charge, current feature and original receiver authority gate recovered reuse")
	var delivered := _site(Vector3(6, 0, 0))
	assert(delivered.job.authorize())
	var delivered_job: ConstructionJob = delivered.job
	var delivered_ref: WeakRef = weakref(delivered)
	var delivered_buffer := _buffer(registry, delivered, stock)
	assert(coordinator.track_site(delivered, 7))
	var delivered_id: int = _load_existing(drone, claims, delivered)
	assert(delivered_id > loaded_id)
	_deliver(drone, delivered, registry, escrow)
	assert(not drone.begin_lost_delivery_return())
	remove_child(delivered)
	assert(not drone.begin_lost_delivery_return())
	delivered.free()
	assert(delivered_job.state == ConstructionJob.State.QUEUED)
	assert(escrow.held_count() == 0 and delivered_buffer.get_amount(INGOT) == 3)
	assert(drone.begin_lost_delivery_return() and not drone.begin_lost_delivery_return())
	assert(not returns.advance_cancelled_recovery(drone, 1.0) and drone.cargo_amount() == 0)
	assert(drone.advance_flight(10.0) and drone.battery_units() == 28.0)
	assert(coordinator.reconcile() == 0 and charging.advance_charging(10.0) == 12.0)
	assert(registry.has_locked_delivery_inventory(delivered_ref, delivered_buffer))
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 3)
	print("PASS H: Freed delivered site returns empty with original staging locked and stock intact")
	var blocked := _site(Vector3(6, 0, 0))
	assert(blocked.job.authorize())
	var blocked_job: ConstructionJob = blocked.job
	var blocked_buffer := _buffer(registry, blocked, stock)
	assert(coordinator.track_site(blocked, 7))
	var blocked_id: int = _load_existing(drone, claims, blocked)
	assert(blocked_id > delivered_id)
	_deliver(drone, blocked, registry, escrow)
	assert(coordinator.reconcile() == 0)
	var held: int = escrow.reservation_for(blocked)
	assert(held > 0 and escrow.held_materials(held)[INGOT] == 3)
	blocked_buffer.max_capacity = 2
	blocked.free()
	assert(blocked_job.state == ConstructionJob.State.QUEUED)
	assert(escrow.needs_recovery(held) and escrow.held_materials(held)[INGOT] == 3)
	assert(drone.begin_lost_delivery_return() and drone.advance_flight(10.0))
	assert(coordinator.reconcile() == 0 and charging.advance_charging(10.0) == 12.0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(escrow.held_count() == 1 and blocked_buffer.get_total_amount() == 0)
	print("PASS I: Lost receiver with blocked refund permits empty return but denies reuse")
	blocked_buffer.max_capacity = 6
	assert(escrow.recover_to(held) and not escrow.recover_to(held))
	assert(blocked_buffer.get_amount(INGOT) == 3 and escrow.held_count() == 0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 4)
	print("PASS J: Explicit exact escrow recovery permits rearm, not receiver release")
	var worker := _site(Vector3(6, 0, 0))
	assert(worker.job.authorize())
	var worker_job: ConstructionJob = worker.job
	var worker_buffer := _buffer(registry, worker, stock)
	assert(coordinator.track_site(worker, 7))
	var worker_id: int = _load_existing(drone, claims, worker)
	assert(worker_id > blocked_id)
	_deliver(drone, worker, registry, escrow)
	assert(coordinator.reconcile() == 0)
	assert(coordinator.admit_delivered_worker(worker, drone) and coordinator.reconcile() == 1)
	worker_job.advance(1.0)
	assert(worker_job.state == ConstructionJob.State.CONSTRUCTING and worker_job.get_progress() > 0.0)
	var progress: float = worker_job.get_progress()
	worker.free()
	assert(worker_job.state == ConstructionJob.State.PAUSED and worker_job.get_wait_reasons().has(&"workers"))
	worker_job.advance(10.0)
	assert(worker_job.get_progress() == progress)
	assert(worker_buffer.get_amount(INGOT) == 3 and escrow.held_count() == 0)
	assert(drone.advance_flight(10.0) and charging.advance_charging(10.0) == 12.0)
	assert(scheduler.has_drone_binding(drone) and not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(coordinator.reconcile() == 0 and not scheduler.has_drone_binding(drone))
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 5 and not worker_job.job_cancelled.is_connected(drone._on_site_ended))
	print("PASS K: Lost admitted worker revokes readiness, preserves refund and requires scheduler cleanup")
	var successor := _site(Vector3(6, 0, 0))
	assert(claims.reserve(drone, successor, INGOT, 3, 5) == 0)
	assert(successor.job.authorize())
	var successor_buffer := _buffer(registry, successor, stock)
	assert(coordinator.track_site(successor, 7))
	var successor_id: int = _load_existing(drone, claims, successor)
	assert(successor_id > worker_id and not claims.collect_pickup(worker_id, drone))
	_deliver(drone, successor, registry, escrow)
	assert(successor_buffer.get_amount(INGOT) == 3 and coordinator.reconcile() == 0)
	assert(coordinator.admit_delivered_worker(successor, drone) and coordinator.reconcile() == 1)
	successor.job.advance(10.0)
	assert(successor.job.state == ConstructionJob.State.COMPLETE)
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.advance_flight(10.0))
	assert(coordinator.reconcile() == 0 and escrow.held_count() == 0)
	assert(charging.advance_charging(10.0) == 12.0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 6)
	print("PASS L: Same drone completes a fresh authorized build after five lost assignments")
	assert(stock.get_amount(INGOT) == 3 and successor_buffer.get_total_amount() == 0)
	assert(stock.get_amount(INGOT) + delivered_buffer.get_amount(INGOT) + blocked_buffer.get_amount(INGOT) + worker_buffer.get_amount(INGOT) + 3 == 15)
	assert(claims.reservation_count() == 0 and returns.reservation_count() == 0 and escrow.held_count() == 0)
	assert(drone.cargo_amount() == 0 and not drone.grants_worker_readiness() and scheduler.get_active_count() == 0)
	assert(not drone.begin_lost_delivery_return() and not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS M: All original ingots accounted for; no stale authority or replay")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneHubCharging") == null and sandbox.get_node_or_null("PrototypeDroneHubCharging") == null)
	main.free()
	sandbox.free()
	print("PASS N: Normal scenes remain opt-out")
	print("ALL 14 E3D5C5X7C3 LOST SITE RECOVERY TESTS PASSED")
