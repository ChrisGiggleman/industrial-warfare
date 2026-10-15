extends Resource
class_name ItemAmount


# =============================================================================
# ITEM AMOUNT DATA
# =============================================================================

# Item represented by this entry.
@export var item: ItemDefinition

# Quantity of the item represented by this entry.
@export_range(1, 999999, 1) var amount: int = 1