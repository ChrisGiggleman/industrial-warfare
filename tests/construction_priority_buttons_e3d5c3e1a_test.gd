extends Control

# =============================================================================
# E3D5C3E1A — PRIORITY BUTTONS: SIGNAL-ONLY / FAIL-CLOSED F6 TEST
# =============================================================================
# A standalone visual fixture. Clicking buttons prints requested priority,
# but does not call WorldInteraction or mutate any ConstructionJob.
# Integration with Q-selected blueprints is a separate future checkpoint.

var _requests: Array[int] = []


func _on_priority_requested(priority: int) -> void:
	_requests.append(priority)
	print("MANUAL PRIORITY REQUEST: ", ConstructionJob.priority_name(priority))


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var heading := Label.new()
	heading.text = "Construction Priority Controls - isolated UI test"
	heading.position = Vector2(24, 18)
	add_child(heading)

	var guide := Label.new()
	guide.text = "Buttons emit requests only; no blueprint is changed."
	guide.position = Vector2(24, 48)
	add_child(guide)

	var controls := BlueprintConstructionPriorityButtons.new()
	controls.name = "PriorityControls"
	controls.position = Vector2(24, 94)
	controls.priority_requested.connect(_on_priority_requested)
	add_child(controls)

	assert(not controls.is_selection_available())
	print("PASS A: Isolated priority controls start disabled without selection")

	assert(controls.get_child_count() == 3)
	assert(controls.get_priority_button(ConstructionJob.Priority.HIGH) != null)
	assert(controls.get_priority_button(ConstructionJob.Priority.NORMAL) != null)
	assert(controls.get_priority_button(ConstructionJob.Priority.LOW) != null)
	print("PASS B: Three controls are created for High, Normal and Low")

	assert(controls.get_priority_button(ConstructionJob.Priority.HIGH).text == "High")
	assert(controls.get_priority_button(ConstructionJob.Priority.NORMAL).text == "Normal")
	assert(controls.get_priority_button(ConstructionJob.Priority.LOW).text == "Low")
	print("PASS C: Buttons have visible, correctly ordered priority labels")

	for button: Node in controls.get_children():
		assert(button is Button)
		assert((button as Button).disabled)
		assert((button as Button).mouse_filter == Control.MOUSE_FILTER_STOP)
	print("PASS D: Buttons are initially disabled and consume GUI clicks")

	controls.get_priority_button(ConstructionJob.Priority.HIGH).pressed.emit()
	assert(_requests.is_empty())
	controls.request_priority(ConstructionJob.Priority.LOW)
	assert(_requests.is_empty())
	print("PASS E: Disabled buttons cannot emit requests, even by signal injection")

	controls.set_selection_available(true)
	assert(controls.is_selection_available())
	for button: Node in controls.get_children():
		assert(not (button as Button).disabled)
	print("PASS F: Explicit selection availability enables all three buttons")

	controls.get_priority_button(ConstructionJob.Priority.HIGH).pressed.emit()
	assert(_requests == [ConstructionJob.Priority.HIGH])
	print("PASS G: High button emits exactly one HIGH request")

	controls.get_priority_button(ConstructionJob.Priority.NORMAL).pressed.emit()
	assert(_requests == [
		ConstructionJob.Priority.HIGH,
		ConstructionJob.Priority.NORMAL
	])
	print("PASS H: Normal button emits exactly one NORMAL request")

	controls.get_priority_button(ConstructionJob.Priority.LOW).pressed.emit()
	assert(_requests == [
		ConstructionJob.Priority.HIGH,
		ConstructionJob.Priority.NORMAL,
		ConstructionJob.Priority.LOW
	])
	print("PASS I: Low button emits exactly one LOW request")

	controls.request_priority(-1)
	controls.request_priority(99)
	assert(_requests.size() == 3)
	assert(controls.get_priority_button(99) == null)
	print("PASS J: Invalid priorities cannot be requested")

	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.set_process(false)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	assert(site.job.get_progress() == 0.0)
	assert(not site.is_in_group("blueprint_area_selected"))
	print("PASS K: Button request signals do not mutate jobs or area selection")

	controls.set_selection_available(false)
	controls.request_priority(ConstructionJob.Priority.HIGH)
	assert(_requests.size() == 3)
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.job.get_progress() == 0.0)
	print("PASS L: Disabling buttons fails closed without changing construction")

	await get_tree().process_frame
	controls.set_selection_available(true)
	assert(controls.visible)
	assert(controls.get_rect().size.x >= 282.0)
	print("ALL 12 E3D5C3E1A ISOLATED PRIORITY BUTTON TESTS PASSED")
	print("MANUAL: Click High, Normal, Low in the F6 window; each prints one request.")
	print("MANUAL: These buttons are NOT connected to sandbox construction yet.")
