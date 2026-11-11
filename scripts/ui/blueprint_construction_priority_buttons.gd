extends HBoxContainer
class_name BlueprintConstructionPriorityButtons

# =============================================================================
# E3D5C3E1A — ISOLATED CLICKABLE PRIORITY REQUEST BUTTONS
# =============================================================================
# UI-only: this class emits requests but NEVER changes ConstructionJob,
# selection membership, authorization, queue state, inventory, worker slots,
# power or construction time. A later, separately tested sandbox adapter
# must route requests through WorldInteraction's validated priority command.

signal priority_requested(priority: int)

var _enabled_for_selection: bool = false
var _buttons: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_constant_override("separation", 8)
	_add_button("High", ConstructionJob.Priority.HIGH)
	_add_button("Normal", ConstructionJob.Priority.NORMAL)
	_add_button("Low", ConstructionJob.Priority.LOW)
	set_selection_available(false)


func _add_button(title: String, priority: int) -> void:
	var button := Button.new()
	button.name = title + "PriorityButton"
	button.text = title
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.custom_minimum_size = Vector2(94, 38)
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
