extends Node3D

# =============================================================================
# E3D5C2A — ISOLATED ATOMIC MATERIAL ESCROW ACCEPTANCE
# =============================================================================

func _site(label: String, position_in_world: Vector3) -> ConstructionSite:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_job(definition, 10.0))
	add_child(site)
	site.position = position_in_world
	site.set_process(false)
	return site


func _stock(
	label: String, ore: ItemDefinition, ingot: ItemDefinition,
	ore_count: int, ingot_count: int
) -> InventoryComponent:
	var inventory := InventoryComponent.new()
	inventory.name = label
	inventory.max_capacity = 20
	add_child(inventory)
	if ore_count > 0:
		assert(inventory.add_item(ore, ore_count) == ore_count)
	if ingot_count > 0:
		assert(inventory.add_item(ingot, ingot_count) == ingot_count)
	return inventory


func _ready() -> void:
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	var costs: Dictionary = {ore: 3, ingot: 2}
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var source: InventoryComponent = _stock("SharedSource", ore, ingot, 5, 3)
	var first: ConstructionSite = _site("First", Vector3(-6, 0, 0))

	assert(escrow.reserve(first, source, costs) == 0)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(source.get_total_amount() == 8)
	print("PASS A: Unauthorised blueprint cannot reserve materials")

	assert(first.job.authorize())
	var detached := InventoryComponent.new()
	assert(escrow.reserve(first, detached, costs) == 0)
	detached.free()
	assert(escrow.reserve(first, source, {}) == 0)
	assert(source.get_total_amount() == 8)
	print("PASS B: Detached inventory and missing bill fail closed")

	for invalid: Dictionary in [{ore: 0}, {ore: -2}, {ore: 1.5}, {"ore": 1}]:
		assert(escrow.reserve(first, source, invalid) == 0)
	assert(source.get_total_amount() == 8)
	print("PASS C: Malformed construction costs cannot debit inventory")

	assert(escrow.reserve(first, source, {ore: 6, ingot: 2}) == 0)
	assert(source.get_amount(ore) == 5 and source.get_amount(ingot) == 3)
	print("PASS D: Insufficient mixed cost is all-or-nothing")

	var first_id: int = escrow.reserve(first, source, costs)
	assert(first_id > 0)
	assert(escrow.held_materials(first_id) == costs)
	assert(source.get_amount(ore) == 2 and source.get_amount(ingot) == 1)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS E: Valid bill is held exactly once for one job")

	assert(escrow.reserve(first, source, costs) == 0)
	assert(escrow.reservation_for(first) == first_id)
	assert(escrow.held_count() == 1)
	print("PASS F: Same site cannot create duplicate escrow")

	var second: ConstructionSite = _site("Second", Vector3(0, 0, 0))
	assert(second.job.authorize())
	assert(escrow.reserve(second, source, costs) == 0)
	assert(source.get_amount(ore) == 2 and source.get_amount(ingot) == 1)
	print("PASS G: Competing site cannot double-claim held resources")

	var probe := BlueprintConstructionReadinessProbe.new()
	var snapshot: Dictionary = probe.inspect(second, true, source, costs)
	var shortages: Dictionary = snapshot["missing_materials"]
	assert(not bool(snapshot["stock_sufficient"]))
	assert(int(shortages[ore]) == 1 and int(shortages[ingot]) == 1)
	print("PASS H: Existing readiness probe sees unreserved stock only")

	assert(escrow.recover_to(first_id))
	assert(not escrow.has_reservation(first_id))
	assert(source.get_amount(ore) == 5 and source.get_amount(ingot) == 3)
	assert(not escrow.recover_to(first_id))
	print("PASS I: Explicit release refunds one complete bill exactly once")

	var second_id: int = escrow.reserve(second, source, costs)
	assert(second_id > first_id)
	assert(source.get_amount(ore) == 2 and source.get_amount(ingot) == 1)
	assert(escrow.reserve(first, source, costs) == 0)
	print("PASS J: Next job can claim only genuinely returned materials")

	assert(second.job.cancel())
	assert(not escrow.has_reservation(second_id))
	assert(source.get_amount(ore) == 5 and source.get_amount(ingot) == 3)
	print("PASS K: Cancelling a site automatically refunds its escrow")

	var third: ConstructionSite = _site("FullReturn", Vector3(6, 0, 0))
	assert(third.job.authorize())
	var third_id: int = escrow.reserve(third, source, costs)
	assert(third_id > second_id)
	source.max_capacity = 8
	assert(source.add_item(ore, 5) == 5)
	assert(source.get_total_amount() == 8)
	assert(third.job.cancel())
	assert(escrow.has_reservation(third_id))
	assert(escrow.needs_recovery(third_id))
	assert(not escrow.recover_to(third_id))
	print("PASS L: Full refund destination retains items safely in escrow")

	var alternate: InventoryComponent = _stock("RecoveryStock", ore, ingot, 0, 0)
	assert(escrow.recover_to(third_id, alternate))
	assert(alternate.get_amount(ore) == 3 and alternate.get_amount(ingot) == 2)
	assert(not escrow.has_reservation(third_id))
	print("PASS M: Alternate live inventory recovers entire held bill")

	assert(not escrow.recover_to(third_id, alternate))
	assert(source.get_total_amount() + alternate.get_total_amount() == 13)
	assert(escrow.held_count() == 0)
	print("PASS N: Duplicate recovery rejected and all units conserved")

	var build_stock: InventoryComponent = _stock("BuildStock", ore, ingot, 3, 2)
	var completed: ConstructionSite = _site("Finished", Vector3(12, 0, 0))
	assert(completed.job.authorize())
	var built: Array[Node3D] = []
	completed.building_completed.connect(
		func(building: Node3D) -> void: built.append(building)
	)
	var completion_id: int = escrow.reserve(completed, build_stock, costs)
	assert(completion_id > 0 and completed.job.get_progress() == 0.0)
	assert(completed.job.set_availability(true, true, true))
	completed.job.advance(10.0)
	assert(completed.job.state == ConstructionJob.State.COMPLETE)
	assert(built.size() == 1)
	assert(not escrow.has_reservation(completion_id))
	assert(not escrow.commit_built(completion_id))
	assert(build_stock.get_total_amount() == 0)
	print("PASS O: Real completed building consumes escrow only once")

	var queue := BlueprintConstructionPriorityQueue.new()
	add_child(queue)
	var scheduler := BlueprintConstructionSlotScheduler.new()
	add_child(scheduler)
	assert(scheduler.configure(queue, 1))
	var waiting: ConstructionSite = _site("Waiting", Vector3(18, 0, 0))
	assert(waiting.job.authorize())
	var wait_stock: InventoryComponent = _stock("WaitingStock", ore, ingot, 3, 2)
	var wait_id: int = escrow.reserve(waiting, wait_stock, costs)
	assert(wait_id > 0)
	assert(scheduler.track_authorized_site(waiting))
	assert(scheduler.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(waiting.job.state == ConstructionJob.State.QUEUED)
	assert(wait_stock.get_total_amount() == 0)
	waiting.free()
	assert(not escrow.has_reservation(wait_id))
	assert(wait_stock.get_amount(ore) == 3 and wait_stock.get_amount(ingot) == 2)
	print("PASS P: Reserved materials never bypass workers; removed sites refund")

	print("ALL 16 E3D5C2A CONSTRUCTION MATERIAL ESCROW TESTS PASSED")
