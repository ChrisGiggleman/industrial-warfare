extends Node
class_name PrototypeConstructionDroneTickController

# =============================================================================
# E3d5c4z — ISOLATED EXPLICIT-TICK DRONE / READY JOB LIFECYCLE
# =============================================================================
# A fixture explicitly calls tick(delta, dock_power_verified). NO _process().
# The boolean is supplied by a test: NOT a real power-grid delivery proof.
# The owner coordinator still owns material escrow and prototype power flags.
# The scheduler still owns worker readiness; the fleet only dispatches already
# authorized jobs whose power and materials were independently verified.
# A tick never authorizes a blueprint, fabricates inventory, unlocks claims,
# performs a refund, or generates battery charge without dock power input.
# NOT installed in the playable Main or Factory Testing Sandbox scenes.

@export var enable_isolated_ticks: bool = false

var _fleet: PrototypeConstructionDroneFleet = null
var _coordinator: BlueprintConstructionReadinessCoordinator = null
var _scheduler: BlueprintConstructionSlotScheduler = null
var _escrow: BlueprintConstructionMaterialEscrow = null
var _configured: bool = false


func configure(
	fleet: PrototypeConstructionDroneFleet,
	coordinator: BlueprintConstructionReadinessCoordinator,
	scheduler: BlueprintConstructionSlotScheduler,
	escrow: BlueprintConstructionMaterialEscrow
) -> bool:
	if (
		not enable_isolated_ticks or _configured or not is_inside_tree()
		or not _live(fleet) or not _live(coordinator)
		or not _live(scheduler) or not _live(escrow)
		or not scheduler.enable_isolated_drone_presence
		or not fleet.matches_scheduler(scheduler)
		or not coordinator.matches_tick_services(scheduler, escrow)
	):
		return false
	_fleet = fleet
	_coordinator = coordinator
	_scheduler = scheduler
	_escrow = escrow
	_configured = true
	return true


# Each single tick is bounded to a supplied delta, and pauses completely
# if the experimental controller or any of its service gates is unavailable.
# Only active, fully reconciled ConstructionJob sites advance construction.
func tick(delta: float, dock_power_verified: bool) -> Dictionary:
	if not _services_ready() or not is_finite(delta) or delta <= 0.0:
		return {}
	var result := {
		"dispatched": 0,
		"started": 0,
		"advanced": 0,
		"charged": 0,
		"recycled": 0
	}
	# First, reserve ONLY site-owned materials and check prototype power.
	# Flight cannot start merely because a job has high priority.
	result["started"] = _coordinator.reconcile()
	result["dispatched"] = _fleet.dispatch_waiting(true)
	var drones: Array[PrototypeConstructionWorkerDrone] = _fleet.registered_drones()
	for drone: PrototypeConstructionWorkerDrone in drones:
		drone.advance_flight(delta)
	# Arrival may grant a slot, but never before the power/escrow check.
	result["started"] += _coordinator.reconcile()
	for site: ConstructionSite in _scheduler.get_active_sites():
		if is_instance_valid(site) and site.job != null:
			if site.job.state == ConstructionJob.State.CONSTRUCTING:
				site.job.advance(delta)
				result["advanced"] += 1
	# Completion/cancellation must invalidate worker bindings before rearm.
	_coordinator.reconcile()
	for drone: PrototypeConstructionWorkerDrone in drones:
		if drone.charge_at_home(delta, dock_power_verified):
			result["charged"] += 1
		if _fleet.recycle_docked_worker(drone, _escrow):
			result["recycled"] += 1
	return result


func _services_ready() -> bool:
	return (
		enable_isolated_ticks and _configured and is_inside_tree()
		and _live(_fleet) and _live(_coordinator)
		and _live(_scheduler) and _live(_escrow)
		and _scheduler.enable_isolated_drone_presence
		and _fleet.matches_scheduler(_scheduler)
		and _coordinator.matches_tick_services(_scheduler, _escrow)
	)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
