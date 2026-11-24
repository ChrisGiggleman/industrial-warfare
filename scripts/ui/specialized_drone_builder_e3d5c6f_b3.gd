extends Node
class_name SpecializedDroneBuilderE3d5c6fB3

## Stage B3: exact-scoped second physical drone, ONE inherited simulation tick.
## The original coordinator/scheduler controls all worker readiness; original
## job advances once per explicit step. No free cargo/charge/power.
@export var enable_b3_builder: bool = false
const EXACT_SCOPE := "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn"
const TICK_OWNER := &"e3d5c6f_single_tick_owner"
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")

var site: ConstructionSite
var original_job: ConstructionJob
var power_pole: PrototypePowerStructure
var source: InventoryComponent
var receipt_id: int = 0
var escrow_id: int = 0
var completed_building: Node3D
var phase: StringName = &"disabled"
var tick_count: int = 0
var progress_ticks: int = 0

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

func _live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()

func _scope() -> Node3D:
	return get_parent() as Node3D

func _refs() -> Dictionary:
	var scope := _scope()
	if not _live(scope) or scope.scene_file_path != EXACT_SCOPE:
		return {}
	return {
		"b1": scope.get_node_or_null("SingleTickController") as PlayableSpecializedDronesE3d5c6f,
		"b2": scope.get_node_or_null("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2,
		"contracts": scope.get_node_or_null("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f,
		"builder": scope.get_node_or_null("ConstructionDrone") as PrototypeConstructionWorkerDrone,
		"logistics": scope.get_node_or_null("LogisticsDrone") as PrototypeConstructionWorkerDrone,
		"queue": scope.get_node_or_null("PriorityQueue") as BlueprintConstructionPriorityQueue,
		"registry": scope.get_node_or_null("StagingRegistry") as BlueprintConstructionSiteStagingRegistry,
		"escrow": scope.get_node_or_null("MaterialEscrow") as BlueprintConstructionMaterialEscrow,
		"scheduler": scope.get_node_or_null("WorkerScheduler") as BlueprintConstructionSlotScheduler,
		"coordinator": scope.get_node_or_null("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator,
		"power": scope.get_node_or_null("PowerAllocator") as PrototypeConstructionPowerAllocator,
		"network": scope.get_node_or_null("PowerNetwork") as ConstructionPowerCoverageNetwork
	}

func _core() -> bool:
	var scope := _scope()
	if not enable_b3_builder or not _live(self) or not _live(scope) or scope.scene_file_path != EXACT_SCOPE or scope.get_node_or_null("B3BuilderController") != self:
		return false
	if is_processing() or is_physics_processing() or original_job == null or receipt_id <= 0 or escrow_id <= 0:
		return false
	var x := _refs()
	if x.is_empty():
		return false
	for node: Variant in x.values():
		if not _live(node as Node):
			return false
	var b1: PlayableSpecializedDronesE3d5c6f = x["b1"]
	var b2: SpecializedDroneLogisticsE3d5c6fB2 = x["b2"]
	var builder: PrototypeConstructionWorkerDrone = x["builder"]
	var logistics: PrototypeConstructionWorkerDrone = x["logistics"]
	var scheduler: BlueprintConstructionSlotScheduler = x["scheduler"]
	var coordinator: BlueprintConstructionReadinessCoordinator = x["coordinator"]
	var escrow: BlueprintConstructionMaterialEscrow = x["escrow"]
	if b1.enable_b1_controller or b2.phase != &"delivered" or builder == logistics or not _live(source):
		return false
	if not _live(power_pole) or power_pole.get_parent() != scope or not _live(power_pole.get_power_node()):
		return false
	if not coordinator.matches_tick_services(scheduler, escrow) or not scheduler.enable_isolated_drone_presence or not scheduler.uses_priority_queue(x["queue"]):
		return false
	if original_job != b2.site.job or b2.receipt_id != receipt_id or b2.source != source:
		return false
	if logistics.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.DOCKED or logistics.cargo_amount() != 0:
		return false
	if phase not in [&"return", &"complete"]:
		if not _live(site) or site.job != original_job or site.get_parent() != scope:
			return false
		if phase in [&"ready", &"flight", &"work"] and original_job.state not in [ConstructionJob.State.QUEUED, ConstructionJob.State.CONSTRUCTING, ConstructionJob.State.PAUSED]:
			return false
	return true

func _on_building_completed(building: Node3D) -> void:
	if is_instance_valid(building) and not is_instance_valid(completed_building):
		completed_building = building

# Configure only after the original logistics drone has returned and B2's
# exact receipt remains valid. Original power network and coordinator are
# configured once, without creating a second escrow or worker-slot service.
func configure_b3(pole: PrototypePowerStructure) -> bool:
	if not enable_b3_builder or phase != &"disabled":
		return false
	var x := _refs()
	if x.is_empty():
		return false
	var b2: SpecializedDroneLogisticsE3d5c6fB2 = x["b2"]
	var contracts: SpecializedDroneRoleContractsE3d5c6f = x["contracts"]
	var builder: PrototypeConstructionWorkerDrone = x["builder"]
	var escrow: BlueprintConstructionMaterialEscrow = x["escrow"]
	if not _live(b2) or not b2.b2_completed() or not _live(contracts) or not contracts.receipt_valid(b2.receipt_id):
		return false
	if not _live(builder) or builder.enable_isolated_drone or builder.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE or builder.cargo_amount() != 0:
		return false
	if not _live(pole) or pole.get_parent() != _scope() or pole.scene_file_path != "res://scenes/buildings/prototype_power_pole.tscn":
		return false
	site = b2.site
	original_job = site.job
	source = b2.source
	power_pole = pole
	receipt_id = b2.receipt_id
	escrow_id = escrow.reservation_for(site)
	if escrow_id <= 0 or escrow.held_materials(escrow_id) != {INGOT: 5} or source.get_amount(INGOT) != 10:
		return false
	var network: ConstructionPowerCoverageNetwork = x["network"]
	var power: PrototypeConstructionPowerAllocator = x["power"]
	var hub := _scope().get_node_or_null("MainHub") as PrototypePowerStructure
	if not _live(hub) or not _live(network) or not _live(power):
		return false
	if not network.register_node(hub.get_power_node()) or not network.register_node(pole.get_power_node()):
		return false
	if not network.link_nodes(hub.get_power_node(), pole.get_power_node()) or not power.configure(network):
		return false
	var coordinator: BlueprintConstructionReadinessCoordinator = x["coordinator"]
	var scheduler: BlueprintConstructionSlotScheduler = x["scheduler"]
	var queue: BlueprintConstructionPriorityQueue = x["queue"]
	var registry: BlueprintConstructionSiteStagingRegistry = x["registry"]
	if not coordinator.configure(queue, scheduler, escrow, power, source, 1):
		return false
	coordinator.enable_isolated_owned_staging = true
	if not coordinator.configure_owned_staging(registry):
		return false
	scheduler.enable_isolated_drone_presence = true
	if not coordinator.track_site(site, 7):
		return false
	if not site.building_completed.is_connected(_on_building_completed):
		site.building_completed.connect(_on_building_completed)
	phase = &"ready"
	return _core()

func start_builder() -> bool:
	if phase != &"ready" or not _core():
		return false
	var x := _refs()
	var b2: SpecializedDroneLogisticsE3d5c6fB2 = x["b2"]
	var contracts: SpecializedDroneRoleContractsE3d5c6f = x["contracts"]
	var builder: PrototypeConstructionWorkerDrone = x["builder"]
	var scheduler: BlueprintConstructionSlotScheduler = x["scheduler"]
	var coordinator: BlueprintConstructionReadinessCoordinator = x["coordinator"]
	var escrow: BlueprintConstructionMaterialEscrow = x["escrow"]
	if not b2.b2_completed() or not contracts.receipt_valid(receipt_id) or not scheduler.is_tracking_site(site):
		return false
	if not coordinator.matches_tick_services(scheduler, escrow) or not coordinator.matches_owned_registry(x["registry"]):
		return false
	# Existing scheduler sees original real material escrow + power but no
	# worker binding; this preflight must NEVER start construction.
	if coordinator.reconcile() != 0 or original_job.state != ConstructionJob.State.QUEUED:
		return false
	if not b2.transfer_tick_owner_to_builder(self):
		return false
	builder.enable_isolated_drone = true
	builder.enable_isolated_battery = true
	if not builder.configure_battery(40.0, 40.0, 1.0, 4.0):
		return false
	if not builder.has_round_trip_energy(site, 2.0):
		return false
	if not contracts.claim_builder(receipt_id, builder):
		return false
	if not builder.assign_to_site(site, builder.global_position, 2.0, 2.0):
		return false
	phase = &"flight"
	return true

# Called explicitly by F6 or later exactly ONE scene adapter. B2 has
# relinquished the tick token. Always reconcile once before advancing the
# existing job, and never advance a job from a second site timer.
func step_builder(delta: float) -> bool:
	if not is_finite(delta) or delta <= 0.0 or delta > 18.0 or phase not in [&"flight", &"work", &"return"] or not _core():
		return false
	var scope := _scope()
	if not scope.has_meta(TICK_OWNER):
		return false
	var token := scope.get_meta(TICK_OWNER) as WeakRef
	if token == null or token.get_ref() != self:
		return false
	var x := _refs()
	var builder: PrototypeConstructionWorkerDrone = x["builder"]
	var scheduler: BlueprintConstructionSlotScheduler = x["scheduler"]
	var coordinator: BlueprintConstructionReadinessCoordinator = x["coordinator"]
	var escrow: BlueprintConstructionMaterialEscrow = x["escrow"]
	var contracts: SpecializedDroneRoleContractsE3d5c6f = x["contracts"]
	if phase == &"flight":
		if not contracts.builder_claim_valid(receipt_id, builder) or escrow.reservation_for(site) != escrow_id:
			return false
		coordinator.reconcile()
		if not builder.is_at_site():
			if not builder.advance_flight(delta):
				return false
		if builder.is_at_site():
			# Power can be absent while physically waiting. Do not bind a
			# worker until original service confirms allocation.
			var status := coordinator.get_status(site)
			if bool(status["materials_reserved"]) and bool(status["power_allocated"]):
				if not scheduler.bind_specialized_builder(site, builder, contracts, receipt_id, coordinator, escrow):
					return false
				if coordinator.reconcile() != 1 or original_job.state != ConstructionJob.State.CONSTRUCTING:
					return false
				phase = &"work"
	elif phase == &"work":
		if not builder.is_at_site() or escrow.reservation_for(site) != escrow_id or not scheduler.has_drone_binding(builder):
			return false
		coordinator.reconcile()
		if original_job.state == ConstructionJob.State.CONSTRUCTING:
			progress_ticks += 1
			original_job.advance(delta)
			if original_job.state == ConstructionJob.State.COMPLETE:
				if not is_instance_valid(completed_building) or escrow.has_reservation(escrow_id):
					return false
				# Completion queues the old site for deletion. Existing
				# flight logic detects the ended original job and returns
				# on subsequent bounded steps, without a new timer.
				builder.advance_flight(0.001)
				phase = &"return"
		elif original_job.state != ConstructionJob.State.PAUSED:
			return false
	else: # return
		if original_job.state != ConstructionJob.State.COMPLETE or not is_instance_valid(completed_building):
			return false
		coordinator.reconcile()
		if builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
			builder.advance_flight(0.001)
		elif builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING:
			if not builder.advance_flight(delta):
				return false
		else:
			return false
		if builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			phase = &"complete"
	tick_count += 1
	return true

func b3_completed() -> bool:
	if phase != &"complete" or not _core():
		return false
	var x := _refs()
	var builder: PrototypeConstructionWorkerDrone = x["builder"]
	var logistics: PrototypeConstructionWorkerDrone = x["logistics"]
	var scheduler: BlueprintConstructionSlotScheduler = x["scheduler"]
	var escrow: BlueprintConstructionMaterialEscrow = x["escrow"]
	if not is_instance_valid(completed_building) or completed_building.is_queued_for_deletion():
		return false
	var runtime := completed_building.get_node_or_null("BuildingRuntime") as BuildingRuntime
	return is_instance_valid(runtime) and runtime.building_definition == PRESS and original_job.state == ConstructionJob.State.COMPLETE and original_job.get_progress() >= 1.0 and original_job.get_remaining_seconds() <= 0.0 and escrow.held_count() == 0 and source.get_amount(INGOT) == 10 and builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED and logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED and builder.cargo_amount() == 0 and logistics.cargo_amount() == 0 and scheduler.get_active_count() == 0
