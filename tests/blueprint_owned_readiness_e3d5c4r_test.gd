extends Node3D

# E3D5C4R — Test-only handoff from two independently claimed site buffers
# to finite prototype power and one synthetic worker slot.
# All jobs are manually advanced. No playable scene is changed.

func _ready() -> void:
	call_deferred("_run_checks")


func _site(definition: BuildingDefinition, label: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _stock(item: ItemDefinition, amount: int) -> InventoryComponent:
	var stock := InventoryComponent.new()
	stock.max_capacity = 16
	add_child(stock)
	assert(stock.add_item(item, amount) == amount)
	return stock


func _stage(
	source: InventoryComponent, definition: BuildingDefinition
) -> BlueprintConstructionMaterialStaging:
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(source, definition, 3))
	return staging


func _attach(
	site: ConstructionSite,
	staging: BlueprintConstructionMaterialStaging,
	registry: BlueprintConstructionSiteStagingRegistry
) -> BlueprintConstructionAnchoredStagingPort:
	var receiver := Node3D.new()
	add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "InputPort"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver.add_child(port)
	assert(port.attach_to_authorized_site(site, staging, registry))
	assert(port.matches_attached_site())
	return port


func _structure(path: String, at: Vector3) -> PrototypePowerStructure:
	var packed := load(path) as PackedScene
	assert(packed != null)
	var structure := packed.instantiate() as PrototypePowerStructure
	assert(structure != null)
	add_child(structure)
	structure.global_position = at
	return structure


