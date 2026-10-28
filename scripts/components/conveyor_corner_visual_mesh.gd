
extends RefCounted
class_name ConveyorCornerVisualMesh


# =============================================================================
# INDUSTRIAL WARFARE — FILLED CONVEYOR CORNER MESH
# =============================================================================

# Creates a single continuous mesh for right and left turns.
#
# Unlike the previous version, this mesh does not use
# overlapping BoxMesh objects.
#
# Input reaches local Z +0.5.
# Right output reaches local X +0.5.
# Left output reaches local X -0.5.
#
# Connection markers and physics are unchanged.


# =============================================================================
# CORNER GEOMETRY SETTINGS
# =============================================================================

const BELT_WIDTH: float = 0.8
const BELT_HEIGHT: float = 0.2
const HALF_CELL: float = 0.5


# =============================================================================
# CREATE CORNER MESH
# =============================================================================

static func build(turn: int) -> ArrayMesh:

	var side: float = 0.0

	if turn == ConveyorTurnIntent.Turn.RIGHT:
		side = 1.0

	elif turn == ConveyorTurnIntent.Turn.LEFT:
		side = -1.0

	else:
		return null

	# =============================================================================
	# CREATE FILLED CORNER OUTLINE
	# =============================================================================

	# The outline forms one continuous turning platform.
	#
	# Its input and output edges match the 0.8m width
	# of our straight conveyor.
	#
	# The central bend is filled rather than assembled
	# from overlapping rectangles.

	var half_width: float = BELT_WIDTH * 0.5

	var outline := PackedVector2Array([
		Vector2(-half_width * side, HALF_CELL),
		Vector2(half_width * side, HALF_CELL),
		Vector2(half_width * side, half_width),
		Vector2(HALF_CELL * side, half_width),
		Vector2(HALF_CELL * side, -half_width),
		Vector2(-half_width * side, -half_width)
	])

	# =============================================================================
	# TRIANGULATE CORNER SURFACE
	# =============================================================================

	var triangles: PackedInt32Array = (
		Geometry2D.triangulate_polygon(outline)
	)

	if triangles.is_empty():
		return null

	# =============================================================================
	# CREATE MATERIAL
	# =============================================================================

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.392,
		0.467,
		0.514
	)

	material.metallic = 0.2
	material.roughness = 0.8

	# =============================================================================
	# INITIALIZE MESH
	# =============================================================================

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_material(material)

	var half_height: float = BELT_HEIGHT * 0.5

	# =============================================================================
	# GENERATE TOP AND BOTTOM SURFACES
	# =============================================================================

	# Godot triangulates the 2D polygon counterclockwise.
	# Reverse the vertex order for the upward-facing top.

	for i in range(0, triangles.size(), 3):

		var a: Vector2 = outline[triangles[i]]
		var b: Vector2 = outline[triangles[i + 1]]
		var c: Vector2 = outline[triangles[i + 2]]

		var top_a := Vector3(a.x, half_height, a.y)
		var top_b := Vector3(b.x, half_height, b.y)
		var top_c := Vector3(c.x, half_height, c.y)

		_add_triangle(
			surface,
			top_a,
			top_c,
			top_b,
			Vector3.UP
		)

		var bottom_a := Vector3(a.x, -half_height, a.y)
		var bottom_b := Vector3(b.x, -half_height, b.y)
		var bottom_c := Vector3(c.x, -half_height, c.y)

		_add_triangle(
			surface,
			bottom_a,
			bottom_b,
			bottom_c,
			Vector3.DOWN
		)

	# =============================================================================
	# GENERATE OUTER SIDE WALLS
	# =============================================================================

	# Each outline edge receives two triangles.
	# Mirrored left-turn outlines use reversed winding.

	for i in range(outline.size()):

		var start: Vector2 = outline[i]
		var finish: Vector2 = outline[
			(i + 1) % outline.size()
		]

		var edge: Vector2 = finish - start

		var normal := Vector3(
			-edge.y,
			0.0,
			edge.x
		).normalized() * side

		var top_start := Vector3(
			start.x, half_height, start.y
		)

		var top_finish := Vector3(
			finish.x, half_height, finish.y
		)

		var bottom_start := Vector3(
			start.x, -half_height, start.y
		)

		var bottom_finish := Vector3(
			finish.x, -half_height, finish.y
		)

		if side > 0.0:

			_add_triangle(
				surface,
				top_start,
				bottom_start,
				top_finish,
				normal
			)

			_add_triangle(
				surface,
				top_finish,
				bottom_start,
				bottom_finish,
				normal
			)

		else:

			_add_triangle(
				surface,
				top_start,
				top_finish,
				bottom_start,
				normal
			)

			_add_triangle(
				surface,
				top_finish,
				bottom_finish,
				bottom_start,
				normal
			)

	# =============================================================================
	# RETURN FINISHED CORNER MESH
	# =============================================================================

	return surface.commit()


# =============================================================================
# ADD ONE TRIANGLE
# =============================================================================

# Shared helper for top, bottom, and side surfaces.

static func _add_triangle(
	surface: SurfaceTool,
	a: Vector3,
	b: Vector3,
	c: Vector3,
	normal: Vector3
) -> void:

	surface.set_normal(normal)
	surface.add_vertex(a)

	surface.set_normal(normal)
	surface.add_vertex(b)

	surface.set_normal(normal)
	surface.add_vertex(c)
