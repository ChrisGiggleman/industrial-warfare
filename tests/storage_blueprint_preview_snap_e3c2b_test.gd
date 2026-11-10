extends Node3D

# =============================================================================
# SANDBOX STORAGE BLUEPRINT SNAP PREVIEWS — E3C2B REGRESSION
# =============================================================================
# Read-only cursor selection of unfinished Storage input/output geometry,
# followed by a normal blueprint commit through validated E3c2a services.
# Main and ordinary non-blueprint conveyor placement are unchanged.

func _plan(
	controller: Node,
	definition: BuildingDefinition,
	at: Vector3,
	yaw: float = 0.0
) -> ConstructionSite:
	var transform := Transform3D(
		Basis(Vector3.UP, deg_to_rad(yaw)), at
	)
	var site := controller._create_blueprint_site(
		definition, transform
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _ready() -> void:
	var world_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(world_scene != null)
	var world := world_scene.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	var coordinator := controller.get_node("BlueprintRouteCoordinator") as BlueprintConveyorRouteCoordinator
	assert(coordinator != null)
	assert(controller.enable_connected_storage_blueprints)
	assert(is_instance_valid(coordinator.port_registry))
	assert(controller._get_storage_blueprint_snap_preview(Vector3.ZERO).is_empty())
	print("PASS A: Planned Storage preview snapping exists only behind sandbox feature flags")

	var storage_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(storage_def != null and belt_def != null)
	var storage := _plan(controller, storage_def, Vector3(-6, 0, 0))
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	assert(coordinator.port_registry.claim_count() == 0)
	assert(storage.get_planned_port(true) != null)
	assert(storage.get_planned_port(false) != null)
	print("PASS B: Unfinished Storage exposes independent free preview targets")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	controller._select_building(
		controller._find_definition_index(&"conveyor_belt")
	)
	var preview := controller.placement_ghost as ConveyorSegment
	assert(is_instance_valid(preview) and preview.is_inside_tree())
	assert(preview.is_in_group("construction_preview"))
	assert(preview.process_mode == Node.PROCESS_MODE_DISABLED)
	print("PASS C: Player Blueprint Mode uses the isolated straight-belt ghost")

	var input_placement: Dictionary = storage.get_planned_belt_transform(preview, true)
	assert(input_placement.has("transform"))
	var input_transform: Transform3D = input_placement["transform"]
	preview.global_transform = input_transform
	var input_choice: Dictionary = controller._get_storage_blueprint_snap_preview(
		input_transform.origin
	)
	assert(input_choice.get("site") == storage)
	assert(input_choice.get("input_side") == true)
	var chosen_input: Transform3D = input_choice["transform"]
	assert(chosen_input.is_equal_approx(input_transform))
	print("PASS D: Correctly oriented preview hard-snaps to future Storage input")

	var marker := storage.get_planned_port(true)
	var from_marker: Dictionary = controller._get_storage_blueprint_snap_preview(
		marker.global_position
	)
	assert(from_marker.get("site") == storage)
	assert(bool(from_marker.get("input_side", false)))
	print("PASS E: Cursor aimed at the visible planned input marker also snaps")

	var fractional: Dictionary = controller._get_storage_blueprint_snap_preview(
		marker.global_position + Vector3(0.12, 0, -0.12)
	)
	assert(fractional.get("site") == storage)
	assert(coordinator.port_registry.claim_count() == 0)
	assert(coordinator.claim_broker.claim_count() == 0)
	print("PASS F: Fractional cursor resolves exact transform without reserving")

	preview.rotation_degrees.y += 90.0
	assert(controller._get_storage_blueprint_snap_preview(
		input_transform.origin
	).is_empty())
	preview.global_transform = input_transform
	print("PASS G: A wrong-facing ghost is rejected without changing R rotation")

	# Interactive placement opts into auto-orientation; plain lookups
	# retain their directional guard for regression compatibility.
	preview.rotation_degrees.y += 90.0
	var auto_choice: Dictionary = controller._get_storage_blueprint_snap_preview(
		input_transform.origin, true
	)
	assert(auto_choice.get("site") == storage)
	assert((auto_choice["transform"] as Transform3D).is_equal_approx(
		input_transform
	))
	assert(not preview.global_transform.is_equal_approx(input_transform))
	preview.global_transform = input_transform
	print("PASS G2: Interactive preview offers correct port rotation despite wrong-facing belt")

	assert(controller._get_storage_blueprint_snap_preview(
		input_transform.origin + Vector3(1.0, 0, 0)
	).is_empty())
	print("PASS H: Outside the tight radius, preview reverts to free placement")

	var output_placement: Dictionary = storage.get_planned_belt_transform(preview, false)
	assert(output_placement.has("transform"))
	var output_transform: Transform3D = output_placement["transform"]
	preview.global_transform = output_transform
	var output_choice: Dictionary = controller._get_storage_blueprint_snap_preview(
		output_transform.origin
	)
	assert(output_choice.get("site") == storage)
	assert(output_choice.get("input_side") == false)
	assert((output_choice["transform"] as Transform3D).is_equal_approx(
		output_transform
	))
	print("PASS I: Storage output independently offers the outbound belt input")

	preview.global_transform = input_transform
	var belt_site := controller._create_straight_conveyor_blueprint(
		belt_def, chosen_input
	) as ConstructionSite
	assert(is_instance_valid(belt_site))
	belt_site.set_process(false)
	assert(coordinator.port_registry.claim_count() == 2)
	assert(coordinator.port_registry.has_building_claim(storage, true))
	assert(coordinator.port_registry.has_belt_claim(belt_site, true))
	assert(belt_site.get_node_or_null("CargoInventory") == null)
	print("PASS J: Commit uses displayed snap transform and reserves exactly one link")

	assert(controller._get_storage_blueprint_snap_preview(
		chosen_input.origin
	).is_empty())
	assert(coordinator.port_registry.claim_count() == 2)
	print("PASS K: Reserved and occupied input cannot offer duplicate preview")

	assert(controller._cancel_blueprint_site(belt_site))
	assert(coordinator.port_registry.claim_count() == 0)
	assert(coordinator.claim_broker.claim_count() == 0)
	await get_tree().process_frame
	assert(not is_instance_valid(belt_site))
	assert(not controller._get_storage_blueprint_snap_preview(
		input_transform.origin
	).is_empty())
	print("PASS L: Cancellation releases claim and restores its preview snap")

	var rotated := _plan(
		controller, storage_def, Vector3(5, 0, 1), 90.0
	)
	var rotated_in: Dictionary = rotated.get_planned_belt_transform(preview, true)
	assert(rotated_in.has("transform"))
	var rotated_transform: Transform3D = rotated_in["transform"]
	preview.global_transform = rotated_transform
	var rotated_choice: Dictionary = controller._get_storage_blueprint_snap_preview(
		rotated_transform.origin
	)
	assert(rotated_choice.get("site") == rotated)
	assert(rotated_choice.get("input_side") == true)
	assert((rotated_choice["transform"] as Transform3D).is_equal_approx(
		rotated_transform
	))
	print("PASS M: Rotated Storage offers the correct exact port-aligned transform")

	controller.enable_connected_storage_blueprints = false
	assert(controller._get_storage_blueprint_snap_preview(
		rotated_transform.origin
	).is_empty())
	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var main := main_scene.instantiate() as Node3D
	assert(not main.get_node("WorldInteraction").enable_connected_storage_blueprints)
	main.free()
	print("PASS N: Disabled feature and Main gameplay retain their prior preview path")

	print("ALL 15 STORAGE BLUEPRINT PREVIEW SNAP E3C2B TESTS PASSED")
