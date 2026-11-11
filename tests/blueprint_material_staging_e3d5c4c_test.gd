extends Node3D

# =============================================================================
# E3D5C4C — BOUNDED MATERIAL STAGING, ESCROW AND RECOVERY (ISOLATED)
# =============================================================================
# Items move by InventoryComponent.transfer_to(), not by spawning items.
# There is NO physical conveyor connection or delivered power in this test.
# ConstructionSite timers are disabled; no real worker services are attached.


func _ready() -> void:
	call_deferred("_run_checks")


func _make_site(
	definition: BuildingDefinition,
	label: String,
	where: Vector3
) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = where
	site.set_process(false)
	return site


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ingot != null and ore != null)
	var bill: Dictionary = ConstructionMaterialBill.get_costs(definition)
	assert(bill.get(ingot, 0) == 3 and bill.size() == 1)

	var staging := BlueprintConstructionMaterialStaging.new()
	add_child(staging)
	assert(not staging.enable_isolated_staging)
	assert(staging.get_staged_inventory() == null)
	assert(staging.receive_item(ingot, 1) == 0)
	print("PASS A: Material staging defaults OFF and transfers nothing")

	var source := InventoryComponent.new()
	source.name = "TestSupply"
	source.max_capacity = 5
	add_child(source)
	assert(source.add_item(ingot, 5) == 5)
	assert(not staging.configure(source, definition, 4))
	print("PASS B: Explicit opt-in is required before staging can be configured")

	staging.enable_isolated_staging = true
	var detached := InventoryComponent.new()
	assert(not staging.configure(detached, definition, 4))
	detached.free()
	assert(not staging.configure(source, definition, 2))
	assert(source.get_amount(ingot) == 5)
	print("PASS C: Detached supply and sub-bill capacities fail closed")

	assert(staging.configure(source, definition, 4))
	assert(not staging.configure(source, definition, 4))
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer != null and buffer.max_capacity == 4)
	assert(buffer.get_total_amount() == 0)
	assert(source.get_amount(ingot) == 5)
	assert(int(staging.missing_for_bill().get(ingot, 0)) == 3)
	print("PASS D: Valid test-only buffer starts empty and cannot reconfigure")

	assert(staging.receive_item(ore, 1) == 0)
	assert(staging.receive_item(ingot, 0) == 0)
	assert(staging.receive_item(ingot, -1) == 0)
	assert(buffer.get_total_amount() == 0 and source.get_amount(ingot) == 5)
	print("PASS E: Wrong items and invalid quantities cannot enter buffer")

	assert(staging.receive_item(ingot, 2) == 2)
	assert(source.get_amount(ingot) == 3)
	assert(buffer.get_amount(ingot) == 2)
	assert(int(staging.missing_for_bill().get(ingot, 0)) == 1)
	print("PASS F: Partial inventory transfer preserves exact unit conservation")

	var first := _make_site(definition, "HighJob", Vector3(-4, 0, 0))
	var second := _make_site(definition, "NormalJob", Vector3(4, 0, 0))
	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.get_progress() == 0.0)
	print("PASS G: Priorities and staged stock do not authorize planned work")

	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	for service: Node in [queue, scheduler, escrow, network, power, coordinator]:
		add_child(service)
	assert(power.configure(network))
	assert(coordinator.configure(queue, scheduler, escrow, power, buffer, 1))
	assert(not coordinator.track_site(first, 7))
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	print("PASS H: Coordinator cannot admit unapproved work or invent inventory")

	assert(first.job.authorize())
	assert(second.job.authorize())
	assert(coordinator.track_site(first, 7))
	assert(coordinator.track_site(second, 7))
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_wait_reasons().size() == 3)
	print("PASS I: Explicitly authorized jobs can wait for staged material supply")

	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(buffer.get_amount(ingot) == 2)
	assert(second.job.get_progress() == 0.0)
	print("PASS J: A partial bill cannot obtain escrow, power or worker permission")

	assert(staging.receive_item(ingot, 1) == 1)
	assert(staging.missing_for_bill().is_empty())
	assert(coordinator.reconcile() == 0)
	var first_id: int = escrow.reservation_for(first)
	assert(first_id > 0)
	assert(escrow.held_materials(first_id) == bill)
	assert(buffer.get_amount(ingot) == 0)
	assert(source.get_amount(ingot) == 2)
	assert(scheduler.get_active_count() == 0)
	print("PASS K: A full bill is escrowed once for High; no power means QUEUED")

	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(first) == first_id)
	assert(escrow.reservation_for(second) == 0)
	assert(escrow.held_count() == 1)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	print("PASS L: Reconciliation never double-spends or starts either job")

	assert(staging.receive_item(ingot, 2) == 2)
	assert(source.get_amount(ingot) == 0)
	assert(buffer.get_amount(ingot) == 2)
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(second) == 0)
	assert(
		source.get_amount(ingot) + buffer.get_amount(ingot)
		+ int(escrow.held_materials(first_id).get(ingot, 0)) == 5
	)
	print("PASS M: Insufficient remainder stays buffered and all five ingots conserved")

	assert(first.job.cancel())
	assert(escrow.has_reservation(first_id))
	assert(escrow.needs_recovery(first_id))
	assert(buffer.get_amount(ingot) == 2)
	assert(not escrow.recover_to(first_id))
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(second) == 0)
	print("PASS N: Cancelled High job cannot refund into a full staging buffer")

	assert(escrow.recover_to(first_id, source))
	assert(not escrow.has_reservation(first_id))
	assert(not escrow.recover_to(first_id, source))
	assert(source.get_amount(ingot) == 3)
	assert(buffer.get_amount(ingot) == 2)
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(second) == 0)
	print("PASS O: Alternate source recovery is exact and cannot be repeated")

	assert(staging.receive_item(ingot, 1) == 1)
	assert(coordinator.reconcile() == 0)
	var second_id: int = escrow.reservation_for(second)
	assert(second_id > 0)
	assert(escrow.held_materials(second_id) == bill)
	assert(source.get_amount(ingot) == 2)
	assert(buffer.get_amount(ingot) == 0)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.get_progress() == 0.0)
	assert(scheduler.get_active_count() == 0)
	staging.enable_isolated_staging = false
	assert(staging.receive_item(ingot, 1) == 0)
	assert(source.get_amount(ingot) == 2)
	assert(escrow.held_count() == 1)
	print("PASS P: Recovered stock funds next job without power/workers or new items")

	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionMaterialStaging") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionMaterialStaging") == null)
	main.free()
	sandbox.free()
	print("ALL 16 E3D5C4C MATERIAL STAGING AND RECOVERY TESTS PASSED")
	print("TEST ONLY: Inventory transfer is NOT physical conveyor delivery.")
