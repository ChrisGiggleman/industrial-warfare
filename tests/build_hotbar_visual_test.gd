extends Node

# =============================================================================
# VISUAL BUILD HOTBAR — UI AND ASSIGNMENT REGRESSION
# =============================================================================
# Run this scene directly in Godot. Gameplay and save data are not modified.


func _ready() -> void:
	var packed := load("res://scenes/core/main.tscn") as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)

	var controller = world.get_node("WorldInteraction")
	var hud = world.get_node_or_null("BuildHUD")
	assert(hud != null, "BuildHUD failed to load; inspect build_hud.tscn resource declarations and Godot parser errors.")
	if hud == null:
		push_error("Visual hotbar test cannot continue: BuildHUD is missing.")
		return
	var visual = hud.get_node_or_null("VisualHotbar")
	assert(visual != null, "VisualHotbar is missing from the BuildHUD scene.")
	if visual == null:
		push_error("Visual hotbar test cannot continue: VisualHotbar is missing.")
		return
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	var hotbar: BuildHotbarConfiguration = controller.build_hotbar
	# WorldInteraction initializes the HUD through a deferred sibling sync.
	await get_tree().process_frame

	var panels: Array = visual.get("slot_panels")
	var icons: Array = visual.get("slot_icons")
	var names: Array = visual.get("slot_names")
	var keys: Array = visual.get("slot_keys")
	assert(panels.size() == 9 and icons.size() == 9)
	assert(names.size() == 9 and keys.size() == 9)
	for i: int in range(9):
		assert(keys[i].text == str(i + 1))
		assert(icons[i].texture != null)
	assert(names[0].text == "Extractor")
	assert(names[8].text == "Turret")
	print("PASS A: Nine horizontal tiles have keys, icons and default names")

	assert(not visual.visible)
	controller._toggle_placement_mode()
	assert(visual.visible)
	assert(panels[0].get_theme_stylebox("panel").border_color == hud.selected_color)
	print("PASS B: Visual bar follows Build Mode and highlights active tile")

	var original_icon: Texture2D = icons[0].texture
	assert(controller.assign_hotbar_slot(0, &"prototype_defensive_turret"))
	assert(hotbar.get_id(8) == &"test_extractor")
	assert(names[0].text == "Turret" and names[8].text == "Extractor")
	assert(icons[0].texture != original_icon)
	assert(icons[0].texture == icons[8].texture or icons[8].texture == original_icon)
	print("PASS C: Catalog-equivalent swap refreshes names and icon identities")

	assert(controller.clear_hotbar_slot(0))
	assert(names[0].text == "Empty")
	assert(icons[0].texture != null)
	assert(hotbar.get_definition(0) == null)
	print("PASS D: Empty slots retain a visible placeholder")

	assert(controller.set_hotbar_unlocked(&"test_extractor", false))
	assert(hotbar.get_id(8) == &"")
	assert(names[8].text == "Empty")
	assert(not controller.assign_hotbar_slot(8, &"test_extractor"))
	print("PASS E: Locking unequips a building and refreshes its visual slot")

	assert(controller.set_hotbar_unlocked(&"test_extractor", true))
	hotbar.reset_to_default()
	controller._on_hotbar_assignment_changed()
	assert(names[0].text == "Extractor")
	assert(names[8].text == "Turret")
	assert(icons[0].texture == original_icon)
	print("PASS F: Restore Defaults redraws all original visual assignments")

	controller._toggle_placement_mode()
	assert(not visual.visible)
	world.queue_free()
	print("ALL 6 VISUAL BUILD HOTBAR REGRESSION CHECKS PASSED")
