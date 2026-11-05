extends CanvasLayer

@onready var visual_hotbar: PanelContainer = $VisualHotbar
@onready var build_panel: PanelContainer = $BuildPanel


func _ready() -> void:
	build_panel.visibility_changed.connect(_sync_visual_visibility)
	_sync_visual_visibility()
	_refresh_hotbar_labels()


func _sync_visual_visibility() -> void:
	visual_hotbar.visible = build_panel.visible


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

	if is_instance_valid(visual_hotbar):
		visual_hotbar.render_slots(
			hotbar_configuration, selected_hotbar_slot, selected_color
		)


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


# =============================================================================
# BUILD CATALOG — PLAYER HOTBAR ASSIGNMENT EDITOR
# =============================================================================

# M opens the editor at any time. Slot changes are delegated to
# WorldInteraction so the existing placement state remains authoritative.
# Assignments persist for this session; save-to-disk is a separate milestone.

var hotbar_controller: Node = null
var catalog_overlay: CenterContainer = null
var catalog_rows: VBoxContainer = null
var catalog_message: Label = null


func set_hotbar_controller(controller: Node) -> void:
	hotbar_controller = controller


func is_catalog_open() -> bool:
	return is_instance_valid(catalog_overlay) and catalog_overlay.visible


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if event.keycode == KEY_M or event.physical_keycode == KEY_M:
		_toggle_build_catalog()
		get_viewport().set_input_as_handled()
	elif is_catalog_open() and event.keycode == KEY_ESCAPE:
		_close_build_catalog()
		get_viewport().set_input_as_handled()


func _toggle_build_catalog() -> void:
	if is_catalog_open():
		_close_build_catalog()
		return
	if hotbar_configuration == null or not is_instance_valid(hotbar_controller):
		return
	_ensure_build_catalog()
	_refresh_build_catalog()
	catalog_overlay.show()


func _close_build_catalog() -> void:
	if is_instance_valid(catalog_overlay):
		catalog_overlay.hide()


func _ensure_build_catalog() -> void:
	if is_instance_valid(catalog_overlay):
		return

	catalog_overlay = CenterContainer.new()
	catalog_overlay.name = "BuildCatalogOverlay"
	catalog_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catalog_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(catalog_overlay)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.025, 0.03, 0.78)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	catalog_overlay.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(510.0, 560.0)
	catalog_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var heading := Label.new()
	heading.text = "BUILD CATALOG — CUSTOMIZE HOTBAR"
	layout.add_child(heading)

	var explanation := Label.new()
	explanation.text = "Select a building for each key. Existing assignments swap slots."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(explanation)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	catalog_rows = VBoxContainer.new()
	catalog_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	catalog_rows.add_theme_constant_override("separation", 8)
	scroll.add_child(catalog_rows)

	catalog_message = Label.new()
	catalog_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(catalog_message)

	var actions := HBoxContainer.new()
	layout.add_child(actions)

	var reset_button := Button.new()
	reset_button.text = "Restore default slots"
	reset_button.pressed.connect(_reset_catalog_slots)
	actions.add_child(reset_button)

	var close_button := Button.new()
	close_button.text = "Close (M / Esc)"
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.pressed.connect(_close_build_catalog)
	actions.add_child(close_button)

	catalog_overlay.hide()


func _refresh_build_catalog() -> void:
	if not is_instance_valid(catalog_rows) or hotbar_configuration == null:
		return
	for child in catalog_rows.get_children():
		catalog_rows.remove_child(child)
		child.queue_free()

	var available: Array[BuildingDefinition] = (
		hotbar_configuration.get_unlocked_catalog()
	)
	for slot_index: int in range(BuildHotbarConfiguration.SLOT_COUNT):
		var line := HBoxContainer.new()
		catalog_rows.add_child(line)

		var slot_label := Label.new()
		slot_label.text = "Key " + str(slot_index + 1)
		slot_label.custom_minimum_size.x = 72.0
		line.add_child(slot_label)

		var selector := OptionButton.new()
		selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(selector)

		selector.add_item("— Empty —")
		selector.set_item_metadata(0, "")
		var chosen: int = 0
		var current_id: StringName = hotbar_configuration.get_id(slot_index)
		for definition: BuildingDefinition in available:
			var item_index: int = selector.item_count
			selector.add_item(_player_facing_name(definition))
			selector.set_item_metadata(item_index, str(definition.building_id))
			if definition.building_id == current_id:
				chosen = item_index
		selector.select(chosen)
		selector.item_selected.connect(
			_on_catalog_slot_selected.bind(slot_index, selector)
		)

	catalog_message.text = "Changes apply immediately to the 1–9 hotbar."


func _on_catalog_slot_selected(
	item_index: int, slot_index: int, selector: OptionButton
) -> void:
	if not is_instance_valid(hotbar_controller):
		return
	var identity := StringName(str(selector.get_item_metadata(item_index)))
	var success: bool = false
	if identity == &"":
		success = bool(hotbar_controller.call("clear_hotbar_slot", slot_index))
	else:
		success = bool(
			hotbar_controller.call("assign_hotbar_slot", slot_index, identity)
		)
	if not success:
		catalog_message.text = "Assignment rejected. Check building unlock state."
	_refresh_build_catalog()


func _reset_catalog_slots() -> void:
	if hotbar_configuration == null or not is_instance_valid(hotbar_controller):
		return
	hotbar_configuration.reset_to_default()
	hotbar_controller.call("_on_hotbar_assignment_changed")
	_refresh_build_catalog()
