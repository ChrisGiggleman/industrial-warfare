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



# Controlled fault injection: normal exact reservation, refused launch.
class RejectingSupplier extends PrototypeDroneSupplierReservations:
	var refuse_launch: bool = false
	var block_after_reserve: InventoryComponent

	func reserve(drone: PrototypeConstructionWorkerDrone, site: ConstructionSite, item: ItemDefinition, amount: int, cargo_capacity: int) -> int:
		var id: int = super.reserve(drone, site, item, amount, cargo_capacity)
		if id > 0 and is_instance_valid(block_after_reserve):
			block_after_reserve.max_capacity = 2
		return id

	func begin_pickup(id: int, drone: PrototypeConstructionWorkerDrone, speed: float) -> bool:
		if refuse_launch:
			return false
		return super.begin_pickup(id, drone, speed)


func _checks() -> void:
	var discovery := PrototypeDroneStorageDiscovery.new()
	var claims := RejectingSupplier.new()
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
	assert(network.register_node(hub.get_power_node()))
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
	assert(not dispatch.enable_isolated_dispatch)
	assert(not dispatch.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	assert(dispatch.dispatch_next()["reason"] == &"disabled_or_unconfigured")
	dispatch.enable_isolated_dispatch = true
	assert(not dispatch.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 0.0))
	var wrong_queue := BlueprintConstructionPriorityQueue.new()
	add_child(wrong_queue)
	assert(not dispatch.configure(drone, wrong_queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	wrong_queue.free()
	assert(dispatch.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	assert(not dispatch.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	print("PASS A: Default-off, invalid configuration and duplicate configure rejected")
	var planned := _site(Vector3(5, 0, 0))
	assert(planned.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(not queue.register_queued_site(planned))
	assert(dispatch.dispatch_next()["reason"] == &"no_eligible_site")
	assert(planned.job.state == ConstructionJob.State.PLANNED and claims.reservation_count() == 0)
	print("PASS B: Planned High job never auto-authorized or reserved")
	var low := _site(Vector3(6, 0, 0))
	assert(low.job.set_priority(ConstructionJob.Priority.LOW) and low.job.authorize())
	var low_buffer := _buffer(registry, low, stock)
	assert(coordinator.track_site(low, 7))
	assert(dispatch.inspect_next()["site"] == low)
	var normal := _site(Vector3(7, 0, 0))
	assert(normal.job.authorize())
	var normal_buffer := _buffer(registry, normal, stock)
	assert(coordinator.track_site(normal, 7))
	assert(dispatch.inspect_next()["site"] == normal)
	print("PASS C: Normal wins over earlier Low using authoritative queue")
	var far := _site(Vector3(100, 0, 0))
	assert(far.job.set_priority(ConstructionJob.Priority.HIGH) and far.job.authorize())
	var far_buffer := _buffer(registry, far, stock)
	assert(coordinator.track_site(far, 7))
	var blocked := _site(Vector3(6, 0, 0))
	assert(blocked.job.set_priority(ConstructionJob.Priority.HIGH) and blocked.job.authorize())
	var blocked_buffer := _buffer(registry, blocked, stock)
	assert(coordinator.track_site(blocked, 7))
	blocked_buffer.max_capacity = 2
	var untracked := _site(Vector3(6, 0, 0))
	assert(untracked.job.set_priority(ConstructionJob.Priority.HIGH) and untracked.job.authorize())
	var untracked_buffer := _buffer(registry, untracked, stock)
	assert(queue.register_queued_site(untracked))
	var skipped: Array = dispatch.inspect_next()["skipped"]
	assert(skipped.size() == 3)
	assert(skipped[0]["site_id"] == far.get_instance_id() and skipped[0]["reason"] == &"stock_dock_or_route_energy")
	assert(skipped[1]["site_id"] == blocked.get_instance_id() and skipped[1]["reason"] == &"receiver_capacity")
	assert(skipped[2]["site_id"] == untracked.get_instance_id() and skipped[2]["reason"] == &"untracked_or_readiness")
	assert(dispatch.inspect_next()["site"] == normal)
	print("PASS D: Ineligible High jobs skipped with ordered energy, receiver and tracking reasons")
	var first := _site(Vector3(8, 0, 0))
	assert(first.job.set_priority(ConstructionJob.Priority.HIGH) and first.job.authorize())
	var first_buffer := _buffer(registry, first, stock)
	assert(coordinator.track_site(first, 7))
	var second := _site(Vector3(4, 0, 0))
	assert(second.job.set_priority(ConstructionJob.Priority.HIGH) and second.job.authorize())
	var second_buffer := _buffer(registry, second, stock)
	assert(coordinator.track_site(second, 7))
	assert(dispatch.inspect_next()["site"] == first)
	assert(first.job.set_priority(ConstructionJob.Priority.LOW))
	assert(dispatch.inspect_next()["site"] == second)
	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(dispatch.inspect_next()["site"] == first)
	print("PASS E: High wins over Normal and Low; FIFO beats shorter route; reprioritization is live")
	var revision: int = stock.get_mutation_revision()
	dock.allow_pickup = false
	assert(dispatch.dispatch_next()["reason"] == &"no_eligible_site")
	assert(claims.reservation_count() == 0 and stock.get_mutation_revision() == revision)
	dock.allow_pickup = true
	assert(dock.minimum_retained == 0)
	dock.minimum_retained = 14
	assert(dispatch.dispatch_next()["reason"] == &"no_eligible_site")
	assert(stock.get_amount(INGOT) == 15 and stock.get_reserved_amount(INGOT) == 0)
	dock.minimum_retained = 0
	print("PASS F: Unavailable dock or retained stock cannot launch")
	var foreign := BlueprintConstructionPriorityQueue.new()
	add_child(foreign)
	var other := PrototypeDroneAutomaticDispatch.new()
	add_child(other)
	other.enable_isolated_dispatch = true
	assert(not other.configure(drone, foreign, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	assert(not other.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, claims, returns, 5, 2.0))
	var extra := _drone()
	assert(dispatch.dispatch_next()["reason"] == &"scope_not_serial")
	extra.free()
	foreign.free()
	other.free()
	print("PASS G: Foreign queue, duplicate dispatcher and multiple drones denied")
	var manual_id: int = claims.reserve(drone, low, INGOT, 3, 5)
	assert(manual_id > 0 and stock.get_reserved_amount(INGOT) == 3)
	assert(dispatch.dispatch_next()["reason"] == &"unresolved_assignment")
	assert(claims.observe(manual_id)["valid"] and claims.reservation_count() == 1)
	assert(claims.release(manual_id, drone))
	print("PASS H: Existing manual claim is protected, not reconciled or preempted")
	drone.enable_isolated_finite_charging = false
	assert(dispatch.dispatch_next()["reason"] == &"home_charge_or_recovery_gate")
	drone.enable_isolated_finite_charging = true
	registry.enable_isolated_site_registry = false
	assert(dispatch.dispatch_next()["reason"] == &"service_identity")
	registry.enable_isolated_site_registry = true
	dispatch.enable_isolated_dispatch = false
	assert(dispatch.dispatch_next()["reason"] == &"disabled_or_unconfigured")
	dispatch.enable_isolated_dispatch = true
	print("PASS I: Current feature flags and original service authority rechecked")
	claims.block_after_reserve = first_buffer
	var stale := dispatch.dispatch_next()
	assert(stale["reason"] == &"claim_revalidation_failed" and stale["site"] == first)
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	claims.block_after_reserve = null
	first_buffer.max_capacity = 6
	claims.refuse_launch = true
	var failed := dispatch.dispatch_next()
	assert(failed["reason"] == &"launch_failed" and failed["site"] == first)
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE and stock.get_amount(INGOT) == 15 and stock.get_mutation_revision() == revision)
	assert(first.job.state == ConstructionJob.State.QUEUED and first.job.get_progress() == 0.0)
	claims.refuse_launch = false
	print("PASS J: Changed receiver and refused launch roll back exact claim without debit or second job")
	var launched := dispatch.dispatch_next()
	assert(launched["reason"] == &"" and launched["site"] == first and launched["job"] == first.job)
	var id: int = launched["claim_id"]
	var claim := claims.observe(id)
	assert(id > manual_id and bool(claim["valid"]) and claim["dock"] == dock and claim["item"] == INGOT and claim["amount"] == 3)
	assert(claims.reservation_count() == 1 and stock.get_reserved_amount(INGOT) == 3 and stock.get_amount(INGOT) == 15)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.PICKUP_OUTBOUND and drone.cargo_amount() == 0)
	assert(drone.global_position.is_equal_approx(Vector3(0, 2, 0)) and drone.battery_units() == 40.0)
	print("PASS K: Selected exact source claim and guarded launch, no remote pickup or flight tick")
	assert(second.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.set_priority(ConstructionJob.Priority.LOW))
	assert(dispatch.dispatch_next()["reason"] == &"drone_busy")
	assert(claims.reservation_count() == 1 and claims.observe(id)["valid"])
	assert(escrow.held_count() == 0 and scheduler.get_active_count() == 0 and not drone.grants_worker_readiness())
	assert(first.job.get_progress() == 0.0 and first.job.get_wait_reasons().has(&"materials"))
	for buffer: InventoryComponent in [low_buffer, normal_buffer, far_buffer, blocked_buffer, untracked_buffer, first_buffer, second_buffer]:
		assert(buffer.get_total_amount() == 0)
	assert(stock.get_mutation_revision() == revision and planned.job.state == ConstructionJob.State.PLANNED)
	print("PASS L: Active launch cannot be preempted; no staging, escrow, worker or timer bypass")
	assert(first.job.cancel())
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0 and stock.get_amount(INGOT) == 15)
	assert(drone.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(dispatch.dispatch_next()["reason"] == &"drone_busy")
	print("PASS M: Existing cancellation releases exact claim; no automatic rearm or next launch")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneAutomaticDispatch") == null and sandbox.get_node_or_null("PrototypeDroneAutomaticDispatch") == null)
	main.free()
	sandbox.free()
	print("PASS N: Ordinary scenes remain opt-out")
	print("ALL 14 E3D5C5X8A AUTOMATIC DISPATCH TESTS PASSED")
