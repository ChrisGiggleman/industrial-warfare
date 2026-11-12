extends Node3D

# =============================================================================
# E3D5C4J — CANCELLED-RECEIVER RECOVERY INSPECTION (ISOLATED)
# =============================================================================
# Test-only read-only inspection of a real construction receiver after job
# cancellation. The fixture moves existing test ingots explicitly through
# staging and belt cargo; it does not reproduce the already proven mining
# factory chain, and never unlocks/deletes a claimed receiver.


func _ready() -> void:
	call_deferred("_run_checks")


func _make_site(definition: BuildingDefinition, label: String) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.position = Vector3(5, 0, 0)
	site.set_process(false)
	return site


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)

	var audit := BlueprintConstructionReceiverRecoveryAudit.new()
	add_child(audit)
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	assert(not audit.enable_isolated_recovery_audit)
	assert(not bool(audit.inspect()["drained_observed"]))
	assert(not bool(audit.inspect()["safe_to_release"]))
	print("PASS A: Recovery audit defaults OFF, never authorizes receiver retirement")

	var site := _make_site(definition, "RecoverableSite")
	var planned := site.get_planned_port_named(&"InputPort")
	assert(planned != null and site.job.state == ConstructionJob.State.PLANNED)
	var source_root := Node3D.new()
	source_root.name = "TestSupplyNode"
	add_child(source_root)
	var source := InventoryComponent.new()
	source.max_capacity = 12
	source_root.add_child(source)
	assert(source.add_item(ingot, 7) == 7)

	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(source, definition, 3))
	var buffer: InventoryComponent = staging.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)
	var receiver_root := Node3D.new()
	receiver_root.name = "SeparateRecoveryReceiver"
	add_child(receiver_root)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "ConstructionInput"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver_root.add_child(port)
	assert(not port.attach_to_authorized_site(site, staging, registry))
	assert(registry.claim_count() == 0)
	assert(not port.has_ended_site())
	print("PASS B: PLANNED site has no receiver rights; separate buffer starts empty")

	assert(site.job.authorize())
	assert(port.attach_to_authorized_site(site, staging, registry))
	assert(registry.has_locked_pair(staging, port))
	assert(registry.inventory_for_site(site) == buffer)
	assert(port.matches_attached_site())
	assert(port.global_transform.is_equal_approx(planned.global_transform))
	print("PASS C: Authorized QUEUED site exclusively owns planned-port receiver")

	var output := ItemPortComponent.new()
	output.name = "OutputPort"
	output.direction = ItemPortComponent.PortDirection.OUTPUT
	output.inventory = source
	output.show_port_label = false
	source_root.add_child(output)
	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene
	assert(belt_scene != null)
	var belt := belt_scene.instantiate() as ConveyorSegment
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
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	var marker := belt.get_node("InputEndpoint") as Marker3D
	source_root.global_transform = Transform3D(
		marker.global_transform.basis * Basis(Vector3.UP, PI),
		marker.global_position
	)
	assert(LogisticsConnectionGeometry.are_endpoints_aligned(
		output, marker, ConveyorSegment.CONNECTION_GAP
	))
	assert(belt.try_connect_building_port(output))
	assert(port.connected_conveyor == belt)
	assert(output.connected_conveyor == belt)
	print("PASS D: Existing conveyor and output ports form a reciprocal physical path")

	audit.enable_isolated_recovery_audit = true
	assert(not audit.configure(site, registry, staging, port, belt, escrow))
	assert(not bool(audit.inspect()["known"]))
	print("PASS E: Audit cannot bind a receiver lacking an actual escrow reservation")

	assert(staging.receive_item(ingot, 3) == 3)
	var reservation_id: int = registry.reserve_for_site(site, escrow)
	assert(reservation_id > 0)
	assert(escrow.has_reservation(reservation_id))
	assert(buffer.get_total_amount() == 0)
	assert(staging.receive_item(ingot, 3) == 3)
	assert(buffer.get_amount(ingot) == 3)
	assert(source.get_amount(ingot) == 1)
	assert(audit.configure(site, registry, staging, port, belt, escrow))
	assert(not audit.configure(site, registry, staging, port, belt, escrow))
	print("PASS F: Known site's escrow ID and physical connection bind only once")

	timer._process(0.01)
	assert(transport.get_held_item() == ingot)
	assert(source.get_amount(ingot) == 0)
	assert(not timer.advance_transport(1.0))
	assert(timer.transport_status == "Blocked")
	var active: Dictionary = audit.inspect()
	assert(bool(active["known"]))
	assert(not bool(active["site_ended"]))
	assert(int(active["buffered"]) == 3)
	assert(int(active["belt_cargo"]) == 1)
	assert(bool(active["escrow_outstanding"]))
	assert(bool(active["belt_connected"]))
	assert(not bool(active["drained_observed"]))
	assert(not bool(active["safe_to_release"]))
	print("PASS G: Active site reports all material/connection blockers; no release")

	audit.enable_isolated_recovery_audit = false
	assert(not bool(audit.inspect()["known"]))
	assert(not bool(audit.inspect()["drained_observed"]))
	audit.enable_isolated_recovery_audit = true
	assert(bool(audit.inspect()["known"]))
	print("PASS H: Audit feature switch fails closed without changing inventories")

	assert(site.job.cancel())
	assert(port.has_ended_site())
	assert(not port.enable_isolated_input)
	assert(not port.can_accept_item(ingot))
	assert(escrow.has_reservation(reservation_id))
	assert(escrow.needs_recovery(reservation_id))
	var cancelled: Dictionary = audit.inspect()
	assert(bool(cancelled["site_ended"]))
	assert(int(cancelled["buffered"]) == 3)
	assert(int(cancelled["belt_cargo"]) == 1)
	assert(bool(cancelled["escrow_outstanding"]))
	assert(bool(cancelled["belt_connected"]))
	assert(not bool(cancelled["drained_observed"]))
	assert(not bool(cancelled["safe_to_release"]))
	print("PASS I: Cancellation stops intake but preserves buffer, belt and held escrow")

	assert(not escrow.recover_to(reservation_id))
	assert(escrow.recover_to(reservation_id, source))
	assert(not escrow.has_reservation(reservation_id))
	assert(source.get_amount(ingot) == 3)
	var after_escrow: Dictionary = audit.inspect()
	assert(not bool(after_escrow["escrow_outstanding"]))
	assert(not bool(after_escrow["drained_observed"]))
	assert(int(after_escrow["buffered"]) == 3)
	assert(int(after_escrow["belt_cargo"]) == 1)
	print("PASS J: Exact escrow recovery alone cannot mark receiver drained")

	assert(belt.disconnect_building_port(port))
	assert(belt.output_building_port == null)
	assert(port.connected_conveyor == null)
	assert(not bool(audit.inspect()["belt_connected"]))
	assert(not bool(audit.inspect()["drained_observed"]))
	assert(transport.cargo_inventory.transfer_to(source, ingot, 1) == 1)
	assert(source.get_amount(ingot) == 4)
	assert(not bool(audit.inspect()["drained_observed"]))
	assert(buffer.transfer_to(source, ingot, 3) == 3)
	assert(source.get_amount(ingot) == 7)
	assert(buffer.get_total_amount() == 0)
	assert(transport.cargo_inventory.get_total_amount() == 0)
	assert(escrow.held_count() == 0)
	var drained: Dictionary = audit.inspect()
	assert(bool(drained["known"]))
	assert(bool(drained["drained_observed"]))
	assert(not bool(drained["safe_to_release"]))
	assert(registry.claim_count() == 1)
	print("PASS K: Disconnected, empty belt/buffer and recovered escrow are observed only")

	await get_tree().process_frame
	var after_free: Dictionary = audit.inspect()
	assert(bool(after_free["known"]))
	assert(bool(after_free["site_ended"]))
	assert(bool(after_free["drained_observed"]))
	assert(not bool(after_free["safe_to_release"]))
	assert(registry.has_locked_pair(staging, port))
	var other := _make_site(definition, "ReplacementCandidate")
	assert(other.job.authorize())
	assert(not registry.claim_site(other, staging, port))
	assert(registry.claim_count() == 1)
	assert(source.get_amount(ingot) == 7)
	assert(other.job.get_progress() == 0.0)
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionReceiverRecoveryAudit") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionReceiverRecoveryAudit") == null)
	main.free()
	sandbox.free()
	print("PASS L: After site deletion, claim still locked; seven ingots conserved")

	print("ALL 12 E3D5C4J RECEIVER RECOVERY AUDIT TESTS PASSED")
	print("TEST ONLY: Observed drained does NOT grant ownership release or persistence.")
