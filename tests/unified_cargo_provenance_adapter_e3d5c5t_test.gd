extends Node3D

const Descriptor = preload("res://scripts/components/unified_factory_route_descriptor.gd")

# E3d5c5t — legacy cargo adapter differential harness.
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


func _feed(belt: ConveyorSegment, merger: ConveyorMergerComponent) -> void:
	assert(ConveyorBuildingTransfer.try_load_into_belt(belt))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(belt))
	assert(merger.advance_merge())


func _forward(first_out: ConveyorSegment) -> void:
	assert(ConveyorBuildingTransfer.try_load_into_belt(first_out))
	assert(ConveyorTransportLink.try_transfer_forward(first_out))


func _convert_before(
	predecessor: ConveyorSegment, target: ConveyorSegment, turn: int
) -> bool:
	var packed: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	if packed == null:
		return false
	var template := packed.instantiate() as ConveyorSegment
	if template == null:
		return false
	var marker := template.get_node("OutputEndpoint") as Marker3D
	var input := target.get_node("InputEndpoint") as Marker3D
	var output_pose: Transform3D = marker.transform
	template.free()
	var desired := input.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	predecessor.global_transform = desired * output_pose.affine_inverse()
	return ConveyorCornerConversion.try_convert_and_connect(predecessor, target, turn)


func _checks() -> void:
	for mode: String in ["single", "linear", "corners", "splitter", "merger", "forward", "reverse"]:
		assert(_case(mode))
	print("ALL 42 E3D5C5T UNIFIED CARGO PROVENANCE ADAPTER TESTS PASSED")
	print("TEST ONLY: existing cargo proof adapter; never grants construction authority.")


