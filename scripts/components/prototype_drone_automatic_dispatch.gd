extends Node
class_name PrototypeDroneAutomaticDispatch

# E3d5c5x8a: explicit, serialized automatic choice and pickup launch only.
# No process loop, player authorization, movement, cargo debit, worker
# admission, readiness mutation, charge, rearm or lifecycle ticking.
@export var enable_isolated_dispatch: bool = false
@export var enable_isolated_lifecycle: bool = false
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
var _charging: PrototypeDroneHubCharging
var _lifecycle_configured: bool = false
var _assigned_site: WeakRef
var _assigned_job: ConstructionJob
var _assigned_definition: BuildingDefinition
var _assigned_buffer: WeakRef
var _assigned_item: ItemDefinition
var _assigned_amount: int = 0
var _claim_id: int = 0
var _ticking: bool = false

# E3d5c6e: default-off single-owner tick extension (exact scene only).
@export var enable_isolated_power_parking: bool = false
const POWER_PARKING_SCENE := "res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn"
const POWER_OUTAGE_DEBOUNCE: float = 2.0
var _power_outage_seconds: float = 0.0


func _parking_enabled() -> bool:
	var root := get_parent() as Node3D
	return (
		enable_isolated_power_parking and _configured and _lifecycle_configured
		and _live(_drone) and _drone.enable_isolated_power_parking
		and is_instance_valid(root) and root.scene_file_path == POWER_PARKING_SCENE
	)


func _power_missing(site: ConstructionSite) -> bool:
	var status: Dictionary = _coordinator.get_status(site)
	return (
		_assigned_job != null
		and _assigned_job.state == ConstructionJob.State.PAUSED
		and bool(status.get("tracked", false))
		and bool(status.get("materials_reserved", false))
		and not bool(status.get("power_allocated", false))
	)


func _begin_power_park_if_due(site: ConstructionSite, delta: float) -> Dictionary:
	if not _power_missing(site):
		_power_outage_seconds = 0.0
		return {"action": &"construction_wait"}
	_power_outage_seconds += delta
	if _power_outage_seconds < POWER_OUTAGE_DEBOUNCE:
		return {"action": &"outage_debounce"}
	if not _drone.begin_power_parking(site):
		return {"action": &"parking_energy_wait"}
	_power_outage_seconds = 0.0
	_coordinator.reconcile()
	return {"action": &"parking_started"}


# This still runs ONLY within the original dispatch.tick() path.
# A parked job retains its original assignment; no terminal rearm until
# completion or cancellation, and no new material pickup on re-approach.
func _tick_power_parking(site: ConstructionSite, state: int, delta: float) -> Dictionary:
	_coordinator.reconcile()
	var terminal: bool = (
		not _live(site) or _assigned_job == null
		or _assigned_job.state in [ConstructionJob.State.CANCELLED, ConstructionJob.State.COMPLETE]
	)
	if terminal:
		_power_outage_seconds = 0.0
		if state == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			if _drone.release_docked_cargo_assignment(_supplier, _returns, _coordinator, _escrow, _scheduler):
				_clear_assignment()
				return {"action": &"rearmed"}
			var charged: float = _charging.advance_charging(delta)
			return {"action": &"charged" if charged > 0.0 else &"dock_wait", "energy": charged}
		if state == PrototypeConstructionWorkerDrone.FlightState.RETURNING:
			return {"action": &"return_flight" if _drone.advance_flight(delta) else &"return_wait"}
		return {"action": &"terminal_return_wait"}
	if state == PrototypeConstructionWorkerDrone.FlightState.RETURNING:
		return {"action": &"parking_return" if _drone.advance_flight(delta) else &"parking_return_wait"}
	if state == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
		var status: Dictionary = _coordinator.get_status(site)
		if (
			bool(status.get("materials_reserved", false))
			and bool(status.get("power_allocated", false))
			and _escrow.reservation_for(site) > 0
			and _drone.begin_power_resume(site)
		):
			_power_outage_seconds = 0.0
			return {"action": &"resume_started"}
		var charged_at_hub: float = _charging.advance_charging(delta)
		return {"action": &"park_charged" if charged_at_hub > 0.0 else &"park_wait", "energy": charged_at_hub}
	if state == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND:
		if _power_missing(site):
			return {"action": &"resume_aborted" if _drone.abort_power_resume(site) else &"resume_wait"}
		return {"action": &"resume_flight" if _drone.advance_flight(delta) else &"resume_wait"}
	if state == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
		if (
			_assigned_job.state == ConstructionJob.State.CONSTRUCTING
			and _scheduler.get_active_sites().has(site)
			and _drone.complete_power_resume(site)
		):
			_power_outage_seconds = 0.0
			return {"action": &"resumed"}
		return _begin_power_park_if_due(site, delta)
	return {"action": &"parking_quarantined"}



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
func _scope_reason() -> StringName:
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
	return &""


