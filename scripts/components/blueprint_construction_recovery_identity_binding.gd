extends Node
class_name BlueprintConstructionRecoveryIdentityBinding

# =============================================================================
# E3D5C4M — TEST-ONLY VERIFIED SITE ID -> LIVE RECOVERY OBSERVATION
# =============================================================================
# Binds an existing E3d5c4k observation to the ID that E3d5c4l already
# issued to the SAME QUEUED ConstructionSite audited by E3d5c4j.
# No arbitrary label supplied by callers; no automatic ID issuance.
#
# Once the site is cancelled/freed, only the original ledger tombstone and
# the same live recovery audit may supply further read-only observations.
# Missing/disabled services fail closed. No release, import, load/save,
# inventory mutation, power, workers or construction dispatch is possible.
# This adapter must NOT be attached to Main or Factory Testing Sandbox.

@export var enable_isolated_identity_binding: bool = false

var _ledger_ref: WeakRef = null
var _audit_ref: WeakRef = null
var _observation_ref: WeakRef = null
var _site_id: String = ""


func configure(
	site: ConstructionSite,
	ledger: BlueprintConstructionSiteIdentityLedger,
	audit: BlueprintConstructionReceiverRecoveryAudit,
	observation: BlueprintConstructionRecoveryObservation
) -> bool:
	if (
		not enable_isolated_identity_binding
		or not is_inside_tree()
		or not _site_id.is_empty()
		or not _live(site)
		or not _live(ledger)
		or not _live(audit)
		or not _live(observation)
		or not ledger.enable_isolated_identity
		or not observation.enable_isolated_observation
		or not audit.matches_queued_site(site)
	):
		return false
	# LOOK UP an existing issued ID; do not create one as a side effect of
	# requesting a recovery observation.
	var id: String = ledger.id_for_site(site)
	if not BlueprintConstructionSiteIdentityLedger.is_valid_id(id):
		return false
	var identity: Dictionary = ledger.observe_id(id)
	if (
		identity.is_empty()
		or str(identity.get("site_id", "")) != id
		or bool(identity.get("site_ended", true))
		or not bool(identity.get("identity_retained", false))
		or bool(identity.get("safe_to_release", true))
	):
		return false
	# The E3d5c4k formatter is bound exactly once to the verified ID.
	# A previously configured, arbitrary-label formatter is rejected.
	if not observation.configure(audit, id):
		return false
	_ledger_ref = weakref(ledger)
	_audit_ref = weakref(audit)
	_observation_ref = weakref(observation)
	_site_id = id
	return true


func observe_verified() -> Dictionary:
	if not enable_isolated_identity_binding or _site_id.is_empty():
		return {}
	var ledger := _ref_node(_ledger_ref) as BlueprintConstructionSiteIdentityLedger
	var audit := _ref_node(_audit_ref) as BlueprintConstructionReceiverRecoveryAudit
	var observation := _ref_node(_observation_ref) as BlueprintConstructionRecoveryObservation
	if not _live(ledger) or not _live(audit) or not _live(observation):
		return {}
	if not ledger.enable_isolated_identity:
		return {}
	var identity: Dictionary = ledger.observe_id(_site_id)
	var recovery: Dictionary = observation.observe()
	if identity.is_empty() or recovery.is_empty():
		return {}
	if (
		str(identity.get("site_id", "")) != _site_id
		or not bool(identity.get("identity_retained", false))
		or bool(identity.get("safe_to_release", true))
		or str(recovery.get("owner_label", "")) != _site_id
		or not bool(recovery.get("claim_locked", false))
		or bool(recovery.get("safe_to_release", true))
		or bool(identity.get("site_ended", false)) != bool(recovery.get("site_ended", true))
		or not BlueprintConstructionRecoveryObservation.validate_record(recovery)
	):
		return {}
	return recovery.duplicate(true)


func encode_verified() -> String:
	var record: Dictionary = observe_verified()
	return "" if record.is_empty() else JSON.stringify(record)


func bound_site_id() -> String:
	# Informational only; not an authorization token.
	return _site_id if enable_isolated_identity_binding else ""


func _ref_node(ref: WeakRef) -> Node:
	if ref == null:
		return null
	return ref.get_ref() as Node


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
