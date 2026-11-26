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
	if b2.receipt_id != receipt_id or b2.source != source:
		return false
	# The site is queue_free()'d after successful building activation;
	# never dereference an invalid original site during physical return.
	if phase not in [&"return", &"complete"] and (not _live(b2.site) or original_job != b2.site.job):
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
	if enable_c4a_blackout:
		return false
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
	if enable_c4a_blackout:
		return false
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
	if enable_c4a_blackout:
		return false
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

# C4A is explicitly separate from the historical B3 success path.
@export var enable_c4a_blackout: bool = false
var _c4_charging: PrototypeDroneHubCharging
var _c4_home: Vector3
var _c4_logistics: PrototypeConstructionWorkerDrone
var _c4_builder: PrototypeConstructionWorkerDrone
var _c4_admitted: bool = false
var _c4_bound_once: bool = false
var _c4_refs: Dictionary = {}

func _c4_scope() -> bool:
	var scope := _scope()
	return enable_c4a_blackout and enable_b3_builder and _live(self) and _live(scope) and scope.scene_file_path == EXACT_SCOPE and scope.get_node_or_null("B3BuilderController") == self and not is_processing() and not is_physics_processing()

func _c4_owner() -> bool:
	if not _c4_scope() or not _c4_admitted or not _scope().has_meta(TICK_OWNER):
		return false
	var token := _scope().get_meta(TICK_OWNER) as WeakRef
	if token == null or token.get_ref() != self:
		return false
	var x := _refs()
	for key: Variant in _c4_refs.keys():
		if not _live(_c4_refs[key]) or x.get(key) != _c4_refs[key]:
			return false
	if x["b1"].enable_b1_controller or x["b1"].is_processing() or x["b1"].is_physics_processing() or x["b2"].phase != &"c4_builder_owned":
		return false
	if not _live(_c4_charging) or _c4_charging != x["b2"]._c1_charging or _c4_charging.get_parent() != _scope() or not _live(power_pole) or not _live(power_pole.get_power_node()):
		return false
	if _c4_logistics.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.DOCKED or _c4_logistics.cargo_amount() != 0 or _c4_builder.cargo_amount() != 0 or _c4_builder.enable_isolated_cargo_pickup or _c4_builder.enable_isolated_cargo_delivery or not _live(source):
		return false
	if not x["coordinator"].matches_tick_services(x["scheduler"], x["escrow"]) or not x["coordinator"].matches_owned_registry(x["registry"]) or x["scheduler"].has_drone_binding(_c4_logistics):
		return false
	var chargers: int = 0
	for child: Node in _scope().get_children():
		if not _live(child):
			continue
		if child is PrototypeDroneHubCharging:
			chargers += 1
		if child is PrototypeDroneAutomaticDispatch or child is PrototypeConstructionDroneFleet or child is PrototypeConstructionDroneTickController:
			return false
		if child is SpecializedDroneBuilderE3d5c6fB3 and child != self:
			return false
	return chargers == 1

func c4_admission_preflight(b2: SpecializedDroneLogisticsE3d5c6fB2) -> bool:
	if not _c4_scope() or phase != &"c4_ready" or _c4_admitted or not _live(b2) or b2 != _scope().get_node_or_null("B2LogisticsController") or not b2._c3_owner():
		return false
	return b2.phase == &"c3_docked" and b2.receipt_id == receipt_id and b2.site == site and site.job == original_job and _c4_refs["contracts"].receipt_valid(receipt_id) and _c4_refs["escrow"].reservation_for(site) == escrow_id and _c4_refs["coordinator"].get_status(site).get("power_allocated", false) and _c4_refs["scheduler"].get_active_count() == 0 and _c4_builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE and _c4_home.distance_to(site.global_position + Vector3.UP * 2.0) * 2.0 + 0.25 <= 40.0

func c4_charging_authorized(charging: PrototypeDroneHubCharging, builder: PrototypeConstructionWorkerDrone) -> bool:
	if not _c4_scope() or charging != _c4_charging or builder != _c4_builder or not _live(charging) or not _live(builder) or builder != _scope().get_node_or_null("ConstructionDrone"):
		return false
	# Registration is performed after owner transfer, before assignment.
	return _c4_owner()

