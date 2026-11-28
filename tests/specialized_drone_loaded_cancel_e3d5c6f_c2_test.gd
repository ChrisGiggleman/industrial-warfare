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

	return {"scope": scope, "b2": b2, "site": site, "job": site.job, "stock": stock, "drone": logistics, "builder": builder, "supplier": scope.get_node("SupplierReservations"), "hub": scope.get_node("MainHub"), "home": logistics.global_position, "buffer": staging.get_staged_inventory(), "escrow": escrow, "scheduler": scheduler, "dock": dock, "storage": storage, "contracts": contracts}


func _enable(x: Dictionary) -> void:
	x.b2.enable_c1_pre_pickup_cancel = true
	assert(x.b2.configure_c1())
	x.b2.enable_c2_loaded_cancel = true
	assert(x.b2.configure_c2())

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

func _cancel(x: Dictionary) -> void:
	assert(x.b2.cancel_c2(x.site, x.drone, x.b2.lease_id))
	assert(x.job.state == ConstructionJob.State.CANCELLED and x.b2.phase == &"c2_cancelled")
	assert(x.drone.cargo_amount() == 5 and x.buffer.get_total_amount() == 0 and x.escrow.held_count() == 0)

func _finish(x: Dictionary) -> void:
	for i: int in range(100):
		if x.b2.phase == &"c2_complete":
			break
		assert(x.b2.step_c2(1.0) != &"rejected")
	assert(x.b2.phase == &"c2_complete")
	assert(x.drone.get_flight_state() == Flight.IDLE and x.drone.global_position.is_equal_approx(x.home))
	assert(is_equal_approx(x.drone.battery_units(), x.drone.battery_capacity()))
	assert(x.drone.cargo_amount() == 0 and x.b2._c1_returns.reservation_count() == 0)

func _alternate(x: Dictionary, at: Vector3) -> PrototypeDroneStorageDock:
	var building := STORAGE.building_scene.instantiate() as Node3D
	x.scope.add_child(building)
	building.position = at
	building.add_to_group("player_built")
	building.add_to_group("logistics_storage")
	(building.get_node("BuildingRuntime") as BuildingRuntime).initialize(STORAGE)
	var inventory := building.get_node("InventoryComponent") as InventoryComponent
	inventory.max_capacity = 5
	var dock := PrototypeDroneStorageDock.new()
	building.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	dock.allow_pickup = false
	assert(x.b2.c2_register_return_dock(dock))
	return dock