func _idle_reason(own_reservation: bool = false) -> StringName:
	var scope_reason: StringName = _scope_reason()
	if scope_reason != &"":
		return scope_reason
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
	if _lifecycle_configured and site.is_processing():
		return {"reason": &"external_site_timer"}
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
	if _lifecycle_configured and (not _ticking or not enable_isolated_lifecycle or _assigned_job != null):
		return {"reason": &"lifecycle_owns_dispatch"}
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
	if _lifecycle_configured:
		_assigned_site = weakref(site)
		_assigned_job = selected["job"]
		_assigned_definition = selected["definition"]
		_assigned_buffer = weakref(selected["buffer"])
		_assigned_item = selected["item"]
		_assigned_amount = selected["amount"]
		_claim_id = id
	return selected


func _exit_tree() -> void:
	var scope: Node = get_parent()
	if is_instance_valid(scope) and scope.has_meta(SCOPE_KEY) and (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() == self:
		scope.remove_meta(SCOPE_KEY)
	# Active physical custody and claim lifecycle remain with existing services.


# x8b: separately opted-in explicit lifecycle, enrolled at a clean home.
# No adoption of an existing manual assignment, no legacy charging bool.
func configure_lifecycle(charging: PrototypeDroneHubCharging) -> bool:
	if not enable_isolated_lifecycle or _lifecycle_configured or _idle_reason() != &"":
		return false
	if not _live(charging) or charging.get_parent() != get_parent():
		return false
	if _drone._charging_owner == null or _drone._charging_owner.get_ref() != charging:
		return false
	if not charging.matches_docked_registration(_drone, _drone._charging_token):
		return false
	_charging = charging
	_lifecycle_configured = true
	return true


func _lifecycle_ready() -> bool:
	if not enable_isolated_lifecycle or not _lifecycle_configured or _scope_reason() != &"":
		return false
	if not _live(_charging) or _charging.get_parent() != get_parent():
		return false
	return _drone._charging_owner != null and _drone._charging_owner.get_ref() == _charging


# A weak exact site plus retained original job survives a freed scene node.
# Never adopt a different live job, receiver or claim.
func _assigned_live_site() -> ConstructionSite:
	if _assigned_site == null:
		return null
	var site := _assigned_site.get_ref() as ConstructionSite
	if not _live(site) or site.get_parent() != get_parent() or site.job != _assigned_job or site.target_definition != _assigned_definition:
		return null
	return site


func _pickup_target_current(site: ConstructionSite) -> bool:
	if not _live(site) or _assigned_buffer == null:
		return false
	var fresh: Dictionary = _candidate(site, false)
	return fresh["reason"] == &"" and fresh["buffer"] == _assigned_buffer.get_ref() and fresh["item"] == _assigned_item and fresh["amount"] == _assigned_amount


func _clear_assignment() -> void:
	_assigned_site = null
	_assigned_job = null
	_assigned_definition = null
	_assigned_buffer = null
	_assigned_item = null
	_assigned_amount = 0
	_claim_id = 0
	_power_outage_seconds = 0.0


# Each call performs at most one timed phase. A successful launch, collect,
# unload, admission or rearm is a separate step; no leftover delta replay.
# The caller owns delta and must not run another movement/charge/job driver.
func tick(delta: float) -> Dictionary:
	if _ticking or not is_finite(delta) or delta <= 0.0 or not _lifecycle_ready():
		return {"action": &"blocked"}
	_ticking = true
	var result: Dictionary = _tick_once(delta)
	_ticking = false
	return result


func _tick_once(delta: float) -> Dictionary:
	var state: int = _drone.get_flight_state()
	if _assigned_job == null:
		if state != PrototypeConstructionWorkerDrone.FlightState.IDLE:
			return {"action": &"foreign_assignment"}
		var selected: Dictionary = dispatch_next()
		return {"action": &"launched" if selected.get("claim_id", 0) > 0 else &"waiting", "selection": selected}
	var site := _assigned_live_site()
	if _parking_enabled() and _drone._power_parked_assignment:
		return _tick_power_parking(site, state, delta)
	match state:
		PrototypeConstructionWorkerDrone.FlightState.PICKUP_OUTBOUND, PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP:
			if not _supplier._owned_valid(_claim_id, _drone):
				# Exact ledger invalidation releases only this claim, with existing
				# terminal/lost-site provenance or conservative quarantine.
				_supplier.advance_pickup(_claim_id, _drone, delta)
				return {"action": &"pickup_invalid"}
			if not _pickup_target_current(site):
				return {"action": &"receiver_wait"}
			if state == PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP:
				return {"action": &"collected" if _supplier.collect_pickup(_claim_id, _drone) else &"pickup_wait"}
			return {"action": &"pickup_flight" if _supplier.advance_pickup(_claim_id, _drone, delta) else &"pickup_wait"}
		PrototypeConstructionWorkerDrone.FlightState.CARGO_HELD, PrototypeConstructionWorkerDrone.FlightState.DELIVERY_OUTBOUND, PrototypeConstructionWorkerDrone.FlightState.AT_DELIVERY:
			if _drone._recovery_cargo_valid():
				return {"action": &"recovery" if _returns.advance_cancelled_recovery(_drone, delta) else &"recovery_wait"}
			if not _live(site) or site.is_processing() or _assigned_buffer == null or _registry.inventory_for_site(site) != _assigned_buffer.get_ref():
				return {"action": &"receiver_wait"}
			if state == PrototypeConstructionWorkerDrone.FlightState.CARGO_HELD:
				return {"action": &"delivery_started" if _drone.begin_delivery(site, _registry, _escrow) else &"delivery_wait"}
			if state == PrototypeConstructionWorkerDrone.FlightState.AT_DELIVERY:
				return {"action": &"unloaded" if _drone.unload_delivery() else &"delivery_wait"}
			return {"action": &"delivery_flight" if _drone.advance_delivery(delta) else &"delivery_wait"}
		PrototypeConstructionWorkerDrone.FlightState.DELIVERED:
			if _assigned_job.state == ConstructionJob.State.CANCELLED:
				return {"action": &"cancelled_return" if _drone.begin_cancelled_delivery_return() else &"return_wait"}
			if _drone._original_site_freed():
				return {"action": &"lost_return" if _drone.begin_lost_delivery_return() else &"return_wait"}
			if not _live(site) or site.is_processing():
				return {"action": &"receiver_wait"}
			_coordinator.reconcile()
			if not _coordinator.admit_delivered_worker(site, _drone):
				return {"action": &"admission_wait"}
			_coordinator.reconcile()
			return {"action": &"admitted"}
		PrototypeConstructionWorkerDrone.FlightState.AT_SITE, PrototypeConstructionWorkerDrone.FlightState.OUTBOUND:
			_coordinator.reconcile()
			if not _live(site) or not _drone.is_at_site():
				return {"action": &"worker_flight" if _drone.advance_flight(delta) else &"worker_wait"}
			if _parking_enabled() and state == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
				if _power_missing(site):
					return _begin_power_park_if_due(site, delta)
				_power_outage_seconds = 0.0
			# Refuse to double-drive a site's own automatic _process timer.
			if site.is_processing() or _assigned_job.state != ConstructionJob.State.CONSTRUCTING or not _scheduler.get_active_sites().has(site):
				return {"action": &"construction_wait"}
			_assigned_job.advance(delta)
			_coordinator.reconcile()
			return {"action": &"construction"}
		PrototypeConstructionWorkerDrone.FlightState.RECOVERY_WAIT, PrototypeConstructionWorkerDrone.FlightState.RECOVERY_OUTBOUND, PrototypeConstructionWorkerDrone.FlightState.AT_RECOVERY, PrototypeConstructionWorkerDrone.FlightState.RECOVERY_HOME:
			return {"action": &"recovery" if _returns.advance_cancelled_recovery(_drone, delta) else &"recovery_wait"}
		PrototypeConstructionWorkerDrone.FlightState.RETURNING:
			return {"action": &"return_flight" if _drone.advance_flight(delta) else &"return_wait"}
		PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			_coordinator.reconcile()
			if _drone.release_docked_cargo_assignment(_supplier, _returns, _coordinator, _escrow, _scheduler):
				_clear_assignment()
				return {"action": &"rearmed"}
			var charged: float = _charging.advance_charging(delta)
			return {"action": &"charged" if charged > 0.0 else &"dock_wait", "energy": charged}
	return {"action": &"assignment_quarantined"}


func has_lifecycle_assignment() -> bool:
	return _assigned_job != null
