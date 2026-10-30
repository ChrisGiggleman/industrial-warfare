extends RefCounted
class_name ConveyorOffsetCornerBridge

# =============================================================================
# EXACT PERPENDICULAR GAP CONNECTOR
# =============================================================================

# Joins an unoccupied output to an unoccupied input through one real
# transport-capable L-shaped belt. Uses endpoint directions and positions,
# never artificially shifts either existing belt or merges occupied inputs.
#
# Both legs are at least half a tile so the 0.8-wide geometry is valid.

const MIN_LEG: float = 0.4
const MAX_LEG: float = 1.5
const ALIGN_EPSILON: float = 0.025
const PERPENDICULAR_DOT: float = 0.02
const WIDTH: float = 0.78
const HALF_WIDTH: float = WIDTH * 0.5


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

	var from_marker := source.get_node_or_null("OutputEndpoint") as Marker3D
	var to_marker := destination.get_node_or_null("InputEndpoint") as Marker3D
	if from_marker == null or to_marker == null:
		return {}

	var basis: Basis = from_marker.global_transform.basis.orthonormalized()
	var incoming_direction: Vector3 = (basis * Vector3.FORWARD).normalized()
	var outgoing_direction: Vector3 = (
		-(to_marker.global_transform.basis * Vector3.FORWARD)
	).normalized()
	if absf(incoming_direction.dot(outgoing_direction)) > PERPENDICULAR_DOT:
		return {}

	var delta: Vector3 = to_marker.global_position - from_marker.global_position
	var input_length: float = delta.dot(incoming_direction)
	var output_length: float = delta.dot(outgoing_direction)
	if input_length < MIN_LEG or input_length > MAX_LEG:
		return {}
	if output_length < MIN_LEG or output_length > MAX_LEG:
		return {}

	var bend: Vector3 = (
		from_marker.global_position + incoming_direction * input_length
	)
	if (bend + outgoing_direction * output_length).distance_to(
		to_marker.global_position
	) > ALIGN_EPSILON:
		return {}

	var right_axis: Vector3 = (basis * Vector3.RIGHT).normalized()
	var right_dot: float = outgoing_direction.dot(right_axis)
	if absf(right_dot) < 0.98:
		return {}
	var side: float = 1.0 if right_dot > 0.0 else -1.0
	var turn: int = (
		ConveyorTurnIntent.Turn.RIGHT
		if side > 0.0 else ConveyorTurnIntent.Turn.LEFT
	)

	var transform := Transform3D(
		basis,
		bend - basis * Vector3(0.0, 0.5, 0.0)
	)

	return {
		"source": source,
		"destination": destination,
		"transform": transform,
		"turn": turn,
		"side": side,
		"input_length": input_length,
		"output_length": output_length
	}


static func find_nearest_preview(
	tree: SceneTree,
	cursor: Vector3,
	search_radius: float = 0.8
) -> Dictionary:
	if tree == null or search_radius <= 0.0:
		return {}
	var nearby: Array[ConveyorSegment] = []
	var reach: float = MAX_LEG * 2.0 + search_radius
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
			if is_instance_valid(destination.previous_segment) or is_instance_valid(destination.input_building_port):
				continue
			var candidate: Dictionary = inspect_pair(source, destination)
			if candidate.is_empty():
				continue
			var p: Vector3 = (candidate["transform"] as Transform3D).origin
			var d2: float = Vector2(cursor.x - p.x, cursor.z - p.z).length_squared()
			if d2 >= closest:
				continue
			best = candidate
			closest = d2
	return best


static func _rectangles(candidate: Dictionary) -> Array[Dictionary]:
	var t: float = candidate["input_length"]
	var s: float = candidate["output_length"]
	var side: float = candidate["side"]
	# Two joined 0.78-wide legs. Their center overlap fills the bend.
	var rectangles: Array[Dictionary] = [
		{
			"size": Vector3(WIDTH, 0.18, t + HALF_WIDTH),
			"offset": Vector3(0.0, 0.3, (t - HALF_WIDTH) * 0.5)
		},
		{
			"size": Vector3(s + HALF_WIDTH, 0.18, WIDTH),
			"offset": Vector3(side * (s - HALF_WIDTH) * 0.5, 0.3, 0.0)
		}
	]
	return rectangles


