extends Node3D

# =============================================================================
# E3D5C4Q — PHASE 2: QUARANTINED DISK READER (AFTER GODOT RESTART)
# =============================================================================
# Run ONLY after Phase 1 finished, the Godot debugger stopped, the entire
# Godot EDITOR closed and the same project reopened. This test has no writer,
# no owner issuer and no world restorer. It only inspects old test JSON files.
# Cleans up the TWO exact fixed test files after all checks pass.


func _ready() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var reader := BlueprintConstructionCheckpointFileQuarantine.new()
	add_child(reader)
	assert(not reader.enable_isolated_disk_test)
	assert(reader.read_slot(1).is_empty())
	assert(reader.read_for_inspection()["status"] == "none")
	assert(not bool(reader.read_for_inspection()["can_restore"]))
	print("PASS A: Newly created inspection reader defaults OFF after restart")

	# No writer exists in this scene. These file paths must survive a
	# COMPLETE editor/process exit from Phase 1.
	var first_path: String = (
		BlueprintConstructionCheckpointFileQuarantine.slot_path(1)
	)
	var second_path: String = (
		BlueprintConstructionCheckpointFileQuarantine.slot_path(2)
	)
	assert(FileAccess.file_exists(first_path))
	assert(FileAccess.file_exists(second_path))
	assert(not FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.temp_path(1)
	))
	assert(not FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.temp_path(2)
	))
	print("PASS B: Both immutable test files survive an editor/process restart")

	var original_first: String = FileAccess.get_file_as_string(first_path)
	var original_second: String = FileAccess.get_file_as_string(second_path)
	assert(not original_first.is_empty())
	assert(not original_second.is_empty())
	var first_digest: String = original_first.sha256_text()
	var second_digest: String = original_second.sha256_text()
	reader.enable_isolated_disk_test = true
	var earlier: Dictionary = reader.read_slot(1)
	var later: Dictionary = reader.read_slot(2)
	assert(not earlier.is_empty() and not later.is_empty())
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(earlier))
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(later))
	print("PASS C: Fresh process independently parses both checksummed generations")

	var expected_id: String = "site_00000000000040008000000000000000"
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(expected_id))
	assert(earlier["site_id"] == expected_id)
	assert(earlier["recovery"]["owner_label"] == expected_id)
	assert(int(earlier["staging_items"][0]["quantity"]) == 3)
	assert(int(earlier["belt_items"][0]["quantity"]) == 1)
	assert(int(earlier["escrow_items"][0]["quantity"]) == 3)
	assert(bool(earlier["recovery"]["escrow_outstanding"]))
	assert(not bool(earlier["safe_to_release"]))
	print("PASS D: Generation 1 retains 3 escrow, 3 staged and 1 belt ingot")

	assert(later["site_id"] == expected_id)
	assert(later["recovery"]["owner_label"] == expected_id)
	assert((later["staging_items"] as Array).is_empty())
	assert((later["belt_items"] as Array).is_empty())
	assert((later["escrow_items"] as Array).is_empty())
	assert(bool(later["recovery"]["drained_observed"]))
	assert(not bool(later["recovery"]["escrow_outstanding"]))
	assert(not bool(later["safe_to_release"]))
	print("PASS E: Generation 2 remains a drained descriptive record only")

	var inspection: Dictionary = reader.read_for_inspection()
	assert(inspection["status"] == "newer_valid_for_inspection")
	assert(int(inspection["generation"]) == 2)
	assert(inspection["record"]["site_id"] == expected_id)
	assert(bool(inspection["record"]["recovery"]["drained_observed"]))
	assert(not bool(inspection["safe_to_release"]))
	assert(not bool(inspection["can_restore"]))
	assert(not bool(inspection["record"]["safe_to_release"]))
	print("PASS F: Cold-process lineage chooses matching newer inspection without authority")

	assert(FileAccess.get_file_as_string(first_path).sha256_text() == first_digest)
	assert(FileAccess.get_file_as_string(second_path).sha256_text() == second_digest)
	var changed_locally: Dictionary = inspection.duplicate(true)
	var local_record: Dictionary = changed_locally["record"]
	local_record["safe_to_release"] = true
	changed_locally["record"] = local_record
	assert(not BlueprintConstructionRecoveryCheckpoint.validate_record(
		changed_locally["record"]
	))
	var untouched: Dictionary = reader.read_for_inspection()
	assert(not bool(untouched["record"]["safe_to_release"]))
	assert(untouched["status"] == "newer_valid_for_inspection")
	print("PASS G: Inspection cannot mutate files or promote locally edited data")

	reader.enable_isolated_disk_test = false
	assert(reader.read_slot(1).is_empty())
	assert(reader.read_for_inspection()["status"] == "none")
	reader.enable_isolated_disk_test = true
	assert(reader.read_for_inspection()["status"] == "newer_valid_for_inspection")
	assert(FileAccess.get_file_as_string(first_path).sha256_text() == first_digest)
	assert(FileAccess.get_file_as_string(second_path).sha256_text() == second_digest)
	print("PASS H: Disabling/re-enabling reader has no write or restore effect")

	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null(
		"BlueprintConstructionCheckpointFileQuarantine"
	) == null)
	assert(sandbox.get_node_or_null(
		"BlueprintConstructionCheckpointFileQuarantine"
	) == null)
	main.free()
	sandbox.free()
	assert(not bool(reader.read_for_inspection()["can_restore"]))
	print("PASS I: Playable scenes still opt out and have no checkpoint restorer")

	# Remove only the two namespaced E3d5c4o test files, and only after
	# all inspection assertions have passed.
	assert(DirAccess.remove_absolute(
		ProjectSettings.globalize_path(first_path)
	) == OK)
	assert(DirAccess.remove_absolute(
		ProjectSettings.globalize_path(second_path)
	) == OK)
	assert(not FileAccess.file_exists(first_path))
	assert(not FileAccess.file_exists(second_path))
	assert(reader.read_for_inspection()["status"] == "none")
	assert(not bool(reader.read_for_inspection()["can_restore"]))
	print("PASS J: Both exact test files cleaned only after successful cold inspection")

	print("ALL 10 E3D5C4Q PHASE 2 RESTART INSPECTION TESTS PASSED")
	print("TEST ONLY: Disk continuity is NOT crash safety, save/load or claim release.")
