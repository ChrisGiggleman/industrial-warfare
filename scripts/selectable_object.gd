extends MeshInstance3D


var original_material: Material
var highlight_material: StandardMaterial3D


func _ready() -> void:
	original_material = material_override

	highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = Color(1.0, 0.8, 0.2)


func set_selected(is_selected: bool) -> void:
	if is_selected:
		material_override = highlight_material
	else:
		material_override = original_material
