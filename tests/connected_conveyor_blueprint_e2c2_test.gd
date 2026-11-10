extends Node3D

# =============================================================================
# CONNECTED CONVEYOR BLUEPRINTS — PHASE E2C2 SANDBOX REGRESSION
# =============================================================================
# Verifies player-sandbox blueprint route discovery, reversible L visuals,
# delayed physical activation and conserved cargo. Normal Build Mode and
# the Main scene remain on the original operational path.

func _plan(
	controller: Node,
	definition: BuildingDefinition,
	location: Vector3,
	yaw: float = 0.0
) -> ConstructionSite:
	var transform := Transform3D(
		Basis(Vector3.UP, deg_to_rad(yaw)), location
	)
	var site := controller._create_straight_conveyor_blueprint(
		definition, transform
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _finish(controller: Node, site: ConstructionSite) -> ConveyorSegment:
	var results: Array[Node3D] = []
	site.building_completed.connect(
		func(built: Node3D) -> void: results.append(built)
	)
	assert(controller._authorize_blueprint_site(site))
	site._process(site.target_definition.construction_seconds)
	assert(results.size() == 1)
	var belt := results[0] as ConveyorSegment
	assert(belt != null)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _cargo(belt: ConveyorSegment) -> InventoryComponent:
	return belt.get_node("CargoInventory") as InventoryComponent


func _ready() -> void:
	var world_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(world_scene != null)
	var world := world_scene.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.enable_blueprint_planning)
	assert(controller.enable_connected_conveyor_blueprints)
	assert(controller.blueprint_sandbox_debug_requirements)
	var coordinator := controller.get_node_or_null(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator != null)
	assert(coordinator.registry != null and coordinator.activator != null)
	print("PASS A: Sandbox alone initializes connected blueprint services")

	var definition := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ore != null)
	var first := _plan(controller, definition, Vector3(-8, 0, -1))
	var second := _plan(controller, definition, Vector3(-8, 0, -2))
	assert(coordinator.registry.claim_count() == 2)
	assert(not first.has_meta("planned_conveyor_turn"))
	assert(not second.has_meta("planned_conveyor_turn"))
	assert(first.get_node_or_null("CargoInventory") == null)
	assert(second.get_node_or_null("ConveyorTransportTimer") == null)
	print("PASS B: Adjacent straight blueprints reserve directed nonoperational link")

	var built_first := _finish(controller, first)
	assert(built_first.next_segment == null)
	var built_second := _finish(controller, second)
	assert(built_first.next_segment == built_second)
	assert(built_second.previous_segment == built_first)
	assert(coordinator.registry.claim_count() == 0)
	print("PASS C: Completed straight pair connects after its second job finishes")

	assert(_cargo(built_first).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(built_first))
	assert(_cargo(built_first).get_amount(ore) == 0)
	assert(_cargo(built_second).get_amount(ore) == 1)
	print("PASS D: Connected straight plan conserves the transferred item")

	var right_start := _plan(controller, definition, Vector3(-5, 0, 2))
	var original_output := (
		right_start.get_node("PlannedOutputEndpoint") as Marker3D
	).transform
	var right_end := _plan(controller, definition, Vector3(-4, 0, 2), -90.0)
	assert(right_start.get_meta("planned_conveyor_turn") == ConveyorTurnIntent.Turn.RIGHT)
	var right_mesh := right_start.get_node("ConstructionPlaceholder") as MeshInstance3D
	assert(right_mesh.mesh is ArrayMesh)
	assert((right_start.get_node("PlannedDirectionArrow") as Label3D).text == "↱")
	assert(right_start.get_node_or_null("CargoInventory") == null)
	print("PASS E: Right-angle reservation renders L-shaped inactive source blueprint")

	var right_template := (
		ConveyorPieceSelector.RIGHT_CORNER_SCENE.instantiate() as ConveyorSegment
	)
	assert((right_start.get_node("PlannedOutputEndpoint") as Marker3D).transform.is_equal_approx(
		(right_template.get_node("OutputEndpoint") as Marker3D).transform
	))
	right_template.free()
	print("PASS F: Planned right corner matches the physical corner endpoint")

	assert(controller._cancel_blueprint_site(right_end))
	assert(right_end.is_queued_for_deletion())
	assert(coordinator.registry.claim_count() == 0)
	assert(not right_start.has_meta("planned_conveyor_turn"))
	assert((right_start.get_node("ConstructionPlaceholder") as MeshInstance3D).mesh is BoxMesh)
	assert((right_start.get_node("PlannedOutputEndpoint") as Marker3D).transform.is_equal_approx(
		original_output
	))
	assert((right_start.get_node("PlannedDirectionArrow") as Label3D).text == "↑")
	print("PASS G: Cancelling the receiver releases route and restores straight visual")

	var left_start := _plan(controller, definition, Vector3(0, 0, 5))
	var left_end := _plan(controller, definition, Vector3(-1, 0, 5), 90.0)
	assert(left_start.get_meta("planned_conveyor_turn") == ConveyorTurnIntent.Turn.LEFT)
	assert((left_start.get_node("ConstructionPlaceholder") as MeshInstance3D).mesh is ArrayMesh)
	assert((left_start.get_node("PlannedDirectionArrow") as Label3D).text == "↰")
	print("PASS H: Left-angle route renders mirrored L-shaped blueprint")

	var left_belt_end := _finish(controller, left_end)
	assert(left_belt_end.previous_segment == null)
	var left_belt_start := _finish(controller, left_start)
	assert(left_belt_start.next_segment == left_belt_end)
	assert(left_belt_end.previous_segment == left_belt_start)
	assert(left_belt_start.get_meta("conveyor_turn") == ConveyorTurnIntent.Turn.LEFT)
	print("PASS I: Receiver-first left turn activates correct real corner")

	assert(_cargo(left_belt_start).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(left_belt_start))
	assert(_cargo(left_belt_start).get_amount(ore) == 0)
	assert(_cargo(left_belt_end).get_amount(ore) == 1)
	print("PASS J: Left-turn blueprint conserves cargo after completion")

	var right_second := _plan(controller, definition, Vector3(3, 0, 1))
	var right_receiver := _plan(controller, definition, Vector3(4, 0, 1), -90.0)
	assert(right_second.get_meta("planned_conveyor_turn") == ConveyorTurnIntent.Turn.RIGHT)
	var right_source_belt := _finish(controller, right_second)
	assert(right_source_belt.next_segment == null)
	var right_target_belt := _finish(controller, right_receiver)
	assert(right_source_belt.next_segment == right_target_belt)
	assert(right_source_belt.get_meta("conveyor_turn") == ConveyorTurnIntent.Turn.RIGHT)
	assert(right_target_belt.previous_segment == right_source_belt)
	print("PASS K: Source-first right-turn blueprint connects after receiver completes")

	var wrong_first := _plan(controller, definition, Vector3(7, 0, 0))
	var wrong_second := _plan(controller, definition, Vector3(8, 0, 0), 90.0)
	assert(not wrong_first.has_meta("planned_conveyor_turn"))
	assert(coordinator.registry.claim_count() == 0)
	assert(wrong_second.job.state == ConstructionJob.State.PLANNED)
	print("PASS L: Wrong-facing neighbor is not reserved or converted")

	var label := right_start.get_node("ConstructionLabel") as Label3D
	assert(label.font_size == 15)
	assert(label.pixel_size < 0.008)
	assert((right_start.get_node("ConstructionPlaceholder") as MeshInstance3D).mesh is BoxMesh)
	print("PASS M: Compact conveyor labels and restored previews retain readability")

	var defaults := load("res://scripts/world_interaction.gd") as GDScript
	assert(defaults != null)
	var default_controller := defaults.new() as Node
	assert(not default_controller.get("enable_connected_conveyor_blueprints"))
	assert(not default_controller.get("enable_blueprint_planning"))
	default_controller.free()
	print("PASS N: Main defaults keep connected blueprint routing disabled")

	# Existing normal placement must remain reachable with P mode off.
	assert(not controller.blueprint_mode_active)
	controller._toggle_placement_mode()
	assert(controller.placement_mode_active)
	assert(controller._toggle_blueprint_mode())
	assert(controller.blueprint_mode_active)
	assert(controller._toggle_blueprint_mode())
	assert(not controller.blueprint_mode_active)
	controller._toggle_placement_mode()
	print("PASS O: Blueprint control toggles without replacing ordinary Build Mode")

	var chain_a := _plan(controller, definition, Vector3(6, 0, -3))
	var chain_b := _plan(controller, definition, Vector3(6, 0, -4))
	var chain_c := _plan(controller, definition, Vector3(6, 0, -5))
	assert(coordinator.registry.claim_count() == 4)
	assert(not chain_a.has_meta("planned_conveyor_turn"))
	assert(not chain_b.has_meta("planned_conveyor_turn"))
	var middle := _finish(controller, chain_b)
	assert(middle.previous_segment == null and middle.next_segment == null)
	var last := _finish(controller, chain_c)
	assert(middle.next_segment == last)
	var first_belt := _finish(controller, chain_a)
	assert(first_belt.next_segment == middle)
	assert(middle.previous_segment == first_belt)
	assert(coordinator.registry.claim_count() == 0)
	print("PASS P: Placed three-belt blueprint chain connects across either build order")

	assert(_cargo(first_belt).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(first_belt))
	assert(ConveyorTransportLink.try_transfer_forward(middle))
	assert(_cargo(first_belt).get_amount(ore) == 0)
	assert(_cargo(middle).get_amount(ore) == 0)
	assert(_cargo(last).get_amount(ore) == 1)
	print("PASS Q: Three-belt sandbox blueprint route conserves cargo over two hops")

	print("ALL 17 CONNECTED CONVEYOR BLUEPRINT E2C2 TESTS PASSED")
