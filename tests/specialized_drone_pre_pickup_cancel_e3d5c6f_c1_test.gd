extends Node3D
const SCOPE := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const STORAGE := preload("res://data/buildings/test_storage.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState

func _ready() -> void:
	call_deferred("_checks")

func _fixture() -> Dictionary:
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

	return {"scope": scope, "b2": b2, "site": site, "job": site.job, "stock": stock, "drone": logistics, "builder": builder, "supplier": scope.get_node("SupplierReservations"), "hub": scope.get_node("MainHub"), "home": logistics.global_position, "buffer": staging.get_staged_inventory(), "escrow": escrow, "scheduler": scheduler}

func _enable(x: Dictionary) -> void:
	x.b2.enable_c1_pre_pickup_cancel = true
	assert(x.b2.configure_c1())

func _cancel(x: Dictionary) -> void:
	assert(x.b2.cancel_c1(x.site, x.drone, x.b2.lease_id))
	assert(x.job.state == ConstructionJob.State.CANCELLED)
	assert(x.supplier.reservation_count() == 0 and x.stock.get_reserved_amount(INGOT) == 0)
	assert(x.stock.get_amount(INGOT) == 15 and x.drone.cargo_amount() == 0)
	assert(x.buffer.get_total_amount() == 0 and x.escrow.held_count() == 0)
	assert(not x.b2.step_b2(0.1) and not x.b2.start_b2())

func _finish(x: Dictionary) -> void:
	for i: int in range(100):
		if x.b2.phase == &"c1_complete":
			break
		assert(x.b2.step_c1(1.0))
	assert(x.b2.phase == &"c1_complete")
	assert(x.drone.get_flight_state() == Flight.IDLE and x.drone.global_position.is_equal_approx(x.home))
	assert(is_equal_approx(x.drone.battery_units(), x.drone.battery_capacity()))
	assert(x.stock.get_amount(INGOT) == 15 and x.supplier.reservation_count() == 0)
	assert(x.scheduler.get_active_count() == 0 and not x.drone.grants_worker_readiness())
	assert(x.builder.get_flight_state() == Flight.IDLE)

func _checks() -> void:
	var x := _fixture()
	assert(not x.b2.configure_c1() and not x.b2.step_c1(0.1))
	assert(not x.b2.cancel_c1(x.site, x.drone, 0))
	var foreign := SpecializedDroneLogisticsE3d5c6fB2.new()
	add_child(foreign)
	foreign.enable_c1_pre_pickup_cancel = true
	assert(not foreign.configure_c1() and not foreign.step_c1(0.1))
	foreign.free()
	print("PASS A: default off and foreign scope refused")
	_enable(x)
	_cancel(x)
	_finish(x)
	print("PASS B: cancel before dispatch leaves original stock and idle drone")
	x.scope.free()

	x = _fixture()
	_enable(x)
	assert(x.b2.c1_reserve())
	assert(x.stock.get_reserved_amount(INGOT) == 5 and x.drone.get_flight_state() == Flight.IDLE)
	_cancel(x)
	_finish(x)
	print("PASS C: cancel reserved but unlaunched exact stock claim")
	x.scope.free()

	x = _fixture()
	_enable(x)
	assert(x.b2.c1_reserve() and x.b2.c1_launch())
	assert(x.b2.step_c1(1.0) and x.drone.get_flight_state() == Flight.PICKUP_OUTBOUND)
	var away: Vector3 = x.drone.global_position
	var energy: float = x.drone.battery_units()
	_cancel(x)
	assert(x.drone.get_flight_state() == Flight.RETURNING and x.drone.global_position == away)
	print("PASS D: outbound cancellation changes state without teleport")
	assert(x.supplier.observe(x.b2.pickup_id).is_empty())
	assert(not x.supplier.collect_pickup(x.b2.pickup_id, x.drone))
	assert(x.stock.get_reserved_amount(INGOT) == 0)
	print("PASS F: exact supplier token removed; stale collect refused")
	assert(x.stock.get_amount(INGOT) == 15 and x.buffer.get_total_amount() == 0 and x.escrow.held_count() == 0)
	print("PASS G: all fifteen ingots conserved in original Storage")
	assert(x.b2.step_c1(1.0))
	assert(x.drone.get_flight_state() == Flight.DOCKED and x.drone.global_position.is_equal_approx(x.home))
	assert(x.drone.battery_units() < energy)
	print("PASS H: metered empty return reaches original berth")
	assert(not x.b2.cancel_c1(x.site, x.drone, x.b2.lease_id))
	assert(not x.b2.c1_reserve() and not x.b2.c1_launch())
	print("PASS I: duplicate cancellation and replay rejected")
	assert(x.hub.set_generator_enabled(false))
	var depleted: float = x.drone.battery_units()
	assert(x.b2.step_c1(1.0))
	assert(x.drone.battery_units() == depleted and x.b2.phase == &"c1_cancelled")
	assert(not x.drone.charge_at_home(1.0, true))
	print("PASS K: blackout blocks real charging and caller-bool shortcut")
	assert(x.hub.set_generator_enabled(true))
	_finish(x)
	print("PASS L: finite recharge and exact terminal assignment cleanup before idle")
	x.scope.free()

	x = _fixture()
	_enable(x)
	assert(x.b2.c1_reserve() and x.b2.c1_launch())
	assert(not x.b2.cancel_c1(null, x.drone, x.b2.lease_id))
	assert(not x.b2.cancel_c1(x.site, x.builder, x.b2.lease_id))
	assert(not x.b2.cancel_c1(x.site, x.drone, x.b2.lease_id + 1))
	assert(x.job.state == ConstructionJob.State.QUEUED and x.stock.get_reserved_amount(INGOT) == 5)
	print("PASS J: wrong site, role and lease refused")
	for i: int in range(10):
		if x.b2.phase == &"c1_at_pickup":
			break
		assert(x.b2.step_c1(1.0))
	assert(x.drone.get_flight_state() == Flight.AT_PICKUP and x.stock.get_amount(INGOT) == 15)
	_cancel(x)
	assert(not x.supplier.collect_pickup(x.b2.pickup_id, x.drone))
	_finish(x)
	print("PASS E: exact arrival before collection cancels without stock debit")
	x.scope.queue_free()
	print("E3d5c6f C1 isolated F6: 12/12 labeled sections passed")
