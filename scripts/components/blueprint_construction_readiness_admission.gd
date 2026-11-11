extends Node
class_name BlueprintConstructionReadinessAdmission

# =============================================================================
# E3D5C4B — ISOLATED AUTHORIZATION-TO-READINESS ADMISSION
# =============================================================================
# Admission is NOT dispatch. A job must have passed WorldInteraction's
# explicit E / Ctrl+E authorization, remain QUEUED, and still be waiting on
# power, materials AND workers before it can be registered for evaluation.
#
# No provider is created here. This adapter does NOT call reconcile(),
# ConstructionJob.authorize(), set_availability(), advance(), or cancel().
# Prototype nameplate power is not delivered power. Keep this script
# unattached to Main and the real Factory Testing Sandbox until physical
# resource delivery, workers, recovery and persistence are validated.

@export var enable_isolated_admission: bool = false

var _controller: Node = null
var _coordinator: BlueprintConstructionReadinessCoordinator = null


func configure(
	controller: Node,
	coordinator: BlueprintConstructionReadinessCoordinator
) -> bool:
	if not enable_isolated_admission or is_instance_valid(_controller):
		return false
	if not _live(controller) or not _live(coordinator):
		return false
	if not _is_sandbox_controller(controller):
		return false
	if bool(controller.get("blueprint_sandbox_debug_requirements")):
		return false
	_controller = controller
	_coordinator = coordinator
	return true


func admit_site(site: ConstructionSite, power_units: int) -> bool:
	if not _admission_enabled() or not _valid_queued_site(site):
		return false
	if power_units <= 0 or power_units > 100000:
		return false
	# The isolated coordinator independently validates the material bill,
	# scheduler, power demand, and absence of debug availability flags.
	# track_site() registers QUEUED work; it does NOT dispatch workers.
	return _coordinator.track_site(site, power_units)


# Explicit caller-driven discovery of already-authorized pending jobs.
# Never runs on a timer, from a priority change, or automatically on UI use.
func admit_waiting(power_units: int) -> int:
	if not _admission_enabled() or power_units <= 0 or power_units > 100000:
		return 0
	var queue := _controller.get_node_or_null(
		"BlueprintConstructionPriorityQueue"
	) as BlueprintConstructionPriorityQueue
	if not _live(queue):
		return 0
	var count: int = 0
	for site: ConstructionSite in queue.get_waiting_sites():
		if admit_site(site, power_units):
			count += 1
	return count


func _valid_queued_site(site: ConstructionSite) -> bool:
	if not _live(site) or site.get_parent() != _controller.get_parent():
		return false
	if not bool(_controller.call("_is_managed_blueprint", site)):
		return false
	if site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return false
	if not is_instance_valid(site.target_definition):
		return false
	var missing: Array[StringName] = site.job.get_wait_reasons()
	return (
		missing.has(&"power")
		and missing.has(&"materials")
		and missing.has(&"workers")
	)


func _admission_enabled() -> bool:
	return (
		enable_isolated_admission
		and _live(_controller)
		and _live(_coordinator)
		and _is_sandbox_controller(_controller)
		and not bool(_controller.get("blueprint_sandbox_debug_requirements"))
	)


func _is_sandbox_controller(controller: Node) -> bool:
	if not _live(controller) or controller.name != "WorldInteraction":
		return false
	var host: Node = controller.get_parent()
	if not _live(host):
		return false
	var dock := host.get_node_or_null(
		"ConstructionAuthorizationDock"
	) as SandboxConstructionAuthorizationDock
	return (
		_live(dock)
		and dock.enable_authorization_controls
		and host.get_node_or_null("BlueprintConstructionSummary") != null
		and bool(controller.get("enable_blueprint_planning"))
		and bool(controller.get("enable_blueprint_area_selection"))
	)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
