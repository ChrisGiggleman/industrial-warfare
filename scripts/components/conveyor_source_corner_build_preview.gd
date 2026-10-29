extends RefCounted
class_name ConveyorSourceCornerBuildPreview

# =============================================================================
# CHAT 08.3G-3F — SOURCE-SIDE CORNER OVERLAY AND COLLISION CHECK
# =============================================================================

# The existing source keeps its input (conveyor or building port).
# Only its free output changes on a successful click.

static func make_overlay(
	candidate: Dictionary,
	preview_material: Material
) -> MeshInstance3D:
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var destination: ConveyorSegment = (
		candidate.get("receiver") as ConveyorSegment
	)
	if not is_instance_valid(source) or not is_instance_valid(destination):
		return null

	var fresh := ConveyorExistingEndpointFinder.inspect_pair(
		source, destination
	)
	if (
		fresh.get("mode", "") != "convert_source"
		or int(fresh.get("turn", -1)) != int(candidate.get("turn", -2))
	):
		return null

	var turn: int = int(fresh["turn"])
	var scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	if scene == null:
		return null
	var template: ConveyorSegment = scene.instantiate() as ConveyorSegment
	if template == null:
		return null
	var template_mesh := template.get_node_or_null("BeltMesh") as MeshInstance3D
	var corner_mesh: ArrayMesh = ConveyorCornerVisualMesh.build(turn)
	if template_mesh == null or corner_mesh == null:
		template.free()
		return null

	var overlay := MeshInstance3D.new()
	overlay.mesh = corner_mesh
	overlay.material_override = preview_material
	overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	overlay.transform = source.global_transform * template_mesh.transform
	overlay.position.y += 0.015
	template.free()
	return overlay


static func is_clear(
	world: World3D,
	candidate: Dictionary,
	collision_mask: int
) -> bool:
	if world == null:
		return false

	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var destination: ConveyorSegment = (
		candidate.get("receiver") as ConveyorSegment
	)
	if not is_instance_valid(source) or not is_instance_valid(destination):
		return false

	var fresh := ConveyorExistingEndpointFinder.inspect_pair(
		source, destination
	)
	if fresh.get("mode", "") != "convert_source":
		return false
	if int(fresh.get("turn", -1)) != int(candidate.get("turn", -2)):
		return false
	var junction: Vector3 = candidate.get("junction", Vector3.INF)
	var current_junction: Vector3 = fresh["junction"]
	if not junction.is_equal_approx(current_junction):
		return false

	var scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(
		int(fresh["turn"])
	)
	if scene == null:
		return false
	var template: ConveyorSegment = scene.instantiate() as ConveyorSegment
	if template == null:
		return false

	var body_shape := (
		template.get_node_or_null("ConveyorBody/ConveyorBody")
		as CollisionShape3D
	)
	var source_body := (
		source.get_node_or_null("ConveyorBody") as PhysicsBody3D
	)
	var destination_body := (
		destination.get_node_or_null("ConveyorBody") as PhysicsBody3D
	)
	if (
		body_shape == null or body_shape.shape == null
		or source_body == null or destination_body == null
	):
		template.free()
		return false

	var exclusions: Array[RID] = [
		source_body.get_rid(),
		destination_body.get_rid()
	]

	# Preserve an existing upstream conveyor.
	if is_instance_valid(source.previous_segment):
		var upstream: ConveyorSegment = source.previous_segment
		var upstream_out := (
			upstream.get_node_or_null("OutputEndpoint") as Marker3D
		)
		var source_in := (
			source.get_node_or_null("InputEndpoint") as Marker3D
		)
		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			upstream_out, source_in, ConveyorSegment.CONNECTION_GAP
		):
			template.free()
			return false
		var upstream_body := (
			upstream.get_node_or_null("ConveyorBody") as PhysicsBody3D
		)
		if upstream_body == null:
			template.free()
			return false
		exclusions.append(upstream_body.get_rid())

	# A building output already supplying this source is NOT disconnected.
	# It must remain physically valid and own the same connected conveyor.
	if is_instance_valid(source.input_building_port):
		var port: ItemPortComponent = source.input_building_port
		var source_input := (
			source.get_node_or_null("InputEndpoint") as Marker3D
		)
		if port.connected_conveyor != source:
			template.free()
			return false
		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			port, source_input, ConveyorSegment.CONNECTION_GAP
		):
			template.free()
			return false

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = body_shape.shape
	query.transform = source.global_transform * body_shape.transform
	query.collision_mask = collision_mask
	query.exclude = exclusions

	var collisions: Array[Dictionary] = (
		world.direct_space_state.intersect_shape(query, 16)
	)
	template.free()
	return collisions.is_empty()
