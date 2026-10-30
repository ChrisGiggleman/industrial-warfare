extends CanvasLayer
class_name ProductionDebugHUD


# =============================================================================
# UI REFERENCES
# =============================================================================

# Label used to display information about the currently selected building.
@export var info_label: Label

# =============================================================================
# ACTIVITY PROGRESS BAR REFERENCE
# =============================================================================

# Displays the progress of the selected building's
# extraction or manufacturing cycle.
#
# For Chat 06, we first connect manufacturing progress.
# Extractor progress will use this same UI component later.
#
# The progress bar remains hidden when the selected
# object does not have a supported production component.

@export var activity_progress_bar: ProgressBar


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
	_refresh_activity_progress()

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
# CHAT 08.3G-3J — SHOW BOTH MERGER LANES AND OUTPUT BACKPRESSURE
# =============================================================================

func _refresh_merger_display(
	building_runtime: BuildingRuntime,
	merger: ConveyorMergerComponent
) -> void:
	if info_label == null:
		return

	var input_a: InventoryComponent = merger.input_a
	var input_b: InventoryComponent = merger.input_b
	var output_inventory: InventoryComponent = merger.output_inventory
	if (
		not is_instance_valid(input_a)
		or not is_instance_valid(input_b)
		or not is_instance_valid(output_inventory)
	):
		info_label.text = "PRODUCTION DEBUG\n\nMerger inventory references missing"
		return

	var port_a := selected_building.get_node_or_null("InputPortA") as ItemPortComponent
	var port_b := selected_building.get_node_or_null("InputPortB") as ItemPortComponent
	var port_out := selected_building.get_node_or_null("OutputPort") as ItemPortComponent

	var connected_a: bool = (
		is_instance_valid(port_a)
		and is_instance_valid(port_a.connected_conveyor)
	)
	var connected_b: bool = (
		is_instance_valid(port_b)
		and is_instance_valid(port_b.connected_conveyor)
	)
	var connected_out: bool = (
		is_instance_valid(port_out)
		and is_instance_valid(port_out.connected_conveyor)
	)

	var status: String = "Transferring"
	if not connected_out:
		status = "Output conveyor disconnected"
	elif output_inventory.is_full():
		status = "Output full / backpressure"
	elif input_a.get_total_amount() == 0 and input_b.get_total_amount() == 0:
		status = "Waiting for input items"

	info_label.text = (
		"PRODUCTION DEBUG\n\n"
		+ "Building: "
		+ building_runtime.building_definition.display_name
		+ "\nType: Conveyor Merger"
		+ "\nStatus: " + status
		+ "\n\nInput A: "
		+ str(input_a.get_total_amount()) + " / " + str(input_a.max_capacity)
		+ "\nConnection: " + ("Connected" if connected_a else "Disconnected")
		+ "\nInput B: "
		+ str(input_b.get_total_amount()) + " / " + str(input_b.max_capacity)
		+ "\nConnection: " + ("Connected" if connected_b else "Disconnected")
		+ "\n\nOutput: "
		+ str(output_inventory.get_total_amount())
		+ " / " + str(output_inventory.max_capacity)
		+ "\nConnection: " + ("Connected" if connected_out else "Disconnected")
		+ "\n\nCompleted merges: " + str(merger.completed_merges)
		+ "\nFrom A: " + str(merger.completed_from_a)
		+ " | From B: " + str(merger.completed_from_b)
		+ "\nNext input lane: " + ("A" if merger.next_lane == 0 else "B")
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

	# =============================================================================
	# CHAT 08.3G-3J — MERGER BACKPRESSURE AND PORT DIAGNOSTICS
	# =============================================================================

	var merger: ConveyorMergerComponent = (
		selected_building.get_node_or_null("MergerComponent")
		as ConveyorMergerComponent
	)
	if is_instance_valid(merger):
		_refresh_merger_display(building_runtime, merger)
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

	# =============================================================================
	# MANUFACTURING OUTPUT INVENTORY LOOKUP
	# =============================================================================

	# Manufacturing buildings use separate input and output
	# inventories instead of one shared InventoryComponent.
	#
	# The Production Debug HUD must read finished products
	# from OutputInventory, not the old inventory node.
	#
	# Existing extractor and storage inventory displays
	# remain unchanged.

	if producer_component != null:

		var manufacturing_output_inventory: InventoryComponent = (
			selected_building.get_node_or_null("OutputInventory")
			as InventoryComponent
		)

		# Use the dedicated output inventory when available.
		if manufacturing_output_inventory != null:
			inventory_component = manufacturing_output_inventory

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

	# =============================================================================
	# MANUFACTURING STATUS DISPLAY
	# =============================================================================

	# Displays the machine's operating condition.
	#
	# Examples:
	# - Producing
	# - Waiting for Inputs
	# - Output Blocked
	# - Invalid Recipe

	display_text += (
		"\nProduction Status: "
		+ producer_component.production_status
	)

	# =============================================================================
	# MANUFACTURING INPUT INVENTORY DISPLAY
	# =============================================================================

	# Display raw materials stored in the manufacturing
	# building's dedicated input inventory.
	#
	# Read the inventory reference directly from ProducerComponent.
	# This supports future manufacturing machines without
	# hardcoding Test Ore or individual building names.

	var manufacturing_input: InventoryComponent = (
		producer_component.input_inventory
	)

	display_text += "\n\nINPUT MATERIALS"

	if is_instance_valid(manufacturing_input):

		# Display input inventory capacity.
		var input_total: int = manufacturing_input.get_total_amount()

		if manufacturing_input.max_capacity == 0:
			display_text += "\nCapacity: Unlimited"
		else:
			display_text += (
				"\nCapacity: "
				+ str(input_total)
				+ " / "
				+ str(manufacturing_input.max_capacity)
			)

		# Display each required recipe ingredient.
		for input_entry in producer_component.recipe.inputs:

			if input_entry == null:
				continue

			if input_entry.item == null:
				continue

			var stored_input: int = manufacturing_input.get_amount(
				input_entry.item
			)

			display_text += (
				"\n"
				+ input_entry.item.display_name
				+ ": "
				+ str(stored_input)
				+ " stored"
				+ " | Requires: "
				+ str(input_entry.amount)
			)

	else:
		display_text += "\nInput Inventory Missing"


	# =============================================================================
	# MANUFACTURING OUTPUT INVENTORY DISPLAY
	# =============================================================================

	# The existing inventory_component variable now references
	# OutputInventory following our previous HUD correction.
	#
	# Display total output storage capacity before listing
	# the finished products.

	display_text += "\n\nOUTPUT MATERIALS"

	if is_instance_valid(inventory_component):

		var output_total: int = inventory_component.get_total_amount()

		if inventory_component.max_capacity == 0:
			display_text += "\nCapacity: Unlimited"
		else:
			display_text += (
				"\nCapacity: "
				+ str(output_total)
				+ " / "
				+ str(inventory_component.max_capacity)
			)

	else:
		display_text += "\nOutput Inventory Missing"

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

	# =============================================================================
	# ACTUAL EXTRACTION OPERATING STATUS
	# =============================================================================

	# Read the extraction component's real operating state.
	#
	# This prevents the HUD from displaying "Extracting"
	# when the inventory is full or the deposit is depleted.
	#
	# The status is maintained by ExtractorComponent._process().

	display_text += (
		"\nStatus: "
		+ extractor_component.extraction_status
	)

	if extractor_component.resource_node == null:
		info_label.text = display_text
		return

	if not is_instance_valid(extractor_component.resource_node):
		info_label.text = display_text
		return

	var resource_definition: ResourceNodeDefinition = (
		extractor_component.resource_node.definition
	)

	if resource_definition == null:
		info_label.text = display_text
		return

	var resource_item: ItemDefinition = resource_definition.resource_item

	if resource_item == null:
		info_label.text = display_text
		return

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
#
# Also resets and hides the activity progress bar so
# previous building progress does not remain visible
# after the player deselects an object.

func _show_no_selection() -> void:

	# =============================================================================
	# RESET ACTIVITY PROGRESS BAR
	# =============================================================================

	if activity_progress_bar != null:
		activity_progress_bar.visible = false
		activity_progress_bar.value = 0.0

	# =============================================================================
	# RESET DEBUG TEXT
	# =============================================================================

	if info_label == null:
		return

	info_label.text = "PRODUCTION DEBUG\n\nNo object selected."



# =============================================================================
# BUILDING ACTIVITY PROGRESS DISPLAY
# =============================================================================

# Updates the shared progress bar using the selected
# building's actual manufacturing progress.
#
# The bar:
# - Is hidden for unsupported objects.
# - Displays 0% to 100% for valid production recipes.
# - Uses the producer's actual cycle timer.
# - Resets visually when manufacturing is blocked.
#
# Future extraction components can use this same bar.

func _refresh_activity_progress() -> void:

	# =============================================================================
	# VALIDATE PROGRESS BAR
	# =============================================================================

	if activity_progress_bar == null:
		return

	# Hide the progress bar by default.
	activity_progress_bar.visible = false
	activity_progress_bar.value = 0.0

	# =============================================================================
	# VALIDATE SELECTED BUILDING
	# =============================================================================

	if not is_instance_valid(selected_building):
		return


	# =============================================================================
	# EXTRACTOR ACTIVITY PROGRESS
	# =============================================================================

	# Check whether the selected building contains an
	# ExtractorComponent.
	#
	# Extractors and manufacturing buildings share the same
	# ActivityProgressBar in the Production Debug HUD.
	#
	# This allows future extraction buildings to display
	# their progress without creating separate UI controls.

	var extractor_component: ExtractorComponent = (
		selected_building.get_node_or_null("ExtractorComponent")
		as ExtractorComponent
	)

	# =============================================================================
	# HANDLE EXTRACTOR BUILDINGS
	# =============================================================================

	if extractor_component != null:

		# The progress bar should be visible whenever an
		# extractor is selected, including when it is blocked.
		activity_progress_bar.visible = true

		# =============================================================================
		# VALIDATE EXTRACTION INTERVAL
		# =============================================================================

		# Prevent division by zero if the extractor has
		# an invalid extraction interval.

		if extractor_component.extraction_interval <= 0.0:
			activity_progress_bar.value = 0.0
			activity_progress_bar.tooltip_text = (
				"Extraction: "
				+ extractor_component.extraction_status
			)
			return

		# =============================================================================
		# CALCULATE EXTRACTION PROGRESS
		# =============================================================================

		# The extractor tracks elapsed time in extraction_timer.
		#
		# Example:
		# extraction_timer: 0.5 seconds
		# extraction_interval: 1.0 second
		# Result: 50% progress

		var extraction_percentage: float = 0.0

		# Only display advancing progress when extraction
		# is actively taking place.
		#
		# When the extractor is full, depleted, or otherwise
		# blocked, display an empty progress bar.

		if extractor_component.extraction_status == "Extracting":

			extraction_percentage = (
				extractor_component.extraction_timer
				/ extractor_component.extraction_interval
			) * 100.0

		# Keep progress within the expected percentage range.
		extraction_percentage = clampf(
			extraction_percentage,
			0.0,
			100.0
		)

		# =============================================================================
		# UPDATE EXTRACTOR PROGRESS BAR
		# =============================================================================

		activity_progress_bar.value = extraction_percentage

		# Display the operating condition when the player
		# hovers over the progress bar.

		activity_progress_bar.tooltip_text = (
			"Extraction: "
			+ extractor_component.extraction_status
		)

		# Extraction progress has been handled.
		#
		# Return to prevent falling through into the
		# manufacturing ProducerComponent logic below.

		return

	# =============================================================================
	# LOCATE PRODUCER COMPONENT
	# =============================================================================

	# Not every building manufactures items.
	# Storage and resource deposits do not use this
	# manufacturing progress calculation.

	var producer_component: ProducerComponent = (
		selected_building.get_node_or_null("ProducerComponent")
		as ProducerComponent
	)

	if producer_component == null:
		return

	# =============================================================================
	# VALIDATE PRODUCTION RECIPE
	# =============================================================================

	if producer_component.recipe == null:
		return

	if producer_component.recipe.production_time <= 0.0:
		return

	# =============================================================================
	# CALCULATE PRODUCTION PERCENTAGE
	# =============================================================================

	# Convert elapsed cycle time into a percentage.
	#
	# Example:
	# Progress: 1.0 second
	# Cycle time: 2.0 seconds
	# Result: 50%

	var progress_percentage: float = (
		producer_component.production_progress
		/ producer_component.recipe.production_time
	) * 100.0

	# Prevent values outside the valid progress range.
	progress_percentage = clampf(
		progress_percentage,
		0.0,
		100.0
	)

	# =============================================================================
	# UPDATE PROGRESS BAR
	# =============================================================================

	activity_progress_bar.visible = true
	activity_progress_bar.value = progress_percentage

	# Show the current operating condition when the
	# player hovers over the progress bar.
	activity_progress_bar.tooltip_text = (
		"Production: " + producer_component.production_status
	)
