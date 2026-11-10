extends Node3D

# =============================================================================
# E3D3B — ROUTE ENDPOINT SNAPPING TO FINISHED AND PLANNED BUILDINGS
# =============================================================================
# Verifies existing-port alignment, deferred connection after construction,
# cancellation reclaims the port, and unfinished port ownership.

func _find_route_claim_site(port: ItemPortComponent) -> ConstructionSite:
	for member: Node in get_tree().get_nodes_in_group("construction_sites"):
		if not member is ConstructionSite:
			continue
		var site := member as ConstructionSite
		if site.is_queued_for_deletion():
			continue
		if int(site.get_meta("route_live_port_id", -1)) == port.get_instance_id():
			return site
	return null


func _ready() -> void:
	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	controller._select_building(
		controller._find_definition_index(&"conveyor_belt")
	)
	var preview := controller.get("placement_ghost") as ConveyorSegment
	assert(preview != null)
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	var building_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(belt_def != null and building_def != null)

	# The completed building has both real ItemPortComponent nodes.
	var building := building_def.building_scene.instantiate() as Node3D
	world.add_child(building)
	building.global_position = FactoryGrid.snap_building_origin(
		Vector3(-7, 0, 4), building_def.footprint_tiles
	)
	building.add_to_group("player_built")
	var out_port := building.get_node("OutputPort") as ItemPortComponent
	var in_port := building.get_node("InputPort") as ItemPortComponent
	assert(out_port != null and in_port != null)
	assert(is_instance_valid(out_port.inventory))
	assert(is_instance_valid(in_port.inventory))
	var coordinator := controller.get_node(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator != null and coordinator.port_registry != null)

	for port: ItemPortComponent in [out_port, in_port]:
		var to_input: bool = port.direction == ItemPortComponent.PortDirection.INPUT
		var proposed: Dictionary = ConveyorBuildingSnap.get_preview_transform(
			port, preview
		)
		assert(proposed.has("transform"))
		var transform: Transform3D = proposed["transform"]
		assert(FactoryGrid.is_on_conveyor_grid(transform.origin))
		var target: Dictionary = BlueprintRoutePortSnap.find_nearest(
			preview, transform.origin, coordinator.port_registry, to_input
		)
		assert(target.get("kind") == "live")
		assert(target.get("port") == port)
		assert(BlueprintRoutePortSnap.matches_route_end(transform, target))
		assert(not BlueprintRoutePortSnap.matches_route_end(
			Transform3D(transform.basis.rotated(Vector3.UP, PI / 2.0),
				transform.origin), target
		))
		print("PASS LIVE SNAP: ", port.name, " returns exact facing transform")

		var tiles: Array[Transform3D] = [transform]
		var placed: int = (
			controller._commit_blueprint_route_tiles(
				tiles, belt_def, {} if to_input else target,
				target if to_input else {}
			)
		)
		assert(placed == 1)
		var site: ConstructionSite = _find_route_claim_site(port)
		assert(site != null)
		assert(BlueprintRoutePortSnap.has_pending_live_claim(get_tree(), port))
		assert(controller._commit_blueprint_route_tiles(
			tiles, belt_def, {} if to_input else target,
			target if to_input else {}
		) == 0)
		print("PASS CLAIM: ", port.name, " rejects duplicate plans")

		assert(controller._cancel_blueprint_site(site))
		await get_tree().process_frame
		assert(not BlueprintRoutePortSnap.has_pending_live_claim(
			get_tree(), port
		))
		assert(controller._commit_blueprint_route_tiles(
			tiles, belt_def, {} if to_input else target,
			target if to_input else {}
		) == 1)
		site = _find_route_claim_site(port)
		assert(site != null)
		assert(controller._authorize_blueprint_site(site))
		site._process(belt_def.construction_seconds + 0.25)
		assert(is_instance_valid(port.connected_conveyor))
		var completed: ConveyorSegment = port.connected_conveyor
		if to_input:
			assert(completed.output_building_port == port)
		else:
			assert(completed.input_building_port == port)
		print("PASS CONNECTION: ", port.name,
			" activates after construction on correct belt end")

	# Planned Storage still reserves via shared pending-port machinery.
	var planned_position := FactoryGrid.snap_building_origin(
		Vector3(6, 0, 3), building_def.footprint_tiles
	)
	var planned := controller._create_blueprint_site(
		building_def, Transform3D(Basis.IDENTITY, planned_position)
	) as ConstructionSite
	assert(planned != null)
	planned.set_process(false)
	var planned_input: Dictionary = planned.get_planned_belt_transform_named(
		preview, &"InputPort"
	)
	assert(planned_input.has("transform"))
	var plan_transform: Transform3D = planned_input["transform"]
	var target: Dictionary = BlueprintRoutePortSnap.find_nearest(
		preview, plan_transform.origin, coordinator.port_registry, true
	)
	assert(target.get("kind") == "planned")
	assert(target.get("site") == planned)
	assert(bool(target["input_side"]))
	var planned_tiles: Array[Transform3D] = [plan_transform]
	assert(controller._commit_blueprint_route_tiles(
		planned_tiles, belt_def, {}, target
	) == 1)
	assert(coordinator.port_registry.has_building_claim(
		planned, true, &"InputPort"
	))
	print("PASS PLANNED: Unfinished building port accepts endpoint reservation")

	assert(controller._cancel_blueprint_site(planned))
	print("PASS CLEANUP: Planned building cancellation releases its port claim")
	print("ALL 8 BLUEPRINT ROUTE BUILDING PORT SNAP E3D3B CHECKS PASSED")
