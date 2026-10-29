
extends RefCounted
class_name ConveyorMissingCornerPlacement


# =============================================================================
# CHAT 08.3G-3D-2 — PERMANENT MISSING CORNER PLACEMENT
# =============================================================================

# Inserts one transport-capable conveyor corner between
# two existing conveyor lines.
#
# Uses a STRAIGHT conveyor as the permanent object so
# inventory, transport, selection and demolition remain.
#
# Applies corner geometry from the corner scene.
#
# Revalidates the candidate before construction.
# Restores connections if either link fails.


# =============================================================================
# PLACE AND CONNECT MISSING CORNER
# =============================================================================

static func try_place(
	parent: Node3D,
	candidate: Dictionary
) -> ConveyorSegment:

	if not is_instance_valid(parent):
		return null

	if not parent.is_inside_tree():
		return null

	if candidate.is_empty():
		return null

	if not candidate.has("transform"):
		return null

	var source: ConveyorSegment = (
		candidate.get("source") as ConveyorSegment
	)

	var destination: ConveyorSegment = (
		candidate.get("destination") as ConveyorSegment
	)

	if not is_instance_valid(source):
		return null

	if not is_instance_valid(destination):
		return null

	var turn: int = int(candidate.get("turn", -1))

	# =============================================================================
	# REVALIDATE SAVED DISCOVERY
	# =============================================================================

	var fresh: Dictionary = (
		ConveyorMissingCornerPreview.preview_for_pair(
			source,
			destination,
			turn
		)
	)

	if fresh.is_empty():
		return null

	var desired: Transform3D = fresh["transform"]
	var saved: Transform3D = candidate["transform"]

	if not desired.is_equal_approx(saved):
		return null

	# =============================================================================
	# REJECT AN EXISTING CONVEYOR IN THE CORNER TILE
	# =============================================================================

	# This is a basic conveyor occupancy check.
	# Full building/physics collision validation is
	# handled during Build Mode integration.

	for node: Node in parent.get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		var existing := node as ConveyorSegment

		if existing.is_queued_for_deletion():
			continue

		if existing.is_in_group("construction_preview"):
			continue

		var offset := Vector2(
			existing.global_position.x - desired.origin.x,
			existing.global_position.z - desired.origin.z
		)

		if offset.length_squared() < 0.01:
			return null

	# =============================================================================
	# PREPARE CORNER GEOMETRY TEMPLATE
	# =============================================================================

	var corner_scene: PackedScene = (
		ConveyorPieceSelector.get_scene_for_turn(turn)
	)

	if corner_scene == null:
		return null

	var template := (
		corner_scene.instantiate() as ConveyorSegment
	)

	if template == null:
		return null

	# =============================================================================
	# CREATE TRANSPORT-CAPABLE CONVEYOR
	# =============================================================================

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	if belt == null:
		template.free()
		return null

	var belt_input := (
		belt.get_node_or_null("InputEndpoint") as Marker3D
	)

	var belt_output := (
		belt.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var belt_mesh := (
		belt.get_node_or_null("BeltMesh") as MeshInstance3D
	)

	var belt_body := (
		belt.get_node_or_null(
			"ConveyorBody/ConveyorBody"
		) as CollisionShape3D
	)

	var belt_hitbox := (
		belt.get_node_or_null(
			"InteractionHitbox/InteractionHitbox"
		) as CollisionShape3D
	)

	var template_input := (
		template.get_node_or_null("InputEndpoint") as Marker3D
	)

	var template_output := (
		template.get_node_or_null("OutputEndpoint") as Marker3D
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
		belt_input == null
		or belt_output == null
		or belt_mesh == null
		or belt_body == null
		or belt_hitbox == null
		or template_input == null
		or template_output == null
		or template_mesh == null
		or template_body == null
		or template_hitbox == null
	):
		belt.free()
		template.free()
		return null

	if (
		template_body.shape == null
		or template_hitbox.shape == null
	):
		belt.free()
		template.free()
		return null

	# =============================================================================
	# APPLY CORNER VISUAL AND PHYSICAL GEOMETRY
	# =============================================================================

	var corner_mesh: ArrayMesh = (
		ConveyorCornerVisualMesh.build(turn)
	)

	if corner_mesh == null:
		belt.free()
		template.free()
		return null

	belt_input.transform = template_input.transform
	belt_output.transform = template_output.transform

	belt_mesh.mesh = corner_mesh
	belt_mesh.transform = template_mesh.transform

	belt_body.shape = template_body.shape.duplicate(true)
	belt_body.transform = template_body.transform

	belt_hitbox.shape = template_hitbox.shape.duplicate(true)
	belt_hitbox.transform = template_hitbox.transform

	belt.set_meta("conveyor_turn", turn)

	template.free()

	# =============================================================================
	# PLACE PERMANENT OBJECT
	# =============================================================================

	parent.add_child(belt)
	belt.global_transform = desired

	# =============================================================================
	# CONNECT SOURCE -> NEW CORNER
	# =============================================================================

	if not source.try_connect_to(belt):
		belt.free()
		return null

	# =============================================================================
	# CONNECT NEW CORNER -> DESTINATION
	# =============================================================================

	if not belt.try_connect_to(destination):

		# Roll back the first connection before removing
		# the new conveyor.

		source.disconnect_next()
		belt.free()
		return null

	# =============================================================================
	# SUCCESS
	# =============================================================================

	return belt
