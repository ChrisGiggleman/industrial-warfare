extends CanvasLayer
class_name BlueprintAreaSelectionOverlay

# =============================================================================
# E3D4 — VISUAL-ONLY DRAG SELECTION RECTANGLE
# =============================================================================
# Does not consume mouse input, select sites, or alter construction jobs.

var _drawing: Control = null
var _begin: Vector2 = Vector2.ZERO
var _finish: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _drag_operation: int = 0


func _ready() -> void:
	layer = 15
	_drawing = Control.new()
	_drawing.name = "SelectionRectangleCanvas"
	_drawing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_drawing)
	_drawing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_drawing.draw.connect(_draw_box)


func start_drag(screen_pos: Vector2, operation: int = 0) -> void:
	_begin = screen_pos
	_finish = screen_pos
	_drag_operation = operation
	_dragging = true
	if is_instance_valid(_drawing):
		_drawing.queue_redraw()


func update_drag(screen_pos: Vector2) -> void:
	if not _dragging:
		return
	_finish = screen_pos
	if is_instance_valid(_drawing):
		_drawing.queue_redraw()


func finish_drag(screen_pos: Vector2) -> Rect2:
	if not _dragging:
		return Rect2()
	update_drag(screen_pos)
	var area := Rect2(_begin, _finish - _begin).abs()
	_dragging = false
	if is_instance_valid(_drawing):
		_drawing.queue_redraw()
	return area


func cancel_drag() -> void:
	_dragging = false
	if is_instance_valid(_drawing):
		_drawing.queue_redraw()


func is_dragging() -> bool:
	return _dragging


func get_drag_rect() -> Rect2:
	return Rect2(_begin, _finish - _begin).abs()


func _draw_box() -> void:
	if not _dragging or not is_instance_valid(_drawing):
		return
	var area: Rect2 = get_drag_rect()
	var fill_color := Color(0.18, 0.84, 0.47, 0.14)
	var line_color := Color(0.25, 1.0, 0.58, 0.95)
	if _drag_operation == 1:
		# Cyan signals additive selection.
		fill_color = Color(0.12, 0.70, 1.0, 0.14)
		line_color = Color(0.24, 0.83, 1.0, 0.95)
	elif _drag_operation == 2:
		# Red signals subtractive selection.
		fill_color = Color(1.0, 0.22, 0.24, 0.14)
		line_color = Color(1.0, 0.35, 0.32, 0.95)
	_drawing.draw_rect(area, fill_color, true)
	_drawing.draw_rect(area, line_color, false, 2.0)
