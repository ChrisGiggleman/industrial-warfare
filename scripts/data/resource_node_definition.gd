extends Resource
class_name ResourceNodeDefinition


# =============================================================================
# RESOURCE NODE IDENTITY
# =============================================================================

@export var resource_node_id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""


# =============================================================================
# RESOURCE CONTENT
# =============================================================================

@export var resource_item: ItemDefinition
@export var infinite_resource: bool = true
@export_range(1, 1000000, 1) var starting_amount: int = 1000
