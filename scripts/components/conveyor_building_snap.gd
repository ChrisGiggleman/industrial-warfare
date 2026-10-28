
extends RefCounted
class_name ConveyorBuildingSnap


# =============================================================================
# BUILDING-TO-CONVEYOR SNAP PREVIEW
# =============================================================================

# Calculates a conveyor placement transform using
# an existing building's physical ItemPortComponent.
#
# Supports:
# - Building OUTPUT -> Conveyor INPUT
# - Conveyor OUTPUT -> Building INPUT
# - Rotated buildings
# - Any valid item type
#
# This helper never moves buildings, changes inventories,
# creates connections or transfers items.


# =============================================================================
# CALCULATE SNAP TRANSFORM
# =============================================================================

static func get_preview_transform(
	port: ItemPortComponent,
	belt: ConveyorSegment
) -> Dictionary:

	# =============================================================================
	# VALIDATE OBJECTS
	# =============================================================================

	if not is_instance_valid(port):
		return {}

	if not is_instance_valid(belt):
		return {}

	if not port.is_inside_tree():
		return {}

	if not belt.is_inside_tree():
		return {}

	if port.is_queued_for_deletion():
		return {}

	if belt.is_queued_for_deletion():
		return {}

	if not is_instance_valid(port.inventory):
		return {}

	# =============================================================================
	# REJECT ALREADY CONNECTED BUILDING PORTS
	# =============================================================================

	# One building port can connect to only one conveyor.
	# An occupied port must not offer another snap preview.

	if is_instance_valid(port.connected_conveyor):
		return {}

	# =============================================================================
	# SELECT CONVEYOR ENDPOINT
	# =============================================================================

	var endpoint: Marker3D = null

	match port.direction:

		ItemPortComponent.PortDirection.OUTPUT:

			# The building supplies the conveyor.
			# Its output must face the conveyor input.

			if is_instance_valid(belt.previous_segment):
				return {}

			# The belt input may already be connected
			# directly to another building's output.

			if is_instance_valid(belt.input_building_port):
				return {}

			endpoint = (
				belt.get_node_or_null("InputEndpoint")
				as Marker3D
			)

		ItemPortComponent.PortDirection.INPUT:

			# The conveyor supplies the building.
			# Its output must face the building input.

			if is_instance_valid(belt.next_segment):
				return {}

			# The belt output may already be connected
			# directly to another building's input.

			if is_instance_valid(belt.output_building_port):
				return {}

			endpoint = (
				belt.get_node_or_null("OutputEndpoint")
				as Marker3D
			)

		_:
			return {}

	if not is_instance_valid(endpoint):
		return {}

	# =============================================================================
	# CALCULATE OPPOSITE-FACING ENDPOINT ORIENTATION
	# =============================================================================

	# Connected endpoints must face one another.
	#
	# The desired belt endpoint orientation is the
	# building port orientation rotated 180 degrees.
	#
	# Compensate for the belt endpoint's own local
	# rotation to calculate the conveyor root basis.

	var desired_endpoint_basis: Basis = (
		port.global_transform.basis.orthonormalized()
		* Basis(Vector3.UP, PI)
	)

	var preview_basis: Basis = (
		desired_endpoint_basis
		* endpoint.transform.basis.inverse()
	).orthonormalized()

	# =============================================================================
	# ALIGN ENDPOINT POSITIONS
	# =============================================================================

	# Position the conveyor root so the selected
	# conveyor endpoint exactly meets the building port.
	#
	# Works regardless of building world rotation.

	var preview_position: Vector3 = (
		port.global_position
		- preview_basis * endpoint.position
	)

	# =============================================================================
	# RETURN READ-ONLY PLACEMENT PREVIEW
	# =============================================================================

	return {
		"transform": Transform3D(
			preview_basis,
			preview_position
		)
	}
