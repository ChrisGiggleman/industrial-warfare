extends HBoxContainer
class_name BlueprintConstructionAuthorizationButtons

# =============================================================================
# SANDBOX-ONLY BLUEPRINT AUTHORIZATION REQUESTS
# =============================================================================
# Signal-only UI. The sandbox adapter and WorldInteraction own eligibility
# and authorization. Buttons never edit ConstructionJobs or readiness flags.

signal selected_requested
signal all_requested

const BUTTON_SIZE := Vector2(156.0, 32.0)
const BUTTON_SPACING: int = 6

var _selected_count: int = 0
var _all_count: int = 0
var _selected_button: Button = null
var _all_button: Button = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_constant_override("separation", BUTTON_SPACING)

	_selected_button = Button.new()
	_selected_button.name = "AuthorizeSelectedButton"
	_selected_button.custom_minimum_size = BUTTON_SIZE
	_selected_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_selected_button.tooltip_text = "Authorize Q+drag-selected planned blueprints (E)"
	_selected_button.pressed.connect(request_selected)
	add_child(_selected_button)

	_all_button = Button.new()
	_all_button.name = "AuthorizeAllButton"
	_all_button.custom_minimum_size = BUTTON_SIZE
	_all_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_all_button.tooltip_text = (
		"Authorize every planned blueprint (Ctrl+E); click again to confirm"
	)
	_all_button.pressed.connect(request_all)
	add_child(_all_button)

	set_available_counts(0, 0)


func set_available_counts(selected_count: int, all_count: int) -> void:
	_selected_count = maxi(0, selected_count)
	_all_count = maxi(0, all_count)
	if is_instance_valid(_selected_button):
		_selected_button.disabled = _selected_count == 0
		_selected_button.text = "Authorize Selected (%d)" % _selected_count
	if is_instance_valid(_all_button):
		_all_button.disabled = _all_count == 0
		_all_button.text = "Authorize All (%d)" % _all_count


func set_all_confirmation_pending(pending: bool) -> void:
	if is_instance_valid(_all_button):
		_all_button.text = (
			"Confirm All (%d)" % _all_count
			if pending and _all_count > 0
			else "Authorize All (%d)" % _all_count
		)


func get_selected_button() -> Button:
	return _selected_button


func get_all_button() -> Button:
	return _all_button


func request_selected() -> void:
	if _selected_count > 0:
		selected_requested.emit()


func request_all() -> void:
	if _all_count > 0:
		all_requested.emit()
