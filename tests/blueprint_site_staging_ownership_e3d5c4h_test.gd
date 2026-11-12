extends Node3D

# =============================================================================
# E3D5C4H — TWO-SITE STAGING OWNERSHIP AND ATOMIC ESCROW (ISOLATED)
# =============================================================================
# This fixture exercises authorization, per-site claim ownership and recovery
# without granting power, workers or construction time. Test ingots are seeded
# ONLY in separate source inventories: this is an ownership test, NOT an
# end-to-end production/transport test (E3d5c4g already covers that route).


func _ready() -> void:
	call_deferred("_run_checks")


func _site(
	definition: BuildingDefinition, label: String, position: Vector3
) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.position = position
	site.set_process(false)
	return site


func _stock(label: String, item: ItemDefinition, quantity: int) -> InventoryComponent:
	var inventory := InventoryComponent.new()
	inventory.name = label
	inventory.max_capacity = 10
	add_child(inventory)
	assert(inventory.add_item(item, quantity) == quantity)
	return inventory


func _staging(
	label: String,
	source: InventoryComponent,
	definition: BuildingDefinition
) -> BlueprintConstructionMaterialStaging:
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.name = label
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(source, definition, 3))
	return staging


func _port(
	label: String, staging: BlueprintConstructionMaterialStaging
) -> BlueprintConstructionStagingInputPort:
	var root := Node3D.new()
	root.name = label + "Receiver"
	add_child(root)
	var port := BlueprintConstructionStagingInputPort.new()
	port.name = label
	port.show_port_label = false
	port.enable_isolated_input = true
	root.add_child(port)
	assert(port.bind_staging(staging))
	return port