static func is_clear(
	world: World3D,
	candidate: Dictionary,
	collision_mask: int
) -> bool:
	if world == null or candidate.is_empty():
		return false
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var destination: ConveyorSegment = candidate.get("destination") as ConveyorSegment
	var fresh: Dictionary = inspect_pair(source, destination)
	if fresh.is_empty():
		return false
	if not (fresh["transform"] as Transform3D).is_equal_approx(
		candidate.get("transform", Transform3D.IDENTITY)
	):
		return false

	var source_body := source.get_node_or_null("ConveyorBody") as PhysicsBody3D
	var destination_body := destination.get_node_or_null("ConveyorBody") as PhysicsBody3D
	if source_body == null or destination_body == null:
		return false

	for rect: Dictionary in _rectangles(fresh):
		var shape := BoxShape3D.new()
		shape.size = rect["size"]
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = shape
		q.transform = (
			(fresh["transform"] as Transform3D)
			* Transform3D(Basis.IDENTITY, rect["offset"])
		)
		q.collision_mask = collision_mask
		q.exclude = [source_body.get_rid(), destination_body.get_rid()]
		if not world.direct_space_state.intersect_shape(q, 16).is_empty():
			return false
	return true


static func make_preview_mesh(candidate: Dictionary) -> ArrayMesh:
	if candidate.is_empty():
		return null
	return ConveyorCornerVisualMesh.build(
		int(candidate["turn"]),
		float(candidate["input_length"]),
		float(candidate["output_length"])
	)


static func try_place(
	parent: Node3D,
	candidate: Dictionary,
	collision_mask: int = 4
) -> ConveyorSegment:
	if not is_instance_valid(parent) or not parent.is_inside_tree():
		return null
	if candidate.is_empty():
		return null
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	var destination: ConveyorSegment = candidate.get("destination") as ConveyorSegment
	var fresh: Dictionary = inspect_pair(source, destination)
	if fresh.is_empty():
		return null
	if not (fresh["transform"] as Transform3D).is_equal_approx(
		candidate.get("transform", Transform3D.IDENTITY)
	):
		return null
	if not is_clear(parent.get_world_3d(), fresh, collision_mask):
		return null

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	)
	if belt == null:
		return null
	var input := belt.get_node_or_null("InputEndpoint") as Marker3D
	var output := belt.get_node_or_null("OutputEndpoint") as Marker3D
	var mesh := belt.get_node_or_null("BeltMesh") as MeshInstance3D
	var body := belt.get_node_or_null("ConveyorBody") as StaticBody3D
	var hitbox := belt.get_node_or_null("InteractionHitbox") as Area3D
	var body_shape := belt.get_node_or_null("ConveyorBody/ConveyorBody") as CollisionShape3D
	var hit_shape := belt.get_node_or_null("InteractionHitbox/InteractionHitbox") as CollisionShape3D
	if (
		input == null or output == null or mesh == null
		or body == null or hitbox == null
		or body_shape == null or hit_shape == null
	):
		belt.free()
		return null

	var shape: ArrayMesh = make_preview_mesh(fresh)
	if shape == null:
		belt.free()
		return null
	mesh.mesh = shape
	input.position = Vector3(0, 0.5, float(fresh["input_length"]))
	input.basis = Basis(Vector3.UP, PI)
	var side: float = fresh["side"]
	output.position = Vector3(
		side * float(fresh["output_length"]), 0.5, 0
	)
	output.basis = Basis(Vector3.UP, -side * PI / 2.0)

	# Extend both the real physics body and selection hitbox.
	var rects: Array[Dictionary] = _rectangles(fresh)
	for i: int in range(rects.size()):
		var rect: Dictionary = rects[i]
		var collision: CollisionShape3D = body_shape if i == 0 else CollisionShape3D.new()
		var selection: CollisionShape3D = hit_shape if i == 0 else CollisionShape3D.new()
		var collision_box := BoxShape3D.new()
		collision_box.size = rect["size"]
		var selection_box := BoxShape3D.new()
		selection_box.size = rect["size"]
		selection_box.size.y = 0.3
		collision.shape = collision_box
		collision.position = rect["offset"]
		selection.shape = selection_box
		selection.position = rect["offset"]
		if i != 0:
			body.add_child(collision)
			hitbox.add_child(selection)

	belt.set_meta("conveyor_turn", int(fresh["turn"]))
	belt.set_meta("offset_corner", true)

	# An L connector traverses both legs, not one fixed-length tile.
	# Use identical units/second to the normal conveyor pieces.
	if not ConveyorPathMotion.configure_segment(belt):
		belt.free()
		return null

	parent.add_child(belt)
	belt.global_transform = fresh["transform"]

	if not source.try_connect_to(belt):
		belt.free()
		return null
	if not belt.try_connect_to(destination):
		source.disconnect_next()
		belt.free()
		return null
	return belt
