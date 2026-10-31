extends RefCounted
class_name ConveyorTerminalBuildingCorner

# =============================================================================
# EXISTING CONVEYOR CORNER INTO A BUILDING INPUT
# =============================================================================

# A straight conveyor beside a building's free input can turn its
# output toward that port. The existing input, inventory, and node
# remain unchanged. Only exact physical endpoint matches are accepted.

static func inspect_pair(
	belt: ConveyorSegment,
	port: ItemPortComponent,
	turn: int
) -> Dictionary:
	if not is_instance_valid(belt) or not is_instance_valid(port):
		return {}
	if not belt.is_inside_tree() or not port.is_inside_tree():
		return {}
	if belt.is_queued_for_deletion() or port.is_queued_for_deletion():
		return {}
	if belt.is_in_group("construction_preview"):
		return {}
	if port.get_parent().is_in_group("construction_preview"):
		return {}
	if port.direction != ItemPortComponent.PortDirection.INPUT:
		return {}
	if not is_instance_valid(port.inventory):
		return {}
	if is_instance_valid(port.connected_conveyor):
		return {}
	if is_instance_valid(belt.next_segment):
		return {}
	if is_instance_valid(belt.output_building_port):
		return {}
	if belt.has_meta("conveyor_turn"):
		return {}
	if turn != ConveyorTurnIntent.Turn.LEFT and turn != ConveyorTurnIntent.Turn.RIGHT:
		return {}

	var output := belt.get_node_or_null("OutputEndpoint") as Marker3D
	if output == null or not output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	var corner_scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	if corner_scene == null:
		return {}
	var template := corner_scene.instantiate() as ConveyorSegment
	if template == null:
		return {}
	var corner_output := template.get_node_or_null("OutputEndpoint") as Marker3D
	if corner_output == null:
		template.free()
		return {}

	# Use the corner's native output transform. Its direction must
	# oppose the receiving building port without any extra rotation.
	var proposed_output: Transform3D = (
		belt.global_transform * corner_output.transform
	)
	template.free()

	if not ConveyorDualEndedBridge._transforms_align(
		proposed_output, port.global_transform
	):
		return {}

	return {"belt": belt, "port": port, "turn": turn}


# =============================================================================
# FIND ONLY A UNIQUE, EXACTLY ALIGNED TERMINAL CORNER
# =============================================================================

static func find_nearest(
	tree: SceneTree,
	mouse_world_position: Vector3,
	search_radius: float = 0.65
) -> Dictionary:
	if tree == null or search_radius <= 0.0:
		return {}

	var best: Dictionary = {}
	var closest_squared: float = search_radius * search_radius
	for node: Node in tree.get_nodes_in_group("player_built"):
		if not node is ConveyorSegment:
			continue
		var belt := node as ConveyorSegment
		if belt.is_queued_for_deletion() or belt.is_in_group("construction_preview"):
			continue
		var offset := Vector2(
			mouse_world_position.x - belt.global_position.x,
			mouse_world_position.z - belt.global_position.z
		)
		var distance_squared: float = offset.length_squared()
		if distance_squared > closest_squared:
			continue

		var matches: Array[Dictionary] = []
		for building: Node in tree.get_nodes_in_group("player_built"):
			if not building is Node3D or building is ConveyorSegment:
				continue
			if building.is_queued_for_deletion():
				continue
			for child: Node in building.get_children():
				if not child is ItemPortComponent:
					continue
				for turn: int in [
					ConveyorTurnIntent.Turn.LEFT,
					ConveyorTurnIntent.Turn.RIGHT
				]:
					var candidate := inspect_pair(belt, child as ItemPortComponent, turn)
					if not candidate.is_empty():
						matches.append(candidate)

		# An ambiguous endpoint must never pick a random port.
		if matches.size() != 1:
			continue
		if distance_squared < closest_squared:
			best = matches[0]
			closest_squared = distance_squared
	return best


# =============================================================================
# CONFIRM COLLISION CLEARANCE WITHOUT MUTATING THE BELT
# =============================================================================

