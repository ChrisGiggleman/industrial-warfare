extends MeshInstance3D


var original_scale: Vector3


func _ready() -> void:
	original_scale = scale


func set_selected(is_selected: bool) -> void:
	if is_selected:
		scale = original_scale * 1.1
	else:
		scale = original_scale
