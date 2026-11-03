extends Node

# =============================================================================
# BUILD HOTBAR MODEL — STABLE ASSIGNMENTS AND UNLOCKS REGRESSION
# =============================================================================

# Standalone Phase 1G foundation. The test never changes current
# Build Mode keys or the conveyor placement implementation.


func _ready() -> void:
	print("\n===== BUILD HOTBAR CONFIGURATION FOUNDATION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(main_scene != null)
	var world := main_scene.instantiate() as Node3D
	assert(world != null)
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	var definitions: Array[BuildingDefinition] = controller.buildable_definitions
	assert(definitions.size() == 9)
	var seen_ids: Dictionary = {}
	for definition: BuildingDefinition in definitions:
		assert(definition != null)
		assert(definition.building_id != &"")
		assert(definition.building_scene != null)
		assert(not seen_ids.has(definition.building_id))
		seen_ids[definition.building_id] = true

	assert(seen_ids.has(&"conveyor_belt"))
	assert(seen_ids.has(&"prototype_defensive_turret"))
	assert(seen_ids.has(&"test_storage"))
	print("PASS A: Nine real prototype building definitions have unique stable IDs")

	var hotbar := BuildHotbarConfiguration.new()
	hotbar.configure(definitions)
	assert(hotbar.get_catalog().size() == 9)
	assert(hotbar.get_unlocked_catalog().size() == 9)
	hotbar.reset_to_default()
	for slot: int in range(9):
		assert(hotbar.get_definition(slot) == definitions[slot])
	assert(hotbar.get_id(4) == &"conveyor_belt")
	assert(hotbar.get_id(8) == &"prototype_defensive_turret")
	print("PASS B: Default hotbar exactly matches current 1–9 prototype controls")

	assert(hotbar.assign(0, &"prototype_defensive_turret"))
	assert(hotbar.get_id(0) == &"prototype_defensive_turret")
	assert(hotbar.get_id(8) == &"test_extractor")
	assert(hotbar.find_slot(&"prototype_defensive_turret") == 0)
	assert(hotbar.find_slot(&"test_extractor") == 8)
	print("PASS C: Assigning Turret to key 1 swaps the prior occupant to key 9")

	assert(hotbar.assign(8, &"test_storage"))
	assert(hotbar.get_id(8) == &"test_storage")
	assert(hotbar.get_id(2) == &"test_extractor")
	assert(hotbar.get_id(0) == &"prototype_defensive_turret")
	assert(hotbar.get_definition(8).display_name == "Test Storage")
	print("PASS D: Storage can be assigned to key 9 while Turret stays on key 1")

	var ids_before: Dictionary = hotbar.to_save_data()
	assert(ids_before.get("version") == 1)
	assert((ids_before["slots"] as Array).size() == 9)
	assert(ids_before["slots"][0] == "prototype_defensive_turret")
	assert(ids_before["slots"][8] == "test_storage")
	assert(ids_before["slots"][4] == "conveyor_belt")
	print("PASS E: Save payload contains stable building IDs rather than array indices")

	assert(hotbar.clear_slot(4))
	assert(hotbar.get_definition(4) == null)
	assert(hotbar.find_slot(&"conveyor_belt") == -1)
	assert(hotbar.assign(3, &"conveyor_belt"))
	assert(hotbar.get_id(3) == &"conveyor_belt")
	assert(hotbar.find_slot(&"test_smelter") == -1)
	assert(hotbar.get_id(4) == &"")
	print("PASS F: Players can clear a slot and equip an unlocked building elsewhere")

	var unchanged: Dictionary = hotbar.to_save_data()
	assert(not hotbar.assign(-1, &"test_storage"))
	assert(not hotbar.assign(9, &"test_storage"))
	assert(not hotbar.assign(2, &"not_an_existing_building"))
	assert(not hotbar.clear_slot(9))
	assert(hotbar.assign(0, &"prototype_defensive_turret"))
	assert(hotbar.to_save_data() == unchanged)
	print("PASS G: Invalid slots/unknown IDs are rejected without altering assignments")

	assert(hotbar.set_unlocked(&"prototype_defensive_turret", false))
	assert(not hotbar.is_unlocked(&"prototype_defensive_turret"))
	assert(hotbar.get_id(0) == &"")
	assert(not hotbar.assign(0, &"prototype_defensive_turret"))
	assert(hotbar.get_unlocked_catalog().size() == 8)
	assert(not hotbar.set_unlocked(&"unknown", true))
	print("PASS H: Locking a building unequips it and prevents reassignment")

	assert(hotbar.set_unlocked(&"prototype_defensive_turret", true))
	assert(hotbar.assign(0, &"prototype_defensive_turret"))
	var save_data: Dictionary = hotbar.to_save_data()
	var json_data: String = JSON.stringify(save_data)
	var decoded: Variant = JSON.parse_string(json_data)
	assert(decoded is Dictionary)
	var loaded := BuildHotbarConfiguration.new()
	loaded.configure(definitions)
	assert(loaded.restore_save_data(decoded as Dictionary))
	assert(loaded.to_save_data() == save_data)
	print("PASS I: JSON-compatible save payload restores the same nine assignments")

	var reordered: Array[BuildingDefinition] = definitions.duplicate()
	reordered.reverse()
	var restored_reordered := BuildHotbarConfiguration.new()
	restored_reordered.configure(reordered)
	assert(restored_reordered.restore_save_data(save_data))
	assert(restored_reordered.get_id(0) == &"prototype_defensive_turret")
	assert(restored_reordered.get_id(8) == &"test_storage")
	assert(restored_reordered.get_id(3) == &"conveyor_belt")
	assert(restored_reordered.get_definition(0) == definitions[8])
	print("PASS J: Saved hotbar remains correct when catalog ordering changes")

	var before_invalid: Dictionary = loaded.to_save_data()
	assert(not loaded.restore_save_data({"version": 99, "slots": []}))
	assert(not loaded.restore_save_data({"version": 1, "slots": []}))
	assert(not loaded.restore_save_data({"version": 1, "slots": "wrong"}))
	assert(not loaded.restore_save_data({"version": 1, "slots": [
		"test_storage", 7, "", "", "", "", "", "", ""
	]}))
	assert(loaded.to_save_data() == before_invalid)
	print("PASS K: Malformed save documents cannot corrupt existing bindings")

	var conflicting: Dictionary = save_data.duplicate(true)
	conflicting["slots"][0] = "test_storage"
	conflicting["slots"][1] = "not_found"
	assert(loaded.restore_save_data(conflicting))
	assert(loaded.get_id(0) == &"test_storage")
	assert(loaded.get_id(1) == &"")
	assert(loaded.get_id(8) == &"")
	var locked_reload := BuildHotbarConfiguration.new()
	locked_reload.configure(definitions)
	assert(locked_reload.set_unlocked(&"test_storage", false))
	assert(locked_reload.restore_save_data(save_data))
	assert(locked_reload.get_id(8) == &"")
	assert(locked_reload.get_unlocked_catalog().size() == 8)
	assert(controller.selected_building_index == 0)
	assert(controller._get_selected_building_definition() == definitions[0])
	print("PASS L: Duplicate, missing and locked saved IDs are sanitized; gameplay unchanged")

	world.queue_free()
	print("================================================")
	print("ALL 12 BUILD HOTBAR CONFIGURATION FOUNDATION TESTS PASSED")
	print("================================================")
