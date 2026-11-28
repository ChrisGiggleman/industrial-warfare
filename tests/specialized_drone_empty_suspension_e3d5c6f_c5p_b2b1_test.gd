extends Node3D
const SCOPE := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const STORAGE := preload("res://data/buildings/test_storage.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState

func _ready() -> void:
	call_deferred("_checks")

func _fixture(automated: bool = true, power_mode: bool = true, suspend_mode: bool = true) -> Dictionary:
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
	b2.enable_c5p_building_power = power_mode
	b2.enable_c5p_empty_suspension = suspend_mode

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

const HUB := preload("res://scenes/buildings/prototype_main_hub.tscn")

func _setup(suspend_mode: bool = true) -> Dictionary:
	var x := _fixture(true, true, suspend_mode)
	_enable(x)
	var pole := POLE.instantiate() as PrototypePowerStructure
	x.scope.add_child(pole)
	pole.position = Vector3(8, 0, 0)
	x.pole = pole
	x.network = x.scope.get_node("PowerNetwork")
	x.power = x.scope.get_node("PowerAllocator")
	assert(x.b2.configure_c5p_power(pole))
	return x

func _park(x: Dictionary) -> void:
	for i: int in range(20):
		if x.b2.phase == &"c5p_empty_parked":
			break
		assert(x.b2.step_c1(0.5))
	assert(x.b2.phase == &"c5p_empty_parked" and x.drone.get_flight_state() == Flight.C5P_EMPTY_PARKED)
	assert(x.drone.global_position.is_equal_approx(x.home) and x.drone.cargo_amount() == 0)
	assert(x.supplier.reservation_count() == 0)

func _at_pickup(x: Dictionary) -> void:
	assert(x.b2.c1_launch())
	for i: int in range(20):
		if x.b2.phase == &"c1_at_pickup":
			break
		assert(x.b2.step_c1(0.5))
	assert(x.drone.get_flight_state() == Flight.AT_PICKUP)

func _checks() -> void:
	var x := _setup()
	assert(x.hub.set_generator_enabled(false))
	assert(not x.b2.c1_reserve() and x.b2.lease_id == 0 and x.supplier.reservation_count() == 0)
	assert(x.supplier.reserve(x.drone, x.site, INGOT, 5, 5) == 0)
	assert(x.stock.get_amount(INGOT) == 15 and x.job.state == ConstructionJob.State.QUEUED)
	print("PASS A: idle outage blocks reserve and direct supplier bypass")
	assert(x.hub.set_generator_enabled(true) and x.b2.c1_reserve())
	var lease: int = x.b2.lease_id
	assert(x.hub.set_generator_enabled(false) and not x.b2.c1_launch())
	_park(x)
	assert(x.b2.lease_id == lease and x.contracts.c2_logistics_lease_matches(lease, x.job, x.drone, false))
	assert(x.stock.get_amount(INGOT) == 15 and x.stock.get_reserved_amount(INGOT) == 0)
	print("PASS B: reserved outage releases claim, preserves lease")
	assert(x.hub.set_generator_enabled(true) and x.b2.step_c1(0.1))
	assert(x.b2.phase == &"c1_reserved" and x.b2.lease_id == lease)
	assert(x.b2.c1_launch() and x.b2.step_c1(1.0))
	var before: Vector3 = x.drone.global_position
	assert(not before.is_equal_approx(x.home))
	x.hub.set_service_enabled(false)
	assert(x.b2.step_c1(0.1) and x.b2.phase == &"c5p_empty_return")
	assert(x.drone.global_position == before and x.stock.get_amount(INGOT) == 15)
	assert(x.b2.step_c1(0.25) and x.drone.global_position.distance_to(x.home) < before.distance_to(x.home))
	x.hub.set_service_enabled(true)
	assert(x.b2.phase == &"c5p_empty_return" and not x.b2.c1_launch())
	_park(x)
	assert(x.b2.step_c1(0.1) and x.b2.phase == &"c1_reserved" and x.b2.lease_id == lease)
	print("PASS C: physical return during service outage, finish parking before resume")
	_at_pickup(x)
	assert(x.hub.set_generator_enabled(false))
	assert(not x.supplier.collect_pickup(x.b2.pickup_id, x.drone))
	assert(not x.b2.c2_collect())
	_park(x)
	assert(x.stock.get_amount(INGOT) == 15 and x.drone.cargo_amount() == 0)
	print("PASS D: arrival outage blocks collection and returns empty")
	assert(x.stock.remove_item(INGOT, 12))
	assert(x.hub.set_generator_enabled(true))
	assert(x.b2.step_c1(0.1) and x.b2.phase == &"c5p_empty_parked" and x.b2.c5p_empty_diagnostic == &"stock_wait")
	assert(x.stock.add_item(INGOT, 7) == 7)
	assert(x.b2.step_c1(0.1) and x.b2.phase == &"c1_reserved" and x.b2.lease_id == lease)
	_at_pickup(x)
	assert(x.b2.c2_collect() and x.stock.get_amount(INGOT) == 5 and x.drone.cargo_amount() == 5)
	assert(x.supplier.reservation_count() == 0 and x.contracts.lease_count() == 1 and x.escrow.held_count() == 0)
	print("PASS E: stock contention and same-lease exact debit")
	x.scope.free()

	x = _setup()
	assert(x.b2.c1_reserve() and x.b2.c1_launch() and x.b2.step_c1(1.0))
	assert(x.hub.set_generator_enabled(false) and x.b2.step_c1(0.1))
	assert(x.b2.cancel_c1(x.site, x.drone, x.b2.lease_id))
	assert(x.hub.set_generator_enabled(true))
	for i: int in range(20):
		if x.b2.phase == &"c1_complete":
			break
		assert(x.b2.step_c1(0.5))
	assert(x.b2.phase == &"c1_complete" and x.drone.get_flight_state() == Flight.IDLE)
	assert(x.stock.get_amount(INGOT) == 15 and x.contracts.c2_logistics_lease_matches(x.b2.lease_id, x.job, x.drone, true))
	assert(not x.b2.c1_reserve())
	print("PASS F: cancel during return wins over restoration")
	x.scope.free()

	x = _setup()
	assert(x.b2.c1_reserve() and x.hub.set_generator_enabled(false) and x.b2.step_c1(0.1))
	_park(x)
	assert(x.b2.cancel_c1(x.site, x.drone, x.b2.lease_id) and x.b2.step_c1(0.1))
	assert(x.b2.phase == &"c1_complete" and x.stock.get_amount(INGOT) == 15)
	print("PASS G: cancel parked settles without refund")
	x.scope.free()

	x = _setup()
	assert(x.b2.c1_reserve() and x.b2.c1_launch() and x.b2.step_c1(1.0))
	assert(x.hub.set_generator_enabled(false) and x.b2.step_c1(0.1))
	before = x.drone.global_position
	assert(not x.drone.c5p_step_empty_return(x.b2, 0.5, false))
	assert(not x.b2.step_c1(0.0) and not x.b2.step_c1(2.0))
	assert(x.drone.global_position == before)
	x.scope.set_meta("e3d5c6f_single_tick_owner", weakref(x.scope.get_node("B3BuilderController")))
	assert(not x.b2.step_c1(0.5) and x.drone.global_position == before)
	x.scope.set_meta("e3d5c6f_single_tick_owner", weakref(x.b2))
	x.hub.position += Vector3(1, 0, 0)
	assert(not x.b2.step_c1(0.5) and x.drone.global_position == before)
	x.hub.position -= Vector3(1, 0, 0)
	_park(x)
	print("PASS H: wrong tick owner and moved hub fail closed")
	x.scope.free()

	x = _setup()
	assert(x.b2.c1_reserve() and x.b2.c1_launch() and x.b2.step_c1(1.0))
	x.power.free()
	assert(x.b2.step_c1(0.1))
	_park(x)
	assert(x.b2.step_c1(0.1) and x.b2.phase == &"c5p_empty_parked" and x.b2.c5p_empty_diagnostic == &"invalid_authority")
	print("PASS I: lost power authority permits safe return but not resume")
	x.scope.free()

	x = _setup()
	assert(x.b2.c1_reserve() and x.b2.c1_launch())
	assert(not x.drone._advance_pickup(RefCounted.new(), x.dock, 0.1))
	assert(not x.supplier.suspend_c5p_claim(x.b2.pickup_id + 1, x.drone, x.b2))
	x.b2.enable_c5p_empty_suspension = false
	assert(x.b2.c5p_empty_mode() and x.drone._c5p_empty_latched)
	assert(x.hub.set_generator_enabled(false) and x.b2.step_c1(0.1))
	_park(x)
	print("PASS J: foreign token and runtime mode switch rejected")
	x.scope.free()

	x = _setup(false)
	assert(not x.b2.c5p_empty_mode() and not x.drone._c5p_empty_latched)
	assert(x.hub.set_generator_enabled(false) and x.b2.c1_reserve() and x.b2.c1_launch())
	assert(x.b2.step_c1(0.1))
	x.scope.free()
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B2LogisticsController") == null)
	main.free()
	print("PASS K: B2a-only mode and Main opt-out preserved")

	x = _setup()
	assert(x.b2.c1_reserve() and x.b2.c1_launch() and x.b2.step_c1(0.5))
	var old_pickup: int = x.b2.pickup_id
	x.dock.free()
	assert(x.supplier.reservation_count() == 0 and x.stock.get_reserved_amount(INGOT) == 0)
	assert(not x.b2.step_c1(0.5) and not x.supplier.collect_pickup(old_pickup, x.drone))
	assert(x.stock.get_amount(INGOT) == 15 and x.drone.cargo_amount() == 0 and x.job.state == ConstructionJob.State.QUEUED)
	print("PASS L: lost source dock releases unused claim and blocks stale pickup")
	x.scope.free()
	print("E3d5c6f C5P-B2b-1: 12/12 printed sections passed")
