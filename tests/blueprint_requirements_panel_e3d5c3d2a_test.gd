extends Node3D

# =============================================================================
# E3D5C3D2A — CLICKABLE READ-ONLY REQUIREMENTS PANEL TEST (F6)
# =============================================================================
# A visible toggle button remains after the checks; click it in the F6 game
# window to confirm that opening/closing requires no keyboard shortcuts.
# Actual Factory Testing Sandbox scene and debug construction are untouched.


func _site(label: String) -> ConstructionSite:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(is_instance_valid(definition))
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.set_process(false)
	return site


func _structure(path: String, label: String, at: Vector3) -> PrototypePowerStructure:
	var resource := load(path) as PackedScene
	assert(resource != null)
	var building := resource.instantiate() as PrototypePowerStructure
	assert(building != null)
	building.name = label
	add_child(building)
	building.global_position = at
	return building


func _ready() -> void:
	var panel := BlueprintConstructionRequirementsPanel.new()
	panel.follow_area_selection = true
	add_child(panel)
	var toggle: Button = panel.get_toggle_button()
	assert(is_instance_valid(toggle))
	assert(toggle.text == "Construction Requirements")
	assert(not panel.is_open())
	assert(panel.get_display_text().contains("No selected site"))
	print("PASS A: Closed panel starts with a visible clickable toggle")

	toggle.pressed.emit()
	assert(panel.is_open())
	assert(toggle.text == "Close Construction Requirements")
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	print("PASS B: Button opens the panel without authorizing construction")

	toggle.pressed.emit()
	assert(not panel.is_open())
	assert(toggle.text == "Construction Requirements")
	assert(panel.get_display_text().contains("No selected site"))
	print("PASS C: Button closes the panel without touching the game")

	var site: ConstructionSite = _site("InspectorStorage")
	panel.set_target(site)
	panel.set_open(true)
	var snapshot: Dictionary = panel.get_last_snapshot()
	assert(bool(snapshot["site_valid"]))
	assert(snapshot["state"] == int(ConstructionJob.State.PLANNED))
	assert(panel.get_display_text().contains("Building: Test Storage"))
	assert(panel.get_display_text().contains("Test Ingot x3"))
	assert(panel.get_display_text().contains("Priority: Normal"))
	print("PASS D: Planned blueprint displays real definition-owned costs")

	assert(panel.get_display_text().contains("Stock: UNKNOWN"))
	assert(panel.get_display_text().contains("Reserved: UNKNOWN"))
	assert(panel.get_display_text().contains("Power: UNKNOWN"))
	assert(panel.get_display_text().contains("Worker: UNKNOWN"))
	assert(not bool(snapshot["live_construction_ready"]))
	print("PASS E: Missing data services are visibly UNKNOWN, never green-lit")

	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(is_instance_valid(ingot))
	var stock := InventoryComponent.new()
	stock.max_capacity = 20
	add_child(stock)
	panel.set_providers(stock)
	assert(panel.get_display_text().contains("Missing Test Ingot x3"))
	assert(stock.get_total_amount() == 0)
	print("PASS F: Empty connected stock displays the exact shortage")

	assert(stock.add_item(ingot, 2) == 2)
	panel.refresh_now()
	assert(panel.get_display_text().contains("Missing Test Ingot x1"))
	assert(stock.get_amount(ingot) == 2)
	print("PASS G: Partial inventory displays updated exact deficit")

	assert(stock.add_item(ingot, 1) == 1)
	snapshot = panel.refresh_now()
	assert(bool(snapshot["stock_sufficient"]))
	assert(panel.get_display_text().contains("Enough on hand (not reserved)"))
	assert(panel.get_display_text().contains("Reserved: UNKNOWN"))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS H: Enough warehouse stock cannot invent a reservation")

	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	assert(site.job.authorize())
	var reservation_id: int = escrow.reserve(
		site, stock, ConstructionMaterialBill.get_costs(site.target_definition)
	)
	assert(reservation_id > 0)
	panel.set_providers(stock, escrow)
	snapshot = panel.get_last_snapshot()
	assert(bool(snapshot["materials_reserved"]))
	assert(panel.get_display_text().contains("Reserved: YES"))
	assert(stock.get_amount(ingot) == 0)
	assert(panel.get_display_text().contains("Stock: INSUFFICIENT"))
	print("PASS I: Actual escrow is distinct from remaining free inventory")

	for i: int in range(3):
		panel.refresh_now()
	assert(escrow.held_count() == 1)
	assert(site.job.get_progress() == 0.0)
	assert(stock.get_total_amount() == 0)
	print("PASS J: UI refresh cannot reserve more items or advance a timer")

	var network := ConstructionPowerCoverageNetwork.new()
	add_child(network)
	var power := PrototypeConstructionPowerAllocator.new()
	add_child(power)
	assert(power.configure(network))
	var hub: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_main_hub.tscn",
		"DemoMainHub", Vector3.ZERO
	)
	var pole: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_power_pole.tscn",
		"DemoPowerPole", Vector3(6, 0, 0)
	)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	site.global_position = Vector3(6, 0, 0)
	assert(network.covers_site(site))
	panel.set_providers(stock, escrow, power)
	assert(panel.get_display_text().contains("Power: NO / waiting"))
	print("PASS K: Nearby powered relay alone is not a budget allocation")

	assert(power.track_site(site, 7))
	snapshot = panel.refresh_now()
	assert(bool(snapshot["prototype_power_allocated"]))
	assert(panel.get_display_text().contains("Power: YES (prototype only)"))
	assert(panel.get_display_text().contains("Worker: UNKNOWN"))
	print("PASS L: Finite prototype allocation is labeled, not certified")

	var queue := BlueprintConstructionPriorityQueue.new()
	add_child(queue)
	var scheduler := BlueprintConstructionSlotScheduler.new()
	add_child(scheduler)
	assert(scheduler.configure(queue, 1))
	assert(scheduler.track_authorized_site(site))
	panel.set_providers(stock, escrow, power, scheduler)
	assert(panel.get_display_text().contains("Worker: NO / waiting"))
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS M: Queued construction does not imply an assigned worker")

	assert(scheduler.update_requirements(site, true, true))
	assert(scheduler.reconcile() == 1)
	snapshot = panel.refresh_now()
	assert(bool(snapshot["prototype_gates_observed"]))
	assert(not bool(snapshot["live_construction_ready"]))
	assert(panel.get_display_text().contains("Worker: YES (prototype only)"))
	assert(panel.get_display_text().contains("Live readiness: NOT VERIFIED"))
	print("PASS N: All prototype gates remain explicitly NOT live certified")

	site.job.advance(2.0)
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	panel.refresh_now()
	assert(panel.get_display_text().contains("Progress: 20%"))
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	print("PASS O: Progress display updates without changing construction time")

	assert(hub.set_generator_enabled(false))
	snapshot = panel.refresh_now()
	assert(not bool(snapshot["prototype_power_allocated"]))
	assert(bool(snapshot["worker_active"]))
	assert(not bool(snapshot["prototype_gates_observed"]))
	assert(panel.get_display_text().contains("Power: NO / waiting"))
	print("PASS P: Outage is reported even if worker state has not reconciled")

	assert(scheduler.update_requirements(site, false, true))
	assert(scheduler.reconcile() == 0)
	snapshot = panel.refresh_now()
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(panel.get_display_text().contains("State: Paused"))
	assert(panel.get_display_text().contains("Worker: NO / waiting"))
	assert(escrow.reservation_for(site) == reservation_id)
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	print("PASS Q: Existing scheduler pauses safely, while panel stays read-only")

	assert(site.job.cancel())
	panel.refresh_now()
	# Cancellation queues the ConstructionSite for removal. The inspector
	# deliberately refuses to display a removed site as still selectable.
	assert(panel.get_display_text().contains("No selected site"))
	assert(not bool(panel.get_last_snapshot()["site_valid"]))
	assert(stock.get_amount(ingot) == 3)
	assert(not escrow.has_reservation(reservation_id))
	var next_site: ConstructionSite = _site("AreaSelectedStorage")
	assert(next_site.job.state == ConstructionJob.State.PLANNED)
	next_site.set_blueprint_area_selected(true)
	panel.set_target(null)
	assert(panel.get_display_text().contains("Building: Test Storage"))
	assert(panel.get_display_text().contains("State: Planned"))
	assert(not bool(panel.get_last_snapshot()["live_construction_ready"]))
	assert(panel.is_open())
	print("PASS R: Cancelled escrow refunds; UI follows area selection without edits")

	print("ALL 18 E3D5C3D2A READ-ONLY REQUIREMENTS PANEL TESTS PASSED")
	print("MANUAL UI CHECK: Click top-right Construction Requirements button twice.")
