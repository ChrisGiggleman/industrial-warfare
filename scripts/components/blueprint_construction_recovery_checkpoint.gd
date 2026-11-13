extends Node
class_name BlueprintConstructionRecoveryCheckpoint

# =============================================================================
# E3D5C4N — QUARANTINED, READ-ONLY MATERIAL OWNERSHIP CHECKPOINT
# =============================================================================
# Captures actual staging inventory, belt cargo inventory and outstanding
# escrow from EXACT services bound by an E3d5c4j audit, plus a verified
# ledger-issued session site ID (E3d5c4m). All item counts use ItemDefinition
# item_id values, not Resource/object pointers.
#
# This is a DESCRIPTIVE snapshot for an isolated F6 disk round-trip, NOT a
# production saved game. No import/rehydration, reserve, refund, release,
# authorization, construction timers, worker or power methods exist here.
# A checksum/JSON validation could not create authority; safe_to_release
# remains false. Main and Factory Testing Sandbox must not install this Node.

const SCHEMA_VERSION: int = 1
const MAX_UNITS: int = 1000000000

@export var enable_isolated_checkpoint: bool = false


func capture(
	binding: BlueprintConstructionRecoveryIdentityBinding,
	audit: BlueprintConstructionReceiverRecoveryAudit,
	staging: BlueprintConstructionMaterialStaging,
	belt: ConveyorSegment,
	escrow: BlueprintConstructionMaterialEscrow,
	reservation_id: int
) -> Dictionary:
	if not enable_isolated_checkpoint or not is_inside_tree():
		return {}
	if (
		not _live(binding)
		or not _live(audit)
		or not _live(staging)
		or not _live(belt)
		or not _live(escrow)
		or not audit.matches_material_sources(
			staging, belt, escrow, reservation_id
		)
	):
		return {}
	var recovery: Dictionary = binding.observe_verified()
	if recovery.is_empty():
		return {}
	var buffer: InventoryComponent = staging.get_staged_inventory()
	var transport := belt.get_node_or_null(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	if not _live(buffer) or not _live(transport):
		return {}
	var cargo: InventoryComponent = transport.cargo_inventory
	if not _live(cargo):
		return {}
	var buffer_result: Dictionary = _rows_from_items(buffer.items)
	var cargo_result: Dictionary = _rows_from_items(cargo.items)
	var escrow_result: Dictionary = _rows_from_items(
		escrow.held_materials(reservation_id)
	)
	if (
		not bool(buffer_result.get("ok", false))
		or not bool(cargo_result.get("ok", false))
		or not bool(escrow_result.get("ok", false))
	):
		return {}
	var snapshot: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"site_id": binding.bound_site_id(),
		"recovery": recovery,
		"staging_items": buffer_result["rows"],
		"belt_items": cargo_result["rows"],
		"escrow_items": escrow_result["rows"],
		"claim_locked": true,
		"safe_to_release": false
	}
	return snapshot if validate_record(snapshot) else {}


func encode_record(record: Dictionary) -> String:
	if not enable_isolated_checkpoint or not validate_record(record):
		return ""
	return JSON.stringify(record)


# Parsing is only for READING/INSPECTING a data record, never restoring it.
static func decode_checked(raw_json: String) -> Dictionary:
	if raw_json.is_empty() or raw_json.length() > 16384:
		return {}
	var decoded: Variant = JSON.parse_string(raw_json)
	if not decoded is Dictionary:
		return {}
	var record: Dictionary = decoded
	return record.duplicate(true) if validate_record(record) else {}


static func validate_record(record: Dictionary) -> bool:
	var expected_keys: Array[String] = [
		"schema_version", "site_id", "recovery", "staging_items",
		"belt_items", "escrow_items", "claim_locked", "safe_to_release"
	]
	if record.size() != expected_keys.size():
		return false
	for key: String in expected_keys:
		if not record.has(key):
			return false
	if (
		not _whole(record["schema_version"], SCHEMA_VERSION)
		or int(record["schema_version"]) != SCHEMA_VERSION
		or typeof(record["site_id"]) != TYPE_STRING
		or not BlueprintConstructionSiteIdentityLedger.is_valid_id(
			str(record["site_id"])
		)
		or typeof(record["claim_locked"]) != TYPE_BOOL
		or not bool(record["claim_locked"])
		or typeof(record["safe_to_release"]) != TYPE_BOOL
		or bool(record["safe_to_release"])
		or not record["recovery"] is Dictionary
	):
		return false
	var recovery: Dictionary = record["recovery"]
	if (
		not BlueprintConstructionRecoveryObservation.validate_record(recovery)
		or str(recovery["owner_label"]) != str(record["site_id"])
		or not bool(recovery["claim_locked"])
		or bool(recovery["safe_to_release"])
	):
		return false

	var staged_total: int = _total_rows(record["staging_items"])
	var belt_total: int = _total_rows(record["belt_items"])
	var held_total: int = _total_rows(record["escrow_items"])
	if staged_total < 0 or belt_total < 0 or held_total < 0:
		return false
	if (
		staged_total != int(recovery["buffered_units"])
		or belt_total != int(recovery["belt_cargo_units"])
	):
		return false
	if bool(recovery["escrow_outstanding"]) != (held_total > 0):
		return false
	return true


# Strictly ordered, unique rows keep repeated encodings deterministic.
static func _rows_from_items(items: Dictionary) -> Dictionary:
	var rows: Array[Dictionary] = []
	var used: Dictionary = {}
	for key: Variant in items.keys():
		var item: ItemDefinition = key as ItemDefinition
		if not is_instance_valid(item):
			return {}
		var item_id: String = str(item.item_id)
		if (
			item_id.is_empty()
			or not item_id.is_valid_identifier()
			or used.has(item_id)
			or not _whole(items[key], MAX_UNITS)
			or int(items[key]) <= 0
		):
			return {}
		used[item_id] = true
		rows.append({"item_id": item_id, "quantity": int(items[key])})
	rows.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return str(a["item_id"]) < str(b["item_id"])
	)
	return {"ok": true, "rows": rows}


static func _total_rows(raw_rows: Variant) -> int:
	if not raw_rows is Array:
		return -1
	var rows: Array = raw_rows
	if rows.size() > 128:
		return -1
	var total: int = 0
	var previous: String = ""
	for entry: Variant in rows:
		if not entry is Dictionary:
			return -1
		var row: Dictionary = entry
		if (
			row.size() != 2
			or not row.has("item_id")
			or not row.has("quantity")
			or typeof(row["item_id"]) != TYPE_STRING
			or not _whole(row["quantity"], MAX_UNITS)
		):
			return -1
		var item_id: String = str(row["item_id"])
		var amount: int = int(row["quantity"])
		if item_id.is_empty() or not item_id.is_valid_identifier():
			return -1
		if not previous.is_empty() and not (previous < item_id):
			return -1
		if amount <= 0 or total > MAX_UNITS - amount:
			return -1
		total += amount
		previous = item_id
	return total


static func _whole(value: Variant, maximum: int) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	var number: float = float(value)
	return (
		number >= 0.0
		and number <= float(maximum)
		and number == floorf(number)
	)


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
