extends Node3D

# =============================================================================
# E3D5C3E1B — COMPACT L/N/H PRIORITIES DOCKED LEFT OF SANDBOX HOTBAR
# =============================================================================
# Tests the REAL sandbox, existing Q-area-selection policy and the actual
# priority button signals. No new jobs are authorized or built.


func _ready() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var isolated := SandboxConstructionPriorityDock.new()
	add_child(isolated)
	assert(not isolated.enable_priority_controls)
	assert(isolated.get_controls() == null)
	print("PASS A: Priority dock script remains opt-in outside the sandbox")

	var sandbox_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(sandbox_scene != null)
	var sandbox := sandbox_scene.instantiate() as Node3D
	assert(sandbox != null)
	var dock := sandbox.get_node("ConstructionPriorityDock") as SandboxConstructionPriorityDock
	assert(dock != null and dock.enable_priority_controls)
	add_child(sandbox)
	var controller: Node = sandbox.get_node("WorldInteraction")
	var hotbar := sandbox.get_node("BuildHUD/VisualHotbar") as Control
	var buttons := dock.get_controls()
	assert(buttons != null and dock.get_child_count() == 1)
	assert(not buttons.visible)
	print("PASS B: Regular sandbox adds exactly one dock, hidden outside Blueprint Mode")

	assert(buttons.get_child_count() == 3)
	assert(buttons.get_child(0) == buttons.get_priority_button(ConstructionJob.Priority.LOW))
	assert(buttons.get_child(1) == buttons.get_priority_button(ConstructionJob.Priority.NORMAL))
	assert(buttons.get_child(2) == buttons.get_priority_button(ConstructionJob.Priority.HIGH))
	assert(buttons.get_priority_button(ConstructionJob.Priority.LOW).text == "L")
	assert(buttons.get_priority_button(ConstructionJob.Priority.NORMAL).text == "N")
	assert(buttons.get_priority_button(ConstructionJob.Priority.HIGH).text == "H")
	print("PASS C: Small vertical buttons display L above N above H")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	dock._update_dock()
	assert(buttons.visible and hotbar.visible)
	assert(not buttons.is_selection_available())
	print("PASS D: Blueprint Mode shows dock; no Q-selection keeps buttons disabled")

	await get_tree().process_frame
	dock._update_dock()
	var stack: Rect2 = buttons.get_global_rect()
	var bar: Rect2 = hotbar.get_global_rect()
	assert(stack.end.x < bar.position.x)
	assert(absf(stack.get_center().y - bar.get_center().y) < 3.0)
	assert(stack.size.x <= 55.0 and stack.size.y <= 105.0)
	print("PASS E: 48px-wide L/N/H stack docks directly left of the centered hotbar")

	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var site: ConstructionSite = controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, Vector3(-6, 0, 0))
	)
	assert(site != null)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	dock._update_dock()
	assert(not buttons.is_selection_available())
	print("PASS F: Placing or inspecting a blueprint alone cannot enable priorities")

	assert(controller._toggle_blueprint_area_selection())
	dock._update_dock()
	assert(not buttons.is_selection_available())
	assert(buttons.get_priority_button(ConstructionJob.Priority.HIGH).disabled)
	print("PASS G: Q mode without a drag selection remains disabled")

	await get_tree().physics_frame
	await get_tree().physics_frame
	var camera := sandbox.get_node("CameraRig/Camera3D") as Camera3D
	var position: Vector2 = camera.unproject_position(
		site.global_position + Vector3.UP * 0.35
	)
	var selection := Rect2(position - Vector2(9, 9), Vector2(18, 18))
	assert(controller._select_blueprints_in_screen_rect(selection) == 1)
	dock._update_dock()
	assert(buttons.is_selection_available())
	assert(site.is_in_group("blueprint_area_selected"))
	print("PASS H: Q+drag-selected PLANNED blueprint enables all priority buttons")

	buttons.get_priority_button(ConstructionJob.Priority.LOW).pressed.emit()
	assert(site.job.priority == ConstructionJob.Priority.LOW)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS I: Clicking L assigns Low through the existing guarded controller")

	buttons.get_priority_button(ConstructionJob.Priority.NORMAL).pressed.emit()
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	print("PASS J: Clicking N assigns Normal without authorizing the plan")

	buttons.get_priority_button(ConstructionJob.Priority.HIGH).pressed.emit()
	assert(site.job.priority == ConstructionJob.Priority.HIGH)
	assert(site.job.get_progress() == 0.0)
	print("PASS K: Clicking H assigns High without advancing construction")

	var second: ConstructionSite = controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, Vector3(-2, 0, 0))
	)
	assert(second != null)
	second.set_process(false)
	assert(second.job.priority == ConstructionJob.Priority.NORMAL)
	buttons.get_priority_button(ConstructionJob.Priority.LOW).pressed.emit()
	assert(site.job.priority == ConstructionJob.Priority.LOW)
	assert(second.job.priority == ConstructionJob.Priority.NORMAL)
	print("PASS L: Unselected blueprints retain their own priorities")

	var key := InputEventKey.new()
	key.keycode = KEY_H
	key.pressed = true
	controller._unhandled_input(key)
	assert(site.job.priority == ConstructionJob.Priority.HIGH)
	assert(second.job.priority == ConstructionJob.Priority.NORMAL)
	print("PASS M: Existing H/N/L keyboard alternative remains functional")

	controller._exit_blueprint_area_selection()
	dock._update_dock()
	assert(not buttons.is_selection_available())
	assert(buttons.get_priority_button(ConstructionJob.Priority.LOW).disabled)
	buttons.get_priority_button(ConstructionJob.Priority.LOW).pressed.emit()
	assert(site.job.priority == ConstructionJob.Priority.HIGH)
	print("PASS N: Leaving Q-selection disables button requests without side effects")

	assert(not controller._request_blueprint_inspection(null))
	assert(controller._request_blueprint_inspection(site))
	dock._update_dock()
	assert(not buttons.is_selection_available())
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS O: Single-click inspection is separate from Q priority control")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var main := main_scene.instantiate()
	assert(main.get_node_or_null("ConstructionPriorityDock") == null)
	main.free()
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	assert(bool(controller.get("enable_blueprint_route_tool")))
	assert(site.job.get_progress() == 0.0)
	assert(second.job.get_progress() == 0.0)
	print("PASS P: Main, debug gates, conveyor routes and construction timers unchanged")

	print("ALL 16 E3D5C3E1B VERTICAL SANDBOX PRIORITY DOCK TESTS PASSED")
	print("MANUAL: In regular Factory Testing Sandbox, enter Blueprint Mode, press Q and drag.")
	print("MANUAL: Click L, N, H beside the bottom hotbar and inspect priority counts.")
