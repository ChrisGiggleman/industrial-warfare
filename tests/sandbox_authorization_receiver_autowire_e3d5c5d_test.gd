extends Node3D

# =============================================================================
# E3d5c5d — MANAGED PLAYER AUTHORIZATION SIGNAL -> PROTECTED RECEIVER
# =============================================================================
# Isolated F6 proof of opt-in event-driven construction intake installation.
# Uses actual WorldInteraction site placement, authorization and physical
# belt transport. No automatic stock creation, worker dispatch or world save.

func _ready() -> void:
	call_deferred("_checks")


func _placed(
	world: Node, definition: BuildingDefinition, position: Vector3
) -> ConstructionSite:
	var transform := Transform3D(Basis.IDENTITY, position)
	assert(world.call("_blueprint_placement_clear", definition, transform))
	var site := world.call("_create_blueprint_site", definition, transform) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	return site


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ingot != null and ore != null)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	assert(main.get_node_or_null("BlueprintConstructionMaterialEscrow") == null)
	main.free()
	print("PASS A: Main has no construction receiver autowire service")

	var packed := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	assert(sandbox != null)
	var gate := sandbox.get_node("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	var world: Node = sandbox.get_node("WorldInteraction")
	assert(gate != null and not gate.enable_isolated_bridge)
	assert(not gate.enable_isolated_authorization_autowire)
	assert(bool(world.get("blueprint_sandbox_debug_requirements")))
	assert(gate.receiver_for_authorized_site(null) == null)
	print("PASS B: Committed sandbox keeps both autowire and lifecycle bridge OFF")

	add_child(sandbox)
	world.set_process(false)
	var site := _placed(world, definition, Vector3(-5, 0, 2))
	var extra := _placed(world, definition, Vector3(-13, 0, 2))
	assert(site.get_parent() == sandbox and extra.get_parent() == sandbox)
	assert(world.call("_is_managed_blueprint", site))
	assert(world.call("_is_managed_blueprint", extra))
	assert(world.has_signal(&"blueprint_site_authorized"))
	print("PASS C: Two real placed blueprints remain PLANNED, with no receiver")

	var supplier := Node3D.new()
	supplier.name = "TestOnlyOutput"
	sandbox.add_child(supplier)
	var stock := InventoryComponent.new()
	stock.max_capacity = 12
	supplier.add_child(stock)
	assert(stock.add_item(ingot, 4) == 4)
	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.show_port_label = false
	output.inventory = stock
	supplier.add_child(output)
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	sandbox.add_child(staging)
	assert(staging.configure(stock, definition, 3))
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer.get_total_amount() == 0)
	print("PASS D: Explicit preconfigured staging has zero cargo and a real supplier")

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	sandbox.add_child(escrow)
	assert(not gate.configure_authorization_autowire(registry, escrow))
	assert(not gate.prepare_player_site_intake(site, staging))
	assert(registry.claim_count() == 0)
	print("PASS E: Default-OFF bridge refuses implicit receiver setup")

	gate.enable_isolated_bridge = true
	gate.enable_isolated_authorization_autowire = true
	assert(not gate.configure_authorization_autowire(registry, escrow))
	assert(gate.receiver_for_authorized_site(site) == null)
	assert(registry.claim_count() == 0)
	print("PASS F: Legacy debug bypass still blocks auto receiver configuration")

	world.set("blueprint_sandbox_debug_requirements", false)
	var foreign_registry := BlueprintConstructionSiteStagingRegistry.new()
	foreign_registry.enable_isolated_site_registry = true
	add_child(foreign_registry)
	assert(not gate.configure_authorization_autowire(foreign_registry, escrow))
	var foreign_escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(foreign_escrow)
	assert(not gate.configure_authorization_autowire(registry, foreign_escrow))
	assert(gate.configure_authorization_autowire(registry, escrow))
	assert(not gate.configure_authorization_autowire(registry, escrow))
	print("PASS G: Exactly one same-sandbox registry and escrow pair can subscribe")

	var outsider := ConstructionSite.new()
	assert(outsider.setup_with_definition_job(definition))
	add_child(outsider)
	outsider.set_process(false)
	assert(not gate.prepare_player_site_intake(outsider, staging))
	assert(gate.prepare_player_site_intake(site, staging))
	assert(not gate.prepare_player_site_intake(site, staging))
	assert(not gate.prepare_player_site_intake(extra, staging))
	assert(registry.claim_count() == 0)
	print("PASS H: Only one PLANNED managed blueprint may reserve this staging")

	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(registry.claim_count() == 0)
	assert(gate.receiver_for_authorized_site(site) == null)
	print("PASS I: High priority alone neither authorizes nor attaches receiver")

	assert(world.call("_authorize_blueprint_site", extra))
	assert(extra.job.state == ConstructionJob.State.QUEUED)
	assert(gate.receiver_for_authorized_site(extra) == null)
	assert(registry.claim_count() == 0)
	assert(not gate.prepare_player_site_intake(extra, staging))
	print("PASS J: An unregistered authorized site gains no receiver or stock")

	assert(world.call("_authorize_blueprint_site", site))
	var port := gate.receiver_for_authorized_site(site)
	assert(port != null and port.matches_attached_site())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_wait_reasons().size() == 3)
	assert(site.job.get_progress() == 0.0)
	assert(registry.claim_count() == 1)
	assert(registry.inventory_for_site(site) == buffer)
	print("PASS K: E-style authorization event installs exactly one owned receiver")

	assert(port.enable_isolated_escrow_intake_lock)
	assert(not port.is_escrow_intake_locked())
	assert(port.can_accept_item(ingot))
	assert(not port.can_accept_item(ore))
	assert(not world.call("_authorize_blueprint_site", site))
	assert(registry.claim_count() == 1)
	assert(gate.receiver_for_authorized_site(extra) == null)
	print("PASS L: Auto-attached receiver has the escrow lock before accepting cargo")

	var belt_scene := load("res://scenes/logistics/conveyor_straight.tscn") as PackedScene
	assert(belt_scene != null)
	var belt := belt_scene.instantiate() as ConveyorSegment
	assert(belt != null)
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	assert(timer != null and transport != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	var endpoint := belt.get_node("InputEndpoint") as Marker3D
	assert(endpoint != null)
	supplier.global_transform = Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		output, endpoint, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(output))
	assert(port.connected_conveyor == belt)
	print("PASS M: Real conveyor connects automatically installed receiver to supplier")

	for i: int in range(3):
		timer._process(0.01)
		assert(transport.get_held_item() == ingot)
		assert(timer.advance_transport(1.0))
		assert(transport.get_held_item() == null)
	assert(buffer.get_amount(ingot) == 3)
	assert(stock.get_amount(ingot) == 1)
	assert(escrow.held_count() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS N: Three actual belt deliveries fill the site without auto-escrow")

	var held: int = registry.reserve_for_site(site, escrow)
	assert(held > 0 and escrow.reservation_for(site) == held)
	assert(escrow.held_count() == 1)
	assert(buffer.get_amount(ingot) == 0)
	assert(port.is_escrow_intake_locked())
	assert(not port.can_accept_item(ingot))
	print("PASS O: Site-owned escrow immediately blocks receiver while still QUEUED")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	assert(buffer.get_total_amount() == 0)
	assert(site.job.get_progress() == 0.0)
	print("PASS P: Fourth ingot remains in belt cargo after site escrow")

	gate.enable_isolated_authorization_autowire = false
	assert(gate.receiver_for_authorized_site(site) == null)
	assert(port.is_escrow_intake_locked())
	assert(not port.can_accept_item(ingot))
	assert(not timer.advance_transport(0.01))
	gate.enable_isolated_authorization_autowire = true
	assert(gate.receiver_for_authorized_site(site) == port)
	print("PASS Q: Autowire toggle cannot silently unlock existing material escrow")

	assert(site.job.cancel())
	assert(not port.enable_isolated_input)
	assert(gate.receiver_for_authorized_site(site) == null)
	assert(escrow.held_count() == 0)
	assert(buffer.get_amount(ingot) == 3)
	assert(registry.claim_count() == 1)
	assert(not timer.advance_transport(0.01))
	print("PASS R: Cancellation returns owned escrow and permanently disables receiver")

	var recovery := InventoryComponent.new()
	sandbox.add_child(recovery)
	assert(transport.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.get_amount(ingot) == 1)
	assert(buffer.get_amount(ingot) == 3)
	assert(stock.get_amount(ingot) == 0)
	assert(escrow.held_count() == 0)
	assert(registry.claim_count() == 1)
	assert(sandbox.get_node_or_null("ConstructionAuthorizationDock") != null)
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	print("PASS S: Four ingots accounted for, old owner claim and UI protected")

	print("ALL 19 E3D5C5D AUTHORIZATION-TO-RECEIVER AUTOWIRE TESTS PASSED")
	print("TEST ONLY: Explicit staging + escrow preregistration; no generated materials, live drones or save.")
