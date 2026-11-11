extends Node3D

# =============================================================================
# E3D5C1 — READ-ONLY READINESS INSPECTION SAFETY GATE
# =============================================================================
# Synthetic power reports and a test-only BOM are used here. No actual power
# provider, reservation, construction worker, or live sandbox integration
# exists in this checkpoint.


func _site(label: String, offset: Vector3) -> ConstructionSite:
	var definition: BuildingDefinition = load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_job(definition, 10.0))
	add_child(site)
	site.position = offset
	site.set_process(false)
	return site


func _ready() -> void:
	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition
	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition
	assert(ore != null and ingot != null)
	var probe := BlueprintConstructionReadinessProbe.new()
	var stock := InventoryComponent.new()
	stock.name = "SharedTestStock"
	stock.max_capacity = 20
	add_child(stock)
	var bill: Dictionary = {ore: 3, ingot: 2}
	var first: ConstructionSite = _site("FirstAuthorized", Vector3(-4, 0, 0))

	var report: Dictionary = probe.inspect(first, true, stock, bill)
	assert(not bool(report["authorized"]))
	assert(not bool(report["stock_sufficient"]))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	print("PASS A: Planned work cannot be considered authorized")

	assert(first.job.authorize())
	report = probe.inspect(first, null, null, {})
	assert(bool(report["authorized"]))
	assert(not bool(report["power_known"]))
	assert(not bool(report["bill_valid"]))
	assert(not bool(report["stock_known"]))
	print("PASS B: Unknown power, costs, and stock fail closed")

	report = probe.inspect(first, "powered", stock, bill)
	assert(not bool(report["power_known"]))
	assert(not bool(report["power_covered"]))
	print("PASS C: Malformed power reports never count as coverage")

	report = probe.inspect(first, false, stock, bill)
	assert(bool(report["power_known"]))
	assert(not bool(report["power_covered"]))
	print("PASS D: Explicit power denial is distinguishable from unknown power")

	report = probe.inspect(first, true, stock, {})
	assert(not bool(report["bill_valid"]))
	assert(not bool(report["stock_sufficient"]))
	print("PASS E: Missing construction cost cannot mean a free building")

	for bad_bill: Dictionary in [
		{ore: 0}, {ore: -1}, {ore: 1.0}, {"ore": 1}
	]:
		report = probe.inspect(first, true, stock, bad_bill)
		assert(not bool(report["bill_valid"]))
		assert(not bool(report["stock_sufficient"]))
	print("PASS F: Zero, negative, fractional, and non-item costs are rejected")

	var detached := InventoryComponent.new()
	report = probe.inspect(first, true, detached, bill)
	assert(bool(report["bill_valid"]))
	assert(not bool(report["stock_known"]))
	detached.free()
	print("PASS G: Detached stock is not accepted as a live source")

	report = probe.inspect(first, true, stock, bill)
	var missing: Dictionary = report["missing_materials"]
	assert(bool(report["stock_known"]))
	assert(not bool(report["stock_sufficient"]))
	assert(int(missing.get(ore, 0)) == 3)
	assert(int(missing.get(ingot, 0)) == 2)
	print("PASS H: Empty stock reports both material deficits")

	assert(stock.add_item(ore, 2) == 2)
	assert(stock.add_item(ingot, 1) == 1)
	report = probe.inspect(first, true, stock, bill)
	missing = report["missing_materials"]
	assert(int(missing.get(ore, 0)) == 1)
	assert(int(missing.get(ingot, 0)) == 1)
	assert(not bool(report["stock_sufficient"]))
	print("PASS I: Partial delivery reports exact shortages")

	assert(stock.add_item(ore, 1) == 1)
	report = probe.inspect(first, true, stock, bill)
	missing = report["missing_materials"]
	assert(not missing.has(ore))
	assert(int(missing.get(ingot, 0)) == 1)
	print("PASS J: Filling one cost does not mask another shortage")

	assert(stock.add_item(ingot, 1) == 1)
	report = probe.inspect(first, true, stock, bill)
	assert(bool(report["power_covered"]))
	assert(bool(report["stock_sufficient"]))
	assert((report["missing_materials"] as Dictionary).is_empty())
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_wait_reasons().size() == 3)
	print("PASS K: Visible stock is NOT worker permission or material reservation")

	for index: int in range(3):
		report = probe.inspect(first, true, stock, bill)
		assert(bool(report["stock_sufficient"]))
	assert(stock.get_amount(ore) == 3)
	assert(stock.get_amount(ingot) == 2)
	assert(first.job.get_progress() == 0.0)
	print("PASS L: Repeated inspections are non-consuming and preserve progress")

	var second: ConstructionSite = _site(
		"SecondAuthorized", Vector3(4, 0, 0)
	)
	assert(second.job.authorize())
	assert(bool(probe.inspect(second, true, stock, bill)["stock_sufficient"]))
	assert(bool(probe.inspect(first, true, stock, bill)["stock_sufficient"]))
	assert(stock.get_amount(ore) == 3)
	assert(stock.get_amount(ingot) == 2)
	print("PASS M: Shared stock is NOT reserved twice by read-only inspection")

	var queue := BlueprintConstructionPriorityQueue.new()
	add_child(queue)
	var scheduler := BlueprintConstructionSlotScheduler.new()
	add_child(scheduler)
	assert(scheduler.configure(queue, 1))
	assert(scheduler.track_authorized_site(first))
	assert(scheduler.track_authorized_site(second))
	assert(scheduler.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(scheduler.get_waiting_count() == 2)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	print("PASS N: Scheduler stays fail-closed without verified reservations")

	assert(second.job.cancel())
	report = probe.inspect(second, true, stock, bill)
	assert(not bool(report["authorized"]))
	assert(not bool(report["stock_sufficient"]))
	assert(scheduler.reconcile() == 0)
	assert(scheduler.get_waiting_count() == 1)
	assert(stock.get_amount(ore) == 3)
	assert(stock.get_amount(ingot) == 2)
	print("PASS O: Cancelled sites cannot pass inspection or affect inventory")

	print("ALL 15 E3D5C1 CONSTRUCTION READINESS PROBE TESTS PASSED")
