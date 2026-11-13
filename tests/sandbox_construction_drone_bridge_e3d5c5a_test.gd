extends Node3D

# E3d5c5a — First sandbox mount of E3d5c4z lifecycle; explicit test-only
# bridge never runs autonomously or while debug readiness bypass is active.

func _ready() -> void:
	call_deferred("_checks")


func _site(sandbox: Node3D, definition: BuildingDefinition,
	label: String, at: Vector3
) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	sandbox.add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _power(sandbox: Node3D, path: String, at: Vector3) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var building := packed.instantiate() as PrototypePowerStructure
	assert(building != null)
	sandbox.add_child(building)
	building.global_position = at
	return building


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var standalone := SandboxConstructionDroneLifecycleGate.new()
	add_child(standalone)
	assert(not standalone.enable_isolated_bridge)
	assert(not standalone.has_bound_driver())
	assert(standalone.tick_once(1.0).is_empty())
	print("PASS A: New lifecycle bridge defaults OFF, no automatic work")

	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate() as Node3D
	var sandbox_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(main != null and sandbox_scene != null)
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	assert(main.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	main.free()
	print("PASS B: Main gameplay has no drone lifecycle gate or controller")

	var default_sandbox := sandbox_scene.instantiate() as Node3D
	var dormant := default_sandbox.get_node(
		"ConstructionDroneLifecycleGate"
	) as SandboxConstructionDroneLifecycleGate
	assert(dormant != null)
	assert(not dormant.enable_isolated_bridge)
	assert(default_sandbox.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	assert(bool(default_sandbox.get_node("WorldInteraction").get(
		"blueprint_sandbox_debug_requirements"
	)))
	print("PASS C: Committed sandbox mounts one dormant gate; debug bypass stays ON")

	add_child(default_sandbox)
	assert(dormant.tick_once(1.0).is_empty())
	assert(not dormant.has_bound_driver())
	dormant.enable_isolated_bridge = true
	assert(dormant.tick_once(1.0).is_empty())
	assert(not dormant.bind_verified_driver(null))
	default_sandbox.free()
	print("PASS D: Toggling bridge ON with legacy debug bypass cannot activate it")

	var sandbox := sandbox_scene.instantiate() as Node3D
	var gate := sandbox.get_node(
		"ConstructionDroneLifecycleGate"
	) as SandboxConstructionDroneLifecycleGate
	var world: Node = sandbox.get_node("WorldInteraction")
	# Only THIS test instance opts into the new verified-construction path.
	world.set("blueprint_sandbox_debug_requirements", false)
	gate.enable_isolated_bridge = true
	add_child(sandbox)
	assert(sandbox.is_inside_tree())
	assert(not gate.has_bound_driver())
	assert(gate.tick_once(1.0).is_empty())
	assert(sandbox.get_node_or_null("ConstructionRequirementsFeatureGate") != null)
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	print("PASS E: Isolated sandbox instance disables debug override, retains UI")

	var first := _site(sandbox, definition, "VerifiedStorageSite", Vector3(6, 0, 0))
	var planned := _site(sandbox, definition, "UnauthorizedSite", Vector3(-6, 0, 0))
	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(planned.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	assert(gate.tick_once(0.5).is_empty())
	print("PASS F: High priority does not authorize either sandbox blueprint")

	assert(world.call("_authorize_blueprint_site", first))
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_wait_reasons().has(&"power"))
	assert(first.job.get_wait_reasons().has(&"materials"))
	assert(first.job.get_wait_reasons().has(&"workers"))
	assert(first.job.get_progress() == 0.0)
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	print("PASS G: Existing E-style sandbox authorization no longer fakes readiness")

	var source := InventoryComponent.new()
	source.max_capacity = 6
	sandbox.add_child(source)
	assert(source.add_item(ingot, 3) == 3)
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	sandbox.add_child(staging)
	assert(staging.configure(source, definition, 3))
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	var receiver := Node3D.new()
	sandbox.add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.enable_isolated_input = true
	port.show_port_label = false
	receiver.add_child(port)
	assert(port.attach_to_authorized_site(first, staging, registry))
	assert(registry.inventory_for_site(first) == staging.get_staged_inventory())
	assert(registry.claim_count() == 1)
	print("PASS H: Sandbox job receives unique test-only material ownership")

	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	var fleet := PrototypeConstructionDroneFleet.new()
	var driver := PrototypeConstructionDroneTickController.new()
	for service: Node in [
		queue, scheduler, escrow, network, power, coordinator, fleet, driver
	]:
		sandbox.add_child(service)
	assert(power.configure(network))
	var hub := _power(sandbox, "res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO)
	var pole := _power(sandbox, "res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0))
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	print("PASS I: Prototype generator and pole are independently linked in sandbox")

	var warehouse := InventoryComponent.new()
	warehouse.max_capacity = 15
	sandbox.add_child(warehouse)
	assert(warehouse.add_item(ingot, 9) == 9)
	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.configure(queue, scheduler, escrow, power, warehouse, 1))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(coordinator.track_site(first, 7))
	fleet.enable_isolated_fleet = true
	fleet.enable_isolated_reuse = true
	assert(fleet.configure(queue, scheduler, 2.0, 2.0))
	print("PASS J: Owned escrow, one worker slot and fleet configured separately")

	var drone := PrototypeConstructionWorkerDrone.new()
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	drone.enable_isolated_reuse = true
	sandbox.add_child(drone)
	assert(drone.configure_battery(40.0, 20.0, 1.0, 4.0))
	assert(fleet.register_drone(drone))
	assert(not gate.bind_verified_driver(driver))
	assert(gate.tick_once(1.0).is_empty())
	assert(escrow.held_count() == 0)
	print("PASS K: Sandbox gate refuses unconfigured driver, even with a drone")

	driver.enable_isolated_ticks = true
	assert(driver.configure(fleet, coordinator, scheduler, escrow))
	assert(driver.has_verified_services())
	assert(gate.bind_verified_driver(driver))
	assert(gate.has_bound_driver())
	assert(not gate.bind_verified_driver(driver))
	assert(gate.tick_once(0.0).is_empty())
	assert(gate.tick_once(INF).is_empty())
	print("PASS L: Sandbox binds exactly one verified driver; invalid ticks fail")

	var wrong_driver := PrototypeConstructionDroneTickController.new()
	add_child(wrong_driver)
	assert(not gate.bind_verified_driver(wrong_driver))
	var no_stock: Dictionary = gate.tick_once(0.5)
	assert(int(no_stock["dispatched"]) == 0)
	assert(int(no_stock["advanced"]) == 0)
	assert(warehouse.get_amount(ingot) == 9)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS M: No staged materials, no flight, no debit from other inventory")

	assert(staging.receive_item(ingot, 2) == 2)
	var partial: Dictionary = gate.tick_once(0.5)
	assert(int(partial["dispatched"]) == 0)
	assert(escrow.held_count() == 0)
	assert(first.job.get_progress() == 0.0)
	print("PASS N: Partial staged bill cannot dispatch an actual sandbox drone")

	assert(staging.receive_item(ingot, 1) == 1)
	var launched: Dictionary = gate.tick_once(0.25)
	assert(int(launched["dispatched"]) == 1)
	assert(int(launched["advanced"]) == 0)
	assert(escrow.held_count() == 1)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS O: Full owned escrow and generator launch exactly one drone")

	assert(int(gate.tick_once(1.0)["advanced"]) == 0)
	assert(not drone.is_at_site())
	assert(first.job.get_progress() == 0.0)
	print("PASS P: Flying drone cannot start sandbox construction in transit")

	var active: Dictionary = gate.tick_once(5.0)
	assert(int(active["advanced"]) == 1)
	assert(drone.is_at_site())
	assert(first.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(first.job.get_progress(), 0.5))
	print("PASS Q: Arrival enables job advancement only with verified services")

	assert(hub.set_generator_enabled(false))
	assert(int(gate.tick_once(1.0)["advanced"]) == 0)
	assert(first.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(first.job.get_progress(), 0.5))
	assert(escrow.held_count() == 1)
	print("PASS R: Power loss pauses sandbox drone job without losing escrow")

	assert(hub.set_generator_enabled(true))
	assert(int(gate.tick_once(5.0)["advanced"]) == 1)
	assert(first.job.state == ConstructionJob.State.COMPLETE)
	assert(first.is_completed())
	assert(escrow.held_count() == 0)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS S: Restored power commits site-owned bill on one completed build")

	world.set("blueprint_sandbox_debug_requirements", true)
	assert(not gate.has_bound_driver())
	assert(gate.tick_once(1.0).is_empty())
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	assert(drone.battery_units() < drone.battery_capacity())
	world.set("blueprint_sandbox_debug_requirements", false)
	gate.enable_isolated_bridge = false
	assert(gate.tick_once(1.0).is_empty())
	assert(not gate.has_bound_driver())
	assert(registry.claim_count() == 1)
	assert(warehouse.get_amount(ingot) == 9)
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	assert(sandbox.get_node_or_null("ConstructionAuthorizationDock") != null)
	print("PASS T: Legacy debug or bridge opt-out stops ticks; UI and claims stay intact")

	print("ALL 20 E3D5C5A SANDBOX DRONE BRIDGE TESTS PASSED")
	print("TEST ONLY: One explicit sandbox tick bridge; no live per-frame automation, real dock wattage or save.")
