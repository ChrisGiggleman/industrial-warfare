extends Node3D

# =============================================================================
# E3D5C3D2E — DIRECT CLICK TO INSPECT AN EXISTING BLUEPRINT
# =============================================================================
# Tests real physics ray hit on a ConstructionSite, the _unhandled_input
# route, and explicit inspection dispatch. Q+drag retains separate ownership.
# Main and normal construction authority remain unchanged.


func _ready() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	assert(sandbox != null)
	add_child(sandbox)
	var controller: Node = sandbox.get_node("WorldInteraction")
	controller.set_process(false)
	var camera := sandbox.get_node("CameraRig/Camera3D") as Camera3D
	var gate := sandbox.get_node(
		"ConstructionRequirementsFeatureGate"
	) as SandboxConstructionRequirementsFeatureGate
	var panel: BlueprintConstructionRequirementsPanel = gate.get_panel()
	assert(camera != null)
	assert(panel != null)
	assert(bool(controller.get("enable_blueprint_click_inspection")))
	print("PASS A: Only sandbox controller opts into click-to-inspect")

	assert(not panel.is_open())
	assert(panel.get_display_text().contains("No selected site"))
	assert(not bool(panel.get_last_snapshot()["site_valid"]))
	print("PASS B: Panel begins closed with no fabricated target")

	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(definition != null)
	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	var site := controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, Vector3(-6, 0, 0))
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: Existing blueprint planning still creates a PLANNED job")

	# Wait for the actual StaticBody3D to enter the physics space.
	await get_tree().physics_frame
	await get_tree().physics_frame
	var click_position: Vector2 = camera.unproject_position(
		site.global_position + Vector3.UP * 0.35
	)
	assert(not camera.is_position_behind(
		site.global_position + Vector3.UP * 0.35
	))
	assert(controller._blueprint_site_at_screen_position(click_position) == site)
	print("PASS D: Real mouse raycast identifies the blueprint hitbox")

	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.pressed = true
	event.position = click_position
	assert(event.is_action_pressed("primary_action"))
	controller._unhandled_input(event)
	assert(panel.is_open())
	assert(bool(panel.get_last_snapshot()["site_valid"]))
	assert(panel.get_display_text().contains("Building: Test Storage"))
	print("PASS E: Plain blueprint click opens requirements for the hit site")

	assert(panel.get_display_text().contains("Test Ingot x3"))
	assert(panel.get_display_text().contains("State: Planned"))
	assert(panel.get_display_text().contains("Progress: 0%"))
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	print("PASS F: Click reports true costs without claiming live readiness")

	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.job.get_progress() == 0.0)
	assert(not site.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).is_empty())
	print("PASS G: Inspection click cannot authorize, build or batch-select")

	panel.set_open(false)
	controller._unhandled_input(event)
	assert(panel.is_open())
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS H: A second click reopens the informational panel")

	var unmanaged := ConstructionSite.new()
	assert(unmanaged.setup_with_definition_job(definition))
	assert(not controller._request_blueprint_inspection(unmanaged))
	unmanaged.free()
	assert(not controller._request_blueprint_inspection(null))
	print("PASS I: Null or detached construction plans cannot be inspected")

	assert(panel.get_display_text().contains("Stock: UNKNOWN"))
	assert(panel.get_display_text().contains("Reserved: UNKNOWN"))
	assert(panel.get_display_text().contains("Power: UNKNOWN"))
	assert(panel.get_display_text().contains("Worker: UNKNOWN"))
	print("PASS J: Clicking cannot fabricate supply or worker services")

	# While Q is active, a click belongs to area selection (not inspect).
	panel.set_open(false)
	assert(controller._toggle_blueprint_area_selection())
	assert(bool(controller.get("_blueprint_area_selection_mode")))
	gate._process(0.0)
	assert(not bool(panel.get_last_snapshot()["site_valid"]))
	controller._unhandled_input(event)
	assert(not panel.is_open())
	assert(not bool(panel.get_last_snapshot()["site_valid"]))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = click_position
	controller._unhandled_input(up)
	print("PASS K: Q-area-selection owns its clicks without opening inspector")

	var drag_box := Rect2(click_position - Vector2(9, 9), Vector2(18, 18))
	assert(controller._select_blueprints_in_screen_rect(drag_box) == 1)
	assert(site.is_in_group("blueprint_area_selected"))
	assert(panel.refresh_now()["site_valid"])
	assert(panel.get_display_text().contains("Building: Test Storage"))
	print("PASS L: Q+drag selection still feeds existing read-only inspection")

	assert(controller._set_selected_blueprint_priority(
		ConstructionJob.Priority.HIGH
	) == 1)
	assert(site.job.priority == ConstructionJob.Priority.HIGH)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(panel.refresh_now()["priority"] == "High")
	print("PASS M: Validated priority selection still works independently")

	controller._exit_blueprint_area_selection()
	panel.set_target(null)
	assert(not site.is_in_group("blueprint_area_selected"))
	panel.refresh_now()
	assert(panel.get_display_text().contains("No selected site"))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS N: Q exit clears multi-selection without losing blueprint")

	# No requirement change is allowed by this feature.
	assert(site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"power"))
	assert(site.job.get_wait_reasons().has(&"materials"))
	assert(site.job.get_wait_reasons().has(&"workers"))
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	print("PASS O: Click inspection preserves job gates and debug settings")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var main := main_scene.instantiate()
	var main_controller: Node = main.get_node("WorldInteraction")
	assert(not bool(main_controller.get("enable_blueprint_click_inspection")))
	main.free()
	print("PASS P: Production Main retains its old click/placement behavior")

	print("ALL 16 E3D5C3D2E DIRECT BLUEPRINT CLICK INSPECTION TESTS PASSED")
	print("MANUAL: Launch the normal Factory Testing Sandbox via F6.")
	print("MANUAL: Enter Build and Blueprint Mode, click an existing planned blueprint.")
	print("MANUAL: Q+drag should still select a group; normal placement remains usable.")