func configure_c4a(pole: PrototypePowerStructure) -> bool:
	if not _c4_scope() or phase != &"disabled":
		return false
	var x := _refs()
	if x.is_empty():
		return false
	for node: Variant in x.values():
		if not _live(node as Node):
			return false
	var b2: SpecializedDroneLogisticsE3d5c6fB2 = x["b2"]
	if not b2._c3_owner() or b2.phase != &"c3_docked" or not b2._core() or not x["contracts"].receipt_valid(b2.receipt_id):
		return false
	if not _live(pole) or pole.get_parent() != _scope() or pole.scene_file_path != "res://scenes/buildings/prototype_power_pole.tscn" or not _live(pole.get_power_node()):
		return false
	var hub := _scope().get_node("MainHub") as PrototypePowerStructure
	var builder: PrototypeConstructionWorkerDrone = x["builder"]
	if not _live(hub) or not builder.global_position.is_equal_approx(hub.global_position + Vector3(0.65, 2, 0)) or builder.enable_isolated_drone or builder.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE:
		return false
	site = b2.site
	original_job = site.job
	source = b2.source
	power_pole = pole
	receipt_id = b2.receipt_id
	escrow_id = x["escrow"].reservation_for(site)
	if escrow_id <= 0 or x["escrow"].held_materials(escrow_id) != {INGOT: 5}:
		return false
	_c4_refs = x
	_c4_builder = builder
	_c4_logistics = x["logistics"]
	_c4_home = builder.global_position
	_c4_charging = b2._c1_charging
	if not _live(_c4_charging) or not x["network"].register_node(pole.get_power_node()) or not x["network"].link_nodes(hub.get_power_node(), pole.get_power_node()):
		return false
	if not x["coordinator"].matches_tick_services(x["scheduler"], x["escrow"]) or not x["coordinator"].matches_owned_registry(x["registry"]):
		return false
	x["scheduler"].enable_isolated_drone_presence = true
	if not x["coordinator"].track_site(site, 7):
		return false
	site.building_completed.connect(_on_building_completed)
	phase = &"c4_ready"
	return true

func start_c4a() -> bool:
	if not _c4_scope() or phase != &"c4_ready":
		return false
	var x := _c4_refs
	var b2: SpecializedDroneLogisticsE3d5c6fB2 = x["b2"]
	# B2's exact guards require an inert builder until transfer. Forecast
	# the configured 40-unit round trip without mutating builder beforehand.
	if not b2._c3_owner() or not x["contracts"].receipt_valid(receipt_id) or x["coordinator"].reconcile() != 0 or not x["coordinator"].get_status(site).get("power_allocated", false):
		return false
	var distance: float = _c4_home.distance_to(site.global_position + Vector3.UP * 2.0)
	if distance * 2.0 + 0.25 > 40.0:
		return false
	if not b2.c4_transfer_to_builder(self):
		return false
	_c4_admitted = true
	_c4_builder.enable_isolated_drone = true
	_c4_builder.enable_isolated_battery = true
	_c4_builder.enable_isolated_finite_charging = true
	_c4_builder.enable_specialized_c4_parking = true
	if not _c4_builder.configure_battery(40.0, 40.0, 1.0, 4.0):
		return false
	_c4_charging.enable_specialized_c4_builder_dock = true
	if not _c4_charging.register_drone(_c4_builder):
		return false
	if not x["contracts"].claim_builder(receipt_id, _c4_builder) or not _c4_builder.assign_to_site(site, _c4_home, 2.0, 2.0):
		return false
	phase = &"c4_flight"
	return true

func c4_flight_authorized(builder: PrototypeConstructionWorkerDrone, original_site: ConstructionSite) -> bool:
	if not _c4_owner() or builder != _c4_builder or not _live(original_site) or original_site != site or site.job != original_job:
		return false
	return _c4_refs["contracts"].c4_builder_authorized(receipt_id, builder, site, original_job, _c4_refs["escrow"])

