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

func _checks() -> void:
	var x := _fixture()
	x.b3 = x.scope.get_node("B3BuilderController")
	x.builder_home = x.builder.global_position
	assert(x.b3.step_c4a(0.1) == &"rejected" and not x.b3.start_c4a())
	var foreign := SpecializedDroneBuilderE3d5c6fB3.new()
	add_child(foreign)
	foreign.enable_c4a_blackout = true
	foreign.enable_b3_builder = true
	assert(not foreign.start_c4a() and foreign.step_c4a(0.1) == &"rejected")
	foreign.free()
	print("PASS A: default off and wrong scope refused")
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
	assert(x.b3.configure_c4a(pole))
	assert(x.b3.start_c4a() and not x.b3.start_c4a())
	assert(x.contracts.builder_claim_valid(x.b3.receipt_id, x.builder))
	assert(not x.contracts.builder_claim_valid(x.b3.receipt_id, x.drone))
	assert(x.b2._c3_ticket > 0 and x.b2.phase == &"c4_builder_owned")
	assert((x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b3)
	assert(x.b2.step_c3(0.1) == &"rejected" and not x.b3.step_builder(0.1))
	print("PASS B: original receipt and exact single owner transfer")
	var charger: PrototypeDroneHubCharging = x.b2._c1_charging
	assert(charger._entries.size() == 2 and charger._entries[0]["token"] != charger._entries[1]["token"])
	assert(charger._dock_for(x.hub, x.builder).is_equal_approx(x.builder_home))
	assert(charger._dock_for(x.hub, x.drone).is_equal_approx(x.home))
	assert(not x.builder.charge_at_home(1.0, true))
	print("PASS C: separate right berth and shared finite charging registration")
	assert(x.b3.step_c4a(1.0) == &"flight")
	var energy: float = x.builder.battery_units()
	var position: Vector3 = x.builder.global_position
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	assert(x.builder.global_position == position and x.job.get_progress() == 0.0 and x.scheduler.get_active_count() == 0)
	assert(x.escrow.held_count() == 1)
	print("PASS D: initial outbound blackout preserves queued job and escrow")
	_park(x)
	assert(x.builder.battery_units() < energy)
	energy = x.builder.battery_units()
	assert(x.b3.step_c4a(1.0) == &"blackout_wait" and x.builder.battery_units() == energy)
	assert(not x.builder.charge_at_home(1.0, true))
	print("PASS E: actual metered empty return and no blackout charge")
	assert(x.hub.set_generator_enabled(true))
	var combined: float = x.builder.battery_units() + x.drone.battery_units()
	var action: StringName = x.b3.step_c4a(0.1)
	assert(action in [&"charging", &"energy_wait"])
	var gained: float = x.builder.battery_units() + x.drone.battery_units() - combined
	var allocator := x.scope.get_node("PowerAllocator") as PrototypeConstructionPowerAllocator
	assert(gained >= 0.0 and gained <= float(allocator.spare_generation_for(x.hub.get_power_node())) * 0.1 + 0.00001)
	_resume(x)
	assert(x.builder.battery_units() == x.builder.battery_capacity())
	print("PASS F: real shared finite recharge and safe outbound resumption")
	_arrive(x)
	assert(x.job.get_progress() == 0.0 and x.scheduler.has_drone_binding(x.builder))
	assert(not x.scheduler.has_drone_binding(x.drone))
	print("PASS G: physical arrival grants exactly one worker")
	assert(x.b3.step_c4a(1.0) == &"work")
	var progress: float = x.job.get_progress()
	assert(progress > 0.0)
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	assert(x.job.state == ConstructionJob.State.PAUSED and x.job.get_progress() == progress and x.escrow.held_count() == 1)
	print("PASS H: active blackout freezes exact progress and original escrow")
	_park(x)
	energy = x.builder.battery_units()
	assert(x.b3.step_c4a(1.0) == &"blackout_wait")
	assert(x.builder.battery_units() == energy and x.scheduler.get_active_count() == 0 and x.job.get_progress() == progress)
	print("PASS I: docked blackout preserves progress without active slot")
	assert(not x.builder.c4_begin_resume(x.b3, x.site))
	# Move the original site temporarily beyond the available energy forecast;
	# this is a diagnostic route rejection, not a new construction assignment.
	var site_pos: Vector3 = x.site.position
	x.site.position.x = 100.0
	assert(not x.builder.c4_can_resume(x.b3, x.site))
	x.site.position = site_pos
	print("PASS J: insufficient route energy and unpowered direct resume refused")
	assert(x.hub.set_generator_enabled(true))
	_resume(x)
	_arrive(x)
	assert(x.job.get_progress() == progress and x.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(x.b3.step_c4a(1.0) == &"work" and x.job.get_progress() > progress)
	progress = x.job.get_progress()
	print("PASS K: same original paused job resumes at physical arrival")
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	_park(x)
	assert(x.hub.set_generator_enabled(true))
	_resume(x)
	assert(x.b3.step_c4a(1.0) == &"flight")
	assert(x.hub.set_generator_enabled(false))
	assert(x.b3.step_c4a(1.0) == &"parking_started")
	_park(x)
	assert(x.job.get_progress() == progress and x.escrow.held_count() == 1)
	assert(x.hub.set_generator_enabled(true))
	_resume(x)
	_arrive(x)
	print("PASS L: repeated blackout during resume safely parks again")
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
	print("PASS M: normal completion consumes original escrow once and returns")
	assert(x.b3.step_c4a(1.0) == &"rejected" and x.b2.step_c3(0.1) == &"rejected")
	assert(x.drone.get_flight_state() == Flight.DOCKED and x.drone.global_position.is_equal_approx(x.home))
	assert(x.builder.cargo_amount() == 0 and x.drone.cargo_amount() == 0 and x.scheduler.get_active_count() == 0)
	assert(x.buffer.get_total_amount() == 0 and (x.scope.get_meta("e3d5c6f_single_tick_owner") as WeakRef).get_ref() == x.b3)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B3BuilderController") == null)
	main.free()
	print("PASS N: role separation, one owner, no replay and Main opt-out")
	x.scope.queue_free()
	print("E3d5c6f C4A isolated F6: 14/14 labeled sections passed")
