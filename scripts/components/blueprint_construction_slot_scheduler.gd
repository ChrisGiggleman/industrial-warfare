extends Node
class_name BlueprintConstructionSlotScheduler

# =============================================================================
# E3D5B — BOUNDED CONSTRUCTION SLOT SCHEDULER (ISOLATED FOUNDATION)
# =============================================================================
# Dispatches only explicit, externally supplied power/material readiness.
# This service mirrors those two verified flags into ConstructionJob while
# granting/revoking the finite worker-availability flag. It cannot fabricate
# power, supply materials, consume inventory, allocate physical drones, or
# advance construction time.
#
# Until actual power/material/worker services exist, no live sandbox controller
# instantiates this scheduler. Tests inject explicit readiness snapshots.
#
# Scheduling: High -> Normal -> Low; FIFO by registration order within tier.
# Active work is non-preemptive; losing readiness pauses and frees the slot.
# A paused job may resume later without losing completed construction progress.

# E3D5C4V: Existing scheduler remains unchanged with this OFF.
# Once a physical worker is bound, disabling this option pauses that work;
# it can never turn a drone-required job into an unguarded slot.
@export var enable_isolated_drone_presence: bool = false
var _drone_presence_latched: bool = false

const MAX_CAPACITY: int = 16

var capacity: int = 0
var _priority_queue: BlueprintConstructionPriorityQueue = null
var _tracked: Array[Dictionary] = []
var _active: Array[WeakRef] = []
var _next_order: int = 0


func configure(
	priority_queue: BlueprintConstructionPriorityQueue,
	worker_slots: int
) -> bool:
	if is_instance_valid(_priority_queue) or not _tracked.is_empty():
		return false
	if not is_instance_valid(priority_queue):
		return false
	if worker_slots < 1 or worker_slots > MAX_CAPACITY:
		return false
	_priority_queue = priority_queue
	capacity = worker_slots
	return true


func track_authorized_site(site: ConstructionSite) -> bool:
	if not is_instance_valid(_priority_queue) or not _is_trackable(site):
		return false
	if site.job.state != ConstructionJob.State.QUEUED:
		return false
	_prune()
	if _find_entry_index(site) >= 0:
		return false
	if not _priority_queue.register_queued_site(site):
		# A controller may have already registered it for its HUD.
		if not _priority_queue.get_waiting_sites().has(site):
			return false
	_tracked.append({
		"ref": weakref(site),
		"order": _next_order,
		"ready_known": false,
		"power": false,
		"materials": false
	})
	_next_order += 1
	return true


# Read-only handoff queries for E3d5c4w's explicit fleet dispatcher.
# A dispatcher must not launch a one-shot drone for an untracked site or
# accidentally mix two different priority queues.
func uses_priority_queue(queue: BlueprintConstructionPriorityQueue) -> bool:
	return is_instance_valid(queue) and _priority_queue == queue and capacity > 0


func is_tracking_site(site: ConstructionSite) -> bool:
	return _is_trackable(site) and _find_entry_index(site) >= 0


# Read-only stale association check: terminal jobs must be pruned by
# reconcile() before a physical worker can be explicitly recycled.
func has_drone_binding(drone: PrototypeConstructionWorkerDrone) -> bool:
	if not is_instance_valid(drone):
		return false
	for entry: Dictionary in _tracked:
		var ref: WeakRef = entry.get("worker_drone") as WeakRef
		if ref != null and ref.get_ref() == drone:
			return true
	return false


# The drone's physical presence gates a real scheduler worker slot. Binding
# does not call authorize(), change availability, or move an inventory item.
# Only a queued site explicitly assigned to THIS live drone can bind.
func bind_site_drone(
	site: ConstructionSite,
	drone: PrototypeConstructionWorkerDrone
) -> bool:
	if (
		not enable_isolated_drone_presence
		or not _is_trackable(site)
		or site.job.state != ConstructionJob.State.QUEUED
		or not is_instance_valid(drone)
		or drone.is_queued_for_deletion()
		or not drone.is_inside_tree()
		or not drone.is_bound_to_site(site)
		or _is_assigned(site)
	):
		return false
	var index: int = _find_entry_index(site)
	if index < 0 or _tracked[index].get("worker_drone") != null:
		return false
	for entry: Dictionary in _tracked:
		var other: WeakRef = entry.get("worker_drone") as WeakRef
		if other != null and other.get_ref() == drone:
			return false
	_tracked[index]["worker_drone"] = weakref(drone)
	_drone_presence_latched = true
	return true


# ONLY the eventual power/material services should supply these two values.
# Missing snapshots fail closed: queued sites never receive worker access.
func update_requirements(
	site: ConstructionSite,
	power_ready: bool,
	materials_ready: bool
) -> bool:
	var index: int = _find_entry_index(site)
	if index < 0 or not _is_trackable(site):
		return false
	_tracked[index]["ready_known"] = true
	_tracked[index]["power"] = power_ready
	_tracked[index]["materials"] = materials_ready
	return true


# Optional explicit removal. Cancellation/completion are also auto-pruned
# on the next reconcile(), including nodes that have been queue_free()'d.
func stop_tracking(site: ConstructionSite) -> void:
	var index: int = _find_entry_index(site)
	if index < 0:
		return
	if _is_trackable(site):
		# Never keep an invisible worker assignment when opting out.
		var entry: Dictionary = _tracked[index]
		site.job.set_availability(
			bool(entry["power"]) and bool(entry["ready_known"]),
			bool(entry["materials"]) and bool(entry["ready_known"]),
			false
		)
	_tracked.remove_at(index)
	_remove_active(site)


