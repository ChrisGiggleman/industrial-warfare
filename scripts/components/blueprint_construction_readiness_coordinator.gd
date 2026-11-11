extends Node
class_name BlueprintConstructionReadinessCoordinator

# =============================================================================
# E3D5C3C1 — ISOLATED MATERIAL -> POWER -> FINITE WORKER COORDINATION
# =============================================================================
# This Node is NOT installed in Main or Factory Testing Sandbox.
# Sequence: reserve definition-owned materials (atomic escrow), request the
# finite prototype power budget for escrow-backed jobs, then reconcile the
# existing non-preemptive worker-slot scheduler. Only scheduler code can
# alter ConstructionJob readiness; no extra timer advances occur here.
#
# CRITICAL: The available power budget is still a prototype generator
# NAMEPLATE rating, not delivered electricity or a fuel/charge simulation.
# Keep this integration TEST ONLY until real power supply and recovery,
# save/load and starter-resource policies have been implemented.

var _queue: BlueprintConstructionPriorityQueue = null
var _scheduler: BlueprintConstructionSlotScheduler = null
var _escrow: BlueprintConstructionMaterialEscrow = null
var _power: PrototypeConstructionPowerAllocator = null
var _source: InventoryComponent = null
var _entries: Array[Dictionary] = []
var _next_order: int = 0
var _configured: bool = false


func configure(
	queue: BlueprintConstructionPriorityQueue,
	scheduler: BlueprintConstructionSlotScheduler,
	escrow: BlueprintConstructionMaterialEscrow,
	power: PrototypeConstructionPowerAllocator,
	source: InventoryComponent,
	worker_slots: int
) -> bool:
	if _configured:
		return false
	if (
		not _live(queue) or not _live(scheduler)
		or not _live(escrow) or not _live(power)
		or not _live(source)
	):
		return false
	if not scheduler.configure(queue, worker_slots):
		return false
	_queue = queue
	_scheduler = scheduler
	_escrow = escrow
	_power = power
	_source = source
	_configured = true
	return true


func track_site(site: ConstructionSite, power_units: int) -> bool:
	if not _configured or not _live(site):
		return false
	if site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return false
	# Admit only fresh, fully gated jobs. Explicit debug/bootstrap bypasses
	# must not reach this real-readiness coordinator.
	var missing: Array[StringName] = site.job.get_wait_reasons()
	if (
		not missing.has(&"power") or not missing.has(&"materials")
		or not missing.has(&"workers")
	):
		return false
	if power_units <= 0 or power_units > 100000:
		return false
	if ConstructionMaterialBill.get_costs(site.target_definition).is_empty():
		return false
	_prune()
	for entry: Dictionary in _entries:
		if (entry["ref"] as WeakRef).get_ref() == site:
			return false
	# This only registers a waiting job. Missing readiness cannot start it.
	if not _scheduler.track_authorized_site(site):
		return false
	_entries.append({
		"ref": weakref(site),
		"order": _next_order,
		"power_units": power_units,
		"power_tracked": false
	})
	_next_order += 1
	return true


