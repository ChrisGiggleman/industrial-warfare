extends Node3D
## E3d5c6f B3: original physical 5-ingot B2 mission followed by a DIFFERENT
## construction drone's metered arrival and original 18-second Press job.
const SCOPE := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const STORAGE := preload("res://data/buildings/test_storage.tres")
const PRESS := preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT := preload("res://data/items/test_ingot.tres")
const POLE := preload("res://scenes/buildings/prototype_power_pole.tscn")

func _ready() -> void:
	call_deferred("_checks")

func _checks() -> void:
	var scope := SCOPE.instantiate() as Node3D
	add_child(scope)
	var b1 := scope.get_node("SingleTickController") as PlayableSpecializedDronesE3d5c6f
	var b2 := scope.get_node("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
	var b3 := scope.get_node("B3BuilderController") as SpecializedDroneBuilderE3d5c6fB3
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node("ConstructionDrone") as PrototypeConstructionWorkerDrone
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var registry := scope.get_node("StagingRegistry") as BlueprintConstructionSiteStagingRegistry
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	var coordinator := scope.get_node("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(PRESS))
	scope.add_child(site)
	site.position = Vector3(10, 0, 0)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(not b3.start_builder() and not b3.step_builder(1.0))
	print("PASS A: no physical builder or worker grant before original B2 delivery")

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
	b1.enable_b1_controller = false
	b2.enable_b2_logistics = true
	b3.enable_b3_builder = true
	assert(b2.configure_b2(site, storage, staging, port, dock))
	assert(not scheduler.bind_specialized_builder(site, builder, contracts, 42, coordinator, escrow))
	print("PASS B: original queued Press/receiver and second worker cannot bind early")

	assert(b2.start_b2())
	assert(b2.step_b2(1.0) and b2.step_b2(3.0))
	assert(stock.get_amount(INGOT) == 10 and logistics.cargo_amount() == 5)
	assert(b2.step_b2(1.0) and b2.step_b2(3.0))
	assert(b2.phase == &"return" and logistics.cargo_amount() == 0)
	assert(escrow.reservation_for(site) > 0 and contracts.receipt_valid(b2.receipt_id))
	assert(b2.step_b2(1.0) and b2.step_b2(10.0) and b2.b2_completed())
	assert(not builder.enable_isolated_drone and site.job.get_progress() == 0.0)
	print("PASS C: authentic B2 transport, five real escrowed ingots and logistics return")

	var pole := POLE.instantiate() as PrototypePowerStructure
	scope.add_child(pole)
	pole.position = Vector3(8, 0, 0)
	assert(pole.get_power_node() != null)
	assert(not b3.start_builder())
	assert(b3.configure_b3(pole))
	assert(not b3.configure_b3(pole))
	assert(coordinator.matches_tick_services(scheduler, escrow))
	assert(scheduler.capacity == 1 and scheduler.is_tracking_site(site))
	assert(scheduler.get_active_count() == 0 and site.job.state == ConstructionJob.State.QUEUED)
	print("PASS D: one real linked power allocation/coordinator and original worker slot")

	var hub := scope.get_node("MainHub") as PrototypePowerStructure
	assert(hub.set_generator_enabled(false))
	var original_progress: float = site.job.get_progress()
	assert(b3.start_builder())
	assert(not b3.start_builder())
	assert(contracts.builder_claim_valid(b3.receipt_id, builder))
	assert(not contracts.builder_claim_valid(b3.receipt_id, logistics))
	assert(builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(not b2.step_b2(1.0))
	assert(site.job.get_progress() == original_progress and scheduler.get_active_count() == 0)
	print("PASS E: exact receipt binds different builder, one tick token and no remote work")

	var home := builder.global_position
	var initial_energy: float = builder.battery_units()
	assert(not scheduler.bind_specialized_builder(site, builder, contracts, b3.receipt_id, coordinator, escrow))
	assert(b3.step_builder(1.0))
	assert(builder.global_position.distance_to(home) > 0.0 and builder.battery_units() < initial_energy)
	assert(not builder.is_at_site() and scheduler.get_active_count() == 0)
	assert(b3.step_builder(4.0))
	assert(builder.is_at_site() and b3.phase == &"flight")
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	print("PASS F: metered physical builder arrives but blackout prevents worker admission")

	assert(hub.set_generator_enabled(true))
	assert(b3.step_builder(0.1))
	assert(b3.phase == &"work" and site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1 and scheduler.has_drone_binding(builder))
	assert(not scheduler.has_drone_binding(logistics))
	assert(not contracts.receipt_valid(b3.receipt_id))
	assert(site.job.get_progress() == 0.0)
	print("PASS G: original coordinator + physical builder admit exactly one worker")

	assert(b3.step_builder(6.0))
	var halfway: float = site.job.get_progress()
	assert(is_equal_approx(halfway, 6.0 / 18.0) and b3.progress_ticks == 1)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING and escrow.held_count() == 1)
	assert(hub.set_generator_enabled(false))
	assert(b3.step_builder(5.0))
	assert(site.job.state == ConstructionJob.State.PAUSED and site.job.get_progress() == halfway)
	assert(scheduler.get_active_count() == 0 and escrow.held_count() == 1)
	print("PASS H: original 18-second clock pauses on real power loss with escrow intact")

	assert(hub.set_generator_enabled(true))
	assert(b3.step_builder(12.0))
	assert(site.job.state == ConstructionJob.State.COMPLETE)
	assert(b3.phase == &"return" and b3.progress_ticks == 2)
	assert(b3.completed_building != null and is_instance_valid(b3.completed_building))
	assert(escrow.held_count() == 0 and stock.get_amount(INGOT) == 10)
	print("PASS I: real 18 seconds completes Press once; original escrow commits once")

	assert(b3.step_builder(10.0))
	assert(b3.b3_completed() and b3.phase == &"complete")
	assert(builder.global_position == home)
	assert(builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(builder.battery_units() < initial_energy)
	assert(scheduler.get_active_count() == 0)
	print("PASS J: separate builder physically returns; only one job and worker slot")

	assert(not b3.step_builder(1.0) and not b3.start_builder())
	assert(not b2.start_b2() and not builder.grants_worker_readiness())
	assert(stock.get_amount(INGOT) == 10 and escrow.held_count() == 0)
	assert(staging.get_staged_inventory().get_total_amount() == 0)
	assert(is_instance_valid(b3.completed_building))
	print("PASS K: replay and duplicate work refused; material accounting conserved")

	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("B3BuilderController") == null)
	main.free()
	print("PASS L: Main remains opt-out; B3 confined to exact isolated scene")
	scope.queue_free()
	print("E3d5c6f B3 isolated F6: 12/12 labeled sections passed")
