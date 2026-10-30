extends RefCounted
class_name ConveyorFractionalBridge

# =============================================================================
# CHAT 08.3G-3F — FRACTIONAL BUILDING-TO-BUILDING GAP BRIDGE
# =============================================================================

# An exactly aligned short gap may be smaller than one normal conveyor tile.
# Insert one REAL transport-capable segment whose endpoints match the gap.
# Discovery is read-only. Both external building-port connections are kept.
# Build Mode integration follows isolated validation.

const MIN_LENGTH: float = 0.15
const MAX_LENGTH: float = 1.5
const LATERAL_TOLERANCE: float = 0.025
const DIRECTION_DOT: float = 0.98

static func inspect_pair(
	source: ConveyorSegment,
	destination: ConveyorSegment
) -> Dictionary:
	if not is_instance_valid(source) or not is_instance_valid(destination):
		return {}
	if source == destination:
		return {}
	for belt: ConveyorSegment in [source, destination]:
		if not belt.is_inside_tree() or belt.is_queued_for_deletion():
			return {}
		if belt.is_in_group("construction_preview"):
			return {}
	if is_instance_valid(source.next_segment):
		return {}
	if is_instance_valid(source.output_building_port):
		return {}
	if is_instance_valid(destination.previous_segment):
		return {}
	if is_instance_valid(destination.input_building_port):
		return {}

	var output := source.get_node_or_null("OutputEndpoint") as Marker3D
	var input := destination.get_node_or_null("InputEndpoint") as Marker3D
	if output == null or input == null:
		return {}

	var output_basis: Basis = output.global_transform.basis.orthonormalized()
	var direction: Vector3 = (output_basis * Vector3.FORWARD).normalized()
	var input_direction: Vector3 = (
		input.global_transform.basis * Vector3.FORWARD
	).normalized()
	if direction.dot(input_direction) > -DIRECTION_DOT:
		return {}

	var delta: Vector3 = input.global_position - output.global_position
	var length: float = delta.dot(direction)
	if length < MIN_LENGTH or length > MAX_LENGTH:
		return {}

	var lateral: Vector3 = delta - direction * length
	if lateral.length() > LATERAL_TOLERANCE:
		return {}

	var center: Vector3 = (
		output.global_position + direction * (length / 2.0)
	)
	var proposed: Transform3D = Transform3D(
		output_basis,
		center - output_basis * Vector3(0.0, 0.5, 0.0)
	)

	return {
		"source": source,
		"destination": destination,
		"length": length,
		"transform": proposed
	}


# =============================================================================
# BUILD MODE — NEAREST PARTIAL-LENGTH STRAIGHT GAP
# =============================================================================

# Full one-unit gaps already belong to the normal two-ended bridge tool.
# This helper only offers a fractional segment when the gap is shorter.
# Hover near the proposed segment center; neither neighbor is moved.

static func find_nearest_preview(
	tree: SceneTree,
	cursor: Vector3,
	search_radius: float = 0.75
) -> Dictionary:
	if tree == null or search_radius <= 0.0:
		return {}

	var nearby: Array[ConveyorSegment] = []
	var reach: float = MAX_LENGTH * 2.0 + search_radius
	for node: Node in tree.get_nodes_in_group("player_built"):
		if not node is ConveyorSegment:
			continue
		var belt: ConveyorSegment = node as ConveyorSegment
		if belt.is_queued_for_deletion() or belt.is_in_group("construction_preview"):
			continue
		if Vector2(
			belt.global_position.x - cursor.x,
			belt.global_position.z - cursor.z
		).length() <= reach:
			nearby.append(belt)

	var best: Dictionary = {}
	var closest: float = search_radius * search_radius
	for source: ConveyorSegment in nearby:
		if is_instance_valid(source.next_segment) or is_instance_valid(source.output_building_port):
			continue
		for destination: ConveyorSegment in nearby:
			if source == destination:
				continue
			var candidate: Dictionary = inspect_pair(source, destination)
			if candidate.is_empty():
				continue
			# Normal 1.0 segments continue using the existing bridge path.
			if float(candidate["length"]) >= 0.95:
				continue
			var p: Vector3 = (candidate["transform"] as Transform3D).origin
			var d2: float = Vector2(cursor.x - p.x, cursor.z - p.z).length_squared()
			if d2 >= closest:
				continue
			best = candidate
			closest = d2

	return best


