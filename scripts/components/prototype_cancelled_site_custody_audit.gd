extends Node
class_name PrototypeCancelledSiteCustodyAudit

## E3d5c6c Stage A — read-only cancelled construction custody provenance.
## This never moves cargo, refunds inventory, unlocks a staging claim, starts
## a drone, authorizes a building, or advances a construction job.
## Explicitly instantiated by isolated F6 or Stage C opt-in; default OFF.

const EXACT_SCENE := "res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn"
const STAGE_C_SCENE := "res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn"
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")

@export var enable_isolated_custody_audit: bool = false

var _registry: BlueprintConstructionSiteStagingRegistry
var _escrow: BlueprintConstructionMaterialEscrow
var _configured: bool = false
var _next_id: int = 1
var _records: Dictionary = {}


func _live(node: Variant) -> bool:
	return node is Node and is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func _scope() -> Node3D:
	var parent := get_parent() as Node3D
	if not _live(parent) or parent.scene_file_path not in [EXACT_SCENE, STAGE_C_SCENE]:
		return null
	return parent


func _enabled() -> bool:
	var scope := _scope()
	return (
		enable_isolated_custody_audit and _configured and scope != null
		and _live(self) and _live(_registry) and _live(_escrow)
		and _registry.get_parent() == scope and _escrow.get_parent() == scope
		and _registry.enable_isolated_site_registry
	)


func configure(registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow) -> bool:
	var scope := _scope()
	if (
		not enable_isolated_custody_audit or _configured or scope == null
		or not _live(registry) or registry.get_parent() != scope
		or not registry.enable_isolated_site_registry
		or not _live(escrow) or escrow.get_parent() != scope
	):
		return false
	_registry = registry
	_escrow = escrow
	_configured = true
	return true


func _bill_count(definition: BuildingDefinition) -> int:
	var expected: int = 0
	if definition == STORAGE:
		expected = 3
	elif definition == PRESS:
		expected = 5
	else:
		return 0
	var bill: Dictionary = ConstructionMaterialBill.get_costs(definition)
	if bill.size() != 1 or int(bill.get(INGOT, 0)) != expected:
		return 0
	return expected


# Capture before the original site is cancelled/freed; callers cannot supply
# item quantities, alternate buffers, an authorizing job, or replacement site.
# The registry checks the actual site's immutable owned buffer association.
func capture_site(site: ConstructionSite, staging: BlueprintConstructionMaterialStaging, port: BlueprintConstructionStagingInputPort) -> int:
	if not _enabled() or not _live(site) or site.get_parent() != _scope():
		return 0
	if site.job == null or site.job.state not in [
		ConstructionJob.State.QUEUED,
		ConstructionJob.State.CONSTRUCTING,
		ConstructionJob.State.PAUSED
	]:
		return 0
	var amount: int = _bill_count(site.target_definition)
	if amount <= 0 or not _live(staging) or staging.get_parent() != _scope():
		return 0
	if not _live(port) or not _live(port.get_parent()) or port.get_parent().get_parent() != _scope():
		return 0
	var buffer: InventoryComponent = staging.get_staged_inventory()
	if not _live(buffer) or not staging.matches_definition(site.target_definition):
		return 0
	if not _registry.matches_owned_inventory(site, buffer) or not _registry.has_locked_pair(staging, port):
		return 0
	if port.get_bound_staging() != staging or port.inventory != buffer:
		return 0
	var hover: Vector3 = site.global_position + Vector3.UP * 2.0
	if not port.global_position.is_equal_approx(hover):
		return 0
	if buffer.get_total_amount() < 0 or buffer.get_total_amount() > amount or buffer.get_amount(INGOT) != buffer.get_total_amount():
		return 0
	for record: Dictionary in _records.values():
		if record["original_job"] == site.job or record["original_site_id"] == site.get_instance_id():
			return 0
	var existing_escrow: int = _escrow.reservation_for(site)
	if existing_escrow > 0 and not _escrow.matches_site_source_bill(site, buffer):
		return 0
	var id: int = _next_id
	_next_id += 1
	_records[id] = {
		"original_site": weakref(site),
		"original_site_id": site.get_instance_id(),
		"original_job": site.job,
		"original_definition": site.target_definition,
		"hover": hover,
		"staging": weakref(staging),
		"port": weakref(port),
		"buffer": weakref(buffer),
		"expected": amount,
		"escrow_id": existing_escrow,
		"cancel_seen": false
	}
	site.job.job_cancelled.connect(_on_cancelled.bind(id))
	return id


