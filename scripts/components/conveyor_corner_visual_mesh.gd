
extends RefCounted
class_name ConveyorCornerVisualMesh


# =============================================================================
# CONVEYOR CORNER VISUAL GEOMETRY
# =============================================================================

# Builds one combined ArrayMesh for either turn direction.
#
# The visual shape contains:
# - An incoming straight section along Z
# - An outgoing section along +X or -X
#
# The geometry fits inside one conveyor grid cell.
#
# This class changes visual geometry only.
# It does not modify physical connections or collisions.



# =============================================================================
# CORNER GEOMETRY SETTINGS
# =============================================================================

# Match the existing straight conveyor width.
# This prevents the visible narrowing at connections.

const BELT_WIDTH: float = 0.8

# Match the straight conveyor's mesh height.

const BELT_HEIGHT: float = 0.2

# Each arm extends to the appropriate grid-cell edge.
#
# ARM_LENGTH / 2 + ARM_OFFSET = 0.5
#
# This keeps the corner inside its intended cell
# while allowing it to meet neighboring straight belts.

const ARM_LENGTH: float = 0.6
const ARM_OFFSET: float = 0.2



# =============================================================================
# CREATE A SINGLE L-SHAPED MESH
# =============================================================================

static func build(turn: int) -> ArrayMesh:

	# =============================================================================
	# VALIDATE TURN DIRECTION
	# =============================================================================

	var side: float = 0.0

	if turn == ConveyorTurnIntent.Turn.RIGHT:
		side = 1.0

	elif turn == ConveyorTurnIntent.Turn.LEFT:
		side = -1.0

	else:
		return null

	# =============================================================================
	# CREATE INCOMING BELT ARM
	# =============================================================================

	# This section reaches the input at local Z +0.5.

	var incoming_box := BoxMesh.new()

	incoming_box.size = Vector3(
		BELT_WIDTH,
		BELT_HEIGHT,
		ARM_LENGTH
	)

	# =============================================================================
	# CREATE OUTGOING BELT ARM
	# =============================================================================

	# This section reaches local X +0.5 for RIGHT
	# or X -0.5 for LEFT.

	var outgoing_box := BoxMesh.new()

	outgoing_box.size = Vector3(
		ARM_LENGTH,
		BELT_HEIGHT,
		BELT_WIDTH
	)

	# =============================================================================
	# PREPARE SURFACE TOOL
	# =============================================================================

	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# =============================================================================
	# FACTORY BELT PLACEHOLDER MATERIAL
	# =============================================================================

	var belt_material := StandardMaterial3D.new()

	belt_material.albedo_color = Color(
		0.392,
		0.467,
		0.514
	)

	belt_material.metallic = 0.2
	belt_material.roughness = 0.8

	surface_tool.set_material(belt_material)

	# =============================================================================
	# COMBINE THE TWO BELT ARMS
	# =============================================================================

	# Both boxes use coordinates relative to BeltMesh.
	#
	# BeltMesh itself remains at Y = 0.3,
	# as in our existing conveyor scenes.

	surface_tool.append_from(
		incoming_box,
		0,
		Transform3D(
			Basis.IDENTITY,
			Vector3(0.0, 0.0, ARM_OFFSET)
		)
	)

	surface_tool.append_from(
		outgoing_box,
		0,
		Transform3D(
			Basis.IDENTITY,
			Vector3(side * ARM_OFFSET, 0.0, 0.0)
		)
	)

	# =============================================================================
	# GENERATE THE COMBINED MESH
	# =============================================================================

	var result: ArrayMesh = surface_tool.commit()

	return result
