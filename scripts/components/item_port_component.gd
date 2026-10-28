
extends Marker3D
class_name ItemPortComponent


# =============================================================================
# PORT DIRECTION
# =============================================================================

# INPUT receives items from connected transport systems.
# OUTPUT supplies items to connected transport systems.
#
# Each instance represents one physical connection point.

enum PortDirection {
	INPUT,
	OUTPUT
}

@export var direction: PortDirection = PortDirection.INPUT


# =============================================================================
# INPUT ACCEPTANCE POLICY
# =============================================================================

# RECIPE_INPUTS:
# The selected manufacturing recipe controls accepted items.
#
# ANY_ITEM:
# General-purpose storage accepts any valid item.
#
# Recipe-controlled is the safe default for machine inputs.

enum InputPolicy {
	RECIPE_INPUTS,
	ANY_ITEM
}

@export var input_policy: InputPolicy = InputPolicy.RECIPE_INPUTS


# =============================================================================
# COMPONENT REFERENCES
# =============================================================================

# The inventory attached to this physical port.
#
# Input ports normally reference a machine's InputInventory.
# Output ports normally reference OutputInventory.
#
# A storage building may reference its general inventory.

@export var inventory: InventoryComponent

# Optional for general storage and extractor output ports.
# Required when the input policy is RECIPE_INPUTS.

@export var producer_component: ProducerComponent

# =============================================================================
# PHYSICAL CONVEYOR CONNECTION STATE
# =============================================================================

# The conveyor physically attached to this port.
#
# Each physical port supports one conveyor connection.
# This is runtime state, not an Inspector configuration.
#
# OUTPUT port -> conveyor input
# INPUT port  <- conveyor output

var connected_conveyor: ConveyorSegment = null

# =============================================================================
# TEMPORARY BUILDING PORT VISUAL INDICATORS
# =============================================================================

# Displays IN or OUT above physical building ports.
#
# These are temporary development placeholders.
# They help identify connection points while our
# factory buildings still use simple box meshes.
#
# Can be disabled later when final 3D models
# have clearly identifiable input/output geometry.

@export var show_port_label: bool = true


# =============================================================================
# CREATE PORT LABEL
# =============================================================================

func _ready() -> void:

	if not show_port_label:
		return

	# Avoid creating duplicate visual labels.

	if has_node("PortDebugLabel"):
		return

	var port_label := Label3D.new()

	port_label.name = "PortDebugLabel"

	# =============================================================================
	# IDENTIFY PORT DIRECTION
	# =============================================================================

	if direction == PortDirection.INPUT:

		port_label.text = "IN"
		port_label.modulate = Color(0.2, 0.75, 1.0)

	else:

		port_label.text = "OUT"
		port_label.modulate = Color(1.0, 0.65, 0.15)

	# =============================================================================
	# CONFIGURE LABEL APPEARANCE
	# =============================================================================

	port_label.font_size = 32
	port_label.pixel_size = 0.012
	port_label.outline_size = 6

	# Always face the game camera.

	port_label.billboard = (
		BaseMaterial3D.BILLBOARD_ENABLED
	)

	# Position above the connection marker.

	port_label.position = Vector3(
		0.0,
		0.45,
		0.0
	)

	# No physics collision is added.
	# The label cannot interfere with conveyor
	# snapping, placement, or item transportation.

	add_child(port_label)


# =============================================================================
# INPUT PORT ACCEPTANCE CHECK
# =============================================================================

# Returns true only when the entire requested amount
# is eligible to enter the connected inventory.
#
# This method does not transfer or modify any items.
#
# Future conveyor systems must recheck these conditions
# when actually performing a transfer.

