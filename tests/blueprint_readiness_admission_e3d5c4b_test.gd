extends Node3D

# =============================================================================
# E3D5C4B — AUTHORIZATION TO READINESS: TEST-ONLY FAIL-CLOSED HANDOFF
# =============================================================================
# Real sandbox authorization is used, but no live power/stock/drones are
# connected to either playable scene. The coordinator is configured only
# inside this fixture. No ConstructionSite is time-stepped here.


func _ready() -> void:
	call_deferred("_run_checks")


func _plan(
	controller: Node, definition: BuildingDefinition, position: Vector3
) -> ConstructionSite:
	var site := controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, position)
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	return site


func _screen_rect(camera: Camera3D, site: ConstructionSite) -> Rect2:
	var screen: Vector2 = camera.unproject_position(
		site.global_position + Vector3.UP * 0.35
	)
	return Rect2(screen - Vector2(9, 9), Vector2(18, 18))


func _run_checks() -> void:
	var default_admission := BlueprintConstructionReadinessAdmission.new()
	add_child(default_admission)
	assert(not default_admission.enable_isolated_admission)
	assert(default_admission.admit_waiting(7) == 0)
	print("PASS A: Test-only admission defaults OFF and never scans work")

	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var sandbox := packed.instantiate() as Node3D
	assert(sandbox != null)
	add_child(sandbox)
	var controller: Node = sandbox.get_node("WorldInteraction")
	controller.set_process(false)
	var dock := sandbox.get_node(
		"ConstructionAuthorizationDock"
	) as SandboxConstructionAuthorizationDock
	assert(dock != null and dock.enable_authorization_controls)
	assert(bool(controller.get("blueprint_sandbox_debug_requirements")))
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("ConstructionAuthorizationDock") == null)
	assert(main.get_node_or_null("BlueprintConstructionReadinessAdmission") == null)
	main.free()
	print("PASS B: Only sandbox has authorization dock; Main is unchanged")

	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	add_child(coordinator)
	assert(not default_admission.configure(controller, coordinator))
	var admission := BlueprintConstructionReadinessAdmission.new()
	admission.enable_isolated_admission = true
	add_child(admission)
	assert(not admission.configure(controller, coordinator))
	print("PASS C: Default-off and sandbox debug bypass cannot configure intake")

	controller.blueprint_sandbox_debug_requirements = false
	assert(admission.configure(controller, coordinator))
	assert(not admission.configure(controller, coordinator))
	assert(admission.admit_waiting(7) == 0)
	print("PASS D: Explicit sandbox test-only intake configures once, with no work")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(definition != null)
	var first := _plan(controller, definition, Vector3(-6, 0, 0))
	var second := _plan(controller, definition, Vector3(-2, 0, 0))
	var third := _plan(controller, definition, Vector3(4, 0, 0))
	assert(not admission.admit_site(first, 7))
	assert(admission.admit_waiting(7) == 0)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	print("PASS E: PLANNED blueprints cannot enter readiness admission")

	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(third.job.set_priority(ConstructionJob.Priority.LOW))
	assert(not admission.admit_site(first, 7))
	assert(first.job.get_progress() == 0.0)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	print("PASS F: Priority changes never authorize or trigger intake")

	assert(controller._toggle_blueprint_area_selection())
	await get_tree().physics_frame
	await get_tree().physics_frame
	var camera := sandbox.get_node("CameraRig/Camera3D") as Camera3D
	assert(controller._select_blueprints_in_screen_rect(
		_screen_rect(camera, first)
	) == 1)
	assert(controller._authorize_selected_blueprint_sites() == 1)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_wait_reasons().size() == 3)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	print("PASS G: Existing Q-selected E authorization makes only first job QUEUED")

	assert(not admission.admit_site(first, 0))
	assert(not admission.admit_site(first, -1))
	assert(not admission.admit_site(first, 100001))
	assert(not admission.admit_site(second, 7))
	print("PASS H: Invalid energy requests and unapproved neighbors are rejected")

	assert(not admission.admit_site(first, 7))
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_progress() == 0.0)
	print("PASS I: Unconfigured readiness coordinator cannot accept any work")

	var queue := controller.get_node(
		"BlueprintConstructionPriorityQueue"
	) as BlueprintConstructionPriorityQueue
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var stock := InventoryComponent.new()
	for service: Node in [scheduler, escrow, network, power, stock]:
		add_child(service)
	assert(power.configure(network))
	assert(coordinator.configure(queue, scheduler, escrow, power, stock, 1))
	print("PASS J: Independent fixture installs bounded services without generators")

	assert(admission.admit_site(first, 7))
	assert(bool(coordinator.get_status(first)["tracked"]))
	assert(not admission.admit_site(first, 7))
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_wait_reasons().size() == 3)
	assert(first.job.get_progress() == 0.0)
	print("PASS K: Only valid QUEUED work is admitted once; no readiness granted")

	assert(admission.admit_waiting(7) == 0)
	assert(not bool(coordinator.get_status(second)["tracked"]))
	assert(not bool(coordinator.get_status(third)["tracked"]))
	print("PASS L: Bulk discovery skips unapproved plans and admitted duplicates")

	assert(controller._authorize_all_blueprint_sites() == 2)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(third.job.state == ConstructionJob.State.QUEUED)
	assert(admission.admit_waiting(7) == 2)
	assert(admission.admit_waiting(7) == 0)
	for site: ConstructionSite in [first, second, third]:
		assert(bool(coordinator.get_status(site)["tracked"]))
		assert(site.job.get_wait_reasons().size() == 3)
		assert(site.job.get_progress() == 0.0)
	print("PASS M: Ctrl+E-style All authorization admits remaining QUEUED plans only")

	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(scheduler.get_active_count() == 0)
	for site: ConstructionSite in [first, second, third]:
		assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS N: No delivered inventory means zero escrow, workers or construction")

	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ingot != null)
	assert(stock.add_item(ingot, 3) == 3)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 1)
	assert(escrow.reservation_for(first) > 0)
	assert(stock.get_amount(ingot) == 0)
	assert(scheduler.get_active_count() == 0)
	for site: ConstructionSite in [first, second, third]:
		assert(site.job.state == ConstructionJob.State.QUEUED)
		assert(site.job.get_progress() == 0.0)
	print("PASS O: Test inventory escrows High first; no generator keeps work QUEUED")

	controller.blueprint_sandbox_debug_requirements = true
	assert(not admission.admit_site(second, 7))
	assert(admission.admit_waiting(7) == 0)
	assert(scheduler.get_active_count() == 0)
	assert(sandbox.get_node_or_null("BlueprintConstructionReadinessAdmission") == null)
	print("PASS P: Re-enabled debug bypass shuts intake; no playable adapter")

	print("ALL 16 E3D5C4B READINESS ADMISSION TESTS PASSED")
	print("TEST ONLY: Real power delivery, worker drones, recovery and save/load remain absent.")
