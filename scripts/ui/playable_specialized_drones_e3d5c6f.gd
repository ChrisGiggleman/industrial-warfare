extends Node
class_name PlayableSpecializedDronesE3d5c6f

## E3d5c6f B1: one explicitly stepped, exact-scoped coordinator.
## B1 NEVER dispatches, advances flight, charges, transfers cargo, reconciles
## worker availability or advances construction. Only observational ticks.
@export var enable_b1_controller: bool = false

const EXACT_SCENE := "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn"
const HUB_SCENE := "res://scenes/buildings/prototype_main_hub.tscn"
const SCOPE_TICK_OWNER := &"e3d5c6f_single_tick_owner"
var tick_count: int = 0
var last_tick: Dictionary = {}

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

func _live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()

func _scope() -> Node3D:
	return get_parent() as Node3D

func _valid_scope() -> bool:
	var scope := _scope()
	if not enable_b1_controller or not _live(self) or not _live(scope) or scope.scene_file_path != EXACT_SCENE:
		return false
	if not _live(scope.get_node_or_null("RoleContracts")) or not (scope.get_node("RoleContracts") is SpecializedDroneRoleContractsE3d5c6f):
		return false
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	if not contracts.enable_stage_a_contracts or not contracts._scope_ok():
		return false
	var hub := scope.get_node_or_null("MainHub") as PrototypePowerStructure
	var logistics := scope.get_node_or_null("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node_or_null("ConstructionDrone") as PrototypeConstructionWorkerDrone
	if not _live(hub) or not _live(logistics) or not _live(builder) or logistics == builder:
		return false
	if hub.get_parent() != scope or hub.scene_file_path != HUB_SCENE or not _live(hub.get_power_node()):
		return false
	if logistics.get_parent() != scope or builder.get_parent() != scope:
		return false
	if logistics.enable_isolated_drone or builder.enable_isolated_drone:
		return false # B1 cannot launch a worker or enable any movement.
	if logistics.enable_isolated_cargo_pickup or builder.enable_isolated_cargo_pickup:
		return false
	if logistics.enable_isolated_cargo_delivery or builder.enable_isolated_cargo_delivery:
		return false
	var counts := {"hub": 0, "drone": 0, "controller": 0, "contracts": 0, "queue": 0, "registry": 0, "escrow": 0, "scheduler": 0, "coordinator": 0, "allocator": 0, "source": 0}
	for node: Node in scope.get_children():
		if not _live(node):
			continue
		if node is PrototypePowerStructure and node.scene_file_path == HUB_SCENE:
			counts["hub"] += 1
		if node is PrototypeConstructionWorkerDrone:
			counts["drone"] += 1
		if node is PlayableSpecializedDronesE3d5c6f:
			counts["controller"] += 1
		if node is SpecializedDroneRoleContractsE3d5c6f:
			counts["contracts"] += 1
		if node is BlueprintConstructionPriorityQueue:
			counts["queue"] += 1
		if node is BlueprintConstructionSiteStagingRegistry:
			counts["registry"] += 1
		if node is BlueprintConstructionMaterialEscrow:
			counts["escrow"] += 1
		if node is BlueprintConstructionSlotScheduler:
			counts["scheduler"] += 1
		if node is BlueprintConstructionReadinessCoordinator:
			counts["coordinator"] += 1
		if node is PrototypeConstructionPowerAllocator:
			counts["allocator"] += 1
		if node is InventoryComponent:
			counts["source"] += 1
		if node is PrototypeDroneAutomaticDispatch or node is PrototypeConstructionDroneFleet or node is PrototypeConstructionDroneTickController or node is PrototypeDroneHubCharging:
			return false
	for key: String in counts.keys():
		var expected: int = 2 if key == "drone" else 1
		if counts[key] != expected:
			return false
	if _live(scope.get_node_or_null("PriorityQueue")) == false or not (scope.get_node("PriorityQueue") is BlueprintConstructionPriorityQueue):
		return false
	if not (scope.get_node_or_null("StagingRegistry") is BlueprintConstructionSiteStagingRegistry):
		return false
	if not (scope.get_node_or_null("MaterialEscrow") is BlueprintConstructionMaterialEscrow):
		return false
	if not (scope.get_node_or_null("WorkerScheduler") is BlueprintConstructionSlotScheduler):
		return false
	if not (scope.get_node_or_null("ReadinessCoordinator") is BlueprintConstructionReadinessCoordinator):
		return false
	if not (scope.get_node_or_null("PowerAllocator") is PrototypeConstructionPowerAllocator):
		return false
	if not (scope.get_node_or_null("StarterInventory") is InventoryComponent):
		return false
	return not is_processing() and not is_physics_processing()

func has_verified_b1_scope() -> bool:
	return _valid_scope()

func step_b1(delta: float) -> bool:
	if not is_finite(delta) or delta <= 0.0 or delta > 1.0 or not _valid_scope():
		return false
	var scope := _scope()
	# No second controller may advance the same scene, even through an
	# externally attached script/duplicate node.
	if scope.has_meta(SCOPE_TICK_OWNER):
		var owner_ref := scope.get_meta(SCOPE_TICK_OWNER) as WeakRef
		if owner_ref == null or owner_ref.get_ref() != self:
			return false
	else:
		scope.set_meta(SCOPE_TICK_OWNER, weakref(self))
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node("ConstructionDrone") as PrototypeConstructionWorkerDrone
	if logistics.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE or builder.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE:
		return false
	if logistics.cargo_amount() != 0 or builder.cargo_amount() != 0:
		return false
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	if not queue.get_waiting_sites().is_empty() or escrow.held_count() != 0 or scheduler.get_active_count() != 0:
		return false
	# Exactly one inert inspection/tick; physical movement starts in B2.
	tick_count += 1
	last_tick = {"action": &"b1_idle", "tick": tick_count, "delta": delta}
	return true
