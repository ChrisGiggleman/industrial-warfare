extends Node
class_name PrototypeCancelledSiteRecoveryTransport

## E3d5c6c Stage B — ISOLATED physical cancelled-site material recovery.
## No _process or parallel construction driver. A test explicitly calls
## tick(); Stage C will decide future playable integration separately.
## Only the original one-drone Direct Build scene can opt in.
const EXACT_SCENE := "res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn"
const INGOT = preload("res://data/items/test_ingot.tres")
const Drone = PrototypeConstructionWorkerDrone
const SPEED: float = 10.0

@export var enable_isolated_physical_recovery: bool = false

var _adapter: Node
var _audit: PrototypeCancelledSiteCustodyAudit
var _drone: PrototypeConstructionWorkerDrone
var _discovery: PrototypeDroneStorageDiscovery
var _dispatch: PrototypeDroneAutomaticDispatch
var _charging: PrototypeDroneHubCharging
var _registry: BlueprintConstructionSiteStagingRegistry
var _escrow: BlueprintConstructionMaterialEscrow

var _configured: bool = false
var _ticket: int = 0
var _token: RefCounted
var _source: WeakRef
var _dock: WeakRef
var _dest: WeakRef
var _building: WeakRef
var _hover: Vector3 = Vector3.ZERO
var _amount: int = 0
var _completed: Dictionary = {}


func _live(node: Variant) -> bool:
	return node is Node and is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func _scope() -> Node3D:
	var root := get_parent() as Node3D
	return root if _live(root) and root.scene_file_path == EXACT_SCENE else null


func _enabled() -> bool:
	var root := _scope()
	return (
		enable_isolated_physical_recovery and _configured and root != null and _live(self)
		and _live(_adapter) and _adapter.get_parent() == root and not _adapter.is_processing()
		and _live(_audit) and _audit.get_parent() == root and _audit._enabled()
		and _audit.enable_isolated_stage_b_source_access
		and _live(_drone) and _drone.get_parent() == root and _drone.enable_isolated_cancelled_staging_flight
		and _live(_discovery) and _discovery.get_parent() == root
		and _live(_dispatch) and _dispatch.get_parent() == root
		and _live(_charging) and _charging.get_parent() == root
		and _live(_registry) and _registry.get_parent() == root
		and _live(_escrow) and _escrow.get_parent() == root
	)


func configure(adapter: Node, audit: PrototypeCancelledSiteCustodyAudit) -> bool:
	var root := _scope()
	if _configured or not enable_isolated_physical_recovery or root == null or not _live(self):
		return false
	if not _live(adapter) or adapter.get_parent() != root or not adapter.has_method("has_verified_services") or not bool(adapter.call("has_verified_services")):
		return false
	if not _live(audit) or audit.get_parent() != root or not audit._enabled() or not audit.enable_isolated_stage_b_source_access:
		return false
	if adapter.is_processing():
		return false # Explicit isolated tick driver only, never two _process loops.
	var drone := adapter.get("drone") as PrototypeConstructionWorkerDrone
	var discovery := adapter.get("discovery") as PrototypeDroneStorageDiscovery
	var dispatch := adapter.get("dispatch") as PrototypeDroneAutomaticDispatch
	var charging := adapter.get("charging") as PrototypeDroneHubCharging
	var registry := adapter.get("registry") as BlueprintConstructionSiteStagingRegistry
	var escrow := adapter.get("escrow") as BlueprintConstructionMaterialEscrow
	if not _live(drone) or not drone.enable_isolated_cancelled_staging_flight or not _live(discovery) or not _live(dispatch) or not _live(charging) or not _live(registry) or not _live(escrow):
		return false
	for component: Node in [drone, discovery, dispatch, charging, registry, escrow]:
		if component.get_parent() != root:
			return false
	if audit._registry != registry or audit._escrow != escrow:
		return false
	for child: Node in root.get_children():
		if child != self and child is PrototypeCancelledSiteRecoveryTransport and _live(child):
			return false
	_adapter = adapter
	_audit = audit
	_drone = drone
	_discovery = discovery
	_dispatch = dispatch
	_charging = charging
	_registry = registry
	_escrow = escrow
	_configured = true
	return true


# Only the exact registered companion may receive the Stage A protected
# source handles. This is NOT a public inventory or salvage API.
func _audit_owned(audit: PrototypeCancelledSiteCustodyAudit) -> bool:
	return _enabled() and _audit == audit


func _owns_staged_mission(drone: PrototypeConstructionWorkerDrone, token: RefCounted) -> bool:
	return _enabled() and _ticket > 0 and _token != null and token == _token and drone == _drone and not _dispatch.has_lifecycle_assignment()


func _claimed_destination() -> bool:
	if not _enabled() or _token == null or _dock == null or _dest == null or _building == null:
		return false
	var dock := _dock.get_ref() as PrototypeDroneStorageDock
	var target := _dest.get_ref() as InventoryComponent
	var building := _building.get_ref() as Node3D
	if not _live(dock) or not _live(target) or not _live(building):
		return false
	if dock.get_parent() != building or not dock.enable_isolated_dock or not dock.available or not dock.allow_returns:
		return false
	if not target.has_drone_return_claim(_token, INGOT, _amount):
		return false
	if target.max_capacity < 0 or (target.max_capacity > 0 and target.get_total_amount() + target.get_reserved_return_space() > target.max_capacity):
		return false
	for candidate: Dictionary in _discovery._entries_for(_drone, INGOT, _amount):
		if candidate["dock"] == dock and candidate["inventory"] == target and candidate["storage"] == building:
			return true
	return false


