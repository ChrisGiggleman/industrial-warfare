extends Node3D

# =============================================================================
# E3D4A — RECTANGLE SELECTION & SELECTED-ONLY BLUEPRINT AUTHORIZATION
# =============================================================================
# Uses real sandbox blueprints and projected screen positions. Does not
# simulate the keyboard, but invokes the same controller methods as Q/drag/E.

func _ready() -> void:
	var packed: PackedScene = load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world: Node3D = packed.instantiate() as Node3D
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	var camera: Camera3D = world.get_node("CameraRig/Camera3D")
	assert(camera != null)
	assert(controller.enable_blueprint_area_selection)
	assert(not controller._toggle_blueprint_area_selection())
	print("PASS A: Q area selection is disabled outside Blueprint Mode")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	var storage: BuildingDefinition = load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var belt: BuildingDefinition = load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(storage != null and belt != null)
	var first: ConstructionSite = controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(-6, 0, 0))
	) as ConstructionSite
	var second: ConstructionSite = controller._create_straight_conveyor_blueprint(
		belt, Transform3D(Basis.IDENTITY, Vector3(-2, 0, 0))
	) as ConstructionSite
	var third: ConstructionSite = controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(5, 0, 0))
	) as ConstructionSite
	assert(first != null and second != null and third != null)
	for site: ConstructionSite in [first, second, third]:
		site.set_process(false)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(third.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Two building types and a third unselected plan coexist")

	var q_key := InputEventKey.new()
	q_key.physical_keycode = KEY_Q
	q_key.pressed = true
	controller._unhandled_input(q_key)
	assert(bool(controller.get("_blueprint_area_selection_mode")))
	var ghost: Node3D = controller.get("placement_ghost") as Node3D
	assert(ghost != null and not ghost.visible)
	var overlay: BlueprintAreaSelectionOverlay = controller.get_node_or_null(
		"BlueprintAreaSelectionOverlay"
	) as BlueprintAreaSelectionOverlay
	assert(overlay != null)
	assert(overlay.is_inside_tree())
	assert(not overlay.is_dragging())
	print("PASS C: Q hides the placement ghost and enables a non-colliding rectangle")

	var a: Vector2 = camera.unproject_position(
		first.global_position + Vector3.UP * 0.4
	)
	var b: Vector2 = camera.unproject_position(
		second.global_position + Vector3.UP * 0.4
	)
	var c: Vector2 = camera.unproject_position(
		third.global_position + Vector3.UP * 0.4
	)
	var upper := Vector2(minf(a.x, b.x), minf(a.y, b.y))
	var lower := Vector2(maxf(a.x, b.x), maxf(a.y, b.y))
	var box := Rect2(
		upper - Vector2(12, 12),
		lower - upper + Vector2(24, 24)
	)
	assert(not box.has_point(c))
	var matches: Array[ConstructionSite] = (
		BlueprintAreaSelectionQuery.find_planned(camera, box, world)
	)
	assert(matches.size() == 2)
	assert(matches.has(first) and matches.has(second))
	assert(not matches.has(third))
	print("PASS D: Screen drag selects only the two planned centers inside its box")

	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = box.position
	controller._unhandled_input(down)
	assert(overlay.is_dragging())
	var move := InputEventMouseMotion.new()
	move.position = box.end
	controller._unhandled_input(move)
	assert(overlay.get_drag_rect().size.is_equal_approx(box.size))
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = box.end
	controller._unhandled_input(up)
	assert(not overlay.is_dragging())
	var selected: Array = controller.get("_area_selected_sites")
	assert(selected.size() == 2)
	assert(first.is_in_group("blueprint_area_selected"))
	assert(second.is_in_group("blueprint_area_selected"))
	assert(not third.is_in_group("blueprint_area_selected"))
	assert(first.get_node_or_null("AreaSelectionHighlight") != null)
	assert(second.get_node_or_null("AreaSelectionHighlight") != null)
	print("PASS E: Dragging produces persistent green highlights and an exact count")

	var hud: Node = world.get_node("BlueprintConstructionSummary")
	hud._refresh()
	var summary: Label = hud.get_node(
		"BlueprintSummaryPanel/SummaryMargin/BlueprintSummaryLabel"
	) as Label
	assert(summary != null and summary.text.contains("Selected: 2"))
	print("PASS F: Construction summary reports selected blueprints")

	var e_key := InputEventKey.new()
	e_key.physical_keycode = KEY_E
	e_key.pressed = true
	controller._unhandled_input(e_key)
	assert(first.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(second.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(third.job.state == ConstructionJob.State.PLANNED)
	assert(first.job.get_progress() == 0.0)
	assert(second.job.get_progress() == 0.0)
	assert((controller.get("_area_selected_sites") as Array).is_empty())
	assert(not first.is_in_group("blueprint_area_selected"))
	assert(not second.is_in_group("blueprint_area_selected"))
	print("PASS G: E authorizes only selected plans, preserving other blueprints and timers")

	assert(controller._authorize_selected_blueprint_sites() == 0)
	var ctrl_e := InputEventKey.new()
	ctrl_e.physical_keycode = KEY_E
	ctrl_e.ctrl_pressed = true
	ctrl_e.pressed = true
	controller._unhandled_input(ctrl_e)
	assert(third.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(third.job.get_progress() == 0.0)
	print("PASS H: Empty E is safe and Ctrl+E still authorizes all remaining plans")

	var fourth: ConstructionSite = controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(0, 0, -6))
	) as ConstructionSite
	assert(fourth != null)
	fourth.set_process(false)
	var pos: Vector2 = camera.unproject_position(
		fourth.global_position + Vector3.UP * 0.4
	)
	var tiny := Rect2(pos - Vector2(10, 10), Vector2(20, 20))
	assert(controller._select_blueprints_in_screen_rect(tiny) == 1)
	var escape_key := InputEventKey.new()
	escape_key.physical_keycode = KEY_ESCAPE
	escape_key.pressed = true
	controller._unhandled_input(escape_key)
	assert(not fourth.is_in_group("blueprint_area_selected"))
	assert(fourth.job.state == ConstructionJob.State.PLANNED)
	controller._unhandled_input(q_key)
	assert(not bool(controller.get("_blueprint_area_selection_mode")))
	assert(ghost.visible)
	assert(fourth.job.state == ConstructionJob.State.PLANNED)
	print("PASS I: Esc and Q clear highlights without authorizing or cancelling sites")

	var main_default: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(not bool(main_default.get("enable_blueprint_area_selection")))
	main_default.free()
	print("PASS J: Main-scene blueprint area selection remains disabled by default")

	print("ALL 10 E3D4A BLUEPRINT AREA SELECTION TESTS PASSED")
