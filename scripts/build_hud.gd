extends CanvasLayer


# =============================================================================
# HUD REFERENCES
# =============================================================================
# References to the labels controlled by this HUD.
#
# These paths depend on the node names in build_hud.tscn, so names such as
# BuildTitle and CancelLabel must match the scene tree exactly.

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
# HUD STYLE SETTINGS
# =============================================================================
# Colors that can be adjusted from the Godot Inspector.
#
# selected_color:
#   Highlights the currently selected building slot.
#
# normal_color:
#   Default HUD text color.
#
# demolition_color:
#   Makes Demolition Mode visually distinct from normal Build Mode.

@export var selected_color: Color = Color(1.0, 0.8, 0.2)
@export var normal_color: Color = Color.WHITE
@export var demolition_color: Color = Color(1.0, 0.25, 0.25)


# =============================================================================
# BUILDING SELECTION DISPLAY
# =============================================================================
# Updates the building-slot labels.
#
# The selected building:
#   - turns gold
#   - receives a ">" marker
#
# Array indexes:
#   0 = Small Building
#   1 = Large Building

func set_selected_building(index: int) -> void:
	# Reset both building slots to their normal appearance.
	building_1_label.modulate = normal_color
	building_2_label.modulate = normal_color

	building_1_label.text = "  [1] Small Building"
	building_2_label.text = "  [2] Large Building"

	# Apply selection feedback to the active building slot.
	if index == 0:
		building_1_label.modulate = selected_color
		building_1_label.text = "> [1] Small Building"

	elif index == 1:
		building_2_label.modulate = selected_color
		building_2_label.text = "> [2] Large Building"


# =============================================================================
# DEMOLITION MODE DISPLAY
# =============================================================================
# Switches the HUD between normal Build Mode and Demolition Mode.
#
# Build Mode:
#   - normal title color
#   - rotation controls displayed
#
# Demolition Mode:
#   - red title
#   - demolition-specific controls displayed

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
