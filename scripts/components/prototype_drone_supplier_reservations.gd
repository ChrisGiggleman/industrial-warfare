extends Node
class_name PrototypeDroneSupplierReservations

# E3d5c5x4a — claims only. No cargo pickup, movement, worker readiness,
# return capacity reservation or production activation. Explicit reconcile.
@export var enable_isolated_reservations: bool = false
const SCOPE_KEY: StringName = &"isolated_drone_supplier_reservation_owner"
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


# One outstanding whole-item claim per drone and site in this prototype.
# No UI-supplied discovery result can authorize the operation: query again.
func reserve(drone: PrototypeConstructionWorkerDrone, site: ConstructionSite, item: ItemDefinition, amount: int, cargo_capacity: int) -> int:
	var discovery := _service()
	if discovery == null:
		return 0
	reconcile()
	for claim: Dictionary in _claims.values():
		if (claim["drone"] as WeakRef).get_ref() == drone or (claim["site"] as WeakRef).get_ref() == site:
			return 0
	var candidate := discovery.find_pickup(drone, site, item, amount, cargo_capacity, 2.0, true)
	if candidate.is_empty():
		return 0
	var inventory: InventoryComponent = candidate["inventory"]
	var dock: PrototypeDroneStorageDock = candidate["dock"]
	var token := RefCounted.new()
	if not inventory.reserve_drone_stock(token, item, amount, dock.minimum_retained):
		return 0
	var id: int = _next_id
	_next_id += 1
	_claims[id] = {
		"token": token, "drone": weakref(drone), "site": weakref(site),
		"job": site.job, "inventory": weakref(inventory), "dock": weakref(dock),
		"storage": weakref(candidate["storage"]), "item": item, "amount": amount, "cargo_capacity": cargo_capacity
	}
	# Unpicked stock stays at source; cancellation releases only the claim.
	site.job.job_cancelled.connect(_on_ended.bind(id))
	site.tree_exiting.connect(_on_ended.bind(id, true))
	for node: Node in [drone, inventory, dock, candidate["storage"]]:
		node.tree_exiting.connect(_on_ended.bind(id))
	return id


func _on_ended(id: int, original_site_exiting: bool = false) -> void:
	_release(id, original_site_exiting)


func _release(id: int, original_site_exiting: bool = false) -> bool:
	if not _claims.has(id):
		return false
	var claim: Dictionary = _claims[id]
	_claims.erase(id)
	var drone := (claim["drone"] as WeakRef).get_ref() as PrototypeConstructionWorkerDrone
	if is_instance_valid(drone):
		var site := (claim["site"] as WeakRef).get_ref() as ConstructionSite
		var site_lost: bool = original_site_exiting or not is_instance_valid(site) or site.is_queued_for_deletion()
		drone._cancel_pickup(claim["token"], self, claim["site"], claim["job"], site_lost)
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	if is_instance_valid(inventory):
		inventory.release_drone_stock(claim["token"])
	var job: ConstructionJob = claim["job"]
	var callback: Callable = _on_ended.bind(id)
	if job.job_cancelled.is_connected(callback):
		job.job_cancelled.disconnect(callback)
	var original := (claim["site"] as WeakRef).get_ref() as ConstructionSite
	var site_callback: Callable = _on_ended.bind(id, true)
	if is_instance_valid(original) and original.tree_exiting.is_connected(site_callback):
		original.tree_exiting.disconnect(site_callback)
	for key: String in ["drone", "inventory", "dock", "storage"]:
		var node: Node = (claim[key] as WeakRef).get_ref()
		if is_instance_valid(node) and node.tree_exiting.is_connected(callback):
			node.tree_exiting.disconnect(callback)
	return true


# Explicit release requires exact claimant identity. Disabled services can
# still release stock; turning flags off cannot silently expose it.
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
	var site := (claim["site"] as WeakRef).get_ref() as ConstructionSite
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	var building := (claim["storage"] as WeakRef).get_ref() as Node3D
	if not _live(drone) or not _live(site) or not _live(dock) or not _live(inventory) or not _live(building):
		return false
	if site.get_parent() != get_parent() or site.job != claim["job"] or site.job.state != ConstructionJob.State.QUEUED or not site.job.get_wait_reasons().has(&"materials") or (drone.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE and not drone._owns_pickup(claim["token"], dock)):
		return false
	var item: ItemDefinition = claim["item"]
	var amount: int = claim["amount"]
	if int(ConstructionMaterialBill.get_costs(site.target_definition).get(item, 0)) < amount:
		return false
	if not inventory.enable_isolated_drone_claims or not inventory.has_drone_stock_claim(claim["token"], item, amount) or inventory.get_amount(item) < inventory.get_reserved_amount(item):
		return false
	for candidate: Dictionary in discovery._entries_for(drone, item, amount):
		if candidate["dock"] == dock and candidate["inventory"] == inventory and candidate["storage"] == building:
			if not dock.allow_pickup or inventory.get_unreserved_amount(item) < dock.minimum_retained:
				return false
			var points: Array[Vector3] = [dock.global_position, site.global_position + Vector3.UP * 2.0]
			return drone.route_feasible(points)
	return false


# Observational snapshot, no token exposure; stale claims remain protected
# until explicit reconcile or lifecycle cleanup. No automatic reassignment.
func observe(id: int) -> Dictionary:
	if not _claims.has(id):
		return {}
	var claim: Dictionary = _claims[id]
	return {"id": id, "valid": _valid(claim, _service()), "dock": (claim["dock"] as WeakRef).get_ref(), "item": claim["item"], "amount": claim["amount"]}


func reconcile() -> int:
	var removed: int = 0
	var discovery := _service()
	for id: int in _claims.keys():
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


# x5a: same claim, same worker, actual battery-metered arrival; no caller
# provided inventory, token, coordinates or item quantity may authorize debit.
func _owned_valid(id: int, drone: PrototypeConstructionWorkerDrone) -> bool:
	return _claims.has(id) and _live(drone) and (_claims[id]["drone"] as WeakRef).get_ref() == drone and _valid(_claims[id], _service())


func begin_pickup(id: int, drone: PrototypeConstructionWorkerDrone, speed: float) -> bool:
	if not _owned_valid(id, drone):
		return false
	var claim: Dictionary = _claims[id]
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	return drone._begin_pickup(claim["token"], dock, claim["cargo_capacity"], speed)


func advance_pickup(id: int, drone: PrototypeConstructionWorkerDrone, delta: float) -> bool:
	if not _owned_valid(id, drone):
		if _claims.has(id) and is_instance_valid(drone) and (_claims[id]["drone"] as WeakRef).get_ref() == drone:
			_release(id)
		return false
	var claim: Dictionary = _claims[id]
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	return drone._advance_pickup(claim["token"], dock, delta)


func collect_pickup(id: int, drone: PrototypeConstructionWorkerDrone) -> bool:
	if not _owned_valid(id, drone):
		return false
	var claim: Dictionary = _claims[id]
	var dock := (claim["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
	var inventory := (claim["inventory"] as WeakRef).get_ref() as InventoryComponent
	if not drone._take_pickup(claim["token"], dock, inventory, claim["item"], claim["amount"], (claim["site"] as WeakRef).get_ref() as ConstructionSite):
		return false
	_release(id)
	return true
