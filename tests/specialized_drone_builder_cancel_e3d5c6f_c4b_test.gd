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
	_admit(x, false)
	assert(not x.b3.cancel_c4b(x.site, x.builder, x.b3.receipt_id))
	assert(x.b3.step_c4b(0.1) == &"rejected")
	x.b3.enable_c4b_terminal_cancel = true
	assert(not x.b3.cancel_c4b(x.site, x.drone, x.b3.receipt_id))
	assert(not x.b3.cancel_c4b(x.site, x.builder, x.b3.receipt_id + 1))
	var foreign := SpecializedDroneBuilderE3d5c6fB3.new()
	add_child(foreign)
	foreign.enable_c4b_terminal_cancel = true
	assert(not foreign.cancel_c4b(x.site, x.builder, x.b3.receipt_id))
	foreign.free()
	print("PASS A: default off, foreign owner, role and receipt rejected")
	assert(x.b3.step_c4a(1.0) == &"flight")
	_cancel(x)
	_handback(x)
	_finish(x)
	print("PASS B: initial outbound cancellation and physical recovery")
	x.scope.free()

	x = _fixture()
	_admit(x)
	_arrive(x)
	assert(x.b3.step_c4a(1.0) == &"work")
	assert(x.job.get_progress() > 0.0)
	_cancel(x)
	_handback(x)
	_finish(x)
	print("PASS C: active partial construction cancellation freezes progress")
	x.scope.free()

	x = _fixture()
	_admit(x)
	_arrive(x)
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	assert(x.b3.step_c4a(0.5) == &"parking")
	_cancel(x)
	_handback(x)
	assert(x.b2.step_c3(0.1) == &"dock_wait")
	assert(x.hub.set_generator_enabled(true))
	_finish(x)
	print("PASS D: cancellation during blackout parking safely returns")
	x.scope.free()

	x = _fixture()
	_admit(x)
	_arrive(x)
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	_park(x)
	var energy: float = x.builder.battery_units()
	_cancel(x)
	_handback(x)
	assert(x.builder.battery_units() == energy and x.b2.step_c3(0.1) == &"dock_wait")
	assert(x.hub.set_generator_enabled(true))
	_finish(x)
	print("PASS E: docked blackout cancellation requires no builder recharge")
	x.scope.free()

	x = _fixture()
	_admit(x)
	_arrive(x)
	assert(x.b3.step_c4a(1.0) == &"work")
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	_park(x)
	assert(x.hub.set_generator_enabled(true))
	_resume(x)
	assert(x.b3.step_c4a(1.0) == &"flight")
	_cancel(x)
	_handback(x)
	_finish(x)
	print("PASS F: resumed outbound cancellation preserves original progress")
	x.scope.free()

	x = _fixture()
	_admit(x)
	_arrive(x)
	assert(x.b3.step_c4a(1.0) == &"work")
	x.buffer.max_capacity = 4
	energy = x.builder.battery_units()
	_cancel(x)
	assert(not x.contracts.receipt_valid(x.b3.receipt_id) and not x.contracts.builder_claim_valid(x.b3.receipt_id, x.builder))
	assert(x.contracts.c4b_terminal_matches(x.b3.receipt_id, x.job, x.builder, x.drone, x.escrow, x.b3.escrow_id))
	assert(x.scheduler.get_active_count() == 0 and not x.scheduler.has_drone_binding(x.builder))
	var allocator := x.scope.get_node("PowerAllocator") as PrototypeConstructionPowerAllocator
	assert(not allocator.get_allocations().has(x.site))
	print("PASS G: exact revoked receipt and terminal scheduler/power cleanup")
	assert(x.escrow.held_count() == 1 and x.buffer.get_total_amount() == 0 and x.stock.get_amount(INGOT) == 10)
	_handback(x)
	for i: int in range(400):
		if x.b2.step_c3(0.1) == &"escrow_wait":
			break
	assert(x.b2.step_c3(0.1) == &"escrow_wait" and x.escrow.held_count() == 1)
	x.buffer.max_capacity = 5
	assert(x.b2.step_c3(0.1) == &"escrow_settled")
	assert(x.buffer.get_amount(INGOT) == 5 and x.escrow.held_count() == 0 and x.stock.get_amount(INGOT) == 10)
	print("PASS H: blocked escrow remains protected and settles to original staging")
	assert(x.builder.battery_units() < energy and x.builder.c4b_is_retired())
	assert(not x.builder.charge_at_home(1.0, true))
	print("PASS I: metered empty return and inert right berth retirement")
	assert(x.b3.step_c4b(0.1) == &"rejected" and x.b3.step_c4a(0.1) == &"rejected")
	assert(not x.b2.c4b_accept_handback(x.b3) and not x.b3.start_c4a())
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b2)
	print("PASS J: one exact hand-back and stale builder ticks rejected")
	assert(x.b2._c3_ticket == x.ticket and x.b2._c3_audit.ticket_count() == 1)
	assert(x.b2._c3_audit.observe(x.ticket).status == &"ready_read_only")
	assert(not x.drone.grants_worker_readiness() and not x.scheduler.has_drone_binding(x.drone))
	assert(not x.contracts.c3_logistics_lease_matches(x.b3.receipt_id, x.job, x.drone, true))
	print("PASS K: original ticket and builder-bearing tombstone preserved")
	_ready_recovery(x)
	x.stock.max_capacity = 10
	assert(x.b2.step_c3(0.1) == &"destination_wait" and x.buffer.get_amount(INGOT) == 5)
	x.stock.max_capacity = 15
	assert(x.b2.step_c3(0.1) == &"recovery_started")
	assert(x.stock.get_reserved_return_space() == 5)
	for i: int in range(100):
		if x.drone.get_flight_state() == Flight.STAGED_AT_SITE:
			break
		assert(x.b2.step_c3(0.1) == &"site_flight")
	assert(x.b2.step_c3(0.1) == &"collected" and x.drone.cargo_amount() == 5 and x.buffer.get_total_amount() == 0)
	assert(x.b2.step_c3(0.1) == &"return_started")
	for i: int in range(100):
		if x.drone.get_flight_state() == Flight.STAGED_AT_STORAGE:
			break
		assert(x.b2.step_c3(0.1) == &"storage_flight")
	assert(x.stock.get_amount(INGOT) == 10 and x.b2.step_c3(0.1) == &"unloaded")
	assert(x.stock.get_amount(INGOT) == 15 and x.drone.cargo_amount() == 0 and x.stock.get_reserved_return_space() == 0)
	print("PASS L: unavailable destination waits; actual logistics pickup and deposit")
	assert(x.hub.set_generator_enabled(false))
	for i: int in range(100):
		if x.drone.get_flight_state() == Flight.DOCKED:
			break
		assert(x.b2.step_c3(0.1) == &"home_flight")
	energy = x.drone.battery_units()
	assert(x.b2.step_c3(0.1) == &"dock_wait" and x.drone.battery_units() == energy)
	assert(x.hub.set_generator_enabled(true))
	_finish(x)
	assert(is_equal_approx(x.drone.battery_units(), x.drone.battery_capacity()))
	assert(x.b2.step_c3(0.1) == &"rejected" and not x.b2._c3_transport.begin(x.ticket))
	print("PASS M: real finite recharge after blackout and no replay")
	assert(x.stock.get_amount(INGOT) + x.buffer.get_total_amount() + x.drone.cargo_amount() + x.builder.cargo_amount() == 15)
	assert(x.job.state == ConstructionJob.State.CANCELLED and x.job.get_progress() == x.progress and not is_instance_valid(x.b3.completed_building))
	assert(x.scheduler.get_active_count() == 0 and x.builder.c4b_is_retired())
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b2)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B3BuilderController") == null)
	main.free()
	print("PASS N: conservation, frozen progress, no building, one owner and Main opt-out")
	x.scope.queue_free()
	print("E3d5c6f C4B isolated F6: 14/14 labeled sections passed")
