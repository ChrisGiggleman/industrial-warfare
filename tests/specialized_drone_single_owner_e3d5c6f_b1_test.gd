extends Node3D
## E3d5c6f B1 isolated F6: identity-only drones + one guarded inert owner.
## There is intentionally no _process-driven gameplay or motion in B1.
const Scope := preload("res://scenes/core/playable_specialized_drones_e3d5c6f.tscn")
const Press := preload("res://data/buildings/prototype_ammunition_press.tres")
const Ingot := preload("res://data/items/test_ingot.tres")

func _ready() -> void:
	call_deferred("_checks")

func _checks() -> void:
	var scope := Scope.instantiate() as Node3D
	add_child(scope)
	var controller := scope.get_node("SingleTickController") as PlayableSpecializedDronesE3d5c6f
	var contracts := scope.get_node("RoleContracts") as SpecializedDroneRoleContractsE3d5c6f
	var logistics := scope.get_node("LogisticsDrone") as PrototypeConstructionWorkerDrone
	var builder := scope.get_node("ConstructionDrone") as PrototypeConstructionWorkerDrone
	var hub := scope.get_node("MainHub") as PrototypePowerStructure
	assert(scope.scene_file_path == controller.EXACT_SCENE)
	assert(contracts._scope_ok() and controller.has_verified_b1_scope())
	assert(hub.scene_file_path == controller.HUB_SCENE and hub.get_power_node() != null)
	assert(logistics != builder and logistics.get_instance_id() != builder.get_instance_id())
	print("PASS A: exact new scope, authentic Hub and two distinct visible drone identities")

	assert(logistics.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(builder.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(not logistics.enable_isolated_drone and not builder.enable_isolated_drone)
	assert(not logistics.enable_isolated_cargo_pickup and not builder.enable_isolated_cargo_pickup)
	assert(not logistics.enable_isolated_cargo_delivery and not builder.enable_isolated_cargo_delivery)
	assert(logistics.cargo_amount() == 0 and builder.cargo_amount() == 0)
	print("PASS B: motion, pickup, delivery and worker admission remain disabled")

	assert(not controller.is_processing() and not controller.is_physics_processing())
	assert(controller.tick_count == 0 and controller.step_b1(0.1))
	assert(controller.tick_count == 1 and controller.last_tick["action"] == &"b1_idle")
	assert(controller.step_b1(0.1) and controller.tick_count == 2)
	assert(not controller.step_b1(0.0) and not controller.step_b1(-1.0))
	assert(not controller.step_b1(2.0) and controller.tick_count == 2)
	print("PASS C: only explicit bounded inert steps; invalid deltas never advance")

	var start_logistics := logistics.global_position
	var start_builder := builder.global_position
	var start_energy_logistics: float = logistics.battery_units()
	var start_energy_builder: float = builder.battery_units()
	var source := scope.get_node("StarterInventory") as InventoryComponent
	var escrow := scope.get_node("MaterialEscrow") as BlueprintConstructionMaterialEscrow
	var queue := scope.get_node("PriorityQueue") as BlueprintConstructionPriorityQueue
	var scheduler := scope.get_node("WorkerScheduler") as BlueprintConstructionSlotScheduler
	var before_stock := source.get_amount(Ingot)
	assert(controller.step_b1(0.1))
	assert(logistics.global_position == start_logistics and builder.global_position == start_builder)
	assert(logistics.battery_units() == start_energy_logistics and builder.battery_units() == start_energy_builder)
	assert(source.get_amount(Ingot) == before_stock and escrow.held_count() == 0)
	assert(scheduler.get_active_count() == 0 and contracts.lease_count() == 0)
	print("PASS D: no movement, charge, inventory, escrow, worker slot or claim changes")

	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(Press))
	scope.add_child(site)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(not queue.register_queued_site(site))
	assert(contracts.claim_logistics(site, logistics, queue, scope.get_node("StagingRegistry"), source) == 0)
	var before_progress: float = site.job.get_progress()
	assert(controller.step_b1(0.1))
	assert(site.job.state == ConstructionJob.State.PLANNED and site.job.get_progress() == before_progress)
	print("PASS E: PLANNED site cannot launch or advance even after inert ticks")

	var impostor := PlayableSpecializedDronesE3d5c6f.new()
	scope.add_child(impostor)
	impostor.enable_b1_controller = true
	assert(not controller.has_verified_b1_scope() and not controller.step_b1(0.1))
	assert(not impostor.step_b1(0.1))
	impostor.free()
	assert(controller.has_verified_b1_scope() and controller.step_b1(0.1))
	print("PASS F: duplicate tick-owner injection stops both; recovery after removal")

	var old_dispatch := PrototypeDroneAutomaticDispatch.new()
	scope.add_child(old_dispatch)
	assert(not controller.has_verified_b1_scope() and not controller.step_b1(0.1))
	old_dispatch.free()
	assert(controller.has_verified_b1_scope())
	print("PASS G: legacy dispatcher cannot be mixed with specialized controller")

	builder.enable_isolated_drone = true
	assert(not controller.step_b1(0.1))
	builder.enable_isolated_drone = false
	logistics.enable_isolated_cargo_pickup = true
	assert(not controller.step_b1(0.1))
	logistics.enable_isolated_cargo_pickup = false
	assert(controller.step_b1(0.1))
	print("PASS H: attempted premature movement or pickup fails closed")

	controller.enable_b1_controller = false
	assert(not controller.step_b1(0.1))
	controller.enable_b1_controller = true
	assert(controller.step_b1(0.1))
	assert(site.job.get_progress() == before_progress and source.get_amount(Ingot) == before_stock)
	print("PASS I: explicit opt-out stops orchestration without changing site/materials")
	scope.queue_free()
	print("E3d5c6f B1 isolated fixture: 9/9 printed sections passed")
