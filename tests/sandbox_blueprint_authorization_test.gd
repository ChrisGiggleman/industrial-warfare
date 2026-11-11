extends Node3D

# =============================================================================
# SANDBOX BLUEPRINT AUTHORIZATION — EXPLICIT SELECTED / CONFIRMED ALL
# =============================================================================
# Exercises real sandbox UI and existing WorldInteraction commands. Debug
# requirements are disabled before authorization to prove QUEUED fail-closed
# states rather than falsely claiming real material/power/worker readiness.


func _ready() -> void:
	call_deferred("_run_checks")


func _plan(controller: Node, definition: BuildingDefinition, spot: Vector3) -> ConstructionSite:
	var site := controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, spot)
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _key(controller: Node, keycode: Key, ctrl: bool = false) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = keycode
	event.keycode = keycode
	event.ctrl_pressed = ctrl
	controller._unhandled_input(event)


func _rect(camera: Camera3D, site: ConstructionSite) -> Rect2:
	var point: Vector2 = camera.unproject_position(
		site.global_position + Vector3.UP * 0.35
	)
	return Rect2(point - Vector2(9, 9), Vector2(18, 18))


func _run_checks() -> void:
	var opt_out := SandboxConstructionAuthorizationDock.new()
	add_child(opt_out)
	assert(not opt_out.enable_authorization_controls)
	assert(opt_out.get_controls() == null)
	print("PASS A: Authorization dock defaults OFF outside the sandbox")

	var sandbox_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(sandbox_scene != null)
	var world := sandbox_scene.instantiate() as Node3D
	assert(world != null)
	var dock := world.get_node(
		"ConstructionAuthorizationDock"
	) as SandboxConstructionAuthorizationDock
	assert(dock != null and dock.enable_authorization_controls)
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	var buttons := dock.get_controls()
	assert(buttons != null and dock.get_child_count() == 1)
	print("PASS B: Only Factory Testing Sandbox explicitly enables the dock")

	assert(buttons.get_child_count() == 2)
	assert(buttons.get_selected_button().text == "Authorize Selected (0)")
	assert(buttons.get_all_button().text == "Authorize All (0)")
	assert(buttons.get_selected_button().disabled)
	assert(buttons.get_all_button().disabled)
	assert(not buttons.visible)
	print("PASS C: Both request-only buttons start hidden and disabled")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	dock._update_dock()
	assert(buttons.visible)
	assert(buttons.get_selected_button().disabled and buttons.get_all_button().disabled)
	print("PASS D: Blueprint Mode alone never provides authorization targets")

	await get_tree().process_frame
	dock._update_dock()
	var bar := world.get_node("BuildHUD/VisualHotbar") as Control
	var priority := world.get_node("ConstructionPriorityDock") as SandboxConstructionPriorityDock
	priority._update_dock()
	var control_rect: Rect2 = buttons.get_global_rect()
	assert(control_rect.end.y <= bar.get_global_rect().position.y)
	assert(not control_rect.intersects(priority.get_controls().get_global_rect()))
	print("PASS E: Authorization buttons sit above hotbar without hiding L/N/H")

	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var first := _plan(controller, definition, Vector3(-6, 0, 0))
	var second := _plan(controller, definition, Vector3(-2, 0, 0))
	var third := _plan(controller, definition, Vector3(3, 0, 0))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(third.job.state == ConstructionJob.State.PLANNED)
	dock._update_dock()
	assert(buttons.get_selected_button().disabled)
	assert(not buttons.get_all_button().disabled)
	assert(buttons.get_all_button().text == "Authorize All (3)")
	print("PASS F: Only explicit All is offered before Q selection")

	buttons.selected_requested.emit()
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	print("PASS G: Synthetic Selected signal fails closed without Q selection")

	assert(controller._toggle_blueprint_area_selection())
	await get_tree().physics_frame
	await get_tree().physics_frame
	var camera := world.get_node("CameraRig/Camera3D") as Camera3D
	assert(controller._select_blueprints_in_screen_rect(_rect(camera, first)) == 1)
	dock._update_dock()
	assert(not buttons.get_selected_button().disabled)
	assert(buttons.get_selected_button().text == "Authorize Selected (1)")
	print("PASS H: Selected action enables only for a valid Q+drag PLANNED site")

	priority._update_dock()
	priority.get_controls().get_priority_button(
		ConstructionJob.Priority.HIGH
	).pressed.emit()
	assert(first.job.priority == ConstructionJob.Priority.HIGH)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.get_progress() == 0.0)
	print("PASS I: Priority High never silently authorizes construction")

	assert(controller._request_blueprint_inspection(second))
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert((controller.get("_area_selected_sites") as Array).has(first))
	print("PASS J: Direct-click inspection does not replace Q authorization selection")

	# This TEST explicitly disables the sandbox's debug availability override.
	# Genuine power, delivered materials and workers are NOT supplied here.
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	controller.blueprint_sandbox_debug_requirements = false
	buttons.get_selected_button().pressed.emit()
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(third.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.get_wait_reasons().size() == 3)
	assert(first.job.get_progress() == 0.0)
	print("PASS K: Selected authorizes only chosen job; missing services keep it QUEUED")

	assert((controller.get("_area_selected_sites") as Array).is_empty())
	dock._update_dock()
	assert(buttons.get_selected_button().disabled)
	buttons.selected_requested.emit()
	assert(second.job.state == ConstructionJob.State.PLANNED)
	print("PASS L: Successful Selected clears highlights and disables repeat requests")

	buttons.get_all_button().pressed.emit()
	assert(dock.is_all_confirmation_pending())
	assert(buttons.get_all_button().text == "Confirm All (2)")
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(third.job.state == ConstructionJob.State.PLANNED)
	print("PASS M: First All click requests confirmation without authorizing anything")

	var fourth := _plan(controller, definition, Vector3(7, 0, 0))
	dock._update_dock()
	assert(not dock.is_all_confirmation_pending())
	assert(buttons.get_all_button().text == "Authorize All (3)")
	assert(fourth.job.state == ConstructionJob.State.PLANNED)
	print("PASS N: Any changed All candidate set invalidates prior confirmation")

	buttons.get_all_button().pressed.emit()
	assert(dock.is_all_confirmation_pending())
	assert(second.job.state == ConstructionJob.State.PLANNED)
	buttons.get_all_button().pressed.emit()
	assert(not dock.is_all_confirmation_pending())
	for site: ConstructionSite in [second, third, fourth]:
		assert(site.job.state == ConstructionJob.State.QUEUED)
		assert(site.job.get_wait_reasons().size() == 3)
		assert(site.job.get_progress() == 0.0)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS O: Second All click authorizes only remaining planned jobs; no dispatch")

	var fifth := _plan(controller, definition, Vector3(-6, 0, -6))
	var sixth := _plan(controller, definition, Vector3(-2, 0, -6))
	assert(controller._select_blueprints_in_screen_rect(_rect(camera, fifth)) == 1)
	_key(controller, KEY_E)
	assert(fifth.job.state == ConstructionJob.State.QUEUED)
	assert(sixth.job.state == ConstructionJob.State.PLANNED)
	assert((controller.get("_area_selected_sites") as Array).is_empty())
	print("PASS P: Physical E shortcut still authorizes only Q-selected plans")

	_key(controller, KEY_E, true)
	assert(sixth.job.state == ConstructionJob.State.QUEUED)
	assert(sixth.job.get_wait_reasons().size() == 3)
	dock._update_dock()
	assert(buttons.get_all_button().disabled)
	assert(not dock.is_all_confirmation_pending())
	print("PASS Q: Physical Ctrl+E still authorizes all remaining plans")

	controller._toggle_blueprint_mode()
	dock._update_dock()
	assert(not buttons.visible)
	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var main := main_scene.instantiate()
	assert(main.get_node_or_null("ConstructionAuthorizationDock") == null)
	main.free()
	for site: ConstructionSite in [first, second, third, fourth, fifth, sixth]:
		assert(site.job.get_progress() == 0.0)
	print("PASS R: Main opted out; no timers, inventory, power or worker flags bypassed")

	print("ALL 18 SANDBOX BLUEPRINT AUTHORIZATION TESTS PASSED")
	print("MANUAL: Blueprint Mode, Q+drag one plan, click Authorize Selected.")
	print("MANUAL: Plan more sites; click Authorize All, then Confirm All.")
	print("MANUAL: With sandbox debug ON jobs will construct after authorization.")
