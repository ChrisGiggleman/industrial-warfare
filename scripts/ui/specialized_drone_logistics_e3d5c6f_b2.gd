extends Node
class_name SpecializedDroneLogisticsE3d5c6fB2

## B2 single-mission explicit step owner. No _process, second dispatcher, or builder movement.
## The original supplier, physical drone, staging registry and escrow own all items.
@export var enable_b2_logistics: bool = false
const EXACT_SCOPE := "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn"
const TICK_OWNER := &"e3d5c6f_single_tick_owner"
const INGOT := preload("res://data/items/test_ingot.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
var site: ConstructionSite
var storage: Node3D
var source: InventoryComponent
var buffer: InventoryComponent
var lease_id: int = 0
var pickup_id: int = 0
var receipt_id: int = 0
var phase: StringName = &"disabled"
var tick_count: int = 0

func _ready() -> void:
	set_process(false)
	set_physics_process(false)

func _live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()

func _scope() -> Node3D:
	return get_parent() as Node3D

func _core() -> bool:
	var scope := _scope()
	if not enable_b2_logistics or not _live(self) or not _live(scope) or scope.scene_file_path != EXACT_SCOPE:
		return false
	if scope.get_node_or_null("B2LogisticsController") != self:
		return false
	var b1 := scope.get_node_or_null("SingleTickController") as PlayableSpecializedDronesE3d5c6f
	var logistics := scope.get_node_or_null("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node_or_null("ConstructionDrone") as PrototypeConstructionWorkerDrone
	var contracts := scope.get_node_or_null("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	if not _live(b1) or b1.enable_b1_controller or b1.is_processing() or not _live(logistics) or not _live(builder) or logistics == builder:
		return false
	if not _live(contracts) or not contracts._scope_ok() or not _live(scope.get_node_or_null("MainHub")):
		return false
	if builder.enable_isolated_drone or builder.enable_isolated_cargo_pickup or builder.enable_isolated_cargo_delivery or builder.cargo_amount() != 0 or builder.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE:
		return false
	if not _live(scope.get_node_or_null("PriorityQueue")) or not _live(scope.get_node_or_null("StagingRegistry")) or not _live(scope.get_node_or_null("MaterialEscrow")) or not _live(scope.get_node_or_null("StorageDiscovery")) or not _live(scope.get_node_or_null("SupplierReservations")):
		return false
	if not _live(scope.get_node_or_null("WorkerScheduler")) or not _live(scope.get_node_or_null("ReadinessCoordinator")):
		return false
	if not _live(site) or site.get_parent() != scope or site.target_definition != PRESS or site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return false
	if not _live(storage) or storage.get_parent() != scope or not _live(source) or not _live(buffer):
		return false
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	if queue.get_waiting_sites().size() != 1 or queue.peek_next() != site or not registry.matches_owned_inventory(site, buffer) or scheduler.get_active_count() != 0 or scheduler.has_drone_binding(logistics) or scheduler.has_drone_binding(builder):
		return false
	if site.job.get_progress() != 0.0 or site.job.get_wait_reasons().has(&"workers") == false:
		return false
	if escrow.held_count() > 1:
		return false
	var count: int = 0
	var suppliers: int = 0
	var discoveries: int = 0
	for node: Node in scope.get_children():
		if not _live(node):
			continue
		if node is SpecializedDroneLogisticsE3d5c6fB2:
			count += 1
		if node is PrototypeDroneSupplierReservations:
			suppliers += 1
		if node is PrototypeDroneStorageDiscovery:
			discoveries += 1
		if node is PrototypeDroneAutomaticDispatch or node is PrototypeConstructionDroneFleet or node is PrototypeConstructionDroneTickController:
			return false
	return count == 1 and suppliers == 1 and discoveries == 1 and not is_processing() and not is_physics_processing()

func configure_b2(original_site: ConstructionSite, original_storage: Node3D, original_staging: BlueprintConstructionMaterialStaging, original_port: BlueprintConstructionStagingInputPort, dock: PrototypeDroneStorageDock) -> bool:
	if not enable_b2_logistics or phase != &"disabled" or not _live(self):
		return false
	var scope := _scope()
	if scope == null or scope.scene_file_path != EXACT_SCOPE or not _live(original_site) or original_site.get_parent() != scope or original_site.target_definition != PRESS or original_site.job.state != ConstructionJob.State.QUEUED:
		return false
	if not _live(original_storage) or original_storage.get_parent() != scope or not _live(original_staging) or not _live(original_port) or not _live(dock) or dock.get_parent() != original_storage:
		return false
	var original_source := original_storage.get_node_or_null("InventoryComponent") as InventoryComponent
	if not _live(original_source) or not original_source.enable_isolated_drone_claims or original_source.get_amount(INGOT) != 15:
		return false
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var discovery := scope.get_node("StorageDiscovery") as PrototypeDroneStorageDiscovery
	var supplier := scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	if not _live(logistics) or logistics.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE or logistics.cargo_amount() != 0:
		return false
	if not registry.enable_isolated_site_registry or not registry.matches_owned_inventory(original_site, original_staging.get_staged_inventory()) or not queue.get_waiting_sites().has(original_site):
		return false
	if original_port.get_bound_staging() != original_staging or not original_staging.accepts_delivered_item(INGOT, 5):
		return false
	# These existing source services are default-OFF in the B1 scene.
	# Enable only after exact E3d5c6f scope and original site/stock/receiver
	# preflight; never require the F6 fixture to secretly enable them.
	if not _live(discovery) or not _live(supplier) or discovery.get_parent() != scope or supplier.get_parent() != scope:
		return false
	if discovery.enable_isolated_discovery or supplier.enable_isolated_reservations:
		return false # A caller must not preconfigure or replace these authorities.
	discovery.enable_isolated_discovery = true
	supplier.enable_isolated_reservations = true
	if not supplier.configure(discovery) or not discovery.register_dock(dock):
		return false
	site = original_site
	storage = original_storage
	source = original_source
	buffer = original_staging.get_staged_inventory()
	# Cargo permissions enabled only AFTER exact scope/material identity preflight.
	logistics.enable_isolated_drone = true
	logistics.enable_isolated_battery = true
	logistics.enable_isolated_cargo_pickup = true
	logistics.enable_isolated_cargo_delivery = true
	if not logistics.configure_battery(40.0, 40.0, 1.0, 4.0):
		logistics.enable_isolated_drone = false
		logistics.enable_isolated_battery = false
		logistics.enable_isolated_cargo_pickup = false
		logistics.enable_isolated_cargo_delivery = false
		return false
	phase = &"ready"
	return _core()

func start_b2() -> bool:
	if enable_c1_pre_pickup_cancel:
		return false
	if phase != &"ready" or not _core():
		return false
	var scope := _scope()
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var discovery := scope.get_node("StorageDiscovery") as PrototypeDroneStorageDiscovery
	var supplier := scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var forecast := discovery.find_pickup(logistics, site, INGOT, 5, 5, 2.0, true)
	if forecast.is_empty() or forecast.get("inventory") != source:
		return false
	# Retain the Stage A exact-site logistics lease before the material claim.
	lease_id = contracts.claim_logistics(site, logistics, queue, registry, buffer)
	if lease_id <= 0:
		return false
	pickup_id = supplier.reserve(logistics, site, INGOT, 5, 5)
	if pickup_id <= 0 or not supplier.begin_pickup(pickup_id, logistics, 2.0):
		return false # Fail closed, no early escrow or manufactured refund.
	phase = &"pickup"
	return true

func step_b2(delta: float) -> bool:
	if enable_c1_pre_pickup_cancel:
		return false
	if not is_finite(delta) or delta <= 0.0 or delta > 10.0 or not _core():
		return false
	var scope := _scope()
	if scope.has_meta(TICK_OWNER):
		var ref := scope.get_meta(TICK_OWNER) as WeakRef
		if ref == null or ref.get_ref() != self:
			return false
	else:
		scope.set_meta(TICK_OWNER, weakref(self))
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var supplier := scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	match phase:
		&"pickup":
			if not supplier.advance_pickup(pickup_id, logistics, delta):
				return false
			if logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP:
				if not supplier.collect_pickup(pickup_id, logistics):
					return false
				if source.get_amount(INGOT) != 10 or logistics.cargo_amount() != 5 or not logistics.begin_delivery(site, registry, escrow):
					return false
				phase = &"delivery"
		&"delivery":
			if not logistics.advance_delivery(delta):
				return false
			if logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_DELIVERY:
				if not logistics.unload_delivery():
					return false
				if logistics.cargo_amount() != 0 or buffer.get_amount(INGOT) != 5:
					return false
				var escrow_id: int = registry.reserve_for_site(site, escrow)
				if escrow_id <= 0 or not escrow.matches_site_source_bill(site, buffer):
					return false
				receipt_id = contracts.seal_handoff(lease_id, escrow)
				if receipt_id != lease_id or not contracts.receipt_valid(receipt_id):
					return false
				if not logistics.begin_specialized_logistics_return(contracts, receipt_id, escrow):
					return false
				phase = &"return"
		&"return":
			if not contracts.receipt_valid(receipt_id) or not logistics.advance_flight(delta):
				return false
			if logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
				if not logistics.finish_specialized_logistics_return(contracts, receipt_id, escrow):
					return false
				phase = &"delivered"
		_:
			return false
	tick_count += 1
	return true

func b2_completed() -> bool:
	if phase != &"delivered" or not _core():
		return false
	var scope := _scope()
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	var original_id: int = escrow.reservation_for(site)
	return original_id > 0 and contracts.receipt_valid(receipt_id) and contracts.lease_count() == 1 and escrow.held_materials(original_id) == {INGOT: 5} and source.get_amount(INGOT) == 10 and buffer.get_total_amount() == 0 and logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED and logistics.cargo_amount() == 0 and not logistics.grants_worker_readiness() and site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0


# B3: single-owner *transfer*, not another active tick driver. The B2
# controller remains frozen at delivered; only this exact new controller
# can inherit the same scene's already-owned step token.
func transfer_tick_owner_to_builder(builder_controller: Node) -> bool:
	if not b2_completed() or not _live(builder_controller) or builder_controller.get_parent() != _scope():
		return false
	if builder_controller.name != "B3BuilderController" or _scope().get_node_or_null("B3BuilderController") != builder_controller:
		return false
	if not builder_controller is SpecializedDroneBuilderE3d5c6fB3:
		return false
	var scope := _scope()
	if not scope.has_meta(TICK_OWNER):
		return false
	var current := scope.get_meta(TICK_OWNER) as WeakRef
	if current == null or current.get_ref() != self:
		return false
	scope.set_meta(TICK_OWNER, weakref(builder_controller))
	return true

# C1 opt-in: isolated pre-collection lifecycle, using the same B2 owner.
# The normal B2 successful delivery path remains unchanged when disabled.
@export var enable_c1_pre_pickup_cancel: bool = false
var _c1_job: ConstructionJob
var _c1_returns: PrototypeDroneReturnReservations
var _c1_charging: PrototypeDroneHubCharging
var _c1_home: Vector3

func _c1_owner() -> bool:
	var scope := _scope()
	if not enable_c1_pre_pickup_cancel or not _live(scope) or scope.scene_file_path != EXACT_SCOPE or scope.get_node_or_null("B2LogisticsController") != self:
		return false
	if is_processing() or is_physics_processing() or not scope.has_meta(TICK_OWNER):
		return false
	var token := scope.get_meta(TICK_OWNER) as WeakRef
	return token != null and token.get_ref() == self

func configure_c1() -> bool:
	if not enable_c1_pre_pickup_cancel or phase != &"ready" or _c1_job != null or not _core():
		return false
	var scope := _scope()
	if scope.has_meta(TICK_OWNER):
		return false
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var hub := scope.get_node("MainHub") as PrototypePowerStructure
	var network := scope.get_node("PowerNetwork") as ConstructionPowerCoverageNetwork
	var power := scope.get_node("PowerAllocator") as PrototypeConstructionPowerAllocator
	var coordinator := scope.get_node("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var discovery := scope.get_node("StorageDiscovery") as PrototypeDroneStorageDiscovery
	if not _live(hub) or not _live(network) or not _live(power) or not _live(hub.get_power_node()):
		return false
	if not logistics.global_position.is_equal_approx(hub.global_position + Vector3(-0.65, 2, 0)):
		return false
	for child: Node in scope.get_children():
		if child is PrototypeDroneReturnReservations or child is PrototypeDroneHubCharging:
			return false
	if not network.register_node(hub.get_power_node()) or not power.configure(network):
		return false
	if not coordinator.configure(queue, scheduler, escrow, power, scope.get_node("StarterInventory") as InventoryComponent, 1):
		return false
	coordinator.enable_isolated_owned_staging = true
	if not coordinator.configure_owned_staging(registry):
		return false
	_c1_returns = PrototypeDroneReturnReservations.new()
	_c1_returns.enable_isolated_reservations = true
	scope.add_child(_c1_returns)
	if not _c1_returns.configure(discovery):
		return false
	_c1_charging = PrototypeDroneHubCharging.new()
	_c1_charging.enable_isolated_charging = true
	_c1_charging.enable_specialized_c1_dock = true
	scope.add_child(_c1_charging)
	logistics.enable_isolated_finite_charging = true
	logistics.enable_isolated_cargo_reuse = true
	logistics.enable_isolated_pre_pickup_rearm = true
	if not _c1_charging.configure(hub, power) or not _c1_charging.register_drone(logistics):
		return false
	_c1_home = logistics.global_position
	_c1_job = site.job
	scope.set_meta(TICK_OWNER, weakref(self))
	_c1_job.job_cancelled.connect(_c1_on_cancelled)
	phase = &"c1_ready"
	return true

func c1_reserve() -> bool:
	if not _c1_owner() or phase != &"c1_ready" or not _core() or site.job != _c1_job or lease_id != 0:
		return false
	var scope := _scope()
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	var supplier := scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	lease_id = contracts.claim_logistics(site, logistics, scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue, scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry, buffer)
	if lease_id <= 0:
		return false
	pickup_id = supplier.reserve(logistics, site, INGOT, 5, 5)
	if pickup_id <= 0:
		contracts.revoke(lease_id)
		return false
	phase = &"c1_reserved"
	return true

func c1_launch() -> bool:
	if not _c1_owner() or phase != &"c1_reserved" or not _core() or site.job != _c1_job:
		return false
	var scope := _scope()
	var supplier := scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	if not supplier.begin_pickup(pickup_id, logistics, 2.0):
		return false
	phase = &"c1_outbound"
	return true

func cancel_c1(original_site: ConstructionSite, drone: PrototypeConstructionWorkerDrone, original_lease: int) -> bool:
	if not _c1_owner() or phase not in [&"c1_ready", &"c1_reserved", &"c1_outbound", &"c1_at_pickup"] or not _core():
		return false
	if original_site != site or site.job != _c1_job or drone != _scope().get_node("LogisticsDrone") or original_lease != lease_id or drone.cargo_amount() != 0:
		return false
	return _c1_job.cancel()

# The original supplier's cancellation signal releases its exact token.
# Signal ordering is irrelevant: the next explicit tick checks settlement.
func _c1_on_cancelled() -> void:
	if not _c1_owner() or _c1_job == null or _c1_job.state != ConstructionJob.State.CANCELLED or phase not in [&"c1_ready", &"c1_reserved", &"c1_outbound", &"c1_at_pickup"]:
		return
	if lease_id > 0:
		(_scope().get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f).revoke(lease_id)
	phase = &"c1_cancelled"

func step_c1(delta: float) -> bool:
	if not _c1_owner() or not is_finite(delta) or delta <= 0.0 or delta > 1.0:
		return false
	var scope := _scope()
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node("ConstructionDrone") as PrototypeConstructionWorkerDrone
	var supplier := scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	var coordinator := scope.get_node("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	if not _live(logistics) or not _live(builder) or not _live(supplier) or not _live(coordinator) or not _live(scheduler) or not _live(escrow) or not _live(queue) or not _live(_c1_returns) or not _live(_c1_charging):
		return false
	if builder.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE or builder.cargo_amount() != 0 or logistics.cargo_amount() != 0 or not _live(source) or source.get_amount(INGOT) != 15 or not _live(buffer) or buffer.get_total_amount() != 0 or escrow.held_count() != 0:
		return false
	if phase == &"c1_outbound":
		if not _core() or not supplier.advance_pickup(pickup_id, logistics, delta):
			return false
		if logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP:
			phase = &"c1_at_pickup" # No collection in this isolated gate.
	elif phase == &"c1_cancelled":
		if _c1_job.state != ConstructionJob.State.CANCELLED or supplier.reservation_count() != 0 or source.get_reserved_amount(INGOT) != 0 or _c1_returns.reservation_count() != 0:
			return false
		coordinator.reconcile()
		if not queue.get_waiting_sites().is_empty() or scheduler.get_active_count() != 0 or scheduler.has_drone_binding(logistics) or scheduler.has_drone_binding(builder):
			return false
		match logistics.get_flight_state():
			PrototypeConstructionWorkerDrone.FlightState.RETURNING:
				if not logistics.advance_flight(delta):
					return false
			PrototypeConstructionWorkerDrone.FlightState.DOCKED:
				if not logistics.global_position.is_equal_approx(_c1_home):
					return false
				if logistics.battery_units() + 0.00001 < logistics.battery_capacity():
					_c1_charging.advance_charging(delta)
				elif logistics.release_docked_cargo_assignment(supplier, _c1_returns, coordinator, escrow, scheduler):
					phase = &"c1_complete"
				else:
					return false
			PrototypeConstructionWorkerDrone.FlightState.IDLE:
				# No launch occurred; no flight assignment exists to rearm.
				if not logistics.global_position.is_equal_approx(_c1_home) or not logistics._finite_cargo_rearm_ready():
					return false
				phase = &"c1_complete"
			_:
				return false
	else:
		return false
	tick_count += 1
	return true

# C2 is an additional opt-in on the original C1/B2 tick owner.
@export var enable_c2_loaded_cancel: bool = false
var _c2_configured: bool = false
var _c2_docks: Array[WeakRef] = []
var _c2_drone: WeakRef
var _c2_lease: int = 0
var _c2_contracts: SpecializedDroneRoleContractsE3d5c6f
var _c2_supplier: PrototypeDroneSupplierReservations
var _c2_discovery: PrototypeDroneStorageDiscovery
var _c2_coordinator: BlueprintConstructionReadinessCoordinator
var _c2_scheduler: BlueprintConstructionSlotScheduler
var _c2_escrow: BlueprintConstructionMaterialEscrow

func configure_c2() -> bool:
	if not enable_c2_loaded_cancel or not _c1_owner() or phase != &"c1_ready" or _c2_configured or not _core():
		return false
	var scope := _scope()
	_c2_drone = weakref(scope.get_node("LogisticsDrone"))
	_c2_contracts = scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	_c2_supplier = scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations
	_c2_discovery = scope.get_node("StorageDiscovery") as PrototypeDroneStorageDiscovery
	_c2_coordinator = scope.get_node("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator
	_c2_scheduler = scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	_c2_escrow = scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	if not _live(_c1_returns) or not _live(_c1_charging) or not _live(_c2_discovery):
		return false
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	# Original dock already registered by B2. Resolve the actual registered
	# entry, not an arbitrary caller inventory or coordinate.
	for candidate: Dictionary in _c2_discovery._entries_for(drone, INGOT, 5):
		if candidate["storage"] == storage and candidate["inventory"] == source:
			_c2_docks.append(weakref(candidate["dock"]))
	if _c2_docks.size() != 1:
		return false
	source.enable_isolated_drone_return_claims = true
	drone.enable_isolated_cargo_recovery = true
	_c1_returns.enable_isolated_cargo_recovery = true
	_c2_configured = true
	_c1_job.job_cancelled.connect(_c2_on_cancelled)
	return true

func _c2_authorized() -> bool:
	if not enable_c2_loaded_cancel or not _c2_configured or not enable_b2_logistics or not _c1_owner() or _c2_drone == null:
		return false
	var scope := _scope()
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	var builder := scope.get_node_or_null("ConstructionDrone") as PrototypeConstructionWorkerDrone
	var b1 := scope.get_node_or_null("SingleTickController") as PlayableSpecializedDronesE3d5c6f
	if not _live(drone) or drone != scope.get_node_or_null("LogisticsDrone") or drone.get_parent() != scope or not _live(builder) or builder == drone:
		return false
	if not _live(b1) or b1.enable_b1_controller or b1.is_processing() or b1.is_physics_processing():
		return false
	if builder.get_flight_state() != PrototypeConstructionWorkerDrone.FlightState.IDLE or builder.cargo_amount() != 0 or builder.enable_isolated_drone or builder.enable_isolated_cargo_pickup:
		return false
	for service: Node in [_c2_contracts, _c2_supplier, _c2_discovery, _c2_coordinator, _c2_scheduler, _c2_escrow, _c1_returns, _c1_charging]:
		if not _live(service) or service.get_parent() != scope:
			return false
	if _c2_contracts != scope.get_node_or_null("RoleContracts") or _c2_supplier != scope.get_node_or_null("SupplierReservations") or _c2_discovery != scope.get_node_or_null("StorageDiscovery") or _c2_coordinator != scope.get_node_or_null("ReadinessCoordinator") or _c2_scheduler != scope.get_node_or_null("WorkerScheduler") or _c2_escrow != scope.get_node_or_null("MaterialEscrow"):
		return false
	if _c2_supplier._service() != _c2_discovery or _c1_returns._service() != _c2_discovery or not _c2_coordinator.matches_tick_services(_c2_scheduler, _c2_escrow):
		return false
	if not _live(source) or not _live(buffer) or buffer.get_total_amount() != 0 or _c2_escrow.held_count() != 0 or receipt_id != 0:
		return false
	if _c2_scheduler.get_active_count() != 0 or _c2_scheduler.has_drone_binding(drone) or _c2_scheduler.has_drone_binding(builder) or drone.grants_worker_readiness():
		return false
	var controllers: int = 0
	var returns: int = 0
	var chargers: int = 0
	for child: Node in scope.get_children():
		if not _live(child):
			continue
		if child is SpecializedDroneLogisticsE3d5c6fB2:
			controllers += 1
		if child is PrototypeDroneReturnReservations:
			returns += 1
		if child is PrototypeDroneHubCharging:
			chargers += 1
		if child is PrototypeDroneAutomaticDispatch or child is PrototypeConstructionDroneFleet or child is PrototypeConstructionDroneTickController:
			return false
	return controllers == 1 and returns == 1 and chargers == 1

# Alternate return docks are admitted by existing discovery validation.
# Never enable their pickup permissions or touch their physical stock.
func c2_register_return_dock(dock: PrototypeDroneStorageDock) -> bool:
	if not _c2_authorized() or phase not in [&"c1_ready", &"c2_loaded", &"c2_delivery", &"c2_at_delivery", &"c2_cancelled"] or not _live(dock):
		return false
	if dock.allow_pickup:
		return false # C2 alternate is a return-only dock.
	for ref: WeakRef in _c2_docks:
		if ref.get_ref() == dock:
			return false
	if not _c2_discovery.register_dock(dock):
		return false
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	for candidate: Dictionary in _c2_discovery._entries_for(drone, INGOT, 5):
		if candidate["dock"] == dock:
			var inventory: InventoryComponent = candidate["inventory"]
			inventory.enable_isolated_drone_return_claims = true
			_c2_docks.append(weakref(dock))
			return true
	return false

func c2_collect() -> bool:
	if not _c2_authorized() or phase != &"c1_at_pickup" or not _core() or site.job != _c1_job or lease_id <= 0:
		return false
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	if source.get_amount(INGOT) != 15 or drone.cargo_amount() != 0 or not _c2_contracts.c2_logistics_lease_matches(lease_id, _c1_job, drone, false):
		return false
	if not _c2_supplier.collect_pickup(pickup_id, drone):
		return false
	_c2_lease = lease_id
	phase = &"c2_loaded"
	return source.get_amount(INGOT) == 10 and drone.cargo_amount() == 5 and drone.cargo_item() == INGOT and _c2_supplier.reservation_count() == 0

func c2_begin_delivery() -> bool:
	if not _c2_authorized() or phase != &"c2_loaded" or not _core() or site.job != _c1_job:
		return false
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	if not _c2_contracts.c2_logistics_lease_matches(_c2_lease, _c1_job, drone, false) or not drone.begin_delivery(site, _scope().get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry, _c2_escrow):
		return false
	phase = &"c2_delivery"
	return true

func cancel_c2(original_site: ConstructionSite, drone: PrototypeConstructionWorkerDrone, original_lease: int) -> bool:
	if not _c2_authorized() or phase not in [&"c2_loaded", &"c2_delivery", &"c2_at_delivery"] or not _core():
		return false
	if original_site != site or site.job != _c1_job or drone != _c2_drone.get_ref() or original_lease != _c2_lease or drone.cargo_amount() != 5 or drone.cargo_item() != INGOT:
		return false
	if not _c2_contracts.c2_logistics_lease_matches(_c2_lease, _c1_job, drone, false):
		return false
	return _c1_job.cancel()

func _c2_on_cancelled() -> void:
	if not _c2_authorized() or _c1_job == null or _c1_job.state != ConstructionJob.State.CANCELLED or phase not in [&"c2_loaded", &"c2_delivery", &"c2_at_delivery"]:
		return
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	if drone.cargo_amount() != 5 or drone.cargo_item() != INGOT or not _c2_contracts.c2_logistics_lease_matches(_c2_lease, _c1_job, drone, false):
		return
	if _c2_contracts.revoke(_c2_lease):
		phase = &"c2_cancelled"

# Return status is explicit: a valid blocked recovery is not an authority
# failure. Exactly one physical service advance per bounded owner tick.
func step_c2(delta: float) -> StringName:
	if not _c2_authorized() or not is_finite(delta) or delta <= 0.0 or delta > 1.0:
		return &"rejected"
	var drone := _c2_drone.get_ref() as PrototypeConstructionWorkerDrone
	if phase == &"c2_delivery":
		if not _core() or not _c2_contracts.c2_logistics_lease_matches(_c2_lease, _c1_job, drone, false) or not drone.advance_delivery(delta):
			return &"rejected"
		if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_DELIVERY:
			phase = &"c2_at_delivery" # Never unload in C2.
		tick_count += 1
		return &"delivery"
	if phase != &"c2_cancelled" or _c1_job.state != ConstructionJob.State.CANCELLED or not _c2_contracts.c2_logistics_lease_matches(_c2_lease, _c1_job, drone, true):
		return &"rejected"
	if _c2_supplier.reservation_count() != 0 or source.get_reserved_amount(INGOT) != 0:
		return &"rejected"
	_c2_coordinator.reconcile()
	if not (_scope().get_node("PriorityQueue") as BlueprintConstructionPriorityQueue).get_waiting_sites().is_empty():
		return &"rejected"
	var state: int = drone.get_flight_state()
	if state == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
		if drone.cargo_amount() != 0 or _c1_returns.reservation_count() != 0 or not drone.global_position.is_equal_approx(_c1_home):
			return &"rejected"
		tick_count += 1
		if drone.battery_units() + 0.00001 < drone.battery_capacity():
			return &"charging" if _c1_charging.advance_charging(delta) > 0.0 else &"charging_wait"
		if not drone.release_docked_cargo_assignment(_c2_supplier, _c1_returns, _c2_coordinator, _c2_escrow, _c2_scheduler):
			return &"rejected"
		phase = &"c2_complete"
		return &"complete"
	if state == PrototypeConstructionWorkerDrone.FlightState.RECOVERY_HOME:
		if drone.cargo_amount() != 0 or _c1_returns.reservation_count() != 0:
			return &"rejected"
	elif drone.cargo_amount() != 5 or drone.cargo_item() != INGOT:
		return &"rejected"
	# The discovery service may only select originally admitted C2 docks.
	for candidate: Dictionary in _c2_discovery._entries_for(drone, INGOT, 5):
		var admitted: bool = false
		for ref: WeakRef in _c2_docks:
			if ref.get_ref() == candidate["dock"]:
				admitted = true
				break
		if not admitted:
			return &"rejected"
	tick_count += 1
	var advanced: bool = _c1_returns.advance_cancelled_recovery(drone, delta)
	if not advanced:
		return &"recovery_wait"
	return &"recovery"