static func is_clear(
	world: World3D,
	candidate: Dictionary,
	collision_mask: int
) -> bool:
	if world == null or candidate.is_empty():
		return false
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var destination: ConveyorSegment = (
		candidate.get("destination") as ConveyorSegment
	)
	var fresh: Dictionary = inspect_pair(source, destination)
	if fresh.is_empty():
		return false
	if not (fresh["transform"] as Transform3D).is_equal_approx(
		candidate.get("transform", Transform3D.IDENTITY)
	):
		return false

	var source_body := source.get_node_or_null("ConveyorBody") as PhysicsBody3D
	var dest_body := destination.get_node_or_null("ConveyorBody") as PhysicsBody3D
	if source_body == null or dest_body == null:
		return false

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.78, 0.18, maxf(0.05, float(fresh["length"]) - 0.1))
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = (
		(fresh["transform"] as Transform3D)
		* Transform3D(Basis.IDENTITY, Vector3(0.0, 0.3, 0.0))
	)
	q.collision_mask = collision_mask
	q.exclude = [source_body.get_rid(), dest_body.get_rid()]
	return world.direct_space_state.intersect_shape(q, 16).is_empty()


static func try_place(
	parent: Node3D,
	candidate: Dictionary
) -> ConveyorSegment:
	if not is_instance_valid(parent) or not parent.is_inside_tree():
		return null
	if candidate.is_empty():
		return null
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var destination: ConveyorSegment = (
		candidate.get("destination") as ConveyorSegment
	)
	var fresh: Dictionary = inspect_pair(source, destination)
	if fresh.is_empty():
		return null
	var proposed: Transform3D = fresh["transform"]
	if not proposed.is_equal_approx(
		candidate.get("transform", Transform3D.IDENTITY)
	):
		return null
	if not is_clear(parent.get_world_3d(), fresh, 4):
		return null

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	if belt == null:
		return null
	var input := belt.get_node_or_null("InputEndpoint") as Marker3D
	var output := belt.get_node_or_null("OutputEndpoint") as Marker3D
	var mesh := belt.get_node_or_null("BeltMesh") as MeshInstance3D
	var body := belt.get_node_or_null("ConveyorBody/ConveyorBody") as CollisionShape3D
	var hitbox := (
		belt.get_node_or_null("InteractionHitbox/InteractionHitbox")
		as CollisionShape3D
	)
	if (
		input == null or output == null or mesh == null
		or body == null or hitbox == null
	):
		belt.free()
		return null
	if not mesh.mesh is BoxMesh:
		belt.free()
		return null
	if not body.shape is BoxShape3D or not hitbox.shape is BoxShape3D:
		belt.free()
		return null

	var length: float = float(fresh["length"])
	var half: float = length / 2.0
	var render_mesh := mesh.mesh.duplicate(true) as BoxMesh
	render_mesh.size.z = length
	mesh.mesh = render_mesh
	var physical_shape := body.shape.duplicate(true) as BoxShape3D
	physical_shape.size.z = maxf(0.05, length - 0.1)
	body.shape = physical_shape
	var selection_shape := hitbox.shape.duplicate(true) as BoxShape3D
	selection_shape.size.z = length
	hitbox.shape = selection_shape
	input.position.z = half
	output.position.z = -half

	parent.add_child(belt)
	belt.global_transform = proposed

	# Both connections must commit or neither survives.
	if not source.try_connect_to(belt):
		belt.free()
		return null
	if not belt.try_connect_to(destination):
		source.disconnect_next()
		belt.free()
		return null
	return belt
