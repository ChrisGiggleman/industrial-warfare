extends Node3D

# =============================================================================
# E3D5C4I — SITE-ALIGNED INDEPENDENT MATERIAL RECEIVER (ISOLATED F6)
# =============================================================================
# Real ConstructionSite planned InputPort geometry + existing connected belt
# transport, owned staging and atomic escrow. Source inventory is test seeded:
# this is an attachment/lifecycle test, NOT a new mining-provenance test.
# Missing power/workers always keep the site QUEUED and progress at 0%.


func _ready() -> void:
	call_deferred("_run_checks")


func _make_site(
	definition: BuildingDefinition, label: String, world_pos: Vector3
) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.position = world_pos
	site.set_process(false)
	return site


func _deliver(
	timer: ConveyorTransportTimer,
	transport: ConveyorTransportComponent,
	ingot: ItemDefinition
) -> void:
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(timer.advance_transport(1.0))
	assert(transport.get_held_item() == null)


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ingot != null and ore != null)
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	add_child(registry)
	var receiver := Node3D.new()
	receiver.name = "IndependentConstructionReceiver"
	add_child(receiver)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInputPort"
	port.show_port_label = false
	receiver.add_child(port)
	assert(not port.enable_isolated_input)
	assert(not registry.enable_isolated_site_registry)
	assert(not port.matches_attached_site())
	print("PASS A: Site-aligned receiver and ownership registry default OFF")

	var site := _make_site(
		definition, "RealPlannedStorage", Vector3(4, 0, 0)
	)
	var planned := site.get_planned_port_named(&"InputPort")
	assert(planned != null and planned.is_inside_tree())
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(not planned is ItemPortComponent)
	assert(site.get_planned_port_names(true).has(&"InputPort"))
	print("PASS B: Real Storage blueprint provides geometry-only PlannedInputPort")

	var supplier := Node3D.new()
	supplier.name = "IsolatedSupplyBuilding"
	add_child(supplier)
	var supply := InventoryComponent.new()
	supply.name = "TestSourceInventory"
	supply.max_capacity = 16
	supplier.add_child(supply)
	assert(supply.add_item(ore, 1) == 1)
	assert(supply.add_item(ingot, 7) == 7)
	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.show_port_label = false
	output.inventory = supply
	supplier.add_child(output)

	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(supply, definition, 3))
	var buffer := staging.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)
	port.enable_isolated_input = true
	registry.enable_isolated_site_registry = true
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(not port.attach_to_authorized_site(site, staging, registry))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(registry.claim_count() == 0)
	print("PASS C: High-priority PLANNED blueprint cannot acquire an input port")

	assert(site.job.authorize())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_wait_reasons().size() == 3)
	assert(site.job.get_progress() == 0.0)
	assert(port.attach_to_authorized_site(site, staging, registry))
	assert(port.matches_attached_site())
	print("PASS D: Explicit authorization is required to attach a receiver")

	assert(registry.claim_count() == 1)
	assert(registry.inventory_for_site(site) == buffer)
	assert(port.get_bound_staging() == staging)
	assert(port.inventory == buffer)
	assert(port.global_transform.is_equal_approx(planned.global_transform))
	print("PASS E: Receiver matches the exact site marker and claimed buffer")

	assert(port.get_parent() == receiver)
	assert(not site.is_ancestor_of(port))
	assert(site.get_node_or_null("ConstructionInputPort") == null)
	assert(not planned is ItemPortComponent)
	assert(port.can_accept_item(ingot))
	assert(not port.can_accept_item(ore))
	print("PASS F: Site retains non-operational ghost; receiver inventory is separate")

	var second := _make_site(
		definition, "CompetingStorage", Vector3(-5, 0, 0)
	)
	assert(second.job.authorize())
	var rival_root := Node3D.new()
	add_child(rival_root)
	var rival := BlueprintConstructionAnchoredStagingPort.new()
	rival.name = "CompetingInputPort"
	rival.enable_isolated_input = true
	rival_root.add_child(rival)
	assert(not rival.attach_to_authorized_site(second, staging, registry))
	assert(not rival.can_accept_item(ingot))
	assert(registry.inventory_for_site(second) == null)
	assert(registry.inventory_for_site(site) == buffer)
	assert(registry.claim_count() == 1)
	print("PASS G: Second authorized site cannot steal existing staging/port claim")

	var belt_packed := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene
	assert(belt_packed != null)
	var belt := belt_packed.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	assert(timer != null and transport != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var snap := ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	assert(belt.output_building_port == port)
	assert(port.connected_conveyor == belt)

	var input_marker := belt.get_node("InputEndpoint") as Marker3D
	assert(input_marker != null)
	supplier.global_transform = Transform3D(
		input_marker.global_transform.basis * Basis(Vector3.UP, PI),
		input_marker.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		output, input_marker, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(output))
	assert(belt.input_building_port == output)
	assert(output.connected_conveyor == belt)
	print("PASS H: Existing belt snaps to site-aligned input with reciprocal output")

	timer._process(0.01)
	assert(transport.get_held_item() == ore)
	assert(not timer.advance_transport(1.0))
	assert(timer.transport_status == "Blocked")
	assert(buffer.get_total_amount() == 0)
	assert(supply.get_amount(ore) == 0)
	print("PASS I: Construction receiver rejects wrong cargo despite physical link")

	var quarantine := InventoryComponent.new()
	quarantine.name = "RejectedOreRecovery"
	add_child(quarantine)
	assert(transport.cargo_inventory.transfer_to(quarantine, ore, 1) == 1)
	assert(quarantine.get_amount(ore) == 1)
	assert(transport.get_held_item() == null)
	print("PASS J: Rejected ore is recovered without entering bill-filtered staging")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(0.4))
	assert(buffer.get_total_amount() == 0)
	assert(timer.advance_transport(0.61))
	assert(buffer.get_amount(ingot) == 1)
	assert(supply.get_amount(ingot) == 6)
	print("PASS K: First valid ingot completes physical travel to site's own buffer")

	_deliver(timer, transport, ingot)
	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 3)
	assert(supply.get_amount(ingot) == 4)
	assert(not port.can_accept_item(ingot))
	assert(timer.successful_transfers == 3)
	print("PASS L: Three timed deliveries satisfy bill without extra capacity")

	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var reservation_id := registry.reserve_for_site(site, escrow)
	assert(reservation_id > 0)
	assert(int(escrow.held_materials(reservation_id).get(ingot, 0)) == 3)
	assert(buffer.get_amount(ingot) == 0)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"power"))
	assert(site.job.get_wait_reasons().has(&"workers"))
	assert(escrow.reservation_for(second) == 0)
	print("PASS M: Site-specific escrow debits three ingots without starting work")

	var location: Vector3 = site.global_position
	site.global_position += Vector3(1, 0, 0)
	assert(not port.matches_attached_site())
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(not timer.advance_transport(1.0))
	assert(buffer.get_total_amount() == 0)
	site.global_position = location
	assert(port.matches_attached_site())
	assert(timer.advance_transport(0.01))
	assert(buffer.get_amount(ingot) == 1)
	print("PASS N: Moving the blueprint prevents stale-port delivery until realignment")

	_deliver(timer, transport, ingot)
	_deliver(timer, transport, ingot)
	assert(buffer.get_amount(ingot) == 3)
	assert(supply.get_amount(ingot) == 1)
	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(supply.get_amount(ingot) == 0)
	assert(not timer.advance_transport(1.0))
	assert(timer.transport_status == "Blocked")
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	assert(site.job.cancel())
	assert(not port.enable_isolated_input)
	assert(not port.matches_attached_site())
	assert(not timer.advance_transport(0.01))
	assert(escrow.has_reservation(reservation_id))
	assert(escrow.needs_recovery(reservation_id))
	assert(buffer.get_amount(ingot) == 3)
	print("PASS O: Cancelled site shuts physical intake; full buffer retains escrow")

	assert(not escrow.recover_to(reservation_id))
	assert(escrow.recover_to(reservation_id, supply))
	assert(not escrow.has_reservation(reservation_id))
	assert(supply.get_amount(ingot) == 3)
	assert(
		supply.get_amount(ingot) + buffer.get_amount(ingot)
		+ transport.cargo_inventory.get_amount(ingot) == 7
	)
	assert(quarantine.get_amount(ore) == 1)
	assert(registry.claim_count() == 1)
	assert(not registry.claim_site(second, staging, port))
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionAnchoredStagingPort") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionAnchoredStagingPort") == null)
	main.free()
	sandbox.free()
	print("PASS P: Recovery conserves all cargo; cancelled receiver stays locked, scenes opt out")

	print("ALL 16 E3D5C4I ANCHORED CONSTRUCTION RECEIVER TESTS PASSED")
	print("TEST ONLY: Separate site-aligned receiver, no production power, workers or save/load.")
