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

# Determines what type of world object is selected and displays the
# appropriate debug information.

func _refresh_display() -> void:
	if info_label == null:
		return

	if selected_building == null:
		_show_no_selection()
		return

	var resource_node_runtime: ResourceNodeRuntime = (
		selected_building.get_node_or_null("ResourceNodeRuntime") as ResourceNodeRuntime
	)

	if resource_node_runtime != null:
		_refresh_resource_node_display(resource_node_runtime)
		return

	var building_runtime: BuildingRuntime = (
		selected_building.get_node_or_null("BuildingRuntime") as BuildingRuntime
	)

	if building_runtime != null:
		_refresh_building_display(building_runtime)
		return

	info_label.text = (
		"PRODUCTION DEBUG\n\n"
		+ "Selected object has no debug data."
	)


# =============================================================================
# RESOURCE NODE DISPLAY
# =============================================================================

# Displays information about the selected resource deposit.

func _refresh_resource_node_display(
	resource_node_runtime: ResourceNodeRuntime
) -> void:
	if resource_node_runtime.definition == null:
		info_label.text = (
			"PRODUCTION DEBUG\n\n"
			+ "Resource node definition unavailable."
		)
		return

	var definition: ResourceNodeDefinition = resource_node_runtime.definition

	var display_text: String = (
		"PRODUCTION DEBUG\n\n"
		+ "RESOURCE NODE"
		+ "\nName: "
		+ definition.display_name
	)

	if definition.resource_item != null:
		display_text += (
			"\nResource: "
			+ definition.resource_item.display_name
		)
	else:
		display_text += "\nResource: None"

	if definition.infinite_resource:
		display_text += "\nSupply: Infinite"
	else:
		display_text += (
			"\nRemaining: "
			+ str(resource_node_runtime.remaining_amount)
			+ " / "
			+ str(definition.starting_amount)
		)

	info_label.text = display_text


# =============================================================================
# BUILDING DISPLAY
# =============================================================================

# Displays the existing building production and inventory information.

func _refresh_building_display(
	building_runtime: BuildingRuntime
) -> void:
	if building_runtime.building_definition == null:
		info_label.text = (
			"PRODUCTION DEBUG\n\n"
			+ "Building definition unavailable."
		)
		return

	var inventory_component: InventoryComponent = (
		selected_building.get_node_or_null("InventoryComponent")
		as InventoryComponent
	)

	var extractor_component: ExtractorComponent = (
		selected_building.get_node_or_null("ExtractorComponent")
		as ExtractorComponent
	)

	if extractor_component != null:
		_refresh_extractor_display(
			building_runtime,
			inventory_component,
			extractor_component
		)
		return

	var producer_component: ProducerComponent = (
		selected_building.get_node_or_null("ProducerComponent")
		as ProducerComponent
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
# EXTRACTOR DISPLAY
# =============================================================================

# Displays extraction status, detected resource, and stored quantity.

func _refresh_extractor_display(
	building_runtime: BuildingRuntime,
	inventory_component: InventoryComponent,
	extractor_component: ExtractorComponent
) -> void:
	var display_text: String = (
		"PRODUCTION DEBUG\n\n"
		+ "Building: "
		+ building_runtime.building_definition.display_name
		+ "\nType: Extractor"
	)

	if extractor_component.resource_node == null:
		display_text += "\nStatus: No Resource In Range"
		info_label.text = display_text
		return

	if not is_instance_valid(extractor_component.resource_node):
		display_text += "\nStatus: No Resource In Range"
		info_label.text = display_text
		return

	var resource_definition: ResourceNodeDefinition = (
		extractor_component.resource_node.definition
	)

	if resource_definition == null:
		display_text += "\nStatus: Resource Data Unavailable"
		info_label.text = display_text
		return

	var resource_item: ItemDefinition = resource_definition.resource_item

	if resource_item == null:
		display_text += "\nStatus: Resource Item Unavailable"
		info_label.text = display_text
		return

	if (
		not resource_definition.infinite_resource
		and extractor_component.resource_node.remaining_amount <= 0
	):
		display_text += "\nStatus: Resource Depleted"
	else:
		display_text += "\nStatus: Extracting"

	display_text += (
		"\nResource: "
		+ resource_item.display_name
	)

	var stored_amount: int = 0

	if inventory_component != null:
		stored_amount = inventory_component.get_amount(resource_item)

	display_text += (
		"\nStored "
		+ resource_item.display_name
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

	info_label.text = "PRODUCTION DEBUG\n\nNo object selected."
