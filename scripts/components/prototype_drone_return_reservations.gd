extends Node
class_name PrototypeDroneReturnReservations

# E3d5c5x4b — return space forecast claims only. No actual cargo custody,
# arrival, unloading, movement, worker readiness or production activation.
# A caller-supplied load is not proof of cargo. Explicit reconcile.
@export var enable_isolated_reservations: bool = false
@export var enable_isolated_cargo_recovery: bool = false
const SCOPE_KEY: StringName = &"isolated_drone_return_reservation_owner"
var _discovery: WeakRef
var _claims: Dictionary = {}
var _next_id: int = 1


func _live(node: Variant) -> bool:
	return is_instance_valid(node) and node is Node and node.is_inside_tree() and not node.is_queued_for_deletion()


func configure(discovery: PrototypeDroneStorageDiscovery) -> bool:
	if not enable_isolated_reservations or _discovery != null or not _live(self) or not _live(discovery) or discovery.get_parent() != get_parent() or not discovery.enable_isolated_discovery or not get_parent() is Node3D:
		return false
	var scope: Node = get_parent()
	if scope.has_meta(SCOPE_KEY):
		var owner: WeakRef = scope.get_meta(SCOPE_KEY)
		if owner.get_ref() != null:
			return false
	scope.set_meta(SCOPE_KEY, weakref(self))
	_discovery = weakref(discovery)
	return true