func _checks() -> void:
	var x := _fixture()
	assert(not x.b2.configure_c2() and not x.b2.c2_collect() and x.b2.step_c2(1.0) == &"rejected")
	var foreign := SpecializedDroneLogisticsE3d5c6fB2.new()
	add_child(foreign)
	foreign.enable_c2_loaded_cancel = true
	assert(not foreign.configure_c2() and foreign.step_c2(1.0) == &"rejected")
	foreign.free()
	print("PASS A: default off and foreign scope refused")
	_enable(x)
	_load(x)
	assert(not x.b2.c2_collect() and not x.drone.unload_delivery())
	print("PASS B: exact physical five-ingot pickup")
	_cancel(x)
	_finish(x)
	assert(x.stock.get_amount(INGOT) == 15)
	print("PASS C: immediate loaded cancellation physically returns original five")
	x.scope.free()

	x = _fixture()
	_enable(x)
	_load(x)
	assert(x.b2.c2_begin_delivery() and x.b2.step_c2(1.0) == &"delivery")
	assert(x.drone.get_flight_state() == Flight.DELIVERY_OUTBOUND)
	_cancel(x)
	_finish(x)
	assert(x.stock.get_amount(INGOT) == 15)
	print("PASS D: mid-delivery cancellation physically recovers")
	x.scope.free()

	x = _fixture()
	_enable(x)
	var alternate := _alternate(x, Vector3(9, 0, 0))
	var receiver := alternate.get_parent().get_node("InventoryComponent") as InventoryComponent
	_load(x)
	assert(x.b2.c2_begin_delivery())
	for i: int in range(10):
		if x.b2.phase == &"c2_at_delivery":
			break
		assert(x.b2.step_c2(1.0) == &"delivery")
	assert(x.drone.get_flight_state() == Flight.AT_DELIVERY)
	assert(x.drone.cargo_amount() == 5 and x.buffer.get_total_amount() == 0)
	assert(not x.b2.cancel_c2(x.site, x.builder, x.b2.lease_id))
	assert(not x.b2.cancel_c2(x.site, x.drone, x.b2.lease_id + 1))
	_cancel(x)
	print("PASS E: arrival before unload remains actual drone cargo")
	assert(x.contracts.c2_logistics_lease_matches(x.b2.lease_id, x.job, x.drone, true))
	assert(not x.drone.unload_delivery() and not x.b2.c2_begin_delivery())
	assert(not x.b2.cancel_c2(x.site, x.drone, x.b2.lease_id))
	assert(not x.b2.step_b2(1.0) and not x.b2.step_c1(1.0))
	print("PASS F: terminal lease tombstone and stale delivery refused")
	var energy: float = x.drone.battery_units()
	assert(x.b2.step_c2(1.0) == &"recovery")
	assert(receiver.get_reserved_return_space() == 5 and x.stock.get_reserved_return_space() == 0)
	assert(receiver.get_total_amount() == 0 and x.drone.battery_units() == energy)
	print("PASS G: nearest eligible dock reserves capacity without deposit")
	assert(receiver.add_item(INGOT, 1) == 0 and receiver.get_total_amount() == 0)
	print("PASS H: normal intake cannot consume reserved space")
	# Full relative to five-ingot load, with no invented physical stock.
	x.stock.max_capacity = 10
	receiver.max_capacity = 4
	assert(x.b2.step_c2(1.0) == &"recovery_wait")
	assert(receiver.get_reserved_return_space() == 0 and x.drone.cargo_amount() == 5)
	assert(x.drone.get_flight_state() == Flight.RECOVERY_WAIT)
	assert(x.b2.step_c2(1.0) == &"recovery_wait")
	assert(x.drone.battery_units() == energy and x.scheduler.get_active_count() == 0)
	print("PASS I: insufficient whole-load space safely retains cargo")
	receiver.max_capacity = 5
	assert(x.b2.step_c2(1.0) == &"recovery")
	assert(receiver.get_reserved_return_space() == 5)
	print("PASS J: restored alternate eligibility reroutes")
	alternate.allow_returns = false
	assert(x.b2.step_c2(1.0) == &"recovery_wait")
	assert(receiver.get_reserved_return_space() == 0 and x.drone.cargo_amount() == 5)
	alternate.allow_returns = true
	assert(x.b2.step_c2(1.0) == &"recovery")
	alternate.get_parent().position.x = 100.0
	assert(x.b2.step_c2(1.0) == &"recovery_wait")
	assert(receiver.get_reserved_return_space() == 0 and x.drone.cargo_amount() == 5)
	print("PASS K: invalidated dock and capacity shrink release stale claim")
	assert(x.b2.step_c2(1.0) == &"recovery_wait")
	assert(x.drone.battery_units() == energy)
	alternate.get_parent().position.x = 8.0
	assert(x.b2.step_c2(1.0) == &"recovery")
	print("PASS L: unreachable dock refused and restored route accepted")
	assert(x.b2.step_c2(1.0) == &"recovery")
	assert(x.drone.get_flight_state() == Flight.AT_RECOVERY and x.drone.battery_units() < energy)
	assert(receiver.get_total_amount() == 0)
	var revision: int = receiver.get_mutation_revision()
	assert(x.b2.step_c2(1.0) == &"recovery")
	assert(receiver.get_amount(INGOT) == 5 and receiver.get_mutation_revision() == revision + 1)
	assert(x.drone.cargo_amount() == 0 and receiver.get_reserved_return_space() == 0)
	print("PASS M: metered arrival and exact-once reserved deposit")
	assert(x.hub.set_generator_enabled(false))
	var return_energy: float = x.drone.battery_units()
	for i: int in range(20):
		if x.drone.get_flight_state() == Flight.DOCKED:
			break
		assert(x.b2.step_c2(1.0) == &"recovery")
	assert(x.drone.get_flight_state() == Flight.DOCKED and x.drone.battery_units() < return_energy)
	var depleted: float = x.drone.battery_units()
	assert(x.b2.step_c2(1.0) == &"charging_wait" and x.drone.battery_units() == depleted)
	assert(not x.drone.charge_at_home(1.0, true))
	print("PASS N: empty metered return and blackout prevents charging")
	assert(x.hub.set_generator_enabled(true))
	_finish(x)
	assert(x.b2.step_c2(1.0) == &"rejected" and receiver.get_mutation_revision() == revision + 1)
	print("PASS O: finite full recharge and terminal rearm, no replay")
	assert(x.stock.get_amount(INGOT) + receiver.get_amount(INGOT) + x.drone.cargo_amount() + x.buffer.get_total_amount() == 15)
	assert(x.stock.get_amount(INGOT) == 10 and x.escrow.held_count() == 0)
	assert(x.builder.get_flight_state() == Flight.IDLE and x.scheduler.get_active_count() == 0)
	assert(not x.drone.grants_worker_readiness() and x.job.get_progress() == 0.0)
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b2)
	assert(not x.scope.get_node("SingleTickController").step_b1(0.1) and not x.scope.get_node("B3BuilderController").step_builder(0.1))
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B2LogisticsController") == null)
	main.free()
	print("PASS P: fifteen conserved, idle builder, one tick owner, Main opt-out")
	x.scope.queue_free()
	print("E3d5c6f C2 isolated F6: 16/16 labeled sections passed")
