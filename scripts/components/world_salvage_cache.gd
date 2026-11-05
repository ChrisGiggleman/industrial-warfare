extends Node3D
class_name WorldSalvageCache

# =============================================================================
# WORLD SALVAGE — RECOVERED MATERIALS
# =============================================================================

# World-owned wreckage is selectable and can be inspected. An EMPTY
# cache can be cleared manually; stocked salvage remains protected until
# the game has a validated player collection/storage workflow.
#
# Never add wreckage to player_built: it is not a zombie factory target.
# Never silently delete recovered items just to remove the placeholder.

@onready var inventory: InventoryComponent = $InventoryComponent
@onready var status_label: Label3D = $SalvageLabel
@onready var selection_mesh: MeshInstance3D = $WreckagePlaceholder

var is_selected: bool = false
var is_demolition_hovered: bool = false

var _original_material: Material = null
var _selection_material: StandardMaterial3D = null
var _clearable_material: StandardMaterial3D = null
var _protected_material: StandardMaterial3D = null


# =============================================================================
# WRECKAGE VISUALS — SELECTION AND SAFE CLEANUP HOVER
# =============================================================================

func _ready() -> void:
	_original_material = selection_mesh.material_override

	_selection_material = StandardMaterial3D.new()
	_selection_material.albedo_color = Color(1.0, 0.8, 0.2)

	_clearable_material = StandardMaterial3D.new()
	_clearable_material.albedo_color = Color(1.0, 0.2, 0.2)

	_protected_material = StandardMaterial3D.new()
	_protected_material.albedo_color = Color(1.0, 0.55, 0.15)


func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_visual_state()


func set_demolition_hover(hovered: bool) -> void:
	is_demolition_hovered = hovered
	_update_visual_state()


func _update_visual_state() -> void:
	if not is_instance_valid(selection_mesh):
		return

	if is_demolition_hovered:
		selection_mesh.material_override = (
			_clearable_material if can_clear_safely() else _protected_material
		)
	elif is_selected:
		selection_mesh.material_override = _selection_material
	else:
		selection_mesh.material_override = _original_material


# =============================================================================
# WRECKAGE CLEANUP SAFETY
# =============================================================================

# Do NOT use only get_total_amount() == 0: an invalid/nonstandard
# inventory entry must still block deletion rather than be discarded.

func can_clear_safely() -> bool:
	return (
		is_instance_valid(inventory)
		and inventory.items.is_empty()
		and not is_queued_for_deletion()
	)


# =============================================================================
# UPDATE PLACEHOLDER SALVAGE LABEL
# =============================================================================

func refresh_display() -> void:
	if not is_instance_valid(inventory) or not is_instance_valid(status_label):
		return

	var total: int = inventory.get_total_amount()
	if total == 0:
		status_label.text = "WRECKAGE"
	else:
		status_label.text = "SALVAGE: " + str(total)

	if is_demolition_hovered:
		_update_visual_state()
