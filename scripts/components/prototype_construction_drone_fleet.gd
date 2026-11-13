extends Node
class_name PrototypeConstructionDroneFleet

# =============================================================================
# E3D5C4W — ISOLATED FINITE ONE-SHOT PHYSICAL WORKER FLEET
# =============================================================================
# An explicit caller can dispatch pre-registered drones to *already authorized*
# QUEUED jobs in priority order. This service binds flights to the existing
# scheduler presence gate; it never authorizes a job, grants worker flags,
# updates power/material requirements or advances time.
#
# Each drone has one permanently pinned job for this experimental phase.
# Cancelled/completed drones return home but are NOT recycled, reused or
# released without separate battery, lifecycle and persisted ownership rules.
# NO _process() and never installed in Main or Factory Testing Sandbox.

@export var enable_isolated_fleet: bool = false
@export var enable_isolated_reuse: bool = false

var _queue: BlueprintConstructionPriorityQueue = null
var _scheduler: BlueprintConstructionSlotScheduler = null
var _registered: Array[Dictionary] = []
var _assignments: Array[Dictionary] = []
var _speed: float = 0.0
var _hover: float = 0.0
var _configured: bool = false


func configure(
	queue: BlueprintConstructionPriorityQueue,
	scheduler: BlueprintConstructionSlotScheduler,
	flight_speed: float,
	hover_height: float
) -> bool:
	if (
		not enable_isolated_fleet or _configured or not is_inside_tree()
		or not _live(queue) or not _live(scheduler)
		or not scheduler.enable_isolated_drone_presence
		or not scheduler.uses_priority_queue(queue)
		or not is_finite(flight_speed)
		or flight_speed <= 0.0
		or flight_speed > PrototypeConstructionWorkerDrone.MAX_SPEED
		or not is_finite(hover_height)
		or hover_height < 0.5 or hover_height > 10.0
	):
		return false
	_queue = queue
	_scheduler = scheduler
	_speed = flight_speed
	_hover = hover_height
	_configured = true
	return true


func register_drone(drone: PrototypeConstructionWorkerDrone) -> bool:
	if not _fleet_ready() or not _live(drone):
		return false
	if (
		not drone.enable_isolated_drone
		or drone.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE
		or not drone.global_position.is_finite()
		or _registered.size() >= _scheduler.capacity
	):
		return false
	for entry: Dictionary in _registered:
		if (entry["drone"] as WeakRef).get_ref() == drone:
			return false
	_registered.append({
		"drone": weakref(drone),
		"home": drone.global_position,
		"used": false
	})
	return true


# Caller-driven, never automatic on priority change, frame, or authorization.
# Even if a scheduler binding were to fail after a successful launch, that
# flight stays quarantined as 'used' rather than being silently reassigned.
func dispatch_waiting() -> int:
	if not _fleet_ready():
		return 0
	var sent: int = 0
	for site: ConstructionSite in _queue.get_waiting_sites():
		if not _valid_queued(site) or not _scheduler.is_tracking_site(site):
			continue
		if get_drone_for_site(site) != null:
			continue
		for entry: Dictionary in _registered:
			if bool(entry["used"]):
				continue
			var worker := (entry["drone"] as WeakRef).get_ref() as PrototypeConstructionWorkerDrone
			if not _live(worker) or not worker.enable_isolated_drone:
				continue
			if worker.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE:
				continue
			if not worker.assign_to_site(site, entry["home"], _speed, _hover):
				continue
			entry["used"] = true
			var bound: bool = _scheduler.bind_site_drone(site, worker)
			_assignments.append({
				"site": weakref(site),
				"drone": weakref(worker),
				"bound": bound,
				"released": false
			})
			if bound:
				sent += 1
			# A failed binding permanently quarantines this launched drone.
			break
	return sent


# Explicit terminal-job release only; charge and cleanup must be completed
# by the caller. Never calls scheduler, job or escrow mutation methods.
func recycle_docked_worker(
	drone: PrototypeConstructionWorkerDrone,
	escrow: BlueprintConstructionMaterialEscrow
) -> bool:
	if (
		not enable_isolated_reuse or not _fleet_ready()
		or not _live(drone) or not _live(escrow)
	):
		return false
	var registered: Dictionary = {}
	for entry: Dictionary in _registered:
		if (entry["drone"] as WeakRef).get_ref() == drone:
			registered = entry
			break
	if registered.is_empty() or not bool(registered["used"]):
		return false
	var prior: Dictionary = {}
	for record: Dictionary in _assignments:
		if (
			bool(record["bound"])
			and not bool(record.get("released", false))
			and (record["drone"] as WeakRef).get_ref() == drone
		):
			prior = record
			break
	if prior.is_empty() or not drone.release_docked_assignment(escrow, _scheduler):
		return false
	prior["released"] = true
	registered["used"] = false
	return true


func get_drone_for_site(site: ConstructionSite) -> PrototypeConstructionWorkerDrone:
	if not is_instance_valid(site):
		return null
	for record: Dictionary in _assignments:
		if not bool(record["bound"]) or bool(record.get("released", false)):
			continue
		if (record["site"] as WeakRef).get_ref() != site:
			continue
		var drone := (
			(record["drone"] as WeakRef).get_ref()
			as PrototypeConstructionWorkerDrone
		)
		if _live(drone):
			return drone
	return null


func registered_count() -> int:
	return _registered.size()


func assigned_count() -> int:
	var count: int = 0
	for record: Dictionary in _assignments:
		if bool(record["bound"]):
			count += 1
	return count


func idle_count() -> int:
	var count: int = 0
	for entry: Dictionary in _registered:
		if bool(entry["used"]):
			continue
		var drone := (entry["drone"] as WeakRef).get_ref() as PrototypeConstructionWorkerDrone
		if (
			_live(drone) and drone.enable_isolated_drone
			and drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE
		):
			count += 1
	return count


func _fleet_ready() -> bool:
	return (
		enable_isolated_fleet and _configured and is_inside_tree()
		and _live(_queue) and _live(_scheduler)
		and _scheduler.enable_isolated_drone_presence
		and _scheduler.uses_priority_queue(_queue)
	)


func _valid_queued(site: ConstructionSite) -> bool:
	return (
		_live(site) and site.job != null
		and is_instance_valid(site.target_definition)
		and site.job.state == ConstructionJob.State.QUEUED
		and site.job.get_wait_reasons().has(&"workers")
	)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node) and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
