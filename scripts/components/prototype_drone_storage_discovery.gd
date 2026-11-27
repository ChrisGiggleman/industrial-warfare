extends Node
class_name PrototypeDroneStorageDiscovery

# E3d5c5x3 — isolated, read-only routing forecast. Explicit caller enrollment.
# No material claims, capacity reservations, flight, escrow, job readiness,
# research unlocks, or automatic discovery in normal gameplay.
const STORAGE = preload("res://data/buildings/test_storage.tres")
const MAX_AMOUNT: int = 100000
@export var enable_isolated_discovery: bool = false
var _entries: Array[Dictionary] = []


func _live(node: Variant) -> bool:
	return is_instance_valid(node) and node is Node and node.is_inside_tree() and not node.is_queued_for_deletion()


func _ready_scope() -> bool:
	return enable_isolated_discovery and _live(self) and get_parent() is Node3D


func _storage_inventory(building: Variant) -> InventoryComponent:
	if not _live(building) or not building is Node3D or building.get_parent() != get_parent():
		return null
	if building.scene_file_path != STORAGE.building_scene.resource_path or not building.is_in_group("player_built") or not building.is_in_group("logistics_storage") or building.is_in_group("construction_preview"):
		return null
	var runtime := building.get_node_or_null("BuildingRuntime") as BuildingRuntime
	var health := building.get_node_or_null("BuildingHealthComponent") as BuildingHealthComponent
	var inventory := building.get_node_or_null("InventoryComponent") as InventoryComponent
	if not _live(runtime) or runtime.building_definition != STORAGE or not _live(health) or not health.is_intact() or not _live(inventory):
		return null
	return inventory


# Registration pins exact Storage, marker and inventory identity, not names.
# No implicit replacement of a deleted or reparented dock/inventory.
func register_dock(dock: PrototypeDroneStorageDock) -> bool:
	if not _ready_scope() or not _live(dock) or not dock.enable_isolated_dock or not dock.global_position.is_finite():
		return false
	var building: Node = dock.get_parent()
	var inventory := _storage_inventory(building)
	if inventory == null:
		return false
	for record: Dictionary in _entries:
		if (record["building"] as WeakRef).get_ref() == building or (record["dock"] as WeakRef).get_ref() == dock or (record["inventory"] as WeakRef).get_ref() == inventory:
			return false
	_entries.append({"building": weakref(building), "dock": weakref(dock), "inventory": weakref(inventory), "order": _entries.size()})
	return true


func _entries_for(drone: PrototypeConstructionWorkerDrone, item: ItemDefinition, amount: int) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	if not _ready_scope() or not _live(drone) or drone.get_parent() != get_parent() or not is_instance_valid(item) or item.item_id == &"" or amount <= 0 or amount > MAX_AMOUNT:
		return found
	for record: Dictionary in _entries:
		var dock := (record["dock"] as WeakRef).get_ref() as PrototypeDroneStorageDock
		var building := (record["building"] as WeakRef).get_ref() as Node3D
		var inventory := (record["inventory"] as WeakRef).get_ref() as InventoryComponent
		if not _live(dock) or not _live(building) or not _live(inventory):
			continue
		if dock.get_parent() != building or _storage_inventory(building) != inventory:
			continue
		if not dock.enable_isolated_dock or not dock.available or not dock.global_position.is_finite() or dock.minimum_retained < 0:
			continue
		found.append({"dock": dock, "storage": building, "inventory": inventory, "order": record["order"]})
	return found


# One requested item and one full-load supplier. Claim-free snapshot only.
# Total travel energy (current -> dock -> site hover -> registered home)
# is primary, distance from dock to site secondary, registration order last.
func find_pickup(drone: PrototypeConstructionWorkerDrone, site: ConstructionSite, item: ItemDefinition, amount: int, cargo_capacity: int, hover_height: float = 2.0, require_claimable: bool = false) -> Dictionary:
	if not _ready_scope() or not _live(site) or site.get_parent() != get_parent() or site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return {}
	if not site.job.get_wait_reasons().has(&"materials") or not _live(drone) or drone.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE:
		return {}
	if amount <= 0 or cargo_capacity < amount or cargo_capacity > MAX_AMOUNT or not is_finite(hover_height) or hover_height < 0.5 or hover_height > 10.0:
		return {}
	var bill: Dictionary = ConstructionMaterialBill.get_costs(site.target_definition)
	if int(bill.get(item, 0)) < amount:
		return {}
	var destination: Vector3 = site.global_position + Vector3.UP * hover_height
	if not destination.is_finite():
		return {}
	var best: Dictionary = {}
	for candidate: Dictionary in _entries_for(drone, item, amount):
		var dock: PrototypeDroneStorageDock = candidate["dock"]
		var inventory: InventoryComponent = candidate["inventory"]
		if require_claimable and not inventory.enable_isolated_drone_claims:
			continue
		if not dock.allow_pickup or inventory.get_unreserved_amount(item) - dock.minimum_retained < amount:
			continue
		var waypoints: Array[Vector3] = [dock.global_position, destination]
		var score: float = drone.route_score(waypoints)
		if not drone.route_feasible(waypoints):
			continue
		candidate["route_score"] = score
		if not drone.c5p_automated_mode():
			candidate["energy_required"] = score
		candidate["distance_to_site"] = dock.global_position.distance_to(destination)
		candidate["amount"] = amount
		if best.is_empty() or _better_pickup(candidate, best):
			best = candidate
	return best


# Forecast for a caller-supplied whole single-item cargo load. Does NOT
# assert that the current prototype drone actually carries these items.
# Primary rank is actual current-position -> dock distance; battery must
# also cover dock -> home. No capacity is reserved or cargo deposited.
func find_return(drone: PrototypeConstructionWorkerDrone, item: ItemDefinition, amount: int, require_claimable: bool = false) -> Dictionary:
	var best: Dictionary = {}
	for candidate: Dictionary in _entries_for(drone, item, amount):
		var dock: PrototypeDroneStorageDock = candidate["dock"]
		var inventory: InventoryComponent = candidate["inventory"]
		if require_claimable and not inventory.enable_isolated_drone_return_claims:
			continue
		var space: int = inventory.get_available_space()
		if not dock.allow_returns or (space >= 0 and space < amount):
			continue
		var waypoints: Array[Vector3] = [dock.global_position]
		var score: float = drone.route_score(waypoints)
		if not drone.route_feasible(waypoints):
			continue
		candidate["route_score"] = score
		if not drone.c5p_automated_mode():
			candidate["energy_required"] = score
		candidate["distance_to_dock"] = drone.global_position.distance_to(dock.global_position)
		candidate["amount"] = amount
		if best.is_empty() or candidate["distance_to_dock"] < best["distance_to_dock"] - 0.00001:
			best = candidate
	return best


func _better_pickup(a: Dictionary, b: Dictionary) -> bool:
	var ea: float = a["route_score"]
	var eb: float = b["route_score"]
	if absf(ea - eb) > 0.00001:
		return ea < eb
	var da: float = a["distance_to_site"]
	var db: float = b["distance_to_site"]
	if absf(da - db) > 0.00001:
		return da < db
	return int(a["order"]) < int(b["order"])
