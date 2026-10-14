extends Node3D


# =============================================================================
# SELECTABLE OBJECT SETTINGS
# =============================================================================
# The MeshInstance3D that receives the visual selection highlight.
# Assign this in the Inspector for each selectable object.

@export var selection_mesh: MeshInstance3D
@export var selected_color: Color = Color(1.0, 0.8, 0.2)
@export var demolition_color: Color = Color(1.0, 0.2, 0.2)

# =============================================================================
# RUNTIME STATE
# =============================================================================
# Stores the original material so it can be restored when deselected.

var original_material: Material
var highlight_material: StandardMaterial3D
var demolition_material: StandardMaterial3D

# =============================================================================
# INITIALIZATION
# =============================================================================
# Verifies that a selection mesh was assigned and prepares the
# temporary highlight material.

func _ready() -> void:
	if selection_mesh == null:
		push_warning("Selectable object has no selection mesh assigned.")
		return

	original_material = selection_mesh.material_override

	highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = selected_color
	demolition_material = StandardMaterial3D.new()
	demolition_material.albedo_color = demolition_color


# =============================================================================
# SELECTION VISUAL STATE
# =============================================================================
# Called by WorldInteraction when this object becomes selected
# or deselected.

func set_selected(is_selected: bool) -> void:
	if selection_mesh == null:
		return

	if is_selected:
		selection_mesh.material_override = highlight_material
	else:
		selection_mesh.material_override = original_material

# =============================================================================
# DEMOLITION HOVER STATE
# =============================================================================
# Provides red visual feedback when this object is targeted by the
# demolition tool.

func set_demolition_hover(is_hovered: bool) -> void:
	if selection_mesh == null:
		return

	if is_hovered:
		selection_mesh.material_override = demolition_material
	else:
		selection_mesh.material_override = original_material