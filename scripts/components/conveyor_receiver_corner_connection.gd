
extends RefCounted
class_name ConveyorReceiverCornerConnection


# =============================================================================
# CHAT 08.3G — RECEIVER-SIDE CORNER CONNECTION
# =============================================================================

# Converts an existing straight receiver into a corner.
#
# Preserves:
# - Receiver node identity and world transform
# - Existing downstream conveyor or building connection
# - Source's existing upstream connection
# - Both inventories and transported items
#
# Only changes the receiver's incoming geometry.
# Does not create, delete, or move conveyor roots.


# =============================================================================
# CHECK VIRTUAL ENDPOINT ALIGNMENT
# =============================================================================

static func _aligns(
	outgoing: Transform3D,
	incoming: Transform3D
) -> bool:

	var offset: Vector3 = incoming.origin - outgoing.origin

	if offset.length() > ConveyorSegment.CONNECTION_GAP:
		return false

	var forward_out: Vector3 = (
		outgoing.basis * Vector3.FORWARD
	).normalized()

	var forward_in: Vector3 = (
		incoming.basis * Vector3.FORWARD
	).normalized()

	if forward_out.dot(forward_in) > -0.98:
		return false

	if offset.length_squared() > 0.000001:
		if forward_out.dot(offset.normalized()) < 0.98:
			return false

	return true


# =============================================================================
# READ-ONLY RECEIVER CORNER DISCOVERY
# =============================================================================

static func get_candidate(
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

	if is_instance_valid(source.next_segment):
		return {}

	if is_instance_valid(source.output_building_port):
		return {}

	if is_instance_valid(receiver.previous_segment):
		return {}

	if is_instance_valid(receiver.input_building_port):
		return {}

	if receiver.has_meta("conveyor_turn"):
		return {}

	var source_output := (
		source.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var receiver_input := (
		receiver.get_node_or_null("InputEndpoint") as Marker3D
	)

	var receiver_output := (
		receiver.get_node_or_null("OutputEndpoint") as Marker3D
	)

	if (
		source_output == null
		or receiver_input == null
		or receiver_output == null
	):
		return {}

	# Receiver must still be an ordinary straight.

	if not receiver_input.position.is_equal_approx(
		Vector3(0.0, 0.5, 0.5)
	):
		return {}

	if not receiver_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	# =============================================================================
	# TEST BOTH CORNER TEMPLATES
	# =============================================================================

	for turn: int in [
		ConveyorTurnIntent.Turn.RIGHT,
		ConveyorTurnIntent.Turn.LEFT
	]:

		var scene: PackedScene = (
			ConveyorPieceSelector.get_scene_for_turn(turn)
		)

		if scene == null:
			continue

		var template := scene.instantiate() as ConveyorSegment

		if template == null:
			continue

		var template_input := (
			template.get_node_or_null("InputEndpoint") as Marker3D
		)

		var template_output := (
			template.get_node_or_null("OutputEndpoint") as Marker3D
		)

		if template_input == null or template_output == null:
			template.free()
			continue

		# Rotate the template inside the receiver's existing
		# local space so its OUTPUT stays unchanged.

		var angle: float = PI / 2.0

		if turn == ConveyorTurnIntent.Turn.LEFT:
			angle = -PI / 2.0

		var local_rotation := Transform3D(
			Basis(Vector3.UP, angle),
			Vector3.ZERO
		)

		var proposed_input: Transform3D = (
			local_rotation * template_input.transform
		)

		var proposed_output: Transform3D = (
			local_rotation * template_output.transform
		)

		# Existing outgoing geometry must remain identical.

		if not proposed_output.is_equal_approx(
			receiver_output.transform
		):
			template.free()
			continue

		var world_input: Transform3D = (
			receiver.global_transform * proposed_input
		)

		template.free()

		if not _aligns(
			source_output.global_transform,
			world_input
		):
			continue

		return {
			"source": source,
			"receiver": receiver,
			"turn": turn,
			"rotation": local_rotation,
			"input_transform": proposed_input
		}

	return {}


# =============================================================================
# PERMANENT RECEIVER CORNER CONVERSION
# =============================================================================

static func try_connect(
	source: ConveyorSegment,
	receiver: ConveyorSegment
) -> bool:

	var candidate: Dictionary = get_candidate(
		source,
		receiver
	)

	if candidate.is_empty():
		return false

	var turn: int = int(candidate["turn"])

	var scene: PackedScene = (
		ConveyorPieceSelector.get_scene_for_turn(turn)
	)

	if scene == null:
		return false

	var template := scene.instantiate() as ConveyorSegment

	if template == null:
		return false

	var receiver_input := (
		receiver.get_node_or_null("InputEndpoint") as Marker3D
	)

	var receiver_mesh := (
		receiver.get_node_or_null("BeltMesh") as MeshInstance3D
	)

	var receiver_body := (
		receiver.get_node_or_null(
			"ConveyorBody/ConveyorBody"
		) as CollisionShape3D
	)

	var receiver_hitbox := (
		receiver.get_node_or_null(
			"InteractionHitbox/InteractionHitbox"
		) as CollisionShape3D
	)

	var template_mesh := (
		template.get_node_or_null("BeltMesh") as MeshInstance3D
	)

	var template_body := (
		template.get_node_or_null(
			"ConveyorBody/ConveyorBody"
		) as CollisionShape3D
	)

	var template_hitbox := (
		template.get_node_or_null(
			"InteractionHitbox/InteractionHitbox"
		) as CollisionShape3D
	)

	if (
		receiver_input == null
		or receiver_mesh == null
		or receiver_body == null
		or receiver_hitbox == null
		or template_mesh == null
		or template_body == null
		or template_hitbox == null
	):
		template.free()
		return false

	if (
		template_body.shape == null
		or template_hitbox.shape == null
	):
		template.free()
		return false

	var corner_mesh: ArrayMesh = (
		ConveyorCornerVisualMesh.build(turn)
	)

	if corner_mesh == null:
		template.free()
		return false

	var body_shape := template_body.shape.duplicate(true)
	var hitbox_shape := template_hitbox.shape.duplicate(true)

	var local_rotation: Transform3D = candidate["rotation"]

	# =============================================================================
	# VALIDATE CONNECTION WITH TEMPORARY INPUT GEOMETRY
	# =============================================================================

	var original_input: Transform3D = receiver_input.transform

	receiver_input.transform = candidate["input_transform"]

	if not source.try_connect_to(receiver):
		receiver_input.transform = original_input
		template.free()
		return false

	# =============================================================================
	# COMMIT CORNER GEOMETRY
	# =============================================================================

	# The receiver root and its output endpoint remain
	# untouched. All existing downstream links stay intact.

	receiver_mesh.mesh = corner_mesh
	receiver_mesh.transform = (
		local_rotation * template_mesh.transform
	)

	receiver_body.shape = body_shape
	receiver_body.transform = (
		local_rotation * template_body.transform
	)

	receiver_hitbox.shape = hitbox_shape
	receiver_hitbox.transform = (
		local_rotation * template_hitbox.transform
	)

	receiver.set_meta("conveyor_turn", turn)

	template.free()

	return true
