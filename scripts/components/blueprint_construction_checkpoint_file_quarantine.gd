extends Node
class_name BlueprintConstructionCheckpointFileQuarantine

# =============================================================================
# E3D5C4O — TEST-ONLY TWO-GENERATION CHECKPOINT FILE QUARANTINE
# =============================================================================
# A bounded two-slot disk experiment for descriptive E3d5c4n snapshots.
# Every slot is immutable once published. A .part is written, read back,
# validated and renamed into a slot that MUST NOT exist beforehand.
#
# This is NOT an atomic multi-object saved game, restart-proof transaction,
# authenticated data source, restoration engine, or release authority.
# A digest detects accidental byte changes, NOT malicious rewriting.
# Reading an older valid record is labelled STALE_FOR_INSPECTION.
# Never put this test-only component into Main or Factory Testing Sandbox.

const ENVELOPE_VERSION: int = 1
const MAX_FILE_BYTES: int = 32768
const SLOT_ONE: String = "user://industrial_warfare_e3d5c4o_test_slot_1.json"
const SLOT_TWO: String = "user://industrial_warfare_e3d5c4o_test_slot_2.json"

@export var enable_isolated_disk_test: bool = false


static func slot_path(generation: int) -> String:
	match generation:
		1:
			return SLOT_ONE
		2:
			return SLOT_TWO
	return ""


static func temp_path(generation: int) -> String:
	var path: String = slot_path(generation)
	return path + ".part" if not path.is_empty() else ""


func write_once(
	generation: int,
	checkpoint: BlueprintConstructionRecoveryCheckpoint,
	record: Dictionary
) -> bool:
	if (
		not enable_isolated_disk_test
		or not is_inside_tree()
		or not _live(checkpoint)
		or not checkpoint.enable_isolated_checkpoint
	):
		return false
	var final_path: String = slot_path(generation)
	var pending_path: String = temp_path(generation)
	if final_path.is_empty():
		return false
	# Refuse overwrite, including an unfinished earlier write.
	if FileAccess.file_exists(final_path) or FileAccess.file_exists(pending_path):
		return false
	var payload: String = checkpoint.encode_record(record)
	if payload.is_empty() or payload.length() > 16384:
		return false
	var envelope: Dictionary = {
		"envelope_version": ENVELOPE_VERSION,
		"generation": generation,
		"checkpoint_json": payload,
		"sha256": payload.sha256_text()
	}
	var raw_text: String = JSON.stringify(envelope)
	if raw_text.to_utf8_buffer().size() > MAX_FILE_BYTES:
		return false

	var file := FileAccess.open(pending_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(raw_text)
	file.flush()
	file.close()
	# Validate the staged bytes before any publication.
	if _read_valid(pending_path, generation).is_empty():
		return false
	if FileAccess.file_exists(final_path):
		return false
	var error: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(pending_path),
		ProjectSettings.globalize_path(final_path)
	)
	if error != OK:
		return false
	return not _read_valid(final_path, generation).is_empty()


# The returned record is UNTRUSTED, DESCRIPTIVE DATA ONLY.
func read_slot(generation: int) -> Dictionary:
	if not enable_isolated_disk_test:
		return {}
	var path: String = slot_path(generation)
	if path.is_empty():
		return {}
	return _read_valid(path, generation)


# The older slot is an inspection fallback, NEVER a restore candidate.
func read_for_inspection() -> Dictionary:
	var result: Dictionary = {
		"status": "none",
		"generation": 0,
		"record": {},
		"safe_to_release": false,
		"can_restore": false
	}
	if not enable_isolated_disk_test:
		return result
	var newer: Dictionary = read_slot(2)
	if not newer.is_empty():
		result["status"] = "newer_valid_for_inspection"
		result["generation"] = 2
		result["record"] = newer
		return result

	var older: Dictionary = read_slot(1)
	if older.is_empty():
		return result
	result["generation"] = 1
	result["record"] = older
	result["status"] = (
		"stale_fallback_for_inspection"
		if FileAccess.file_exists(SLOT_TWO)
		else "older_only_for_inspection"
	)
	return result


static func _read_valid(path: String, expected_generation: int) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	if file.get_length() <= 0 or file.get_length() > MAX_FILE_BYTES:
		file.close()
		return {}
	var raw: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not parsed is Dictionary:
		return {}
	var envelope: Dictionary = parsed
	if (
		envelope.size() != 4
		or not envelope.has("envelope_version")
		or not envelope.has("generation")
		or not envelope.has("sha256")
		or not envelope.has("checkpoint_json")
		or not _exact_number(envelope["envelope_version"], ENVELOPE_VERSION)
		or not _exact_number(envelope["generation"], expected_generation)
		or typeof(envelope["checkpoint_json"]) != TYPE_STRING
		or typeof(envelope["sha256"]) != TYPE_STRING
	):
		return {}
	var payload: String = envelope["checkpoint_json"]
	if payload.is_empty() or payload.length() > 16384:
		return {}
	if str(envelope["sha256"]) != payload.sha256_text():
		return {}
	return BlueprintConstructionRecoveryCheckpoint.decode_checked(payload)


static func _exact_number(value: Variant, expected: int) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	return float(value) == float(expected)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
