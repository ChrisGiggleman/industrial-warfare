extends Node
class_name ExtractorComponent


# =============================================================================
# EXTRACTION SETTINGS
# =============================================================================

# Number of resource units requested during each extraction cycle.
@export_range(1, 1000, 1) var extraction_amount: int = 1

# Time in seconds between extraction cycles.
@export_range(0.1, 60.0, 0.1) var extraction_interval: float = 1.0

# Area used to detect nearby resource deposits.
@export var extraction_area: Area3D


# =============================================================================
# RUNTIME STATE
# =============================================================================

# Resource node currently supplying this extractor.
var resource_node: ResourceNodeRuntime = null

# Time accumulated toward the next extraction cycle.
var extraction_timer: float = 0.0

# =============================================================================
# EXTRACTION OPERATING STATUS
# =============================================================================

# Tracks the extractor's current operating condition.
#
# This will be read by our shared Production Debug HUD.
#
# Possible states:
# - Initializing
# - Extracting
# - No Resource In Range
# - Resource Depleted
# - Inventory Full
# - Inventory Missing
# - Resource Data Unavailable
# - Resource Item Unavailable
# - Invalid Extraction Interval

var extraction_status: String = "Initializing"
# Inventory that receives successfully extracted resources.
var inventory_component: InventoryComponent = null

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	inventory_component = (
		get_parent().get_node_or_null("InventoryComponent")
		as InventoryComponent
	)

	if inventory_component == null:
		push_warning("ExtractorComponent has no InventoryComponent available.")

	if extraction_area == null:
		push_warning("ExtractorComponent has no ExtractionArea assigned.")
		return

	extraction_area.body_entered.connect(_on_body_entered)
	extraction_area.body_exited.connect(_on_body_exited)

	call_deferred("_scan_for_resource_node")



# =============================================================================
# EXTRACTION UPDATE
# =============================================================================

# Advances extraction only while the machine can actively mine.
#
# The extraction timer must stop when:
# - No resource deposit is available.
# - The resource deposit is depleted.
# - Inventory capacity is full.
# - Required resource data is missing.
#
# This allows our shared activity progress bar to accurately
# represent real extraction work.

func _process(delta: float) -> void:

	# =============================================================================
	# VALIDATE RESOURCE NODE
	# =============================================================================

	if not is_instance_valid(resource_node):
		resource_node = null
		_stop_extraction("No Resource In Range")
		return

	if resource_node.definition == null:
		_stop_extraction("Resource Data Unavailable")
		return

	if resource_node.definition.resource_item == null:
		_stop_extraction("Resource Item Unavailable")
		return

	# =============================================================================
	# CHECK RESOURCE DEPLETION
	# =============================================================================

	# Infinite deposits never run out of material.
	# Finite deposits must have resources remaining.

	if (
		not resource_node.definition.infinite_resource
		and resource_node.remaining_amount <= 0
	):
		_stop_extraction("Resource Depleted")
		return

	# =============================================================================
	# VALIDATE INVENTORY
	# =============================================================================

	if not is_instance_valid(inventory_component):
		_stop_extraction("Inventory Missing")
		return

	# Do not continue extracting while inventory is full.
	if inventory_component.is_full():
		_stop_extraction("Inventory Full")
		return

	# =============================================================================
	# VALIDATE EXTRACTION INTERVAL
	# =============================================================================

	if extraction_interval <= 0.0:
		_stop_extraction("Invalid Extraction Interval")
		return

	# =============================================================================
	# ADVANCE EXTRACTION PROGRESS
	# =============================================================================

	# All extraction requirements are satisfied.
	extraction_status = "Extracting"

	extraction_timer += delta

	if extraction_timer < extraction_interval:
		return

	# Preserve additional elapsed time.
	extraction_timer -= extraction_interval

	# =============================================================================
	# COMPLETE EXTRACTION CYCLE
	# =============================================================================

	# The existing extraction function performs capacity-aware
	# resource extraction and stores the accepted materials.
	#
	# No changes to resource accounting are required here.

	_extract_resource()


