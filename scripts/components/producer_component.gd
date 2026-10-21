extends Node
class_name ProducerComponent


# =============================================================================
# PRODUCTION SETTINGS
# =============================================================================

# Recipe executed by this producer.
@export var recipe: ProductionRecipe

# =============================================================================
# INPUT INVENTORY REFERENCE
# =============================================================================

# Inventory containing the raw materials required by the recipe.
#
# This reference will be assigned to the Test Smelter's
# dedicated InputInventory node in the Godot Inspector.
#
# Input and output inventories will remain separate so
# stored raw materials do not compete with finished items.

@export var input_inventory: InventoryComponent

# =============================================================================
# OUTPUT INVENTORY REFERENCE
# =============================================================================

# Inventory that receives completed manufactured products.
#
# This is separate from the input inventory so raw materials
# and finished products have independent storage capacities.
#
# The Test Smelter will assign its OutputInventory node
# through the Godot Inspector.

@export var output_inventory: InventoryComponent
# =============================================================================
# RUNTIME STATE
# =============================================================================

# Tracks elapsed time through the current production cycle.
var production_progress: float = 0.0

# Describes the current manufacturing condition.
#
# The Production Debug HUD will use this information
# to show whether the machine is actively producing,
# waiting for inputs, or blocked by output capacity.

var production_status: String = "Initializing"

# =============================================================================
# RECIPE INPUT AVAILABILITY
# =============================================================================

# Checks whether the input inventory contains all materials
# required to complete one production recipe.
#
# This function only checks availability.
# It does NOT remove, consume, or modify inventory items.
#
# Returns:
# true  = All required inputs are available.
# false = Missing inventory, missing resources, or invalid inputs.

func has_required_inputs() -> bool:

	# =============================================================================
	# VALIDATE RECIPE AND INVENTORY
	# =============================================================================

	# A recipe must be assigned.
	if recipe == null:
		return false

	# The machine must have a valid input inventory.
	if not is_instance_valid(input_inventory):
		return false

	# For our manufacturing system, an empty input list
	# must not permit unlimited free production.
	if recipe.inputs.is_empty():
		return false

	# =============================================================================
	# COLLECT REQUIRED MATERIALS
	# =============================================================================

	# Store the total amount required for each item.
	#
	# If an item appears twice in a recipe, its requirements
	# must be combined before checking availability.

	var required_items: Dictionary = {}

	for input in recipe.inputs:

		# Reject missing or invalid recipe entries.
		if input == null:
			return false

		if input.item == null:
			return false

		if input.amount <= 0:
			return false

		# Get the amount already required for this item.
		var current_requirement: int = int(
			required_items.get(input.item, 0)
		)

		# Add the amount from this recipe entry.
		required_items[input.item] = (
			current_requirement + input.amount
		)

	# =============================================================================
	# CHECK INVENTORY QUANTITIES
	# =============================================================================

	# Every ingredient must have enough available quantity.
	for item in required_items.keys():

		var required_amount: int = int(required_items[item])

		if not input_inventory.has_amount(
			item as ItemDefinition,
			required_amount
		):
			return false

	# =============================================================================
	# ALL INPUTS AVAILABLE
	# =============================================================================

	# No inventory quantities have been changed.
	return true

# =============================================================================
# RECIPE OUTPUT CAPACITY CHECK
# =============================================================================

# Determines whether the output inventory has enough room
# to store every item produced by one recipe cycle.
#
# All outputs must fit before production is permitted.
#
# This function performs availability checks only.
# It does not add or remove items from either inventory.
#
# Returns:
# true  = All recipe outputs can fit.
# false = Missing inventory, invalid recipe, or insufficient space.

