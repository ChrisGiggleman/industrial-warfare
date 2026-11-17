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


func _loaded(claims: PrototypeDroneSupplierReservations, site: ConstructionSite) -> PrototypeConstructionWorkerDrone:
	var drone := _drone()
	drone.enable_isolated_cargo_pickup = true
	var id: int = claims.reserve(drone, site, INGOT, 3, 5)
	assert(id > 0)
	assert(claims.begin_pickup(id, drone, 2.0))
	assert(claims.advance_pickup(id, drone, 3.0))
	assert(claims.collect_pickup(id, drone))
	return drone


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
	add_child(claims)
	claims.enable_isolated_reservations = true
	assert(claims.configure(discovery))
	var dock := _storage(Vector3(3, 0, 0), 9)
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
	for service: Node in [registry, escrow, queue, scheduler, network, power, coordinator]:
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
	var site := _site(Vector3(6, 0, 0))
	var other := _site(Vector3(7, 0, 0))
	assert(site.job.authorize() and other.job.authorize())
	var buffer := _buffer(registry, site, stock)
	var other_buffer := _buffer(registry, other, stock)
	assert(coordinator.track_site(site, 7) and coordinator.track_site(other, 7))
	scheduler.enable_isolated_drone_presence = true
	var drone := _loaded(claims, site)
	drone.enable_isolated_cargo_delivery = true
	assert(not coordinator.admit_delivered_worker(site, drone))
	assert(coordinator.reconcile() == 0 and escrow.held_count() == 0)
	assert(drone.cargo_amount() == 3 and site.job.state == ConstructionJob.State.QUEUED)
	print("PASS A: Loaded drone cannot bypass the actual delivery")
	_deliver(drone, site, registry, escrow)
	assert(drone.cargo_amount() == 0 and buffer.get_amount(INGOT) == 3)
	assert(not coordinator.admit_delivered_worker(site, drone))
	assert(not scheduler.bind_site_drone(site, drone))
	print("PASS B: Delivered drone remains default-off and non-authoritative")
	drone.enable_isolated_delivered_worker = true
	assert(not coordinator.admit_delivered_worker(site, drone))
	assert(not coordinator.admit_delivered_worker(other, drone))
	assert(site.job.get_progress() == 0.0)
	print("PASS C: Exact original site and complete held escrow required")
	assert(coordinator.reconcile() == 0)
	var id: int = escrow.reservation_for(site)
	assert(id > 0 and escrow.matches_site_source_bill(site, buffer))
	assert(not escrow.matches_site_source_bill(site, stock))
	assert(site.job.state == ConstructionJob.State.QUEUED and scheduler.get_active_count() == 0)
	print("PASS D: Coordinator reserves only staged bill; no worker yet")
	scheduler.enable_isolated_drone_presence = false
	assert(not coordinator.admit_delivered_worker(site, drone))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DELIVERED)
	scheduler.enable_isolated_drone_presence = true
	var arrival: Vector3 = drone.global_position
	drone.global_position += Vector3(0.5, 0, 0)
	assert(not coordinator.admit_delivered_worker(site, drone))
	drone.global_position = arrival
	print("PASS E: Disabled scheduler and stale physical arrival refuse handoff")
	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0)
	var energy: float = drone.battery_units()
	assert(coordinator.admit_delivered_worker(site, drone))
	assert(drone.is_at_site() and drone.is_bound_to_site(site))
	assert(drone.global_position == arrival and drone.battery_units() == energy)
	assert(not coordinator.admit_delivered_worker(site, drone) and not coordinator.admit_delivered_worker(other, drone))
	assert(not drone.grants_worker_readiness() and coordinator.reconcile() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	print("PASS F: Same drone hands off without flight or readiness bypass")
	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING and scheduler.get_active_count() == 1)
	site.job.advance(3.0)
	assert(is_equal_approx(site.job.get_progress(), 0.3))
	print("PASS G: Existing finite power and worker gate starts timed construction")
	drone.enable_isolated_delivered_worker = false
	assert(coordinator.reconcile() == 0 and site.job.state == ConstructionJob.State.PAUSED)
	site.job.advance(100.0)
	assert(is_equal_approx(site.job.get_progress(), 0.3) and escrow.has_reservation(id))
	drone.enable_isolated_delivered_worker = true
	assert(coordinator.reconcile() == 1)
	print("PASS H: Handoff feature loss pauses and restoration resumes")
	registry.enable_isolated_site_registry = false
	assert(coordinator.reconcile() == 0 and site.job.state == ConstructionJob.State.PAUSED)
	assert(escrow.has_reservation(id))
	registry.enable_isolated_site_registry = true
	assert(coordinator.reconcile() == 1)
	print("PASS I: Receiver ownership loss revokes readiness without deleting escrow")
	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0 and site.job.state == ConstructionJob.State.PAUSED)
	site.job.advance(100.0)
	assert(is_equal_approx(site.job.get_progress(), 0.3))
	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	print("PASS J: Power outage preserves progress and exact held materials")
	# The second job delivers but cannot borrow the first job's active slot.
	var d2 := _loaded(claims, other)
	_deliver(d2, other, registry, escrow)
	d2.enable_isolated_delivered_worker = true
	assert(coordinator.reconcile() == 0)
	var id2: int = escrow.reservation_for(other)
	assert(id2 > id and coordinator.admit_delivered_worker(other, d2))
	assert(coordinator.reconcile() == 0 and scheduler.get_active_count() == 1)
	assert(other.job.state == ConstructionJob.State.QUEUED)
	print("PASS K: Two delivered drones cannot exceed finite power or worker slots")
	site.job.advance(7.0)
	assert(site.job.state == ConstructionJob.State.COMPLETE and site.is_completed())
	assert(not escrow.has_reservation(id))
	assert(coordinator.reconcile() == 1)
	assert(other.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1)
	print("PASS L: Completion commits once and releases slot to next owned job")
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		drone.advance_flight(0.1)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.global_position == Vector3(0, 2, 0) and is_equal_approx(drone.battery_units(), 28.0))
	print("PASS M: Completed worker physically returns with metered battery")
	other.job.advance(2.0)
	assert(other.job.cancel())
	assert(not escrow.has_reservation(id2) and other_buffer.get_amount(INGOT) == 3)
	assert(coordinator.reconcile() == 0 and scheduler.get_active_count() == 0)
	assert(d2.advance_flight(10.0) and d2.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(stock.get_amount(INGOT) + other_buffer.get_amount(INGOT) + 3 == 9)
	assert(drone.cargo_amount() == 0 and d2.cargo_amount() == 0)
	print("PASS N: Canceled work refunds its own staging; both trips conserve materials")
	drone.enable_isolated_reuse = true
	assert(drone.charge_at_home(10.0, true))
	assert(not drone.release_docked_assignment(escrow, scheduler))
	print("PASS O: Delivered worker reuse stays quarantined until x7")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneSupplierReservations") == null and sandbox.get_node_or_null("PrototypeDroneSupplierReservations") == null)
	main.free()
	sandbox.free()
	print("PASS P: Normal scenes remain opt-out")
	print("ALL 16 E3D5C5X5C DELIVERED DRONE WORKER INTEGRATION TESTS PASSED")
