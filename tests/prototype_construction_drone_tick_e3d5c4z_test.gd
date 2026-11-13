extends Node3D

# E3d5c4z: deterministic controller tick with real escrow and rechargeable
# one-worker fleet. No real-time Godot _process dispatch, grid draw or saves.

func _ready() -> void:
	call_deferred("_checks")


func _site(definition: BuildingDefinition, label: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _stage(
	site: ConstructionSite,
	definition: BuildingDefinition,
	ingot: ItemDefinition,
	quantity: int,
	registry: BlueprintConstructionSiteStagingRegistry
) -> BlueprintConstructionMaterialStaging:
	var source := InventoryComponent.new()
	source.max_capacity = 10
	add_child(source)
	assert(source.add_item(ingot, quantity) == quantity)
	var stage := BlueprintConstructionMaterialStaging.new()
	stage.enable_isolated_staging = true
	add_child(stage)
	assert(stage.configure(source, definition, 3))
	var owner := Node3D.new()
	add_child(owner)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.enable_isolated_input = true
	port.show_port_label = false
	owner.add_child(port)
	assert(port.attach_to_authorized_site(site, stage, registry))
	return stage


func _power(path: String, where: Vector3) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var node := packed.instantiate() as PrototypePowerStructure
	assert(node != null)
	add_child(node)
	node.global_position = where
	return node


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var driver := PrototypeConstructionDroneTickController.new()
	add_child(driver)
	assert(not driver.enable_isolated_ticks)
	assert(driver.tick(1.0, true).is_empty())
	print("PASS A: Autonomous lifecycle tick defaults OFF with no work")

	var first := _site(definition, "FirstHigh", Vector3(6, 0, 0))
	var second := _site(definition, "SecondNormal", Vector3(8, 0, 0))
	var planned := _site(definition, "NeverAuthorized", Vector3(-6, 0, 0))
	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(planned.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Changing priority alone does not authorize construction")

	assert(first.job.authorize())
	assert(second.job.authorize())
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)
	var stage_a := _stage(first, definition, ingot, 6, registry)
	var stage_b := _stage(second, definition, ingot, 3, registry)
	assert(registry.claim_count() == 2)
	assert(registry.inventory_for_site(first) != registry.inventory_for_site(second))
	print("PASS C: Only two authorized sites receive exclusive material buffers")

	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var fleet := PrototypeConstructionDroneFleet.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var allocator := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	var warehouse := InventoryComponent.new()
	for service: Node in [
		queue, scheduler, fleet, escrow, network, allocator, coordinator, warehouse
	]:
		add_child(service)
	warehouse.max_capacity = 15
	assert(warehouse.add_item(ingot, 9) == 9)
	assert(allocator.configure(network))
	var hub := _power("res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO)
	var pole := _power("res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0))
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.configure(queue, scheduler, escrow, allocator, warehouse, 1))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(coordinator.track_site(first, 7))
	assert(coordinator.track_site(second, 7))
	assert(not coordinator.track_site(planned, 7))
	print("PASS D: One worker slot, owned escrow, prototype power and two queued jobs")

	fleet.enable_isolated_fleet = true
	fleet.enable_isolated_reuse = true
	assert(fleet.configure(queue, scheduler, 2.0, 2.0))
	var drone := PrototypeConstructionWorkerDrone.new()
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	drone.enable_isolated_reuse = true
	add_child(drone)
	assert(drone.configure_battery(40.0, 16.0, 1.0, 4.0))
	assert(fleet.register_drone(drone))
	driver.enable_isolated_ticks = true
	assert(driver.configure(fleet, coordinator, scheduler, escrow))
	assert(not driver.configure(fleet, coordinator, scheduler, escrow))
	assert(driver.tick(0.0, true).is_empty())
	assert(driver.tick(INF, true).is_empty())
	print("PASS E: Single configured drone and driver reject invalid or duplicate ticks")

	var empty: Dictionary = driver.tick(1.0, false)
	assert(int(empty["dispatched"]) == 0 and int(empty["advanced"]) == 0)
	assert(fleet.idle_count() == 1)
	assert(escrow.held_count() == 0)
	print("PASS F: No materials means no automated flight despite authorization")

	assert(stage_a.receive_item(ingot, 2) == 2)
	var partial: Dictionary = driver.tick(1.0, false)
	assert(int(partial["dispatched"]) == 0)
	assert(escrow.held_count() == 0)
	assert(first.job.get_progress() == 0.0)
	print("PASS G: Partial owned bill cannot attract a drone or begin work")

	assert(stage_a.receive_item(ingot, 1) == 1)
	var launched: Dictionary = driver.tick(0.25, false)
	assert(int(launched["dispatched"]) == 1)
	assert(int(launched["advanced"]) == 0)
	assert(escrow.reservation_for(first) > 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS H: Full escrow and power launch one drone but cannot instantly start work")

	assert(int(driver.tick(2.0, false)["advanced"]) == 0)
	assert(not drone.is_at_site())
	assert(first.job.get_progress() == 0.0)
	print("PASS I: Traveling worker does not advance the authorized job timer")

	assert(int(driver.tick(1.5, false)["advanced"]) == 1)
	assert(drone.is_at_site())
	assert(first.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(first.job.get_progress(), 0.15))
	print("PASS J: Physical arrival, ownership and power trigger controlled construction")

	assert(hub.set_generator_enabled(false))
	var held_progress: float = first.job.get_progress()
	assert(int(driver.tick(2.0, false)["advanced"]) == 0)
	assert(first.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(first.job.get_progress(), held_progress))
	assert(escrow.held_count() == 1)
	print("PASS K: Generator outage pauses construction with progress and escrow intact")

	assert(hub.set_generator_enabled(true))
	assert(int(driver.tick(1.0, false)["advanced"]) == 1)
	assert(first.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(first.job.get_progress(), 0.25))
	print("PASS L: Restored power resumes only the existing drone-owned job")

	assert(stage_a.receive_item(ingot, 3) == 3)
	var hold_a: int = escrow.reservation_for(first)
	assert(hold_a > 0)
	assert(first.job.cancel())
	assert(escrow.needs_recovery(hold_a))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(fleet.get_drone_for_site(first) == drone)
	print("PASS M: Cancellation retains unresolved material escrow and starts return")

	assert(int(driver.tick(5.0, false)["recycled"]) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.battery_units() < drone.battery_capacity())
	assert(fleet.idle_count() == 0)
	print("PASS N: Docking alone does not recycle a worker without charge/recovery")

	var charging: Dictionary = driver.tick(10.0, true)
	assert(int(charging["charged"]) == 1)
	assert(int(charging["recycled"]) == 0)
	assert(is_equal_approx(drone.battery_units(), 40.0))
	assert(escrow.held_count() == 1)
	print("PASS O: Fully recharged worker remains locked while escrow is unresolved")

	var recovery := InventoryComponent.new()
	recovery.max_capacity = 10
	add_child(recovery)
	assert(escrow.recover_to(hold_a, recovery))
	assert(recovery.get_amount(ingot) == 3)
	var recycled: Dictionary = driver.tick(0.1, true)
	assert(int(recycled["recycled"]) == 1)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(drone.completed_rearms() == 1)
	assert(fleet.get_drone_for_site(first) == null)
	assert(registry.claim_count() == 2)
	print("PASS P: Clear escrow and full dock charge automatically rearm worker only")

	assert(stage_b.receive_item(ingot, 1) == 1)
	assert(int(driver.tick(0.5, false)["dispatched"]) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	print("PASS Q: Second blueprint waits for own complete materials before dispatch")

	assert(stage_b.receive_item(ingot, 2) == 2)
	assert(int(driver.tick(0.25, false)["dispatched"]) == 1)
	assert(drone.is_bound_to_site(second))
	assert(not drone.is_bound_to_site(first))
	assert(second.job.state == ConstructionJob.State.QUEUED)
	print("PASS R: Recharged worker launches to second site without old ownership")

	assert(int(driver.tick(5.0, false)["advanced"]) == 1)
	assert(second.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(second.job.get_progress(), 0.5))
	assert(int(driver.tick(5.0, false)["advanced"]) == 1)
	assert(second.job.state == ConstructionJob.State.COMPLETE)
	assert(second.is_completed())
	assert(escrow.held_count() == 0)
	assert(second.job.get_progress() == 1.0)
	print("PASS S: Second job requires fresh escrow and drone arrival, then completes")

	# A completed job emits no cancellation signal. The first tick marks
	# RETURNING; the following tick physically moves the worker to its dock.
	assert(int(driver.tick(0.1, false)["recycled"]) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(int(driver.tick(5.0, false)["recycled"]) == 0)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(int(driver.tick(10.0, true)["recycled"]) == 1)
	assert(drone.completed_rearms() == 2)
	assert(fleet.idle_count() == 1)
	assert(warehouse.get_amount(ingot) == 9)
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(recovery.get_amount(ingot) == 3)
	assert(stage_b.get_staged_inventory().get_amount(ingot) == 0)
	assert(registry.claim_count() == 2)
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	main.free()
	sandbox.free()
	print("PASS T: Both cycles conserve materials; no unauthorized sites or playable integration")

	print("ALL 20 E3D5C4Z CONTROLLED DRONE LIFECYCLE TICK TESTS PASSED")
	print("TEST ONLY: Explicit ticks and manual power flags; no live factory automation, navigation or saving.")