func can_store_recipe_outputs() -> bool:

	# =============================================================================
	# VALIDATE RECIPE AND OUTPUT INVENTORY
	# =============================================================================

	if recipe == null:
		return false

	if not is_instance_valid(output_inventory):
		return false

	# A manufacturing recipe must define at least one output.
	if recipe.outputs.is_empty():
		return false

	# =============================================================================
	# CALCULATE REQUIRED OUTPUT CAPACITY
	# =============================================================================

	# Capacity is shared between all item types stored within
	# this particular output inventory.
	#
	# Example:
	# 2 Iron Plates + 3 Copper Wires = 5 required spaces.

	var required_capacity: int = 0

	for output in recipe.outputs:

		# Reject invalid recipe entries.
		if output == null:
			return false

		if output.item == null:
			return false

		if output.amount <= 0:
			return false

		# Add the quantity of each output to the total.
		required_capacity += output.amount

	# =============================================================================
	# CHECK AVAILABLE OUTPUT SPACE
	# =============================================================================

	var available_space: int = output_inventory.get_available_space()

	# An available space value of -1 represents unlimited
	# inventory capacity.
	if available_space == -1:
		return true

	# Reject production if any outputs would not fit.
	if available_space < required_capacity:
		return false

	# =============================================================================
	# OUTPUT CAPACITY AVAILABLE
	# =============================================================================

	# All finished products can fit in the output inventory.
	return true

# =============================================================================
# SAFE MANUFACTURING TRANSACTION
# =============================================================================

# Attempts to complete one entire production recipe.
#
# The input and output inventories must be separate.
#
# Before changing inventory quantities, this function:
# - Verifies all required inputs are available.
# - Verifies all finished outputs can fit.
# - Rejects configurations sharing the same inventory.
#
# If an unexpected removal or addition fails, the function
# attempts to restore the inventory to its previous state.
#
# Returns true only when the complete recipe succeeds.
#
# This function will be connected to the production timer
# after our isolated manufacturing tests pass.

func try_complete_recipe_cycle() -> bool:

	# =============================================================================
	# VALIDATE INVENTORY REFERENCES
	# =============================================================================

	if not is_instance_valid(input_inventory):
		return false

	if not is_instance_valid(output_inventory):
		return false

	# Manufacturing requires separate input and output storage.
	if input_inventory == output_inventory:
		return false

	# =============================================================================
	# VALIDATE RECIPE REQUIREMENTS
	# =============================================================================

	if not has_required_inputs():
		return false

	if not can_store_recipe_outputs():
		return false

	# =============================================================================
	# COMBINE REQUIRED INPUT QUANTITIES
	# =============================================================================

	# An ingredient may appear more than once in a recipe.
	# Combine its quantities before attempting consumption.

	var required_inputs: Dictionary = {}

	for input_entry in recipe.inputs:
		var current_amount: int = int(
			required_inputs.get(input_entry.item, 0)
		)

		required_inputs[input_entry.item] = (
			current_amount + input_entry.amount
		)

	# =============================================================================
	# CONSUME RECIPE INPUTS
	# =============================================================================

	# Tracks successful removals so they can be restored
	# if any later operation fails.

	var consumed_inputs: Dictionary = {}

	for item_key in required_inputs.keys():

		var item: ItemDefinition = item_key as ItemDefinition
		var amount: int = int(required_inputs[item_key])

		if not input_inventory.remove_item(item, amount):
			_rollback_recipe_cycle(consumed_inputs, {})
			return false

		consumed_inputs[item] = amount

	# =============================================================================
	# CREATE FINISHED PRODUCTS
	# =============================================================================

	# Tracks successfully added outputs for failure recovery.

	var produced_outputs: Dictionary = {}

	for output_entry in recipe.outputs:

		var item: ItemDefinition = output_entry.item
		var requested_amount: int = output_entry.amount

		var accepted_amount: int = output_inventory.add_item(
			item,
			requested_amount
		)

		if accepted_amount > 0:
			produced_outputs[item] = (
				int(produced_outputs.get(item, 0))
				+ accepted_amount
			)

		# Any rejected output means the complete recipe failed.
		if accepted_amount != requested_amount:

			_rollback_recipe_cycle(
				consumed_inputs,
				produced_outputs
			)

			push_warning(
				"Manufacturing transaction failed: output rejected."
			)

			return false

	# =============================================================================
	# MANUFACTURING SUCCESS
	# =============================================================================

	# All inputs were consumed and all outputs were stored.
	return true


