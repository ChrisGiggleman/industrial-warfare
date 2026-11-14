extends Node3D

# E3d5c5e — EXISTING PHYSICAL OUTPUT PORT -> EMPTY BILL-SIZED STAGING
# Existing sandbox WorldInteraction authorization emits an event; optional
# source enrollment creates NO stock, energy, workers or construction rights.
# A real timed conveyor must transport the four explicitly test-seeded ingots.

func _ready() -> void:
	call_deferred("_checks")


func _placed(world: Node, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var transform := Transform3D(Basis.IDENTITY, at)
	assert(world.call("_blueprint_placement_clear", definition, transform))
	var site := world.call("_create_blueprint_site", definition, transform) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _deliver(timer: ConveyorTransportTimer,
	transport: ConveyorTransportComponent, item: ItemDefinition
) -> void:
	timer._process(0.01)
	assert(transport.get_held_item() == item)
	assert(timer.advance_transport(1.0))
	assert(transport.get_held_item() == null)


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	main.free()
	print("PASS A: Main gameplay has no source enrollment or construction bridge")

	var packed := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	var gate := sandbox.get_node("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	var world: Node = sandbox.get_node("WorldInteraction")
	assert(gate != null and not gate.enable_isolated_bridge)
	assert(not gate.enable_isolated_authorization_autowire)
	assert(not gate.enable_isolated_output_enrollment)
	assert(bool(world.get("blueprint_sandbox_debug_requirements")))
	print("PASS B: Committed sandbox defaults all three source/receiver gates OFF")

	add_child(sandbox)
	world.set_process(false)
	var site := _placed(world, definition, Vector3(-5.0, 0.0, 2.0))
	var other := _placed(world, definition, Vector3(-13.0, 0.0, 2.0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(other.job.state == ConstructionJob.State.PLANNED)
	assert(gate.receiver_for_authorized_site(site) == null)
	print("PASS C: Real blueprint placement creates two independent inactive sites")

	var supplier := Node3D.new()
	supplier.name = "FixturePhysicalSupplier"
	sandbox.add_child(supplier)
	var stock := InventoryComponent.new()
	stock.max_capacity = 10
	supplier.add_child(stock)
	assert(stock.add_item(ingot, 4) == 4)
	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.show_port_label = false
	output.inventory = stock
	supplier.add_child(output)
	assert(output.get_parent() == stock.get_parent())
	assert(stock.get_amount(ingot) == 4)
	print("PASS D: One real output port references four existing ingots, not free stock")

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	sandbox.add_child(escrow)
	assert(gate.prepare_player_site_from_output(site, output) == null)
	assert(not gate.configure_authorization_autowire(registry, escrow))
	assert(registry.claim_count() == 0)
	print("PASS E: Disabled gates refuse source enrollment and receiver ownership")

	gate.enable_isolated_bridge = true
	gate.enable_isolated_authorization_autowire = true
	gate.enable_isolated_output_enrollment = true
	assert(gate.prepare_player_site_from_output(site, output) == null)
	assert(not gate.configure_authorization_autowire(registry, escrow))
	print("PASS F: Sandbox debug requirements bypass blocks enrollment and setup")

	world.set("blueprint_sandbox_debug_requirements", false)
	assert(gate.configure_authorization_autowire(registry, escrow))
	assert(gate.receiver_for_authorized_site(site) == null)
	assert(gate.prepare_player_site_from_output(site, null) == null)
	print("PASS G: Verified registry and escrow subscribe; null source rejected")

	var outsider_port := ItemPortComponent.new()
	outsider_port.direction = ItemPortComponent.PortDirection.OUTPUT
	outsider_port.show_port_label = false
	outsider_port.inventory = stock
	add_child(outsider_port)
	assert(gate.prepare_player_site_from_output(site, outsider_port) == null)
	var input_port := ItemPortComponent.new()
	input_port.direction = ItemPortComponent.PortDirection.INPUT
	input_port.show_port_label = false
	input_port.inventory = stock
	supplier.add_child(input_port)
	assert(gate.prepare_player_site_from_output(site, input_port) == null)
	var mismatched := ItemPortComponent.new()
	mismatched.direction = ItemPortComponent.PortDirection.OUTPUT
	mismatched.show_port_label = false
	mismatched.inventory = stock
	sandbox.add_child(mismatched)
	assert(gate.prepare_player_site_from_output(site, mismatched) == null)
	print("PASS H: Foreign, INPUT and wrong-owner source ports fail closed")

	var staging := gate.prepare_player_site_from_output(site, output)
	assert(staging != null and staging.get_parent() == sandbox)
	assert(staging.enable_isolated_staging)
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer != null and buffer.max_capacity == 3)
	assert(buffer.get_total_amount() == 0)
	assert(stock.get_amount(ingot) == 4)
	print("PASS I: Enrollment creates only EMPTY three-unit bill-sized staging")

	assert(gate.prepare_player_site_from_output(site, output) == null)
	assert(gate.prepare_player_site_from_output(other, output) == null)
	assert(registry.claim_count() == 0)
	assert(gate.receiver_for_authorized_site(other) == null)
	print("PASS J: Duplicate site or competing use of one OUTPUT is refused")

	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(gate.receiver_for_authorized_site(site) == null)
	assert(buffer.get_total_amount() == 0)
	print("PASS K: Priority alone never makes a port or construction receiver")

	assert(world.call("_authorize_blueprint_site", other))
	assert(other.job.state == ConstructionJob.State.QUEUED)
	assert(gate.receiver_for_authorized_site(other) == null)
	assert(registry.claim_count() == 0)
	print("PASS L: Unenrolled authorized site cannot borrow another output")

	assert(world.call("_authorize_blueprint_site", site))
	var port := gate.receiver_for_authorized_site(site)
	assert(port != null and port.matches_attached_site())
	assert(port.enable_isolated_escrow_intake_lock)
	assert(not port.is_escrow_intake_locked())
	assert(site.job.get_wait_reasons().size() == 3)
	assert(registry.inventory_for_site(site) == buffer)
	assert(registry.claim_count() == 1)
	print("PASS M: Explicit authorization attaches one guarded owner receiver")

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
	assert(belt.input_building_port == output and belt.output_building_port == port)
	print("PASS N: Existing real supplier connects physically through one conveyor")

	_deliver(timer, transport, ingot)
	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 2)
	assert(stock.get_amount(ingot) == 2)
	assert(escrow.held_count() == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS O: Timed cargo makes two real deliveries without auto-start")

	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 3)
	assert(stock.get_amount(ingot) == 1)
	var reserved: int = registry.reserve_for_site(site, escrow)
	assert(reserved > 0 and escrow.reservation_for(site) == reserved)
	assert(port.is_escrow_intake_locked())
	assert(buffer.get_total_amount() == 0)
	print("PASS P: Exact owner escrow blocks intake without starting construction")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	assert(site.job.get_progress() == 0.0)
	print("PASS Q: Fourth ingot stays in real belt cargo before drone arrival")

	assert(site.job.cancel())
	assert(escrow.held_count() == 0)
	assert(buffer.get_amount(ingot) == 3)
	assert(not port.enable_isolated_input)
	assert(registry.claim_count() == 1)
	var recovery := InventoryComponent.new()
	sandbox.add_child(recovery)
	assert(transport.cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(recovery.get_amount(ingot) == 1)
	assert(stock.get_amount(ingot) == 0)
	assert(buffer.get_amount(ingot) + recovery.get_amount(ingot) == 4)
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	assert(sandbox.get_node_or_null("ConstructionAuthorizationDock") != null)
	print("PASS R: Cancellation refunds three; fourth recovered, no free inventory")

	print("ALL 18 E3D5C5E SANDBOX OUTPUT ENROLLMENT TESTS PASSED")
	print("TEST ONLY: Explicit existing output, empty staging and physical belt; no automatic supplier discovery or save.")
