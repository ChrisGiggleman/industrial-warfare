extends Node3D

# =============================================================================
# E3D5C3D1 — READ-ONLY CONSTRUCTION REQUIREMENTS INSPECTION (F6)
# =============================================================================
# This fixture verifies observation only. It does NOT enable live sandbox
# construction, grant electrical energy, reserve materials or dispatch workers.
# A separate test fixture explicitly drives the already-accepted services.


func _site(label: String, at: Vector3) -> ConstructionSite:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(is_instance_valid(definition))
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _structure(
	path: String, label: String, at: Vector3
) -> PrototypePowerStructure:
	var scene := load(path) as PackedScene
	assert(scene != null)
	var structure := scene.instantiate() as PrototypePowerStructure
	assert(is_instance_valid(structure))
	structure.name = label
	add_child(structure)
	structure.global_position = at
	return structure


func _ready() -> void:
	var inspector := BlueprintConstructionRequirementsInspector.new()
	var absent: Dictionary = inspector.inspect(null)
	assert(not bool(absent["site_valid"]))
	assert(not bool(absent["live_construction_ready"]))
	print("PASS A: Null site reports invalid status without granting readiness")

	var site: ConstructionSite = _site("InspectionStorage", Vector3(6, 0, 0))
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(is_instance_valid(ingot))
	var view: Dictionary = inspector.inspect(site)
	assert(bool(view["site_valid"]))
	assert(view["state"] == int(ConstructionJob.State.PLANNED))
	assert(view["building_name"] == "Test Storage")
	assert(view["priority"] == "Normal")
	assert(is_equal_approx(float(view["progress"]), 0.0))
	assert(view["required_materials"] == {ingot: 3})
	print("PASS B: Planned site shows its actual definition-owned material bill")

	assert(not bool(view["stock_known"]))
	assert(not bool(view["escrow_known"]))
	assert(not bool(view["power_known"]))
	assert(not bool(view["worker_known"]))
	assert(not bool(view["prototype_gates_observed"]))
	print("PASS C: Missing services are unknown, never automatically ready")

	var empty_site := ConstructionSite.new()
	add_child(empty_site)
	var invalid: Dictionary = inspector.inspect(empty_site)
	assert(not bool(invalid["site_valid"]))
	assert(not bool(invalid["bill_valid"]))
	print("PASS D: Unconfigured construction site fails closed")

	var stock := InventoryComponent.new()
	stock.max_capacity = 20
	add_child(stock)
	view = inspector.inspect(site, stock)
	assert(bool(view["stock_known"]))
	assert(not bool(view["stock_sufficient"]))
	assert(int(view["missing_materials"].get(ingot, -1)) == 3)
	print("PASS E: Empty live inventory reports full material deficit")

	assert(stock.add_item(ingot, 2) == 2)
	view = inspector.inspect(site, stock)
	assert(not bool(view["stock_sufficient"]))
	assert(int(view["missing_materials"].get(ingot, -1)) == 1)
	print("PASS F: Partial inventory reports exact shortage")

	assert(stock.add_item(ingot, 1) == 1)
	view = inspector.inspect(site, stock)
	assert(bool(view["stock_sufficient"]))
	assert((view["missing_materials"] as Dictionary).is_empty())
	assert(not bool(view["materials_reserved"]))
	assert(not bool(view["prototype_gates_observed"]))
	print("PASS G: Sufficient warehouse stock does not imply a material reservation")

	assert(site.job.authorize())
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var reservation_id: int = escrow.reserve(
		site, stock, ConstructionMaterialBill.get_costs(site.target_definition)
	)
	assert(reservation_id > 0)
	view = inspector.inspect(site, stock, escrow)
	assert(bool(view["escrow_known"]))
	assert(bool(view["materials_reserved"]))
	assert(not bool(view["stock_sufficient"]))
	assert(stock.get_amount(ingot) == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS H: Held job escrow is distinct from remaining warehouse inventory")

	for i: int in range(4):
		view = inspector.inspect(site, stock, escrow)
		assert(bool(view["materials_reserved"]))
	assert(escrow.held_count() == 1)
	assert(stock.get_total_amount() == 0)
	assert(site.job.get_progress() == 0.0)
	print("PASS I: Repeated inspections do not withdraw items or advance work")

	var network := ConstructionPowerCoverageNetwork.new()
	add_child(network)
	var power := PrototypeConstructionPowerAllocator.new()
	add_child(power)
	assert(power.configure(network))
	var hub: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_main_hub.tscn",
		"InspectionHub", Vector3.ZERO
	)
	var pole: PrototypePowerStructure = _structure(
		"res://scenes/buildings/prototype_power_pole.tscn",
		"InspectionPole", Vector3(6, 0, 0)
	)
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(network.covers_site(site))
	print("PASS J: Inspector fixture uses completed Hub and explicit relay link")

	view = inspector.inspect(site, stock, escrow, power)
	assert(bool(view["power_known"]))
	assert(not bool(view["prototype_power_allocated"]))
	assert(not bool(view["worker_known"]))
	assert(not bool(view["prototype_gates_observed"]))
	print("PASS K: Coverage alone cannot be reported as allocated power")

	assert(power.track_site(site, 7))
	view = inspector.inspect(site, stock, escrow, power)
	assert(bool(view["prototype_power_allocated"]))
	assert(not bool(view["worker_active"]))
	assert(not bool(view["prototype_gates_observed"]))
	print("PASS L: Finite power allocation does not fabricate a worker")

	var queue := BlueprintConstructionPriorityQueue.new()
	add_child(queue)
	var scheduler := BlueprintConstructionSlotScheduler.new()
	add_child(scheduler)
	assert(scheduler.configure(queue, 1))
	assert(scheduler.track_authorized_site(site))
	view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(bool(view["worker_known"]))
	assert(not bool(view["worker_active"]))
	print("PASS M: Tracked worker queue does not imply an assigned slot")

	assert(scheduler.update_requirements(site, true, true))
	assert(scheduler.reconcile() == 1)
	view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(bool(view["materials_reserved"]))
	assert(bool(view["prototype_power_allocated"]))
	assert(bool(view["worker_active"]))
	assert(bool(view["prototype_gates_observed"]))
	assert(not bool(view["live_construction_ready"]))
	print("PASS N: Three observed prototype gates are NOT production certification")

	site.job.advance(2.0)
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	for i: int in range(4):
		view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	assert(escrow.held_count() == 1 and stock.get_total_amount() == 0)
	print("PASS O: Observation preserves progress, materials and worker assignment")

	assert(hub.set_generator_enabled(false))
	view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(not bool(view["prototype_power_allocated"]))
	assert(bool(view["worker_active"]))
	assert(not bool(view["prototype_gates_observed"]))
	print("PASS P: Inspection exposes stale worker state on outage without changing it")

	assert(scheduler.update_requirements(site, false, true))
	assert(scheduler.reconcile() == 0)
	view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(not bool(view["worker_active"]))
	site.job.advance(200.0)
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	assert(escrow.reservation_for(site) == reservation_id)
	print("PASS Q: Existing scheduler pauses work and preserves escrow on outage")

	assert(hub.set_generator_enabled(true))
	assert(scheduler.update_requirements(site, true, true))
	assert(scheduler.reconcile() == 1)
	view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(bool(view["prototype_gates_observed"]))
	assert(not bool(view["live_construction_ready"]))
	assert(is_equal_approx(site.job.get_progress(), 0.2))
	assert(site.job.cancel())
	assert(scheduler.reconcile() == 0)
	view = inspector.inspect(site, stock, escrow, power, scheduler)
	assert(not bool(view["prototype_gates_observed"]))
	assert(not bool(view["materials_reserved"]))
	assert(stock.get_amount(ingot) == 3)
	assert(not escrow.has_reservation(reservation_id))
	print("PASS R: Restored prototype gates and cancellation remain observational")

	print("ALL 18 E3D5C3D1 CONSTRUCTION REQUIREMENTS INSPECTOR TESTS PASSED")
