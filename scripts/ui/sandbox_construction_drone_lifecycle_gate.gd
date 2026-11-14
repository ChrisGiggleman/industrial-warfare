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
# Separate opt-in: only PRE-REGISTERED site-owned staging may auto-attach
# a guarded receiver after a genuine WorldInteraction authorization signal.
@export var enable_isolated_authorization_autowire: bool = false

var _driver: PrototypeConstructionDroneTickController = null
var _auto_registry: BlueprintConstructionSiteStagingRegistry = null
var _auto_escrow: BlueprintConstructionMaterialEscrow = null
var _auto_configured: bool = false
var _auto_pending: Array[Dictionary] = []
var _auto_attached: Array[Dictionary] = []


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


# E3d5c5b — explicit owned receiver installation for a REAL sandbox
# WorldInteraction-placed blueprint. The site must already be authorized.
# This is not a material source or a construction readiness provider.
# The independent receiver is a child of the sandbox, NEVER the site,
# so cancellation cannot silently discard refunded inventory.
func attach_player_site_receiver(
	site: ConstructionSite,
	staging: BlueprintConstructionMaterialStaging,
	registry: BlueprintConstructionSiteStagingRegistry
) -> BlueprintConstructionAnchoredStagingPort:
	if not _host_ready():
		return null
	var sandbox: Node3D = get_parent() as Node3D
	var world: Node = sandbox.get_node_or_null("WorldInteraction")
	if (
		not is_instance_valid(site) or site.is_queued_for_deletion()
		or site.get_parent() != sandbox or site.job == null
		or site.job.state != ConstructionJob.State.QUEUED
		or not world.call("_is_managed_blueprint", site)
		or not is_instance_valid(staging)
		or staging.is_queued_for_deletion()
		or staging.get_parent() != sandbox
		or not staging.enable_isolated_staging
		or not is_instance_valid(registry)
		or registry.is_queued_for_deletion()
		or registry.get_parent() != sandbox
		or not registry.enable_isolated_site_registry
		or not is_instance_valid(staging.get_staged_inventory())
	):
		return null
	var receiver := Node3D.new()
	receiver.name = "SiteOwnedReceiver"
	sandbox.add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver.add_child(port)
	if not port.attach_to_authorized_site(site, staging, registry):
		receiver.free()
		return null
	return port


# E3d5c5d — Explicitly supply existing receiver-ownership and escrow
# services. Does not make a stock buffer, feed items or grant readiness.
# These services are not attached to the committed sandbox by default.
func configure_authorization_autowire(
	registry: BlueprintConstructionSiteStagingRegistry,
	escrow: BlueprintConstructionMaterialEscrow
) -> bool:
	if (
		not _host_ready() or not enable_isolated_authorization_autowire
		or _auto_configured
		or not _live_autowire_node(registry)
		or not _live_autowire_node(escrow)
		or registry.get_parent() != get_parent()
		or escrow.get_parent() != get_parent()
		or not registry.enable_isolated_site_registry
	):
		return false
	var world: Node = get_parent().get_node_or_null("WorldInteraction")
	if not is_instance_valid(world) or not world.has_signal(&"blueprint_site_authorized"):
		return false
	if world.connect(&"blueprint_site_authorized", _on_authorized_player_blueprint) != OK:
		return false
	_auto_registry = registry
	_auto_escrow = escrow
	_auto_configured = true
	return true


# Register real, preconfigured staging for one MANAGED and still-PLANNED site.
# A separate builder/factory inventory must supply this staging; the gate
# never invents stock or automatically places construction buildings.
func prepare_player_site_intake(
	site: ConstructionSite,
	staging: BlueprintConstructionMaterialStaging
) -> bool:
	if (
		not _autowire_ready()
		or not _live_autowire_node(site)
		or site.get_parent() != get_parent()
		or not _live_autowire_node(staging)
		or staging.get_parent() != get_parent()
		or site.job == null
		or site.job.state != ConstructionJob.State.PLANNED
		or not staging.enable_isolated_staging
		or not staging.matches_definition(site.target_definition)
		or not _live_autowire_node(staging.get_staged_inventory())
	):
		return false
	var world: Node = get_parent().get_node_or_null("WorldInteraction")
	if not is_instance_valid(world) or not world.call("_is_managed_blueprint", site):
		return false
	for entry: Dictionary in _auto_pending:
		var prior_site: ConstructionSite = (
			(entry["site"] as WeakRef).get_ref() as ConstructionSite
		)
		var prior_staging: BlueprintConstructionMaterialStaging = (
			(entry["staging"] as WeakRef).get_ref()
			as BlueprintConstructionMaterialStaging
		)
		if prior_site == site or prior_staging == staging:
			return false
	_auto_pending.append({
		"site": weakref(site),
		"staging": weakref(staging),
		"attempted": false
	})
	return true


# Observation only. Refuses ended sites, stale claims and foreign receivers.
func receiver_for_authorized_site(
	site: ConstructionSite
) -> BlueprintConstructionAnchoredStagingPort:
	if not _autowire_ready() or not _live_autowire_node(site):
		return null
	for entry: Dictionary in _auto_attached:
		if (entry["site"] as WeakRef).get_ref() != site:
			continue
		var port: BlueprintConstructionAnchoredStagingPort = (
			(entry["port"] as WeakRef).get_ref()
			as BlueprintConstructionAnchoredStagingPort
		)
		if _live_autowire_node(port) and port.matches_attached_site():
			return port
	return null


# No _process(): this signal is triggered ONLY by the existing E/Ctrl+E
# authorization path. Every other blueprint remains untouched.
func _on_authorized_player_blueprint(site: ConstructionSite) -> void:
	if not _autowire_ready() or not _live_autowire_node(site):
		return
	for entry: Dictionary in _auto_pending:
		if (entry["site"] as WeakRef).get_ref() != site:
			continue
		if bool(entry["attempted"]):
			return
		# Permanent one-attempt admission: never reconstruct a live claim.
		entry["attempted"] = true
		var staging: BlueprintConstructionMaterialStaging = (
			(entry["staging"] as WeakRef).get_ref()
			as BlueprintConstructionMaterialStaging
		)
		if (
			not _live_autowire_node(staging)
			or _auto_escrow.reservation_for(site) != 0
		):
			return
		var port: BlueprintConstructionAnchoredStagingPort = (
			attach_player_site_receiver(site, staging, _auto_registry)
		)
		if port == null:
			return
		# Fail closed during the synchronous callback: no belt can accept
		# material between receiver creation and its original escrow binding.
		port.enable_isolated_escrow_intake_lock = true
		if not port.bind_escrow_intake_lock(_auto_escrow):
			port.enable_isolated_input = false
			push_error("Autowire failed after owner claim; receiver kept disabled")
			return
		_auto_attached.append({"site": weakref(site), "port": weakref(port)})
		return


func _autowire_ready() -> bool:
	return (
		_auto_configured and enable_isolated_authorization_autowire
		and _host_ready()
		and _live_autowire_node(_auto_registry)
		and _live_autowire_node(_auto_escrow)
		and _auto_registry.get_parent() == get_parent()
		and _auto_escrow.get_parent() == get_parent()
		and _auto_registry.enable_isolated_site_registry
	)


func _live_autowire_node(node: Node) -> bool:
	return (
		is_instance_valid(node) and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)


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
