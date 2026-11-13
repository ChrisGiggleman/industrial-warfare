extends Node
class_name BlueprintConstructionSiteIdentityLedger

# =============================================================================
# E3D5C4L — ISOLATED SESSION-STABLE CONSTRUCTION SITE IDENTITY
# =============================================================================
# Issues a randomly generated UUIDv4-style ID to a real, live ConstructionSite.
# Keeps a retired/tombstone record even after cancellation or node destruction.
# NO removal, reassignment, import, save/load or authoritative claim restore.
#
# This is a process-local registry, NOT a persistent save file or an
# authentication mechanism. It neither grants construction authorization
# nor changes resource, power, worker, job, or escrow state. Do not attach
# this experimental ledger to Main or Factory Testing Sandbox.

const SCHEMA_VERSION: int = 1
const ID_PREFIX: String = "site_"
const HEX_ALPHABET: String = "0123456789abcdef"

@export var enable_isolated_identity: bool = false

var _records: Dictionary = {}


func issue_id(site: ConstructionSite) -> String:
	if not enable_isolated_identity or not _live(site):
		return ""
	if not is_instance_valid(site.target_definition) or site.job == null:
		return ""
	if site.job.state not in [
		ConstructionJob.State.PLANNED, ConstructionJob.State.QUEUED
	]:
		return ""

	# The same live site retains its ID, independent of name, position,
	# priority or authorization. No new ID is generated on repeated calls.
	var previous: String = id_for_site(site)
	if not previous.is_empty():
		return previous

	# OS-backed random bytes rather than scene-path/instance-ID addresses.
	var crypto := Crypto.new()
	for attempt: int in range(8):
		var bytes: PackedByteArray = crypto.generate_random_bytes(16)
		if bytes.size() != 16:
			return ""
		bytes[6] = (int(bytes[6]) & 15) | 64
		bytes[8] = (int(bytes[8]) & 63) | 128
		var label: String = ID_PREFIX + bytes.hex_encode()
		if _records.has(label) or not is_valid_id(label):
			continue
		_records[label] = {
			"site": weakref(site),
			"ended": false
		}
		site.job.job_cancelled.connect(_mark_ended.bind(label))
		site.tree_exiting.connect(_mark_ended.bind(label))
		return label
	return ""


func id_for_site(site: ConstructionSite) -> String:
	if not enable_isolated_identity or not _live(site):
		return ""
	for key: Variant in _records.keys():
		var record: Dictionary = _records[key]
		var weak: WeakRef = record["site"] as WeakRef
		if weak != null and weak.get_ref() == site:
			return str(key)
	return ""


# A tombstone is intentionally *retained* when the original scene Node dies.
# Even an ended, drained site record does not unlock a material receiver.
func observe_id(id: String) -> Dictionary:
	if not enable_isolated_identity or not is_valid_id(id):
		return {}
	if not _records.has(id):
		return {}
	var record: Dictionary = _records[id]
	var site_weak: WeakRef = record["site"] as WeakRef
	var site: ConstructionSite = null
	if site_weak != null:
		site = site_weak.get_ref() as ConstructionSite
	var ended: bool = bool(record["ended"]) or not _live(site)
	return {
		"schema_version": SCHEMA_VERSION,
		"site_id": id,
		"site_ended": ended,
		"identity_retained": true,
		"safe_to_release": false
	}


func identity_count() -> int:
	return _records.size() if enable_isolated_identity else 0


static func is_valid_id(id: String) -> bool:
	if not id.begins_with(ID_PREFIX) or id.length() != 37:
		return false
	var hex: String = id.substr(5, 32)
	for i: int in range(32):
		if not HEX_ALPHABET.contains(hex.substr(i, 1)):
			return false
	# RFC 4122 v4 nibble and 10xx variant nibble; no punctuation.
	return hex.substr(12, 1) == "4" and "89ab".contains(hex.substr(16, 1))


func _mark_ended(id: String) -> void:
	if not _records.has(id):
		return
	var record: Dictionary = _records[id]
	record["ended"] = true
	_records[id] = record


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
