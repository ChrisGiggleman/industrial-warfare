extends PanelContainer

# =============================================================================
# VISUAL BUILD HOTBAR — PRESENTATION ONLY
# =============================================================================
# Displays the existing nine stable-ID assignments. WorldInteraction remains
# responsible for keyboard input, selection, placement and catalog edits.

const SLOT_SIZE := Vector2(78.0, 86.0)
const ICON_SIZE := 32

var slot_panels: Array[PanelContainer] = []
var slot_icons: Array[TextureRect] = []
var slot_names: Array[Label] = []
var slot_keys: Array[Label] = []
var _icon_cache: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 6)
	add_child(margin)

	var slots := HBoxContainer.new()
	slots.name = "Slots"
	slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slots.add_theme_constant_override("separation", 5)
	margin.add_child(slots)

	for index: int in range(BuildHotbarConfiguration.SLOT_COUNT):
		var tile := PanelContainer.new()
		tile.name = "Slot" + str(index + 1)
		tile.custom_minimum_size = SLOT_SIZE
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slots.add_child(tile)
		slot_panels.append(tile)

		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		content.add_theme_constant_override("separation", 1)
		tile.add_child(content)

		var key := Label.new()
		key.text = str(index + 1)
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.add_theme_font_size_override("font_size", 12)
		key.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(key)
		slot_keys.append(key)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)
		slot_icons.append(icon)

		var name_label := Label.new()
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 10)
		name_label.clip_text = true
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(name_label)
		slot_names.append(name_label)


func render_slots(
	configuration: BuildHotbarConfiguration,
	selected_slot: int,
	selected_color: Color
) -> void:
	if slot_panels.size() != BuildHotbarConfiguration.SLOT_COUNT:
		return

	for index: int in range(slot_panels.size()):
		var definition: BuildingDefinition = null
		if configuration != null:
			definition = configuration.get_definition(index)
		var identity: StringName = &""
		if is_instance_valid(definition):
			identity = definition.building_id

		var active: bool = index == selected_slot and identity != &""
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.15, 0.18, 0.94) if identity != &"" else Color(0.07, 0.08, 0.09, 0.78)
		style.border_color = selected_color if active else Color(0.37, 0.42, 0.47)
		style.set_border_width_all(3 if active else 1)
		style.set_corner_radius_all(5)
		slot_panels[index].add_theme_stylebox_override("panel", style)
		slot_keys[index].modulate = selected_color if active else Color.WHITE
		slot_icons[index].texture = _get_icon(identity)
		slot_icons[index].modulate = Color.WHITE if identity != &"" else Color(0.5, 0.5, 0.5)
		slot_names[index].text = _short_name(identity)
		slot_panels[index].tooltip_text = (
			str(index + 1) + ": " + definition.display_name
			if is_instance_valid(definition)
			else str(index + 1) + ": Empty"
		)


func _short_name(identity: StringName) -> String:
	match identity:
		&"test_extractor": return "Extractor"
		&"test_building_large": return "Large"
		&"test_storage": return "Storage"
		&"test_smelter": return "Smelter"
		&"conveyor_belt": return "Belt"
		&"conveyor_merger": return "Merger"
		&"conveyor_splitter": return "Splitter"
		&"prototype_ammunition_press": return "Ammo"
		&"prototype_defensive_turret": return "Turret"
		&"": return "Empty"
		_: return "Building"


func _get_icon(identity: StringName) -> Texture2D:
	if _icon_cache.has(identity):
		return _icon_cache[identity] as Texture2D

	var image := Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.08, 0.10, 1.0))
	var foreground := Color(0.64, 0.81, 0.89)
	var accent := Color(0.98, 0.72, 0.30)
	var kind: int = [
		&"test_extractor", &"test_building_large", &"test_storage",
		&"test_smelter", &"conveyor_belt", &"conveyor_merger",
		&"conveyor_splitter", &"prototype_ammunition_press",
		&"prototype_defensive_turret"
	].find(identity)

	match kind:
		0:
			image.fill_rect(Rect2i(11, 6, 10, 20), foreground)
			image.fill_rect(Rect2i(5, 17, 22, 5), accent)
		1:
			image.fill_rect(Rect2i(5, 7, 22, 20), foreground)
			image.fill_rect(Rect2i(10, 12, 12, 10), Color(0.05, 0.08, 0.10))
		2:
			for y: int in [7, 14, 21]:
				image.fill_rect(Rect2i(5, y, 22, 5), foreground)
		3:
			image.fill_rect(Rect2i(5, 17, 22, 10), foreground)
			image.fill_rect(Rect2i(11, 5, 5, 14), accent)
		4:
			image.fill_rect(Rect2i(3, 11, 26, 10), foreground)
			for x: int in [7, 15, 23]:
				image.fill_rect(Rect2i(x, 12, 3, 8), accent)
		5:
			image.fill_rect(Rect2i(3, 5, 9, 7), foreground)
			image.fill_rect(Rect2i(3, 20, 9, 7), foreground)
			image.fill_rect(Rect2i(14, 13, 15, 6), accent)
		6:
			image.fill_rect(Rect2i(3, 13, 14, 6), foreground)
			image.fill_rect(Rect2i(20, 4, 9, 8), accent)
			image.fill_rect(Rect2i(20, 20, 9, 8), accent)
		7:
			image.fill_rect(Rect2i(6, 9, 20, 18), foreground)
			image.fill_rect(Rect2i(13, 3, 6, 19), accent)
		8:
			image.fill_rect(Rect2i(9, 17, 14, 11), foreground)
			image.fill_rect(Rect2i(14, 3, 4, 20), accent)
			image.fill_rect(Rect2i(5, 12, 22, 5), foreground)
		_:
			image.fill_rect(Rect2i(12, 12, 8, 8), Color(0.28, 0.33, 0.38))

	var texture := ImageTexture.create_from_image(image)
	_icon_cache[identity] = texture
	return texture
