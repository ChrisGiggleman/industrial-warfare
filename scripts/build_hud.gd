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

@onready var building_3_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building3Label
)

@onready var building_4_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building4Label
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

# Updates the building selection labels whenever the player
# changes the currently selected building.
#
# Selected building:
# - Highlighted in gold.
# - Receives the ">" selection marker.
#
# Building indexes match the WorldInteraction buildable_definitions array.
#
# Index 0 = Test Extractor (key 1)
# Index 1 = Large Building (key 2)
# Index 2 = Test Storage (key 3)

func set_selected_building(index: int) -> void:

	# =============================================================================
	# RESET BUILDING LABELS
	# =============================================================================

	# Restore all three labels to their normal colors.
	building_1_label.modulate = normal_color
	building_2_label.modulate = normal_color
	building_3_label.modulate = normal_color
	building_4_label.modulate = normal_color

	# Remove selection markers before applying the active selection.
	building_1_label.text = "  [1] Test Extractor"
	building_2_label.text = "  [2] Large Building"
	building_3_label.text = "  [3] Test Storage"
	building_4_label.text = "  [4] Test Smelter"

	# =============================================================================
	# APPLY BUILDING SELECTION
	# =============================================================================

	# Building slot 1.
	if index == 0:
		building_1_label.modulate = selected_color
		building_1_label.text = "> [1] Test Extractor"

	# Building slot 2.
	elif index == 1:
		building_2_label.modulate = selected_color
		building_2_label.text = "> [2] Large Building"

	# Building slot 3: Test Storage.
	elif index == 2:
		building_3_label.modulate = selected_color
		building_3_label.text = "> [3] Test Storage"

	# Building Slot 4: Test Smelter.
	elif index == 3:
		building_4_label.modulate = selected_color
		building_4_label.text = "> [4] Test Smelter"

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
