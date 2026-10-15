extends Node
class_name ProducerComponent


# =============================================================================
# PRODUCTION SETTINGS
# =============================================================================

# Recipe executed by this producer.
@export var recipe: ProductionRecipe


# =============================================================================
# RUNTIME STATE
# =============================================================================

# Inventory that receives produced items and will later supply recipe inputs.
var inventory_component: InventoryComponent = null

# Tracks elapsed time through the current production cycle.
var production_progress: float = 0.0


# =============================================================================
# INITIALIZATION
# =============================================================================

# Locates the InventoryComponent belonging to the same building.

func _ready() -> void:
	inventory_component = (
		get_parent().get_node_or_null("InventoryComponent") as InventoryComponent
	)


# =============================================================================
# PRODUCTION UPDATE
# =============================================================================

# Advances production while a valid recipe and inventory are available.

func _process(delta: float) -> void:
	if recipe == null:
		return

	if inventory_component == null:
		return

	if recipe.production_time <= 0.0:
		return

	production_progress += delta

	if production_progress < recipe.production_time:
		return

	production_progress -= recipe.production_time
	_produce_outputs()


# =============================================================================
# PRODUCE OUTPUTS
# =============================================================================

# Adds each output defined by the active recipe to the building inventory.

func _produce_outputs() -> void:
	for output in recipe.outputs:
		if output == null:
			continue

		if output.item == null:
			continue

		if output.amount <= 0:
			continue

		inventory_component.add_item(
			output.item,
			output.amount
		)

	