func can_accept_item(
	item: ItemDefinition,
	amount: int = 1
) -> bool:

	# Validate direction, item, quantity, and inventory.

	if direction != PortDirection.INPUT:
		return false

	if item == null or amount <= 0:
		return false

	if not is_instance_valid(inventory):
		return false

	# =============================================================================
	# APPLY INPUT POLICY
	# =============================================================================

	match input_policy:

		InputPolicy.RECIPE_INPUTS:

			# Manufacturing inputs require a valid producer.
			if not is_instance_valid(producer_component):
				return false

			# Protect against referencing the wrong inventory.
			if producer_component.input_inventory != inventory:
				return false

			# The active recipe determines ingredient eligibility.
			if not producer_component.accepts_input_item(item):
				return false

		InputPolicy.ANY_ITEM:
			pass

		_:
			return false

	# =============================================================================
	# CHECK INVENTORY CAPACITY
	# =============================================================================

	# Existing InventoryComponent uses total unit capacity.
	# -1 means unlimited.
	#
	# Future slot-based storage will require additional checks.

	var available_space: int = inventory.get_available_space()

	return available_space == -1 or available_space >= amount


# =============================================================================
# OUTPUT PORT AVAILABILITY CHECK
# =============================================================================

# Checks whether an output inventory contains the
# requested product quantity.
#
# Does not remove products from the source inventory.

func can_provide_item(
	item: ItemDefinition,
	amount: int = 1
) -> bool:

	if direction != PortDirection.OUTPUT:
		return false

	if item == null or amount <= 0:
		return false

	if not is_instance_valid(inventory):
		return false

	# When a producer is assigned, verify this output port
	# references its actual output inventory.

	if is_instance_valid(producer_component):
		if producer_component.output_inventory != inventory:
			return false

	return inventory.has_amount(item, amount)

# =============================================================================
# SAFE PORT-TO-PORT ITEM TRANSFER
# =============================================================================

# Attempts to move items from this OUTPUT port into
# another port configured as an INPUT.
#
# Safety rules:
# - Source must be an OUTPUT port.
# - Destination must be an INPUT port.
# - Ports must reference different inventories.
# - Source must contain the requested amount.
# - Destination must accept the item type.
# - Destination must have room for the full request.
#
# Existing InventoryComponent.transfer_to() handles
# the actual resource movement and accounting.
#
# Returns the number of items actually transferred.
# Returns 0 when validation fails.
#
# This method does not check whether physical conveyor
# connections exist. That will be handled separately.

func try_transfer_to_port(
	destination_port: ItemPortComponent,
	item: ItemDefinition,
	amount: int = 1
) -> int:

	# =============================================================================
	# VALIDATE PORTS AND DIRECTION
	# =============================================================================

	if not is_instance_valid(destination_port):
		return 0

	if destination_port == self:
		return 0

	if direction != PortDirection.OUTPUT:
		return 0

	if destination_port.direction != PortDirection.INPUT:
		return 0

	# =============================================================================
	# VALIDATE INVENTORY REFERENCES
	# =============================================================================

	if not is_instance_valid(inventory):
		return 0

	if not is_instance_valid(destination_port.inventory):
		return 0

	# Prevent removing and reinserting items into
	# the same inventory.

	if inventory == destination_port.inventory:
		return 0

	# =============================================================================
	# CHECK SOURCE AVAILABILITY
	# =============================================================================

	# Requires the source to contain the full amount.
	# Invalid items and quantities are rejected here.

	if not can_provide_item(item, amount):
		return 0

	# =============================================================================
	# CHECK DESTINATION ACCEPTANCE
	# =============================================================================

	# Validates the active recipe, correct inventory,
	# requested quantity, and destination capacity.

	if not destination_port.can_accept_item(item, amount):
		return 0

	# =============================================================================
	# EXECUTE INVENTORY TRANSFER
	# =============================================================================

	# The existing transfer function performs removal,
	# addition, capacity handling, and restoration of
	# any unexpectedly unaccepted items.
	#
	# Always return the actual amount moved.

	return inventory.transfer_to(
		destination_port.inventory,
		item,
		amount
	)

# =============================================================================
# PHYSICAL CONNECTION CLEANUP
# =============================================================================

# When a building is removed, its physical ports leave
# the scene tree and must clear their conveyor references.
#
# This does not remove inventory items.

func _exit_tree() -> void:

	if is_instance_valid(connected_conveyor):

		connected_conveyor.disconnect_building_port(
			self
		)

	connected_conveyor = null
