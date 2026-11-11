extends VBoxContainer
class_name BlueprintConstructionPriorityButtons

# =============================================================================
# E3D5C3E1B — COMPACT VERTICAL PRIORITY REQUEST BUTTONS (L / N / H)
# =============================================================================
# Presentation and request signals only. WorldInteraction remains responsible
# for determining which PLANNED blueprints can be reprioritized. Button clicks
# cannot authorize, change readiness, schedule workers or advance job timers.

signal priority_requested(priority: int)

const BUTTON_SIZE := Vector2(48.0, 30.0)
const BUTTON_SPACING := 2

var _enabled_for_selection: bool = false
var _buttons: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_constant_override("separation", BUTTON_SPACING)
	# Match the requested top-to-bottom order beside the build hotbar.
	_add_button("L", "Low priority (L)", ConstructionJob.Priority.LOW)
	_add_button("N", "Normal priority (N)", ConstructionJob.Priority.NORMAL)
	_add_button("H", "High priority (H)", ConstructionJob.Priority.HIGH)
	set_selection_available(false)


func _add_button(title: String, hint: String, priority: int) -> void:
	var button := Button.new()
	button.name = ConstructionJob.priority_name(priority) + "PriorityButton"
	button.text = title
	button.tooltip_text = hint
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.custom_minimum_size = BUTTON_SIZE
	button.pressed.connect(request_priority.bind(priority))
	add_child(button)
	_buttons[priority] = button


func set_selection_available(available: bool) -> void:
	_enabled_for_selection = available
	for priority: Variant in _buttons.keys():
		var button: Button = _buttons[priority] as Button
		if is_instance_valid(button):
			button.disabled = not available


func is_selection_available() -> bool:
	return _enabled_for_selection


func get_priority_button(priority: int) -> Button:
	if not _buttons.has(priority):
		return null
	return _buttons[priority] as Button


func request_priority(priority: int) -> void:
	if not _enabled_for_selection:
		return
	if priority not in [
		ConstructionJob.Priority.HIGH,
		ConstructionJob.Priority.NORMAL,
		ConstructionJob.Priority.LOW
	]:
		return
	priority_requested.emit(priority)
