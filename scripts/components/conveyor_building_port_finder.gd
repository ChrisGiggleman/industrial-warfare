
extends RefCounted
class_name ConveyorBuildingPortFinder


# =============================================================================
# CHAT 08.3F-2A — BUILDING PORT DISCOVERY
# =============================================================================

# Searches existing player-built structures for
# compatible physical conveyor connection ports.
#
# Supports:
# - Building OUTPUT -> Conveyor INPUT
# - Conveyor OUTPUT -> Building INPUT
# - Rotated buildings
# - Port occupancy restrictions
# - Player-selected conveyor direction
#
# Does not create connections or move items.


# =============================================================================
# FIND NEAREST BUILDING PORT SNAP
# =============================================================================

static func find_nearest_preview(
	preview_belt: ConveyorSegment,
	mouse_world_position: Vector3,
	search_radius: float = 1.25
) -> Dictionary:

	# =============================================================================
	# VALIDATE PREVIEW
	# =============================================================================

	if not is_instance_valid(preview_belt):
		return {}

	if not preview_belt.is_inside_tree():
		return {}

	if preview_belt.is_queued_for_deletion():
		return {}

	if search_radius <= 0.0:
		return {}

	# =============================================================================
	# PRESERVE PLAYER-SELECTED DIRECTION
	# =============================================================================

	# The player's R rotation controls which way
	# the new conveyor should face.
	#
	# Reject any snap transform that would silently
	# change the requested travel direction.

	var requested_forward: Vector3 = (
		preview_belt.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	# =============================================================================
	# INITIALIZE NEAREST CANDIDATE
	# =============================================================================

	var best_preview: Dictionary = {}

	var best_distance_squared: float = (
		search_radius * search_radius
	)

	# =============================================================================
	# SEARCH PLAYER-BUILT STRUCTURES
	# =============================================================================

	for candidate: Node in (
		preview_belt.get_tree().get_nodes_in_group(
			"player_built"
		)
	):

		if candidate == preview_belt:
			continue

		if not candidate is Node3D:
			continue

		if candidate.is_queued_for_deletion():
			continue

		# Placement ghosts must never be treated
		# as real, available building ports.

		if candidate.process_mode == Node.PROCESS_MODE_DISABLED:
			continue

		# =============================================================================
		# INSPECT BUILDING PORTS
		# =============================================================================

		# Existing Extractor and Smelter ports are
		# direct children of their building roots.
		#
		# Future Storage ports will follow the same
		# component arrangement.

		for child: Node in candidate.get_children():

			if not child is ItemPortComponent:
				continue

			var port: ItemPortComponent = (
				child as ItemPortComponent
			)

			# =============================================================================
			# GET SAFE SNAP TRANSFORM
			# =============================================================================

			# Reuse our already-tested helper.
			#
			# It rejects unavailable ports, occupied
			# belt endpoints, and invalid references.

			var preview: Dictionary = (
				ConveyorBuildingSnap.get_preview_transform(
					port,
					preview_belt
				)
			)

			if preview.is_empty():
				continue

			var proposed: Transform3D = (
				preview["transform"]
			)

			# =============================================================================
			# VERIFY REQUESTED ROTATION
			# =============================================================================

			var proposed_forward: Vector3 = (
				proposed.basis
				* Vector3.FORWARD
			).normalized()

			if requested_forward.dot(
				proposed_forward
			) < 0.98:
				continue

			# =============================================================================
			# MEASURE HORIZONTAL MOUSE DISTANCE
			# =============================================================================

			# Use X/Z just like our existing
			# conveyor-to-conveyor snap finder.
			#
			# The proposed placement origin is compared
			# against the mouse's snapped grid position.

			var offset: Vector2 = Vector2(
				mouse_world_position.x - proposed.origin.x,
				mouse_world_position.z - proposed.origin.z
			)

			var distance_squared: float = (
				offset.length_squared()
			)

			if distance_squared >= best_distance_squared:
				continue

			# =============================================================================
			# STORE BEST AVAILABLE CONNECTION
			# =============================================================================

			best_distance_squared = distance_squared

			best_preview = {
				"port": port,
				"transform": proposed,
				"distance_squared": distance_squared
			}

	# =============================================================================
	# RETURN NEAREST VALID BUILDING CONNECTION
	# =============================================================================

	return best_preview