# =============================================================================
# MANUFACTURING TRANSACTION ROLLBACK
# =============================================================================

# Reverses inventory changes if a production cycle fails.
#
# Finished outputs are removed first, then consumed inputs
# are returned to the input inventory.
#
# InventoryComponent operations are synchronous, so no
# other operation should interleave during this rollback.

func _rollback_recipe_cycle(
	consumed_inputs: Dictionary,
	produced_outputs: Dictionary
) -> void:

	# =============================================================================
	# REMOVE PARTIALLY PRODUCED OUTPUTS
	# =============================================================================

	for item_key in produced_outputs.keys():

		var item: ItemDefinition = item_key as ItemDefinition
		var amount: int = int(produced_outputs[item_key])

		if not output_inventory.remove_item(item, amount):
			push_error(
				"Manufacturing rollback failed to remove an output."
			)

	# =============================================================================
	# RESTORE CONSUMED INPUTS
	# =============================================================================

	for item_key in consumed_inputs.keys():

		var item: ItemDefinition = item_key as ItemDefinition
		var amount: int = int(consumed_inputs[item_key])

		var restored_amount: int = input_inventory.add_item(
			item,
			amount
		)

		if restored_amount != amount:
			push_error(
				"Manufacturing rollback failed to restore an input."
			)


# =============================================================================
# PRODUCTION UPDATE
# =============================================================================

# Advances manufacturing progress each frame.
#
# A manufacturing cycle can begin only when:
# - A valid recipe exists.
# - Separate input and output inventories are assigned.
# - All required inputs are available.
# - All finished outputs can fit.
#
# Resources are consumed only when a completed cycle
# successfully executes try_complete_recipe_cycle().
#
# The progress timer resets when production is blocked.

func _process(delta: float) -> void:

	# =============================================================================
	# VALIDATE PRODUCTION RECIPE
	# =============================================================================

	if recipe == null:
		_stop_production("No Recipe")
		return

	if recipe.production_time <= 0.0:
		_stop_production("Invalid Recipe")
		return

	if recipe.inputs.is_empty() or recipe.outputs.is_empty():
		_stop_production("Invalid Recipe")
		return

	# =============================================================================
	# VALIDATE INVENTORY REFERENCES
	# =============================================================================

	if not is_instance_valid(input_inventory):
		_stop_production("Input Inventory Missing")
		return

	if not is_instance_valid(output_inventory):
		_stop_production("Output Inventory Missing")
		return

	if input_inventory == output_inventory:
		_stop_production("Invalid Inventory Setup")
		return

	# =============================================================================
	# CHECK REQUIRED INPUTS
	# =============================================================================

	# Do not advance the production timer when ingredients
	# are missing or insufficient.

	if not has_required_inputs():
		_stop_production("Waiting for Inputs")
		return

	# =============================================================================
	# CHECK OUTPUT INVENTORY CAPACITY
	# =============================================================================

	# Every finished item must fit in output storage.
	# Production stops until sufficient space is available.

	if not can_store_recipe_outputs():
		_stop_production("Output Blocked")
		return

	# =============================================================================
	# ADVANCE PRODUCTION TIMER
	# =============================================================================

	# All manufacturing requirements are satisfied.
	production_status = "Producing"

	production_progress += delta

	# Continue processing until one full cycle completes.
	if production_progress < recipe.production_time:
		return

	# =============================================================================
	# COMPLETE MANUFACTURING CYCLE
	# =============================================================================

	# The transaction rechecks requirements immediately
	# before consuming ingredients and creating outputs.

	if try_complete_recipe_cycle():

		# Reset the progress timer for the next cycle.
		production_progress = 0.0
		return

	# If an unexpected condition prevents completion,
	# reset the timer and report the failure.
	_stop_production("Cycle Failed")


# =============================================================================
# STOP PRODUCTION
# =============================================================================

# Resets manufacturing progress when a machine cannot run.
#
# This keeps the future progress bar synchronized with
# actual manufacturing activity.
#
# No items are consumed or produced by this function.

func _stop_production(reason: String) -> void:

	production_progress = 0.0
	production_status = reason
