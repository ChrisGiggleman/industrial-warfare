extends Node3D

# =============================================================================
# E3D5C3D2D — REGULAR SANDBOX: REQUIREMENTS PANEL DEFAULT-ON (F6)
# =============================================================================
# This test loads the committed Factory Testing Sandbox unchanged (no opt-in
# edits on its instance). The UI is read-only, CLOSED initially and toggled
# with its existing Button. No providers are fabricated.
# Gameplay Main is checked as a detached fixture only; never modified.


func _site(label: String) -> ConstructionSite:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(is_instance_valid(definition))
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	return site


func _ready() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var generic_gate := SandboxConstructionRequirementsFeatureGate.new()
	add_child(generic_gate)
	assert(not generic_gate.enable_read_only_requirements_panel)
	assert(generic_gate.get_panel() == null)
	print("PASS A: Unconfigured gate instances remain disabled by default")

	var scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(scene != null)
	var sandbox := scene.instantiate() as Node3D
	assert(sandbox != null)
	var gate := sandbox.get_node(
		"ConstructionRequirementsFeatureGate"
	) as SandboxConstructionRequirementsFeatureGate
	assert(gate != null and gate.enable_read_only_requirements_panel)
	print("PASS B: Committed testing sandbox enables read-only UI by default")

	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().process_frame
	var panel: BlueprintConstructionRequirementsPanel = gate.get_panel()
	assert(is_instance_valid(panel))
	assert(panel.is_inside_tree())
	assert(gate.get_child_count() == 1)
	assert(panel.follow_area_selection)
	assert(not panel.is_open())
	print("PASS C: Regular sandbox boots exactly one closed requirements panel")

	var toggle: Button = panel.get_toggle_button()
	assert(is_instance_valid(toggle) and toggle.visible)
	assert(toggle.text == "Construction Requirements")
	var hud := sandbox.get_node(
		"ProductionDebugHUD/InfoPanel"
	) as Control
	var summary := sandbox.get_node(
		"BlueprintConstructionSummary/BlueprintSummaryPanel"
	) as Control
	assert(hud != null and summary != null)
	assert(not toggle.get_global_rect().intersects(hud.get_global_rect()))
	assert(not toggle.get_global_rect().intersects(summary.get_global_rect()))
	print("PASS D: Toggle is visible without blocking existing factory HUDs")

	toggle.pressed.emit()
	await get_tree().process_frame
	var details := panel.get_node(
		"RequirementsCanvas/RequirementsPanel"
	) as Control
	assert(panel.is_open() and details.visible)
	assert(toggle.text == "Close Construction Requirements")
	assert(not details.get_global_rect().intersects(hud.get_global_rect()))
	assert(not details.get_global_rect().intersects(summary.get_global_rect()))
	print("PASS E: Requirements open below Production Debug without overlap")

	assert(panel.get_display_text().contains("No selected site"))
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	assert(not bool(panel.get_last_snapshot()["site_valid"]))
	print("PASS F: No selection does not invent inventory or construction readiness")

	var storage: ConstructionSite = _site("DefaultOnStorage")
	sandbox.add_child(storage)
	storage.global_position = Vector3(6, 0, 0)
	storage.set_process(false)
	storage.set_blueprint_area_selected(true)
	var snapshot: Dictionary = panel.refresh_now()
	assert(bool(snapshot["site_valid"]))
	assert(panel.get_display_text().contains("Building: Test Storage"))
	assert(panel.get_display_text().contains("State: Planned"))
	assert(panel.get_display_text().contains("Test Ingot x3"))
	assert(panel.get_display_text().contains("Priority: Normal"))
	print("PASS G: Regular blueprint area selection populates real material costs")

	assert(panel.get_display_text().contains("Stock: UNKNOWN"))
	assert(panel.get_display_text().contains("Reserved: UNKNOWN"))
	assert(panel.get_display_text().contains("Power: UNKNOWN"))
	assert(panel.get_display_text().contains("Worker: UNKNOWN"))
	assert(not bool(snapshot["live_construction_ready"]))
	print("PASS H: No fake stock, power, escrow or worker providers are connected")

	var controller: Node = sandbox.get_node("WorldInteraction")
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	assert(bool(controller.get("enable_blueprint_route_tool")))
	assert(bool(controller.get("enable_blueprint_area_selection")))
	assert(bool(controller.get("enable_blueprint_construction_priorities")))
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	assert(storage.job.get_progress() == 0.0)
	print("PASS I: Existing keyboard/blueprint controls and debug gate remain")

	toggle.pressed.emit()
	assert(not panel.is_open())
	assert(not details.visible)
	assert(toggle.visible)
	toggle.pressed.emit()
	assert(panel.is_open() and details.visible)
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	print("PASS J: Closing/reopening UI never authorizes selected construction")

	storage.set_blueprint_area_selected(false)
	snapshot = panel.refresh_now()
	assert(not bool(snapshot["site_valid"]))
	assert(panel.get_display_text().contains("No selected site"))
	storage.set_blueprint_area_selected(true)
	assert(storage.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(panel.refresh_now()["priority"] == "High")
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	print("PASS K: Deselect and priority updates are observed without mutation")

	for i: int in range(5):
		panel.refresh_now()
	assert(gate.get_child_count() == 1)
	assert(storage.job.get_progress() == 0.0)
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	var main := load("res://scenes/core/main.tscn") as PackedScene
	assert(main != null)
	var live_main: Node = main.instantiate()
	assert(live_main != null)
	assert(live_main.get_node_or_null("ConstructionRequirementsFeatureGate") == null)
	live_main.free()
	assert(sandbox.get_node_or_null("BuildHUD") != null)
	assert(sandbox.get_node_or_null("ProductionDebugHUD") != null)
	print("PASS L: UI reads cannot advance work, duplicate panels or affect Main")

	print("ALL 12 E3D5C3D2D DEFAULT-ON SANDBOX REQUIREMENTS TESTS PASSED")
	print("MANUAL: Run res://scenes/core/factory_testing_sandbox.tscn with F6.")
	print("MANUAL: Click Construction Requirements to OPEN, CLOSE, then REOPEN.")
