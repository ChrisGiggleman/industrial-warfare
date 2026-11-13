extends Node3D

# =============================================================================
# E3D5C4L — PROCESS-LOCAL SITE IDENTITY / TOMBSTONE F6 CHECKS
# =============================================================================
# Real ConstructionSites, real ConstructionJobs, cryptographic random IDs.
# NO save/load, import, claim release, materials transfer, power or workers.


func _ready() -> void:
	call_deferred("_run_checks")


func _make_site(
	definition: BuildingDefinition, label: String, location: Vector3
) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	site.position = location
	return site


func _run_checks() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(definition != null)

	var ledger := BlueprintConstructionSiteIdentityLedger.new()
	add_child(ledger)
	assert(not ledger.enable_isolated_identity)
	assert(ledger.issue_id(null).is_empty())
	assert(ledger.id_for_site(null).is_empty())
	assert(ledger.observe_id("").is_empty())
	assert(ledger.identity_count() == 0)
	print("PASS A: Identity ledger defaults OFF and grants no site IDs")

	assert(not BlueprintConstructionSiteIdentityLedger.is_valid_id(""))
	assert(not BlueprintConstructionSiteIdentityLedger.is_valid_id("site_fake"))
	assert(not BlueprintConstructionSiteIdentityLedger.is_valid_id(
		"site_00000000000000000000000000000000"
	))
	assert(not BlueprintConstructionSiteIdentityLedger.is_valid_id(
		"site_0000000000004000800000000000000z"
	))
	print("PASS B: Malformed IDs, non-v4 and non-hex UUIDs are rejected")

	var first := _make_site(definition, "StoragePlan", Vector3(2, 0, 4))
	ledger.enable_isolated_identity = true
	assert(ledger.issue_id(first).is_empty())
	assert(ledger.id_for_site(first).is_empty())
	assert(first.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: Detached sites cannot obtain an identity")

	add_child(first)
	var first_id: String = ledger.issue_id(first)
	assert(not first_id.is_empty())
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(first_id))
	assert(first_id.length() == 37)
	assert(first_id.begins_with("site_"))
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.get_progress() == 0.0)
	print("PASS D: Real PLANNED site receives a well-formed session UUID")

	assert(ledger.issue_id(first) == first_id)
	assert(ledger.id_for_site(first) == first_id)
	assert(ledger.identity_count() == 1)
	var record: Dictionary = ledger.observe_id(first_id)
	assert(int(record["schema_version"]) == 1)
	assert(record["site_id"] == first_id)
	assert(not bool(record["site_ended"]))
	assert(bool(record["identity_retained"]))
	assert(not bool(record["safe_to_release"]))
	print("PASS E: Repeated lookup retains same ID and never permits release")

	first.name = "StoragePlanRenamed"
	first.position += Vector3(1, 0, 0)
	assert(ledger.issue_id(first) == first_id)
	assert(ledger.id_for_site(first) == first_id)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	print("PASS F: Renaming or moving a blueprint never changes identity")

	assert(first.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(ledger.issue_id(first) == first_id)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.get_wait_reasons().size() == 3)
	assert(first.job.get_progress() == 0.0)
	print("PASS G: High priority and stable ID never authorize construction")

	var second := _make_site(
		definition, "StoragePlanRenamed", first.position
	)
	add_child(second)
	var second_id: String = ledger.issue_id(second)
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(second_id))
	assert(second_id != first_id)
	assert(ledger.id_for_site(second) == second_id)
	assert(ledger.identity_count() == 2)
	print("PASS H: Distinct sites sharing a name/location never share an ID")

	assert(first.job.authorize())
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(ledger.issue_id(first) == first_id)
	assert(first.job.get_wait_reasons().size() == 3)
	assert(first.job.get_progress() == 0.0)
	assert(not bool(ledger.observe_id(first_id)["safe_to_release"]))
	print("PASS I: Explicit job authorization keeps ID stable and readiness missing")

	assert(first.job.cancel())
	assert(first.job.state == ConstructionJob.State.CANCELLED)
	assert(bool(ledger.observe_id(first_id)["site_ended"]))
	assert(not bool(ledger.observe_id(first_id)["safe_to_release"]))
	assert(ledger.identity_count() == 2)
	print("PASS J: Cancellation immediately tombstones ID without releasing rights")

	await get_tree().process_frame
	assert(not is_instance_valid(first))
	assert(bool(ledger.observe_id(first_id)["site_ended"]))
	assert(ledger.observe_id(first_id)["site_id"] == first_id)
	assert(ledger.identity_count() == 2)
	print("PASS K: Tombstone persists after cancelled ConstructionSite is freed")

	var replacement := _make_site(
		definition, "StoragePlanRenamed", Vector3(3, 0, 4)
	)
	add_child(replacement)
	var replacement_id: String = ledger.issue_id(replacement)
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(replacement_id))
	assert(replacement_id != first_id)
	assert(replacement_id != second_id)
	assert(ledger.observe_id(first_id)["site_id"] == first_id)
	assert(ledger.identity_count() == 3)
	print("PASS L: Replacement site cannot recycle a deleted blueprint's UUID")

	second.queue_free()
	await get_tree().process_frame
	assert(not is_instance_valid(second))
	assert(bool(ledger.observe_id(second_id)["site_ended"]))
	assert(not bool(ledger.observe_id(second_id)["safe_to_release"]))
	assert(ledger.identity_count() == 3)
	print("PASS M: Direct tree exit also retains a permanently locked tombstone")

	ledger.enable_isolated_identity = false
	assert(ledger.issue_id(replacement).is_empty())
	assert(ledger.id_for_site(replacement).is_empty())
	assert(ledger.observe_id(first_id).is_empty())
	assert(ledger.identity_count() == 0)
	ledger.enable_isolated_identity = true
	assert(ledger.id_for_site(replacement) == replacement_id)
	assert(ledger.identity_count() == 3)
	print("PASS N: Disabled feature hides IDs but never erases stored tombstones")

	assert(ledger.observe_id("site_00000000000040008000000000000000").is_empty())
	assert(ledger.observe_id("site_invalid").is_empty())
	var observation: Dictionary = ledger.observe_id(first_id)
	var raw: String = JSON.stringify(observation)
	var parsed: Variant = JSON.parse_string(raw)
	assert(parsed is Dictionary)
	assert(parsed["site_id"] == first_id)
	assert(bool(parsed["site_ended"]))
	assert(not bool(parsed["safe_to_release"]))
	assert(not bool(ledger.observe_id(replacement_id)["site_ended"]))
	print("PASS O: Inert JSON description is no import, restore or release authority")

	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionSiteIdentityLedger") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionSiteIdentityLedger") == null)
	main.free()
	sandbox.free()
	assert(replacement.job.state == ConstructionJob.State.PLANNED)
	assert(replacement.job.get_progress() == 0.0)
	print("PASS P: Both playable scenes opt out; no jobs or resources dispatched")

	print("ALL 16 E3D5C4L SESSION SITE IDENTITY TESTS PASSED")
	print("TEST ONLY: Session UUIDs/tombstones are NOT saved, restored or release rights.")