# Job cancellation signal executes synchronously before the site is freed.
# The escrow might refund before or after this callback; preserve its exact
# reservation ID for a later read-only settlement check either way.
func _on_cancelled(id: int) -> void:
	if not _records.has(id):
		return
	var record: Dictionary = _records[id]
	var job: ConstructionJob = record["original_job"]
	if job.state != ConstructionJob.State.CANCELLED or bool(record["cancel_seen"]):
		return
	var site := (record["original_site"] as WeakRef).get_ref() as ConstructionSite
	if is_instance_valid(site) and site.job == job:
		record["escrow_id"] = maxi(int(record["escrow_id"]), _escrow.reservation_for(site))
	record["cancel_seen"] = true
	_records[id] = record


func ticket_count() -> int:
	return _records.size()


# E3d5c6c Stage B — opt-in companion-only source resolution. The accepted
# Stage A audit stays read-only for all other callers. A real locked original
# receiver and terminal escrow settlement are reverified every time.
@export var enable_isolated_stage_b_source_access: bool = false


func _recovery_source_for(id: int, controller: Node) -> Dictionary:
	if not enable_isolated_stage_b_source_access or not _enabled() or not _records.has(id):
		return {}
	if not _live(controller) or controller.get_parent() != _scope():
		return {}
	if controller.get_script() == null or controller.get_script().resource_path != "res://scripts/components/prototype_cancelled_site_recovery_transport.gd":
		return {}
	if not controller.has_method("_audit_owned") or not bool(controller.call("_audit_owned", self)):
		return {}
	var snapshot: Dictionary = observe(id)
	if snapshot.get("status") != &"ready_read_only":
		return {}
	var record: Dictionary = _records[id]
	var buffer := (record["buffer"] as WeakRef).get_ref() as InventoryComponent
	var staging := (record["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
	var port := (record["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
	if not _live(buffer) or not _live(staging) or not _live(port):
		return {}
	if staging.get_staged_inventory() != buffer or port.get_bound_staging() != staging or port.inventory != buffer:
		return {}
	if not _registry.has_locked_pair(staging, port) or not port.global_position.is_equal_approx(record["hover"]):
		return {}
	return {
		"buffer": buffer, "port": port, "staging": staging,
		"amount": int(snapshot["amount"]), "hover": snapshot["hover_position"],
		"original_site_id": int(snapshot["original_site_id"])
	}


# Diagnostic only: NEVER expose the original inventory or port as a mutable
# return object, and never interpret reservation counts as physical material.
# A terminal site may have been freed; unique staging+port+buffer identity is
# the retained ownership proof and prevents cross-site weakref-null matching.
func observe(id: int) -> Dictionary:
	var result: Dictionary = {"status": &"unavailable", "amount": 0, "expected": 0}
	if not _enabled() or not _records.has(id):
		return result
	var record: Dictionary = _records[id]
	var job: ConstructionJob = record["original_job"]
	if job.state == ConstructionJob.State.COMPLETE:
		result["status"] = &"complete_not_recoverable"
		return result
	if job.state != ConstructionJob.State.CANCELLED or not bool(record["cancel_seen"]):
		result["status"] = &"active_not_recoverable"
		return result
	result["status"] = &"quarantined"
	var staging := (record["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
	var port := (record["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
	var buffer := (record["buffer"] as WeakRef).get_ref() as InventoryComponent
	if not _live(staging) or staging.get_parent() != _scope() or not _live(port) or not _live(buffer):
		return result
	if not _live(port.get_parent()) or port.get_parent().get_parent() != _scope():
		return result
	if not _registry.has_locked_pair(staging, port):
		return result
	if staging.get_staged_inventory() != buffer or port.get_bound_staging() != staging or port.inventory != buffer:
		return result
	if not port.global_position.is_equal_approx(record["hover"]):
		return result
	var existing_escrow: int = int(record["escrow_id"])
	if existing_escrow > 0 and _escrow.has_reservation(existing_escrow):
		result["status"] = &"escrow_unsettled"
		return result
	var amount: int = buffer.get_amount(INGOT)
	if amount != buffer.get_total_amount() or amount < 0 or amount > int(record["expected"]):
		return result
	result["amount"] = amount
	result["expected"] = int(record["expected"])
	result["original_site_id"] = int(record["original_site_id"])
	result["hover_position"] = record["hover"]
	result["definition_id"] = (record["original_definition"] as BuildingDefinition).building_id
	result["status"] = &"empty_no_pickup" if amount == 0 else (&"ready_read_only" if amount == int(record["expected"]) else &"quarantined")
	return result
