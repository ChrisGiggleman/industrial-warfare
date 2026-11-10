extends RefCounted
class_name PlannedConveyorRouteGeometry

# =============================================================================
# PLANNED CONVEYOR ROUTES — GEOMETRY DISCOVERY ONLY
# =============================================================================
# Inspects the intended connection between two unfinished straight belt sites.
# Reports a direct link or a source belt's right/left corner conversion.
# Never mutates scenes, reserves endpoints, produces cargo or connects belts.
# Later route ownership and activation must revalidate this exact geometry.

static func inspect_pair(
	source: ConstructionSite,
	receiver: ConstructionSite
) -> Dictionary:
	if not _is_available_straight_site(source):
		return {}
	if not _is_available_straight_site(receiver):
		return {}
	if source == receiver:
		return {}

	var source_output := (
		source.get_node_or_null("PlannedOutputEndpoint") as Marker3D
	)
	var receiver_input := (
		receiver.get_node_or_null("PlannedInputEndpoint") as Marker3D
	)
	if not is_instance_valid(source_output) or not is_instance_valid(receiver_input):
		return {}

	# A straight section should not be converted if its planned shape has
	# already been explicitly assigned a turn in a later route phase.
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

	if source.has_meta("planned_conveyor_turn"):
		return {}

	for turn: int in [
		ConveyorTurnIntent.Turn.RIGHT,
		ConveyorTurnIntent.Turn.LEFT
	]:
		var template_scene := ConveyorPieceSelector.get_scene_for_turn(turn)
		if not is_instance_valid(template_scene):
			continue

		# This template is never added to SceneTree. It supplies only
		# the established physical corner's true output-marker geometry.
		var prototype := template_scene.instantiate() as ConveyorSegment
		if not is_instance_valid(prototype):
			continue
		var corner_output := (
			prototype.get_node_or_null("OutputEndpoint") as Marker3D
		)
		if not is_instance_valid(corner_output):
			prototype.free()
			continue

		var proposed_output := (
			source.global_transform * corner_output.transform
		)
		prototype.free()

		if _endpoints_align(
			proposed_output, receiver_input.global_transform
		):
			return {
				"source": source,
				"receiver": receiver,
				"mode": "convert_source",
				"turn": turn,
				"junction": proposed_output.origin
			}

	return {}


static func _is_available_straight_site(site: ConstructionSite) -> bool:
	if not is_instance_valid(site):
		return false
	if not site.is_inside_tree() or site.is_queued_for_deletion():
		return false
	if site.job == null or not site.accepts_planned_connections():
		return false
	if not is_instance_valid(site.target_definition):
		return false
	if site.target_definition.building_id != &"conveyor_belt":
		return false
	if site.target_definition.building_scene != ConveyorPieceSelector.STRAIGHT_SCENE:
		return false
	return (
		site.get_node_or_null("PlannedInputEndpoint") is Marker3D
		and site.get_node_or_null("PlannedOutputEndpoint") is Marker3D
	)


static func _endpoints_align(
	outgoing: Transform3D, incoming: Transform3D
) -> bool:
	var delta := incoming.origin - outgoing.origin
	if delta.length() > ConveyorSegment.CONNECTION_GAP:
		return false

	var outgoing_forward := (
		outgoing.basis * Vector3.FORWARD
	).normalized()
	var incoming_forward := (
		incoming.basis * Vector3.FORWARD
	).normalized()
	if outgoing_forward.dot(incoming_forward) > (
		-LogisticsConnectionGeometry.MIN_ALIGNMENT_DOT
	):
		return false

	if delta.length_squared() > (
		LogisticsConnectionGeometry.POSITION_EPSILON_SQUARED
	):
		if outgoing_forward.dot(delta.normalized()) < (
			LogisticsConnectionGeometry.MIN_ALIGNMENT_DOT
		):
			return false

	return true
