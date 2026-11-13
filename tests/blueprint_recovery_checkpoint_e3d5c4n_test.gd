extends Node3D

# =============================================================================
# E3D5C4N — VERIFIED MATERIAL OWNERSHIP CHECKPOINT (ISOLATED F6)
# =============================================================================
# Uses real ConstructionSite identities, E3d5c4h ownership, anchored intake,
# E3d5c4j live audit, E3d5c4k JSON observation and E3d5c4l tombstones.
# Supplies are fixture-seeded solely to test owner identity, not provenance.
# Does not perform recovery release, import/save, readiness or job advance.


func _ready() -> void:
	call_deferred("_run_checks")


func _plan(
	definition: BuildingDefinition,
	label: String,
	location: Vector3,
	parent_node: Node3D
) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	parent_node.add_child(site)
	site.position = location
	site.set_process(false)
	return site


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(definition != null and ingot != null)

	var ledger := BlueprintConstructionSiteIdentityLedger.new()
	add_child(ledger)
	var binder := BlueprintConstructionRecoveryIdentityBinding.new()
	add_child(binder)
	var checkpoint := BlueprintConstructionRecoveryCheckpoint.new()
	add_child(checkpoint)
	assert(not checkpoint.enable_isolated_checkpoint)
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	add_child(registry)
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var audit := BlueprintConstructionReceiverRecoveryAudit.new()
	audit.enable_isolated_recovery_audit = true
	add_child(audit)
	var observation := BlueprintConstructionRecoveryObservation.new()
	observation.enable_isolated_observation = true
	add_child(observation)
	assert(not binder.enable_isolated_identity_binding)
	assert(binder.observe_verified().is_empty())
	assert(binder.encode_verified().is_empty())
	assert(binder.bound_site_id().is_empty())
	print("PASS A: Identity-to-observation binding defaults OFF and is inert")

	var first := _plan(
		definition, "TwinPlan", Vector3(5, 0, 2), self
	)
	var alternate_parent := Node3D.new()
	alternate_parent.name = "OtherPlanHost"
	add_child(alternate_parent)
	var second := _plan(
		definition, "TwinPlan", Vector3(5, 0, 2), alternate_parent
	)
	assert(first.name == second.name)
	assert(first.global_position.is_equal_approx(second.global_position))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	ledger.enable_isolated_identity = true
	var first_id: String = ledger.issue_id(first)
	var second_id: String = ledger.issue_id(second)
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(first_id))
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(second_id))
	assert(first_id != second_id)
	assert(ledger.identity_count() == 2)
	print("PASS B: Two real same-name/location sites have different issued IDs")

	var source := InventoryComponent.new()
	source.name = "FixtureSupply"
	source.max_capacity = 10
	add_child(source)
	assert(source.add_item(ingot, 7) == 7)
	var staging := BlueprintConstructionMaterialStaging.new()
	staging.enable_isolated_staging = true
	add_child(staging)
	assert(staging.configure(source, definition, 3))
	var buffer := staging.get_staged_inventory()
	assert(buffer != null and buffer.get_total_amount() == 0)
	var receiver_root := Node3D.new()
	receiver_root.name = "IndependentFixtureReceiver"
	add_child(receiver_root)
	var port := BlueprintConstructionAnchoredStagingPort.new()
	port.name = "InputPort"
	port.show_port_label = false
	port.enable_isolated_input = true
	receiver_root.add_child(port)

	binder.enable_isolated_identity_binding = true
	assert(not binder.configure(first, ledger, audit, observation))
	assert(binder.bound_site_id().is_empty())
	assert(ledger.id_for_site(first) == first_id)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: Issued IDs cannot bind unaudited or unauthorized blueprints")

	assert(first.job.authorize())
	assert(second.job.authorize())
	assert(first.job.get_progress() == 0.0)
	assert(port.attach_to_authorized_site(first, staging, registry))
	assert(port.matches_attached_site())
	assert(registry.inventory_for_site(first) == buffer)
	assert(registry.inventory_for_site(second) == null)
	print("PASS D: Only explicitly authorized first site owns this receiver")

	assert(not binder.configure(first, ledger, audit, observation))
	assert(observation.observe().is_empty())
	print("PASS E: Owned receiver without verified escrow/audit cannot bind")

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
	assert(timer != null)
	timer.set_process(false)
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(
		port, belt
	)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(port))
	assert(port.connected_conveyor == belt)
	assert(belt.output_building_port == port)
	print("PASS F: Actual aligned reciprocal belt is linked to first site's port")

	assert(staging.receive_item(ingot, 3) == 3)
	var hold: int = registry.reserve_for_site(first, escrow)
	assert(hold > 0)
	assert(escrow.has_reservation(hold))
	assert(buffer.get_total_amount() == 0)
	assert(source.get_amount(ingot) == 4)
	assert(audit.configure(first, registry, staging, port, belt, escrow))
	assert(audit.matches_queued_site(first))
	assert(not audit.matches_queued_site(second))
	assert(bool(audit.inspect()["known"]))
	print("PASS G: Escrow-backed audit proves the original queued site ownership")

	assert(not binder.configure(second, ledger, audit, observation))
	assert(observation.observe().is_empty())
	assert(binder.bound_site_id().is_empty())
	assert(second.job.get_progress() == 0.0)
	print("PASS H: Unrelated site UUID cannot be attached to first site's audit")

	var foreign := BlueprintConstructionRecoveryObservation.new()
	foreign.enable_isolated_observation = true
	add_child(foreign)
	assert(foreign.configure(audit, "site_untrusted_label"))
	assert(not binder.configure(first, ledger, audit, foreign))
	assert(binder.bound_site_id().is_empty())
	assert(foreign.observe()["owner_label"] == "site_untrusted_label")
	print("PASS I: Previously caller-labelled observation is refused, not trusted")

	assert(binder.configure(first, ledger, audit, observation))
	assert(not binder.configure(first, ledger, audit, observation))
	assert(binder.bound_site_id() == first_id)
	assert(binder.bound_site_id() != second_id)
	assert(registry.claim_count() == 1)
	print("PASS J: One-time binding uses only ledger-issued matching site UUID")

	var active: Dictionary = binder.observe_verified()
	assert(not active.is_empty())
	assert(active["owner_label"] == first_id)
	assert(not bool(active["site_ended"]))
	assert(bool(active["claim_locked"]))
	assert(bool(active["escrow_outstanding"]))
	assert(bool(active["belt_connected"]))
	assert(not bool(active["safe_to_release"]))
	var parsed: Dictionary = (
		BlueprintConstructionRecoveryObservation.decode_checked(
			binder.encode_verified()
		)
	)
	assert(parsed["owner_label"] == first_id)
	assert(not bool(parsed["safe_to_release"]))
	assert(checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	).is_empty())
	checkpoint.enable_isolated_checkpoint = true
	var live_record: Dictionary = checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(live_record))
	assert(live_record["site_id"] == first_id)
	assert((live_record["staging_items"] as Array).is_empty())
	assert((live_record["belt_items"] as Array).is_empty())
	assert(int(live_record["escrow_items"][0]["quantity"]) == 3)
	assert(checkpoint.capture(
		binder, audit, staging, belt, escrow, hold + 1
	).is_empty())
	# A live, bill-matching but different staging buffer is not the audited
	# source, even if its apparent stock eventually matches a real one.
	var impostor_staging := BlueprintConstructionMaterialStaging.new()
	impostor_staging.enable_isolated_staging = true
	add_child(impostor_staging)
	assert(impostor_staging.configure(source, definition, 3))
	assert(checkpoint.capture(
		binder, audit, impostor_staging, belt, escrow, hold
	).is_empty())
	print("PASS K: Live UUID-bound JSON round-trips without any release authority")

	# Force the real cancellation path to hold escrow: a full staging
	# inventory cannot accept the original 3-ingot escrow refund.
	assert(staging.receive_item(ingot, 3) == 3)
	assert(buffer.get_amount(ingot) == 3)
	assert(source.get_amount(ingot) == 1)
	# Test-only direct loading of a physical belt cargo inventory; this
	# tests capture of held cargo, NOT a new production routing claim.
	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	assert(transport != null)
	assert(transport.try_receive_from_inventory(source, ingot))
	assert(source.get_amount(ingot) == 0)
	assert(transport.cargo_inventory.get_amount(ingot) == 1)
	var full_record: Dictionary = checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(full_record))
	assert(int(full_record["staging_items"][0]["quantity"]) == 3)
	assert(int(full_record["belt_items"][0]["quantity"]) == 1)
	assert(int(full_record["escrow_items"][0]["quantity"]) == 3)
	assert(first.job.cancel())
	assert(port.has_ended_site())
	assert(not port.enable_isolated_input)
	assert(bool(ledger.observe_id(first_id)["site_ended"]))
	var cancelled: Dictionary = binder.observe_verified()
	assert(bool(cancelled["site_ended"]))
	assert(cancelled["owner_label"] == first_id)
	assert(bool(cancelled["escrow_outstanding"]))
	assert(int(cancelled["buffered_units"]) == 3)
	assert(int(cancelled["belt_cargo_units"]) == 1)
	var cancelled_snapshot: Dictionary = checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(cancelled_snapshot))
	assert(cancelled_snapshot["site_id"] == first_id)
	assert(int(cancelled_snapshot["staging_items"][0]["quantity"]) == 3)
	assert(int(cancelled_snapshot["belt_items"][0]["quantity"]) == 1)
	assert(int(cancelled_snapshot["escrow_items"][0]["quantity"]) == 3)
	assert(not bool(cancelled["safe_to_release"]))
	print("PASS L: Cancelled-site tombstone and audit match while escrow remains")

	await get_tree().process_frame
	assert(not is_instance_valid(first))
	var after_free: Dictionary = binder.observe_verified()
	assert(bool(after_free["site_ended"]))
	assert(after_free["owner_label"] == first_id)
	assert(bool(after_free["claim_locked"]))
	assert(not bool(after_free["safe_to_release"]))
	assert(registry.has_locked_pair(staging, port))
	var after_free_snapshot: Dictionary = checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	)
	assert(after_free_snapshot["site_id"] == first_id)
	assert(bool(after_free_snapshot["recovery"]["site_ended"]))
	assert(int(after_free_snapshot["belt_items"][0]["quantity"]) == 1)
	print("PASS M: Audit and issued UUID remain linked after original node is freed")

	ledger.enable_isolated_identity = false
	assert(checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	).is_empty())
	assert(binder.observe_verified().is_empty())
	assert(binder.encode_verified().is_empty())
	ledger.enable_isolated_identity = true
	audit.enable_isolated_recovery_audit = false
	assert(binder.observe_verified().is_empty())
	audit.enable_isolated_recovery_audit = true
	observation.enable_isolated_observation = false
	assert(binder.observe_verified().is_empty())
	observation.enable_isolated_observation = true
	binder.enable_isolated_identity_binding = false
	assert(binder.observe_verified().is_empty())
	binder.enable_isolated_identity_binding = true
	assert(binder.observe_verified()["owner_label"] == first_id)
	print("PASS N: Disabling any identity/audit/observation gate fails closed")

	assert(not escrow.recover_to(hold))
	assert(buffer.transfer_to(source, ingot, 3) == 3)
	assert(source.get_amount(ingot) == 3)
	assert(escrow.recover_to(hold, source))
	assert(source.get_amount(ingot) == 6)
	assert(transport.cargo_inventory.transfer_to(source, ingot, 1) == 1)
	assert(source.get_amount(ingot) == 7)
	assert(transport.cargo_inventory.get_total_amount() == 0)
	assert(buffer.get_total_amount() == 0)
	assert(not escrow.has_reservation(hold))
	assert(belt.disconnect_building_port(port))
	var drained: Dictionary = binder.observe_verified()
	assert(not drained.is_empty())
	assert(bool(drained["drained_observed"]))
	assert(not bool(drained["safe_to_release"]))
	var drained_snapshot: Dictionary = checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(drained_snapshot))
	assert(bool(drained_snapshot["recovery"]["drained_observed"]))
	assert((drained_snapshot["staging_items"] as Array).is_empty())
	assert((drained_snapshot["belt_items"] as Array).is_empty())
	assert((drained_snapshot["escrow_items"] as Array).is_empty())
	assert(not bool(drained_snapshot["safe_to_release"]))
	assert(registry.claim_count() == 1)
	assert(not registry.claim_site(second, staging, port))
	assert(ledger.observe_id(first_id)["site_id"] == first_id)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.get_progress() == 0.0)
	print("PASS O: Drained observation keeps UUID tombstone and receiver claim locked")

	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionRecoveryIdentityBinding") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionRecoveryIdentityBinding") == null)
	assert(main.get_node_or_null("BlueprintConstructionSiteIdentityLedger") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSiteIdentityLedger") == null)
	assert(main.get_node_or_null("BlueprintConstructionRecoveryCheckpoint") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionRecoveryCheckpoint") == null)
	main.free()
	sandbox.free()
	assert(source.get_amount(ingot) == 7)
	assert(buffer.get_total_amount() == 0)
	assert(escrow.held_count() == 0)
	assert(not bool(drained["safe_to_release"]))
	print("PASS P: Main/sandbox opt out; resources conserved and no work dispatched")

	print("PASS Q: Real owned staging/belt/escrow quantities match UUID-bound audit")
	print("PASS R: After cancellation/deletion, all seven units remain represented")

	# A deliberately quarantined F6 file round-trip. The component itself
	# cannot write, load/rebuild sites, or grant recovery authority.
	var json_text: String = checkpoint.encode_record(cancelled_snapshot)
	assert(not json_text.is_empty())
	var path: String = "user://industrial_warfare_e3d5c4n_test_only.json"
	var out_file := FileAccess.open(path, FileAccess.WRITE)
	assert(out_file != null)
	out_file.store_string(json_text)
	out_file.flush()
	out_file.close()
	var in_file := FileAccess.open(path, FileAccess.READ)
	assert(in_file != null)
	var read_text: String = in_file.get_as_text()
	in_file.close()
	assert(DirAccess.remove_absolute(
		ProjectSettings.globalize_path(path)
	) == OK)
	var disk_record: Dictionary = (
		BlueprintConstructionRecoveryCheckpoint.decode_checked(read_text)
	)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(disk_record))
	assert(disk_record["site_id"] == first_id)
	assert(int(disk_record["staging_items"][0]["quantity"]) == 3)
	assert(int(disk_record["belt_items"][0]["quantity"]) == 1)
	assert(int(disk_record["escrow_items"][0]["quantity"]) == 3)
	assert(not bool(disk_record["safe_to_release"]))
	assert(not bool(disk_record["recovery"]["safe_to_release"]))
	print("PASS S: Test-only JSON file writes, reads and validates exact item quantities")

	var forged: Dictionary = cancelled_snapshot.duplicate(true)
	forged["safe_to_release"] = true
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["site_id"] = second_id
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["schema_version"] = 2
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["staging_items"][0]["quantity"] = 4
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["belt_items"][0]["quantity"] = -1
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["escrow_items"] = []
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["escrow_items"][0]["quantity"] = 3.5
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["staging_items"].append(
		{"item_id": "test_ingot", "quantity": 1}
	)
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	forged = cancelled_snapshot.duplicate(true)
	forged["unrecognized"] = "grant_release"
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(forged))
	assert(BlueprintConstructionRecoveryCheckpoint.decode_checked(
		"{broken_json"
	).is_empty())
	checkpoint.enable_isolated_checkpoint = false
	assert(checkpoint.capture(
		binder, audit, staging, belt, escrow, hold
	).is_empty())
	assert(checkpoint.encode_record(drained_snapshot).is_empty())
	assert(registry.claim_count() == 1)
	assert(source.get_amount(ingot) == 7)
	print("PASS T: Forged, inconsistent or disabled snapshots cannot grant release")

	print("ALL 20 E3D5C4N MATERIAL OWNERSHIP CHECKPOINT TESTS PASSED")
	print("TEST ONLY: File round-trip is NOT saved gameplay, restore or release.")
