extends Node3D

# =============================================================================
# STRAIGHT CONVEYOR BLUEPRINT — SANDBOX PHASE E1 REGRESSION
# =============================================================================
# Validates one independent non-operational belt plan. E1 intentionally does
# not promise connections, automatic corner conversion or material delivery.

func _ready() -> void:
	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	assert(world != null)
	add_child(world)
	var controller = world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.enable_blueprint_planning)
	assert(controller.blueprint_sandbox_debug_requirements)
	var definition := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(definition != null)
	assert(definition.footprint_tiles == Vector2i.ONE)
	assert(is_equal_approx(definition.construction_seconds, 2.0))
	print("PASS A: Sandbox enables separate two-second straight belt plans")

	var first_transform := Transform3D(
		Basis(Vector3.UP, deg_to_rad(90.0)),
		Vector3(-4.0, 0.0, -1.0)
	)
	assert(ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		definition, first_transform
	))
	var first := controller._create_straight_conveyor_blueprint(
		definition, first_transform
	) as ConstructionSite
	assert(first != null)
	first.set_process(false)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(not first.is_completed())
	assert(is_equal_approx(first.job.get_remaining_seconds(), 2.0))
	print("PASS B: Rotated straight blueprint remains PLANNED at zero progress")

	assert(first.get_node_or_null("ReservedFootprint/CollisionShape3D") != null)
	assert(first.get_node_or_null("PlannedInputEndpoint") is Marker3D)
	assert(first.get_node_or_null("PlannedOutputEndpoint") is Marker3D)
	assert(first.get_node_or_null("PlannedDirectionArrow") is Label3D)
	assert(first.get_node_or_null("CargoInventory") == null)
	assert(first.get_node_or_null("ConveyorTransportTimer") == null)
	assert(first.get_node_or_null("ConveyorTransportComponent") == null)
	assert((first.get_node("ConstructionLabel") as Label3D).text == "PLANNED 0%")
	print("PASS C: Planned belt reserves endpoints without cargo or transport")

	assert(not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		definition, first_transform
	))
	assert(controller._create_straight_conveyor_blueprint(
		definition, first_transform
	) == null)
	assert(controller._create_straight_conveyor_blueprint(
		definition, Transform3D(
			first_transform.basis,
			first_transform.origin + Vector3(0.25, 0.0, 0.0)
		)
	) == null)
	print("PASS D: Duplicate and off-grid belt plans are rejected safely")

	var invalid_rotation := Transform3D(
		Basis(Vector3.UP, deg_to_rad(45.0)),
		Vector3(-2.0, 0.0, -2.0)
	)
	assert(not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		definition, invalid_rotation
	))
	var storage := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(storage != null)
	assert(not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		storage, first_transform
	))
	print("PASS E: Noncardinal or nonbelt placement is rejected")

	controller.blueprint_sandbox_debug_requirements = false
	assert(controller._authorize_blueprint_site(first))
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_wait_reasons() == [
		&"power", &"materials", &"workers"
	])
	first._process(20.0)
	assert(is_zero_approx(first.get_progress()))
	assert(first.get_node_or_null("CargoInventory") == null)
	print("PASS F: Unpowered and unsupplied planned belt cannot build")

	assert(first.job.set_availability(true, true, true))
	first._process(1.0)
	assert(is_equal_approx(first.get_progress(), 0.5))
	assert(first.get_node_or_null("CargoInventory") == null)
	assert((first.get_node("ConstructionLabel") as Label3D).text == "CONSTRUCTING 50%")
	print("PASS G: One second creates only half of a nonoperational site")

	assert(first.job.set_availability(false, true, true))
	first._process(100.0)
	assert(first.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(first.get_progress(), 0.5))
	assert((first.get_node("ConstructionLabel") as Label3D).text == "PAUSED 50%")
	print("PASS H: Power loss pauses a partly built belt without activation")

	var planned_input := (
		first.get_node("PlannedInputEndpoint") as Marker3D
	).global_transform
	var planned_output := (
		first.get_node("PlannedOutputEndpoint") as Marker3D
	).global_transform
	var completed: Array[Node3D] = []
	first.building_completed.connect(
		func(entity: Node3D) -> void: completed.append(entity)
	)
	assert(first.job.set_availability(true, true, true))
	first._process(1.0)
	assert(completed.size() == 1)
	assert(first.is_queued_for_deletion())
	var belt := completed[0] as ConveyorSegment
	assert(belt != null)
	assert(belt.get_node_or_null("CargoInventory") is InventoryComponent)
	assert(belt.get_node_or_null("ConveyorTransportTimer") is ConveyorTransportTimer)
	assert(belt.get_node_or_null("ConveyorTransportComponent") is ConveyorTransportComponent)
	print("PASS I: Two-second completion creates one actual belt and inventory")

	assert(belt.global_transform.is_equal_approx(first_transform))
	assert((belt.get_node("InputEndpoint") as Marker3D).global_transform.is_equal_approx(
		planned_input
	))
	assert((belt.get_node("OutputEndpoint") as Marker3D).global_transform.is_equal_approx(
		planned_output
	))
	print("PASS J: Rotation and both directed endpoints survive activation")

	assert(belt.previous_segment == null)
	assert(belt.next_segment == null)
	assert(belt.input_building_port == null)
	assert(belt.output_building_port == null)
	assert(belt.can_demolish_safely())
	first._process(5.0)
	assert(completed.size() == 1)
	print("PASS K: No phantom connections, double builds or loaded cargo")

	var second_transform := Transform3D(
		Basis.IDENTITY, Vector3(1.0, 0.0, -3.0)
	)
	var second := controller._create_straight_conveyor_blueprint(
		definition, second_transform
	) as ConstructionSite
	assert(second != null)
	second.set_process(false)
	assert(controller._cancel_blueprint_site(second))
	assert(second.is_queued_for_deletion())
	assert(not second.is_completed())
	assert(not controller._authorize_blueprint_site(second))
	print("PASS L: Cancelling a planned belt prevents physical activation")

	await get_tree().process_frame
	assert(ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		definition, second_transform
	))
	var replacement := controller._create_straight_conveyor_blueprint(
		definition, second_transform
	) as ConstructionSite
	assert(replacement != null)
	replacement.set_process(false)
	controller.blueprint_sandbox_debug_requirements = true
	assert(controller._authorize_blueprint_site(replacement))
	assert(replacement.job.state == ConstructionJob.State.CONSTRUCTING)
	replacement._process(definition.construction_seconds)
	assert(replacement.is_completed())
	print("PASS M: Cancelled tile can be reused; sandbox override completes job")

	var defaults := load("res://scripts/world_interaction.gd") as GDScript
	assert(defaults != null)
	var controller_default := defaults.new() as Node
	assert(controller_default != null)
	assert(not controller_default.get("enable_blueprint_planning"))
	assert(not controller_default.get("blueprint_sandbox_debug_requirements"))
	controller_default.free()
	print("PASS N: Main default Build Mode remains opt-out of blueprint belts")

	print("ALL 14 STRAIGHT CONVEYOR BLUEPRINT E1 TESTS PASSED")
