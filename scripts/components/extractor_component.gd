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

# Advances extraction only while a valid resource node and inventory exist.

func _process(delta: float) -> void:
	if resource_node == null:
		extraction_timer = 0.0
		return

	if not is_instance_valid(resource_node):
		resource_node = null
		extraction_timer = 0.0
		return

	if inventory_component == null:
		return

	if extraction_interval <= 0.0:
		return

	extraction_timer += delta

	if extraction_timer < extraction_interval:
		return

	extraction_timer -= extraction_interval
	_extract_resource()


# =============================================================================
# RESOURCE EXTRACTION
# =============================================================================

# Requests resource from the detected node and stores the amount actually
# provided in this building's inventory.

func _extract_resource() -> void:
	if resource_node == null:
		return

	if resource_node.definition == null:
		return

	var resource_item: ItemDefinition = resource_node.definition.resource_item

	if resource_item == null:
		return

	var extracted_amount: int = resource_node.extract(extraction_amount)

	if extracted_amount <= 0:
		return

	inventory_component.add_item(
		resource_item,
		extracted_amount
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