static func is_clear(
	world: World3D,
	candidate: Dictionary,
	collision_mask: int
) -> bool:
	if world == null:
		return false
	var belt: ConveyorSegment = candidate.get("belt") as ConveyorSegment
	var port: ItemPortComponent = candidate.get("port") as ItemPortComponent
	var turn: int = int(candidate.get("turn", -1))
	if inspect_pair(belt, port, turn).is_empty():
		return false

	var corner_scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	if corner_scene == null:
		return false
	var template := corner_scene.instantiate() as ConveyorSegment
	if template == null:
		return false
	var corner_shape := (
		template.get_node_or_null("ConveyorBody/ConveyorBody")
		as CollisionShape3D
	)
	var belt_body := belt.get_node_or_null("ConveyorBody") as PhysicsBody3D
	if corner_shape == null or corner_shape.shape == null or belt_body == null:
		template.free()
		return false

	var exclusions: Array[RID] = [belt_body.get_rid()]

	# A connected upstream conveyor remains where it is.
	if is_instance_valid(belt.previous_segment):
		var upstream := belt.previous_segment
		var upstream_out := upstream.get_node_or_null("OutputEndpoint") as Marker3D
		var belt_in := belt.get_node_or_null("InputEndpoint") as Marker3D
		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			upstream_out, belt_in, ConveyorSegment.CONNECTION_GAP
		):
			template.free()
			return false
		var upstream_body := upstream.get_node_or_null("ConveyorBody") as PhysicsBody3D
		if upstream_body == null:
			template.free()
			return false
		exclusions.append(upstream_body.get_rid())

	# A building output feeding the belt must retain its own connection.
	if is_instance_valid(belt.input_building_port):
		var input_port := belt.input_building_port
		var belt_in := belt.get_node_or_null("InputEndpoint") as Marker3D
		if input_port.connected_conveyor != belt or not (
			LogisticsConnectionGeometry.are_endpoints_aligned(
				input_port, belt_in, ConveyorSegment.CONNECTION_GAP
			)
		):
			template.free()
			return false

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = corner_shape.shape
	query.transform = belt.global_transform * corner_shape.transform
	query.collision_mask = collision_mask
	query.exclude = exclusions
	var hits: Array[Dictionary] = world.direct_space_state.intersect_shape(query, 16)
	template.free()
	return hits.is_empty()


# =============================================================================
# READ-ONLY IN-PLACE CORNER VISUAL
# =============================================================================

static func make_overlay(
	candidate: Dictionary,
	preview_material: Material
) -> MeshInstance3D:
	var belt: ConveyorSegment = candidate.get("belt") as ConveyorSegment
	var port: ItemPortComponent = candidate.get("port") as ItemPortComponent
	var turn: int = int(candidate.get("turn", -1))
	if inspect_pair(belt, port, turn).is_empty():
		return null
	var corner_scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	var template := corner_scene.instantiate() as ConveyorSegment
	if template == null:
		return null
	var template_mesh := template.get_node_or_null("BeltMesh") as MeshInstance3D
	var mesh := ConveyorCornerVisualMesh.build(turn)
	if template_mesh == null or mesh == null:
		template.free()
		return null
	var overlay := MeshInstance3D.new()
	overlay.mesh = mesh
	overlay.material_override = preview_material
	overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	overlay.transform = belt.global_transform * template_mesh.transform
	overlay.position.y += 0.015
	template.free()
	return overlay


# =============================================================================
# COMMIT CORNER WITHOUT REPLACING THE EXISTING CONVEYOR
# =============================================================================

static func try_connect(candidate: Dictionary) -> bool:
	var belt: ConveyorSegment = candidate.get("belt") as ConveyorSegment
	var port: ItemPortComponent = candidate.get("port") as ItemPortComponent
	var turn: int = int(candidate.get("turn", -1))
	if inspect_pair(belt, port, turn).is_empty():
		return false

	var corner_scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
	var template := corner_scene.instantiate() as ConveyorSegment
	if template == null:
		return false
	var output := belt.get_node_or_null("OutputEndpoint") as Marker3D
	var corner_output := template.get_node_or_null("OutputEndpoint") as Marker3D
	var mesh := belt.get_node_or_null("BeltMesh") as MeshInstance3D
	var corner_mesh := template.get_node_or_null("BeltMesh") as MeshInstance3D
	var body := belt.get_node_or_null("ConveyorBody/ConveyorBody") as CollisionShape3D
	var corner_body := template.get_node_or_null("ConveyorBody/ConveyorBody") as CollisionShape3D
	var hitbox := belt.get_node_or_null("InteractionHitbox/InteractionHitbox") as CollisionShape3D
	var corner_hitbox := template.get_node_or_null("InteractionHitbox/InteractionHitbox") as CollisionShape3D
	var generated_mesh: ArrayMesh = ConveyorCornerVisualMesh.build(turn)
	if (
		output == null or corner_output == null or mesh == null
		or corner_mesh == null or body == null or corner_body == null
		or hitbox == null or corner_hitbox == null or generated_mesh == null
		or corner_body.shape == null or corner_hitbox.shape == null
	):
		template.free()
		return false

	var original_output: Transform3D = output.transform
	output.transform = corner_output.transform
	if not belt.try_connect_building_port(port):
		output.transform = original_output
		template.free()
		return false

	mesh.mesh = generated_mesh
	mesh.transform = corner_mesh.transform
	body.shape = corner_body.shape.duplicate(true)
	body.transform = corner_body.transform
	hitbox.shape = corner_hitbox.shape.duplicate(true)
	hitbox.transform = corner_hitbox.transform
	belt.set_meta("conveyor_turn", turn)
	template.free()
	return true


