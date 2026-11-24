extends Node3D
## B2 F6: original 15-ingot Storage -> five physical cargo -> original
## site staging + escrow -> distinct idle builder and metered return home.
const SCOPE := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const STORAGE := preload("res://data/buildings/test_storage.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")

func _ready() -> void:
	call_deferred("_checks")

func _checks() -> void:
	var scope := SCOPE.instantiate() as Node3D
	add_child(scope)
	var b1 := scope.get_node("SingleTickController") as PlayableSpecializedDronesE3d5c6f
	var b2 := scope.get_node("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node("ConstructionDrone") as PrototypeConstructionWorkerDrone
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(PRESS))
	scope.add_child(site)
	site.position = Vector3(10, 0, 0)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	b1.enable_b1_controller = false
	b2.enable_b2_logistics = true
	assert(not b2.start_b2() and not b2.step_b2(1.0))
	assert(not queue.register_queued_site(site) and contracts.lease_count() == 0)
	print("PASS A: no launch or escrow before original job authorization")

	var storage := STORAGE.building_scene.instantiate() as Node3D
	scope.add_child(storage)
	storage.position = Vector3(5, 0, 0)
	storage.add_to_group("player_built")
	storage.add_to_group("logistics_storage")
	(storage.get_node("BuildingRuntime") as BuildingRuntime).initialize(STORAGE)
	var stock := storage.get_node("InventoryComponent") as InventoryComponent
	stock.enable_isolated_drone_claims = true
	stock.max_capacity = 20
	assert(stock.add_item(INGOT, 15) == 15)
	var dock := PrototypeDroneStorageDock.new()
	storage.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	registry.enable_isolated_site_registry = true
	var staging := BlueprintConstructionMaterialStaging.new()
	scope.add_child(staging)
	staging.enable_isolated_staging = true
	assert(staging.configure(stock, PRESS, 5))
	var port := BlueprintConstructionStagingInputPort.new()
	scope.add_child(port)
	port.enable_isolated_input = true
	port.show_port_label = false
	assert(port.bind_staging(staging))
	assert(site.job.authorize() and queue.register_queued_site(site))
	assert(registry.claim_site(site, staging, port))
	assert(b2.configure_b2(site, storage, staging, port, dock))
	assert(not builder.enable_isolated_drone and not builder.enable_isolated_cargo_pickup)
	assert(b2.phase == &"ready" and stock.get_amount(INGOT) == 15)
	print("PASS B: exact queued Press, original Storage 15 and pinned site receiver")

	var home := logistics.global_position
	var start_energy: float = logistics.battery_units()
	assert(b2.start_b2())
	assert(b2.phase == &"pickup" and b2.lease_id > 0 and b2.pickup_id > 0)
	assert(not b2.start_b2())
	assert(stock.get_amount(INGOT) == 15 and stock.get_reserved_amount(INGOT) == 5)
	assert(logistics.cargo_amount() == 0 and escrow.held_count() == 0)
	print("PASS C: one authenticated supplier reservation; no remote stock debit")

	assert(b2.step_b2(1.0))
	assert(logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.PICKUP_OUTBOUND)
	assert(logistics.global_position.distance_to(home) > 0.0 and logistics.battery_units() < start_energy)
	assert(stock.get_amount(INGOT) == 15 and logistics.cargo_amount() == 0)
	assert(b2.step_b2(3.0))
	assert(b2.phase == &"delivery")
	assert(logistics.cargo_amount() == 5 and logistics.cargo_item() == INGOT)
	assert(stock.get_amount(INGOT) == 10 and stock.get_reserved_amount(INGOT) == 0)
	assert((scope.get_node("SupplierReservations") as PrototypeDroneSupplierReservations).reservation_count() == 0)
	print("PASS D: metered arrival physically debits exactly five from Storage to cargo")

	assert(not logistics.unload_delivery())
	assert(escrow.held_count() == 0 and staging.get_staged_inventory().get_amount(INGOT) == 0)
	assert(b2.step_b2(1.0))
	assert(b2.phase == &"delivery" and logistics.cargo_amount() == 5)
	assert(b2.step_b2(3.0))
	assert(b2.phase == &"return")
	assert(logistics.cargo_amount() == 0 and staging.get_staged_inventory().get_total_amount() == 0)
	assert(logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	print("PASS E: full-bill physical arrival, exact-once unload and protected escrow")

	var escrow_id: int = escrow.reservation_for(site)
	assert(escrow_id > 0 and escrow.held_materials(escrow_id) == {INGOT: 5})
	assert(b2.receipt_id == b2.lease_id and contracts.receipt_valid(b2.receipt_id))
	assert(contracts.lease_count() == 1 and not contracts.claim_builder(b2.receipt_id, logistics))
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	assert(scheduler.get_active_count() == 0 and not logistics.grants_worker_readiness())
	print("PASS F: original five-ingot escrow and immutable handoff; no worker readiness")

	assert(not b2.step_b2(-1.0) and not b2.step_b2(20.0))
	var energy_delivery: float = logistics.battery_units()
	assert(b2.step_b2(1.0))
	assert(logistics.battery_units() < energy_delivery)
	assert(logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(b2.step_b2(10.0))
	assert(b2.phase == &"delivered" and b2.b2_completed())
	assert(logistics.global_position == home)
	assert(logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	print("PASS G: empty logistics drone returns physically with finite battery")

	assert(not b2.step_b2(1.0) and not b2.start_b2())
	assert(not logistics.unload_delivery())
	assert(escrow.held_materials(escrow_id) == {INGOT: 5} and stock.get_amount(INGOT) == 10)
	assert(builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(builder.global_position == Vector3(0.65, 2, 0))
	assert(not builder.grants_worker_readiness() and site.job.get_progress() == 0.0)
	print("PASS H: no replay, no duplicate goods, builder never moved or worked")

	assert(stock.get_amount(INGOT) + logistics.cargo_amount() + staging.get_staged_inventory().get_amount(INGOT) + int(escrow.held_materials(escrow_id).get(INGOT, 0)) == 15)
	assert(escrow.held_count() == 1 and scheduler.get_active_count() == 0)
	assert(not (scope.get_node("SingleTickController") as PlayableSpecializedDronesE3d5c6f).step_b1(0.1))
	print("PASS I: all 15 ingots conserved under a single specialized tick owner")
	scope.queue_free()
	print("E3d5c6f B2 physical logistics F6: 9/9 labeled sections passed")
