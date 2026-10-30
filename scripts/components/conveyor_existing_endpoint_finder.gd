
extends RefCounted
class_name ConveyorExistingEndpointFinder


# =============================================================================
# EXISTING ENDPOINT DISCOVERY
# =============================================================================

# Detects compatible connections between TWO placed conveyors.
#
# Supports:
# - Direct output-to-input alignment
# - Converting an existing straight into a RIGHT corner
# - Converting an existing straight into a LEFT corner
#
# This is discovery only.
#
# Never:
# - Move a conveyor
# - Modify connection references
# - Convert conveyor geometry
# - Change or transfer inventory
#
# Actual connection and collision validation come later.


# =============================================================================
# CHECK TWO ENDPOINT TRANSFORMS
# =============================================================================

static func _endpoints_align(
	outgoing: Transform3D,
	incoming: Transform3D
) -> bool:

	var offset: Vector3 = incoming.origin - outgoing.origin

	if offset.length() > ConveyorSegment.CONNECTION_GAP:
		return false

	var output_forward: Vector3 = (
		outgoing.basis * Vector3.FORWARD
	).normalized()

	var input_forward: Vector3 = (
		incoming.basis * Vector3.FORWARD
	).normalized()

	if output_forward.dot(input_forward) > -0.98:
		return false

	if offset.length_squared() > 0.000001:
		if output_forward.dot(offset.normalized()) < 0.98:
			return false

	return true


# =============================================================================
# INSPECT TWO EXISTING CONVEYORS
# =============================================================================

static func inspect_pair(
	source: ConveyorSegment,
	receiver: ConveyorSegment
) -> Dictionary:

	if not is_instance_valid(source):
		return {}

	if not is_instance_valid(receiver):
		return {}

	if source == receiver:
		return {}

	for belt: ConveyorSegment in [source, receiver]:
		if not belt.is_inside_tree():
			return {}

		if belt.is_queued_for_deletion():
			return {}

		if belt.is_in_group("construction_preview"):
			return {}

	# =============================================================================
	# REQUIRE AVAILABLE ENDPOINTS
	# =============================================================================

	if is_instance_valid(source.next_segment):
		return {}

	if is_instance_valid(source.output_building_port):
		return {}

	if is_instance_valid(receiver.previous_segment):
		return {}

	if is_instance_valid(receiver.input_building_port):
		return {}

	var source_output := (
		source.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var receiver_input := (
		receiver.get_node_or_null("InputEndpoint") as Marker3D
	)

	if source_output == null or receiver_input == null:
		return {}

	# =============================================================================
	# OPTION A — DIRECT CONNECTION
	# =============================================================================

	if _endpoints_align(
		source_output.global_transform,
		receiver_input.global_transform
	):
		return {
			"source": source,
			"receiver": receiver,
			"mode": "direct",
			"turn": ConveyorTurnIntent.Turn.STRAIGHT,
			"junction": source_output.global_position
		}

	# =============================================================================
	# OPTION A2 — CONVERT EXISTING RECEIVER INTO A CORNER
	# =============================================================================

	# The receiving conveyor may already have a downstream
	# connection to another conveyor or building.
	#
	# Instead of changing its output, calculate whether
	# its input can turn toward the source.
	#
	# Discovery is read-only.

	var receiver_candidate: Dictionary = (
		ConveyorReceiverCornerConnection.get_candidate(
			source,
			receiver
		)
	)

	if not receiver_candidate.is_empty():

		var proposed_input: Transform3D = (
			receiver_candidate["input_transform"]
		)

		var junction_transform: Transform3D = (
			receiver.global_transform * proposed_input
		)

		return {
			"source": source,
			"receiver": receiver,
			"mode": "convert_receiver",
			"turn": int(receiver_candidate["turn"]),
			"junction": junction_transform.origin
		}

	# =============================================================================
	# OPTION B — CONVERT AN EXISTING STRAIGHT TO A CORNER
	# =============================================================================

	# Only original straight conveyors can use our existing
	# corner conversion helper.

	if not source_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	if source.has_meta("conveyor_turn"):
		return {}

	for turn: int in [
		ConveyorTurnIntent.Turn.RIGHT,
		ConveyorTurnIntent.Turn.LEFT
	]:

		var corner_scene: PackedScene = (
			ConveyorPieceSelector.get_scene_for_turn(turn)
		)

		if corner_scene == null:
			continue

		var template: ConveyorSegment = (
			corner_scene.instantiate() as ConveyorSegment
		)

		if template == null:
			continue

		var corner_output := (
			template.get_node_or_null("OutputEndpoint") as Marker3D
		)

		if corner_output == null:
			template.free()
			continue

		# Calculate the world endpoint as though the
		# existing source had this corner's output.
		#
		# The real source is NEVER changed here.

		var proposed_output: Transform3D = (
			source.global_transform * corner_output.transform
		)

		template.free()

		if _endpoints_align(
			proposed_output,
			receiver_input.global_transform
		):
			return {
				"source": source,
				"receiver": receiver,
				"mode": "convert_source",
				"turn": turn,
				"junction": proposed_output.origin
			}

	return {}


# =============================================================================
# FIND NEAREST CONNECTION BETWEEN EXISTING BELTS
# =============================================================================

static func find_nearest_candidate(
	tree: SceneTree,
	mouse_world_position: Vector3,
	search_radius: float = 1.25
) -> Dictionary:

	if tree == null or search_radius <= 0.0:
		return {}

	var belts: Array[ConveyorSegment] = []

	for node: Node in tree.get_nodes_in_group("player_built"):

		if not node is ConveyorSegment:
			continue

		var belt: ConveyorSegment = node as ConveyorSegment

		if belt.is_queued_for_deletion():
			continue

		if belt.is_in_group("construction_preview"):
			continue

		belts.append(belt)

	var best: Dictionary = {}
	var best_distance_squared: float = (
		search_radius * search_radius
	)

	for source: ConveyorSegment in belts:

		for receiver: ConveyorSegment in belts:

			if source == receiver:
				continue

			var candidate: Dictionary = (
				inspect_pair(source, receiver)
			)

			if candidate.is_empty():
				continue

			var junction: Vector3 = candidate["junction"]

			var offset := Vector2(
				mouse_world_position.x - junction.x,
				mouse_world_position.z - junction.z
			)

			var distance_squared: float = offset.length_squared()

			if distance_squared >= best_distance_squared:
				continue

			best_distance_squared = distance_squared
			best = candidate

	return best
