extends Node3D

# E3d5c5h — DIRECT SINGLE-BELT ROUTE AND EPHEMERAL CARGO ORIGIN CHECKS.
# Factory output inventories are explicitly seeded for reproducibility.
# Discovery creates nothing; manual opt-in enrollment creates EMPTY staging.
# Only real physical conveyor travel and explicit E authorization move stock.

func _ready() -> void:
	call_deferred("_checks")


func _place(world: Node, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var transform := Transform3D(Basis.IDENTITY, at)
	assert(world.call("_blueprint_placement_clear", definition, transform))
	var site := world.call("_create_blueprint_site", definition, transform) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _building(sandbox: Node3D, scene_path: String, at: Vector3) -> Node3D:
	var packed := load(scene_path) as PackedScene
	assert(packed != null)
	var building := packed.instantiate() as Node3D
	assert(building != null)
	sandbox.add_child(building)
	building.global_position = at
	return building


func _checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ingot != null and ore != null)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	main.free()
	print("PASS A: Main gameplay has no experimental supplier-discovery bridge")

	var packed := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	assert(sandbox != null)
	var gate := sandbox.get_node("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	var world: Node = sandbox.get_node("WorldInteraction")
	assert(not gate.enable_isolated_bridge)
	assert(not gate.enable_isolated_authorization_autowire)
	assert(not gate.enable_isolated_output_enrollment)
	assert(not gate.enable_isolated_supplier_discovery)
	assert(bool(world.get("blueprint_sandbox_debug_requirements")))
	print("PASS B: Supplier discovery and all older sandbox gates default OFF")

	add_child(sandbox)
	world.set_process(false)
	var first := _place(world, definition, Vector3(-5, 0, 2))
	var second := _place(world, definition, Vector3(-13, 0, 16))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(gate.discover_available_factory_outputs(first).is_empty())
	print("PASS C: Two real player blueprints remain unapproved and undiscovered")

	var near := _building(sandbox, "res://scenes/buildings/test_storage.tscn", Vector3(-11, 0, 2))
	var far := _building(sandbox, "res://scenes/buildings/test_smelter.tscn", Vector3(-25, 0, 2))
	var partial := _building(sandbox, "res://scenes/buildings/test_storage.tscn", Vector3(-7, 0, 12))
	var wrong := _building(sandbox, "res://scenes/buildings/test_storage.tscn", Vector3(-5, 0, 11))
	var near_stock := near.get_node("InventoryComponent") as InventoryComponent
	var far_stock := far.get_node("OutputInventory") as InventoryComponent
	var partial_stock := partial.get_node("InventoryComponent") as InventoryComponent
	var wrong_stock := wrong.get_node("InventoryComponent") as InventoryComponent
	assert(near_stock.add_item(ingot, 4) == 4)
	assert(far_stock.add_item(ingot, 3) == 3)
	assert(partial_stock.add_item(ingot, 2) == 2)
	assert(wrong_stock.add_item(ore, 9) == 9)
	var near_port := near.get_node("OutputPort") as ItemPortComponent
	var far_port := far.get_node("OutputPort") as ItemPortComponent
	var partial_port := partial.get_node("OutputPort") as ItemPortComponent
	var wrong_port := wrong.get_node("OutputPort") as ItemPortComponent
	assert(near_port.inventory == near_stock)
	assert(far_port.inventory == far_stock)
	assert(far_port.producer_component.output_inventory == far_stock)
	print("PASS D: Actual Storage and Smelter outputs have only existing counted stock")

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	sandbox.add_child(escrow)
	assert(gate.discover_available_factory_outputs(first).is_empty())
	assert(gate.prepare_player_site_from_discovery(first) == null)
	print("PASS E: Disabled discovery cannot expose or enroll factory stock")

	gate.enable_isolated_bridge = true
	gate.enable_isolated_authorization_autowire = true
	gate.enable_isolated_output_enrollment = true
	gate.enable_isolated_supplier_discovery = true
	assert(gate.discover_available_factory_outputs(first).is_empty())
	assert(not gate.configure_authorization_autowire(registry, escrow))
	print("PASS F: Legacy debug bypass prevents automatic supplier discovery")

	world.set("blueprint_sandbox_debug_requirements", false)
	assert(gate.configure_authorization_autowire(registry, escrow))
	gate.enable_isolated_supplier_discovery = false
	assert(gate.discover_available_factory_outputs(first).is_empty())
	assert(gate.prepare_player_site_from_discovery(first) == null)
	assert(registry.claim_count() == 0)
	print("PASS G: Read-only discovery requires its separate opt-in after setup")

	gate.enable_isolated_supplier_discovery = true
	var choices: Array[ItemPortComponent] = gate.discover_available_factory_outputs(first)
	assert(choices.size() == 2)
	assert(choices[0] == near_port and choices[1] == far_port)
	assert(registry.claim_count() == 0 and escrow.held_count() == 0)
	print("PASS H: Real stocked Storage ranks before more distant qualified Smelter")

	assert(not choices.has(partial_port))
	assert(not choices.has(wrong_port))
	assert(not choices.has(near.get_node("InputPort")))
	assert(partial_stock.get_amount(ingot) == 2)
	assert(wrong_stock.get_amount(ore) == 9)
	print("PASS I: Partial bills, wrong cargo and INPUT ports are never recommended")

	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(near_stock.get_amount(ingot) == 4)
	assert(far_stock.get_amount(ingot) == 3)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneTickController") == null)
	print("PASS J: Discovery only observes stock; no authority, power or workers")

	var stage_a := gate.prepare_player_site_from_discovery(first)
	assert(stage_a != null and stage_a.get_parent() == sandbox)
	assert(stage_a.matches_source_inventory(near_stock))
	assert(stage_a.get_staged_inventory().max_capacity == 3)
	assert(stage_a.get_staged_inventory().get_total_amount() == 0)
	assert(near_stock.get_amount(ingot) == 4)
	print("PASS K: Deliberate enrollment chooses nearest source, creates EMPTY buffer")

	assert(gate.prepare_player_site_from_discovery(first) == null)
	assert(gate.discover_available_factory_outputs(first).is_empty())
	var second_choices: Array[ItemPortComponent] = gate.discover_available_factory_outputs(second)
	assert(second_choices.size() == 1 and second_choices[0] == far_port)
	print("PASS L: Enrolled output cannot be selected again for another blueprint")

	var stage_b := gate.prepare_player_site_from_discovery(second)
	assert(stage_b != null and stage_b.matches_source_inventory(far_stock))
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	assert(gate.discover_available_factory_outputs(second).is_empty())
	assert(registry.claim_count() == 0)
	print("PASS M: Second blueprint independently pins a different actual factory output")

	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(gate.receiver_for_authorized_site(first) == null)
	assert(gate.receiver_for_authorized_site(second) == null)
	print("PASS N: High priority never authorizes or attaches a material receiver")

	assert(world.call("_authorize_blueprint_site", first))
	assert(world.call("_authorize_blueprint_site", second))
	var receiver := gate.receiver_for_authorized_site(first)
	var second_receiver := gate.receiver_for_authorized_site(second)
	assert(receiver != null and receiver.matches_attached_site())
	assert(second_receiver != null and second_receiver.matches_attached_site())
	assert(receiver.enable_isolated_escrow_intake_lock)
	assert(receiver.enable_isolated_output_source_guard)
	assert(registry.claim_count() == 2 and escrow.held_count() == 0)
	assert(registry.inventory_for_site(first) == stage_a.get_staged_inventory())
	assert(registry.inventory_for_site(second) == stage_b.get_staged_inventory())
	print("PASS O: Explicit authorizations attach two separate source-pinned receivers")

	var belt := (load("res://scenes/logistics/conveyor_straight.tscn") as PackedScene).instantiate() as ConveyorSegment
	assert(belt != null)
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	assert(timer != null and transport != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(receiver, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(receiver))
	var endpoint := belt.get_node("InputEndpoint") as Marker3D
	assert(endpoint != null)
	var output_target := Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	near.global_transform = output_target * near_port.transform.affine_inverse()
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		near_port, endpoint, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(near_port))
	assert(belt.output_building_port == receiver and belt.input_building_port == near_port)
	print("PASS P: An actual TestStorage output connects to the protected site via belt")

	assert(not receiver.enable_isolated_single_belt_route_guard)
	assert(not receiver.bind_single_belt_route(belt))
	assert(receiver.can_accept_item(ingot))
	receiver.enable_isolated_single_belt_route_guard = true
	assert(not receiver.has_verified_single_belt_route())
	assert(not receiver.can_accept_item(ingot))
	assert(near_port.try_transfer_to_port(receiver, ingot, 1) == 0)
	print("PASS Q: Default-off route mode; opt-in rejects direct transfers and unbound intake")

	# Cargo loaded before binding cannot be grandfathered into a protected route.
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not receiver.bind_single_belt_route(belt))
	assert(not timer.advance_transport(1.0))
	assert(transport.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(near_stock.get_amount(ingot) == 4)
	assert(receiver.bind_single_belt_route(belt))
	assert(receiver.has_verified_single_belt_route())
	assert(not receiver.bind_single_belt_route(belt))
	print("PASS R: Nonempty belt refuses initial binding; empty correct route pins once")

	# A different valid output is physically aligned, but is not the enrolled source.
	var decoy: ItemPortComponent = partial_port
	var wrong_transform: Transform3D = partial.global_transform
	assert(belt.disconnect_building_port(near_port))
	partial.global_transform = output_target * decoy.transform.affine_inverse()
	assert(belt.try_connect_building_port(decoy))
	assert(not receiver.has_verified_single_belt_route())
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(stage_a.get_staged_inventory().get_total_amount() == 0)
	print("PASS S: Physically connected wrong supplier cannot deliver its ingot")

	assert(belt.disconnect_building_port(decoy))
	partial.global_transform = wrong_transform
	assert(belt.try_connect_building_port(near_port))
	assert(receiver.has_verified_single_belt_route())
	assert(not timer.advance_transport(0.01))
	assert(transport.cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	assert(partial_stock.get_amount(ingot) == 2)
	print("PASS T: Reconnecting enrolled supplier cannot legitimize already-loaded foreign cargo")

	timer._process(0.01)
	assert(transport.has_physical_building_load(near_port, ingot))
	near_port.connected_conveyor = null
	assert(not receiver.has_verified_single_belt_route())
	assert(not timer.advance_transport(1.0))
	assert(transport.get_held_item() == ingot)
	near_port.connected_conveyor = belt
	assert(receiver.has_verified_single_belt_route())
	var correct_transform: Transform3D = near.global_transform
	near.global_position += Vector3(3, 0, 0)
	assert(not receiver.has_verified_single_belt_route())
	assert(not timer.advance_transport(0.01))
	near.global_transform = correct_transform
	assert(receiver.has_verified_single_belt_route())
	print("PASS U: Nonreciprocal or misaligned source connection blocks delivery and preserves cargo")

	receiver.enable_isolated_single_belt_route_guard = false
	assert(not receiver.can_accept_item(ingot))
	assert(not timer.advance_transport(0.01))
	receiver.enable_isolated_single_belt_route_guard = true
	assert(transport.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(partial_stock.transfer_to(transport.cargo_inventory, ingot, 1) == 1)
	assert(not transport.has_physical_building_load(near_port, ingot))
	assert(not timer.advance_transport(0.01))
	assert(transport.cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	assert(near_stock.get_amount(ingot) == 4)
	print("PASS V: Guard toggle and unstamped same-item cargo cannot bypass route proof")

	for step: int in range(3):
		timer._process(0.01)
		assert(transport.get_held_item() == ingot)
		assert(timer.advance_transport(1.0))
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(near_stock.get_amount(ingot) == 1)
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	print("PASS W: Three timed ingots move physically; second site receives nothing")

	var reservation: int = registry.reserve_for_site(first, escrow)
	assert(reservation > 0 and escrow.reservation_for(first) == reservation)
	assert(stage_a.get_staged_inventory().get_total_amount() == 0)
	assert(receiver.is_escrow_intake_locked())
	assert(not receiver.can_accept_item(ingot))
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS X: Exclusive escrow blocks a fourth delivery while site remains QUEUED")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(transport.has_physical_building_load(near_port, ingot))
	assert(receiver.has_verified_single_belt_route())
	assert(not receiver.can_accept_belt_item(belt, ingot))
	assert(not timer.advance_transport(1.0))
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	assert(first.job.cancel())
	assert(escrow.held_count() == 0)
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(registry.claim_count() == 2)
	print("PASS Y: Cancellation refunds exact bill and leaves extra cargo on belt")

	var recovered := InventoryComponent.new()
	recovered.max_capacity = 4
	sandbox.add_child(recovered)
	assert(transport.cargo_inventory.transfer_to(recovered, ingot, 1) == 1)
	assert(recovered.get_amount(ingot) == 1)
	assert(stage_a.get_staged_inventory().get_amount(ingot) + recovered.get_amount(ingot) == 4)
	assert(far_stock.get_amount(ingot) == 3)
	assert(partial_stock.get_amount(ingot) == 2)
	assert(wrong_stock.get_amount(ore) == 9)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(second_receiver.can_accept_item(ingot))
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	assert(sandbox.get_node_or_null("ConstructionAuthorizationDock") != null)
	print("PASS Z: Both factory stocks conserved; protected UI and unused site intact")

	print("ALL 26 E3D5C5H SINGLE BELT ROUTE VERIFICATION TESTS PASSED")
	print("TEST ONLY: One pinned straight belt and API-mutation cargo stamp; no multi-belt provenance or save.")
