extends "res://scripts/ui/playable_automatic_construction_drone_sandbox.gd"
class_name PlayableCancelledSiteRecoveryE3d5c6cStageC

## E3d5c6c Stage C — separately gated, playable, SINGLE-DRIVER recovery.
## The accepted Direct Build and Main scenes continue using the original
## adapter. This subclass is installed ONLY by the exact Stage C test scene.
## No parallel _process, second drone, fabricated stock, or escrow shortcut.
const EXACT_PLAYABLE := "res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn"
const UNIFIED_STAGE_A := "res://scenes/core/playable_unified_construction_e3d5c6d.tscn"
const Audit = preload("res://scripts/components/prototype_cancelled_site_custody_audit.gd")
const Transport = preload("res://scripts/components/prototype_cancelled_site_recovery_transport.gd")

var custody: PrototypeCancelledSiteCustodyAudit
var recovery: PrototypeCancelledSiteRecoveryTransport
var recovery_tickets: Array[int] = []
var _recovery_configured: bool = false


func _is_sandbox_path(path: String) -> bool:
	return path in [EXACT_PLAYABLE, UNIFIED_STAGE_A]


func _direct_build_enabled() -> bool:
	return enable_direct_build_authorization and _live(_scope) and _scope.scene_file_path in [EXACT_PLAYABLE, UNIFIED_STAGE_A]


func start() -> bool:
	if not super.start():
		return false
	# The original adapter has completed registration, but this subclass
	# now takes over its sole tick entry. Quiesce before configuring transport.
	set_process(false)
	custody = Audit.new() as PrototypeCancelledSiteCustodyAudit
	custody.name = "CancelledSiteCustodyAudit"
	_scope.add_child(custody)
	custody.enable_isolated_custody_audit = true
	custody.enable_isolated_stage_b_source_access = true
	if not custody.configure(registry, escrow):
		push_error("E3d5c6c Stage C: custody configuration refused")
		return false
	recovery = Transport.new() as PrototypeCancelledSiteRecoveryTransport
	recovery.name = "CancelledSitePhysicalRecovery"
	_scope.add_child(recovery)
	recovery.enable_isolated_physical_recovery = true
	drone.enable_isolated_cancelled_staging_flight = true
	if not recovery.configure(self, custody):
		push_error("E3d5c6c Stage C: physical recovery configuration refused")
		return false
	_recovery_configured = true
	set_process(true)
	_refresh_feedback()
	print("E3d5c6c Stage C opt-in playable recovery enabled (single adapter tick)")
	return true


func _on_player_authorized(site: ConstructionSite) -> void:
	super._on_player_authorized(site)
	if not _recovery_configured or not is_enrolled_site(site):
		return
	# The original authorization path has already claimed the immutable
	# staging/port pair. Capture BEFORE X cancellation can free the site.
	for entry: Dictionary in _site_entries:
		if (entry["site"] as WeakRef).get_ref() != site or entry["job"] != site.job:
			continue
		if not entry.has("staging") or not entry.has("port"):
			return
		var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
		var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
		var ticket: int = custody.capture_site(site, staging, port)
		if ticket > 0:
			recovery_tickets.append(ticket)
		else:
			push_warning("E3d5c6c Stage C: site custody could not be captured")
		return


func _process(delta: float) -> void:
	if not _recovery_configured or not is_instance_valid(custody) or not is_instance_valid(recovery):
		super._process(delta)
		return
	if not is_finite(delta) or delta <= 0.0 or not has_verified_services():
		super._process(delta)
		return
	var step: float = minf(delta, MAX_FRAME_STEP)
	# Never drive the construction dispatcher while physical recovery is
	# active. All site->Storage->Hub->recharge legs use its SAME drone.
	if recovery.active_ticket() > 0:
		last_tick = recovery.tick(step)
		tick_count += 1
		_refresh_feedback()
		return
	# An older construction lifecycle must be allowed to return/rearm before
	# recovery can reserve a new destination or use the drone.
	if dispatch.has_lifecycle_assignment():
		super._process(delta)
		return
	for ticket: int in recovery_tickets:
		var snapshot: Dictionary = custody.observe(ticket)
		if snapshot.get("status") != &"ready_read_only":
			continue
		# Prioritize cancelled physical inventory over launching another job.
		# If the Storage dock is full/unavailable or energy is insufficient,
		# WAIT with unchanged custody; never debit staging remotely.
		if recovery.begin(ticket):
			last_tick = recovery.tick(step)
		else:
			last_tick = {"action": &"recovery_wait", "ticket": ticket}
		tick_count += 1
		_refresh_feedback()
		return
	# Normal original dispatch only when no previous or recovery mission
	# owns the drone. This is a call to the ORIGINAL single driver.
	super._process(delta)


func _build_feedback() -> void:
	super._build_feedback()
	if is_instance_valid(_status_label):
		_status_label.custom_minimum_size = Vector2(465, 205)


func _refresh_feedback() -> void:
	super._refresh_feedback()
	if not _recovery_configured or not is_instance_valid(_status_label) or not is_instance_valid(recovery):
		return
	var observation: Dictionary = recovery.observe()
	_status_label.text += "\nRecovery: %s | tickets %d | recovered %d" % [
		"ACTIVE" if recovery.active_ticket() > 0 else "WAITING / IDLE",
		recovery_tickets.size(), recovery.completed_count()
	]
	if recovery.active_ticket() > 0:
		_status_label.text += " | staged %d" % int(observation.get("amount", 0))
