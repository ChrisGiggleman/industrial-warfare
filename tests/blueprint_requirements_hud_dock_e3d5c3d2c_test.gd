extends Node3D

# =============================================================================
# E3D5C3D2C — REAL SANDBOX HUD COLLISION / READ-ONLY DOCK (F6)
# =============================================================================
# Opens only a test instance of the Factory Testing Sandbox feature gate.
# Exercises adaptive placement relative to the Production Debug HUD.
# No materials, power, worker, combat, placement or selection logic changes.


func _ready() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var sandbox_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(sandbox_scene != null)
	var sandbox := sandbox_scene.instantiate() as Node3D
	assert(sandbox != null)
	var gate := sandbox.get_node(
		"ConstructionRequirementsFeatureGate"
	) as SandboxConstructionRequirementsFeatureGate
	assert(gate != null)
	assert(gate.enable_read_only_requirements_panel)
	print("PASS A: Committed Factory Testing Sandbox UI is enabled by default")

	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().process_frame
	var controller: Node = sandbox.get_node("WorldInteraction")
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	var panel: BlueprintConstructionRequirementsPanel = gate.get_panel()
	assert(is_instance_valid(panel))
	assert(not panel.is_open())
	print("PASS B: Default-on UI leaves sandbox debug gates intact")

	var hud: Control = sandbox.get_node(
		"ProductionDebugHUD/InfoPanel"
	) as Control
	var summary: Control = sandbox.get_node(
		"BlueprintConstructionSummary/BlueprintSummaryPanel"
	) as Control
	var button: Button = panel.get_toggle_button()
	var details: Control = panel.get_node(
		"RequirementsCanvas/RequirementsPanel"
	) as Control
	assert(is_instance_valid(hud))
	assert(is_instance_valid(summary))
	assert(is_instance_valid(button))
	assert(is_instance_valid(details))
	print("PASS C: Both existing HUDs and the new clickable panel are present")

	assert(not button.get_global_rect().intersects(hud.get_global_rect()))
	var available_height: float = get_viewport().get_visible_rect().size.y
	assert(button.get_global_rect().end.y <= available_height + 1.0)
	print("PASS D: Construction Requirements button does not cover Production Debug")

	button.pressed.emit()
	assert(panel.is_open())
	await get_tree().process_frame
	assert(not details.get_global_rect().intersects(hud.get_global_rect()))
	assert(details.get_global_rect().end.y <= available_height + 1.0)
	print("PASS E: Open requirements details avoid the original production panel")

	var storage := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(storage != null)
	var selected := ConstructionSite.new()
	assert(selected.setup_with_definition_job(storage))
	sandbox.add_child(selected)
	selected.set_process(false)
	selected.set_blueprint_area_selected(true)
	var snapshot: Dictionary = panel.refresh_now()
	assert(bool(snapshot["site_valid"]))
	assert(panel.get_display_text().contains("Test Ingot x3"))
	assert(panel.get_display_text().contains("Stock: UNKNOWN"))
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	print("PASS F: Repositioning never changes the read-only data contract")

	var old_bottom: float = hud.offset_bottom
	hud.offset_bottom = available_height - 80.0
	await get_tree().process_frame
	await get_tree().process_frame
	assert(not button.get_global_rect().intersects(hud.get_global_rect()))
	assert(not details.get_global_rect().intersects(hud.get_global_rect()))
	assert(not button.get_global_rect().intersects(summary.get_global_rect()))
	assert(not details.get_global_rect().intersects(summary.get_global_rect()))
	print("PASS G: Tall Production Debug forces safe left-side placement")

	assert(button.get_global_rect().position.x < 32.0)
	assert(details.get_global_rect().position.x < 32.0)
	assert(details.get_global_rect().end.y <= available_height + 1.0)
	print("PASS H: Left fallback stays below Factory Blueprints and in viewport")

	hud.offset_bottom = old_bottom
	await get_tree().process_frame
	await get_tree().process_frame
	assert(not details.get_global_rect().intersects(hud.get_global_rect()))
	button.pressed.emit()
	assert(not panel.is_open())
	button.pressed.emit()
	assert(panel.is_open())
	assert(not button.get_global_rect().intersects(hud.get_global_rect()))
	print("PASS I: Restored Production Debug re-docks; mouse toggle still works")

	for i: int in range(4):
		panel.refresh_now()
	assert(selected.job.state == ConstructionJob.State.PLANNED)
	assert(selected.job.get_progress() == 0.0)
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	assert(sandbox.get_node_or_null("BuildHUD") != null)
	print("PASS J: Adaptive UI never authorizes plans, advances time or removes HUDs")

	print("ALL 10 E3D5C3D2C SANDBOX REQUIREMENTS HUD DOCK TESTS PASSED")
	print("MANUAL: Inspect top-right panel BELOW Production Debug in the F6 window.")
	print("MANUAL: Click to close/reopen, then select a building to expand Production Debug.")
