extends Node3D
const SCOPE := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const STORAGE := preload("res://data/buildings/test_storage.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState

func _ready() -> void:
	call_deferred("_checks")

func _fixture(automated: bool = true) -> Dictionary:
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
	b2.enable_c5p_automated_lifecycle = automated

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
	var anchor := Node3D.new()
	scope.add_child(anchor)
	anchor.global_position = site.global_position + Vector3.UP * 2.0
	anchor.add_child(port)
	port.enable_isolated_input = true
	port.show_port_label = false
	assert(port.bind_staging(staging))
	assert(site.job.authorize() and queue.register_queued_site(site))
	assert(registry.claim_site(site, staging, port))
	assert(b2.configure_b2(site, storage, staging, port, dock))
	assert(not builder.enable_isolated_drone and not builder.enable_isolated_cargo_pickup)
	assert(b2.phase == &"ready" and stock.get_amount(INGOT) == 15)

	return {"scope": scope, "b2": b2, "site": site, "job": site.job, "stock": stock, "drone": logistics, "builder": builder, "supplier": scope.get_node("SupplierReservations"), "hub": scope.get_node("MainHub"), "home": logistics.global_position, "buffer": staging.get_staged_inventory(), "escrow": escrow, "scheduler": scheduler, "dock": dock, "storage": storage, "contracts": contracts, "staging": staging, "port": port}


func _enable(x: Dictionary) -> void:
	x.b2.enable_c1_pre_pickup_cancel = true
	assert(x.b2.configure_c1())
	x.b2.enable_c2_loaded_cancel = true
	assert(x.b2.configure_c2())
	x.b2.enable_c3_staging_recovery = true
	assert(x.b2.configure_c3(x.staging, x.port))

func _load(x: Dictionary) -> void:
	assert(x.b2.c1_reserve() and x.b2.c1_launch())
	for i: int in range(10):
		if x.b2.phase == &"c1_at_pickup":
			break
		assert(x.b2.step_c1(1.0))
	assert(x.drone.get_flight_state() == Flight.AT_PICKUP)
	assert(x.stock.get_amount(INGOT) == 15)
	assert(x.b2.c2_collect())
	assert(x.stock.get_amount(INGOT) == 10 and x.drone.cargo_amount() == 5 and x.drone.cargo_item() == INGOT)
	assert(x.supplier.reservation_count() == 0 and x.stock.get_reserved_amount(INGOT) == 0)


func _deliver(x: Dictionary) -> void:
	_load(x)
	assert(x.b2.c2_begin_delivery())
	for i: int in range(10):
		if x.b2.phase == &"c2_at_delivery":
			break
		assert(x.b2.step_c2(1.0) == &"delivery")
	assert(x.b2.c3_unload())
	assert(x.stock.get_amount(INGOT) == 10 and x.buffer.get_amount(INGOT) == 5)
	assert(x.drone.cargo_amount() == 0 and x.escrow.held_count() == 0)


const POLE := preload("res://scenes/buildings/prototype_power_pole.tscn")

func _park(x: Dictionary) -> void:
	for i: int in range(100):
		if x.b3.phase == &"c4_parked":
			break
		assert(x.b3.step_c4a(1.0) == &"parking")
	assert(x.b3.phase == &"c4_parked" and x.builder.get_flight_state() == Flight.DOCKED)
	assert(x.builder.global_position.is_equal_approx(x.builder_home))

func _resume(x: Dictionary) -> void:
	for i: int in range(100):
		if x.b3.phase == &"c4_flight":
			break
		var action: StringName = x.b3.step_c4a(1.0)
		assert(action in [&"energy_wait", &"charging", &"resumed_flight"])
	assert(x.b3.phase == &"c4_flight")

func _arrive(x: Dictionary) -> void:
	for i: int in range(30):
		if x.b3.phase == &"c4_work":
			break
		assert(x.b3.step_c4a(1.0) in [&"flight", &"admitted"])
	assert(x.b3.phase == &"c4_work" and x.builder.is_at_site())
	assert(x.scheduler.get_active_count() == 1 and x.job.state == ConstructionJob.State.CONSTRUCTING)


func _admit(x: Dictionary, terminal_enabled: bool = true) -> void:
	x.b3 = x.scope.get_node("B3BuilderController")
	x.builder_home = x.builder.global_position
	_enable(x)
	_deliver(x)
	assert(x.b2.c3_reserve_escrow() and x.b2.c3_begin_empty_return())
	for i: int in range(120):
		if x.b2.phase == &"c3_docked":
			break
		assert(x.b2.step_c3(0.1) == &"empty_return")
	assert(x.b2.phase == &"c3_docked")
	var pole := POLE.instantiate() as PrototypePowerStructure
	x.scope.add_child(pole)
	pole.position = Vector3(8, 0, 0)
	x.b3.enable_b3_builder = true
	x.b3.enable_c4a_blackout = true
	x.b3.enable_c4b_terminal_cancel = terminal_enabled
	assert(x.b3.configure_c4a(pole) and x.b3.start_c4a())
	x.ticket = x.b2._c3_ticket
	assert(x.ticket > 0)

func _cancel(x: Dictionary) -> void:
	x.progress = x.job.get_progress()
	assert(x.b3.cancel_c4b(x.site, x.builder, x.b3.receipt_id))
	assert(x.job.state == ConstructionJob.State.CANCELLED and x.job.get_progress() == x.progress)
	assert(x.b3.phase == &"c4b_terminal" and x.b2.phase == &"c4_builder_owned")
	assert(x.builder.cargo_amount() == 0 and not is_instance_valid(x.b3.completed_building))

func _handback(x: Dictionary) -> void:
	for i: int in range(100):
		if x.b3.phase == &"c4b_retired":
			break
		assert(x.b3.step_c4b(0.5) in [&"terminal_return", &"handed_back"])
	assert(x.b3.phase == &"c4b_retired" and x.b2.phase == &"c3_cancelled")
	assert(x.builder.c4b_is_retired() and x.builder.global_position.is_equal_approx(x.builder_home))
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b2)

