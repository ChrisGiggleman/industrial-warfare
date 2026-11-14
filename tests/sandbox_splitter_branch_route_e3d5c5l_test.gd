extends Node3D

# E3d5c5l — ONE actual splitter and two downstream straight belts.
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


func _belt(sandbox: Node3D, target: ItemPortComponent) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(target, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(target))
	return belt


func _cargo(belt: ConveyorSegment) -> ConveyorTransportComponent:
	return belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent


func _timer(belt: ConveyorSegment) -> ConveyorTransportTimer:
	return belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer


func _feed(belt: ConveyorSegment, splitter: ConveyorSplitterComponent) -> void:
	_timer(belt)._process(0.01)
	assert(_timer(belt).advance_transport(1.0))
	assert(splitter.advance_split())


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

	var last := _belt(sandbox, receiver)
	var first_out := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	sandbox.add_child(first_out)
	_timer(first_out).set_process(false)
	_timer(first_out).travel_interval = 1.0
	var preview: Dictionary = first_out.get_snap_preview_transform_before(last)
	assert(preview.has("transform"))
	first_out.global_transform = preview["transform"]
	assert(first_out.try_connect_to(last))
	var building := _building(sandbox, "res://scenes/buildings/conveyor_splitter.tscn", Vector3.ZERO)
	var splitter := building.get_node("SplitterComponent") as ConveyorSplitterComponent
	splitter.set_process(false)
	var input := building.get_node("InputPort") as ItemPortComponent
	var lane_a := building.get_node("OutputPortA") as ItemPortComponent
	var lane_b := building.get_node("OutputPortB") as ItemPortComponent
	var marker := first_out.get_node("InputEndpoint") as Marker3D
	var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	building.global_transform = desired * lane_a.transform.affine_inverse()
	assert(first_out.try_connect_building_port(lane_a))
	var incoming := _belt(sandbox, input)
	var source_marker := incoming.get_node("InputEndpoint") as Marker3D
	var source_target := source_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	near.global_transform = source_target * near_port.transform.affine_inverse()
	assert(incoming.try_connect_building_port(near_port))
	var route: Array[ConveyorSegment] = [first_out, last]
	print("PASS P: Actual Storage, splitter and three straight belts physically connected")

	assert(not receiver.enable_isolated_splitter_branch_guard)
	assert(not receiver.bind_splitter_branch(splitter, incoming, input, lane_a, route))
	receiver.enable_isolated_splitter_branch_guard = true
	assert(not receiver.can_accept_item(ingot))
	assert(not receiver.has_verified_splitter_branch())
	assert(not receiver.bind_splitter_branch(splitter, incoming, input, lane_a, route))
	splitter.enable_isolated_splitter_provenance = true
	assert(splitter.configure_splitter_provenance())
	print("PASS Q: Independent opt-ins and empty configured splitter required")

	assert(not receiver.bind_splitter_branch(splitter, incoming, input, lane_b, route))
	var reverse: Array[ConveyorSegment] = [last, first_out]
	assert(not receiver.bind_splitter_branch(splitter, incoming, input, lane_a, reverse))
	_timer(incoming)._process(0.01)
	assert(not receiver.bind_splitter_branch(splitter, incoming, input, lane_a, route))
	assert(_cargo(incoming).cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(receiver.bind_splitter_branch(splitter, incoming, input, lane_a, route))
	assert(receiver.has_verified_splitter_branch())
	assert(not receiver.bind_splitter_branch(splitter, incoming, input, lane_a, route))
	print("PASS R: Wrong lane, reverse and nonempty route refused; exact route binds once")

	# Foreign source uses same physical chain, then correct supplier reconnects.
	assert(incoming.disconnect_building_port(near_port))
	var partial_pose: Transform3D = partial.global_transform
	partial.global_transform = source_target * partial_port.transform.affine_inverse()
	assert(incoming.try_connect_building_port(partial_port))
	_feed(incoming, splitter)
	_timer(first_out)._process(0.01)
	assert(_timer(first_out).advance_transport(1.0))
	assert(_cargo(last).has_verified_splitter_branch(partial_port, ingot, splitter, incoming, input, lane_a, route))
	assert(not _timer(last).advance_transport(1.0))
	assert(incoming.disconnect_building_port(partial_port))
	partial.global_transform = partial_pose
	assert(incoming.try_connect_building_port(near_port))
	assert(receiver.has_verified_splitter_branch())
	assert(not _timer(last).advance_transport(0.01))
	assert(_cargo(last).cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	print("PASS S: Foreign origin survives splitter but cannot enter after correct source reconnect")

	# Wrong-lane proof travels onto a distinct connected belt.
	var other := _belt(sandbox, lane_b)
	# Round robin next lane is B after prior A distribution.
	_feed(incoming, splitter)
	assert(splitter.output_b.get_amount(ingot) == 1)
	_timer(other)._process(0.01)
	assert(_cargo(other).has_verified_splitter_load(near_port, ingot, splitter, incoming, lane_b))
	assert(not receiver.can_accept_belt_item(other, ingot))
	assert(_cargo(other).cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(other.disconnect_building_port(lane_b))
	print("PASS T: Other splitter lane cannot deliver to the pinned receiver")

	_feed(incoming, splitter)
	_timer(first_out)._process(0.01)
	assert(_cargo(first_out).has_verified_splitter_load(near_port, ingot, splitter, incoming, lane_a))
	assert(_cargo(first_out).try_move_to_buffer(_cargo(last)))
	assert(not _cargo(last).has_verified_splitter_branch(near_port, ingot, splitter, incoming, input, lane_a, route))
	assert(not _timer(last).advance_transport(1.0))
	assert(_cargo(last).cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	print("PASS U: Low-level buffer transfer cannot manufacture downstream proof")

	_feed(incoming, splitter)
	_timer(first_out)._process(0.01)
	assert(not _timer(first_out).advance_transport(0.4))
	assert(_timer(first_out).advance_transport(0.6))
	assert(_cargo(last).has_verified_splitter_branch(near_port, ingot, splitter, incoming, input, lane_a, route))
	assert(_cargo(last).physical_origin_snapshot().is_empty())
	last.previous_segment = null
	assert(not receiver.has_verified_splitter_branch())
	assert(not _timer(last).advance_transport(1.0))
	last.previous_segment = first_out
	assert(receiver.has_verified_splitter_branch())
	print("PASS V: Timed downstream proof remains separate; broken link blocks delivery")

	receiver.enable_isolated_splitter_branch_guard = false
	assert(not receiver.can_accept_item(ingot))
	assert(not _timer(last).advance_transport(0.01))
	receiver.enable_isolated_splitter_branch_guard = true
	assert(_cargo(last).cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(partial_stock.transfer_to(_cargo(last).cargo_inventory, ingot, 1) == 1)
	assert(not _timer(last).advance_transport(0.01))
	assert(_cargo(last).cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	assert(near_stock.get_amount(ingot) == 4)
	print("PASS W: Bound guard toggle and same-type cargo replacement cannot bypass proof")

	for step: int in range(3):
		_feed(incoming, splitter)
		_timer(first_out)._process(0.01)
		assert(_timer(first_out).advance_transport(1.0))
		assert(_cargo(last).has_verified_splitter_branch(near_port, ingot, splitter, incoming, input, lane_a, route))
		assert(_timer(last).advance_transport(1.0))
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	print("PASS X: Three verified ingots reach only the assigned blueprint")

	var reservation: int = registry.reserve_for_site(first, escrow)
	assert(reservation > 0 and escrow.reservation_for(first) == reservation)
	_feed(incoming, splitter)
	_timer(first_out)._process(0.01)
	assert(_timer(first_out).advance_transport(1.0))
	assert(receiver.has_verified_splitter_branch())
	assert(not _timer(last).advance_transport(1.0))
	assert(_cargo(last).get_held_item() == ingot)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS Y: Escrow denies fourth proven ingot without discarding it")

	assert(first.job.cancel())
	assert(escrow.held_count() == 0)
	var recovery := InventoryComponent.new()
	sandbox.add_child(recovery)
	assert(_cargo(last).cargo_inventory.transfer_to(recovery, ingot, 1) == 1)
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(recovery.get_amount(ingot) == 1 and near_stock.get_amount(ingot) == 0)
	assert(partial_stock.get_amount(ingot) == 2 and far_stock.get_amount(ingot) == 3)
	assert(wrong_stock.get_amount(ore) == 9)
	assert(registry.claim_count() == 2)
	assert(second_receiver.can_accept_item(ingot))
	assert(bool(building.call("can_demolish_safely")))
	print("PASS Z: Cancellation refunds exact bill; all stock and independent site conserved")

	print("ALL 26 E3D5C5L SPLITTER BRANCH ROUTE TESTS PASSED")
	print("TEST ONLY: One incoming straight belt, one splitter, pinned downstream straight path; no merger or save.")
