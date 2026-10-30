
extends RefCounted
class_name ConveyorBuildingTransfer


# =============================================================================
# BUILDING TO CONVEYOR TRANSFER
# =============================================================================

# Loads one item from a physically connected building
# output port into a conveyor cargo inventory.
#
# Works with any valid ItemDefinition.
#
# This helper does not run automatically.
# A future controller will schedule loading attempts.


# =============================================================================
# TRY LOAD ITEM FROM CONNECTED BUILDING
# =============================================================================

static func try_load_into_belt(
	belt: ConveyorSegment
) -> bool:

	# =============================================================================
	# VALIDATE CONVEYOR
	# =============================================================================

	if not is_instance_valid(belt):
		return false

	if not belt.is_inside_tree():
		return false

	if belt.is_queued_for_deletion():
		return false

	# =============================================================================
	# VALIDATE PHYSICAL BUILDING CONNECTION
	# =============================================================================

	var port: ItemPortComponent = (
		belt.input_building_port
	)

	if not is_instance_valid(port):
		return false

	if not port.is_inside_tree():
		return false

	if port.is_queued_for_deletion():
		return false

	if port.direction != ItemPortComponent.PortDirection.OUTPUT:
		return false

	# Both endpoints must agree about the connection.

	if port.connected_conveyor != belt:
		return false

	# The belt input cannot have two sources.

	if is_instance_valid(belt.previous_segment):
		return false

	if not is_instance_valid(port.inventory):
		return false

	# =============================================================================
	# VALIDATE CURRENT PHYSICAL ALIGNMENT
	# =============================================================================

	var belt_input: Marker3D = (
		belt.get_node_or_null("InputEndpoint")
		as Marker3D
	)

	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		port,
		belt_input,
		ConveyorSegment.CONNECTION_GAP
	):
		return false

	# =============================================================================
	# FIND CONVEYOR CARGO COMPONENT
	# =============================================================================

	var transport: ConveyorTransportComponent = (
		belt.get_node_or_null(
			"ConveyorTransportComponent"
		) as ConveyorTransportComponent
	)

	if not is_instance_valid(transport):
		return false

	if not is_instance_valid(transport.cargo_inventory):
		return false

	if transport.cargo_inventory == port.inventory:
		return false

	# =============================================================================
	# FIND AN AVAILABLE ITEM
	# =============================================================================

	# The building inventory can contain multiple
	# different ItemDefinition resources.
	#
	# Do not hardcode Test Ore, Test Ingots,
	# copper, ammunition, or other item names.
	#
	# Current prototype: choose the first eligible
	# inventory entry. Item priority can be designed
	# later for multi-item building outputs.

	for stored_key in port.inventory.items.keys():

		var item: ItemDefinition = (
			stored_key as ItemDefinition
		)

		if item == null:
			continue

		# The existing output port validates
		# quantity and producer inventory ownership.

		if not port.can_provide_item(item, 1):
			continue

		# =============================================================================
		# TRANSFER ONE ITEM
		# =============================================================================

		# The transport component enforces the
		# one-item cargo capacity.
		#
		# InventoryComponent.transfer_to() handles
		# safe inventory accounting.

		return transport.try_receive_from_inventory(
			port.inventory,
			item
		)

	# No eligible item was available.

	return false

# =============================================================================
# CONVEYOR TO BUILDING UNLOADING
# =============================================================================

# Transfers one item from a physically connected conveyor
# into a building's input inventory.
#
# The receiving building controls item acceptance.
# Recipe-controlled machines reject unwanted items.
# Universal storage accepts any valid item type.
#
# This is a manual transfer, not automatic processing.


static func try_unload_from_belt(
	belt: ConveyorSegment
) -> bool:

	# =============================================================================
	# VALIDATE CONVEYOR
	# =============================================================================

	if not is_instance_valid(belt):
		return false

	if not belt.is_inside_tree():
		return false

	if belt.is_queued_for_deletion():
		return false

	# =============================================================================
	# VALIDATE BUILDING INPUT CONNECTION
	# =============================================================================

	var port: ItemPortComponent = belt.output_building_port

	if not is_instance_valid(port):
		return false

	if not port.is_inside_tree():
		return false

	if port.is_queued_for_deletion():
		return false

	if port.direction != ItemPortComponent.PortDirection.INPUT:
		return false

	if port.connected_conveyor != belt:
		return false

	# Prevent competing output connections.

	if is_instance_valid(belt.next_segment):
		return false

	if not is_instance_valid(port.inventory):
		return false

	# =============================================================================
	# VALIDATE PHYSICAL ENDPOINT ALIGNMENT
	# =============================================================================

	var belt_output: Marker3D = (
		belt.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		belt_output,
		port,
		ConveyorSegment.CONNECTION_GAP
	):
		return false

	# =============================================================================
	# FIND CONVEYOR TRANSPORT COMPONENT
	# =============================================================================

	var transport: ConveyorTransportComponent = (
		belt.get_node_or_null("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)

	if not is_instance_valid(transport):
		return false

	if not is_instance_valid(transport.cargo_inventory):
		return false

	# =============================================================================
	# IDENTIFY TRANSPORTED ITEM
	# =============================================================================

	var item: ItemDefinition = transport.get_held_item()

	if item == null:
		return false

	if port.inventory == transport.cargo_inventory:
		return false

	# =============================================================================
	# VALIDATE RECEIVING BUILDING
	# =============================================================================

	# The building's input policy determines whether
	# this item can enter its inventory.
	#
	# Machines check their currently selected recipe.
	# Universal storage accepts all valid items.
	#
	# Also checks destination inventory capacity.

	if not port.can_accept_item(item, 1):
		return false

	# =============================================================================
	# TRANSFER ONE ITEM SAFELY
	# =============================================================================

	# Existing InventoryComponent handles resource
	# conservation and destination capacity.

	var transferred: int = (
		transport.cargo_inventory.transfer_to(
			port.inventory,
			item,
			1
		)
	)

	return transferred == 1
