extends CanvasLayer
class_name ProductionDebugHUD


# =============================================================================
# UI REFERENCES
# =============================================================================

# Label used to display information about the currently selected building.
@export var info_label: Label


# =============================================================================
# RUNTIME STATE
# =============================================================================

# World object currently being displayed by the debug HUD.
var selected_building: Node = null


# =============================================================================
# FRAME UPDATE
# =============================================================================

# Refreshes displayed production information so changing inventory quantities
# remain visible while the selected building continues producing.

func _process(_delta: float) -> void:
	if selected_building == null:
		_show_no_selection()
		return

	if not is_instance_valid(selected_building):
		selected_building = null
		_show_no_selection()
		return

	_refresh_display()


# =============================================================================
# BUILDING SELECTION
# =============================================================================

# Assigns the world object whose production information should be displayed.

func set_selected_building(building: Node) -> void:
	selected_building = building
	_refresh_display()


# =============================================================================
# SELECTION CLEARING
# =============================================================================

# Removes the current building reference and restores the default display.

func clear_selection() -> void:
	selected_building = null
	_show_no_selection()


# =============================================================================
# DISPLAY REFRESH
# =============================================================================

# Reads reusable building components and builds the current debug text.

func _refresh_display() -> void:
	if info_label == null:
		return

	if selected_building == null:
		_show_no_selection()
		return

	var building_runtime: BuildingRuntime = (
		selected_building.get_node_or_null("BuildingRuntime") as BuildingRuntime
	)

	if building_runtime == null:
		info_label.text = (
			"PRODUCTION DEBUG\n\n"
			+ "Selected object has no building data."
		)
		return

	if building_runtime.building_definition == null:
		info_label.text = (
			"PRODUCTION DEBUG\n\n"
			+ "Building definition unavailable."
		)
		return

	var inventory_component: InventoryComponent = (
		selected_building.get_node_or_null("InventoryComponent") as InventoryComponent
	)

	var producer_component: ProducerComponent = (
		selected_building.get_node_or_null("ProducerComponent") as ProducerComponent
	)

	var display_text: String = (
		"PRODUCTION DEBUG\n\n"
		+ "Building: "
		+ building_runtime.building_definition.display_name
	)

	if producer_component == null or producer_component.recipe == null:
		display_text += "\nRecipe: None"
		info_label.text = display_text
		return

	display_text += (
		"\nRecipe: "
		+ producer_component.recipe.display_name
	)

	for output in producer_component.recipe.outputs:
		if output == null:
			continue

		if output.item == null:
			continue

		var stored_amount: int = 0

		if inventory_component != null:
			stored_amount = inventory_component.get_amount(output.item)

		display_text += (
			"\nStored "
			+ output.item.display_name
			+ ": "
			+ str(stored_amount)
		)

	info_label.text = display_text


# =============================================================================
# DEFAULT DISPLAY
# =============================================================================

# Displays the idle state when no world object is selected.

func _show_no_selection() -> void:
	if info_label == null:
		return

	info_label.text = "PRODUCTION DEBUG\n\nNo building selected."
