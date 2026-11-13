extends Node3D

# =============================================================================
# E3D5C4Q — PHASE 1: QUARANTINED DISK WRITER (SEPARATE PROCESS TEST)
# =============================================================================
# Execute ONCE with F6. Then stop the debugger, fully EXIT the Godot
# editor, reopen the same project and F6 the separate Phase 2 reader scene.
#
# Synthetic internally valid material descriptions only. No actual world
# save, live inventory transfer, site restoration, claim release or authority.
# Uses the existing TWO immutable E3d5c4o test-only disk slots. It does NOT
# delete or overwrite any pre-existing slot or pending .part file.


func _ready() -> void:
	call_deferred("_run_checks")


func _sample(site_id: String, drained: bool) -> Dictionary:
	var blocked: Array[String] = []
	var staged: Array[Dictionary] = []
	var moving: Array[Dictionary] = []
	var escrow: Array[Dictionary] = []
	if not drained:
		blocked = [
			"belt_cargo_outstanding",
			"staging_stock_outstanding",
			"escrow_outstanding"
		]
		staged.append({"item_id": "test_ingot", "quantity": 3})
		moving.append({"item_id": "test_ingot", "quantity": 1})
		escrow.append({"item_id": "test_ingot", "quantity": 3})
	var recovery: Dictionary = {
		"schema_version": 1,
		"owner_label": site_id,
		"site_ended": true,
		"buffered_units": 0 if drained else 3,
		"belt_cargo_units": 0 if drained else 1,
		"escrow_outstanding": not drained,
		"belt_connected": false,
		"claim_locked": true,
		"drained_observed": drained,
		"safe_to_release": false,
		"blockers": blocked
	}
	return {
		"schema_version": 1,
		"site_id": site_id,
		"recovery": recovery,
		"staging_items": staged,
		"belt_items": moving,
		"escrow_items": escrow,
		"claim_locked": true,
		"safe_to_release": false
	}


func _run_checks() -> void:
	var writer := BlueprintConstructionCheckpointFileQuarantine.new()
	add_child(writer)
	var codec := BlueprintConstructionRecoveryCheckpoint.new()
	add_child(codec)
	assert(not writer.enable_isolated_disk_test)
	assert(not codec.enable_isolated_checkpoint)
	assert(writer.read_for_inspection()["status"] == "none")
	print("PASS A: Phase 1 defaults OFF and cannot recover gameplay")

	# Never delete test files automatically. A previous incomplete run
	# should be inspected rather than silently overwritten.
	for generation: int in [1, 2]:
		var slot: String = (
			BlueprintConstructionCheckpointFileQuarantine.slot_path(generation)
		)
		var pending: String = (
			BlueprintConstructionCheckpointFileQuarantine.temp_path(generation)
		)
		assert(not FileAccess.file_exists(slot))
		assert(not FileAccess.file_exists(pending))
	print("PASS B: Test-only slots and pending files are initially absent")

	var id: String = "site_00000000000040008000000000000000"
	assert(BlueprintConstructionSiteIdentityLedger.is_valid_id(id))
	var first: Dictionary = _sample(id, false)
	var second: Dictionary = _sample(id, true)
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(first))
	assert(BlueprintConstructionRecoveryCheckpoint.validate_record(second))
	assert(int(first["staging_items"][0]["quantity"]) == 3)
	assert(int(first["belt_items"][0]["quantity"]) == 1)
	assert(int(first["escrow_items"][0]["quantity"]) == 3)
	assert((second["staging_items"] as Array).is_empty())
	assert(bool(second["recovery"]["drained_observed"]))
	print("PASS C: Both same-owner synthetic material records validate")

	assert(not writer.write_once(1, codec, first))
	writer.enable_isolated_disk_test = true
	assert(not writer.write_once(1, codec, first))
	codec.enable_isolated_checkpoint = true
	assert(not writer.write_once(0, codec, first))
	assert(not writer.write_once(3, codec, first))
	print("PASS D: Writer needs both opt-ins and refuses invalid generations")

	assert(writer.write_once(1, codec, first))
	assert(not writer.write_once(1, codec, first))
	assert(FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.slot_path(1)
	))
	assert(not FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.temp_path(1)
	))
	assert(int(writer.read_slot(1)["belt_items"][0]["quantity"]) == 1)
	print("PASS E: Generation 1 publishes once with 3 escrowed, 3 staged, 1 cargo")

	assert(writer.write_once(2, codec, second))
	assert(not writer.write_once(2, codec, second))
	assert(FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.slot_path(2)
	))
	assert(not FileAccess.file_exists(
		BlueprintConstructionCheckpointFileQuarantine.temp_path(2)
	))
	assert((writer.read_slot(2)["escrow_items"] as Array).is_empty())
	print("PASS F: Same-site generation 2 publishes without overwriting generation 1")

	var chosen: Dictionary = writer.read_for_inspection()
	assert(chosen["status"] == "newer_valid_for_inspection")
	assert(int(chosen["generation"]) == 2)
	assert(chosen["record"]["site_id"] == id)
	assert(bool(chosen["record"]["recovery"]["drained_observed"]))
	assert(not bool(chosen["safe_to_release"]))
	assert(not bool(chosen["can_restore"]))
	assert(not bool(chosen["record"]["safe_to_release"]))
	print("PASS G: Both generations readable only as non-authoritative observations")

	# Leave slots intact for Phase 2. This is intentionally NOT cleanup.
	for generation: int in [1, 2]:
		assert(FileAccess.file_exists(
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
	assert(main.get_node_or_null(
		"BlueprintConstructionCheckpointFileQuarantine"
	) == null)
	assert(sandbox.get_node_or_null(
		"BlueprintConstructionCheckpointFileQuarantine"
	) == null)
	main.free()
	sandbox.free()
	print("PASS H: Two diagnostic files remain on disk; playable scenes opt out")

	print("ALL 8 E3D5C4Q PHASE 1 CHECKPOINT WRITER TESTS PASSED")
	print("NEXT: Stop debugger; completely EXIT Godot; reopen the SAME project.")
	print("THEN F6: res://tests/blueprint_checkpoint_restart_reader_e3d5c4q_test.tscn")
	print("NOT A SAVE: No game world, material escrow, or release authority was stored.")
