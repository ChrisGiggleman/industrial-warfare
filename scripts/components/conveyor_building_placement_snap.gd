
extends RefCounted
class_name ConveyorBuildingPlacementSnap


# =============================================================================
# CHAT 08.3F-2E — BUILDING PLACEMENT AGAINST CONVEYORS
# =============================================================================

# Calculates where an unplaced building should snap
# to an existing conveyor's available endpoint.
#
# Supports:
# - Conveyor OUTPUT -> Building INPUT
# - Building OUTPUT -> Conveyor INPUT
# - Rotated buildings
# - Multiple building port types
# - Occupied connection protection
#
# Uses the player's selected building rotation.
#
# This helper does not move buildings, create links,
# modify inventories, or bypass collision checks.


# =============================================================================
# FIND NEAREST BUILDING PLACEMENT PREVIEW
# =============================================================================

static func find_nearest_preview(
	building: Node3D,
	mouse_world_position: Vector3,
	search_radius: float = 1.5
) -> Dictionary:

	# =============================================================================
	# VALIDATE BUILDING
	# =============================================================================

	if not is_instance_valid(building):
		return {}

	if not building.is_inside_tree():
		return {}

	if building.is_queued_for_deletion():
		return {}

	if search_radius <= 0.0:
		return {}

	var best_result: Dictionary = {}
	var best_distance_squared: float = (
		search_radius * search_radius
	)

	var building_basis: Basis = (
		building.global_transform.basis.orthonormalized()
	)

	# =============================================================================
	# SEARCH EXISTING CONVEYORS
	# =============================================================================

	for node: Node in building.get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		var belt := node as ConveyorSegment

		if belt.is_queued_for_deletion():
			continue

		# Ignore temporary construction ghosts.

		if belt.process_mode == Node.PROCESS_MODE_DISABLED:
			continue

		# =============================================================================
		# SEARCH BUILDING PORTS
		# =============================================================================

		for child: Node in building.get_children():

			if not child is ItemPortComponent:
				continue

			var port := child as ItemPortComponent

			if not is_instance_valid(port.inventory):
				continue

			if is_instance_valid(port.connected_conveyor):
				continue

			# =============================================================================
			# IDENTIFY AVAILABLE CONVEYOR ENDPOINT
			# =============================================================================

			var endpoint: Marker3D = null

			match port.direction:

				ItemPortComponent.PortDirection.INPUT:

					# Conveyor supplies the building.

					if is_instance_valid(belt.next_segment):
						continue

					if is_instance_valid(
						belt.output_building_port
					):
						continue

					endpoint = (
						belt.get_node_or_null("OutputEndpoint")
						as Marker3D
					)

				ItemPortComponent.PortDirection.OUTPUT:

					# Building supplies the conveyor.

					if is_instance_valid(belt.previous_segment):
						continue

					if is_instance_valid(
						belt.input_building_port
					):
						continue

					endpoint = (
						belt.get_node_or_null("InputEndpoint")
						as Marker3D
					)

				_:
					continue

			if not is_instance_valid(endpoint):
				continue

			# =============================================================================
			# VALIDATE ENDPOINT FACING
			# =============================================================================

			# A valid connection requires the building
			# port and conveyor endpoint to face opposite
			# directions.
			#
			# Do not automatically change the player's
			# selected building rotation.

			var port_forward: Vector3 = (
				port.global_transform.basis
				* Vector3.FORWARD
			).normalized()

			var belt_forward: Vector3 = (
				endpoint.global_transform.basis
				* Vector3.FORWARD
			).normalized()

			if port_forward.dot(belt_forward) > -0.98:
				continue

			# =============================================================================
			# CALCULATE BUILDING POSITION
			# =============================================================================

			# The ports in our current buildings are
			# direct children of the building root.
			#
			# Position the root so its chosen port lands
			# exactly on the conveyor endpoint.

			var proposed_position: Vector3 = (
				endpoint.global_position
				- building_basis * port.position
			)

			var proposed_transform := Transform3D(
				building_basis,
				proposed_position
			)

			# =============================================================================
			# MEASURE DISTANCE TO PLAYER'S MOUSE
			# =============================================================================

			var offset := Vector2(
				mouse_world_position.x - proposed_position.x,
				mouse_world_position.z - proposed_position.z
			)

			var distance_squared: float = (
				offset.length_squared()
			)

			if distance_squared >= best_distance_squared:
				continue

			# =============================================================================
			# SAVE NEAREST COMPATIBLE CONNECTION
			# =============================================================================

			best_distance_squared = distance_squared

			best_result = {
				"belt": belt,
				"port": port,
				"transform": proposed_transform,
				"distance_squared": distance_squared
			}

	return best_result
