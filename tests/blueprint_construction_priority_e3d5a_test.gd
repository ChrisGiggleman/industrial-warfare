extends Node3D

# =============================================================================
# E3D5A — BLUEPRINT PRIORITIES AND NON-DISPATCHING WAIT QUEUE
# =============================================================================
# Tests H/N/L group priority, stable queue ordering, missing requirements,
# cancellation, queue reprioritization, and sandbox compatibility.

func _key(controller: Node, keycode: Key, ctrl: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	event.ctrl_pressed = ctrl
	controller._unhandled_input(event)


func _around(camera: Camera3D, site: ConstructionSite) -> Rect2:
	var center: Vector2 = camera.unproject_position(
		site.global_position + Vector3.UP * 0.35
	)
	return Rect2(center - Vector2(7, 7), Vector2(14, 14))


func _ready() -> void:
	var packed: PackedScene = load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller: Node = world.get_node("WorldInteraction")
	controller.set_process(false)
	var camera: Camera3D = world.get_node("CameraRig/Camera3D")
	assert(camera != null)
	assert(controller.enable_blueprint_construction_priorities)
	var priority_queue: BlueprintConstructionPriorityQueue = controller.get_node(
		"BlueprintConstructionPriorityQueue"
	) as BlueprintConstructionPriorityQueue
	assert(priority_queue != null)
	assert(priority_queue.get_waiting_sites().is_empty())
	assert(not controller._set_selected_blueprint_priority(
		ConstructionJob.Priority.HIGH
	))
	print("PASS A: Priority service is sandbox opt-in and selection gated")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	var storage: BuildingDefinition = load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var belt: BuildingDefinition = load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(storage != null and belt != null)
	var high_first := controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(-6, 0, 0))
	) as ConstructionSite
	var low_first := controller._create_straight_conveyor_blueprint(
		belt, Transform3D(Basis.IDENTITY, Vector3(-2, 0, 0))
	) as ConstructionSite
	var normal := controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(5, 0, 0))
	) as ConstructionSite
	var high_second := controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(1, 0, -5))
	) as ConstructionSite
	var immediate := controller._create_blueprint_site(
		storage, Transform3D(Basis.IDENTITY, Vector3(-6, 0, -5))
	) as ConstructionSite
	assert(
		high_first != null and low_first != null and normal != null
		and high_second != null and immediate != null
	)
	for site: ConstructionSite in [
		high_first, low_first, normal, high_second, immediate
	]:
		site.set_process(false)
		assert(site.job.state == ConstructionJob.State.PLANNED)
		assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	print("PASS B: Mixed planned blueprints default to Normal priority")

	_key(controller, KEY_Q)
	assert(bool(controller.get("_blueprint_area_selection_mode")))
	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, high_first)
	) == 1)
	_key(controller, KEY_H)
	assert(high_first.job.priority == ConstructionJob.Priority.HIGH)
	assert(high_first.job.state == ConstructionJob.State.PLANNED)
	assert(high_first.job.get_progress() == 0.0)
	print("PASS C: H sets High without authorizing or advancing a job")

	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, low_first)
	) == 1)
	_key(controller, KEY_L)
	assert(low_first.job.priority == ConstructionJob.Priority.LOW)
	assert(low_first.job.state == ConstructionJob.State.PLANNED)
	print("PASS D: L sets Low inside Q mode without starting L-route planning")

	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, high_second)
	) == 1)
	_key(controller, KEY_H)
	assert(high_second.job.priority == ConstructionJob.Priority.HIGH)
	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, normal)
	) == 1)
	_key(controller, KEY_N)
	assert(normal.job.priority == ConstructionJob.Priority.NORMAL)
	assert(not normal.job.set_priority(-99))
	assert(not normal.job.set_priority(99))
	print("PASS E: N retains Normal and invalid priorities are rejected")

	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, high_first)
	) == 1)
	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, high_second),
		controller.BLUEPRINT_SELECT_ADD
	) == 2)
	_key(controller, KEY_N)
	assert(high_first.job.priority == ConstructionJob.Priority.NORMAL)
	assert(high_second.job.priority == ConstructionJob.Priority.NORMAL)
	_key(controller, KEY_H)
	assert(high_first.job.priority == ConstructionJob.Priority.HIGH)
	assert(high_second.job.priority == ConstructionJob.Priority.HIGH)
	print("PASS F: Priority changes apply to mixed selections without duplicates")

	var hud: Node = world.get_node("BlueprintConstructionSummary")
	hud._refresh()
	var hud_text: Label = hud.get_node(
		"BlueprintSummaryPanel/SummaryMargin/BlueprintSummaryLabel"
	) as Label
	assert(hud_text.text.contains("Selected priority: H 2"))
	assert(hud_text.text.contains("Waiting queue: 0"))
	print("PASS G: HUD reports selected priority mix and empty queue")

	# Retain previous factory test behavior: debugger availability still
	# authorizes immediate construction without changing timers.
	assert(controller._select_blueprints_in_screen_rect(
		_around(camera, immediate)
	) == 1)
	_key(controller, KEY_E)
	assert(immediate.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(immediate.job.get_progress() == 0.0)
	assert(priority_queue.get_waiting_count() == 0)
	print("PASS H: Sandbox debug override still builds immediately and preserves timers")

	# Turn off ONLY the sandbox test override for this isolated check.
	# No power/material/worker provider is fabricated by the queue.
	controller.blueprint_sandbox_debug_requirements = false
	assert(controller._authorize_blueprint_site(low_first))
	assert(controller._authorize_blueprint_site(normal))
	assert(controller._authorize_blueprint_site(high_first))
	assert(controller._authorize_blueprint_site(high_second))
	assert(priority_queue.get_waiting_count() == 4)
	var ordered: Array[ConstructionSite] = priority_queue.get_waiting_sites()
	assert(ordered == [high_first, high_second, normal, low_first])
	assert(priority_queue.peek_next() == high_first)
	for site: ConstructionSite in ordered:
		assert(site.job.state == ConstructionJob.State.QUEUED)
		assert(site.job.get_wait_reasons().size() == 3)
		assert(site.job.get_progress() == 0.0)
	print("PASS I: Queued jobs sort High then Normal then Low, FIFO within priority")

	# High priority never overrides missing power, materials or workers.
	high_first.job.advance(120.0)
	assert(high_first.job.state == ConstructionJob.State.QUEUED)
	assert(high_first.job.get_progress() == 0.0)
	assert(not high_first.job.set_priority(ConstructionJob.Priority.LOW) == false)
	assert(high_first.job.set_priority(ConstructionJob.Priority.HIGH))
	print("PASS J: Queue never bypasses unmet requirements or advances waiting jobs")

	assert(low_first.job.set_priority(ConstructionJob.Priority.HIGH))
	ordered = priority_queue.get_waiting_sites()
	assert(ordered == [low_first, high_first, high_second, normal])
	hud._refresh()
	assert(hud_text.text.contains("Waiting queue: 4"))
	assert(hud_text.text.contains("Next: High"))
	print("PASS K: Reprioritized queued job moves first without losing authorization order")

	assert(low_first.job.set_availability(true, true, true))
	assert(low_first.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(priority_queue.get_waiting_count() == 3)
	assert(priority_queue.peek_next() == high_first)
	assert(low_first.job.get_progress() == 0.0)
	print("PASS L: Only external readiness starts work; started jobs leave the waiting queue")

	assert(controller._cancel_blueprint_site(high_second))
	ordered = priority_queue.get_waiting_sites()
	assert(ordered == [high_first, normal])
	assert(priority_queue.get_waiting_count() == 2)
	print("PASS M: Cancellation removes a waiting job without disturbing other jobs")

	assert(not low_first.job.set_priority(ConstructionJob.Priority.LOW))
	assert(high_first.job.state == ConstructionJob.State.QUEUED)
	assert(normal.job.state == ConstructionJob.State.QUEUED)
	print("PASS N: Active jobs cannot be reprioritized; waiting jobs remain gated")

	var defaults: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(not bool(defaults.get("enable_blueprint_construction_priorities")))
	defaults.free()
	print("PASS O: Main gameplay remains opted out of priority management")

	print("ALL 15 E3D5A BLUEPRINT CONSTRUCTION PRIORITY TESTS PASSED")
