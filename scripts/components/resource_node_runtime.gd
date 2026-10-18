extends Node
class_name ResourceNodeRuntime


# =============================================================================
# RESOURCE NODE DEFINITION
# =============================================================================

@export var definition: ResourceNodeDefinition


# =============================================================================
# RUNTIME STATE
# =============================================================================

var remaining_amount: int = 0


# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	if definition == null:
		push_warning("ResourceNodeRuntime has no ResourceNodeDefinition assigned.")
		return

	remaining_amount = definition.starting_amount

	print(
		"Resource node initialized: ",
		definition.display_name,
		" | Remaining: ",
		remaining_amount
	)

# =============================================================================
# RESOURCE EXTRACTION
# =============================================================================

# Attempts to extract the requested amount of resource from this node.
# Returns the amount that was actually extracted.

func extract(amount: int) -> int:
	if definition == null:
		return 0

	if definition.resource_item == null:
		return 0

	if amount <= 0:
		return 0

	if definition.infinite_resource:
		return amount

	var extracted_amount: int = min(amount, remaining_amount)

	remaining_amount -= extracted_amount

	return extracted_amount
