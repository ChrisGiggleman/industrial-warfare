extends Node3D
const SCOPE := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const STORAGE := preload("res://data/buildings/test_storage.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState

func _ready() -> void:
	call_deferred("_checks")

func _fixture(automated: bool = true, power_mode: bool = true) -> Dictionary:
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

func _setup() -> Dictionary:
	var x := _fixture()
	_enable(x)
	var pole := POLE.instantiate() as PrototypePowerStructure
	x.scope.add_child(pole)
	pole.position = Vector3(8, 0, 0)
	x.pole = pole
	x.network = x.scope.get_node("PowerNetwork")
	x.power = x.scope.get_node("PowerAllocator")
	assert(x.b2.configure_c5p_power(pole))
	return x

func _checks() -> void:
	var x := _setup()
	var before: Dictionary = x.power.get_allocations()
	var progress: float = x.job.get_progress()
	for i: int in range(5):
		var status: Dictionary = x.b2.c5p_power_snapshot()
		assert(status.reason == &"forecast_available" and status.forecast_available and not status.actual_allocation_ready)
		assert(status.required_units == 7 and status.spare_units == 12 and status.allocated_units == 0)
	assert(x.power.get_allocations() == before and x.power._requests.is_empty() and x.escrow.held_count() == 0)
	assert(x.stock.get_amount(INGOT) == 15 and x.supplier.reservation_count() == 0 and x.job.get_progress() == progress and x.scheduler.get_active_count() == 0)
	print("PASS A: pre-escrow forecast is read-only and avoids circular wait")
	assert(x.hub.set_generator_enabled(false))
	assert(x.b2.c5p_power_snapshot().reason == &"hub_offline")
	assert(x.hub.set_generator_enabled(true))
	assert(x.network.unlink_nodes(x.hub.get_power_node(), x.pole.get_power_node()))
	assert(x.b2.c5p_power_snapshot().reason == &"site_uncovered")
	assert(x.network.link_nodes(x.hub.get_power_node(), x.pole.get_power_node()))
	print("PASS B: generator outage and disconnected destination")
	x.site.position = Vector3(11.4, 0, 0)
	assert(x.b2.c5p_power_snapshot().reason == &"site_uncovered")
	x.site.position = Vector3(10, 0, 0)
	assert(x.b2.c5p_power_snapshot().forecast_available)
	print("PASS C: entire site footprint required")
	x.hub.rated_generation = 6
	x.hub.refresh_power_state()
	assert(x.b2.c5p_power_snapshot().reason == &"insufficient_supply")
	x.hub.rated_generation = 12
	x.hub.refresh_power_state()
	print("PASS D: finite generation threshold")
	var alternate := HUB.instantiate() as PrototypePowerStructure
	x.scope.add_child(alternate)
	alternate.position = Vector3(-6, 0, 0)
	assert(x.network.register_node(alternate.get_power_node()))
	assert(x.network.link_nodes(x.hub.get_power_node(), alternate.get_power_node()))
	assert(x.hub.set_generator_enabled(false))
	assert(x.b2.c5p_power_snapshot().forecast_available)
	assert(x.hub.set_generator_enabled(true))
	assert(x.network.unlink_nodes(x.hub.get_power_node(), alternate.get_power_node()))
	assert(alternate.set_generator_enabled(false))
	print("PASS E: authentic alternate source energizes hub")
	var competitor := ConstructionSite.new()
	assert(competitor.setup_with_definition_job(PRESS))
	x.scope.add_child(competitor)
	competitor.position = Vector3(8, 0, 0)
	competitor.set_process(false)
	assert(competitor.job.authorize())
	assert(x.power.track_site(competitor, 6))
	assert(x.b2.c5p_power_snapshot().reason == &"insufficient_supply")
	x.power.stop_tracking(competitor)
	competitor.free()
	print("PASS F: existing allocations reduce available supply")
	assert(not x.b2.configure_c5p_power(x.pole))
	var duplicate := SpecializedDronePowerAuthorizationC5PB2A.new()
	x.scope.add_child(duplicate)
	assert(not duplicate.configure(x.b2, x.pole, 7))
	assert(x.b2.c5p_power_snapshot().reason == &"invalid_authority")
	duplicate.free()
	x.b2.enable_c5p_building_power = false
	assert(x.b2.c5p_power_mode() and x.b2.c5p_power_snapshot().forecast_available)
	print("PASS G: duplicate authority rejected and mode latched")
	_deliver(x)
	assert(x.b2.c3_reserve_escrow() and x.b2.c3_begin_empty_return())
	for i: int in range(120):
		if x.b2.phase == &"c3_docked":
			break
		assert(x.b2.step_c3(0.1) == &"empty_return")
	assert(x.b2.phase == &"c3_docked")
	var b3 := x.scope.get_node("B3BuilderController") as SpecializedDroneBuilderE3d5c6fB3
	b3.enable_b3_builder = true
	b3.enable_c4a_blackout = true
	assert(b3.configure_c4a(x.pole))
	var coordinator := x.scope.get_node("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator
	coordinator.reconcile()
	var actual: Dictionary = x.b2.c5p_power_snapshot()
	assert(actual.reason == &"actual_allocation_ready" and actual.actual_allocation_ready and actual.forecast_available)
	assert(actual.allocated_units == 7 and actual.spare_units == 5)
	assert(x.escrow.held_count() == 1 and x.stock.get_amount(INGOT) == 10)
	print("PASS H: builder reuses topology and recognizes own grant without double counting")
	x.scope.free()

	x = _setup()
	var synthetic := ConstructionPowerNetworkNode.new()
	x.scope.add_child(synthetic)
	assert(x.network.register_node(synthetic))
	assert(x.b2.c5p_power_snapshot().reason == &"invalid_authority")
	synthetic.free()
	x.scope.free()
	print("PASS I: foreign network participant rejected")

	x = _setup()
	x.power.free()
	assert(x.b2.c5p_power_snapshot().reason == &"invalid_authority")
	x.scope.free()
	print("PASS J: freed allocator fails closed")

	x = _fixture(true, false)
	_enable(x)
	assert(not x.b2.c5p_power_mode() and x.b2.c5p_power_snapshot().reason == &"invalid_authority")
	x.scope.free()
	x = _fixture(false, false)
	_enable(x)
	assert(not x.b2.c5p_power_mode() and not x.drone.c5p_automated_mode())
	x.scope.free()
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B2LogisticsController") == null)
	main.free()
	print("PASS K: legacy and B1-only opt-out; Main unaffected")
	print("E3d5c6f C5P-B2a: 11/11 printed sections passed")
