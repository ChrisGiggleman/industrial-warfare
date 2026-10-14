extends Node3D


# =============================================================================
# SELECTABLE OBJECT SETTINGS
# =============================================================================
# Visual settings for objects that can be selected or targeted by the
# demolition tool.
#
# selection_mesh:
#   MeshInstance3D that receives selection and demolition highlighting.
#   Assign this in the Inspector for each selectable object.
#
# selected_color:
#   Color shown when the object is normally selected.
#
# demolition_color:
#   Color shown when the object is targeted by the demolition tool.

@export var selection_mesh: MeshInstance3D
@export var selected_color: Color = Color(1.0, 0.8, 0.2)
@export var demolition_color: Color = Color(1.0, 0.2, 0.2)


# =============================================================================
# RUNTIME STATE
# =============================================================================
# Stores the object's original material and the temporary materials used for
# interaction feedback.

var original_material: Material
var selection_material: StandardMaterial3D
var demolition_material: StandardMaterial3D

var is_selected: bool = false
var is_demolition_hovered: bool = false


# =============================================================================
# INITIALIZATION
# =============================================================================
# Verifies that a selection mesh was assigned.
#
# The mesh's original material is saved so it can be restored when no
# interaction highlight is active.

func _ready() -> void:
	if selection_mesh == null:
		push_warning(
			"Selectable object has no selection mesh assigned."
		)
		return

	original_material = selection_mesh.material_override

	selection_material = StandardMaterial3D.new()
	selection_material.albedo_color = selected_color

	demolition_material = StandardMaterial3D.new()
	demolition_material.albedo_color = demolition_color


# =============================================================================
# SELECTION VISUAL STATE
# =============================================================================
# Called by WorldInteraction when this logical object becomes selected or
# deselected.

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_visual_state()


# =============================================================================
# DEMOLITION HOVER STATE
# =============================================================================
# Called by WorldInteraction while the demolition tool is active.
#
# A valid demolition target receives red visual feedback while underneath
# the mouse cursor.

func set_demolition_hover(hovered: bool) -> void:
	is_demolition_hovered = hovered
	_update_visual_state()


# =============================================================================
# VISUAL STATE UPDATE
# =============================================================================
# Chooses which material should currently be displayed.
#
# Priority:
#   1. Demolition hover
#   2. Normal selection
#   3. Original material
#
# Keeping the decision in one function prevents interaction states from
# accidentally overwriting one another.

func _update_visual_state() -> void:
	if selection_mesh == null:
		return

	if is_demolition_hovered:
		selection_mesh.material_override = demolition_material

	elif is_selected:
		selection_mesh.material_override = selection_material

	else:
		selection_mesh.material_override = original_material