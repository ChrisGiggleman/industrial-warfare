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
