extends Node3D

# E3d5c5i — TEST-ONLY THREE-SEGMENT STRAIGHT ROUTE AND CARGO HISTORY.
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

	var belt_scene := load("res://scenes/logistics/conveyor_straight.tscn") as PackedScene
	var first_belt := belt_scene.instantiate() as ConveyorSegment
	var middle_belt := belt_scene.instantiate() as ConveyorSegment
	var last_belt := belt_scene.instantiate() as ConveyorSegment
	var route: Array[ConveyorSegment] = [first_belt, middle_belt, last_belt]
	var timers: Array[ConveyorTransportTimer] = []
	var cargo: Array[ConveyorTransportComponent] = []
	for belt: ConveyorSegment in route:
		sandbox.add_child(belt)
		var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
		timer.set_process(false)
		timer.travel_interval = 1.0
		timers.append(timer)
		cargo.append(belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent)
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(receiver, last_belt)
	assert(snap.has("transform"))
	last_belt.global_transform = snap["transform"]
	assert(last_belt.try_connect_building_port(receiver))
	var before_last: Dictionary = middle_belt.get_snap_preview_transform_before(last_belt)
	assert(before_last.has("transform"))
	middle_belt.global_transform = before_last["transform"]
	assert(middle_belt.try_connect_to(last_belt))
	var before_middle: Dictionary = first_belt.get_snap_preview_transform_before(middle_belt)
	assert(before_middle.has("transform"))
	first_belt.global_transform = before_middle["transform"]
	assert(first_belt.try_connect_to(middle_belt))
	var endpoint := first_belt.get_node("InputEndpoint") as Marker3D
	var output_target := Transform3D(
		endpoint.global_transform.basis * Basis(Vector3.UP, PI),
		endpoint.global_position
	)
	near.global_transform = output_target * near_port.transform.affine_inverse()
	assert(first_belt.try_connect_building_port(near_port))
	print("PASS P: Three actual straight belts connect source to receiver")

	assert(not receiver.enable_isolated_multi_belt_route_guard)
	assert(not receiver.bind_multi_belt_route(route))
	assert(receiver.can_accept_item(ingot))
	receiver.enable_isolated_multi_belt_route_guard = true
	assert(not receiver.has_verified_multi_belt_route())
	assert(not receiver.can_accept_item(ingot))
	assert(near_port.try_transfer_to_port(receiver, ingot, 1) == 0)
	print("PASS Q: Opt-in rejects direct and unbound delivery; old mode remains default")

	var repeated: Array[ConveyorSegment] = [first_belt, middle_belt, middle_belt, last_belt]
	var reversed: Array[ConveyorSegment] = [last_belt, middle_belt, first_belt]
	assert(not receiver.bind_multi_belt_route(repeated))
	assert(not receiver.bind_multi_belt_route(reversed))
	middle_belt.previous_segment = null
	assert(not receiver.bind_multi_belt_route(route))
	middle_belt.previous_segment = first_belt
	print("PASS R: Duplicate, reversed and nonreciprocal paths cannot bind")

	timers[0]._process(0.01)
	assert(cargo[0].get_held_item() == ingot)
	assert(not receiver.bind_multi_belt_route(route))
	assert(cargo[0].cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(receiver.bind_multi_belt_route(route))
	assert(receiver.has_verified_multi_belt_route())
	assert(not receiver.bind_multi_belt_route(route))
	print("PASS S: Nonempty path refuses binding; empty exact chain binds once")

	# Foreign supplier loads a real item into the path before reconnection.
	assert(first_belt.disconnect_building_port(near_port))
	var old_partial: Transform3D = partial.global_transform
	partial.global_transform = output_target * partial_port.transform.affine_inverse()
	assert(first_belt.try_connect_building_port(partial_port))
	timers[0]._process(0.01)
	assert(cargo[0].has_physical_building_load(partial_port, ingot))
	assert(not receiver.has_verified_multi_belt_route())
	assert(timers[0].advance_transport(1.0))
	assert(timers[1].advance_transport(1.0))
	assert(cargo[2].has_verified_physical_route(partial_port, ingot, route))
	assert(not timers[2].advance_transport(1.0))
	print("PASS T: Foreign cargo traverses belts but cannot enter protected receiver")

	assert(first_belt.disconnect_building_port(partial_port))
	partial.global_transform = old_partial
	assert(first_belt.try_connect_building_port(near_port))
	assert(receiver.has_verified_multi_belt_route())
	assert(not timers[2].advance_transport(0.01))
	assert(cargo[2].cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	assert(partial_stock.get_amount(ingot) == 2)
	print("PASS U: Correct source reconnection cannot legitimize foreign history")

	# Deliberately use the low-level buffer interface, not a physical hop.
	timers[0]._process(0.01)
	assert(cargo[0].has_physical_building_load(near_port, ingot))
	assert(cargo[0].try_move_to_buffer(cargo[1]))
	assert(timers[1].advance_transport(1.0))
	assert(not cargo[2].has_verified_physical_route(near_port, ingot, route))
	assert(not timers[2].advance_transport(1.0))
	assert(cargo[2].cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	print("PASS V: Low-level buffer transfer cannot forge a physical hop")

	timers[0]._process(0.01)
	var prefix: Array[ConveyorSegment] = [first_belt, middle_belt]
	assert(not timers[0].advance_transport(0.4))
	assert(timers[0].advance_transport(0.6))
	assert(cargo[1].has_verified_physical_route(near_port, ingot, prefix))
	assert(not cargo[1].has_physical_building_load(near_port, ingot))
	var correct_middle: Transform3D = middle_belt.global_transform
	middle_belt.global_position += Vector3(3, 0, 0)
	assert(not receiver.has_verified_multi_belt_route())
	assert(not timers[1].advance_transport(1.0))
	assert(cargo[1].get_held_item() == ingot)
	middle_belt.global_transform = correct_middle
	assert(receiver.has_verified_multi_belt_route())
	assert(timers[1].advance_transport(0.01))
	assert(cargo[2].has_verified_physical_route(near_port, ingot, route))
	print("PASS W: Timed physical hops preserve ordered proof across repaired alignment")

	# A cycle or broken upstream link must stop final delivery even if cargo
	# is already at the last belt. Restore fields before continuing tests.
	first_belt.previous_segment = last_belt
	last_belt.next_segment = first_belt
	assert(not receiver.has_verified_multi_belt_route())
	assert(not receiver.can_accept_belt_item(last_belt, ingot))
	first_belt.previous_segment = null
	last_belt.next_segment = null
	middle_belt.previous_segment = null
	assert(not receiver.has_verified_multi_belt_route())
	assert(not timers[2].advance_transport(1.0))
	middle_belt.previous_segment = first_belt
	assert(receiver.has_verified_multi_belt_route())
	print("PASS X: Cyclic or broken upstream chain denies final delivery")

	receiver.enable_isolated_multi_belt_route_guard = false
	assert(not receiver.can_accept_item(ingot))
	assert(not timers[2].advance_transport(0.01))
	receiver.enable_isolated_multi_belt_route_guard = true
	assert(cargo[2].cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(partial_stock.transfer_to(cargo[2].cargo_inventory, ingot, 1) == 1)
	assert(not cargo[2].has_verified_physical_route(near_port, ingot, route))
	assert(not timers[2].advance_transport(0.01))
	assert(cargo[2].cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	assert(near_stock.get_amount(ingot) == 4)
	print("PASS Y: Disabling guard or replacing cargo cannot bypass proof")

	for step: int in range(3):
		timers[0]._process(0.01)
		assert(timers[0].advance_transport(1.0))
		assert(timers[1].advance_transport(1.0))
		assert(cargo[2].has_verified_physical_route(near_port, ingot, route))
		assert(timers[2].advance_transport(1.0))
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	assert(near_stock.get_amount(ingot) == 1)
	print("PASS Z: Three full-path physical ingots reach only their owned staging")

	var reservation: int = registry.reserve_for_site(first, escrow)
	assert(reservation > 0 and escrow.reservation_for(first) == reservation)
	assert(receiver.is_escrow_intake_locked())
	assert(first.job.state == ConstructionJob.State.QUEUED)
	timers[0]._process(0.01)
	assert(timers[0].advance_transport(1.0))
	assert(timers[1].advance_transport(1.0))
	assert(cargo[2].has_verified_physical_route(near_port, ingot, route))
	assert(not timers[2].advance_transport(1.0))
	assert(first.job.cancel())
	assert(escrow.held_count() == 0)
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(registry.claim_count() == 2)
	var recovered := InventoryComponent.new()
	sandbox.add_child(recovered)
	assert(cargo[2].cargo_inventory.transfer_to(recovered, ingot, 1) == 1)
	assert(recovered.get_amount(ingot) + stage_a.get_staged_inventory().get_amount(ingot) == 4)
	assert(near_stock.get_amount(ingot) == 0)
	assert(far_stock.get_amount(ingot) == 3)
	assert(partial_stock.get_amount(ingot) == 2)
	assert(wrong_stock.get_amount(ore) == 9)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(second_receiver.can_accept_item(ingot))
	assert(sandbox.get_node_or_null("ConstructionPriorityDock") != null)
	assert(sandbox.get_node_or_null("ConstructionAuthorizationDock") != null)
	print("PASS AA: Escrow blocks fourth proven ingot; cancellation and recovery conserve stock")

	print("ALL 27 E3D5C5I MULTI BELT ROUTE VERIFICATION TESTS PASSED")
	print("TEST ONLY: Pinned straight linear route and in-memory physical hop history; no corners, branching or save.")
