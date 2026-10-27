
extends RefCounted
class_name ConveyorTransportLink


# =============================================================================
# CONNECTED CONVEYOR ITEM TRANSFER
# =============================================================================

# Transfers one item from a conveyor to its next
# physically connected conveyor.
#
# This method validates conveyor direction, connection
# references, endpoint alignment and cargo components.
#
# No automatic timing is implemented yet.


static func try_transfer_forward(
	source: ConveyorSegment
) -> bool:

	# =============================================================================
	# VALIDATE SOURCE SEGMENT
	# =============================================================================

	if not is_instance_valid(source):
		return false

	if source.is_queued_for_deletion():
		return false

	if not source.is_inside_tree():
		return false

	# =============================================================================
	# VALIDATE DIRECTED CONNECTION
	# =============================================================================

	var destination: ConveyorSegment = source.next_segment

	if not is_instance_valid(destination):
		return false

	if destination.is_queued_for_deletion():
		return false

	if not destination.is_inside_tree():
		return false

	if destination == source:
		return false

	# Both segments must agree about the connection.

	if destination.previous_segment != source:
		return false

	# =============================================================================
	# VALIDATE PHYSICAL ENDPOINT ALIGNMENT
	# =============================================================================

	var outgoing: Marker3D = (
		source.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var incoming: Marker3D = (
		destination.get_node_or_null("InputEndpoint") as Marker3D
	)

	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		outgoing,
		incoming,
		ConveyorSegment.CONNECTION_GAP
	):
		return false

	# =============================================================================
	# FIND TRANSPORT COMPONENTS
	# =============================================================================

	var source_transport: ConveyorTransportComponent = (
		source.get_node_or_null("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)

	var destination_transport: ConveyorTransportComponent = (
		destination.get_node_or_null("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)

	if not is_instance_valid(source_transport):
		return false

	if not is_instance_valid(destination_transport):
		return false

	# =============================================================================
	# EXECUTE SAFE ITEM TRANSFER
	# =============================================================================

	# The existing cargo buffer component handles
	# occupancy, capacity and resource conservation.

	return source_transport.try_move_to_buffer(
		destination_transport
	)
