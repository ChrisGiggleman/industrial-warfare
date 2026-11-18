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
	assert(not drone.enable_isolated_cargo_reuse)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS A: Cargo rearm defaults off and idle drone has no terminal assignment")
	var first := _site(Vector3(6, 0, 0))
	assert(first.job.authorize())
	var first_job: ConstructionJob = first.job
	var first_buffer := _buffer(registry, first, stock)
	assert(coordinator.track_site(first, 7))
	var id1: int = _load_existing(drone, claims, first)
	assert(drone.cargo_amount() == 3 and stock.get_amount(INGOT) == 12)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS B: A loaded active assignment cannot rearm")
	_deliver(drone, first, registry, escrow)
	assert(first_buffer.get_amount(INGOT) == 3)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(coordinator.reconcile() == 0)
	var held: int = escrow.reservation_for(first)
	assert(held > 0 and coordinator.admit_delivered_worker(first, drone))
	assert(coordinator.reconcile() == 1)
	first.job.advance(10.0)
	assert(first_job.state == ConstructionJob.State.COMPLETE and not escrow.has_reservation(held))
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(is_equal_approx(drone.battery_units(), 28.0))
	print("PASS C: First delivery and construction commit once; physical home return")
	drone.enable_isolated_cargo_reuse = true
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(charging.advance_charging(10.0) == 12.0)
	assert(scheduler.has_drone_binding(drone))
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(coordinator.reconcile() == 0 and not scheduler.has_drone_binding(drone))
	print("PASS D: Depleted battery and stale scheduler each block rearm")
	drone.enable_isolated_cargo_reuse = false
	drone.enable_isolated_reuse = true
	assert(not drone.release_docked_assignment(escrow, scheduler))
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	drone.enable_isolated_cargo_reuse = true
	print("PASS E: Legacy rearm and default-off cargo rearm remain denied")
	var duplicate := BlueprintConstructionMaterialEscrow.new()
	add_child(duplicate)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, duplicate, scheduler))
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	duplicate.free()
	charging.enable_isolated_charging = false
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	charging.enable_isolated_charging = true
	drone.global_position.x = 0.25
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	drone.global_position.x = 0.0
	print("PASS F: Exact live services and physical Hub registration required")
	var second := _site(Vector3(7, 0, 0))
	assert(second.job.authorize())
	var second_buffer := _buffer(registry, second, stock)
	var extra_drone := _drone()
	var blocked: int = claims.reserve(extra_drone, second, INGOT, 3, 5)
	assert(blocked > id1)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(claims.release(blocked, extra_drone))
	var return_id: int = returns.reserve(drone, INGOT, 1)
	assert(return_id > 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(returns.release(return_id, drone))
	print("PASS G: Outstanding supplier or return claims block rearm without releasing them")
	assert(stock.transfer_to(second_buffer, INGOT, 3) == 3)
	var second_hold: int = registry.reserve_for_site(second, escrow)
	assert(second_hold > held and escrow.held_count() == 1)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(second.job.cancel() and escrow.held_count() == 0)
	# The separate canceled staging remains owned; test-only transfer counts its stock.
	assert(second_buffer.transfer_to(stock, INGOT, 3) == 3 and stock.get_amount(INGOT) == 12)
	print("PASS H: Outstanding escrow blocks reuse until explicitly settled")
	var registry_count: int = registry.claim_count()
	var rev: int = stock.get_mutation_revision()
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE and drone.completed_rearms() == 1)
	assert(not first_job.job_cancelled.is_connected(drone._on_site_ended))
	if is_instance_valid(first):
		assert(not first.tree_exiting.is_connected(drone._on_site_ended))
	assert(registry.claim_count() == registry_count and stock.get_mutation_revision() == rev)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	print("PASS I: Exact-once rearm clears old callbacks, not material ownership")
	var cancelled := _site(Vector3(7, 0, 0))
	assert(claims.reserve(drone, cancelled, INGOT, 3, 5) == 0)
	assert(cancelled.job.authorize())
	var cancelled_buffer := _buffer(registry, cancelled, stock)
	assert(coordinator.track_site(cancelled, 7))
	assert(not drone.assign_to_site(cancelled, Vector3(0, 2, 0), 2.0, 2.0))
	var id2: int = _load_existing(drone, claims, cancelled)
	assert(id2 > id1 and drone.cargo_amount() == 3)
	assert(not claims.collect_pickup(id1, drone))
	assert(not drone.begin_delivery(second, registry, escrow))
	print("PASS J: New authorization and fresh pickup required; stale claim and legacy bypass denied")
	assert(drone.begin_delivery(cancelled, registry, escrow))
	assert(drone.advance_delivery(1.0))
	assert(cancelled.job.cancel())
	dock.allow_returns = false
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.cargo_amount() == 3 and not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	dock.allow_returns = true
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(returns.advance_cancelled_recovery(drone, 10.0))
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.cargo_amount() == 0 and stock.get_amount(INGOT) == 12)
	assert(cancelled_buffer.get_total_amount() == 0)
	print("PASS K: Canceled successor retains cargo until exact physical recovery")
	assert(returns.advance_cancelled_recovery(drone, 10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(coordinator.reconcile() == 0)
	assert(not drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(not drone.charge_at_home(100.0, true))
	assert(charging.advance_charging(10.0) > 0.0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 2)
	print("PASS L: Recovered canceled cargo worker can rearm only after verified full recharge")
	var third := _site(Vector3(8, 0, 0))
	assert(third.job.authorize())
	var third_buffer := _buffer(registry, third, stock)
	assert(coordinator.track_site(third, 7))
	var id3: int = _load_existing(drone, claims, third)
	assert(id3 > id2 and drone.cargo_amount() == 3)
	_deliver(drone, third, registry, escrow)
	assert(third_buffer.get_amount(INGOT) == 3)
	assert(coordinator.reconcile() == 0)
	assert(coordinator.admit_delivered_worker(third, drone))
	assert(coordinator.reconcile() == 1)
	third.job.advance(10.0)
	assert(third.job.state == ConstructionJob.State.COMPLETE)
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.advance_flight(10.0))
	assert(coordinator.reconcile() == 0 and escrow.held_count() == 0)
	assert(stock.get_amount(INGOT) == 9 and drone.cargo_amount() == 0)
	assert(charging.advance_charging(10.0) == 16.0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 3)
	print("PASS M: Same drone completes another distinct build through all original gates")
	var fourth := _site(Vector3(6, 0, 0))
	assert(fourth.job.authorize())
	var fourth_buffer := _buffer(registry, fourth, stock)
	assert(coordinator.track_site(fourth, 7))
	_load_existing(drone, claims, fourth)
	_deliver(drone, fourth, registry, escrow)
	assert(coordinator.reconcile() == 0)
	assert(coordinator.admit_delivered_worker(fourth, drone) and coordinator.reconcile() == 1)
	fourth.job.advance(2.0)
	assert(fourth.job.cancel() and fourth_buffer.get_amount(INGOT) == 3)
	assert(coordinator.reconcile() == 0)
	assert(drone.advance_flight(10.0))
	assert(charging.advance_charging(10.0) == 12.0)
	assert(drone.release_docked_cargo_assignment(claims, returns, coordinator, escrow, scheduler))
	assert(drone.completed_rearms() == 4 and fourth_buffer.get_amount(INGOT) == 3)
	assert(stock.get_amount(INGOT) + fourth_buffer.get_amount(INGOT) + 6 == 15)
	assert(claims.reservation_count() == 0 and returns.reservation_count() == 0 and escrow.held_count() == 0)
	print("PASS N: Cancellation after work refunds owned staging; two builds and all stock conserved")
	drone.enable_isolated_cargo_reuse = false
	var fifth := _site(Vector3(6, 0, 0))
	assert(fifth.job.authorize())
	var id5: int = claims.reserve(drone, fifth, INGOT, 3, 5)
	assert(id5 > 0 and not claims.begin_pickup(id5, drone, 2.0))
	assert(claims.release(id5, drone))
	assert(not drone.assign_to_site(fifth, Vector3(0, 2, 0), 2.0, 2.0))
	assert(stock.get_amount(INGOT) == 6 and drone.cargo_amount() == 0)
	print("PASS O: Feature loss after rearm cannot reopen legacy dispatch or pick up cargo")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneHubCharging") == null and sandbox.get_node_or_null("PrototypeDroneHubCharging") == null)
	main.free()
	sandbox.free()
	print("PASS P: Normal scenes remain opt-out")
	print("ALL 16 E3D5C5X7B CARGO WORKER REUSE TESTS PASSED")