func _run_checks() -> void:
	var storage_definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var smelter_definition := load(
		"res://data/buildings/test_smelter.tres"
	) as BuildingDefinition
	var ingot := load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition
	assert(storage_definition != null)
	assert(smelter_definition != null and ingot != null)
	var costs: Dictionary = ConstructionMaterialBill.get_costs(storage_definition)
	assert(costs.size() == 1 and int(costs.get(ingot, 0)) == 3)

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	assert(not registry.enable_isolated_site_registry)
	assert(registry.claim_count() == 0)
	assert(registry.inventory_for_site(null) == null)
	assert(registry.reserve_for_site(null, escrow) == 0)
	print("PASS A: Site material ownership defaults OFF and cannot reserve")

	var source_a := _stock("RealTestSourceA", ingot, 6)
	var source_b := _stock("RealTestSourceB", ingot, 3)
	var staging_a := _staging("StagingForA", source_a, storage_definition)
	var staging_b := _staging("StagingForB", source_b, storage_definition)
	var buffer_a := staging_a.get_staged_inventory()
	var buffer_b := staging_b.get_staged_inventory()
	assert(buffer_a != null and buffer_b != null and buffer_a != buffer_b)
	assert(staging_a.matches_definition(storage_definition))
	assert(staging_b.matches_definition(storage_definition))
	assert(not staging_a.matches_definition(smelter_definition))
	assert(buffer_a.get_total_amount() == 0 and buffer_b.get_total_amount() == 0)
	print("PASS B: Two empty distinct buffers carry exact Test Storage bills")

	var port_a := _port("InputForA", staging_a)
	var port_b := _port("InputForB", staging_b)
	assert(port_a.get_bound_staging() == staging_a)
	assert(port_b.get_bound_staging() == staging_b)
	assert(port_a.inventory == buffer_a and port_b.inventory == buffer_b)
	assert(port_a.can_accept_item(ingot) and port_b.can_accept_item(ingot))
	print("PASS C: Two opt-in ports bind only their respective staging buffers")

	var first := _site(storage_definition, "HighSiteA", Vector3(-6, 0, 0))
	var second := _site(storage_definition, "NormalSiteB", Vector3(6, 0, 0))
	assert(not registry.claim_site(first, staging_a, port_a))
	registry.enable_isolated_site_registry = true
	assert(not registry.claim_site(first, staging_a, port_a))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(registry.claim_count() == 0)
	print("PASS D: PLANNED work cannot claim staged stock, even with registry ON")

	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(not registry.claim_site(first, staging_a, port_a))
	assert(first.job.get_progress() == 0.0)
	print("PASS E: High priority alone never authorizes a material receiver")

	var wrong_bill := _site(smelter_definition, "SmelterMismatch", Vector3(0, 0, 6))
	assert(wrong_bill.job.authorize())
	assert(not registry.claim_site(wrong_bill, staging_a, port_a))
	assert(registry.claim_count() == 0)
	print("PASS F: Smelter bill cannot falsely claim Storage-specific staging")

	assert(first.job.authorize())
	assert(registry.claim_site(first, staging_a, port_a))
	assert(registry.claim_count() == 1)
	assert(registry.inventory_for_site(first) == buffer_a)
	assert(registry.inventory_for_site(second) == null)
	print("PASS G: Authorized first site exclusively claims its verified port and buffer")

	assert(not registry.claim_site(first, staging_a, port_a))
	assert(second.job.authorize())
	assert(not registry.claim_site(second, staging_a, port_a))
	assert(registry.claim_count() == 1)
	print("PASS H: Same site and second site cannot reuse the claimed A receiver")

	assert(not registry.claim_site(second, staging_b, port_a))
	assert(registry.inventory_for_site(second) == null)
	assert(registry.claim_count() == 1)
	print("PASS I: Mixed port/buffer identity cannot authorize cross-site stock")

	assert(registry.claim_site(second, staging_b, port_b))
	assert(registry.claim_count() == 2)
	assert(registry.inventory_for_site(second) == buffer_b)
	assert(registry.inventory_for_site(first) == buffer_a)
	assert(registry.inventory_for_site(wrong_bill) == null)
	print("PASS J: Authorized second site receives its own independent claim")

	registry.enable_isolated_site_registry = false
	assert(registry.inventory_for_site(first) == null)
	assert(registry.reserve_for_site(first, escrow) == 0)
	assert(buffer_a.get_total_amount() == 0)
	registry.enable_isolated_site_registry = true
	print("PASS K: Disabling the feature immediately blocks lookup and escrow")

	assert(staging_a.receive_item(ingot, 2) == 2)
	assert(buffer_a.get_amount(ingot) == 2)
	assert(registry.reserve_for_site(first, escrow) == 0)
	assert(registry.reserve_for_site(second, escrow) == 0)
	assert(escrow.held_count() == 0)
	assert(source_a.get_amount(ingot) == 4)
	assert(source_b.get_amount(ingot) == 3)
	print("PASS L: Incomplete A supply cannot reserve; untouched B never borrows")

	assert(staging_a.receive_item(ingot, 1) == 1)
	var first_id: int = registry.reserve_for_site(first, escrow)
	assert(first_id > 0)
	assert(escrow.reservation_for(first) == first_id)
	assert(escrow.held_materials(first_id) == costs)
	assert(registry.reserve_for_site(first, escrow) == 0)
	assert(registry.reserve_for_site(second, escrow) == 0)
	assert(buffer_a.get_amount(ingot) == 0)
	assert(source_a.get_amount(ingot) == 3)
	print("PASS M: A alone atomically holds three ingots; B cannot double-spend A")

	assert(staging_b.receive_item(ingot, 3) == 3)
	var second_id: int = registry.reserve_for_site(second, escrow)
	assert(second_id > first_id)
	assert(escrow.reservation_for(second) == second_id)
	assert(escrow.held_materials(second_id) == costs)
	assert(buffer_b.get_total_amount() == 0)
	assert(source_b.get_amount(ingot) == 0)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_progress() == 0.0 and second.job.get_progress() == 0.0)
	print("PASS N: Both jobs escrow separate bills without worker/power dispatch")

	# Full staging prevents cancelled A from refunding its escrow. Existing
	# Escrow must KEEP the reservation for an explicit alternate recovery.
	assert(staging_a.receive_item(ingot, 3) == 3)
	assert(buffer_a.get_amount(ingot) == 3)
	assert(first.job.cancel())
	assert(escrow.has_reservation(first_id))
	assert(escrow.needs_recovery(first_id))
	assert(registry.inventory_for_site(first) == null)
	assert(escrow.reservation_for(second) == second_id)
	assert(not escrow.recover_to(first_id))
	assert(escrow.recover_to(first_id, source_a))
	assert(not escrow.has_reservation(first_id))
	assert(source_a.get_amount(ingot) == 3)
	assert(buffer_a.get_amount(ingot) == 3)
	assert(registry.claim_count() == 2)
	print("PASS O: Cancelled A stays locked; full-buffer refund uses exact alternate stock")

	# A second plan may not inherit cancelled A's claimed staging port.
	var replacement := _site(
		storage_definition, "ReplacementA", Vector3(-12, 0, 0)
	)
	assert(replacement.job.authorize())
	assert(not registry.claim_site(replacement, staging_a, port_a))
	assert(registry.inventory_for_site(replacement) == null)
	assert(second.job.cancel())
	assert(not escrow.has_reservation(second_id))
	assert(buffer_b.get_amount(ingot) == 3)
	assert(escrow.held_count() == 0)
	assert(
		source_a.get_amount(ingot) + buffer_a.get_amount(ingot)
		+ source_b.get_amount(ingot) + buffer_b.get_amount(ingot) == 9
	)
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionSiteStagingRegistry") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSiteStagingRegistry") == null)
	main.free()
	sandbox.free()
	print("PASS P: Cancelled stock is never reassigned; nine ingots remain conserved")

	print("ALL 16 E3D5C4H PER-SITE CONSTRUCTION STAGING OWNERSHIP TESTS PASSED")
	print("TEST ONLY: Owner claims and escrow, not physical delivery, power, workers or save/load.")
