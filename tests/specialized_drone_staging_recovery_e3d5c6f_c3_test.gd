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

func _cancel(x: Dictionary) -> void:
	assert(x.b2.cancel_c3(x.site, x.drone, x.b2.lease_id))
	assert(x.job.state == ConstructionJob.State.CANCELLED and x.b2.phase == &"c3_cancelled")
	assert(x.b2._c3_ticket > 0 and x.contracts.c3_logistics_lease_matches(x.b2.lease_id, x.job, x.drone, true))

func _ready_recovery(x: Dictionary) -> void:
	for i: int in range(400):
		if x.drone.get_flight_state() == Flight.IDLE:
			break
		var action: StringName = x.b2.step_c3(0.1)
		assert(action != &"rejected" and action != &"source_quarantined")
	assert(x.drone.get_flight_state() == Flight.IDLE)

func _finish(x: Dictionary) -> void:
	for i: int in range(400):
		if x.b2.phase == &"c3_complete":
			break
		var action: StringName = x.b2.step_c3(0.1)
		assert(action not in [&"rejected", &"blocked", &"source_quarantined", &"destination_wait", &"energy_wait"])
	assert(x.b2.phase == &"c3_complete")
	assert(x.stock.get_amount(INGOT) == 15 and x.buffer.get_total_amount() == 0)
	assert(x.drone.get_flight_state() == Flight.IDLE and x.drone.cargo_amount() == 0)
	assert(x.b2._c3_transport.recovered_amount(x.b2._c3_ticket) == 5)

