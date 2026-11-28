extends Node
class_name PrototypeDroneHubCharging

# E3d5c5x7a: isolated shared surplus nameplate rate * explicit simulation
# delta, at one real completed Hub. One service per scope, FIFO enrollment.
# Construction gets precedence. No charging from a caller-provided bool.
# Not actual fuel/electricity metering, no _process or Main activation.
@export var enable_isolated_charging: bool = false
const SCOPE_KEY: StringName = &"isolated_drone_hub_charging_owner"
const HUB_PATH: String = "res://scenes/buildings/prototype_main_hub.tscn"
@export var enable_specialized_c1_dock: bool = false
@export var enable_specialized_c4_builder_dock: bool = false
var _hub: WeakRef
var _allocator: WeakRef
var _power_node: WeakRef
var _entries: Array[Dictionary] = []
var _c5p_dock_only: bool = false

func c5p_dock_only() -> bool:
	return _c5p_dock_only

func configure_c5p_dock(hub: PrototypePowerStructure, allocator: PrototypeConstructionPowerAllocator, controller: Node) -> bool:
	var scope := get_parent()
	if _hub != null or _c5p_dock_only or not _live(scope) or scope.scene_file_path != "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn":
		return false
	var b2 := scope.get_node_or_null("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
	if not _live(b2) or controller != b2 or not b2.c5p_automated_mode() or b2._c1_charging != self or b2.phase != &"ready" or enable_isolated_charging:
		return false
	_c5p_dock_only = true
	return configure(hub, allocator)

func matches_c5p_enrollment(drone: PrototypeConstructionWorkerDrone, token: RefCounted) -> bool:
	var hub := _live_hub()
	if _live(drone) and drone._c5p_empty_latched and drone.cargo_amount() == 0:
		hub = _c5p_empty_physical_hub(drone)
	if not _c5p_dock_only or enable_isolated_charging or hub == null or not _live(drone) or drone.get_parent() != get_parent() or token == null:
		return false
	var scope := get_parent()
	if scope.scene_file_path != "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn" or hub != scope.get_node_or_null("MainHub") or not hub.global_position.is_finite():
		return false
	var b2 := scope.get_node_or_null("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
	if not _live(b2) or not b2.c5p_automated_mode() or b2._c1_charging != self:
		return false
	var berth: Vector3
	if drone == scope.get_node_or_null("LogisticsDrone"):
		berth = hub.global_position + Vector3(-0.65, 2, 0)
	elif drone == scope.get_node_or_null("ConstructionDrone"):
		berth = hub.global_position + Vector3(0.65, 2, 0)
	else:
		return false
	var authorities: int = 0
	for child: Node in scope.get_children():
		if child is PrototypeDroneHubCharging and _live(child):
			authorities += 1
	if authorities != 1:
		return false
	for entry: Dictionary in _entries:
		if (entry["drone"] as WeakRef).get_ref() == drone and entry["token"] == token and drone._home.is_equal_approx(berth) and berth.is_equal_approx(entry["berth"]):
			return true
	return false


func _live(node: Variant) -> bool:
	return is_instance_valid(node) and node is Node and node.is_inside_tree() and not node.is_queued_for_deletion()


func configure(hub: PrototypePowerStructure, allocator: PrototypeConstructionPowerAllocator) -> bool:
	if (not enable_isolated_charging and not _c5p_dock_only) or _hub != null or not _live(self) or not _live(hub) or not _live(allocator) or not get_parent() is Node3D:
		return false
	if hub.get_parent() != get_parent() or allocator.get_parent() != get_parent() or hub.scene_file_path != HUB_PATH:
		return false
	var node := hub.get_power_node()
	if not _live(node):
		return false
	var scope: Node = get_parent()
	if scope.has_meta(SCOPE_KEY):
		var old: WeakRef = scope.get_meta(SCOPE_KEY)
		if old.get_ref() != null:
			return false
	scope.set_meta(SCOPE_KEY, weakref(self))
	_hub = weakref(hub)
	_allocator = weakref(allocator)
	_power_node = weakref(node)
	return true


func _live_hub() -> PrototypePowerStructure:
	if (not enable_isolated_charging and not _c5p_dock_only) or (_c5p_dock_only and enable_isolated_charging) or not _live(self) or _hub == null or _allocator == null or _power_node == null:
		return null
	var hub := _hub.get_ref() as PrototypePowerStructure
	var allocator := _allocator.get_ref() as PrototypeConstructionPowerAllocator
	var node := _power_node.get_ref() as ConstructionPowerNetworkNode
	if not _live(hub) or not _live(allocator) or not _live(node):
		return null
	var scope: Node = get_parent()
	if hub.get_parent() != scope or allocator.get_parent() != scope or hub.get_power_node() != node:
		return null
	if not scope.has_meta(SCOPE_KEY) or (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() != self:
		return null
	var count: int = 0
	for child: Node in scope.get_children():
		if child is PrototypeConstructionPowerAllocator and _live(child):
			count += 1
	if count != 1 or not _live(hub.get_health()) or not hub.get_health().is_intact() or not hub.service_enabled or not node.operational:
		return null
	return hub


# C1 uses the existing left-hand logistics berth, never a caller coordinate.
func _dock_for(hub: PrototypePowerStructure, drone: PrototypeConstructionWorkerDrone) -> Vector3:
	var scope := get_parent()
	if enable_specialized_c1_dock and scope.scene_file_path == "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn" and scope.get_node_or_null("LogisticsDrone") == drone:
		var b2 := scope.get_node_or_null("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
		if is_instance_valid(b2) and b2.enable_c1_pre_pickup_cancel:
			return hub.global_position + Vector3(-0.65, 2, 0)
	if enable_specialized_c4_builder_dock and scope.scene_file_path == "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn" and scope.get_node_or_null("ConstructionDrone") == drone:
		var b3 := scope.get_node_or_null("B3BuilderController") as SpecializedDroneBuilderE3d5c6fB3
		if is_instance_valid(b3) and b3.c4_charging_authorized(self, drone):
			return hub.global_position + Vector3(0.65, 2, 0)
	return hub.global_position + Vector3.UP * 2.0

func register_drone(drone: PrototypeConstructionWorkerDrone) -> bool:
	var hub := _live_hub()
	if hub == null or not _live(drone) or drone.get_parent() != get_parent():
		return false
	for entry: Dictionary in _entries:
		if (entry["drone"] as WeakRef).get_ref() == drone:
			return false
	var token := RefCounted.new()
	var berth := _dock_for(hub, drone)
	if _c5p_dock_only:
		if drone == get_parent().get_node_or_null("LogisticsDrone"):
			if not berth.is_equal_approx(hub.global_position + Vector3(-0.65, 2, 0)):
				return false
		elif drone == get_parent().get_node_or_null("ConstructionDrone"):
			if not berth.is_equal_approx(hub.global_position + Vector3(0.65, 2, 0)):
				return false
		else:
			return false
		if not drone._bind_c5p_dock(self, token, berth):
			return false
	elif not drone._bind_finite_charging(self, token, berth):
		return false
	if _c5p_dock_only:
		_entries.append({"drone": weakref(drone), "token": token, "berth": berth})
	else:
		_entries.append({"drone": weakref(drone), "token": token})
	return true


# One explicit simulation tick for the entire registered fleet. Total
# accepted energy cannot exceed spare generation times this tick duration.
# Fixed enrollment order is deliberate for the isolated gate, not fairness.
func advance_charging(delta: float) -> float:
	if _c5p_dock_only:
		return 0.0
	if not is_finite(delta) or delta <= 0.0:
		return 0.0
	var hub := _live_hub()
	if hub == null:
		return 0.0
	var allocator := _allocator.get_ref() as PrototypeConstructionPowerAllocator
	var budget: float = float(allocator.spare_generation_for(hub.get_power_node())) * delta
	if not is_finite(budget) or budget <= 0.0:
		return 0.0
	var total: float = 0.0
	for entry: Dictionary in _entries:
		var drone := (entry["drone"] as WeakRef).get_ref() as PrototypeConstructionWorkerDrone
		if not _live(drone) or drone.get_parent() != get_parent():
			continue
		var accepted: float = drone._accept_finite_charge(self, entry["token"], _dock_for(hub, drone), delta, maxf(0.0, budget - total))
		total += accepted
	return total


func _exit_tree() -> void:
	var scope: Node = get_parent()
	if is_instance_valid(scope) and scope.has_meta(SCOPE_KEY) and (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() == self:
		scope.remove_meta(SCOPE_KEY)
	# Drones stay latched; loss of service cannot restore legacy charging.


# x7b: observation only, verifies original enrollment and actual home.
# This is not a new power grant; previously stored energy remains usable
# during generator outage if the Hub/service itself is still intact.
func matches_docked_registration(drone: PrototypeConstructionWorkerDrone, token: RefCounted) -> bool:
	if _c5p_dock_only:
		return matches_c5p_enrollment(drone, token) and drone.get_flight_state() in [PrototypeConstructionWorkerDrone.FlightState.IDLE, PrototypeConstructionWorkerDrone.FlightState.DOCKED] and drone.global_position.is_finite() and drone.global_position.distance_to(drone._home) <= 0.00001
	var hub := _live_hub()
	if hub == null or not _live(drone) or drone.get_parent() != get_parent() or token == null:
		return false
	if drone.get_flight_state() not in [PrototypeConstructionWorkerDrone.FlightState.IDLE, PrototypeConstructionWorkerDrone.FlightState.DOCKED]:
		return false
	if not drone.global_position.is_finite() or not hub.global_position.is_finite() or drone.global_position.distance_to(_dock_for(hub, drone)) > 0.00001:
		return false
	for entry: Dictionary in _entries:
		if (entry["drone"] as WeakRef).get_ref() == drone and entry["token"] == token:
			return true
	return false

# B2b-1: empty logistics can reach its original intact berth without
# electrical or allocator permission. All original enrollment checks follow.
func _c5p_empty_physical_hub(drone: PrototypeConstructionWorkerDrone) -> PrototypePowerStructure:
	if not _c5p_dock_only or enable_isolated_charging or not _live(self) or _hub == null or not _live(drone):
		return null
	var scope := get_parent()
	var hub := _hub.get_ref() as PrototypePowerStructure
	var b2 := scope.get_node_or_null("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
	if not _live(b2) or not b2.c5p_empty_mode() or b2._c1_charging != self or drone != scope.get_node_or_null("LogisticsDrone") or not _live(hub) or hub != scope.get_node_or_null("MainHub") or hub.scene_file_path != HUB_PATH or hub.get_parent() != scope:
		return null
	if not _live(hub.get_health()) or not hub.get_health().is_intact() or not hub.global_transform.is_finite() or not scope.has_meta(SCOPE_KEY) or (scope.get_meta(SCOPE_KEY) as WeakRef).get_ref() != self:
		return null
	return hub
