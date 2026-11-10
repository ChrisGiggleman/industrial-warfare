extends Node3D

# =============================================================================
# E3D3B — THREE-CLICK L-ROUTE GAMEPLAY INTEGRATION
# =============================================================================
# Exercises the sandbox controller's state and actual planned-site creation
# without relying on screen coordinates or editor input injection.

func _ready() -> void:
	var packed: PackedScene = load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world: Node3D = packed.instantiate() as Node3D
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(bool(controller.get("enable_blueprint_route_tool")))
	assert(not bool(controller.get("_blueprint_l_route_mode")))
	assert(not controller._toggle_blueprint_l_route_mode())
	print("PASS A: Three-click mode cannot start outside Blueprint Mode")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	controller._select_building(
		controller._find_definition_index(&"conveyor_belt")
	)
	assert(controller._toggle_blueprint_l_route_mode())
	assert(bool(controller.get("_blueprint_l_route_mode")))
	print("PASS B: L toggles three-click mode with conveyor selected")

	var start := Vector3(-6, 0, 4)
	var corner := Vector3(-6, 0, 2)
	var finish := Vector3(-4, 0, 2)
	assert(controller._handle_blueprint_l_route_position(start) == 0)
	var anchor: Dictionary = controller.get("_route_anchor")
	assert(anchor.has("position") and not anchor.has("turn"))
	assert(get_tree().get_nodes_in_group("construction_sites").is_empty())
	print("PASS C: First point records a start without creating sites")

	assert(controller._handle_blueprint_l_route_position(start) == 0)
	anchor = controller.get("_route_anchor")
	assert(not anchor.has("turn"))
	assert(controller._handle_blueprint_l_route_position(corner) == 0)
	anchor = controller.get("_route_anchor")
	assert(anchor.has("turn"))
	print("PASS D: Invalid turn is rejected; valid turn is retained")

	assert(controller._handle_blueprint_l_route_position(
		Vector3(-6, 0, 0)
	) == 0)
	anchor = controller.get("_route_anchor")
	assert(anchor.has("position") and anchor.has("turn"))
	print("PASS E: Invalid endpoint preserves the first two points for retry")

	assert(controller._handle_blueprint_l_route_position(finish) == 5)
	anchor = controller.get("_route_anchor")
	assert(anchor.is_empty())
	var planned: Array[ConstructionSite] = []
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == world:
			planned.append(node as ConstructionSite)
	assert(planned.size() == 5)
	var pivot_site: ConstructionSite = null
	for site: ConstructionSite in planned:
		if site.global_position.is_equal_approx(corner):
			pivot_site = site
	assert(pivot_site != null)
	assert(pivot_site.has_meta("planned_conveyor_turn"))
	assert(int(pivot_site.get_meta("planned_conveyor_turn")) ==
		ConveyorTurnIntent.Turn.RIGHT)
	print("PASS F: Five planned sites include one automatic right-hand corner")

	var coordinator := controller.get_node(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator != null)
	assert(coordinator.registry.claim_count() == 8)
	assert(controller._handle_blueprint_l_route_position(start) == 0)
	assert((controller.get("_route_anchor") as Dictionary).is_empty())
	print("PASS G: Four links reserve endpoints and existing tiles reject overlaps")

	assert(controller._authorize_all_blueprint_sites() == 5)
	for site: ConstructionSite in planned:
		assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
		assert(site.job.get_progress() == 0.0)
	print("PASS H: Ctrl+E authorizes the L-route without skipping build times")

	for site: ConstructionSite in planned:
		assert(controller._cancel_blueprint_site(site))
	assert(coordinator.registry.claim_count() == 0)
	assert(not controller._toggle_blueprint_l_route_mode())
	assert(not bool(controller.get("_blueprint_l_route_mode")))
	print("PASS I: Cancellation releases connections; L returns to straight mode")

	print("ALL 9 E3D3B THREE-CLICK L-ROUTE INTEGRATION TESTS PASSED")