# Reserve destination capacity BEFORE any original source is debited.
# The drone must be idle, fully charged, unassigned and able to fly the
# whole real home -> original hover -> Storage -> home journey.
func begin(ticket: int) -> bool:
	if not _enabled() or _ticket != 0 or ticket <= 0 or _completed.has(ticket):
		return false
	if _dispatch.has_lifecycle_assignment() or _drone.get_flight_state() != Drone.FlightState.IDLE:
		return false
	if _drone.cargo_amount() != 0 or _drone.cargo_item() != null:
		return false
	var snapshot: Dictionary = _audit.observe(ticket)
	if snapshot.get("status") != &"ready_read_only":
		return false
	var original: Dictionary = _audit._recovery_source_for(ticket, self)
	if original.is_empty() or int(original["amount"]) != int(snapshot["expected"]):
		return false
	var amount: int = int(original["amount"])
	if amount not in [3, 5]:
		return false
	var hover: Vector3 = original["hover"]
	var candidate: Dictionary = _discovery.find_return(_drone, INGOT, amount, true)
	if candidate.is_empty():
		return false
	var dock: PrototypeDroneStorageDock = candidate["dock"]
	var dest: InventoryComponent = candidate["inventory"]
	var building: Node3D = candidate["storage"]
	var path: Array[Vector3] = [hover, dock.global_position]
	var energy: float = _drone.estimate_route_energy(path)
	if energy < 0.0 or energy > _drone.battery_units() + 0.00001:
		return false
	var token := RefCounted.new()
	if not dest.reserve_drone_return_space(token, INGOT, amount):
		return false
	_token = token
	_ticket = ticket
	_source = weakref(original["buffer"])
	_dock = weakref(dock)
	_dest = weakref(dest)
	_building = weakref(building)
	_hover = hover
	_amount = amount
	if not _drone._staged_begin(self, token, hover, dock, SPEED):
		dest.release_drone_return_space(token)
		_clear()
		return false
	return true


func _clear() -> void:
	_ticket = 0
	_token = null
	_source = null
	_dock = null
	_dest = null
	_building = null
	_hover = Vector3.ZERO
	_amount = 0


func active_ticket() -> int:
	return _ticket


func completed_count() -> int:
	return _completed.size()


func recovered_amount(ticket: int) -> int:
	return int(_completed.get(ticket, 0))


# Observational status only. No physical stock is fabricated by a snapshot.
func observe() -> Dictionary:
	return {
		"active_ticket": _ticket, "amount": _amount,
		"flight_state": _drone.get_flight_state() if _live(_drone) else -1,
		"completed_count": _completed.size(), "source_state": _audit.observe(_ticket) if _live(_audit) and _ticket > 0 else {}
	}


func tick(delta: float) -> Dictionary:
	if not _enabled() or _ticket == 0 or not is_finite(delta) or delta <= 0.0 or delta > 0.1:
		return {"action": &"blocked"}
	if _dispatch.has_lifecycle_assignment():
		return {"action": &"foreign_assignment"}
	var state: int = _drone.get_flight_state()
	if state == Drone.FlightState.STAGED_TO_SITE:
		var original: Dictionary = _audit._recovery_source_for(_ticket, self)
		if original.is_empty() or original["buffer"] != _source.get_ref() or original["hover"] != _hover:
			return {"action": &"source_quarantined"}
		if not _claimed_destination():
			return {"action": &"destination_wait"}
		return {"action": &"site_flight" if _drone._staged_step(self, _token, delta) else &"energy_wait"}
	if state == Drone.FlightState.STAGED_AT_SITE:
		var original: Dictionary = _audit._recovery_source_for(_ticket, self)
		if original.is_empty() or original["buffer"] != _source.get_ref() or original["hover"] != _hover:
			return {"action": &"source_quarantined"}
		if not _claimed_destination():
			return {"action": &"destination_wait"}
		var source := original["buffer"] as InventoryComponent
		if not _drone._staged_collect(self, _token, source, INGOT, _amount):
			return {"action": &"pickup_wait"}
		return {"action": &"collected"}
	if state == Drone.FlightState.STAGED_LOADED:
		if not _claimed_destination():
			return {"action": &"destination_wait"}
		var dock := _dock.get_ref() as PrototypeDroneStorageDock
		return {"action": &"return_started" if _drone._staged_begin_return(self, _token, dock, INGOT, _amount) else &"destination_wait"}
	if state == Drone.FlightState.STAGED_TO_STORAGE:
		if not _claimed_destination():
			return {"action": &"destination_wait"}
		return {"action": &"storage_flight" if _drone._staged_step(self, _token, delta) else &"energy_wait"}
	if state == Drone.FlightState.STAGED_AT_STORAGE:
		if not _claimed_destination():
			return {"action": &"destination_wait"}
		var dock := _dock.get_ref() as PrototypeDroneStorageDock
		var dest := _dest.get_ref() as InventoryComponent
		if not _drone._staged_unload(self, _token, dock, dest, INGOT, _amount):
			return {"action": &"destination_wait"}
		return {"action": &"unloaded"}
	if state == Drone.FlightState.STAGED_HOME:
		return {"action": &"home_flight" if _drone._staged_step(self, _token, delta) else &"energy_wait"}
	if state == Drone.FlightState.DOCKED:
		if _drone._staged_rearm(self, _token):
			_completed[_ticket] = _amount
			_clear()
			return {"action": &"rearmed"}
		var charged: float = _charging.advance_charging(delta)
		return {"action": &"charged" if charged > 0.0 else &"dock_wait"}
	return {"action": &"quarantined"}