# =============================================================================
# READ-ONLY IN-GAME TERMINAL CORNER INSPECTION
# =============================================================================

# Called only when the player requests a placement diagnostic.
# Does not move any object, change a connection, or transfer cargo.

static func inspect_at_cursor(
	tree: SceneTree,
	world: World3D,
	mouse_world_position: Vector3,
	collision_mask: int,
	search_radius: float = 0.65
) -> void:
	if tree == null:
		return

	print("TERMINAL INSPECT | Cursor grid: ", mouse_world_position)

	var nearest: ConveyorSegment = null
	var best_squared: float = search_radius * search_radius
	for node: Node in tree.get_nodes_in_group("player_built"):
		if not node is ConveyorSegment:
			continue
		var belt := node as ConveyorSegment
		if belt.is_queued_for_deletion() or belt.is_in_group("construction_preview"):
			continue
		var delta := Vector2(
			mouse_world_position.x - belt.global_position.x,
			mouse_world_position.z - belt.global_position.z
		)
		var distance_squared: float = delta.length_squared()
		if distance_squared <= best_squared:
			nearest = belt
			best_squared = distance_squared

	if nearest == null:
		print("TERMINAL INSPECT | No existing conveyor centered on this tile.")
		return

	print(
		"TERMINAL INSPECT | Belt: ", nearest.name,
		" at ", nearest.global_position,
		" | rotation Y: ", nearest.rotation_degrees.y,
		" | next_busy: ", is_instance_valid(nearest.next_segment),
		" | output_port_busy: ", is_instance_valid(nearest.output_building_port),
		" | already_corner: ", nearest.has_meta("conveyor_turn")
	)

	var input_port: ItemPortComponent = null
	var best_port_squared: float = 4.0
	for building: Node in tree.get_nodes_in_group("player_built"):
		if not building is Node3D or building is ConveyorSegment:
			continue
		if building.is_queued_for_deletion() or building.is_in_group("construction_preview"):
			continue
		for child: Node in building.get_children():
			if not child is ItemPortComponent:
				continue
			var port := child as ItemPortComponent
			if port.direction != ItemPortComponent.PortDirection.INPUT:
				continue
			var delta := Vector2(
				port.global_position.x - nearest.global_position.x,
				port.global_position.z - nearest.global_position.z
			)
			var d2: float = delta.length_squared()
			if d2 < best_port_squared:
				best_port_squared = d2
				input_port = port

	if input_port == null:
		print("TERMINAL INSPECT | No building INPUT within two tiles.")
		return

	print(
		"TERMINAL INSPECT | Nearest input: ",
		input_port.get_parent().name, "/", input_port.name,
		" at ", input_port.global_position,
		" | occupied: ", is_instance_valid(input_port.connected_conveyor),
		" | inventory_valid: ", is_instance_valid(input_port.inventory)
	)

	for turn: int in [
		ConveyorTurnIntent.Turn.LEFT,
		ConveyorTurnIntent.Turn.RIGHT
	]:
		var label: String = (
			"LEFT" if turn == ConveyorTurnIntent.Turn.LEFT else "RIGHT"
		)
		var scene: PackedScene = ConveyorPieceSelector.get_scene_for_turn(turn)
		if scene == null:
			continue
		var template := scene.instantiate() as ConveyorSegment
		if template == null:
			continue
		var output := template.get_node_or_null("OutputEndpoint") as Marker3D
		if output == null:
			template.free()
			continue
		var proposed: Transform3D = nearest.global_transform * output.transform
		var direction_a: Vector3 = (
			proposed.basis * Vector3.FORWARD
		).normalized()
		var direction_b: Vector3 = (
			input_port.global_transform.basis * Vector3.FORWARD
		).normalized()
		var candidate: Dictionary = inspect_pair(nearest, input_port, turn)
		print(
			"TERMINAL INSPECT | ", label,
			" | gap: ", proposed.origin.distance_to(input_port.global_position),
			" | facing_dot: ", direction_a.dot(direction_b),
			" | exact_candidate: ", not candidate.is_empty(),
			" | clearance: ",
			(is_clear(world, candidate, collision_mask) if not candidate.is_empty() else false)
		)
		template.free()

	var found: Dictionary = find_nearest(
		tree, mouse_world_position, search_radius
	)
	print(
		"TERMINAL INSPECT | Discovery result: ",
		("MATCH" if not found.is_empty() else "NO MATCH")
	)