func _checks() -> void:
	var x := _fixture()
	assert(not x.b2.configure_c3(x.staging, x.port) and x.b2.step_c3(0.1) == &"rejected")
	var foreign := SpecializedDroneLogisticsE3d5c6fB2.new()
	add_child(foreign)
	foreign.enable_c3_staging_recovery = true
	assert(not foreign.configure_c3(x.staging, x.port))
	foreign.free()
	print("PASS A: default off and foreign owner refused")
	_enable(x)
	_deliver(x)
	assert(x.b2.receipt_id == 0 and x.port.global_position.is_equal_approx(x.site.global_position + Vector3.UP * 2.0))
	print("PASS B: authentic anchored delivery without escrow")
	_cancel(x)
	assert(x.b2._c3_audit.observe(x.b2._c3_ticket).status == &"ready_read_only")
	_finish(x)
	print("PASS C: unloaded staging cancellation recovers physically")
	x.scope.free()

	x = _fixture()
	_enable(x)
	_deliver(x)
	assert(x.b2.c3_reserve_escrow())
	assert(x.contracts.receipt_valid(x.b2.receipt_id) and x.buffer.get_total_amount() == 0)
	assert(x.escrow.held_materials(x.b2._c3_escrow_id) == {INGOT: 5})
	print("PASS D: genuine escrow and immutable handoff")
	_cancel(x)
	assert(x.buffer.get_amount(INGOT) == 5 and x.stock.get_amount(INGOT) == 10 and x.escrow.held_count() == 0)
	assert(not x.contracts.receipt_valid(x.b2.receipt_id))
	_finish(x)
	print("PASS E: held escrow refunds only original staging then physical recovery")
	x.scope.free()

	x = _fixture()
	_enable(x)
	_deliver(x)
	assert(x.b2.c3_reserve_escrow())
	x.buffer.max_capacity = 4
	_cancel(x)
	assert(x.escrow.held_count() == 1 and x.buffer.get_total_amount() == 0)
	assert(x.b2._c3_audit.observe(x.b2._c3_ticket).status == &"escrow_unsettled")
	for i: int in range(400):
		if x.b2.step_c3(0.1) == &"escrow_wait":
			break
	assert(x.escrow.held_count() == 1 and x.drone.get_flight_state() == Flight.DOCKED)
	assert(x.b2.step_c3(0.1) == &"escrow_wait")
	x.buffer.max_capacity = 5
	assert(x.b2.step_c3(0.1) == &"escrow_settled")
	assert(x.escrow.held_count() == 0 and x.buffer.get_amount(INGOT) == 5)
	_finish(x)
	print("PASS F: blocked refund retains escrow and exact retry settles once")
	x.scope.free()

	x = _fixture()
	_enable(x)
	_deliver(x)
	assert(x.b2.c3_reserve_escrow() and x.b2.c3_begin_empty_return())
	assert(x.b2.step_c3(0.1) == &"empty_return")
	var pos: Vector3 = x.drone.global_position
	_cancel(x)
	assert(x.drone.global_position == pos and not x.contracts.receipt_valid(x.b2.receipt_id))
	_finish(x)
	print("PASS G: cancellation during empty return safely retires revoked receipt")
	x.scope.free()

	x = _fixture()
	_enable(x)
	_deliver(x)
	assert(x.b2.c3_reserve_escrow() and x.b2.c3_begin_empty_return())
	for i: int in range(100):
		if x.b2.phase == &"c3_docked":
			break
		assert(x.b2.step_c3(0.1) == &"empty_return")
	assert(x.b2.phase == &"c3_docked" and x.drone.get_flight_state() == Flight.DOCKED)
	assert(not x.scope.get_node("B3BuilderController").start_builder())
	_cancel(x)
	_ready_recovery(x)
	print("PASS H: docked pre-builder handoff canceled and cleaned")
	var hover: Vector3 = x.port.global_position
	x.port.global_position += Vector3.RIGHT
	assert(x.b2.step_c3(0.1) == &"source_quarantined")
	assert(x.buffer.get_amount(INGOT) == 5 and x.drone.cargo_amount() == 0)
	x.port.global_position = hover
	print("PASS I: moved original receiver quarantined without debit")
	x.stock.max_capacity = 10
	assert(x.b2.step_c3(0.1) == &"destination_wait")
	x.stock.max_capacity = 15
	x.storage.position.x = 100.0
	assert(x.b2.step_c3(0.1) == &"destination_wait")
	x.storage.position.x = 5.0
	assert(x.buffer.get_amount(INGOT) == 5 and x.stock.get_reserved_return_space() == 0)
	print("PASS J: capacity and full-route energy gates prevent departure")
	assert(x.b2.step_c3(0.1) == &"recovery_started")
	assert(x.stock.get_reserved_return_space() == 5 and x.stock.add_item(INGOT, 1) == 0)
	assert(x.buffer.get_amount(INGOT) == 5 and x.drone.cargo_amount() == 0)
	print("PASS K: exact protected capacity reserved before collection")
	var energy: float = x.drone.battery_units()
	assert(x.b2.step_c3(0.1) == &"site_flight")
	assert(x.drone.battery_units() < energy and x.buffer.get_amount(INGOT) == 5)
	for i: int in range(40):
		if x.drone.get_flight_state() == Flight.STAGED_AT_SITE:
			break
		assert(x.b2.step_c3(0.1) == &"site_flight")
	assert(x.drone.get_flight_state() == Flight.STAGED_AT_SITE and x.drone.global_position.is_equal_approx(hover))
	print("PASS L: metered actual site approach without remote pickup")
	assert(x.b2.step_c3(0.1) == &"collected")
	assert(x.drone.cargo_amount() == 5 and x.buffer.get_total_amount() == 0)
	assert(x.scope.get_node("StagingRegistry").has_locked_pair(x.staging, x.port))
	print("PASS M: exact physical collection preserves original staging lock")
	x.dock.allow_returns = false
	assert(x.b2.step_c3(0.1) == &"destination_wait")
	assert(x.drone.cargo_amount() == 5 and x.stock.get_reserved_return_space() == 5)
	x.dock.allow_returns = true
	assert(x.b2.step_c3(0.1) == &"return_started")
	print("PASS N: invalid destination safely holds cargo and existing claim")
	for i: int in range(40):
		if x.drone.get_flight_state() == Flight.STAGED_AT_STORAGE:
			break
		assert(x.b2.step_c3(0.1) == &"storage_flight")
	assert(x.drone.get_flight_state() == Flight.STAGED_AT_STORAGE and x.stock.get_amount(INGOT) == 10)
	var revision: int = x.stock.get_mutation_revision()
	assert(x.b2.step_c3(0.1) == &"unloaded")
	assert(x.stock.get_amount(INGOT) == 15 and x.stock.get_mutation_revision() == revision + 1)
	assert(x.stock.get_reserved_return_space() == 0 and x.drone.cargo_amount() == 0)
	print("PASS O: exact-once physical deposit")
	x.dock.queue_free()
	assert(x.hub.set_generator_enabled(false))
	energy = x.drone.battery_units()
	for i: int in range(40):
		if x.drone.get_flight_state() == Flight.DOCKED:
			break
		assert(x.b2.step_c3(0.1) == &"home_flight")
	assert(x.drone.get_flight_state() == Flight.DOCKED and x.drone.battery_units() < energy)
	energy = x.drone.battery_units()
	assert(x.b2.step_c3(0.1) == &"dock_wait" and x.drone.battery_units() == energy)
	print("PASS P: home independent of lost dock and blackout blocks charging")
	assert(x.hub.set_generator_enabled(true))
	_finish(x)
	assert(x.b2.step_c3(0.1) == &"rejected" and x.stock.get_mutation_revision() == revision + 1)
	assert(not x.b2._c3_transport.begin(x.b2._c3_ticket))
	print("PASS Q: finite recharge and rearm without replay")
	assert(x.stock.get_amount(INGOT) + x.buffer.get_total_amount() + x.drone.cargo_amount() == 15 and x.escrow.held_count() == 0)
	assert(x.builder.get_flight_state() == Flight.IDLE and x.scheduler.get_active_count() == 0 and x.job.get_progress() == 0.0)
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b2)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B2LogisticsController") == null)
	main.free()
	print("PASS R: conservation, idle builder, single tick owner and Main opt-out")
	x.scope.queue_free()
	print("E3d5c6f C3 isolated F6: 18/18 labeled sections passed")
