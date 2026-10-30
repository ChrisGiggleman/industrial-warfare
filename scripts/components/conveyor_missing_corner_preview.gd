
extends RefCounted
class_name ConveyorMissingCornerPreview


# =============================================================================
# AUTOMATIC MISSING CORNER DISCOVERY
# =============================================================================

# Finds an exact one-tile corner between two existing belts.
#
# Directed flow:
# Source -> New Corner -> Destination
#
# This helper is read-only.
# It does not:
# - Create or move existing conveyors
# - Establish connections
# - Modify inventories
# - Change collision shapes
#
# Geometry and occupancy must both be valid.


# =============================================================================
# CHECK A SPECIFIC SOURCE, DESTINATION, AND TURN
# =============================================================================

static func preview_for_pair(
	source: ConveyorSegment,
	destination: ConveyorSegment,
	turn: int
) -> Dictionary:

	if not is_instance_valid(source):
		return {}

	if not is_instance_valid(destination):
		return {}

	if source == destination:
		return {}

	for belt: ConveyorSegment in [source, destination]:
		if not belt.is_inside_tree():
			return {}

		if belt.is_queued_for_deletion():
			return {}

		if belt.is_in_group("construction_preview"):
			return {}

	# Both endpoints must be free.
	# Existing upstream and downstream connections
	# are allowed.

	if is_instance_valid(source.next_segment):
		return {}

	if is_instance_valid(source.output_building_port):
		return {}

	if is_instance_valid(destination.previous_segment):
		return {}

	if is_instance_valid(destination.input_building_port):
		return {}

	if (
		turn != ConveyorTurnIntent.Turn.RIGHT
		and turn != ConveyorTurnIntent.Turn.LEFT
	):
		return {}

	var source_output := (
		source.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var destination_input := (
		destination.get_node_or_null("InputEndpoint") as Marker3D
	)

	if source_output == null or destination_input == null:
		return {}

	# =============================================================================
	# LOAD CORNER ENDPOINT TEMPLATE
	# =============================================================================

	var corner_scene: PackedScene = (
		ConveyorPieceSelector.get_scene_for_turn(turn)
	)

	if corner_scene == null:
		return {}

	var corner := (
		corner_scene.instantiate() as ConveyorSegment
	)

	if corner == null:
		return {}

	var corner_input := (
		corner.get_node_or_null("InputEndpoint") as Marker3D
	)

	var corner_output := (
		corner.get_node_or_null("OutputEndpoint") as Marker3D
	)

	if corner_input == null or corner_output == null:
		corner.free()
		return {}

	# =============================================================================
	# CALCULATE VIRTUAL CORNER TRANSFORM
	# =============================================================================

	# Match the new corner's input to the source output.
	# Use actual physical endpoints, not rounded mouse
	# positions or guessed offsets.

	var corner_basis: Basis = (
		source_output.global_transform.basis.orthonormalized()
	)

	var corner_position: Vector3 = (
		source_output.global_position
		- corner_basis * corner_input.position
	)

	var corner_transform := Transform3D(
		corner_basis,
		corner_position
	)

	var proposed_input: Transform3D = (
		corner_transform * corner_input.transform
	)

	var proposed_output: Transform3D = (
		corner_transform * corner_output.transform
	)

	corner.free()

	# =============================================================================
	# VALIDATE BOTH PHYSICAL CONNECTIONS
	# =============================================================================

	if not ConveyorDualEndedBridge._transforms_align(
		source_output.global_transform,
		proposed_input
	):
		return {}

	if not ConveyorDualEndedBridge._transforms_align(
		proposed_output,
		destination_input.global_transform
	):
		return {}

	return {
		"source": source,
		"destination": destination,
		"turn": turn,
		"transform": corner_transform
	}


# =============================================================================
# FIND NEAREST MISSING CORNER
# =============================================================================

static func find_nearest(
	tree: SceneTree,
	mouse_position: Vector3,
	search_radius: float = 0.75
) -> Dictionary:

	if tree == null:
		return {}

	if search_radius <= 0.0:
		return {}

	var belts: Array[ConveyorSegment] = []

	for node: Node in tree.get_nodes_in_group("player_built"):

		if not node is ConveyorSegment:
			continue

		var belt := node as ConveyorSegment

		if not belt.is_inside_tree():
			continue

		if belt.is_queued_for_deletion():
			continue

		if belt.is_in_group("construction_preview"):
			continue

		belts.append(belt)

	var best: Dictionary = {}

	var best_distance_squared: float = (
		search_radius * search_radius
	)

	# =============================================================================
	# CHECK ALL FREE SOURCE AND DESTINATION PAIRS
	# =============================================================================

	for source: ConveyorSegment in belts:

		if is_instance_valid(source.next_segment):
			continue

		if is_instance_valid(source.output_building_port):
			continue

		for destination: ConveyorSegment in belts:

			if source == destination:
				continue

			if is_instance_valid(destination.previous_segment):
				continue

			if is_instance_valid(destination.input_building_port):
				continue

			for turn: int in [
				ConveyorTurnIntent.Turn.RIGHT,
				ConveyorTurnIntent.Turn.LEFT
			]:

				var candidate: Dictionary = preview_for_pair(
					source,
					destination,
					turn
				)

				if candidate.is_empty():
					continue

				var proposed: Transform3D = (
					candidate["transform"]
				)

				var offset := Vector2(
					mouse_position.x - proposed.origin.x,
					mouse_position.z - proposed.origin.z
				)

				var distance_squared: float = (
					offset.length_squared()
				)

				if distance_squared >= best_distance_squared:
					continue

				best_distance_squared = distance_squared
				best = candidate

	return best
