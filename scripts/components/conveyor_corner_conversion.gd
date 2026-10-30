
extends RefCounted
class_name ConveyorCornerConversion


# =============================================================================
# IN-PLACE CONVEYOR CORNER CONVERSION
# =============================================================================

# Converts an existing straight conveyor into a corner
# when a newly placed perpendicular straight can connect.
#
# The preceding conveyor keeps:
# - Its original node identity
# - Its current world transform
# - Its existing incoming connection
# - Its selection and demolition behavior
#
# The new conveyor remains straight.
#
# Failed conversions leave both segments unchanged.


# =============================================================================
# CONVERT PREVIOUS STRAIGHT AND CONNECT NEXT
# =============================================================================

static func try_convert_and_connect(
	source: ConveyorSegment,
	receiver: ConveyorSegment,
	turn: int
) -> bool:

	# =============================================================================
	# VALIDATE BOTH CONVEYORS
	# =============================================================================

	if not is_instance_valid(source):
		return false

	if not is_instance_valid(receiver):
		return false

	if source == receiver:
		return false

	if not source.is_inside_tree() or not receiver.is_inside_tree():
		return false

	# Do not overwrite an existing outgoing connection.
	# Do not attach to an already occupied incoming port.

	if is_instance_valid(source.next_segment):
		return false

	if is_instance_valid(receiver.previous_segment):
		return false

	# =============================================================================
	# VALIDATE TURN DIRECTION
	# =============================================================================

	if (
		turn != ConveyorTurnIntent.Turn.RIGHT
		and turn != ConveyorTurnIntent.Turn.LEFT
	):
		return false

	# =============================================================================
	# FIND THE ORIGINAL STRAIGHT OUTPUT
	# =============================================================================

	var source_output: Marker3D = (
		source.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var receiver_input: Marker3D = (
		receiver.get_node_or_null("InputEndpoint") as Marker3D
	)

	if source_output == null or receiver_input == null:
		return false

	# Only an unconverted straight belt is eligible.
	# This comparison uses LOCAL coordinates, so rotating
	# the entire belt does not invalidate the check.

	if not source_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return false

	# =============================================================================
	# LOAD THE CORRECT CORNER TEMPLATE
	# =============================================================================

	var template_scene: PackedScene = (
		ConveyorPieceSelector.get_scene_for_turn(turn)
	)

	if template_scene == null:
		return false

	var instance: Node = template_scene.instantiate()

	if not instance is ConveyorSegment:
		if instance != null:
			instance.free()
		return false

	var template: ConveyorSegment = instance as ConveyorSegment

	# =============================================================================
	# COLLECT MESH AND COLLISION REFERENCES
	# =============================================================================

	var source_mesh: MeshInstance3D = (
		source.get_node_or_null("BeltMesh") as MeshInstance3D
	)

	var source_body: CollisionShape3D = (
		source.get_node_or_null("ConveyorBody/ConveyorBody")
		as CollisionShape3D
	)

	var source_hitbox: CollisionShape3D = (
		source.get_node_or_null(
			"InteractionHitbox/InteractionHitbox"
		) as CollisionShape3D
	)

	var template_output: Marker3D = (
		template.get_node_or_null("OutputEndpoint") as Marker3D
	)

	var template_mesh: MeshInstance3D = (
		template.get_node_or_null("BeltMesh") as MeshInstance3D
	)

	var template_body: CollisionShape3D = (
		template.get_node_or_null("ConveyorBody/ConveyorBody")
		as CollisionShape3D
	)

	var template_hitbox: CollisionShape3D = (
		template.get_node_or_null(
			"InteractionHitbox/InteractionHitbox"
		) as CollisionShape3D
	)

	if (
		source_mesh == null
		or source_body == null
		or source_hitbox == null
		or template_output == null
		or template_mesh == null
		or template_body == null
		or template_hitbox == null
	):
		template.free()
		return false

	if (
		template_mesh.mesh == null
		or template_body.shape == null
		or template_hitbox.shape == null
	):
		template.free()
		return false

	# =============================================================================
	# PREPARE INDEPENDENT GEOMETRY RESOURCES
	# =============================================================================

	# Duplicate resources to avoid accidentally modifying
	# another conveyor or its saved PackedScene.

	
	# =============================================================================
	# GENERATE VISIBLE L-SHAPED CONVEYOR MESH
	# =============================================================================

	# Build the correct visual shape for the turn.
	#
	# RIGHT creates an incoming section with an
	# outgoing arm toward local +X.
	#
	# LEFT creates the mirrored shape toward local -X.
	#
	# This changes the visual geometry only.
	# Physical connection geometry remains unchanged.

	var corner_mesh: ArrayMesh = (
		ConveyorCornerVisualMesh.build(turn)
	)

	# =============================================================================
	# VALIDATE GENERATED CORNER MESH
	# =============================================================================

	if corner_mesh == null:
		template.free()
		return false


	var corner_body_shape: Shape3D = (
		template_body.shape.duplicate(true) as Shape3D
	)

	var corner_hitbox_shape: Shape3D = (
		template_hitbox.shape.duplicate(true) as Shape3D
	)

	# =============================================================================
	# TEMPORARILY APPLY THE CORNER OUTPUT
	# =============================================================================

	# Preserve the straight output transform in case
	# the proposed connection is invalid.

	var original_output_transform: Transform3D = (
		source_output.transform
	)

	source_output.transform = template_output.transform

	# =============================================================================
	# VALIDATE AND ESTABLISH THE CONNECTION
	# =============================================================================

	# try_connect_to() already checks endpoint geometry,
	# direction, distance, and occupied connection state.

	if not source.try_connect_to(receiver):

		# Restore the original straight conveyor.
		# Its mesh and collision shapes were not changed.

		source_output.transform = original_output_transform
		template.free()
		return false

	# =============================================================================
	# COMMIT THE NEW CORNER APPEARANCE
	# =============================================================================

	# Connection succeeded. The original source object
	# now receives the corner's visual/physical geometry.

	source_mesh.mesh = corner_mesh
	source_mesh.transform = template_mesh.transform

	source_body.shape = corner_body_shape
	source_body.transform = template_body.transform

	source_hitbox.shape = corner_hitbox_shape
	source_hitbox.transform = template_hitbox.transform

	# Record the runtime shape for future systems.
	# Persistent save/load support will be added later.

	source.set_meta("conveyor_turn", turn)

	# =============================================================================
	# CLEANUP AND SUCCESS
	# =============================================================================

	template.free()
	return true
