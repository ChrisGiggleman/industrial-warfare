extends Node3D

# =============================================================================
# E3D1 — SANDBOX BATCH BLUEPRINT AUTHORIZATION REGRESSION
# =============================================================================
# Ctrl+E authorizes only eligible PLANNED jobs in the current sandbox world.
# Normal power/material/worker gates are unchanged.

func _plan(
	controller: Node, definition: BuildingDefinition, position: Vector3
) -> ConstructionSite:
	var site := controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, position)
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _ready() -> void:
	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	var storage := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(storage != null)
	assert(controller.enable_blueprint_planning)
	assert(controller._authorize_all_blueprint_sites() == 0)
	print("PASS A: Batch action requires active Blueprint Mode")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	var a := _plan(controller, storage, Vector3(-6, 0, 0))
	var b := _plan(controller, storage, Vector3(3, 0, 0))
	var cancelled := _plan(controller, storage, Vector3(7, 0, 0))
	assert(controller._cancel_blueprint_site(cancelled))
	assert(a.job.state == ConstructionJob.State.PLANNED)
	assert(b.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Two active plans and one cancelled plan coexist")

	assert(controller._authorize_all_blueprint_sites() == 2)
	assert(a.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(b.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(cancelled.job.state == ConstructionJob.State.CANCELLED)
	print("PASS C: Batch authorizes exactly two pending plans")

	assert(controller._authorize_all_blueprint_sites() == 0)
	assert(a.job.get_progress() == 0.0)
	assert(b.job.get_progress() == 0.0)
	print("PASS D: Repeated batch is idempotent and does not skip build time")

	# Switching off sandbox requirement overrides must leave new jobs
	# queued, not constructing without actual power/material/worker supply.
	controller.blueprint_sandbox_debug_requirements = false
	var waiting := _plan(controller, storage, Vector3(-2, 0, -6))
	assert(controller._authorize_all_blueprint_sites() == 1)
	assert(waiting.job.state == ConstructionJob.State.QUEUED)
	assert(waiting.job.get_wait_reasons().size() == 3)
	print("PASS E: Batch keeps power, materials and worker gates intact")

	assert(controller._toggle_blueprint_mode())
	assert(controller._authorize_all_blueprint_sites() == 0)
	print("PASS F: No batch authorization outside Blueprint Mode")

	var script := load("res://scripts/world_interaction.gd") as GDScript
	var main_defaults := script.new() as Node
	assert(not main_defaults.get("enable_blueprint_planning"))
	main_defaults.free()
	print("PASS G: Main scene retains batch authorization opt-out")

	print("ALL 7 BATCH BLUEPRINT AUTHORIZATION E3D1 TESTS PASSED")
