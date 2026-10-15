extends Resource
class_name ItemDefinition


# =============================================================================
# ITEM IDENTITY
# =============================================================================

# Unique internal identifier used by gameplay systems.
@export var item_id: StringName

# Player-facing item name.
@export var display_name: String = "Item"

# Short description for future inventory and production interfaces.
@export_multiline var description: String = ""