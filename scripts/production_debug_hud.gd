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

	# =============================================================================
	# STORAGE BUILDING DISPLAY CHECK
	# =============================================================================

	# Storage buildings have a dedicated inventory display.
	#
	# The logistics_storage group identifies buildings that can
	# receive resources from our logistics system.
	#
	# Handle storage before checking production recipes so storage
	# buildings no longer display the generic "Recipe: None" message.

	if selected_building.is_in_group("logistics_storage"):
		_refresh_storage_display(
			building_runtime,
			inventory_component
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

	# =============================================================================
	# EXTRACTOR INVENTORY CAPACITY DISPLAY
	# =============================================================================

	# Displays how much inventory space the extractor is using.
	#
	# This uses the same InventoryComponent methods as our
	# Test Storage building.
	#
	# Capacity 0 represents an unlimited inventory.

	if inventory_component != null:

		var total_stored: int = inventory_component.get_total_amount()
		var max_capacity: int = inventory_component.max_capacity

		if max_capacity == 0:
			display_text += (
				"\nInventory Capacity: Unlimited"
			)
		else:
			display_text += (
				"\nInventory Capacity: "
				+ str(total_stored)
				+ " / "
				+ str(max_capacity)
			)

			# Show a clear status when the extractor is full.
			if inventory_component.is_full():
				display_text += "\nInventory Status: FULL"

	else:
		display_text += "\nInventory: Missing"

	# =============================================================================
	# EXTRACTOR LOGISTICS STATUS DISPLAY
	# =============================================================================

	# Locate the logistics component belonging to the selected extractor.
	#
	# The component stores the latest transfer status and quantity.
	# We only read these values; the HUD never moves resources.

	var logistics_component: LogisticsTransferComponent = (
		selected_building.get_node_or_null("LogisticsTransferComponent")
		as LogisticsTransferComponent
	)

	# =============================================================================
	# VALIDATE LOGISTICS COMPONENT
	# =============================================================================

	# Not every extractor or future production building will
	# necessarily have a logistics component.

	if logistics_component != null:

		# Add a separate section for logistics information.
		display_text += "\n\nLOGISTICS STATUS"

		# =============================================================================
		# CURRENT LOGISTICS STATUS
		# =============================================================================

		# Display the current operating condition.
		# Examples:
		# - Transferring
		# - Waiting for Resources
		# - No Eligible Storage

		display_text += (
			"\nStatus: "
			+ logistics_component.logistics_status
		)

		# =============================================================================
		# CONFIGURED TRANSFER RATE
		# =============================================================================

		# Show the maximum configured throughput.
		#
		# This is the theoretical transfer rate, not the actual
		# number of resources moved during the last second.

		var transfer_rate: float = (
			float(logistics_component.transfer_amount)
			/ logistics_component.transfer_interval
		)

		display_text += (
			"\nTransfer Rate: Up to "
			+ str(transfer_rate)
			+ " units/sec"
		)

		# =============================================================================
		# LAST TRANSFER AMOUNT
		# =============================================================================

		# Show how many items were successfully moved
		# during the most recent transfer attempt.

		display_text += (
			"\nLast Transfer: "
			+ str(logistics_component.last_transfer_amount)
			+ " units"
		)

		# =============================================================================
		# LAST SUCCESSFUL TRANSFER DISPLAY
		# =============================================================================

		# Displays the quantity moved during the most recent
		# successful inventory transfer.
		#
		# Unlike Last Transfer, this value is preserved when:
		# - The destination storage becomes full.
		# - No eligible storage building is available.
		# - The source inventory has no resources to transfer.
		#
		# This helps distinguish a stopped logistics connection
		# from one that has never transferred resources.

		display_text += (
			"\nLast Successful Transfer: "
			+ str(logistics_component.last_successful_transfer_amount)
			+ " units"
		)

	else:
		display_text += "\n\nLogistics: Not Installed"

	info_label.text = display_text


# =============================================================================
# STORAGE BUILDING DISPLAY
# =============================================================================

# Displays inventory usage for a selected storage building.
#
# This function reads the existing InventoryComponent directly.
# It does not modify resources or interfere with logistics.
#
# Storage capacity and inventory totals update automatically
# because the Production Debug HUD refreshes every frame.

func _refresh_storage_display(
	building_runtime: BuildingRuntime,
	inventory_component: InventoryComponent
) -> void:

	var display_text: String = (
		"PRODUCTION DEBUG\n\n"
		+ "Building: "
		+ building_runtime.building_definition.display_name
		+ "\nType: Storage"
	)

	# =============================================================================
	# VALIDATE INVENTORY
	# =============================================================================

	# Storage buildings should have an InventoryComponent.
	# Report missing components rather than triggering an error.

	if inventory_component == null:
		display_text += "\nInventory: Missing"
		info_label.text = display_text
		return

	# =============================================================================
	# INVENTORY CAPACITY DISPLAY
	# =============================================================================

	# Calculate how many total item units are currently stored.
	var stored_amount: int = inventory_component.get_total_amount()

	# Read the configured inventory capacity.
	var max_capacity: int = inventory_component.max_capacity

	# Unlimited inventories use capacity 0.
	if max_capacity == 0:
		display_text += (
			"\nStored Items: "
			+ str(stored_amount)
			+ "\nCapacity: Unlimited"
		)
	else:
		display_text += (
			"\nStored Items: "
			+ str(stored_amount)
			+ "\nCapacity: "
			+ str(stored_amount)
			+ " / "
			+ str(max_capacity)
		)

	# =============================================================================
	# STORAGE INVENTORY CONTENTS
	# =============================================================================

	# Displays each resource currently stored in this inventory.
	#
	# InventoryComponent stores items in a Dictionary:
	# Key   = ItemDefinition
	# Value = Stored quantity
	#
	# This allows us to support any future resource type without
	# having to hardcode Test Ore or other specific resources.

	display_text += "\n\nINVENTORY CONTENTS"

	# Check whether the inventory contains any items.
	if inventory_component.items.is_empty():
		display_text += "\nEmpty"

	else:
		# Loop through every stored item definition.
		for item in inventory_component.items.keys():

			# Ignore invalid item references.
			if not item is ItemDefinition:
				continue

			var item_definition: ItemDefinition = item as ItemDefinition

			# Retrieve the stored amount using our existing
			# InventoryComponent helper function.
			var item_amount: int = inventory_component.get_amount(
				item_definition
			)

			# Display the resource name and current quantity.
			display_text += (
				"\n"
				+ item_definition.display_name
				+ ": "
				+ str(item_amount)
			)

	# =============================================================================
	# UPDATE HUD
	# =============================================================================

	info_label.text = display_text

# =============================================================================
# DEFAULT DISPLAY
# =============================================================================

# Displays the idle state when no world object is selected.

func _show_no_selection() -> void:
	if info_label == null:
		return

	info_label.text = "PRODUCTION DEBUG\n\nNo object selected."