func _ready_recovery(x: Dictionary) -> void:
	for i: int in range(400):
		if x.drone.get_flight_state() == Flight.IDLE:
			break
		assert(x.b2.step_c3(0.1) in [&"charged", &"ready_recovery"])
	assert(x.drone.get_flight_state() == Flight.IDLE)

func _finish(x: Dictionary) -> void:
	for i: int in range(600):
		if x.b2.phase == &"c3_complete":
			break
		var action: StringName = x.b2.step_c3(0.1)
		assert(action not in [&"rejected", &"blocked", &"source_quarantined", &"destination_wait", &"energy_wait", &"escrow_wait", &"dock_wait"])
	assert(x.b2.phase == &"c3_complete" and x.b2._c3_transport.recovered_amount(x.ticket) == 5)
	assert(x.stock.get_amount(INGOT) == 15 and x.buffer.get_total_amount() == 0 and x.escrow.held_count() == 0)
	assert(x.job.get_progress() == x.progress and x.builder.c4b_is_retired())

func _checks() -> void:
	var x := _fixture()
	_enable(x)
	assert(x.drone.c5p_automated_mode() and x.b2._c1_charging.c5p_dock_only())
	assert(x.drone.battery_units() == -1.0 and x.drone.battery_capacity() == 0.0)
	assert(not x.drone.enable_isolated_battery and not x.drone.enable_isolated_finite_charging)
	assert(not x.drone.charge_at_home(1.0, true) and x.b2._c1_charging.advance_charging(1.0) == 0.0)
	assert(not x.drone.configure_battery(40.0, 40.0, 1.0, 4.0))
	assert(not x.b2._c1_charging.register_drone(x.drone))
	x.b2.enable_c5p_automated_lifecycle = false
	assert(x.b2.c5p_automated_mode() and x.drone.c5p_automated_mode())
	assert(not x.drone.configure_c5p_automated(x.b2))
	var foreign := PrototypeConstructionWorkerDrone.new()
	x.scope.add_child(foreign)
	foreign.enable_isolated_drone = true
	assert(not foreign.configure_c5p_automated(x.b2))
	assert(not x.b2._c1_charging.register_drone(foreign))
	foreign.free()
	print("PASS A: immutable battery-independent mode and unique dock")
	var points: Array[Vector3] = [Vector3(100, 2, 0)]
	assert(x.drone.route_feasible(points) and x.drone.route_score(points) > 40.0)
	assert(x.drone.estimate_route_energy(points) < 0.0)
	points = [Vector3(INF, 0, 0)]
	assert(not x.drone.route_feasible(points))
	assert(not x.drone.advance_flight(NAN))
	var token := x.drone._charging_token as RefCounted
	assert(x.b2._c1_charging.matches_docked_registration(x.drone, token))
	assert(not x.b2._c1_charging.matches_docked_registration(x.drone, RefCounted.new()))
	x.drone.global_position += Vector3(1, 0, 0)
	assert(not x.b2._c1_charging.matches_docked_registration(x.drone, token))
	x.drone.global_position = x.home
	x.drone.enable_isolated_battery = true
	points = [Vector3(100, 2, 0)]
	assert(not x.drone.route_feasible(points))
	x.drone.enable_isolated_battery = false
	print("PASS B: finite physical routes without synthetic energy")
	_load(x)
	assert(x.drone.battery_units() == -1.0)
	assert(x.b2.cancel_c2(x.site, x.drone, x.b2.lease_id))
	assert(x.hub.set_generator_enabled(false))
	x.stock.max_capacity = 10
	assert(x.b2.step_c2(1.0) == &"recovery_wait")
	assert(x.stock.get_amount(INGOT) == 10 and x.drone.cargo_amount() == 5)
	x.stock.max_capacity = 20
	for i: int in range(100):
		if x.b2.phase == &"c2_complete":
			break
		assert(x.b2.step_c2(1.0) not in [&"rejected", &"charging", &"charging_wait"])
	assert(x.b2.phase == &"c2_complete" and x.stock.get_amount(INGOT) == 15 and x.drone.cargo_amount() == 0)
	print("PASS C: loaded cancellation returns actual cargo without recharge")
	x.scope.free()

	x = _fixture()
	_admit(x)
	assert(x.builder.c5p_automated_mode() and x.builder.battery_units() == -1.0)
	assert(x.drone.battery_units() == -1.0 and x.b2._c1_charging._entries.size() == 2)
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b3)
	assert(x.b2.step_c3(0.1) == &"rejected")
	print("PASS D: physical delivery and exclusive builder handoff")
	_arrive(x)
	assert(x.b3.step_c4a(1.0) == &"work")
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	_park(x)
	assert(x.b3.step_c4a(1.0) == &"blackout_wait")
	assert(x.hub.set_generator_enabled(true))
	assert(x.b3.step_c4a(1.0) == &"resumed_flight")
	_arrive(x)
	print("PASS E: existing site power parking resumes without charging")
	_cancel(x)
	_handback(x)
	_finish(x)
	assert(x.drone.battery_units() == -1.0 and x.builder.battery_units() == -1.0)
	print("PASS F: retirement, handback and physical staging recovery conserve all materials")
	x.scope.free()
	x = _fixture()
	_enable(x)
	assert(x.b2.c1_reserve() and x.b2.c1_launch())
	assert(x.b2.step_c1(0.1))
	assert(x.b2.cancel_c1(x.site, x.drone, x.b2.lease_id))
	for i: int in range(100):
		if x.b2.phase == &"c1_complete":
			break
		assert(x.b2.step_c1(0.1))
	assert(x.b2.phase == &"c1_complete" and x.stock.get_amount(INGOT) == 15 and x.supplier.reservation_count() == 0)
	print("PASS G: pre-pickup cancellation returns empty and releases only unused stock claim")
	x.scope.free()

	x = _fixture()
	_admit(x)
	_arrive(x)
	for i: int in range(30):
		if x.b3.phase == &"c4_complete_return":
			break
		assert(x.b3.step_c4a(1.0) in [&"work", &"built"])
	assert(x.job.state == ConstructionJob.State.COMPLETE and x.escrow.held_count() == 0 and x.stock.get_amount(INGOT) == 10)
	assert(is_instance_valid(x.b3.completed_building))
	for i: int in range(30):
		if x.b3.phase == &"c4_complete":
			break
		assert(x.b3.step_c4a(1.0) in [&"complete_return", &"complete"])
	assert(x.b3.phase == &"c4_complete" and x.builder.global_position.is_equal_approx(x.builder_home))
	assert(x.b3.step_c4a(1.0) == &"rejected" and x.b2.step_c3(0.1) == &"rejected")
	assert(x.builder.battery_units() == -1.0 and x.buffer.get_total_amount() == 0)
	print("PASS H: normal construction consumes escrow once and returns; no replay")
	x.scope.free()

	x = _fixture(false)
	_enable(x)
	assert(not x.b2.c5p_automated_mode() and not x.drone.c5p_automated_mode())
	assert(x.drone.battery_units() == 40.0 and x.drone.battery_capacity() == 40.0)
	assert(not x.b2._c1_charging.c5p_dock_only())
	var long_route: Array[Vector3] = [Vector3(100, 2, 0)]
	assert(not x.drone.route_feasible(long_route))
	x.scope.free()
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B3BuilderController") == null)
	main.free()
	print("PASS I: legacy default still finite and Main remains opted out")

	x = _fixture()
	_enable(x)
	assert(x.b2.c1_reserve() and x.b2.c1_launch())
	var before: Vector3 = x.drone.global_position
	x.scope.set_meta("e3d5c6f_single_tick_owner", weakref(x.scope.get_node("B3BuilderController")))
	assert(not x.b2.step_c1(0.1))
	points = [Vector3(10, 2, 0)]
	assert(not x.drone.route_feasible(points))
	assert(x.drone.global_position == before and x.stock.get_amount(INGOT) == 15)
	x.scope.set_meta("e3d5c6f_single_tick_owner", weakref(x.b2))
	assert(x.b2.step_c1(0.1))
	x.b2._c1_charging.free()
	before = x.drone.global_position
	assert(not x.b2.step_c1(0.1) and not x.drone.route_feasible(points))
	assert(x.drone.global_position == before and x.stock.get_amount(INGOT) == 15)
	print("PASS J: wrong tick owner and lost dock authority fail closed")
	x.scope.free()
	print("E3d5c6f C5P-B1: 10/10 printed sections passed")
