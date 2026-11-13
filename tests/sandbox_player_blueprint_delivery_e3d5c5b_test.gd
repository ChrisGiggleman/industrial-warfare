extends Node3D

# E3d5c5b — player placement + actual factory belt + owned drone readiness.
# Explicit, test-only sandbox bridge. In-game factory stays debug-mode ON.
# Four ingots are test-seeded; source-to-receiver transport is REAL and timed.

func _ready() -> void:
	call_deferred("_checks")


func _power(
	sandbox: Node3D, path: String, at: Vector3
) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var building := packed.instantiate() as PrototypePowerStructure
	assert(building != null)
	sandbox.add_child(building)
	building.global_position = at
	return building


func _deliver(
	timer: ConveyorTransportTimer,
	transport: ConveyorTransportComponent,
	ingot: ItemDefinition
) -> void:
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(0.4))
	assert(timer.advance_transport(0.61))
	assert(transport.get_held_item() == null)


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var standalone := SandboxConstructionDroneLifecycleGate.new()
	add_child(standalone)
	assert(not standalone.enable_isolated_bridge)
	assert(standalone.tick_once(1.0).is_empty())
	assert(standalone.attach_player_site_receiver(null, null, null) == null)
	print("PASS A: New receiver-admission API defaults OFF and has no authority")

	var packed := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	assert(sandbox != null)
	var world: Node = sandbox.get_node("WorldInteraction")
	var gate := sandbox.get_node("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	assert(gate != null and not gate.enable_isolated_bridge)
	assert(bool(world.get("blueprint_sandbox_debug_requirements")))
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	print("PASS B: Normal Factory Testing Sandbox retains debug mode and dormant bridge")

	gate.enable_isolated_bridge = true
	add_child(sandbox)
	world.set_process(false)
	assert(gate.attach_player_site_receiver(null, null, null) == null)
	assert(not gate.has_bound_driver())
	assert(gate.tick_once(1.0).is_empty())
	print("PASS C: Debug bypass blocks receiver binding even with feature ON")

	world.set("blueprint_sandbox_debug_requirements", false)
	assert(world.get("enable_blueprint_planning"))
	var placement := Transform3D(
		Basis(Vector3.UP, deg_to_rad(90.0)), Vector3(-5.0, 0.0, 2.0)
	)
	assert(world.call("_blueprint_placement_clear", definition, placement))
	var site := world.call("_create_blueprint_site", definition, placement) as ConstructionSite
	assert(site != null and site.get_parent() == sandbox)
	site.set_process(false)
	assert(site.global_transform.is_equal_approx(placement))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.get_planned_port_named(&"InputPort") != null)
	print("PASS D: Real WorldInteraction placement creates snapped Storage blueprint")

	assert(world.call("_is_managed_blueprint", site))
	assert(not world.call("_blueprint_placement_clear", definition, placement))
	assert(world.call("_create_blueprint_site", definition, placement) == null)
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS E: Existing overlap check and high priority cannot authorize construction")

	var source := Node3D.new()
	source.name = "FixtureSupplier"
	sandbox.add_child(source)
	var supply := InventoryComponent.new()
	supply.max_capacity = 10
	source.add_child(supply)
	assert(supply.add_item(ingot, 4) == 4)
	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.show_port_label = false
	output.inventory = supply
	source.add_child(output)
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	sandbox.add_child(staging)
	assert(staging.configure(supply, definition, 3))
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	assert(gate.attach_player_site_receiver(site, staging, registry) == null)
	assert(registry.claim_count() == 0)
	print("PASS F: Unapproved player plan cannot claim construction inputs")

	assert(world.call("_authorize_blueprint_site", site))
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_wait_reasons().size() == 3)
	assert(site.job.get_progress() == 0.0)
	print("PASS G: Existing E-style authorization leaves verified requirements pending")

	var foreign := ConstructionSite.new()
	assert(foreign.setup_with_definition_job(definition))
	add_child(foreign)
	foreign.set_process(false)
	assert(foreign.job.authorize())
	assert(gate.attach_player_site_receiver(foreign, staging, registry) == null)
	assert(registry.claim_count() == 0)
	print("PASS H: Gate refuses foreign authorized sites outside its sandbox")

	var port := gate.attach_player_site_receiver(site, staging, registry)
	assert(port != null and port.matches_attached_site())
	assert(not site.is_ancestor_of(port))
	assert(port.get_parent().get_parent() == sandbox)
	assert(registry.inventory_for_site(site) == staging.get_staged_inventory())
	assert(port.global_transform.is_equal_approx(
		site.get_planned_port_named(&"InputPort").global_transform
	))
	print("PASS I: Real player blueprint owns distinct anchored receiver and buffer")

	assert(gate.attach_player_site_receiver(site, staging, registry) == null)
	assert(registry.claim_count() == 1)
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(ore != null and not port.can_accept_item(ore))
	print("PASS J: Repeat ownership and incorrect material types are refused")

	var belt_packed := load("res://scenes/logistics/conveyor_straight.tscn") as PackedScene
	assert(belt_packed != null)
	var belt := belt_packed.instantiate() as ConveyorSegment
	assert(belt != null)
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	assert(timer != null and transport != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	var endpoint := belt.get_node("InputEndpoint") as Marker3D
	assert(endpoint != null)
	source.global_transform = Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		output, endpoint, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(output))
	assert(belt.output_building_port == port and belt.input_building_port == output)
	print("PASS K: Real connected conveyor and supplier attach to player blueprint")

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
	var hub := _power(sandbox, "res://scenes/buildings/prototype_main_hub.tscn",
		site.global_position + Vector3(-6, 0, 0))
	var pole := _power(sandbox, "res://scenes/buildings/prototype_power_pole.tscn",
		site.global_position)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	var warehouse := InventoryComponent.new()
	warehouse.max_capacity = 15
	sandbox.add_child(warehouse)
	assert(warehouse.add_item(ingot, 9) == 9)
	scheduler.enable_isolated_drone_presence = true
	assert(coordinator.configure(queue, scheduler, escrow, power, warehouse, 1))
	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(coordinator.track_site(site, 7))
	fleet.enable_isolated_fleet = true
	assert(fleet.configure(queue, scheduler, 2.0, 2.0))
	var drone := PrototypeConstructionWorkerDrone.new()
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	sandbox.add_child(drone)
	assert(drone.configure_battery(40.0, 20.0, 1.0, 4.0))
	assert(fleet.register_drone(drone))
	driver.enable_isolated_ticks = true
	assert(driver.configure(fleet, coordinator, scheduler, escrow))
	assert(gate.bind_verified_driver(driver))
	print("PASS L: Verified owner, finite power and physical drone are separately configured")

	assert(int(gate.tick_once(0.5)["dispatched"]) == 0)
	assert(escrow.held_count() == 0 and site.job.get_progress() == 0.0)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS M: Disconnected shared warehouse cannot dispatch an empty construction receiver")

	_deliver(timer, transport, ingot)
	assert(staging.get_staged_inventory().get_amount(ingot) == 1)
	assert(int(gate.tick_once(0.5)["dispatched"]) == 0)
	print("PASS N: First physically carried ingot leaves the authorized job waiting")

	_deliver(timer, transport, ingot)
	assert(staging.get_staged_inventory().get_amount(ingot) == 2)
	assert(int(gate.tick_once(0.5)["dispatched"]) == 0)
	print("PASS O: Second physical delivery cannot start an underfunded blueprint")

	_deliver(timer, transport, ingot)
	assert(staging.get_staged_inventory().get_amount(ingot) == 3)
	assert(timer.successful_transfers == 3)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS P: Third physical delivery fills site buffer without bypassing authorization")

	var launch: Dictionary = gate.tick_once(0.25)
	assert(int(launch["dispatched"]) == 1)
	assert(int(launch["advanced"]) == 0)
	assert(escrow.held_count() == 1)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(warehouse.get_amount(ingot) == 9)
	print("PASS Q: Owned escrow and power dispatch a drone, but flight does not start work")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	assert(int(gate.tick_once(5.0)["advanced"]) == 1)
	assert(drone.is_at_site())
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(site.job.get_progress(), 0.5))
	assert(not port.can_accept_item(ingot))
	print("PASS R: Arrived drone advances real player plan; extra belt cargo stays blocked")

	assert(hub.set_generator_enabled(false))
	assert(int(gate.tick_once(1.0)["advanced"]) == 0)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(escrow.held_count() == 1)
	assert(is_equal_approx(site.job.get_progress(), 0.5))
	assert(hub.set_generator_enabled(true))
	assert(int(gate.tick_once(5.0)["advanced"]) == 1)
	assert(site.job.state == ConstructionJob.State.COMPLETE)
	assert(site.is_completed())
	assert(escrow.held_count() == 0)
	print("PASS S: Power loss and recovery finish one player-placed Storage with exact escrow")

	var recovery := InventoryComponent.new()
	sandbox.add_child(recovery)
	assert(transport.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.get_amount(ingot) == 1)
	assert(supply.get_amount(ingot) == 0)
	assert(staging.get_staged_inventory().get_amount(ingot) == 0)
	assert(warehouse.get_amount(ingot) == 9)
	assert(registry.claim_count() == 1)
	assert(not port.can_accept_item(ingot))
	assert(gate.attach_player_site_receiver(site, staging, registry) == null)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	main.free()
	print("PASS T: Three ingots built plus one recovered; Main and old claims unchanged")

	print("ALL 20 E3D5C5B PLAYER BLUEPRINT BELT DELIVERY TESTS PASSED")
	print("TEST ONLY: Physical belt with seeded factory stock; no automatic placement wiring, grid draw, nav or save.")