# Returns the number of newly dispatched worker slots. Does not advance time.
# Invoke before the game's construction time step; after an outage this
# immediately pauses the old job and releases its worker slot.
func reconcile() -> int:
	if not _configured:
		return 0
	_prune()
	if not _live(_scheduler):
		return 0
	if (
		not _live(_queue) or not _live(_escrow)
		or not _live(_power) or not _live(_source)
	):
		# Revoke readiness before returning if a required service vanishes.
		# Otherwise already-active ConstructionSite._process would keep
		# advancing a job with stale worker and power permissions.
		for entry: Dictionary in _entries:
			var pending: ConstructionSite = (
				(entry["ref"] as WeakRef).get_ref() as ConstructionSite
			)
			if _valid_site(pending):
				_scheduler.update_requirements(pending, false, false)
		_scheduler.reconcile()
		return 0

	var ordered: Array[Dictionary] = _entries.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var left: ConstructionSite = (a["ref"] as WeakRef).get_ref() as ConstructionSite
		var right: ConstructionSite = (b["ref"] as WeakRef).get_ref() as ConstructionSite
		var left_active: bool = left.job.state == ConstructionJob.State.CONSTRUCTING
		var right_active: bool = right.job.state == ConstructionJob.State.CONSTRUCTING
		if left_active != right_active:
			return left_active
		if int(left.job.priority) != int(right.job.priority):
			return int(left.job.priority) < int(right.job.priority)
		return int(a["order"]) < int(b["order"])
	)

	# Atomic material reservation FIRST, ordered by priority, never by
	# warehouse stock inspection. An unreserved job does not request power.
	for entry: Dictionary in ordered:
		var site: ConstructionSite = (entry["ref"] as WeakRef).get_ref() as ConstructionSite
		if not _valid_site(site):
			continue
		var reservation_id: int = _escrow.reservation_for(site)
		if reservation_id == 0 and site.job.state == ConstructionJob.State.QUEUED:
			var bill: Dictionary = ConstructionMaterialBill.get_costs(
				site.target_definition
			)
			if not bill.is_empty():
				reservation_id = _escrow.reserve(site, _source, bill)
		var owned: bool = _owns_materials(site)
		if owned and not bool(entry["power_tracked"]):
			if _power.track_site(site, int(entry["power_units"])):
				entry["power_tracked"] = true
		elif not owned and bool(entry["power_tracked"]):
			_power.stop_tracking(site)
			entry["power_tracked"] = false

	var allocations: Dictionary = _power.get_allocations()
	for entry: Dictionary in _entries:
		var site: ConstructionSite = (entry["ref"] as WeakRef).get_ref() as ConstructionSite
		if not _valid_site(site):
			continue
		var materials_ready: bool = _owns_materials(site)
		var power_ready: bool = (
			materials_ready and bool(entry["power_tracked"])
			and int(allocations.get(site, 0)) == int(entry["power_units"])
		)
		_scheduler.update_requirements(site, power_ready, materials_ready)
	return _scheduler.reconcile()


func get_status(site: ConstructionSite) -> Dictionary:
	var result: Dictionary = {
		"tracked": false,
		"materials_reserved": false,
		"power_allocated": false,
		"worker_active": false
	}
	if not _configured or not _valid_site(site):
		return result
	for entry: Dictionary in _entries:
		if (entry["ref"] as WeakRef).get_ref() != site:
			continue
		result["tracked"] = true
		result["materials_reserved"] = _owns_materials(site)
		result["power_allocated"] = (
			bool(result["materials_reserved"])
			and bool(entry["power_tracked"])
			and _power.is_fully_allocated(site)
		)
		result["worker_active"] = _scheduler.get_active_sites().has(site)
		return result
	return result


func _owns_materials(site: ConstructionSite) -> bool:
	if not _valid_site(site) or not _live(_escrow):
		return false
	var id: int = _escrow.reservation_for(site)
	if id <= 0 or not _escrow.has_reservation(id) or _escrow.needs_recovery(id):
		return false
	var expected: Dictionary = ConstructionMaterialBill.get_costs(site.target_definition)
	return not expected.is_empty() and _escrow.held_materials(id) == expected


func _prune() -> void:
	var remaining: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		var site: ConstructionSite = (entry["ref"] as WeakRef).get_ref() as ConstructionSite
		if _valid_site(site):
			remaining.append(entry)
			continue
		# A freed site must NEVER be passed to a typed method.
		if is_instance_valid(site):
			if _live(_power):
				_power.stop_tracking(site)
			if _live(_scheduler):
				_scheduler.stop_tracking(site)
	_entries = remaining


func _valid_site(site: ConstructionSite) -> bool:
	return (
		_live(site) and site.job != null
		and is_instance_valid(site.target_definition)
		and site.job.state in [
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.CONSTRUCTING,
			ConstructionJob.State.PAUSED
		]
	)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
