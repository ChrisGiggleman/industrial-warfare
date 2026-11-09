extends Node3D

# =============================================================================
# SANDBOX BLUEPRINT PLANNING — PLAYER CONTROL INTEGRATION REGRESSION
# =============================================================================
# Tests building-only planning, spatial reservations, explicit authorization
# and cancellation. Live power, worker and material delivery are not created.

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
	var defaults := load("res://scripts/world_interaction.gd").new()
	assert(not defaults.enable_blueprint_planning)
	assert(not defaults.blueprint_sandbox_debug_requirements)
	defaults.free()
	print("PASS A: Building Blueprint Mode and debug override are opt-in only")

	assert(not controller._toggle_blueprint_mode())
	controller._toggle_placement_mode()
	assert(controller.placement_mode_active)
	assert(controller._toggle_blueprint_mode())
	assert(controller.blueprint_mode_active)
	var hud := world.get_node("BuildHUD")
	assert(hud.build_title.text == "BLUEPRINT MODE (TEST)")
	assert(hud.controls_label.text.contains("E Authorize"))
	print("PASS B: Player Build Mode toggles a visible blueprint interface")

	var storage := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var conveyor := load("res://data/buildings/conveyor_belt.tres") as BuildingDefinition
	var turret := load(
		"res://data/buildings/prototype_defensive_turret.tres"
	) as BuildingDefinition
	assert(storage != null and conveyor != null and turret != null)
	var transform := Transform3D(
		Basis(Vector3.UP, deg_to_rad(90.0)),
		Vector3(-5.0, 0.0, 2.0)
	)
	assert(controller._blueprint_placement_clear(storage, transform))
	var storage_site := controller._create_blueprint_site(
		storage, transform
	) as ConstructionSite
	assert(storage_site != null)
	storage_site.set_process(false)
	assert(storage_site.job.state == ConstructionJob.State.PLANNED)
	assert(storage_site.get_node_or_null("ReservedFootprint/CollisionShape3D") != null)
	assert(storage_site.get_node_or_null("InventoryComponent") == null)
	assert(storage_site.get_planned_port(true) != null)
	assert(storage_site.get_planned_port(false) != null)
	print("PASS C: A rotated Storage blueprint reserves footprint and ports only")

	assert(not controller._blueprint_placement_clear(storage, transform))
	assert(controller._create_blueprint_site(storage, transform) == null)
	var offset := Transform3D(
		transform.basis, transform.origin + Vector3(0.2, 0.0, 0.0)
	)
	assert(not controller._blueprint_placement_clear(storage, offset))
	print("PASS D: Overlapping and off-grid plans are rejected without duplicate sites")

	assert(controller._create_blueprint_site(
		conveyor, Transform3D(Basis.IDENTITY, Vector3(-2.0, 0.0, 2.0))
	) == null)
	assert(not controller._authorize_blueprint_site(null))
	assert(not controller._cancel_blueprint_site(null))
	print("PASS E: Unsupported belt plans and invalid targets fail closed")

	controller.blueprint_sandbox_debug_requirements = false
	assert(controller._authorize_blueprint_site(storage_site))
	assert(storage_site.job.state == ConstructionJob.State.QUEUED)
	assert(storage_site.job.get_wait_reasons() == [
		&"power", &"materials", &"workers"
	])
	storage_site._process(50.0)
	assert(is_zero_approx(storage_site.get_progress()))
	assert(not storage_site.is_completed())
	print("PASS F: Authorized plan waits without real power, materials or workers")

	assert(storage_site.job.set_availability(true, true, true))
	storage_site._process(4.0)
	assert(is_equal_approx(storage_site.get_progress(), 0.4))
	assert(storage_site.job.set_availability(false, true, true))
	storage_site._process(50.0)
	assert(storage_site.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(storage_site.get_progress(), 0.4))
	print("PASS G: Site progress pauses when a required service disappears")

	var completed: Array[Node3D] = []
	storage_site.building_completed.connect(
		func(building: Node3D) -> void: completed.append(building)
	)
	assert(storage_site.job.set_availability(true, true, true))
	storage_site._process(6.0)
	assert(completed.size() == 1)
	assert(storage_site.is_queued_for_deletion())
	var built := completed[0]
	assert(built.get_node_or_null("InventoryComponent") is InventoryComponent)
	assert(built.get_node_or_null("InputPort") is ItemPortComponent)
	assert(built.global_transform.is_equal_approx(transform))
	print("PASS H: Authorized planned Storage activates one real rotated building")

	assert(not controller._cancel_blueprint_site(storage_site))
	assert(not controller._authorize_blueprint_site(storage_site))
	print("PASS I: Completed blueprints cannot be cancelled or reauthorized")

	var turret_transform := Transform3D(
		Basis.IDENTITY, Vector3(5.0, 0.0, -2.0)
	)
	var turret_site := controller._create_blueprint_site(
		turret, turret_transform
	) as ConstructionSite
	assert(turret_site != null)
	turret_site.set_process(false)
	assert(turret_site.get_node_or_null("BuildingHealthComponent") == null)
	assert(controller._cancel_blueprint_site(turret_site))
	assert(turret_site.is_queued_for_deletion())
	assert(not turret_site.is_completed())
	print("PASS J: Cancelling a defensive blueprint cannot activate its turret")

	var second_transform := Transform3D(
		Basis.IDENTITY, Vector3(2.0, 0.0, 3.0)
	)
	var second := controller._create_blueprint_site(
		turret, second_transform
	) as ConstructionSite
	assert(second != null)
	second.set_process(false)
	controller.blueprint_sandbox_debug_requirements = true
	assert(controller._authorize_blueprint_site(second))
	assert(second.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(second.job.get_wait_reasons().is_empty())
	second._process(turret.construction_seconds)
	assert(second.is_queued_for_deletion())
	assert(second.is_completed())
	print("PASS K: Explicit sandbox-only override can progress an authorized plan")

	assert(controller._toggle_blueprint_mode())
	assert(not controller.blueprint_mode_active)
	assert(hud.build_title.text == "BUILD MODE")
	controller._toggle_placement_mode()
	assert(not controller.placement_mode_active)
	assert(not controller.blueprint_mode_active)
	print("PASS L: Leaving planning restores ordinary Build Mode and exits cleanly")

	print("ALL 12 SANDBOX BLUEPRINT PLANNING TESTS PASSED")
