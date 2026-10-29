extends RefCounted
class_name ConveyorReceiverCornerBuildPreview


# =============================================================================
# CHAT 08.3G-3E — EXISTING RECEIVER CORNER VISUAL & COLLISION PREVIEW
# =============================================================================

# Does not mutate the real receiver. Its output and inventory stay intact.


static func make_overlay(
	candidate: Dictionary,
	preview_material: Material
) -> MeshInstance3D:
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var receiver: ConveyorSegment = candidate.get("receiver") as ConveyorSegment
	if not is_instance_valid(source) or not is_instance_valid(receiver):
		return null

	var geometry: Dictionary = (
		ConveyorReceiverCornerConnection.get_candidate(source, receiver)
	)
	if geometry.is_empty() or int(geometry["turn"]) != int(candidate.get("turn", -1)):
		return null

	var turn: int = int(geometry["turn"])
	var scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	if scene == null:
		return null
	var template: ConveyorSegment = scene.instantiate() as ConveyorSegment
	if template == null:
		return null
	var template_mesh: MeshInstance3D = (
		template.get_node_or_null("BeltMesh") as MeshInstance3D
	)
	var generated_mesh: ArrayMesh = ConveyorCornerVisualMesh.build(turn)
	if template_mesh == null or generated_mesh == null:
		template.free()
		return null

	var overlay := MeshInstance3D.new()
	overlay.mesh = generated_mesh
	overlay.material_override = preview_material
	overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var local_rotation: Transform3D = geometry["rotation"]
	overlay.transform = (
		receiver.global_transform * local_rotation * template_mesh.transform
	)
	overlay.position.y += 0.015
	template.free()
	return overlay


static func is_clear(
	world: World3D,
	candidate: Dictionary,
	collision_mask: int
) -> bool:
	if world == null or candidate.is_empty():
		return false

	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var receiver: ConveyorSegment = candidate.get("receiver") as ConveyorSegment
	if not is_instance_valid(source) or not is_instance_valid(receiver):
		return false

	# Always revalidate: either endpoint may have become occupied.
	var fresh: Dictionary = (
		ConveyorExistingEndpointFinder.inspect_pair(source, receiver)
	)
	if fresh.get("mode", "") != "convert_receiver":
		return false
	if int(fresh.get("turn", -1)) != int(candidate.get("turn", -1)):
		return false
	var expected_junction: Vector3 = candidate.get("junction", Vector3.INF)
	var current_junction: Vector3 = fresh["junction"]
	if not current_junction.is_equal_approx(expected_junction):
		return false

	var geometry: Dictionary = (
		ConveyorReceiverCornerConnection.get_candidate(source, receiver)
	)
	if geometry.is_empty():
		return false

	var scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(
		int(candidate["turn"])
	)
	if scene == null:
		return false
	var template: ConveyorSegment = scene.instantiate() as ConveyorSegment
	if template == null:
		return false

	var corner_shape: CollisionShape3D = (
		template.get_node_or_null("ConveyorBody/ConveyorBody")
		as CollisionShape3D
	)
	var source_body: PhysicsBody3D = (
		source.get_node_or_null("ConveyorBody") as PhysicsBody3D
	)
	var receiver_body: PhysicsBody3D = (
		receiver.get_node_or_null("ConveyorBody") as PhysicsBody3D
	)
	if (
		corner_shape == null
		or corner_shape.shape == null
		or source_body == null
		or receiver_body == null
	):
		template.free()
		return false

	# The converted receiver replaces itself. Source is a verified link.
	var exclusions: Array[RID] = [
		source_body.get_rid(),
		receiver_body.get_rid()
	]

	# An existing downstream conveyor must retain exact output alignment.
	if is_instance_valid(receiver.next_segment):
		var downstream: ConveyorSegment = receiver.next_segment
		var outgoing: Marker3D = (
			receiver.get_node_or_null("OutputEndpoint") as Marker3D
		)
		var incoming: Marker3D = (
			downstream.get_node_or_null("InputEndpoint") as Marker3D
		)
		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming, ConveyorSegment.CONNECTION_GAP
		):
			template.free()
			return false
		var downstream_body: PhysicsBody3D = (
			downstream.get_node_or_null("ConveyorBody") as PhysicsBody3D
		)
		if downstream_body == null:
			template.free()
			return false
		exclusions.append(downstream_body.get_rid())

	var local_rotation: Transform3D = geometry["rotation"]
	var test := PhysicsShapeQueryParameters3D.new()
	test.shape = corner_shape.shape
	test.transform = (
		receiver.global_transform * local_rotation * corner_shape.transform
	)
	test.collision_mask = collision_mask
	test.exclude = exclusions
	var hits: Array[Dictionary] = (
		world.direct_space_state.intersect_shape(test, 16)
	)
	template.free()
	return hits.is_empty()
