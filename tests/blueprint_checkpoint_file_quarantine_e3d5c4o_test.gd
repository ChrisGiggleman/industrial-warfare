extends Node3D

# =============================================================================
# E3D5C4O — QUARANTINED CHECKPOINT FILE PUBLICATION / FALLBACK F6
# =============================================================================
# Tests file mechanics using internally consistent, SYNTHETIC E3d5c4n
# descriptions. E3d5c4n independently validated live sources in 20/20.
# These descriptions are NEVER a production authority or restorable state.


func _ready() -> void:
	call_deferred("_run_checks")


func _remove_test_file(path: String) -> void:
	if FileAccess.file_exists(path):
		assert(DirAccess.remove_absolute(
			ProjectSettings.globalize_path(path)
		) == OK)


func _sample_record(site_id: String, drained: bool) -> Dictionary:
	var remaining: int = 0 if drained else 3
	var cargo: int = 0 if drained else 1
	var blockers: Array[String] = []
	if not drained:
		blockers = [
			"belt_cargo_outstanding",
			"staging_stock_outstanding",
			"escrow_outstanding"
		]
	var recovery: Dictionary = {
		"schema_version": 1,
		"owner_label": site_id,
		"site_ended": true,
		"buffered_units": remaining,
		"belt_cargo_units": cargo,
		"escrow_outstanding": not drained,
		"belt_connected": false,
		"claim_locked": true,
		"drained_observed": drained,
		"safe_to_release": false,
		"blockers": blockers
	}
	var staged: Array[Dictionary] = []
	var belt: Array[Dictionary] = []
	var held: Array[Dictionary] = []
	if not drained:
		staged.append({"item_id": "test_ingot", "quantity": 3})
		belt.append({"item_id": "test_ingot", "quantity": 1})
		held.append({"item_id": "test_ingot", "quantity": 3})
	return {
		"schema_version": 1,
		"site_id": site_id,
		"recovery": recovery,
		"staging_items": staged,
		"belt_items": belt,
		"escrow_items": held,
		"claim_locked": true,
		"safe_to_release": false
	}