func _run_checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)
	var cost: Dictionary = ConstructionMaterialBill.get_costs(definition)
	assert(int(cost.get(ingot, 0)) == 3)

	var registry := BlueprintConstructionSiteStagingRegistry.new()
	var coordinator := BlueprintConstructionReadinessCoordinator.new()
	add_child(registry)
	add_child(coordinator)
	assert(not coordinator.enable_isolated_owned_staging)
	assert(not coordinator.configure_owned_staging(registry))
	assert(coordinator.reconcile() == 0)
	print("PASS A: Owned readiness defaults OFF and has no scheduling authority")

	var source_a := _stock(ingot, 3)
	var source_b := _stock(ingot, 3)
	var shared := _stock(ingot, 9)
	var staging_a := _stage(source_a, definition)
	var staging_b := _stage(source_b, definition)
	var buffer_a: InventoryComponent = staging_a.get_staged_inventory()
	var buffer_b: InventoryComponent = staging_b.get_staged_inventory()
	assert(buffer_a != buffer_b)
	assert(buffer_a.get_total_amount() == 0 and buffer_b.get_total_amount() == 0)
	print("PASS B: Two empty unique site buffers; separate warehouse contains nine")

	var high := _site(definition, "OwnedHigh", Vector3(6, 0, 0))
	var normal := _site(definition, "OwnedNormal", Vector3(6, 0, 1))
	assert(high.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(high.job.state == ConstructionJob.State.PLANNED)
	assert(not registry.matches_owned_inventory(high, buffer_a))
	print("PASS C: Higher priority does not authorize or claim materials")

	assert(high.job.authorize())
	assert(normal.job.authorize())
	registry.enable_isolated_site_registry = true
	var port_a := _attach(high, staging_a, registry)
	var port_b := _attach(normal, staging_b, registry)
	assert(registry.claim_count() == 2)
	assert(registry.inventory_for_site(high) == buffer_a)
	assert(registry.inventory_for_site(normal) == buffer_b)
	assert(not registry.claim_site(normal, staging_a, port_a))
	print("PASS D: Two authorized sites receive exclusive locked receiver claims")

	var queue := BlueprintConstructionPriorityQueue.new()
	var scheduler := BlueprintConstructionSlotScheduler.new()
	var escrow := BlueprintConstructionMaterialEscrow.new()
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	for service: Node in [queue, scheduler, escrow, network, power]:
		add_child(service)
	assert(power.configure(network))
	var hub := _structure("res://scenes/buildings/prototype_main_hub.tscn", Vector3.ZERO)
	var pole := _structure("res://scenes/buildings/prototype_power_pole.tscn", Vector3(6, 0, 0))
	assert(network.register_node(hub.get_power_node()))
	assert(network.register_node(pole.get_power_node()))
	assert(network.link_nodes(hub.get_power_node(), pole.get_power_node()))
	assert(hub.available_nameplate_generation() == 12)
	assert(coordinator.configure(queue, scheduler, escrow, power, shared, 1))
	assert(not coordinator.configure_owned_staging(registry))
	print("PASS E: Finite power and one worker configured, owned mode still OFF")

	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.configure_owned_staging(registry))
	assert(not coordinator.configure_owned_staging(registry))
	var unclaimed := _site(definition, "Unclaimed", Vector3(6, 0, -1))
	assert(unclaimed.job.authorize())
	assert(not coordinator.track_site(unclaimed, 7))
	assert(coordinator.track_site(high, 7))
	assert(coordinator.track_site(normal, 7))
	assert(not coordinator.track_site(normal, 7))
	print("PASS F: Only claimed authorized sites enter owned readiness")

	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0 and scheduler.get_active_count() == 0)
	assert(shared.get_amount(ingot) == 9)
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(normal.job.state == ConstructionJob.State.QUEUED)
	print("PASS G: Unrelated warehouse cannot fund an empty site buffer")

	assert(staging_b.receive_item(ingot, 2) == 2)
	assert(coordinator.reconcile() == 0)
	assert(escrow.held_count() == 0)
	assert(buffer_b.get_amount(ingot) == 2)
	print("PASS H: Partial staged stock cannot authorize a construction start")

	assert(staging_b.receive_item(ingot, 1) == 1)
	assert(coordinator.reconcile() == 1)
	var normal_id: int = escrow.reservation_for(normal)
	assert(normal_id > 0 and escrow.held_materials(normal_id) == cost)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(buffer_b.get_amount(ingot) == 0 and shared.get_amount(ingot) == 9)
	print("PASS I: Normal starts using three of its own ingots, no shared debit")

	assert(staging_a.receive_item(ingot, 2) == 2)
	assert(coordinator.reconcile() == 0)
	assert(escrow.reservation_for(high) == 0)
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(buffer_a.get_amount(ingot) == 2)
	print("PASS J: High cannot steal active Normal escrow or use partial staging")

	assert(staging_a.receive_item(ingot, 1) == 1)
	assert(coordinator.reconcile() == 0)
	var high_id: int = escrow.reservation_for(high)
	assert(high_id > 0 and high_id != normal_id)
	assert(escrow.held_materials(high_id) == cost)
	assert(high.job.state == ConstructionJob.State.QUEUED)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS K: High reserves own bill but cannot preempt active Normal")

	registry.enable_isolated_site_registry = false
	assert(coordinator.reconcile() == 0)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0 and escrow.held_count() == 2)
	print("PASS L: Ownership outage pauses work and preserves both escrows")

	registry.enable_isolated_site_registry = true
	coordinator.enable_isolated_owned_staging = false
	assert(coordinator.reconcile() == 0)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 0)
	print("PASS M: Disabled owned opt-in cannot fall back to shared stock")

	coordinator.enable_isolated_owned_staging = true
	assert(coordinator.reconcile() == 1)
	assert(high.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 1)
	print("PASS N: Restored resources dispatch waiting High first")

	normal.job.advance(5.0)
	high.job.advance(5.0)
	assert(is_equal_approx(normal.job.get_progress(), 0.0))
	assert(is_equal_approx(high.job.get_progress(), 0.5))
	print("PASS O: Manual time advances only ready work, not paused job")

	high.job.advance(5.0)
	assert(high.job.state == ConstructionJob.State.COMPLETE and high.is_completed())
	assert(not escrow.has_reservation(high_id))
	assert(coordinator.reconcile() == 1)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS P: High completes and commits cost; Normal resumes afterward")

	assert(normal.job.cancel())
	assert(not escrow.has_reservation(normal_id))
	assert(buffer_b.get_amount(ingot) == 3)
	assert(port_b.has_ended_site() and not port_b.can_accept_item(ingot))
	assert(registry.claim_count() == 2)
	assert(coordinator.reconcile() == 0)
	print("PASS Q: Normal cancellation refunds its own buffer; claim stays locked")

	assert(source_a.get_amount(ingot) == 0 and source_b.get_amount(ingot) == 0)
	assert(buffer_a.get_amount(ingot) == 0 and buffer_b.get_amount(ingot) == 3)
	assert(shared.get_amount(ingot) == 9 and escrow.held_count() == 0)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionReadinessCoordinator") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSiteStagingRegistry") == null)
	main.free()
	sandbox.free()
	print("PASS R: All ingots accounted for; playable scenes remain untouched")

	print("ALL 18 E3D5C4R SITE-OWNED READINESS TESTS PASSED")
	print("TEST ONLY: Prototype-rated power and synthetic worker slot, not a live drone or game save.")
