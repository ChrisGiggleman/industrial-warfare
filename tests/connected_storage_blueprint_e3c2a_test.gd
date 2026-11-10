extends Node3D

# =============================================================================
# SANDBOX BLUEPRINT STORAGE PORTS — PHASE E3C2A REGRESSION
# =============================================================================
# Tests automatic reservations when players plan Storage/belts in either
# order. Physical connections use E3c1 only after timed completion.
# All power, materials and workers here are explicit sandbox overrides.

func _plan_storage(
	controller: Node,
	definition: BuildingDefinition,
	position: Vector3,
	yaw: float = 0.0
) -> ConstructionSite:
	var placement := Transform3D(
		Basis(Vector3.UP, deg_to_rad(yaw)), position
	)
	var site := controller._create_blueprint_site(
		definition, placement
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _plan_belt(
	controller: Node,
	definition: BuildingDefinition,
	position: Vector3,
	yaw: float = 0.0
) -> ConstructionSite:
	var placement := Transform3D(
		Basis(Vector3.UP, deg_to_rad(yaw)), position
	)
	var site := controller._create_straight_conveyor_blueprint(
		definition, placement
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _finish(controller: Node, site: ConstructionSite) -> Node3D:
	var built: Array[Node3D] = []
	site.building_completed.connect(
		func(entity: Node3D) -> void: built.append(entity)
	)
	assert(controller._authorize_blueprint_site(site))
	site._process(site.target_definition.construction_seconds)
	assert(built.size() == 1)
	assert(site.is_completed())
	var real: Node3D = built[0]
	if real is ConveyorSegment:
		(real.get_node(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer).set_process(false)
	return real


func _cargo(belt: ConveyorSegment) -> InventoryComponent:
	return belt.get_node("CargoInventory") as InventoryComponent


func _ready() -> void:
	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.enable_blueprint_planning)
	assert(controller.enable_connected_conveyor_blueprints)
	assert(controller.enable_connected_storage_blueprints)
	assert(controller.blueprint_sandbox_debug_requirements)
	var coordinator := controller.get_node(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator != null)
	assert(coordinator.enable_storage_port_blueprints)
	assert(is_instance_valid(coordinator.claim_broker))
	assert(is_instance_valid(coordinator.port_registry))
	assert(is_instance_valid(coordinator.port_activator))
	assert(is_instance_valid(coordinator.registry))
	assert(is_instance_valid(coordinator.activator))
	print("PASS A: Sandbox initializes both reservation systems with one broker")

	var storage_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(storage_def != null and belt_def != null and ore != null)

	var storage_site := _plan_storage(
		controller, storage_def, Vector3(-5, 0, 0)
	)
	assert(storage_site.job.state == ConstructionJob.State.PLANNED)
	assert(coordinator.port_registry.claim_count() == 0)
	assert(storage_site.get_node_or_null("InventoryComponent") == null)
	print("PASS B: Planned Storage remains inert with two future port markers")

	var input_site := _plan_belt(
		controller, belt_def, Vector3(-5, 0, 2)
	)
	var output_site := _plan_belt(
		controller, belt_def, Vector3(-5, 0, -2)
	)
	assert(coordinator.port_registry.claim_count() == 4)
	assert(coordinator.claim_broker.claim_count() == 4)
	assert(coordinator.port_registry.has_building_claim(storage_site, true))
	assert(coordinator.port_registry.has_building_claim(storage_site, false))
	assert(coordinator.port_registry.has_belt_claim(input_site, true))
	assert(coordinator.port_registry.has_belt_claim(output_site, false))
	print("PASS C: Placement automatically reserves Storage input and output")

	var upstream_site := _plan_belt(
		controller, belt_def, Vector3(-5, 0, 3)
	)
	assert(coordinator.registry.claim_count() == 2)
	assert(coordinator.port_registry.claim_count() == 4)
	assert(coordinator.claim_broker.claim_count() == 6)
	assert(upstream_site.get_node_or_null("CargoInventory") == null)
	print("PASS D: Mixed upstream belt and Storage routes use separate endpoint sides")

	var storage := _finish(controller, storage_site)
	var input_port := storage.get_node("InputPort") as ItemPortComponent
	var output_port := storage.get_node("OutputPort") as ItemPortComponent
	var inventory := storage.get_node("InventoryComponent") as InventoryComponent
	assert(input_port.connected_conveyor == null)
	assert(output_port.connected_conveyor == null)
	assert(coordinator.claim_broker.claim_count() == 6)
	print("PASS E: Storage-first completion cannot activate unfinished belts")

	var input_belt := _finish(controller, input_site) as ConveyorSegment
	assert(input_belt != null)
	assert(input_belt.output_building_port == input_port)
	assert(input_port.connected_conveyor == input_belt)
	assert(input_belt.previous_segment == null)
	assert(coordinator.claim_broker.claim_count() == 4)
	print("PASS F: Completed input belt activates one reciprocal Storage link")

	var output_belt := _finish(controller, output_site) as ConveyorSegment
	assert(output_belt != null)
	assert(output_belt.input_building_port == output_port)
	assert(output_port.connected_conveyor == output_belt)
	assert(coordinator.claim_broker.claim_count() == 2)
	print("PASS G: Output port activates independently without claiming upstream")

	var upstream_belt := _finish(controller, upstream_site) as ConveyorSegment
	assert(upstream_belt.next_segment == input_belt)
	assert(input_belt.previous_segment == upstream_belt)
	assert(coordinator.claim_broker.claim_count() == 0)
	assert(coordinator.port_registry.claim_count() == 0)
	assert(coordinator.registry.claim_count() == 0)
	print("PASS H: Completed upstream route links without unresolved claims")

	assert(_cargo(upstream_belt).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(upstream_belt))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(input_belt))
	assert(inventory.get_amount(ore) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(output_belt))
	assert(inventory.get_amount(ore) == 0)
	assert(_cargo(output_belt).get_amount(ore) == 1)
	assert(_cargo(upstream_belt).get_amount(ore) == 0)
	assert(_cargo(input_belt).get_amount(ore) == 0)
	print("PASS I: End-to-end planned Storage path conserves ore through both ports")

	assert(inventory.add_item(ore, 1) == 1)
	assert(not ConveyorBuildingTransfer.try_load_into_belt(output_belt))
	assert(inventory.get_amount(ore) == 1)
	assert(_cargo(output_belt).get_amount(ore) == 1)
	print("PASS J: Full outbound blueprint belt backpressures without losing ore")

	var cancel_storage := _plan_storage(
		controller, storage_def, Vector3(3, 0, 0)
	)
	var cancel_belt := _plan_belt(
		controller, belt_def, Vector3(3, 0, 2)
	)
	assert(coordinator.port_registry.claim_count() == 2)
	assert(controller._cancel_blueprint_site(cancel_storage))
	assert(not coordinator.port_registry.has_belt_claim(cancel_belt, true))
	assert(coordinator.claim_broker.claim_count() == 0)
	assert(cancel_belt.job.state == ConstructionJob.State.PLANNED)
	print("PASS K: Cancelling planned Storage releases adjacent belt without building")

	# Planning order can be reversed: register the belt before its Storage.
	var first_belt_site := _plan_belt(
		controller, belt_def, Vector3(3, 0, -2)
	)
	assert(coordinator.port_registry.claim_count() == 0)
	var second_storage_site := _plan_storage(
		controller, storage_def, Vector3(3, 0, -4)
	)
	assert(coordinator.port_registry.claim_count() == 2)
	assert(coordinator.port_registry.has_building_claim(second_storage_site, true))
	var first_belt := _finish(controller, first_belt_site) as ConveyorSegment
	assert(first_belt.output_building_port == null)
	var second_storage := _finish(controller, second_storage_site)
	assert(first_belt.output_building_port == second_storage.get_node("InputPort"))
	assert(coordinator.claim_broker.claim_count() == 0)
	print("PASS L: Belt-first planning and construction connect after Storage finishes")

	var rotated_site := _plan_storage(
		controller, storage_def, Vector3(-1, 0, -6), 90.0
	)
	var rot_basis := rotated_site.global_transform.basis
	var rot_input := _plan_belt(
		controller, belt_def,
		rotated_site.global_position + rot_basis * Vector3(0, 0, 2),
		90.0
	)
	var rot_output := _plan_belt(
		controller, belt_def,
		rotated_site.global_position + rot_basis * Vector3(0, 0, -2),
		90.0
	)
	assert(coordinator.port_registry.claim_count() == 4)
	var real_rot_input := _finish(controller, rot_input) as ConveyorSegment
	var real_rot_output := _finish(controller, rot_output) as ConveyorSegment
	var real_rot_storage := _finish(controller, rotated_site)
	assert(real_rot_input.output_building_port == real_rot_storage.get_node("InputPort"))
	assert(real_rot_output.input_building_port == real_rot_storage.get_node("OutputPort"))
	assert(coordinator.claim_broker.claim_count() == 0)
	print("PASS M: Rotated Storage automatically discovers and builds both ports")

	var wrong_storage := _plan_storage(
		controller, storage_def, Vector3(7, 0, -4)
	)
	var wrong_belt := _plan_belt(
		controller, belt_def, Vector3(7, 0, -2), 180.0
	)
	assert(wrong_storage.job.state == ConstructionJob.State.PLANNED)
	assert(wrong_belt.job.state == ConstructionJob.State.PLANNED)
	assert(coordinator.port_registry.claim_count() == 0)
	assert(coordinator.claim_broker.claim_count() == 0)
	print("PASS N: Reversed belt direction never reserves the wrong Storage port")

	var corner_a := _plan_belt(
		controller, belt_def, Vector3(7, 0, 2)
	)
	var corner_b := _plan_belt(
		controller, belt_def, Vector3(8, 0, 2), -90.0
	)
	assert(corner_a.get_meta("planned_conveyor_turn") == ConveyorTurnIntent.Turn.RIGHT)
	assert(coordinator.registry.claim_count() == 2)
	assert(coordinator.claim_broker.claim_count() == 2)
	assert(controller._cancel_blueprint_site(corner_b))
	assert(coordinator.registry.claim_count() == 0)
	assert(coordinator.claim_broker.claim_count() == 0)
	assert(not corner_a.has_meta("planned_conveyor_turn"))
	print("PASS O: Existing corner previews still reserve and cancel correctly")

	var defaults_script := load(
		"res://scripts/world_interaction.gd"
	) as GDScript
	var defaults := defaults_script.new() as Node
	assert(not defaults.get("enable_connected_storage_blueprints"))
	assert(not defaults.get("enable_connected_conveyor_blueprints"))
	defaults.free()
	assert(not input_belt.is_queued_for_deletion())
	assert(output_port.connected_conveyor == output_belt)
	print("PASS P: Main defaults remain opted out; completed factory stays intact")

	print("ALL 16 CONNECTED STORAGE BLUEPRINT E3C2A TESTS PASSED")
