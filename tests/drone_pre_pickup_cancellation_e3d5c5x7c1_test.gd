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
	assert(not drone.enable_isolated_pre_pickup_rearm)
	drone.enable_isolated_cargo_reuse = true
	var first := _site(Vector3(6, 0, 0))
	assert(first.job.authorize())
	var first_buffer := _buffer(registry, first, stock)
	assert(coordinator.track_site(first, 7))
	var id1: int = claims.reserve(drone, first, INGOT, 3, 5)
	assert(id1 > 0 and stock.get_reserved_amount(INGOT) == 3)
	assert(first.job.cancel())
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(stock.get_amount(INGOT) == 15 and first_buffer.get_total_amount() == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 0 and drone.battery_units() == 40.0)
	assert(coordinator.reconcile() == 0)
	print("PASS A: Forecast-only cancellation releases stock without flight or rearm")
	drone.enable_isolated_pre_pickup_rearm = true
	var launch := _site(Vector3(6, 0, 0))
	assert(launch.job.authorize())
	var launch_buffer := _buffer(registry, launch, stock)
	assert(coordinator.track_site(launch, 7))
	var id2: int = claims.reserve(drone, launch, INGOT, 3, 5)
	assert(id2 > id1 and claims.begin_pickup(id2, drone, 2.0))
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(launch.job.cancel())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(not claims.collect_pickup(id2, drone))
	assert(stock.get_amount(INGOT) == 15 and launch_buffer.get_total_amount() == 0)
	assert(coordinator.reconcile() == 0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 1 and drone.battery_units() == 40.0)
	print("PASS B: Cancel immediately after launch at home; explicit exact-once rearm")
	var mid := _site(Vector3(6, 0, 0))
	assert(mid.job.authorize())
	var mid_buffer := _buffer(registry, mid, stock)
	assert(coordinator.track_site(mid, 7))
	var id3: int = claims.reserve(drone, mid, INGOT, 3, 5)
	assert(id3 > id2 and claims.begin_pickup(id3, drone, 2.0))
	assert(claims.advance_pickup(id3, drone, 0.75))
	assert(is_equal_approx(drone.battery_units(), 38.5))
	assert(mid.job.cancel())
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(stock.get_amount(INGOT) == 15 and drone.cargo_amount() == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(not claims.advance_pickup(id3, drone, 1.0) and not claims.collect_pickup(id3, drone))
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS C: Midflight cancellation releases claim but preserves physical return")
	assert(drone.advance_flight(0.5))
	assert(is_equal_approx(drone.global_position.x, 0.5) and is_equal_approx(drone.battery_units(), 37.5))
	assert(not drone.charge_at_home(10.0, true) and charging.advance_charging(1.0) == 0.0)
	assert(drone.advance_flight(1.0))
	assert(drone.global_position == Vector3(0, 2, 0) and is_equal_approx(drone.battery_units(), 37.0))
	assert(coordinator.reconcile() == 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS D: Return is battery-metered; airborne or depleted rearm refused")
	assert(hub.set_generator_enabled(false))
	assert(charging.advance_charging(10.0) == 0.0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(hub.set_generator_enabled(true))
	assert(is_equal_approx(charging.advance_charging(10.0), 3.0))
	drone.enable_isolated_pre_pickup_rearm = false
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	drone.enable_isolated_pre_pickup_rearm = true
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 2 and mid_buffer.get_total_amount() == 0)
	print("PASS E: Verified full charge and explicit opt-in required after empty return")
	var at_dock := _site(Vector3(6, 0, 0))
	assert(at_dock.job.authorize())
	var dock_buffer := _buffer(registry, at_dock, stock)
	assert(coordinator.track_site(at_dock, 7))
	var id4: int = claims.reserve(drone, at_dock, INGOT, 3, 5)
	assert(id4 > id3 and claims.begin_pickup(id4, drone, 2.0))
	assert(claims.advance_pickup(id4, drone, 10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP)
	assert(drone.battery_units() == 37.0 and stock.get_amount(INGOT) == 15)
	drone.enable_isolated_pre_pickup_rearm = false
	assert(at_dock.job.cancel())
	assert(not claims.collect_pickup(id4, drone))
	assert(drone.cargo_amount() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(drone.advance_flight(10.0))
	assert(drone.battery_units() == 34.0 and stock.get_amount(INGOT) == 15)
	assert(coordinator.reconcile() == 0)
	assert(charging.advance_charging(10.0) == 6.0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	drone.enable_isolated_pre_pickup_rearm = true
	print("PASS F: At-dock cancellation before debit; feature loss retains terminal provenance")
	var blocker := returns.reserve(drone, INGOT, 1)
	assert(blocker > 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(returns.release(blocker, drone))
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 3 and dock_buffer.get_total_amount() == 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS G: Outstanding return claim blocks rearm; no duplicate release")
	var legacy := _drone()
	legacy.enable_isolated_cargo_pickup = true
	legacy.enable_isolated_cargo_reuse = true
	legacy.enable_isolated_finite_charging = true
	assert(charging.register_drone(legacy))
	var legacy_site := _site(Vector3(6, 0, 0))
	assert(legacy_site.job.authorize())
	var legacy_id: int = claims.reserve(legacy, legacy_site, INGOT, 3, 5)
	assert(legacy_id > id4 and claims.begin_pickup(legacy_id, legacy, 2.0))
	assert(legacy_site.job.cancel())
	legacy.enable_isolated_pre_pickup_rearm = true
	assert(not legacy.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS H: Enabling pre-pickup rearm after cancellation cannot fabricate provenance")
	var invalid := _drone()
	invalid.enable_isolated_cargo_pickup = true
	invalid.enable_isolated_cargo_reuse = true
	invalid.enable_isolated_pre_pickup_rearm = true
	invalid.enable_isolated_finite_charging = true
	assert(charging.register_drone(invalid))
	var healthy := _site(Vector3(6, 0, 0))
	assert(healthy.job.authorize())
	var invalid_id: int = claims.reserve(invalid, healthy, INGOT, 3, 5)
	assert(invalid_id > legacy_id and claims.begin_pickup(invalid_id, invalid, 2.0))
	assert(claims.release(invalid_id, invalid))
	assert(healthy.job.state == ConstructionJob.State.QUEUED)
	assert(not invalid.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(healthy.job.cancel())
	assert(not invalid.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS I: Nonterminal claim release and later unrelated cancellation cannot rearm")
	var successor := _site(Vector3(6, 0, 0))
	assert(claims.reserve(drone, successor, INGOT, 3, 5) == 0)
	assert(successor.job.authorize())
	var successor_buffer := _buffer(registry, successor, stock)
	assert(coordinator.track_site(successor, 7))
	var id5: int = _load_existing(drone, claims, successor)
	assert(id5 > invalid_id and stock.get_amount(INGOT) == 12)
	assert(not claims.collect_pickup(id4, drone))
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
	assert(drone.completed_rearms() == 4)
	print("PASS J: Same drone completes fresh authorized build after three pre-pickup cancellations")
	assert(stock.get_amount(INGOT) + 3 == 15)
	assert(claims.reservation_count() == 0 and returns.reservation_count() == 0 and escrow.held_count() == 0)
	assert(drone.cargo_amount() == 0 and not drone.grants_worker_readiness())
	assert(first_buffer.get_total_amount() == 0 and launch_buffer.get_total_amount() == 0 and mid_buffer.get_total_amount() == 0 and dock_buffer.get_total_amount() == 0)
	print("PASS K: All fifteen original ingots accounted for; no canceled stock debit or worker bypass")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneHubCharging") == null and sandbox.get_node_or_null("PrototypeDroneHubCharging") == null)
	main.free()
	sandbox.free()
	print("PASS L: Normal scenes remain opt-out")
	print("ALL 12 E3D5C5X7C1 PRE-PICKUP CANCELLATION TESTS PASSED")
