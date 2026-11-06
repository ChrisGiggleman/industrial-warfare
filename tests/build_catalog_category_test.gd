extends Node

# =============================================================================
# BUILD CATALOG — CATEGORY GROUPING REGRESSION
# =============================================================================

func _ready() -> void:
	var packed := load("res://scenes/core/main.tscn") as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller = world.get_node("WorldInteraction")
	var hud = world.get_node("BuildHUD")
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	await get_tree().process_frame

	hud.call("_toggle_build_catalog")
	assert(hud.call("is_catalog_open"))
	var rows: VBoxContainer = hud.get("catalog_rows")
	assert(rows.get_child_count() == 9)
	var selector := rows.get_child(0).get_child(1) as OptionButton
	assert(selector != null)
	var known_categories: Array[String] = ["Defense", "Logistics", "Production", "Storage"]
	var found_categories: Array[String] = []
	var turret_index: int = -1
	for index: int in range(selector.item_count):
		var label: String = selector.get_item_text(index)
		if selector.get_item_metadata(index) == "prototype_defensive_turret":
			turret_index = index
		if known_categories.has(label):
			assert(selector.is_item_disabled(index))
			found_categories.append(label)
	assert(found_categories.size() >= 3)
	assert(turret_index >= 0)
	print("PASS A: Catalog groups unlocked definitions under disabled category headings")

	hud.call("_on_catalog_slot_selected", turret_index, 0, selector)
	assert(controller.build_hotbar.get_id(0) == &"prototype_defensive_turret")
	assert(controller.build_hotbar.get_id(8) == &"test_extractor")
	assert((hud.get_node("VisualHotbar") as Node).get("slot_names")[0].text == "Turret")
	print("PASS B: Selecting grouped Turret still swaps slots and redraws the hotbar")

	hud.call("_reset_catalog_slots")
	assert(controller.build_hotbar.get_id(0) == &"test_extractor")
	assert(controller.build_hotbar.get_id(8) == &"prototype_defensive_turret")
	print("PASS C: Restore Defaults survives category grouping")

	hud.call("_close_build_catalog")
	assert(not hud.call("is_catalog_open"))
	world.queue_free()
	print("ALL 3 BUILD CATALOG CATEGORY REGRESSION CHECKS PASSED")