func _service() -> PrototypeDroneStorageDiscovery:
	if not enable_isolated_reservations or _discovery == null or not _live(self):
		return null
	var discovery := _discovery.get_ref() as PrototypeDroneStorageDiscovery
	if not _live(discovery) or not discovery.enable_isolated_discovery or discovery.get_parent() != get_parent():
		return null
	var scope: Node = get_parent()
	if not scope.has_meta(SCOPE_KEY) or (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() != self:
		return null
	return discovery


# One outstanding whole-load return claim per drone. Site cancellation
# is not a release trigger: recovery is intended to outlive that site.
func reserve(drone: PrototypeConstructionWorkerDrone, item: ItemDefinition, amount: int) -> int:
	var discovery := _service()
	if discovery == null:
		return 0
	reconcile()
	for claim: Dictionary in _claims.values():
		if (claim["drone"] as WeakRef).get_ref() == drone:
			return 0
	var candidate := discovery.find_return(drone, item, amount, true)
	if candidate.is_empty():
		return 0
	var inventory: InventoryComponent = candidate["inventory"]
	var dock: PrototypeDroneStorageDock = candidate["dock"]
	var token := RefCounted.new()
	if not inventory.reserve_drone_return_space(token, item, amount):
		return 0
	var id: int = _next_id
	_next_id += 1
	_claims[id] = {
		"token": token, "drone": weakref(drone), "inventory": weakref(inventory),
		"dock": weakref(dock), "storage": weakref(candidate["storage"]),
		"item": item, "amount": amount
	}
	for node: Node in [drone, inventory, dock, candidate["storage"]]:
		node.tree_exiting.connect(_on_ended.bind(id))
	return id


func _on_ended(id: int) -> void:
	_release(id)


func _release(id: int) -> bool:
	if not _claims.has(id):
		return false
	var claim: Dictionary = _claims[id]
	_claims.erase(id)
	if claim.get("recovery", false):
		var drone := (claim["drone"] as WeakRef).get_ref() as PrototypeConstructionWorkerDrone
		if is_instance_valid(drone):
			drone._cancel_cargo_return(claim["token"])
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	if is_instance_valid(inventory):
		inventory.release_drone_return_space(claim["token"])
	var callback: Callable = _on_ended.bind(id)
	for key: String in ["drone", "inventory", "dock", "storage"]:
		var node: Node = (claim[key] as WeakRef).get_ref()
		if is_instance_valid(node) and node.tree_exiting.is_connected(callback):
			node.tree_exiting.disconnect(callback)
	return true


# Explicit release requires exact claimant identity. Disabled services can
# still release capacity; turning flags off cannot silently expose it.
func release(id: int, drone: PrototypeConstructionWorkerDrone) -> bool:
	if not _claims.has(id) or not is_instance_valid(drone) or (_claims[id]["drone"] as WeakRef).get_ref() != drone:
		return false
	return _release(id)


func reservation_count() -> int:
	return _claims.size()


func _valid(claim: Dictionary, discovery: PrototypeDroneStorageDiscovery) -> bool:
	if discovery == null:
		return false
	var drone := (claim["drone"] as WeakRef).get_ref() as PrototypeConstructionWorkerDrone
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	var building := (claim["storage"] as WeakRef).get_ref() as Node3D
	if not _live(drone) or not _live(dock) or not _live(inventory) or not _live(building):
		return false
	var item: ItemDefinition = claim["item"]
	var amount: int = claim["amount"]
	if claim.get("recovery", false) and (not enable_isolated_cargo_recovery or not drone._owns_cargo_return(claim["token"], dock, item, amount)):
		return false
	if not inventory.enable_isolated_drone_return_claims or not inventory.has_drone_return_claim(claim["token"], item, amount):
		return false
	# If capacity shrinks, fail closed until explicit reconciliation.
	# Check ALL claims against actual physical occupancy, not unclaimed space.
	if inventory.max_capacity < 0 or (inventory.max_capacity > 0 and inventory.get_total_amount() + inventory.get_reserved_return_space() > inventory.max_capacity):
		return false
	for candidate: Dictionary in discovery._entries_for(drone, item, amount):
		if candidate["dock"] == dock and candidate["inventory"] == inventory and candidate["storage"] == building:
			if not dock.allow_returns:
				return false
			var points: Array[Vector3] = [dock.global_position]
			return drone.route_feasible(points)
	return false


# Observational snapshot, no token exposure; stale space claims remain protected
# until explicit reconcile or lifecycle cleanup. No automatic reassignment.
func observe(id: int) -> Dictionary:
	if not _claims.has(id):
		return {}
	var claim: Dictionary = _claims[id]
	return {"id": id, "valid": _valid(claim, _service()), "dock": (claim["dock"] as WeakRef).get_ref(), "item": claim["item"], "amount": claim["amount"]}


func reconcile() -> int:
	var removed: int = 0
	var discovery := _service()
	var ids: Array = _claims.keys()
	ids.sort()
	ids.reverse()
	for id: int in ids:
		if not _valid(_claims[id], discovery):
			_release(id)
			removed += 1
	return removed


func _exit_tree() -> void:
	for id: int in _claims.keys():
		_release(id)
	var scope: Node = get_parent()
	if is_instance_valid(scope) and scope.has_meta(SCOPE_KEY) and (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() == self:
		scope.remove_meta(SCOPE_KEY)


# x6: explicit isolated tick, not a normal scene dispatcher. A live recovery
# claim is created from actual drone cargo, not from a caller-supplied load.
# Every tick revalidates the route and claim; canceled cargo stays protected
# if no eligible destination exists. At most one transition/leg per tick.
func advance_cancelled_recovery(drone: PrototypeConstructionWorkerDrone, delta: float) -> bool:
	if not is_finite(delta) or delta <= 0.0 or not _live(drone) or drone.get_parent() != get_parent():
		return false
	reconcile()
	if not enable_isolated_cargo_recovery or _service() == null or not drone._recovery_enabled():
		return false
	if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RECOVERY_HOME:
		return drone._advance_recovery_home(delta)
	if not drone._recovery_cargo_valid():
		return false
	for id: int in _claims.keys():
		var claim: Dictionary = _claims[id]
		if (claim["drone"] as WeakRef).get_ref() != drone:
			continue
		# Never steal or convert a pre-existing forecast-only reservation.
		if not claim.get("recovery", false):
			return false
		var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
		var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
		if not _valid(claim, _service()):
			_release(id)
			return false
		if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_RECOVERY and drone.global_position.distance_to(dock.global_position) <= 0.00001:
			if not drone._deposit_cargo_return(claim["token"], dock, inventory):
				_release(id)
				return false
			_release(id)
			return true
		return drone._advance_cargo_return(claim["token"], dock, delta)
	if not drone._wait_for_recovery():
		return false
	var id: int = reserve(drone, drone.cargo_item(), drone.cargo_amount())
	if id <= 0:
		return false
	var claim: Dictionary = _claims[id]
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	if not drone._begin_cargo_return(claim["token"], dock):
		_release(id)
		return false
	claim["recovery"] = true
	_claims[id] = claim
	return true
