extends CanvasLayer


# =============================================================================
# HUD REFERENCES
# =============================================================================

@onready var build_title: Label = (
	$BuildPanel/PanelMargin/BuildInfo/BuildTitle
)

@onready var building_1_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building1Label
)

@onready var building_2_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building2Label
)

@onready var controls_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/ControlsLabel
)

@onready var cancel_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/CancelLabel
)

# =============================================================================
# HUD COLORS
# =============================================================================
# Selected building is highlighted yellow.
# Unselected buildings remain white.

@export var selected_color: Color = Color(1.0, 0.8, 0.2)
@export var normal_color: Color = Color.WHITE
@export var demolition_color: Color = Color(1.0, 0.25, 0.25)


# =============================================================================
# BUILDING SELECTION DISPLAY
# =============================================================================
# Updates the HUD so the currently selected building slot:
#   - turns gold
#   - receives a ">" selection marker

func set_selected_building(index: int) -> void:
	building_1_label.modulate = normal_color
	building_2_label.modulate = normal_color

	building_1_label.text = "  [1] Small Building"
	building_2_label.text = "  [2] Large Building"

	if index == 0:
		building_1_label.modulate = selected_color
		building_1_label.text = "> [1] Small Building"
	elif index == 1:
		building_2_label.modulate = selected_color
		building_2_label.text = "> [2] Large Building"

# =============================================================================
# DEMOLITION MODE DISPLAY
# =============================================================================
# Changes the HUD text and title color so demolition mode is clearly
# different from normal building placement.

func set_demolition_mode(active: bool) -> void:
	if active:
		build_title.text = "DEMOLITION MODE"
		build_title.modulate = demolition_color

		controls_label.text = "LMB - Demolish"
		cancel_label.text = "Delete - Return to Build"
	else:
		build_title.text = "BUILD MODE"
		build_title.modulate = normal_color

		controls_label.text = "R - Rotate"
		cancel_label.text = "RMB - Cancel"