# =============================================================================
# STOP EXTRACTION
# =============================================================================

# Resets extraction progress when the machine cannot mine.
#
# This ensures the future progress bar displays 0% when
# extraction is blocked or no resource is available.
#
# No inventory or resource quantities are changed here.

func _stop_extraction(reason: String) -> void:

	extraction_timer = 0.0
	extraction_status = reason

# =============================================================================
# RESOURCE EXTRACTION
# =============================================================================

# Extracts resources from the detected resource node.
#
# Before extraction, checks the inventory's available capacity.
# Only requests the amount that can actually fit.
#
# This prevents resources from being permanently removed from
# finite deposits when the extractor's inventory is full.

func _extract_resource() -> void:
	if resource_node == null:
		return

	if resource_node.definition == null:
		return

	if inventory_component == null:
		return

	var resource_item: ItemDefinition = resource_node.definition.resource_item

	if resource_item == null:
		return

	# =============================================================================
	# CHECK INVENTORY CAPACITY
	# =============================================================================

	# -1 means the inventory has unlimited capacity.
	var available_space: int = inventory_component.get_available_space()

	# Begin with the extractor's configured extraction amount.
	var requested_amount: int = extraction_amount

	# Limit the requested amount when capacity is restricted.
	if available_space >= 0:
		requested_amount = mini(requested_amount, available_space)

	# Stop mining if the inventory cannot accept any more items.
	if requested_amount <= 0:
		return

	# =============================================================================
	# EXTRACT RESOURCE
	# =============================================================================

	# Only request the quantity that can fit in the inventory.
	# The resource node handles finite and infinite deposits.
	var extracted_amount: int = resource_node.extract(requested_amount)

	if extracted_amount <= 0:
		return

	# =============================================================================
	# STORE EXTRACTED RESOURCE
	# =============================================================================

	# Store the extracted amount in the building's inventory.
	# add_item() returns the number of units successfully accepted.
	var stored_amount: int = inventory_component.add_item(
		resource_item,
		extracted_amount
	)

	# Report unexpected storage discrepancies during development.
	if stored_amount != extracted_amount:
		push_warning(
			"Extractor inventory accepted fewer items than extracted."
		)


	
# =============================================================================
# RESOURCE NODE DETECTION
# =============================================================================

func _scan_for_resource_node() -> void:
	if extraction_area == null:
		return

	for body in extraction_area.get_overlapping_bodies():
		var detected_resource: ResourceNodeRuntime = _find_resource_node(body)

		if detected_resource != null:
			resource_node = detected_resource

			print(
				"Extractor found resource node: ",
				resource_node.definition.display_name
			)

			return

	resource_node = null
	print("Extractor has no resource node")


func _on_body_entered(body: Node3D) -> void:
	if resource_node != null:
		return

	var detected_resource: ResourceNodeRuntime = _find_resource_node(body)

	if detected_resource == null:
		return

	resource_node = detected_resource

	print(
		"Extractor found resource node: ",
		resource_node.definition.display_name
	)


func _on_body_exited(body: Node3D) -> void:
	if resource_node == null:
		return

	var detected_resource: ResourceNodeRuntime = _find_resource_node(body)

	if detected_resource != resource_node:
		return

	resource_node = null
	print("Extractor lost resource node")

	call_deferred("_scan_for_resource_node")

# =============================================================================
# RESOURCE NODE LOOKUP
# =============================================================================

func _find_resource_node(body: Node) -> ResourceNodeRuntime:
	var current_node: Node = body

	while current_node != null:
		var runtime: ResourceNodeRuntime = (
			current_node.get_node_or_null("ResourceNodeRuntime")
			as ResourceNodeRuntime
		)

		if runtime != null:
			return runtime

		current_node = current_node.get_parent()

	return null
