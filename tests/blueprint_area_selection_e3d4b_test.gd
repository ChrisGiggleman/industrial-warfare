extends Node3D

# =============================================================================
# E3D4B — ADD/SUBTRACT SELECTION AND PARTIAL FOOTPRINT OVERLAP
# =============================================================================
# Input-level Q, normal/Shift/Alt drag, E and Ctrl+E regression. Uses actual
# planned storage and conveyor sites, but never bypasses job timing or gates.

func _key(controller: Node, keycode: Key, ctrl: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	event.ctrl_pressed = ctrl
	controller._unhandled_input(event)


func _drag(
	controller: Node, rectangle: Rect2,
	shift: bool = false, alt: bool = false
) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = rectangle.position
	down.shift_pressed = shift
	down.alt_pressed = alt
	controller._unhandled_input(down)
	var move := InputEventMouseMotion.new()
	move.position = rectangle.end
	controller._unhandled_input(move)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = rectangle.end
	controller._unhandled_input(up)


func _around(camera: Camera3D, site: ConstructionSite) -> Rect2:
	var projected: Vector2 = camera.unproject_position(
		site.global_position + Vector3.UP * 0.35
	)
	return Rect2(projected - Vector2(9, 9), Vector2(18, 18))


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
	assert(not controller._toggle_blueprint_area_selection())
	print("PASS A: Area selection still requires Build and Blueprint Mode")

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
	var rotated: ConstructionSite = controller._create_blueprint_site(
		storage, Transform3D(
			Basis(Vector3.UP, PI * 0.5), Vector3(1, 0, -5)
		)
	) as ConstructionSite
	assert(first != null and second != null and third != null)
	assert(rotated != null)
	for site: ConstructionSite in [first, second, third, rotated]:
		site.set_process(false)
	assert(first.job.state == ConstructionJob.State.PLANNED)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Mixed buildings and rotated Storage can coexist as plans")

	var diamond: Array[Vector2] = [
		Vector2(50, 0), Vector2(100, 50),
		Vector2(50, 100), Vector2(0, 50)
	]
	assert(BlueprintAreaSelectionQuery.footprint_intersects_rectangle(
		diamond, Rect2(Vector2(45, 0), Vector2(10, 10))
	))
	assert(not BlueprintAreaSelectionQuery.footprint_intersects_rectangle(
		diamond, Rect2(Vector2(2, 2), Vector2(8, 8))
	))
	print("PASS C: Polygon/rectangle overlap rejects empty corners of its bounding box")

	var corners: Array[Vector2] = (
		BlueprintAreaSelectionQuery.projected_footprint(camera, rotated)
	)
	assert(corners.size() == 4)
	var small := Rect2(corners[0] - Vector2(3, 3), Vector2(6, 6))
	var center: Vector2 = camera.unproject_position(
		rotated.global_position + Vector3.UP * 0.35
	)
	assert(not small.has_point(center))
	var partial: Array[ConstructionSite] = (
		BlueprintAreaSelectionQuery.find_planned(camera, small, world)
	)
	assert(partial.has(rotated))
	print("PASS D: Small edge-only drag finds rotated Storage without containing center")

	_key(controller, KEY_Q)
	assert(bool(controller.get("_blueprint_area_selection_mode")))
	var overlay := controller.get_node(
		"BlueprintAreaSelectionOverlay"
	) as BlueprintAreaSelectionOverlay
	assert(overlay != null)
	var first_rect := _around(camera, first)
	_drag(controller, first_rect)
	assert(first.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).size() == 1)
	print("PASS E: Normal drag replaces selection with one planned building")

	var second_rect := _around(camera, second)
	_drag(controller, second_rect, true)
	assert(overlay.get("_drag_operation") == 1)
	assert(first.is_in_group("blueprint_area_selected"))
	assert(second.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).size() == 2)
	_drag(controller, second_rect, true)
	assert((controller.get("_area_selected_sites") as Array).size() == 2)
	print("PASS F: Shift+drag adds separate conveyors and never duplicates selection")

	var third_rect := _around(camera, third)
	_drag(controller, third_rect, true)
	assert(third.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).size() == 3)
	_drag(controller, second_rect, false, true)
	assert(overlay.get("_drag_operation") == 2)
	assert(not second.is_in_group("blueprint_area_selected"))
	assert(first.is_in_group("blueprint_area_selected"))
	assert(third.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).size() == 2)
	_drag(controller, second_rect, false, true)
	assert((controller.get("_area_selected_sites") as Array).size() == 2)
	print("PASS G: Alt+drag removes only matching plans and does not remove twice")

	_drag(controller, first_rect, true, true)
	assert(not first.is_in_group("blueprint_area_selected"))
	assert(third.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).size() == 1)
	print("PASS H: Alt overrides Shift when both modifiers are pressed")

	_drag(controller, first_rect)
	assert(first.is_in_group("blueprint_area_selected"))
	assert(not third.is_in_group("blueprint_area_selected"))
	assert((controller.get("_area_selected_sites") as Array).size() == 1)
	_drag(controller, third_rect, true)
	assert((controller.get("_area_selected_sites") as Array).size() == 2)
	print("PASS I: Plain drag resets previous selection; Shift can build a new group")

	var summary: Node = world.get_node("BlueprintConstructionSummary")
	summary._refresh()
	var label: Label = summary.get_node(
		"BlueprintSummaryPanel/SummaryMargin/BlueprintSummaryLabel"
	) as Label
	assert(label.text.contains("Selected: 2"))
	_key(controller, KEY_E)
	assert(first.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(third.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(second.job.state == ConstructionJob.State.PLANNED)
	assert(rotated.job.state == ConstructionJob.State.PLANNED)
	assert((controller.get("_area_selected_sites") as Array).is_empty())
	assert(first.job.get_progress() == 0.0)
	assert(third.job.get_progress() == 0.0)
	print("PASS J: E authorizes only composite selection with unchanged timers")

	_drag(controller, small)
	assert((controller.get("_area_selected_sites") as Array).has(rotated))
	_key(controller, KEY_ESCAPE)
	assert((controller.get("_area_selected_sites") as Array).is_empty())
	assert(rotated.job.state == ConstructionJob.State.PLANNED)
	_key(controller, KEY_Q)
	assert(not bool(controller.get("_blueprint_area_selection_mode")))
	print("PASS K: Esc and Q clear the new selection without changing jobs")

	_key(controller, KEY_Q)
	_key(controller, KEY_E, true)
	assert(second.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(rotated.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(second.job.get_progress() == 0.0)
	print("PASS L: Existing Ctrl+E still authorizes all remaining plans")

	var defaults: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(not bool(defaults.get("enable_blueprint_area_selection")))
	defaults.free()
	print("PASS M: Main remains opted out; no production input behavior changed")

	print("ALL 13 E3D4B ADVANCED BLUEPRINT SELECTION TESTS PASSED")
