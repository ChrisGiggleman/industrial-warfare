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
	assert(not drone.enable_isolated_post_delivery_rearm)
	drone.enable_isolated_cargo_reuse = true
	assert(not drone.begin_cancelled_delivery_return())
	var legacy := _drone()
	legacy.enable_isolated_cargo_pickup = true
	legacy.enable_isolated_cargo_reuse = true
	var legacy_site := _site(Vector3(6, 0, 0))
	assert(legacy_site.job.authorize())
	var legacy_buffer := _buffer(registry, legacy_site, stock)
	_load_existing(legacy, claims, legacy_site)
	_deliver(legacy, legacy_site, registry, escrow)
	assert(legacy_site.job.cancel())
	assert(not legacy.begin_cancelled_delivery_return())
	legacy.enable_isolated_post_delivery_rearm = true
	assert(not legacy.begin_cancelled_delivery_return())
	assert(legacy.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DELIVERED and legacy_buffer.get_amount(INGOT) == 3)
	print("PASS A: Default-off and late opt-in cannot create terminal delivery provenance")
	drone.enable_isolated_post_delivery_rearm = true
	var first := _site(Vector3(6, 0, 0))
	assert(first.job.authorize())
	var first_buffer := _buffer(registry, first, stock)
	assert(coordinator.track_site(first, 7))
	var id1: int = _load_existing(drone, claims, first)
	assert(not drone.begin_cancelled_delivery_return() and drone.cargo_amount() == 3)
	_deliver(drone, first, registry, escrow)
	assert(not drone.begin_cancelled_delivery_return())
	assert(first.job.state == ConstructionJob.State.QUEUED and first.job.get_progress() == 0.0)
	assert(not scheduler.has_drone_binding(drone) and first_buffer.get_amount(INGOT) == 3)
	print("PASS B: Loaded or healthy delivered job cannot enter canceled return")
	var first_ref: WeakRef = weakref(first)
	var first_rev: int = first_buffer.get_mutation_revision()
	var stock_rev: int = stock.get_mutation_revision()
	var locked_count: int = registry.claim_count()
	assert(first.job.cancel())
	assert(escrow.held_count() == 0)
	drone.enable_isolated_post_delivery_rearm = false
	assert(drone.begin_cancelled_delivery_return())
	assert(not drone.begin_cancelled_delivery_return() and not drone.unload_delivery())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(drone.cargo_amount() == 0 and drone.cargo_item() == null)
	assert(not returns.advance_cancelled_recovery(drone, 1.0) and returns.reservation_count() == 0)
	assert(first_buffer.get_mutation_revision() == first_rev and stock.get_mutation_revision() == stock_rev)
	assert(first_buffer.get_amount(INGOT) == 3 and registry.claim_count() == locked_count)
	print("PASS C: Terminal cancellation without escrow retains owned stock and never creates cargo")
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.battery_units() == 34.0 and drone.advance_flight(1.0))
	assert(drone.global_position.is_equal_approx(Vector3(4, 2, 0)) and drone.battery_units() == 32.0)
	assert(charging.advance_charging(1.0) == 0.0)
	assert(drone.advance_flight(10.0))
	assert(drone.global_position == Vector3(0, 2, 0) and drone.battery_units() == 28.0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(coordinator.reconcile() == 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS D: Physical metered empty return, no airborne charging or depleted rearm")
	assert(charging.advance_charging(10.0) == 12.0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	drone.enable_isolated_post_delivery_rearm = true
	registry.enable_isolated_site_registry = false
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	registry.enable_isolated_site_registry = true
	assert(registry.has_locked_delivery_inventory(first_ref, first_buffer))
	assert(not registry.has_locked_delivery_inventory(weakref(legacy_site), first_buffer))
	assert(registry.claim_count() == locked_count and first_buffer.get_amount(INGOT) == 3)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 1 and not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS E: Current opt-in, live original ownership and full charge gate exact-once rearm")
	var second := _site(Vector3(6, 0, 0))
	assert(second.job.authorize())
	var second_buffer := _buffer(registry, second, stock)
	assert(coordinator.track_site(second, 7))
	var id2: int = _load_existing(drone, claims, second)
	assert(id2 > id1)
	_deliver(drone, second, registry, escrow)
	assert(coordinator.reconcile() == 0 and second.job.state == ConstructionJob.State.QUEUED)
	var held: int = escrow.reservation_for(second)
	assert(held > 0 and escrow.matches_site_source_bill(second, second_buffer))
	assert(second_buffer.get_amount(INGOT) == 0 and escrow.held_materials(held)[INGOT] == 3)
	assert(not scheduler.has_drone_binding(drone) and not drone.begin_cancelled_delivery_return())
	print("PASS F: Full escrow alone does not admit worker or permit healthy return")
	assert(second.job.cancel())
	assert(not escrow.has_reservation(held) and second_buffer.get_amount(INGOT) == 3)
	assert(not coordinator.admit_delivered_worker(second, drone))
	var second_rev: int = second_buffer.get_mutation_revision()
	assert(drone.begin_cancelled_delivery_return())
	assert(drone.advance_flight(10.0) and coordinator.reconcile() == 0)
	assert(second_buffer.get_mutation_revision() == second_rev)
	assert(charging.advance_charging(10.0) == 12.0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 2 and second_buffer.get_amount(INGOT) == 3)
	print("PASS G: Cancellation after escrow but before admission refunds exactly once")
	var blocked := _site(Vector3(6, 0, 0))
	assert(blocked.job.authorize())
	var blocked_buffer := _buffer(registry, blocked, stock)
	assert(coordinator.track_site(blocked, 7))
	var id3: int = _load_existing(drone, claims, blocked)
	assert(id3 > id2)
	_deliver(drone, blocked, registry, escrow)
	assert(coordinator.reconcile() == 0)
	var held3: int = escrow.reservation_for(blocked)
	assert(held3 > held and escrow.held_materials(held3)[INGOT] == 3)
	blocked_buffer.max_capacity = 2
	assert(blocked.job.cancel())
	assert(escrow.needs_recovery(held3) and escrow.held_materials(held3)[INGOT] == 3)
	assert(blocked_buffer.get_total_amount() == 0)
	assert(drone.begin_cancelled_delivery_return() and drone.advance_flight(10.0))
	assert(coordinator.reconcile() == 0 and charging.advance_charging(10.0) == 12.0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(escrow.held_count() == 1 and not escrow.recover_to(held3))
	print("PASS H: Blocked refund remains in escrow; empty return allowed but rearm denied")
	blocked_buffer.max_capacity = 6
	assert(escrow.recover_to(held3) and not escrow.recover_to(held3))
	assert(blocked_buffer.get_amount(INGOT) == 3 and escrow.held_count() == 0)
	var before_rearm: int = registry.claim_count()
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 3 and registry.claim_count() == before_rearm)
	print("PASS I: Explicit escrow recovery enables rearm without releasing receiver ownership")
	var successor := _site(Vector3(6, 0, 0))
	assert(claims.reserve(drone, successor, INGOT, 3, 5) == 0)
	assert(successor.job.authorize())
	var successor_buffer := _buffer(registry, successor, stock)
	assert(coordinator.track_site(successor, 7))
	var id4: int = _load_existing(drone, claims, successor)
	assert(id4 > id3 and not claims.collect_pickup(id3, drone))
	_deliver(drone, successor, registry, escrow)
	assert(successor_buffer.get_amount(INGOT) == 3 and coordinator.reconcile() == 0)
	assert(coordinator.admit_delivered_worker(successor, drone) and coordinator.reconcile() == 1)
	assert(not drone.begin_cancelled_delivery_return())
	successor.job.advance(10.0)
	assert(successor.job.state == ConstructionJob.State.COMPLETE)
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.advance_flight(10.0))
	assert(coordinator.reconcile() == 0 and escrow.held_count() == 0)
	assert(charging.advance_charging(10.0) == 12.0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 4)
	print("PASS J: Fresh authorized build uses original admission gates after three canceled deliveries")
	assert(stock.get_amount(INGOT) == 0 and successor_buffer.get_total_amount() == 0)
	assert(legacy_buffer.get_amount(INGOT) + first_buffer.get_amount(INGOT) + second_buffer.get_amount(INGOT) + blocked_buffer.get_amount(INGOT) + 3 == 15)
	assert(claims.reservation_count() == 0 and returns.reservation_count() == 0 and escrow.held_count() == 0)
	assert(drone.cargo_amount() == 0 and not drone.grants_worker_readiness() and scheduler.get_active_count() == 0)
	print("PASS K: All fifteen ingots conserved and no remaining worker or cargo claims")
	assert(not drone.begin_cancelled_delivery_return() and not drone.unload_delivery())
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(first_buffer.get_amount(INGOT) == 3 and second_buffer.get_amount(INGOT) == 3 and blocked_buffer.get_amount(INGOT) == 3)
	print("PASS L: Replayed cancellation, unload and rearm cannot alter stock")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneHubCharging") == null and sandbox.get_node_or_null("PrototypeDroneHubCharging") == null)
	main.free()
	sandbox.free()
	print("PASS M: Normal scenes remain opt-out")
	print("ALL 13 E3D5C5X7C2 POST-DELIVERY CANCELLATION TESTS PASSED")
