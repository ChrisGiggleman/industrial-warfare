extends Node
class_name PrototypeDroneReturnReservations

# E3d5c5x4b — return space forecast claims only. No actual cargo custody,
# arrival, unloading, movement, worker readiness or production activation.
# A caller-supplied load is not proof of cargo. Explicit reconcile.
@export var enable_isolated_reservations: bool = false
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
			var energy: float = drone.estimate_route_energy(points)
			return energy >= 0.0 and energy <= drone.battery_units() + 0.00001
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