func _case(mode: String) -> bool:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ingot != null and ore != null)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("ConstructionDroneLifecycleGate") == null)
	main.free()

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

	add_child(sandbox)
	world.set_process(false)
	var first := _place(world, definition, Vector3(-5, 0, 2))
	var second := _place(world, definition, Vector3(-13, 0, 16))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(gate.discover_available_factory_outputs(first).is_empty())

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

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	sandbox.add_child(escrow)
	assert(gate.discover_available_factory_outputs(first).is_empty())
	assert(gate.prepare_player_site_from_discovery(first) == null)

	gate.enable_isolated_bridge = true
	gate.enable_isolated_authorization_autowire = true
	gate.enable_isolated_output_enrollment = true
	gate.enable_isolated_supplier_discovery = true
	assert(gate.discover_available_factory_outputs(first).is_empty())
	assert(not gate.configure_authorization_autowire(registry, escrow))

	world.set("blueprint_sandbox_debug_requirements", false)
	assert(gate.configure_authorization_autowire(registry, escrow))
	gate.enable_isolated_supplier_discovery = false
	assert(gate.discover_available_factory_outputs(first).is_empty())
	assert(gate.prepare_player_site_from_discovery(first) == null)
	assert(registry.claim_count() == 0)

	gate.enable_isolated_supplier_discovery = true
	var choices: Array[ItemPortComponent] = gate.discover_available_factory_outputs(first)
	assert(choices.size() == 2)
	assert(choices[0] == near_port and choices[1] == far_port)
	assert(registry.claim_count() == 0 and escrow.held_count() == 0)

	assert(not choices.has(partial_port))
	assert(not choices.has(wrong_port))
	assert(not choices.has(near.get_node("InputPort")))
	assert(partial_stock.get_amount(ingot) == 2)
	assert(wrong_stock.get_amount(ore) == 9)

	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(near_stock.get_amount(ingot) == 4)
	assert(far_stock.get_amount(ingot) == 3)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneTickController") == null)

	var stage_a := gate.prepare_player_site_from_discovery(first)
	assert(stage_a != null and stage_a.get_parent() == sandbox)
	assert(stage_a.matches_source_inventory(near_stock))
	assert(stage_a.get_staged_inventory().max_capacity == 3)
	assert(stage_a.get_staged_inventory().get_total_amount() == 0)
	assert(near_stock.get_amount(ingot) == 4)

	assert(gate.prepare_player_site_from_discovery(first) == null)
	assert(gate.discover_available_factory_outputs(first).is_empty())
	var second_choices: Array[ItemPortComponent] = gate.discover_available_factory_outputs(second)
	assert(second_choices.size() == 1 and second_choices[0] == far_port)

	var stage_b := gate.prepare_player_site_from_discovery(second)
	assert(stage_b != null and stage_b.matches_source_inventory(far_stock))
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	assert(gate.discover_available_factory_outputs(second).is_empty())
	assert(registry.claim_count() == 0)

	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(gate.receiver_for_authorized_site(first) == null)
	assert(gate.receiver_for_authorized_site(second) == null)

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

	var steps: Array = []
	var first_segment: ConveyorSegment = null
	var final_segment: ConveyorSegment = null
	var allow_corners: bool = mode == "corners"
	var legacy: Callable
	if mode == "single":
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
		steps = [belt]
		first_segment = belt
		final_segment = belt
		receiver.enable_isolated_single_belt_route_guard = true
		assert(receiver.bind_single_belt_route(belt))
		legacy = receiver.has_verified_single_belt_route
	elif mode == "linear":
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
		steps = [first_belt, middle_belt, last_belt]
		first_segment = first_belt
		final_segment = last_belt
		receiver.enable_isolated_multi_belt_route_guard = true
		receiver.enable_isolated_corner_route_guard = allow_corners
		assert(receiver.bind_multi_belt_route(route))
		legacy = receiver.has_verified_multi_belt_route
	elif mode == "corners":
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
		var first_id: int = first_belt.get_instance_id()
		var middle_id: int = middle_belt.get_instance_id()
		assert(_convert_before(middle_belt, last_belt, ConveyorTurnIntent.Turn.LEFT))
		assert(_convert_before(first_belt, middle_belt, ConveyorTurnIntent.Turn.RIGHT))
		assert(first_belt.get_instance_id() == first_id)
		assert(middle_belt.get_instance_id() == middle_id)
		assert(first_belt.get_meta("conveyor_turn") == ConveyorTurnIntent.Turn.RIGHT)
		assert(middle_belt.get_meta("conveyor_turn") == ConveyorTurnIntent.Turn.LEFT)
		assert(not last_belt.has_meta("conveyor_turn"))
		assert(cargo[0].get_parent() == first_belt and cargo[1].get_parent() == middle_belt)
		var endpoint := first_belt.get_node("InputEndpoint") as Marker3D
		var output_target := Transform3D(
			endpoint.global_transform.basis * Basis(Vector3.UP, PI),
			endpoint.global_position
		)
		near.global_transform = output_target * near_port.transform.affine_inverse()
		assert(first_belt.try_connect_building_port(near_port))
		steps = [first_belt, middle_belt, last_belt]
		first_segment = first_belt
		final_segment = last_belt
		receiver.enable_isolated_multi_belt_route_guard = true
		receiver.enable_isolated_corner_route_guard = allow_corners
		assert(receiver.bind_multi_belt_route(route))
		legacy = receiver.has_verified_multi_belt_route
	elif mode == "splitter":
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
		steps = [incoming, {"input": input, "output": lane_a}, first_out, last]
		first_segment = incoming
		final_segment = last
		splitter.enable_isolated_splitter_provenance = true
		assert(splitter.configure_splitter_provenance())
		receiver.enable_isolated_splitter_branch_guard = true
		assert(receiver.bind_splitter_branch(splitter, incoming, input, lane_a, route))
		legacy = receiver.has_verified_splitter_branch
	elif mode == "merger":
		var last := _belt(sandbox, receiver)
		var first_out := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
		sandbox.add_child(first_out)
		_timer(first_out).set_process(false)
		_timer(first_out).travel_interval = 1.0
		var preview: Dictionary = first_out.get_snap_preview_transform_before(last)
		assert(preview.has("transform"))
		first_out.global_transform = preview["transform"]
		assert(first_out.try_connect_to(last))
		var building := _building(sandbox, "res://scenes/buildings/conveyor_merger.tscn", Vector3.ZERO)
		var merger := building.get_node("MergerComponent") as ConveyorMergerComponent
		merger.set_process(false)
		var input := building.get_node("InputPortA") as ItemPortComponent
		var lane_b := building.get_node("InputPortB") as ItemPortComponent
		var output := building.get_node("OutputPort") as ItemPortComponent
		var marker := first_out.get_node("InputEndpoint") as Marker3D
		var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		building.global_transform = desired * output.transform.affine_inverse()
		assert(first_out.try_connect_building_port(output))
		var incoming := _belt(sandbox, input)
		var foreign := _belt(sandbox, lane_b)
		var source_marker := incoming.get_node("InputEndpoint") as Marker3D
		var source_target := source_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		near.global_transform = source_target * near_port.transform.affine_inverse()
		assert(incoming.try_connect_building_port(near_port))
		var foreign_marker := foreign.get_node("InputEndpoint") as Marker3D
		var foreign_target := foreign_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		partial.global_transform = foreign_target * partial_port.transform.affine_inverse()
		assert(foreign.try_connect_building_port(partial_port))
		var route: Array[ConveyorSegment] = [first_out, last]
		steps = [incoming, {"input": input, "output": output}, first_out, last]
		first_segment = incoming
		final_segment = last
		merger.enable_isolated_merger_provenance = true
		assert(merger.configure_merger_provenance())
		receiver.enable_isolated_merger_route_guard = true
		assert(receiver.bind_merger_route(merger, incoming, input, output, route))
		legacy = receiver.has_verified_merger_route
	elif mode == "forward":
		var last := _belt(sandbox, receiver)
		var first_out := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
		sandbox.add_child(first_out)
		_timer(first_out).set_process(false)
		_timer(first_out).travel_interval = 1.0
		var preview: Dictionary = first_out.get_snap_preview_transform_before(last)
		assert(preview.has("transform"))
		first_out.global_transform = preview["transform"]
		assert(first_out.try_connect_to(last))
		var building := _building(sandbox, "res://scenes/buildings/conveyor_merger.tscn", Vector3.ZERO)
		var merger := building.get_node("MergerComponent") as ConveyorMergerComponent
		merger.set_process(false)
		var input := building.get_node("InputPortA") as ItemPortComponent
		var lane_b := building.get_node("InputPortB") as ItemPortComponent
		var output := building.get_node("OutputPort") as ItemPortComponent
		var marker := first_out.get_node("InputEndpoint") as Marker3D
		var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		building.global_transform = desired * output.transform.affine_inverse()
		assert(first_out.try_connect_building_port(output))
		var middle := _belt(sandbox, input)
		var sb := _building(sandbox, "res://scenes/buildings/conveyor_splitter.tscn", Vector3.ZERO)
		var splitter := sb.get_node("SplitterComponent") as ConveyorSplitterComponent
		splitter.set_process(false)
		var split_input := sb.get_node("InputPort") as ItemPortComponent
		var split_output := sb.get_node("OutputPortA") as ItemPortComponent
		var split_other := sb.get_node("OutputPortB") as ItemPortComponent
		var mid_marker := middle.get_node("InputEndpoint") as Marker3D
		var mid_target := mid_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		sb.global_transform = mid_target * split_output.transform.affine_inverse()
		assert(middle.try_connect_building_port(split_output))
		var incoming := _belt(sandbox, split_input)
		var foreign := _belt(sandbox, lane_b)
		var source_marker := incoming.get_node("InputEndpoint") as Marker3D
		var source_target := source_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		near.global_transform = source_target * near_port.transform.affine_inverse()
		assert(incoming.try_connect_building_port(near_port))
		var foreign_marker := foreign.get_node("InputEndpoint") as Marker3D
		var foreign_target := foreign_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		partial.global_transform = foreign_target * partial_port.transform.affine_inverse()
		assert(foreign.try_connect_building_port(partial_port))
		var route: Array[ConveyorSegment] = [first_out, last]
		steps = [incoming, {"input": split_input, "output": split_output}, middle, {"input": input, "output": output}, first_out, last]
		first_segment = incoming
		final_segment = last
		splitter.enable_isolated_splitter_provenance = true
		merger.enable_isolated_merger_provenance = true
		assert(splitter.configure_splitter_provenance() and merger.configure_merger_provenance())
		merger.enable_isolated_splitter_merger_provenance = true
		receiver.enable_isolated_composite_route_guard = true
		assert(receiver.bind_composite_route(splitter, incoming, split_input, split_output, middle, merger, input, output, route))
		legacy = receiver.has_verified_composite_route
	elif mode == "reverse":
		var last := _belt(sandbox, receiver)
		var first_out := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
		sandbox.add_child(first_out)
		_timer(first_out).set_process(false)
		_timer(first_out).travel_interval = 1.0
		var preview: Dictionary = first_out.get_snap_preview_transform_before(last)
		assert(preview.has("transform"))
		first_out.global_transform = preview["transform"]
		assert(first_out.try_connect_to(last))
		var sb := _building(sandbox, "res://scenes/buildings/conveyor_splitter.tscn", Vector3.ZERO)
		var splitter := sb.get_node("SplitterComponent") as ConveyorSplitterComponent
		splitter.set_process(false)
		var split_input := sb.get_node("InputPort") as ItemPortComponent
		var split_output := sb.get_node("OutputPortA") as ItemPortComponent
		var split_other := sb.get_node("OutputPortB") as ItemPortComponent
		var marker := first_out.get_node("InputEndpoint") as Marker3D
		var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		sb.global_transform = desired * split_output.transform.affine_inverse()
		assert(first_out.try_connect_building_port(split_output))
		var middle := _belt(sandbox, split_input)
		var building := _building(sandbox, "res://scenes/buildings/conveyor_merger.tscn", Vector3.ZERO)
		var merger := building.get_node("MergerComponent") as ConveyorMergerComponent
		merger.set_process(false)
		var input := building.get_node("InputPortA") as ItemPortComponent
		var lane_b := building.get_node("InputPortB") as ItemPortComponent
		var output := building.get_node("OutputPort") as ItemPortComponent
		var mid_marker := middle.get_node("InputEndpoint") as Marker3D
		var mid_target := mid_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		building.global_transform = mid_target * output.transform.affine_inverse()
		assert(middle.try_connect_building_port(output))
		var incoming := _belt(sandbox, input)
		var foreign := _belt(sandbox, lane_b)
		var source_marker := incoming.get_node("InputEndpoint") as Marker3D
		var source_target := source_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		near.global_transform = source_target * near_port.transform.affine_inverse()
		assert(incoming.try_connect_building_port(near_port))
		var foreign_marker := foreign.get_node("InputEndpoint") as Marker3D
		var foreign_target := foreign_marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
		partial.global_transform = foreign_target * partial_port.transform.affine_inverse()
		assert(foreign.try_connect_building_port(partial_port))
		var route: Array[ConveyorSegment] = [first_out, last]
		steps = [incoming, {"input": input, "output": output}, middle, {"input": split_input, "output": split_output}, first_out, last]
		first_segment = incoming
		final_segment = last
		splitter.enable_isolated_splitter_provenance = true
		merger.enable_isolated_merger_provenance = true
		assert(splitter.configure_splitter_provenance() and merger.configure_merger_provenance())
		splitter.enable_isolated_merger_splitter_provenance = true
		receiver.enable_isolated_reverse_composite_route_guard = true
		assert(receiver.bind_reverse_composite_route(splitter, incoming, split_input, split_output, middle, merger, input, output, route))
		legacy = receiver.has_verified_reverse_composite_route

	assert(first_segment != null and final_segment != null and legacy.is_valid())
	var descriptor = Descriptor.capture(near_port, receiver, steps, allow_corners)
	assert(descriptor != null and descriptor.validate() and bool(legacy.call()))
	var cargo := _cargo(final_segment)
	assert(not descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(near_stock.transfer_to(cargo.cargo_inventory, ingot, 1) == 1)
	assert(not descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(cargo.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	print("PASS ", mode, " 1: Empty and untracked final cargo denied by both paths")

	assert(_travel(steps))
	var source_revision: int = near_stock.get_mutation_revision()
	var cargo_revision: int = cargo.cargo_inventory.get_mutation_revision()
	var stage_revision: int = stage_a.get_staged_inventory().get_mutation_revision()
	assert(descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(not descriptor.matches_legacy_cargo(final_segment, ore))
	assert(not descriptor.matches_legacy_cargo(null, ingot))
	if first_segment != final_segment:
		assert(not descriptor.matches_legacy_cargo(first_segment, ingot))
	assert(near_stock.get_mutation_revision() == source_revision)
	assert(cargo.cargo_inventory.get_mutation_revision() == cargo_revision)
	assert(stage_a.get_staged_inventory().get_mutation_revision() == stage_revision)
	assert(registry.claim_count() == 2 and escrow.held_count() == 0)
	assert(cargo.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	print("PASS ", mode, " 2: Genuine complete physical history matches; query does not move stock")

	# Actually send an identical item from a different original supplier
	# through the entire path, then restore the enrolled source geometry.
	var foreign_belt: ConveyorSegment = partial_port.connected_conveyor
	var partial_pose: Transform3D = partial.global_transform
	if foreign_belt != null:
		assert(foreign_belt.disconnect_building_port(partial_port))
	assert(first_segment.disconnect_building_port(near_port))
	var marker := first_segment.get_node("InputEndpoint") as Marker3D
	var desired := marker.global_transform * Transform3D(Basis(Vector3.UP, PI), Vector3.ZERO)
	partial.global_transform = desired * partial_port.transform.affine_inverse()
	assert(first_segment.try_connect_building_port(partial_port))
	assert(_travel(steps))
	assert(first_segment.disconnect_building_port(partial_port))
	partial.global_transform = partial_pose
	if foreign_belt != null:
		assert(foreign_belt.try_connect_building_port(partial_port))
	assert(first_segment.try_connect_building_port(near_port))
	assert(descriptor.validate())
	assert(not descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(cargo.cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	print("PASS ", mode, " 3: Foreign real cargo stays foreign after legitimate geometry restored")

	assert(_travel(steps))
	assert(descriptor.matches_legacy_cargo(final_segment, ingot))
	var final_pose: Transform3D = final_segment.global_transform
	final_segment.global_position += Vector3(0, 0, 10)
	assert(not descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	final_segment.global_transform = final_pose
	assert(descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(cargo.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(partial_stock.transfer_to(cargo.cargo_inventory, ingot, 1) == 1)
	assert(not descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(cargo.cargo_inventory.transfer_to(partial_stock, ingot, 1) == 1)
	print("PASS ", mode, " 4: Broken geometry and same-type replacement cannot validate")

	assert(_travel(steps))
	var flag: String = "enable_isolated_multi_belt_route_guard"
	match mode:
		"single": flag = "enable_isolated_single_belt_route_guard"
		"splitter": flag = "enable_isolated_splitter_branch_guard"
		"merger": flag = "enable_isolated_merger_route_guard"
		"forward": flag = "enable_isolated_composite_route_guard"
		"reverse": flag = "enable_isolated_reverse_composite_route_guard"
	receiver.set(flag, false)
	assert(descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(final_segment))
	receiver.set(flag, true)
	assert(receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(cargo.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	# Every selected tracked junction must still have a valid proof epoch.
	for value: Variant in steps:
		if value is Dictionary:
			assert(_travel(steps))
			var port := value["input"] as ItemPortComponent
			var junction := port.get_parent()
			var component := junction.get_node_or_null("SplitterComponent") as ConveyorSplitterComponent
			if component != null:
				component.enable_isolated_splitter_provenance = false
				component.enable_isolated_splitter_provenance = true
			else:
				var merge := junction.get_node("MergerComponent") as ConveyorMergerComponent
				merge.enable_isolated_merger_provenance = false
				merge.enable_isolated_merger_provenance = true
			assert(not descriptor.matches_legacy_cargo(final_segment, ingot))
			assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
			assert(cargo.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	print("PASS ", mode, " 5: Cargo proof never substitutes for receiver guard; junction epochs remain authoritative")

	for i: int in range(3):
		assert(_travel(steps))
		assert(descriptor.matches_legacy_cargo(final_segment, ingot))
		assert(receiver.can_accept_belt_item(final_segment, ingot, 1))
		assert(ConveyorBuildingTransfer.try_unload_from_belt(final_segment))
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	var reservation: int = registry.reserve_for_site(first, escrow)
	assert(reservation > 0 and escrow.reservation_for(first) == reservation)
	assert(_travel(steps))
	assert(descriptor.matches_legacy_cargo(final_segment, ingot))
	assert(not receiver.can_accept_belt_item(final_segment, ingot, 1))
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(final_segment))
	assert(first.job.cancel())
	assert(escrow.held_count() == 0)
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(final_segment))
	assert(cargo.cargo_inventory.transfer_to(near_stock, ingot, 1) == 1)
	assert(stage_a.get_staged_inventory().get_amount(ingot) == 3)
	assert(near_stock.get_amount(ingot) == 1 and partial_stock.get_amount(ingot) == 2)
	assert(far_stock.get_amount(ingot) == 3 and wrong_stock.get_amount(ore) == 9)
	assert(stage_b.get_staged_inventory().get_total_amount() == 0)
	sandbox.free()
	assert(not descriptor.validate())
	print("PASS ", mode, " 6: Escrow, cancellation, independent site and full stock conservation remain intact")
	return true


# Execute the real helper for each connection, never fabricate observations.
func _travel(steps: Array) -> bool:
	var previous: ConveyorSegment = null
	for value: Variant in steps:
		if value is ConveyorSegment:
			var belt := value as ConveyorSegment
			if previous == null:
				if not ConveyorBuildingTransfer.try_load_into_belt(belt):
					return false
			elif not ConveyorTransportLink.try_transfer_forward(previous):
				return false
			previous = belt
		elif value is Dictionary:
			if previous == null or not ConveyorBuildingTransfer.try_unload_from_belt(previous):
				return false
			var port := value["input"] as ItemPortComponent
			var building := port.get_parent()
			var split := building.get_node_or_null("SplitterComponent") as ConveyorSplitterComponent
			if split != null:
				if not split.advance_split():
					return false
			else:
				var merge := building.get_node_or_null("MergerComponent") as ConveyorMergerComponent
				if merge == null or not merge.advance_merge():
					return false
			previous = null
		else:
			return false
	return previous != null
