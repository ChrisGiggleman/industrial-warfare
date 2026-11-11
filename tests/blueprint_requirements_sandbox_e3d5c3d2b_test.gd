extends Node3D

# =============================================================================
# E3D5C3D2B — DISABLED-BY-DEFAULT SANDBOX REQUIREMENTS UI (F6)
# =============================================================================
# F6 loads the REAL Factory Testing Sandbox in an opt-in test instance.
# Main, combat, conveyor logic and debug construction gates remain untouched.
# UI has no stock/escrow/power/worker providers, so UNKNOWN is required.


func _ready() -> void:
	var standalone_gate := SandboxConstructionRequirementsFeatureGate.new()
	add_child(standalone_gate)
	assert(not standalone_gate.enable_read_only_requirements_panel)
	assert(standalone_gate.get_panel() == null)
	print("PASS A: New requirements gate is disabled by default")

	var sandbox_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(sandbox_scene != null)
	var sandbox := sandbox_scene.instantiate() as Node3D
	assert(sandbox != null)
	var gate := sandbox.get_node_or_null(
		"ConstructionRequirementsFeatureGate"
	) as SandboxConstructionRequirementsFeatureGate
	assert(gate != null)
	assert(not gate.enable_read_only_requirements_panel)
	assert(gate.get_panel() == null)
	print("PASS B: Committed sandbox has feature disabled by default")

	# Opt in ONLY this one F6 fixture instance, before _ready on children.
	gate.enable_read_only_requirements_panel = true
	add_child(sandbox)
	assert(sandbox.is_inside_tree())
	var controller: Node = sandbox.get_node("WorldInteraction")
	assert(controller != null)
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	assert(bool(controller.get("enable_blueprint_area_selection")))
	assert(bool(controller.get("enable_blueprint_construction_priorities")))
	print("PASS C: Opt-in test preserves existing sandbox blueprint debug flags")

	var panel: BlueprintConstructionRequirementsPanel = gate.get_panel()
	assert(is_instance_valid(panel))
	assert(panel.is_inside_tree())
	assert(panel.follow_area_selection)
	assert(not panel.is_open())
	assert(panel.get_toggle_button() != null)
	print("PASS D: Opt-in sandbox creates exactly one closed read-only panel")

	assert(gate.get_child_count() == 1)
	var toggle: Button = panel.get_toggle_button()
	assert(toggle.text == "Construction Requirements")
	assert(panel.get_display_text().contains("No selected site"))
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	print("PASS E: Standalone panel is not duplicated or incorrectly green-lit")

	toggle.pressed.emit()
	assert(panel.is_open())
	assert(toggle.text == "Close Construction Requirements")
	assert(panel.get_display_text().contains("No selected site"))
	print("PASS F: Sandbox mouse-toggle signal opens read-only details")

	var storage := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(storage != null)
	var selected := ConstructionSite.new()
	selected.name = "SelectedTestStorage"
	assert(selected.setup_with_definition_job(storage))
	sandbox.add_child(selected)
	selected.global_position = Vector3(6, 0, 0)
	selected.set_process(false)
	assert(selected.job.state == ConstructionJob.State.PLANNED)
	selected.set_blueprint_area_selected(true)
	var snapshot: Dictionary = panel.refresh_now()
	assert(bool(snapshot["site_valid"]))
	assert(panel.get_display_text().contains("Building: Test Storage"))
	assert(panel.get_display_text().contains("State: Planned"))
	print("PASS G: Panel follows the existing sandbox blueprint-selection group")

	assert(panel.get_display_text().contains("Test Ingot x3"))
	assert(panel.get_display_text().contains("Priority: Normal"))
	assert(panel.get_display_text().contains("Progress: 0%"))
	assert(selected.job.get_progress() == 0.0)
	print("PASS H: Definition costs, priority and time are displayed read-only")

	assert(panel.get_display_text().contains("Stock: UNKNOWN"))
	assert(panel.get_display_text().contains("Reserved: UNKNOWN"))
	assert(panel.get_display_text().contains("Power: UNKNOWN"))
	assert(panel.get_display_text().contains("Worker: UNKNOWN"))
	print("PASS I: Missing sandbox supply providers stay UNKNOWN")

	assert(not bool(snapshot["live_construction_ready"]))
	assert(not bool(snapshot["prototype_gates_observed"]))
	assert(selected.job.get_wait_reasons().size() == 3)
	print("PASS J: UI cannot disguise bypass mode as real readiness")

	toggle.pressed.emit()
	assert(not panel.is_open())
	toggle.pressed.emit()
	assert(panel.is_open())
	assert(selected.job.state == ConstructionJob.State.PLANNED)
	assert(selected.job.get_progress() == 0.0)
	print("PASS K: Closing and reopening the panel does not authorize plans")

	for i: int in range(5):
		panel.refresh_now()
	assert(selected.job.state == ConstructionJob.State.PLANNED)
	assert(is_equal_approx(selected.job.get_progress(), 0.0))
	assert(panel.get_display_text().contains("Test Ingot x3"))
	print("PASS L: Continuous UI reads do not advance construction or mint stock")

	assert(selected.job.set_priority(ConstructionJob.Priority.HIGH))
	panel.refresh_now()
	assert(panel.get_display_text().contains("Priority: High"))
	assert(selected.job.state == ConstructionJob.State.PLANNED)
	print("PASS M: External priority changes are reflected without UI mutation")

	selected.set_blueprint_area_selected(false)
	snapshot = panel.refresh_now()
	assert(not bool(snapshot["site_valid"]))
	assert(panel.get_display_text().contains("No selected site"))
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	print("PASS N: Deselecting a blueprint safely clears requirements details")

	selected.set_blueprint_area_selected(true)
	assert(selected.job.authorize())
	snapshot = panel.refresh_now()
	assert(snapshot["state"] == int(ConstructionJob.State.QUEUED))
	assert(panel.get_display_text().contains("State: Queued"))
	assert(panel.get_display_text().contains("Stock: UNKNOWN"))
	assert(panel.get_display_text().contains("Power: UNKNOWN"))
	selected.job.advance(100.0)
	assert(selected.job.get_progress() == 0.0)
	print("PASS O: Authorized ungated test work never advances from UI inspection")

	assert(sandbox.get_node_or_null("BuildHUD") != null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSummary") != null)
	assert(sandbox.get_node_or_null("ProductionDebugHUD") != null)
	assert(bool(controller.get("enable_blueprint_route_tool")))
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	print("PASS P: Original sandbox HUD, blueprint routes and debug gates remain")

	print("ALL 16 E3D5C3D2B SANDBOX READ-ONLY REQUIREMENTS UI TESTS PASSED")
	print("MANUAL: In the F6 window, click Close Construction Requirements, then reopen it.")
	print("MANUAL: The factory sandbox scene itself remains disabled by default.")
