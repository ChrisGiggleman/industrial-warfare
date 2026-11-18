extends Node
class_name PrototypeDroneAutomaticDispatch

# E3d5c5x8a: explicit, serialized automatic choice and pickup launch only.
# No process loop, player authorization, movement, cargo debit, worker
# admission, readiness mutation, charge, rearm or lifecycle ticking.
@export var enable_isolated_dispatch: bool = false
const SCOPE_KEY: StringName = &"isolated_drone_automatic_dispatch_owner"
var _drone: PrototypeConstructionWorkerDrone
var _queue: BlueprintConstructionPriorityQueue
var _scheduler: BlueprintConstructionSlotScheduler
var _coordinator: BlueprintConstructionReadinessCoordinator
var _registry: BlueprintConstructionSiteStagingRegistry
var _escrow: BlueprintConstructionMaterialEscrow
var _discovery: PrototypeDroneStorageDiscovery
var _supplier: PrototypeDroneSupplierReservations
var _returns: PrototypeDroneReturnReservations
var _capacity: int = 0
var _speed: float = 0.0
var _configured: bool = false


func _live(node: Variant) -> bool:
	return is_instance_valid(node) and node is Node and node.is_inside_tree() and not node.is_queued_for_deletion()


func configure(drone: PrototypeConstructionWorkerDrone, queue: BlueprintConstructionPriorityQueue, scheduler: BlueprintConstructionSlotScheduler, coordinator: BlueprintConstructionReadinessCoordinator, registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow, discovery: PrototypeDroneStorageDiscovery, supplier: PrototypeDroneSupplierReservations, returns: PrototypeDroneReturnReservations, cargo_capacity: int, speed: float) -> bool:
	if not enable_isolated_dispatch or _configured or not _live(self) or not get_parent() is Node3D:
		return false
	if cargo_capacity <= 0 or cargo_capacity > 100000 or not is_finite(speed) or speed <= 0.0 or speed > PrototypeConstructionWorkerDrone.MAX_SPEED:
		return false
	for service: Node in [drone, queue, scheduler, coordinator, registry, escrow, discovery, supplier, returns]:
		if not _live(service) or service.get_parent() != get_parent():
			return false
	var scope: Node = get_parent()
	if scope.has_meta(SCOPE_KEY) and (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() != null:
		return false
	if not coordinator.matches_tick_services(scheduler, escrow) or not coordinator.matches_owned_registry(registry) or not scheduler.uses_priority_queue(queue):
		return false
	if supplier._service() != discovery or returns._service() != discovery:
		return false
	_drone = drone
	_queue = queue
	_scheduler = scheduler
	_coordinator = coordinator
	_registry = registry
	_escrow = escrow
	_discovery = discovery
	_supplier = supplier
	_returns = returns
	_capacity = cargo_capacity
	_speed = speed
	_configured = true
	scope.set_meta(SCOPE_KEY, weakref(self))
	return true


# Whole-scope serialization deliberately matches the conservative x7 reuse
# gate. Never reconcile/release someone else's claim as a side effect.
func _idle_reason(own_reservation: bool = false) -> StringName:
	if not enable_isolated_dispatch or not _configured or not _live(self):
		return &"disabled_or_unconfigured"
	var scope: Node = get_parent()
	if not scope.has_meta(SCOPE_KEY) or (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() != self:
		return &"service_identity"
	for service: Variant in [_drone, _queue, _scheduler, _coordinator, _registry, _escrow, _discovery, _supplier, _returns]:
		if not _live(service) or service.get_parent() != scope:
			return &"service_identity"
	if not _coordinator.matches_tick_services(_scheduler, _escrow) or not _coordinator.matches_owned_registry(_registry) or not _scheduler.uses_priority_queue(_queue) or not _scheduler.enable_isolated_drone_presence:
		return &"service_identity"
	if _supplier._service() != _discovery or _returns._service() != _discovery:
		return &"service_identity"
	var drones: int = 0
	var registries: int = 0
	var escrows: int = 0
	var coordinators: int = 0
	var schedulers: int = 0
	for child: Node in scope.get_children():
		if not _live(child):
			continue
		if child is PrototypeConstructionWorkerDrone:
			drones += 1
		if child is BlueprintConstructionSiteStagingRegistry:
			registries += 1
		if child is BlueprintConstructionMaterialEscrow:
			escrows += 1
	if child is BlueprintConstructionReadinessCoordinator:
			coordinators += 1
		if child is BlueprintConstructionSlotScheduler:
			schedulers += 1
	if drones != 1 or registries != 1 or escrows != 1 or coordinators != 1 or schedulers != 1 or _scheduler.capacity != 1:
		return &"scope_not_serial"
	if _drone.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE or _drone.cargo_amount() != 0:
		return &"drone_busy"
	if _supplier.reservation_count() != (1 if own_reservation else 0) or _returns.reservation_count() != 0 or _escrow.held_count() != 0 or _scheduler.get_active_count() != 0 or _scheduler.has_drone_binding(_drone):
		return &"unresolved_assignment"
	if not _drone.enable_isolated_cargo_pickup or not _drone.enable_isolated_cargo_delivery or not _drone.enable_isolated_delivered_worker or not _drone.enable_isolated_cargo_reuse or not _drone.enable_isolated_cargo_recovery or not _returns.enable_isolated_cargo_recovery:
		return &"cargo_features_disabled"
	if not _drone.enable_isolated_pre_pickup_rearm or not _drone.enable_isolated_post_delivery_rearm or not _drone.enable_isolated_lost_site_rearm or not _drone._finite_cargo_rearm_ready():
		return &"home_charge_or_recovery_gate"
	return &""


# A whole outstanding single-item bill only: partial already staged stock
# counts against demand; multi-trip and multi-item scheduling are later gates.
func _candidate(site: ConstructionSite, forecast_supplier: bool) -> Dictionary:
	if not _live(site) or site.get_parent() != get_parent() or site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return {"reason": &"not_authorized_or_live"}
	var buffer := _registry.inventory_for_site(site)
	if not _live(buffer):
		return {"reason": &"receiver_unavailable"}
	if not _coordinator.permits_pickup_forecast(site, _queue, _scheduler, _registry, _escrow):
		return {"reason": &"untracked_or_readiness"}
	var bill: Dictionary = ConstructionMaterialBill.get_costs(site.target_definition)
	if bill.size() != 1:
		return {"reason": &"unsupported_bill"}
	var item: ItemDefinition = bill.keys()[0]
	var amount: int = int(bill[item]) - buffer.get_amount(item)
	if amount <= 0:
		return {"reason": &"no_outstanding_materials"}
	if amount > _capacity:
		return {"reason": &"cargo_capacity"}
	if not _registry.can_receive_drone_delivery(site, buffer, item, amount):
		return {"reason": &"receiver_capacity"}
	var result: Dictionary = {"reason": &"", "site": site, "job": site.job, "definition": site.target_definition, "buffer": buffer, "item": item, "amount": amount}
	if forecast_supplier:
		var source := _discovery.find_pickup(_drone, site, item, amount, _capacity, 2.0, true)
		if source.is_empty():
			return {"reason": &"stock_dock_or_route_energy"}
		result["dock"] = source["dock"]
	return result


# Snapshot only. The existing queue provides priority/FIFO ordering. No
# caller-provided snapshot may authorize dispatch, and no inventory is moved.
func inspect_next() -> Dictionary:
	var reason: StringName = _idle_reason()
	var skipped: Array[Dictionary] = []
	if reason != &"":
		return {"reason": reason, "skipped": skipped}
	for site: ConstructionSite in _queue.get_waiting_sites():
		var candidate := _candidate(site, true)
		if candidate["reason"] == &"":
			candidate["skipped"] = skipped
			return candidate
		skipped.append({"site_id": site.get_instance_id(), "reason": candidate["reason"]})
	return {"reason": &"no_eligible_site", "skipped": skipped}


# Explicit single dispatch attempt. Existing ledger re-forecasts, reserves
# the actual source, checks exact claimant/token and launches pickup. This
# method never releases any pre-existing claim, or tries a second launch
# after a failed launch. Failure leaves stock physically at source.
func dispatch_next() -> Dictionary:
	var selected := inspect_next()
	if selected["reason"] != &"":
		return selected
	var site: ConstructionSite = selected["site"]
	var id: int = _supplier.reserve(_drone, site, selected["item"], selected["amount"], _capacity)
	if id <= 0:
		selected["reason"] = &"reservation_failed"
		return selected
	var fresh := _candidate(site, false)
	var claim := _supplier.observe(id)
	var same: bool = _idle_reason(true) == &"" and fresh["reason"] == &"" and _queue.get_waiting_sites().has(site) and _supplier._owned_valid(id, _drone)
	if same:
		for key: String in ["job", "definition", "buffer", "item", "amount"]:
			if fresh[key] != selected[key]:
				same = false
				break
	if not same or claim.is_empty() or not bool(claim["valid"]) or claim["dock"] != selected["dock"] or claim["item"] != selected["item"] or claim["amount"] != selected["amount"]:
		_supplier.release(id, _drone)
		selected["reason"] = &"claim_revalidation_failed"
		return selected
	if not _supplier.begin_pickup(id, _drone, _speed):
		_supplier.release(id, _drone)
		selected["reason"] = &"launch_failed"
		return selected
	selected["claim_id"] = id
	return selected


func _exit_tree() -> void:
	var scope: Node = get_parent()
	if is_instance_valid(scope) and scope.has_meta(SCOPE_KEY) and (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() == self:
		scope.remove_meta(SCOPE_KEY)
	# Active physical custody and claim lifecycle remain with existing services.
