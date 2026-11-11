extends Node3D

# =============================================================================
# E3D5C3C1 — ISOLATED MATERIAL / POWER / WORKER COORDINATOR
# =============================================================================
# No physical drones, real-world fuel or game-scene integration.
# Every job is manually time-stepped to avoid false-positive build progress.

func _site(label: String, at: Vector3) -> ConstructionSite:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(is_instance_valid(definition))
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _structure(path: String, label: String, at: Vector3) -> PrototypePowerStructure:
	var scene := load(path) as PackedScene
	assert(is_instance_valid(scene))
	var building := scene.instantiate() as PrototypePowerStructure
	assert(is_instance_valid(building))
	building.name = label
	add_child(building)
	building.global_position = at
	return building


func _ready() -> void:
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	add_child(coordinator)
	assert(coordinator.reconcile() == 0)
	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var stock := InventoryComponent.new()
	add_child(queue)
	add_child(scheduler)
	add_child(escrow)
	add_child(network)
	add_child(power)
	add_child(stock)
	assert(not coordinator.configure(queue, scheduler, escrow, null, stock, 1))
	print("PASS A: Missing power allocator fails closed before registration")

	assert(power.configure(network))
	var hub: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_main_hub.tscn",
		"CompletedHub", Vector3.ZERO
	)
	var pole: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_power_pole.tscn",
		"CompletedPole", Vector3(6, 0, 0)
	)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	print("PASS B: Completed generator and explicit relay produce prototype coverage")

	assert(coordinator.configure(queue, scheduler, escrow, power, stock, 1))
	assert(not coordinator.configure(queue, scheduler, escrow, power, stock, 2))
	assert(scheduler.capacity == 1)
	print("PASS C: Coordinator owns exactly one bounded worker scheduler")

	var planned: ConstructionSite = _site("Unapproved", Vector3(6, 0, 0))
	assert(not coordinator.track_site(planned, 7))
	assert(planned.job.authorize())
	assert(not coordinator.track_site(planned, 0))
	assert(not coordinator.track_site(planned, -1))
	assert(not coordinator.track_site(planned, 100001))
	assert(not bool(coordinator.get_status(planned)["tracked"]))
	var bypass_definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var debug_bypass := ConstructionSite.new()
	assert(debug_bypass.setup_with_definition_job(
		bypass_definition, false, true, true
	))
	add_child(debug_bypass)
	debug_bypass.set_process(false)
	assert(debug_bypass.job.authorize())
	assert(debug_bypass.job.state == ConstructionJob.State.QUEUED)
	assert(not coordinator.track_site(debug_bypass, 7))
	print("PASS D: Unapproved, invalid-demand and power-bypass jobs are rejected")

	var low: ConstructionSite = _site("LowPriority", Vector3(6, 0, 0))
	assert(low.job.set_priority(ConstructionJob.Priority.LOW))
	assert(low.job.authorize())
	assert(coordinator.track_site(low, 7))
	var normal: ConstructionSite = _site("NormalPriority", Vector3(6, 0, 0))
	assert(normal.job.authorize())
	assert(coordinator.track_site(normal, 7))
	assert(coordinator.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.held_count() == 0)
	assert(low.job.state == ConstructionJob.State.QUEUED)
	assert(normal.job.state == ConstructionJob.State.QUEUED)
	print("PASS E: Without delivered inventory no job can receive power or workers")

	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(is_instance_valid(ingot))
	assert(stock.add_item(ingot, 3) == 3)
	assert(coordinator.reconcile() == 1)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(low.job.state == ConstructionJob.State.QUEUED)
	assert(stock.get_amount(ingot) == 0)
	assert(escrow.reservation_for(normal) > 0)
	assert(escrow.reservation_for(low) == 0)
	print("PASS F: Normal receives scarce materials before earlier Low priority")

	assert(not coordinator.track_site(normal, 7))
	assert(scheduler.get_active_count() == 1)
	assert(normal.job.get_progress() == 0.0)
	var active_status: Dictionary = coordinator.get_status(normal)
	assert(bool(active_status["materials_reserved"]))
	assert(bool(active_status["power_allocated"]))
	assert(bool(active_status["worker_active"]))
	print("PASS G: Real escrow, bounded power and worker slot all agree")

	var blocked: Dictionary = coordinator.get_status(low)
	assert(bool(blocked["tracked"]))
	assert(not bool(blocked["materials_reserved"]))
	assert(not bool(blocked["power_allocated"]))
	assert(not bool(blocked["worker_active"]))
	assert(low.job.get_wait_reasons().has(&"materials"))
	print("PASS H: Unreserved lower-priority job cannot occupy the power budget")

	assert(stock.add_item(ingot, 3) == 3)
	var urgent: ConstructionSite = _site("NewHigh", Vector3(6, 0, 0))
	assert(urgent.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(urgent.job.authorize())
	assert(coordinator.track_site(urgent, 7))
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(urgent) > 0)
	assert(stock.get_amount(ingot) == 0)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(urgent.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.get_active_count() == 1)
	print("PASS I: New High cannot interrupt already constructing Normal work")

	normal.job.advance(2.0)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	assert(urgent.job.get_progress() == 0.0)
	assert(low.job.get_progress() == 0.0)
	print("PASS J: Time advances only on a job with all three real gates")

	assert(hub.set_generator_enabled(false))
	assert(coordinator.reconcile() == 0)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.reservation_for(normal) > 0)
	assert(escrow.reservation_for(urgent) > 0)
	print("PASS K: Generator outage pauses active work but retains both escrows")

	normal.job.advance(100.0)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	assert(not bool(coordinator.get_status(normal)["power_allocated"]))
	assert(not bool(coordinator.get_status(normal)["worker_active"]))
	print("PASS L: Power-outage pause retains progress with zero phantom work")

	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	assert(urgent.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	assert(scheduler.get_active_count() == 1)
	print("PASS M: Restored power dispatches waiting High ahead of paused Normal")

	assert(urgent.job.cancel())
	assert(stock.get_amount(ingot) == 3)
	assert(coordinator.reconcile() == 1)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(normal.job.get_progress(), 0.2))
	assert(escrow.reservation_for(low) > 0)
	assert(stock.get_amount(ingot) == 0)
	print("PASS N: High cancellation refunds inventory; paused Normal safely resumes")

	var normal_id: int = escrow.reservation_for(normal)
	assert(normal_id > 0)
	normal.job.advance(8.0)
	assert(normal.job.state == ConstructionJob.State.COMPLETE)
	assert(normal.is_completed())
	assert(not escrow.has_reservation(normal_id))
	assert(stock.get_amount(ingot) == 0)
	print("PASS O: Timed building completion commits its reserved cost once")

	assert(coordinator.reconcile() == 1)
	assert(low.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_count() == 1)
	assert(low.job.get_progress() == 0.0)
	assert(escrow.held_count() == 1)
	print("PASS P: Finishing a job frees its worker slot for the waiting Low")

	low.job.advance(10.0)
	assert(low.job.state == ConstructionJob.State.COMPLETE)
	assert(low.is_completed())
	assert(coordinator.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.held_count() == 0)
	assert(stock.get_amount(ingot) == 0)
	print("PASS Q: Both buildings finish without duplicated items or workers")

	assert(hub.set_generator_enabled(false))
	assert(stock.add_item(ingot, 3) == 3)
	var offline: ConstructionSite = _site("OfflineQueue", Vector3(6, 0, 0))
	assert(offline.job.authorize())
	assert(coordinator.track_site(offline, 7))
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(offline) > 0)
	assert(offline.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.get_active_count() == 0)
	assert(hub.set_generator_enabled(true))
	assert(coordinator.reconcile() == 1)
	assert(offline.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(offline.job.cancel())
	assert(stock.get_amount(ingot) == 3)
	assert(coordinator.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(escrow.held_count() == 0)
	print("PASS R: Offline jobs wait; restored work and cancellation stay lossless")

	print("ALL 18 E3D5C3C1 CONSTRUCTION READINESS COORDINATOR TESTS PASSED")
