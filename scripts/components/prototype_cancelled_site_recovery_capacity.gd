extends Node
class_name PrototypeCancelledSiteRecoveryCapacity

## E3d5c6c B1: reserve real Storage destination capacity against a verified
## terminal custody ticket. This is NOT a physical pickup or transfer driver.
## Feature is default OFF, added only by a new isolated F6 fixture.
const EXACT_SCENE := "res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn"
const INGOT = preload("res://data/items/test_ingot.tres")
const SCOPE_KEY: StringName = &"isolated_cancelled_site_recovery_capacity_owner"

@export var enable_isolated_recovery_capacity: bool = false

var _audit: PrototypeCancelledSiteCustodyAudit
var _discovery: PrototypeDroneStorageDiscovery
var _returns: PrototypeDroneReturnReservations
var _dispatch: PrototypeDroneAutomaticDispatch
var _drone: PrototypeConstructionWorkerDrone
var _configured: bool = false
var _claims: Dictionary = {}
var _next_id: int = 1


func _live(node: Variant) -> bool:
	return node is Node and is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func _scope() -> Node3D:
	var parent := get_parent() as Node3D
	if not _live(parent) or parent.scene_file_path != EXACT_SCENE:
		return null
	return parent


func _enabled() -> bool:
	var scope := _scope()
	return (
		enable_isolated_recovery_capacity and _configured and scope != null
		and _live(self) and _live(_audit) and _live(_discovery)
		and _live(_returns) and _live(_dispatch) and _live(_drone)
		and _audit.get_parent() == scope and _audit._enabled()
		and _discovery.get_parent() == scope and _discovery._ready_scope()
		and _returns.get_parent() == scope and _returns._service() == _discovery
		and _dispatch.get_parent() == scope and _drone.get_parent() == scope
		and scope.has_meta(SCOPE_KEY)
		and (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() == self
	)


func configure(
	audit: PrototypeCancelledSiteCustodyAudit,
	discovery: PrototypeDroneStorageDiscovery,
	returns: PrototypeDroneReturnReservations,
	dispatch: PrototypeDroneAutomaticDispatch,
	drone: PrototypeConstructionWorkerDrone
) -> bool:
	var scope := _scope()
	if (
		not enable_isolated_recovery_capacity or _configured or scope == null
		or not _live(self) or not _live(audit) or not _live(discovery)
		or not _live(returns) or not _live(dispatch) or not _live(drone)
		or audit.get_parent() != scope or not audit._enabled()
		or discovery.get_parent() != scope or not discovery._ready_scope()
		or returns.get_parent() != scope or returns._service() != discovery
		or dispatch.get_parent() != scope or drone.get_parent() != scope
	):
		return false
	if scope.has_meta(SCOPE_KEY):
		var prior := scope.get_meta(SCOPE_KEY) as WeakRef
		if prior != null and prior.get_ref() != null:
			return false
	_audit = audit
	_discovery = discovery
	_returns = returns
	_dispatch = dispatch
	_drone = drone
	_configured = true
	scope.set_meta(SCOPE_KEY, weakref(self))
	return true


func claim_count() -> int:
	return _claims.size()


func _idle_original_drone() -> bool:
	return (
		_enabled()
		and _drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE
		and _drone.cargo_amount() == 0
		and not _dispatch.has_lifecycle_assignment()
		and _returns.reservation_count() == 0
	)


# Reserve only AFTER the physical delivery and cancelled-site escrow have
# settled, and only if the drone is back at home with no current assignment.
# Caller-supplied source objects must match the immutable Stage A ticket.
func reserve(
	ticket_id: int,
	staging: BlueprintConstructionMaterialStaging,
	port: BlueprintConstructionStagingInputPort,
	buffer: InventoryComponent,
	original_job: ConstructionJob
) -> int:
	if not _idle_original_drone():
		return 0
	var snapshot: Dictionary = _audit.observe(ticket_id)
	if snapshot.get("status") != &"ready_read_only":
		return 0
	if not _audit.matches_original_terminal_source(ticket_id, staging, port, buffer, original_job):
		return 0
	var amount: int = int(snapshot.get("amount", 0))
	var hover: Vector3 = snapshot.get("hover_position", Vector3.INF)
	if amount <= 0 or amount > 5 or not hover.is_finite():
		return 0
	for claim: Dictionary in _claims.values():
		# Only one outstanding staged-recovery task per original ticket and
		# per real worker. A ticket can be retried after an explicit release.
		if int(claim["ticket_id"]) == ticket_id or (claim["drone"] as WeakRef).get_ref() == _drone:
			return 0
	var best: Dictionary = {}
	for candidate: Dictionary in _discovery._entries_for(_drone, INGOT, amount):
		var dock := candidate["dock"] as PrototypeDroneStorageDock
		var inventory := candidate["inventory"] as InventoryComponent
		if not dock.allow_returns or not inventory.enable_isolated_drone_return_claims:
			continue
		var free: int = inventory.get_available_space()
		if free >= 0 and free < amount:
			continue
		var route: Array[Vector3] = [hover, dock.global_position]
		var energy: float = _drone.estimate_route_energy(route)
		if energy < 0.0 or energy > _drone.battery_units() + 0.00001:
			continue
		if best.is_empty() or energy < float(best["energy"]) - 0.00001:
			best = {"dock": dock, "storage": candidate["storage"], "inventory": inventory, "energy": energy}
	if best.is_empty():
		return 0
	var target := best["inventory"] as InventoryComponent
	var token := RefCounted.new()
	if not target.reserve_drone_return_space(token, INGOT, amount):
		return 0
	# No awaits/signals between reserving and anchoring the claim. If any
	# original source condition changed, give back ONLY this new space claim.
	if not _audit.matches_original_terminal_source(ticket_id, staging, port, buffer, original_job):
		target.release_drone_return_space(token)
		return 0
	var claim_id: int = _next_id
	_next_id += 1
	_claims[claim_id] = {
		"ticket_id": ticket_id,
		"token": token,
		"staging": weakref(staging),
		"port": weakref(port),
		"buffer": weakref(buffer),
		"job": original_job,
		"drone": weakref(_drone),
		"dock": weakref(best["dock"]),
		"storage": weakref(best["storage"]),
		"inventory": weakref(target),
		"amount": amount,
		"hover": hover
	}
	return claim_id


func _valid_claim(claim: Dictionary) -> bool:
	if not _enabled() or not _idle_original_drone():
		return false
	var ticket_id: int = int(claim["ticket_id"])
	var staging := (claim["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
	var port := (claim["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
	var buffer := (claim["buffer"] as WeakRef).get_ref() as InventoryComponent
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	var storage := (claim["storage"] as WeakRef).get_ref() as Node3D
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	var job := claim["job"] as ConstructionJob
	var amount: int = int(claim["amount"])
	if not _audit.matches_original_terminal_source(ticket_id, staging, port, buffer, job):
		return false
	if not _live(dock) or not _live(storage) or not _live(inventory):
		return false
	if not dock.allow_returns or not dock.available or not inventory.has_drone_return_claim(claim["token"], INGOT, amount):
		return false
	if inventory.max_capacity > 0 and inventory.get_total_amount() + inventory.get_reserved_return_space() > inventory.max_capacity:
		return false
	var found: bool = false
	for candidate: Dictionary in _discovery._entries_for(_drone, INGOT, amount):
		if candidate["dock"] == dock and candidate["storage"] == storage and candidate["inventory"] == inventory:
			found = true
			break
	if not found:
		return false
	var snap: Dictionary = _audit.observe(ticket_id)
	if snap.get("status") != &"ready_read_only" or int(snap.get("amount", 0)) != amount or snap.get("hover_position") != claim["hover"]:
		return false
	var route: Array[Vector3] = [claim["hover"], dock.global_position]
	var need: float = _drone.estimate_route_energy(route)
	return need >= 0.0 and need <= _drone.battery_units() + 0.00001


# Diagnostic snapshot only. No token, InventoryComponent, dock or mutable
# original site source is returned to callers.
func observe(claim_id: int) -> Dictionary:
	if not _claims.has(claim_id):
		return {"status": &"unavailable"}
	var claim: Dictionary = _claims[claim_id]
	return {
		"status": &"reserved_read_only" if _valid_claim(claim) else &"quarantined",
		"ticket_id": int(claim["ticket_id"]),
		"amount": int(claim["amount"])
	}


# Explicit original-worker cleanup; disabled mode cannot strand space
# reservations. Never releases terminal staging claims or changes stock.
func release(claim_id: int, drone: PrototypeConstructionWorkerDrone) -> bool:
	if not _claims.has(claim_id) or drone != _drone:
		return false
	var claim: Dictionary = _claims[claim_id]
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	if _live(inventory):
		inventory.release_drone_return_space(claim["token"])
	_claims.erase(claim_id)
	return true


func _exit_tree() -> void:
	for id: int in _claims.keys():
		release(id, _drone)
	var scope: Node3D = get_parent() as Node3D
	if is_instance_valid(scope) and scope.has_meta(SCOPE_KEY):
		var owner := scope.get_meta(SCOPE_KEY) as WeakRef
		if owner != null and owner.get_ref() == self:
			scope.remove_meta(SCOPE_KEY)
