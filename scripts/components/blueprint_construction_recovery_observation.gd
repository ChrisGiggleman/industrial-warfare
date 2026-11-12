extends Node
class_name BlueprintConstructionRecoveryObservation

# =============================================================================
# E3D5C4K — TEST-ONLY, READ-ONLY RECOVERY OBSERVATION FORMAT
# =============================================================================
# Data-only JSON snapshot of the E3d5c4j recovery audit. The caller-provided
# owner label is NOT yet an authoritative, persistent unique ID.
# No import, restore, escrow mutation, claim release, power or worker actions.
# Both playable scenes remain opted out.

const SCHEMA_VERSION: int = 1
@export var enable_isolated_observation: bool = false

var _audit_ref: WeakRef = null
var _owner_label: String = ""


func configure(
	audit: BlueprintConstructionReceiverRecoveryAudit,
	owner_label: String
) -> bool:
	if not enable_isolated_observation or _audit_ref != null:
		return false
	if not _live(audit) or not _valid_label(owner_label):
		return false
	var state: Dictionary = audit.inspect()
	if (
		not bool(state.get("known", false))
		or not bool(state.get("claim_locked", false))
		or bool(state.get("safe_to_release", true))
	):
		return false
	_audit_ref = weakref(audit)
	_owner_label = owner_label
	return true


func observe() -> Dictionary:
	if not enable_isolated_observation or _audit_ref == null:
		return {}
	var audit: BlueprintConstructionReceiverRecoveryAudit = (
		_audit_ref.get_ref() as BlueprintConstructionReceiverRecoveryAudit
	)
	if not _live(audit):
		return {}
	var state: Dictionary = audit.inspect()
	if (
		not bool(state.get("known", false))
		or not bool(state.get("claim_locked", false))
		or bool(state.get("safe_to_release", true))
	):
		return {}
	var raw_blockers: Variant = state.get("blockers", [])
	if not raw_blockers is Array:
		return {}
	var blockers: Array[String] = []
	for entry: Variant in raw_blockers:
		if typeof(entry) not in [TYPE_STRING, TYPE_STRING_NAME]:
			return {}
		blockers.append(str(entry))
	var record: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"owner_label": _owner_label,
		"site_ended": bool(state.get("site_ended", false)),
		"buffered_units": int(state.get("buffered", -1)),
		"belt_cargo_units": int(state.get("belt_cargo", -1)),
		"escrow_outstanding": bool(state.get("escrow_outstanding", true)),
		"belt_connected": bool(state.get("belt_connected", true)),
		"claim_locked": true,
		"drained_observed": bool(state.get("drained_observed", false)),
		"safe_to_release": false,
		"blockers": blockers
	}
	if not validate_record(record):
		return {}
	return record


func encode_observation() -> String:
	var record: Dictionary = observe()
	return "" if record.is_empty() else JSON.stringify(record)


# Validates descriptive data, never reconstructs live world ownership.
static func decode_checked(raw_json: String) -> Dictionary:
	if raw_json.is_empty() or raw_json.length() > 4096:
		return {}
	var parsed: Variant = JSON.parse_string(raw_json)
	if not parsed is Dictionary:
		return {}
	var record: Dictionary = parsed
	return record.duplicate(true) if validate_record(record) else {}


static func validate_record(record: Dictionary) -> bool:
	var keys: Array[String] = [
		"schema_version", "owner_label", "site_ended", "buffered_units",
		"belt_cargo_units", "escrow_outstanding", "belt_connected",
		"claim_locked", "drained_observed", "safe_to_release", "blockers"
	]
	if record.size() != keys.size():
		return false
	for key: String in keys:
		if not record.has(key):
			return false
	if (
		typeof(record["schema_version"]) != TYPE_INT
		or int(record["schema_version"]) != SCHEMA_VERSION
		or typeof(record["owner_label"]) != TYPE_STRING
		or not _valid_label(str(record["owner_label"]))
	):
		return false
	for key: String in [
		"site_ended", "escrow_outstanding", "belt_connected",
		"claim_locked", "drained_observed", "safe_to_release"
	]:
		if typeof(record[key]) != TYPE_BOOL:
			return false
	for key: String in ["buffered_units", "belt_cargo_units"]:
		if typeof(record[key]) != TYPE_INT or int(record[key]) < 0:
			return false
	if not bool(record["claim_locked"]) or bool(record["safe_to_release"]):
		return false
	if not record["blockers"] is Array:
		return false
	var blockers: Array = record["blockers"]
	if blockers.size() > 12:
		return false
	var seen: Dictionary = {}
	for item: Variant in blockers:
		if typeof(item) != TYPE_STRING or str(item).is_empty():
			return false
		if str(item).length() > 64 or seen.has(item):
			return false
		seen[item] = true
	var required: Array[String] = []
	if not bool(record["site_ended"]):
		required.append("site_not_ended")
	if bool(record["belt_connected"]):
		required.append("belt_still_connected")
	if int(record["belt_cargo_units"]) > 0:
		required.append("belt_cargo_outstanding")
	if int(record["buffered_units"]) > 0:
		required.append("staging_stock_outstanding")
	if bool(record["escrow_outstanding"]):
		required.append("escrow_outstanding")
	for reason: String in required:
		if not blockers.has(reason):
			return false
	if bool(record["drained_observed"]) != blockers.is_empty():
		return false
	return true


static func _valid_label(label: String) -> bool:
	# Correlation only; no claim that this is a trusted save-game UUID.
	return (
		label.length() >= 8
		and label.length() <= 64
		and label.begins_with("site_")
		and label.is_valid_identifier()
	)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
