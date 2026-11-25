extends Node
class_name SpecializedDroneRoleContractsE3d5c6f

## Stage A only: opt-in bookkeeping and immutable internal receipt snapshots.
## No _process, no simulation tick, inventory writes, worker grant or movement.
@export var enable_stage_a_contracts: bool = false
const EXACT_SCOPE := "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn"
const LOGISTICS := &"logistics"
const BUILDER := &"builder"

var _leases: Dictionary = {}
var _receipts: Dictionary = {}
var _serial: int = 0

func _scope_ok() -> bool:
	return enable_stage_a_contracts and is_inside_tree() and owner != null and owner.scene_file_path == EXACT_SCOPE

func _live(node: Node) -> bool:
	return is_instance_valid(node) and not node.is_queued_for_deletion() and node.is_inside_tree()

func _site_queued(site: ConstructionSite, queue: BlueprintConstructionPriorityQueue) -> bool:
	return _live(site) and _live(queue) and site.job != null and site.job.state == ConstructionJob.State.QUEUED and queue.get_waiting_sites().has(site)

func _lease_valid(lease: Dictionary) -> bool:
	var site := (lease["site"] as WeakRef).get_ref() as ConstructionSite
	var drone := (lease["drone"] as WeakRef).get_ref() as Node
	return _live(site) and _live(drone) and site.job == lease["job"] and site.target_definition == lease["definition"] and site.job.state == ConstructionJob.State.QUEUED

func claim_logistics(site: ConstructionSite, drone: Node, queue: BlueprintConstructionPriorityQueue, registry: BlueprintConstructionSiteStagingRegistry, buffer: InventoryComponent) -> int:
	if not _scope_ok() or not _site_queued(site, queue) or not _live(drone) or not _live(registry) or not _live(buffer):
		return 0
	if not registry.matches_owned_inventory(site, buffer):
		return 0
	if ConstructionMaterialBill.get_costs(site.target_definition).is_empty() or not _leases.is_empty():
		return 0
	_serial += 1
	_leases[_serial] = {"role": LOGISTICS, "site": weakref(site), "job": site.job, "definition": site.target_definition, "drone": weakref(drone), "buffer": weakref(buffer), "registry": weakref(registry)}
	return _serial

## Receipt cannot be supplied by the caller. The snapshot is stored internally.
## The escrow and registry own the material truth; no item duplication here.
func seal_handoff(lease_id: int, escrow: BlueprintConstructionMaterialEscrow) -> int:
	if not _scope_ok() or not _leases.has(lease_id) or not _live(escrow):
		return 0
	var lease: Dictionary = _leases[lease_id]
	if lease["role"] != LOGISTICS or lease.get("revoked", false) or not _lease_valid(lease) or _receipts.has(lease_id):
		return 0
	var site := (lease["site"] as WeakRef).get_ref() as ConstructionSite
	var buffer := (lease["buffer"] as WeakRef).get_ref() as InventoryComponent
	var registry := (lease["registry"] as WeakRef).get_ref() as BlueprintConstructionSiteStagingRegistry
	if not _live(buffer) or not _live(registry) or not registry.matches_owned_inventory(site, buffer):
		return 0
	if not escrow.matches_site_source_bill(site, buffer):
		return 0
	var escrow_id: int = escrow.reservation_for(site)
	if escrow_id <= 0:
		return 0
	_receipts[lease_id] = {"site": lease["site"], "job": lease["job"], "definition": lease["definition"], "buffer": lease["buffer"], "registry": lease["registry"], "escrow": weakref(escrow), "escrow_id": escrow_id, "bill": ConstructionMaterialBill.get_costs(site.target_definition), "logistics_drone": lease["drone"], "revoked": false}
	return lease_id

func receipt_valid(receipt_id: int) -> bool:
	if not _scope_ok() or not _receipts.has(receipt_id):
		return false
	var proof: Dictionary = _receipts[receipt_id]
	if proof["revoked"]:
		return false
	var site := (proof["site"] as WeakRef).get_ref() as ConstructionSite
	var buffer := (proof["buffer"] as WeakRef).get_ref() as InventoryComponent
	var registry := (proof["registry"] as WeakRef).get_ref() as BlueprintConstructionSiteStagingRegistry
	var escrow := (proof["escrow"] as WeakRef).get_ref() as BlueprintConstructionMaterialEscrow
	var logistics := (proof["logistics_drone"] as WeakRef).get_ref() as Node
	return _live(site) and _live(buffer) and _live(registry) and _live(escrow) and _live(logistics) and site.job == proof["job"] and site.job.state == ConstructionJob.State.QUEUED and site.target_definition == proof["definition"] and registry.matches_owned_inventory(site, buffer) and escrow.reservation_for(site) == proof["escrow_id"] and escrow.matches_site_source_bill(site, buffer) and escrow.held_materials(proof["escrow_id"]) == proof["bill"] and ConstructionMaterialBill.get_costs(site.target_definition) == proof["bill"]

func claim_builder(receipt_id: int, builder: Node) -> bool:
	if not receipt_valid(receipt_id) or not _live(builder) or not _leases.has(receipt_id):
		return false
	var logistics := (_receipts[receipt_id]["logistics_drone"] as WeakRef).get_ref() as Node
	if builder == logistics:
		return false
	for key: Variant in _leases.keys():
		if key != receipt_id and (_leases[key]["drone"] as WeakRef).get_ref() == builder:
			return false
	var lease: Dictionary = _leases[receipt_id]
	if lease.has("builder"):
		return false
	lease["builder"] = weakref(builder)
	return true

## Fail-closed tombstone: never release escrow, inventory, or recovery custody.
func revoke(receipt_or_lease_id: int) -> bool:
	if not _scope_ok() or not _leases.has(receipt_or_lease_id):
		return false
	if _receipts.has(receipt_or_lease_id):
		_receipts[receipt_or_lease_id]["revoked"] = true
	_leases[receipt_or_lease_id]["revoked"] = true
	return true

func builder_claim_valid(receipt_id: int, builder: Node) -> bool:
	if not receipt_valid(receipt_id) or not _leases.has(receipt_id):
		return false
	var lease: Dictionary = _leases[receipt_id]
	return lease.has("builder") and _live(builder) and (lease["builder"] as WeakRef).get_ref() == builder

func lease_count() -> int:
	return _leases.size()

# Read-only exact lease observation for C2, including its terminal tombstone.
# No authority to transfer cargo or grant a worker.
func c2_logistics_lease_matches(id: int, job: ConstructionJob, drone: Node, revoked: bool) -> bool:
	if not _scope_ok() or id <= 0 or not _leases.has(id) or not _live(drone) or job == null:
		return false
	var lease: Dictionary = _leases[id]
	return lease["role"] == LOGISTICS and lease["job"] == job and (lease["drone"] as WeakRef).get_ref() == drone and bool(lease.get("revoked", false)) == revoked and not _receipts.has(id) and not lease.has("builder")

func c3_logistics_lease_matches(id: int, job: ConstructionJob, drone: Node, revoked: bool) -> bool:
	if not _scope_ok() or id <= 0 or not _leases.has(id) or not _live(drone) or job == null:
		return false
	var lease: Dictionary = _leases[id]
	if lease["role"] != LOGISTICS or lease["job"] != job or (lease["drone"] as WeakRef).get_ref() != drone or bool(lease.get("revoked", false)) != revoked or lease.has("builder"):
		return false
	if _receipts.has(id):
		var receipt: Dictionary = _receipts[id]
		return receipt["job"] == job and (receipt["logistics_drone"] as WeakRef).get_ref() == drone and bool(receipt["revoked"]) == revoked
	return true