func step_c4a(delta: float) -> StringName:
	if not _c4_owner() or not is_finite(delta) or delta <= 0.0 or delta > 1.0 or phase not in [&"c4_flight", &"c4_work", &"c4_parking", &"c4_parked", &"c4_complete_return"]:
		return &"rejected"
	var coordinator: BlueprintConstructionReadinessCoordinator = _c4_refs["coordinator"]
	var scheduler: BlueprintConstructionSlotScheduler = _c4_refs["scheduler"]
	var escrow: BlueprintConstructionMaterialEscrow = _c4_refs["escrow"]
	var builder := _c4_builder
	var flight := builder.get_flight_state()
	if phase == &"c4_complete_return":
		if original_job.state != ConstructionJob.State.COMPLETE or not _live(completed_building) or escrow.has_reservation(escrow_id):
			return &"rejected"
		coordinator.reconcile()
		if flight == PrototypeConstructionWorkerDrone.FlightState.AT_SITE:
			builder.advance_flight(0.001)
		elif flight == PrototypeConstructionWorkerDrone.FlightState.RETURNING:
			if not builder.advance_flight(delta):
				return &"energy_wait"
		elif flight != PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			return &"rejected"
		tick_count += 1
		if builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			phase = &"c4_complete"
			return &"complete"
		return &"complete_return"
	if not c4_flight_authorized(builder, site):
		return &"rejected"
	coordinator.reconcile()
	var status: Dictionary = coordinator.get_status(site)
	var powered: bool = bool(status.get("power_allocated", false))
	if not status.get("materials_reserved", false):
		return &"rejected"
	tick_count += 1
	if phase in [&"c4_flight", &"c4_work"] and not powered:
		if scheduler.get_active_count() != 0 or not builder.c4_begin_parking(self, site):
			return &"rejected"
		phase = &"c4_parked" if builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED else &"c4_parking"
		return &"parking_started"
	if phase == &"c4_parking":
		if not builder.advance_flight(delta):
			return &"energy_wait"
		if builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			phase = &"c4_parked"
		return &"parking"
	if phase == &"c4_parked":
		if scheduler.get_active_count() != 0 or flight != PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			return &"rejected"
		if not powered:
			return &"blackout_wait"
		if not builder.c4_can_resume(self, site):
			_c4_charging.advance_charging(delta)
			return &"energy_wait"
		if not builder._finite_cargo_rearm_ready():
			_c4_charging.advance_charging(delta)
			return &"charging"
		if not builder.c4_begin_resume(self, site):
			return &"rejected"
		phase = &"c4_flight"
		return &"resumed_flight"
	if phase == &"c4_flight":
		if not builder.is_at_site():
			if not builder.advance_flight(delta):
				# Existing flight energy forecast can safely retire a trip.
				if builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING:
					return &"rejected"
				return &"energy_wait"
		if builder.is_at_site():
			if not _c4_bound_once:
				if not scheduler.bind_specialized_builder(site, builder, _c4_refs["contracts"], receipt_id, coordinator, escrow):
					return &"rejected"
				_c4_bound_once = true
			coordinator.reconcile()
			if original_job.state != ConstructionJob.State.CONSTRUCTING or scheduler.get_active_count() != 1 or not builder.c4_finish_resume(self, site):
				return &"rejected"
			phase = &"c4_work"
			return &"admitted"
		return &"flight"
	if not builder.is_at_site() or not scheduler.has_drone_binding(builder) or scheduler.get_active_count() != 1 or original_job.state != ConstructionJob.State.CONSTRUCTING:
		return &"rejected"
	progress_ticks += 1
	original_job.advance(delta)
	if original_job.state == ConstructionJob.State.COMPLETE:
		if not _live(completed_building) or escrow.has_reservation(escrow_id):
			return &"rejected"
		builder.advance_flight(0.001)
		phase = &"c4_complete_return"
		return &"built"
	return &"work"

func c4_resume_power_authorized(builder: PrototypeConstructionWorkerDrone, original_site: ConstructionSite) -> bool:
	return phase == &"c4_parked" and c4_flight_authorized(builder, original_site) and _c4_refs["coordinator"].get_status(site).get("power_allocated", false) and _c4_refs["scheduler"].get_active_count() == 0