func _run_checks() -> void:
	var journal := BlueprintConstructionCheckpointFileQuarantine.new()
	add_child(journal)
	var checkpoint := BlueprintConstructionRecoveryCheckpoint.new()
	add_child(checkpoint)
	for generation: int in [1, 2]:
		_remove_test_file(
			BlueprintConstructionCheckpointFileQuarantine.slot_path(generation)
		)
		_remove_test_file(
			BlueprintConstructionCheckpointFileQuarantine.temp_path(generation)
		)
	assert(not journal.enable_isolated_disk_test)
	assert(journal.read_slot(1).is_empty())
	assert(journal.read_for_inspection()["status"] == "none")
	assert(not bool(journal.read_for_inspection()["can_restore"]))
	print("PASS A: File quarantine defaults OFF and cannot restore anything")

	var fixture_id := "site_00000000000040008000000000000000"
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(fixture_id))
	var earlier: Dictionary = _sample_record(fixture_id, false)
	var later: Dictionary = _sample_record(fixture_id, true)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(earlier))
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(later))
	assert(int(earlier["staging_items"][0]["quantity"]) == 3)
	assert(int(earlier["belt_items"][0]["quantity"]) == 1)
	assert(int(earlier["escrow_items"][0]["quantity"]) == 3)
	assert((later["escrow_items"] as Array).is_empty())
	print("PASS B: Synthetic seven-item and drained observations pass strict schema")

	assert(not journal.write_once(1, checkpoint, earlier))
	journal.enable_isolated_disk_test = true
	assert(not journal.write_once(1, checkpoint, earlier))
	checkpoint.enable_isolated_checkpoint = true
	var forged: Dictionary = earlier.duplicate(true)
	forged["safe_to_release"] = true
	assert(not journal.write_once(1, checkpoint, forged))
	assert(not journal.write_once(0, checkpoint, earlier))
	assert(not journal.write_once(3, checkpoint, earlier))
	print("PASS C: Both opt-ins and valid schema are required to publish")

	assert(journal.write_once(1, checkpoint, earlier))
	assert(FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.slot_path(1)
	))
	assert(not FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.temp_path(1)
	))
	assert(not journal.write_once(1, checkpoint, later))
	assert(int(journal.read_slot(1)["belt_items"][0]["quantity"]) == 1)
	print("PASS D: First slot publishes once; repeat cannot overwrite existing stock")

	var only_older: Dictionary = journal.read_for_inspection()
	assert(only_older["status"] == "older_only_for_inspection")
	assert(int(only_older["generation"]) == 1)
	assert(int(only_older["record"]["staging_items"][0]["quantity"]) == 3)
	assert(not bool(only_older["safe_to_release"]))
	assert(not bool(only_older["can_restore"]))
	print("PASS E: A single older slot is observable but never authoritative")

	assert(journal.write_once(2, checkpoint, later))
	var newest: Dictionary = journal.read_for_inspection()
	assert(newest["status"] == "newer_valid_for_inspection")
	assert(int(newest["generation"]) == 2)
	assert(bool(newest["record"]["recovery"]["drained_observed"]))
	assert((newest["record"]["staging_items"] as Array).is_empty())
	assert((newest["record"]["belt_items"] as Array).is_empty())
	assert((newest["record"]["escrow_items"] as Array).is_empty())
	print("PASS F: Valid newer generation is preferred without mutating the older")

	assert(not bool(newest["safe_to_release"]))
	assert(not bool(newest["can_restore"]))
	assert(not bool(newest["record"]["safe_to_release"]))
	assert(journal.read_slot(1)["site_id"] == journal.read_slot(2)["site_id"])
	assert(not journal.write_once(2, checkpoint, earlier))
	print("PASS G: Drained newer record still cannot restore or release a receiver")

	var slot_two: String = (
		BlueprintConstructionCheckpointFileQuarantine.slot_path(2)
	)
	var tampered: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(slot_two)
	)
	assert(tampered is Dictionary)
	(tampered as Dictionary)["sha256"] = "bad_checksum"
	var file := FileAccess.open(slot_two, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(tampered))
	file.close()
	assert(journal.read_slot(2).is_empty())
	print("PASS H: Digest mismatch rejects otherwise well-formed newer file")

	var fallback: Dictionary = journal.read_for_inspection()
	assert(fallback["status"] == "stale_fallback_for_inspection")
	assert(int(fallback["generation"]) == 1)
	assert(int(fallback["record"]["belt_items"][0]["quantity"]) == 1)
	assert(not bool(fallback["safe_to_release"]))
	assert(not bool(fallback["can_restore"]))
	assert(not journal.write_once(2, checkpoint, later))
	print("PASS I: Corrupted newer slot exposes explicitly STALE earlier observation")

	var slot_one: String = (
		BlueprintConstructionCheckpointFileQuarantine.slot_path(1)
	)
	var damaged := FileAccess.open(slot_one, FileAccess.WRITE)
	assert(damaged != null)
	damaged.store_string("{truncated")
	damaged.close()
	assert(journal.read_slot(1).is_empty())
	var unavailable: Dictionary = journal.read_for_inspection()
	assert(unavailable["status"] == "none")
	assert(int(unavailable["generation"]) == 0)
	assert((unavailable["record"] as Dictionary).is_empty())
	assert(not bool(unavailable["can_restore"]))
	print("PASS J: Both corrupt slots fail closed; no snapshot is promoted")

	_remove_test_file(slot_one)
	_remove_test_file(slot_two)
	var partial_path: String = (
		BlueprintConstructionCheckpointFileQuarantine.temp_path(1)
	)
	var partial := FileAccess.open(partial_path, FileAccess.WRITE)
	assert(partial != null)
	partial.store_string("{incomplete_pending")
	partial.close()
	assert(not journal.write_once(1, checkpoint, earlier))
	assert(journal.read_slot(1).is_empty())
	assert(journal.read_for_inspection()["status"] == "none")
	_remove_test_file(partial_path)
	print("PASS K: Incomplete .part file cannot be published or read as valid")

	journal.enable_isolated_disk_test = false
	assert(journal.read_for_inspection()["status"] == "none")
	assert(not bool(journal.read_for_inspection()["can_restore"]))
	for generation: int in [1, 2]:
		assert(not FileAccess.file_exists(
			BlueprintConstructionCheckpointFileQuarantine.slot_path(generation)
		))
		assert(not FileAccess.file_exists(
			BlueprintConstructionCheckpointFileQuarantine.temp_path(generation)
		))
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("BlueprintConstructionCheckpointFileQuarantine") == null)
	assert(sandbox.get_node_or_null("BlueprintConstructionCheckpointFileQuarantine") == null)
	main.free()
	sandbox.free()
	print("PASS L: All fixed test files cleaned; Main and sandbox remain opted out")

	print("ALL 12 E3D5C4O CHECKPOINT FILE QUARANTINE TESTS PASSED")
	print("TEST ONLY: Older fallback is STALE; NO world restore, release or crash proof.")
