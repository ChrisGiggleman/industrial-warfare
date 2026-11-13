extends Node3D

# =============================================================================
# E3D5C4W — TWO PHYSICAL DRONES / THREE AUTHORIZED SITES, ONE-SHOT FLEET
# =============================================================================
# Drills explicit queue dispatch, strict priority order, exclusive ownership,
# finite drone capacity, multi-site readiness, movement loss and power outages.
# Materials use separate test staging buffers, not conveyor delivery here.
# Main/Factory Testing Sandbox and gameplay work remain unchanged.

func _ready() -> void:
	call_deferred("_run_checks")


func _site(definition: BuildingDefinition, label: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _station(
	path: String, at: Vector3
) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var station := packed.instantiate() as PrototypePowerStructure
	assert(station != null)
	add_child(station)
	station.global_position = at
	return station


func _staging(
	site: ConstructionSite,
	definition: BuildingDefinition,
	item: ItemDefinition,
	registry: BlueprintConstructionSiteStagingRegistry
) -> BlueprintConstructionMaterialStaging:
	var supply := InventoryComponent.new()
	supply.max_capacity = 6
	add_child(supply)
	assert(supply.add_item(item, 3) == 3)
	var stage := BlueprintConstructionMaterialStaging.new()
	stage.enable_isolated_staging = true
	add_child(stage)
	assert(stage.configure(supply, definition, 3))
	var receiver_root := Node3D.new()
	add_child(receiver_root)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.enable_isolated_input = true
	port.show_port_label = false
	receiver_root.add_child(port)
	assert(port.attach_to_authorized_site(site, stage, registry))
	assert(registry.inventory_for_site(site) == stage.get_staged_inventory())
	return stage


func _drone(at: Vector3) -> PrototypeConstructionWorkerDrone:
	var drone := PrototypeConstructionWorkerDrone.new()
	drone.enable_isolated_drone = true
	add_child(drone)
	drone.global_position = at
	return drone


func _run_checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	assert(int(ConstructionMaterialBill.get_costs(definition).get(ingot, 0)) == 3)
	var fleet := PrototypeConstructionDroneFleet.new()
	add_child(fleet)
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	add_child(queue)
	add_child(scheduler)
	assert(not fleet.enable_isolated_fleet)
	assert(not fleet.configure(queue, scheduler, 2.0, 2.0))
	assert(fleet.dispatch_waiting() == 0)
	print("PASS A: Fleet defaults OFF with no ability to launch or grant readiness")

	var low := _site(definition, "LowSite", Vector3(6, 0, 1))
	var normal := _site(definition, "NormalSite", Vector3(6, 0, 0))
	var high := _site(definition, "HighSite", Vector3(6, 0, -1))
	var unapproved := _site(definition, "NeverAuthorized", Vector3(-6, 0, 0))
	assert(low.job.set_priority(ConstructionJob.Priority.LOW))
	assert(high.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(unapproved.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(fleet.dispatch_waiting() == 0)
	for site: ConstructionSite in [low, normal, high, unapproved]:
		assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Priority changes never authorize any of the four plans")

	assert(low.job.authorize())
	assert(normal.job.authorize())
	assert(high.job.authorize())
	assert(unapproved.job.state == ConstructionJob.State.PLANNED)
	assert(queue.get_waiting_count() == 0)
	assert(fleet.dispatch_waiting() == 0)
	print("PASS C: E-style authorization makes exactly three QUEUED, not yet dispatched")

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)
	var low_stage := _staging(low, definition, ingot, registry)
	var normal_stage := _staging(normal, definition, ingot, registry)
	var high_stage := _staging(high, definition, ingot, registry)
	assert(registry.claim_count() == 3)
	assert(registry.inventory_for_site(low) != registry.inventory_for_site(normal))
	assert(registry.inventory_for_site(normal) != registry.inventory_for_site(high))
	assert(not registry.inventory_for_site(unapproved))
	print("PASS D: Three authorized sites exclusively own distinct staged material claims")

	var warehouse := InventoryComponent.new()
	warehouse.max_capacity = 20
	add_child(warehouse)
	assert(warehouse.add_item(ingot, 9) == 9)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	for service: Node in [escrow, network, power, coordinator]:
		add_child(service)
	assert(power.configure(network))
	var hub := _station(
		"res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO
	)
	var pole := _station(
		"res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0)
	)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.configure(queue, scheduler, escrow, power, warehouse, 2))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	print("PASS E: Site-owned escrow, finite 12-unit power and two scheduler slots exist")

	# Intentionally register in reverse priority to prove ordering.
	assert(coordinator.track_site(low, 5))
	assert(coordinator.track_site(normal, 5))
	assert(coordinator.track_site(high, 5))
	assert(queue.get_waiting_sites() == [high, normal, low])
	assert(not coordinator.track_site(unapproved, 5))
	assert(not scheduler.is_tracking_site(unapproved))
	print("PASS F: Waiting queue orders High, Normal, Low independently of admission order")

	fleet.enable_isolated_fleet = true
	assert(not fleet.configure(queue, scheduler, 0.0, 2.0))
	assert(not fleet.configure(queue, scheduler, 2.0, 0.0))
	assert(fleet.configure(queue, scheduler, 2.0, 2.0))
	assert(not fleet.configure(queue, scheduler, 2.0, 2.0))
	assert(fleet.dispatch_waiting() == 0)
	print("PASS G: One-time explicit fleet configuration rejects invalid settings")

	var worker_a := _drone(Vector3(0, 0, -2))
	var worker_b := _drone(Vector3(0, 0, 2))
	var spare := _drone(Vector3(0, 0, 4))
	assert(fleet.register_drone(worker_a))
	assert(not fleet.register_drone(worker_a))
	assert(fleet.register_drone(worker_b))
	assert(not fleet.register_drone(spare))
	assert(fleet.registered_count() == 2)
	assert(fleet.idle_count() == 2)
	print("PASS H: Exactly two unique physical workers register, third refused by capacity")

	assert(fleet.dispatch_waiting() == 2)
	assert(fleet.get_drone_for_site(high) == worker_a)
	assert(fleet.get_drone_for_site(normal) == worker_b)
	assert(fleet.get_drone_for_site(low) == null)
	assert(fleet.get_drone_for_site(unapproved) == null)
	assert(fleet.assigned_count() == 2 and fleet.idle_count() == 0)
	print("PASS I: Explicit dispatch gives first drone High and second Normal")

	assert(fleet.dispatch_waiting() == 0)
	assert(worker_a.is_bound_to_site(high) and worker_b.is_bound_to_site(normal))
	assert(not worker_a.is_bound_to_site(low))
	assert(not worker_b.is_at_site() and not worker_a.is_at_site())
	assert(scheduler.get_active_count() == 0)
	print("PASS J: Fleet assignments are exclusive and traveling alone grants no slots")

	for stage: BlueprintConstructionMaterialStaging in [high_stage, normal_stage, low_stage]:
		assert(stage.receive_item(ingot, 3) == 3)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 3)
	assert(scheduler.get_active_count() == 0)
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(normal.job.state == ConstructionJob.State.QUEUED)
	assert(low.job.state == ConstructionJob.State.QUEUED)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS K: All three owned bills escrow but flying drones start no work")

	var high_status: Dictionary = coordinator.get_status(high)
	var normal_status: Dictionary = coordinator.get_status(normal)
	var low_status: Dictionary = coordinator.get_status(low)
	assert(bool(high_status["power_allocated"]))
	assert(bool(normal_status["power_allocated"]))
	assert(not bool(low_status["power_allocated"]))
	assert(not bool(low_status["worker_active"]))
	print("PASS L: Finite prototype power serves High + Normal; Low waits without borrowing")

	assert(worker_a.advance_flight(10.0))
	assert(worker_a.is_at_site())
	assert(not worker_b.is_at_site())
	assert(coordinator.reconcile() == 1)
	assert(high.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(normal.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.get_active_count() == 1)
	print("PASS M: First arrived drone starts only High, despite Normal's escrow and power")

	assert(worker_b.advance_flight(10.0))
	assert(worker_b.is_at_site())
	assert(coordinator.reconcile() == 1)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(low.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.get_active_count() == 2)
	print("PASS N: Second physical arrival starts Normal; low remains waiting")

	high.job.advance(2.0)
	assert(is_equal_approx(high.job.get_progress(), 0.2))
	assert(normal.job.get_progress() == 0.0)
	assert(low.job.get_progress() == 0.0)
	assert(not high.job.set_priority(ConstructionJob.Priority.LOW))
	print("PASS O: Only worker-present construction advances; running High is non-preemptive")

	var original: Vector3 = high.global_position
	high.global_position += Vector3(1, 0, 0)
	assert(not worker_a.is_at_site())
	assert(coordinator.reconcile() == 0)
	assert(high.job.state == ConstructionJob.State.PAUSED)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1)
	high.job.advance(30.0)
	assert(is_equal_approx(high.job.get_progress(), 0.2))
	print("PASS P: Drone displaced from site pauses only its job, retaining escrow and progress")

	assert(worker_a.advance_flight(0.1))
	assert(not worker_a.is_at_site())
	assert(worker_a.advance_flight(10.0))
	assert(worker_a.is_at_site())
	assert(coordinator.reconcile() == 1)
	assert(high.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(high.job.get_progress(), 0.2))
	assert(original != high.global_position)
	print("PASS Q: Drone physically reacquires moved blueprint before work resumes")

	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0)
	assert(high.job.state == ConstructionJob.State.PAUSED)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.held_count() == 3)
	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 2)
	assert(high.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS R: Outage pauses both drones' jobs; restored power resumes without loss")

	assert(normal.job.cancel())
	assert(worker_b.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(coordinator.reconcile() == 0)
	assert(normal_stage.get_staged_inventory().get_amount(ingot) == 3)
	assert(high.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(low.job.state == ConstructionJob.State.QUEUED)
	assert(registry.claim_count() == 3)
	assert(fleet.dispatch_waiting() == 0)
	assert(worker_b.advance_flight(10.0))
	assert(worker_b.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	print("PASS S: Cancellation refunds Normal, returns drone, never reassigns retired worker")

	high.job.advance(8.0)
	assert(high.job.state == ConstructionJob.State.COMPLETE)
	assert(high.is_completed())
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(high) == 0)
	assert(worker_a.advance_flight(0.1) == false or worker_a.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(worker_a.advance_flight(10.0))
	assert(worker_a.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(fleet.dispatch_waiting() == 0)
	assert(low.job.state == ConstructionJob.State.QUEUED)
	print("PASS T: High completes and worker docks; Low cannot inherit one-shot drones")

	assert(low.job.cancel())
	assert(escrow.held_count() == 0)
	assert(low_stage.get_staged_inventory().get_amount(ingot) == 3)
	assert(high_stage.get_staged_inventory().get_total_amount() == 0)
	assert(normal_stage.get_staged_inventory().get_amount(ingot) == 3)
	assert(warehouse.get_amount(ingot) == 9)
	assert(fleet.assigned_count() == 2)
	assert(fleet.idle_count() == 0)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("PrototypeConstructionDroneFleet") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneFleet") == null)
	assert(main.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	main.free()
	sandbox.free()
	print("PASS U: Three bills conserved, original nine warehouse ingots untouched, scenes opt out")

	print("ALL 21 E3D5C4W PHYSICAL CONSTRUCTION FLEET TESTS PASSED")
	print("TEST ONLY: Two one-shot drones, explicit dispatch, prototype power; no live fleet reuse or charging.")
