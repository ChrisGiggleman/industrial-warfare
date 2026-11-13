extends Node
class_name SandboxConstructionDroneLifecycleGate

# =============================================================================
# E3d5c5a — SANDBOX-ONLY, FAIL-CLOSED EXPLICIT TICK BRIDGE
# =============================================================================
# Present but OFF in the committed Factory Testing Sandbox scene. Main has no
# such node. This bridge NEVER discovers, creates or automatically authorizes
# construction jobs or synthetic material/power/worker services.
#
# An opt-in test must explicitly disable the sandbox's older DEBUG readiness
# bypass, configure an isolated driver using its own verified services, then
# bind that SAME child driver under the exact factory-sandbox scene instance.
# No _process(); no autonomous simulation in gameplay.
#
# Charge power remains FALSE until a real dock power provider is designed.
# This bridge may advance one manually requested simulation step, but cannot
# invent charger watts, recycle with imaginary energy, or release inventory.

@export var enable_isolated_bridge: bool = false
var _driver: PrototypeConstructionDroneTickController = null


func bind_verified_driver(driver: PrototypeConstructionDroneTickController) -> bool:
	if not _host_ready() or is_instance_valid(_driver):
		return false
	var sandbox: Node = get_parent()
	if (
		not is_instance_valid(driver)
		or driver.is_queued_for_deletion()
		or not driver.is_inside_tree()
		or driver.get_parent() != sandbox
		or not driver.has_verified_services()
	):
		return false
	_driver = driver
	return true


func tick_once(delta: float) -> Dictionary:
	if (
		not _host_ready()
		or not is_instance_valid(_driver)
		or _driver.is_queued_for_deletion()
		or not _driver.is_inside_tree()
		or _driver.get_parent() != get_parent()
		or not _driver.has_verified_services()
		or not is_finite(delta)
		or delta <= 0.0
	):
		return {}
	# There is deliberately NO charging signal/provider in the playable world.
	return _driver.tick(delta, false)


func has_bound_driver() -> bool:
	return (
		_host_ready() and is_instance_valid(_driver)
		and not _driver.is_queued_for_deletion()
		and _driver.is_inside_tree()
		and _driver.get_parent() == get_parent()
		and _driver.has_verified_services()
	)


func _host_ready() -> bool:
	if not enable_isolated_bridge or not is_inside_tree():
		return false
	var sandbox: Node3D = get_parent() as Node3D
	if not is_instance_valid(sandbox):
		return false
	if sandbox.scene_file_path != "res://scenes/core/factory_testing_sandbox.tscn":
		return false
	var interaction: Node = sandbox.get_node_or_null("WorldInteraction")
	if not is_instance_valid(interaction):
		return false
	return (
		bool(interaction.get("enable_blueprint_planning"))
		and not bool(interaction.get("blueprint_sandbox_debug_requirements"))
		and is_instance_valid(sandbox.get_node_or_null("BlueprintConstructionSummary"))
		and is_instance_valid(sandbox.get_node_or_null("ConstructionAuthorizationDock"))
		and is_instance_valid(sandbox.get_node_or_null("BuildHUD"))
	)
