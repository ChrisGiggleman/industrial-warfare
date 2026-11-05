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

@onready var building_5_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building5Label
)

@onready var building_6_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building6Label
)

@onready var building_7_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building7Label
)

@onready var building_8_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building8Label
)

@onready var building_9_label: Label = (
	$BuildPanel/PanelMargin/BuildInfo/Building9Label
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
# BUILD HOTBAR — ASSIGNED BUILDINGS AND SELECTED SLOT
# =============================================================================

# Display data comes from stable building IDs, not array positions.
# The initial nine prototype mappings preserve the familiar HUD labels.
# A future Build Catalog will use set_hotbar_configuration() whenever
# the player edits assignments or unlocks new structures.

var hotbar_configuration: BuildHotbarConfiguration = null
var selected_hotbar_slot: int = 0


func _slot_labels() -> Array[Label]:
	var labels: Array[Label] = [
		building_1_label, building_2_label, building_3_label,
		building_4_label, building_5_label, building_6_label,
		building_7_label, building_8_label, building_9_label
	]
	return labels


func set_hotbar_configuration(configuration: BuildHotbarConfiguration) -> void:
	hotbar_configuration = configuration
	_refresh_hotbar_labels()


func set_selected_building(index: int) -> void:
	# index now means the hotbar slot (zero-based), NOT the selected
	# definition's position in WorldInteraction.buildable_definitions.
	selected_hotbar_slot = index
	_refresh_hotbar_labels()


func _player_facing_name(definition: BuildingDefinition) -> String:
	if not is_instance_valid(definition):
		return "Empty"
	if definition.building_id == &"test_building_large":
		return "Large Building"
	var label_name: String = definition.display_name
	if label_name.begins_with("Prototype "):
		label_name = label_name.trim_prefix("Prototype ")
	return label_name


func _refresh_hotbar_labels() -> void:
	if not is_node_ready():
		return

	var labels: Array[Label] = _slot_labels()
	for slot_index: int in range(labels.size()):
		var label_node: Label = labels[slot_index]
		if not is_instance_valid(label_node):
			continue

		var slot_name: String = "Empty"
		if hotbar_configuration != null:
			slot_name = _player_facing_name(
				hotbar_configuration.get_definition(slot_index)
			)
		else:
			# Legacy fallback for a HUD instance without a controller.
			var names: Array[String] = [
				"Test Extractor", "Large Building", "Test Storage",
				"Test Smelter", "Conveyor Belt", "Conveyor Merger",
				"Conveyor Splitter", "Ammunition Press",
				"Defensive Turret"
			]
			slot_name = names[slot_index]

		var selected: bool = (
			slot_index == selected_hotbar_slot
			and slot_name != "Empty"
		)
		label_node.modulate = selected_color if selected else normal_color
		label_node.text = (
			"> " if selected else "  "
		) + "[" + str(slot_index + 1) + "] " + slot_name


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