func reconcile() -> int:
	if not is_instance_valid(_priority_queue) or capacity < 1:
		return 0
	_prune()

	# Existing assignments remain active without being preempted by new
	# High-priority jobs. Requirements disappearing release the worker
	# before the next candidate is considered.
	var retained: Array[WeakRef] = []
	for ref: WeakRef in _active:
		var site: ConstructionSite = ref.get_ref() as ConstructionSite
		if not _is_trackable(site):
			continue
		var index: int = _find_entry_index(site)
		if index < 0:
			continue
		var entry: Dictionary = _tracked[index]
		if not _is_eligible(entry):
			site.job.set_availability(
				bool(entry["power"]) and bool(entry["ready_known"]),
				bool(entry["materials"]) and bool(entry["ready_known"]),
				false
			)
			continue
		if site.job.state != ConstructionJob.State.CONSTRUCTING:
			continue
		retained.append(ref)
	_active = retained

	# Preserve actual power/material flags for every waiting/paused job,
	# but never grant a worker to a site outside the assigned set.
	for entry: Dictionary in _tracked:
		var site: ConstructionSite = (
			(entry["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		if not _is_trackable(site) or _is_assigned(site):
			continue
		site.job.set_availability(
			bool(entry["power"]) and bool(entry["ready_known"]),
			bool(entry["materials"]) and bool(entry["ready_known"]),
			false
		)

	var available: int = capacity - _active.size()
	if available <= 0:
		return 0
	var pending: Array[Dictionary] = []
	for entry: Dictionary in _tracked:
		if not _is_eligible(entry):
			continue
		var site: ConstructionSite = (
			(entry["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		if _is_assigned(site):
			continue
		if site.job.state in [
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.PAUSED
		]:
			pending.append(entry)
	pending.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_site: ConstructionSite = (
			(left["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		var right_site: ConstructionSite = (
			(right["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		var left_priority: int = int(left_site.job.priority)
		var right_priority: int = int(right_site.job.priority)
		if left_priority != right_priority:
			return left_priority < right_priority
		return int(left["order"]) < int(right["order"])
	)

	var dispatched: int = 0
	for entry: Dictionary in pending:
		if available <= 0:
			break
		var site: ConstructionSite = (
			(entry["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		if not _is_trackable(site) or not _is_eligible(entry):
			continue
		if not site.job.set_availability(true, true, true):
			continue
		if site.job.state != ConstructionJob.State.CONSTRUCTING:
			continue
		_active.append(weakref(site))
		available -= 1
		dispatched += 1
	return dispatched


func get_active_sites() -> Array[ConstructionSite]:
	var result: Array[ConstructionSite] = []
	for ref: WeakRef in _active:
		var site: ConstructionSite = ref.get_ref() as ConstructionSite
		if (
			_is_trackable(site)
			and site.job.state == ConstructionJob.State.CONSTRUCTING
		):
			result.append(site)
	return result


func get_active_count() -> int:
	return get_active_sites().size()


func get_waiting_count() -> int:
	_prune()
	var total: int = 0
	for entry: Dictionary in _tracked:
		var site: ConstructionSite = (
			(entry["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		if _is_trackable(site) and not _is_assigned(site):
			if site.job.state in [
				ConstructionJob.State.QUEUED,
				ConstructionJob.State.PAUSED
			]:
				total += 1
	return total


func _is_eligible(entry: Dictionary) -> bool:
	if (
		not bool(entry["ready_known"])
		or not bool(entry["power"])
		or not bool(entry["materials"])
	):
		return false
	# Legacy isolated scheduler tests still work with the feature OFF.
	# Enabling the gate requires EVERY tracked job to present its own drone.
	# Any later opt-out remains fail-closed for previously bound jobs.
	if not enable_isolated_drone_presence and not _drone_presence_latched:
		return true
	if not enable_isolated_drone_presence:
		return false
	var drone_ref: WeakRef = entry.get("worker_drone") as WeakRef
	if drone_ref == null:
		return false
	var site_ref: WeakRef = entry["ref"] as WeakRef
	if site_ref == null:
		return false
	var site: ConstructionSite = site_ref.get_ref() as ConstructionSite
	var drone: PrototypeConstructionWorkerDrone = (
		drone_ref.get_ref() as PrototypeConstructionWorkerDrone
	)
	return (
		_is_trackable(site)
		and is_instance_valid(drone)
		and not drone.is_queued_for_deletion()
		and drone.is_inside_tree()
		and drone.is_bound_to_site(site)
		and drone.is_at_site()
	)


func _is_trackable(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and site.job != null
		and site.job.state not in [
			ConstructionJob.State.PLANNED,
			ConstructionJob.State.COMPLETE,
			ConstructionJob.State.CANCELLED
		]
	)


func _is_assigned(site: ConstructionSite) -> bool:
	if not is_instance_valid(site):
		return false
	for ref: WeakRef in _active:
		if ref.get_ref() == site:
			return true
	return false


func _remove_active(site: ConstructionSite) -> void:
	var remaining: Array[WeakRef] = []
	for ref: WeakRef in _active:
		if ref.get_ref() != site:
			remaining.append(ref)
	_active = remaining


func _find_entry_index(site: ConstructionSite) -> int:
	if not is_instance_valid(site):
		return -1
	for index: int in range(_tracked.size()):
		var ref: WeakRef = _tracked[index]["ref"] as WeakRef
		if ref.get_ref() == site:
			return index
	return -1


func _prune() -> void:
	var remaining: Array[Dictionary] = []
	for entry: Dictionary in _tracked:
		var ref: WeakRef = entry["ref"] as WeakRef
		var site: ConstructionSite = ref.get_ref() as ConstructionSite
		if _is_trackable(site):
			remaining.append(entry)
	_tracked = remaining
