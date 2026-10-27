
extends MeshInstance3D


# =============================================================================
# INDUSTRIAL WARFARE — CONVEYOR DIRECTION ARROW
# =============================================================================

# Displays the direction items travel along a conveyor.
#
# Attach this script to a MeshInstance3D child of OutputEndpoint.
#
# The arrow:
# - Points along local -Z (forward).
# - Automatically rotates with OutputEndpoint.
# - Works when a straight conveyor becomes a corner.
# - Appears on placed conveyors and placement ghosts.
# - Does not affect physics, inventory, or connections.


# =============================================================================
# ARROW VISUAL SETTINGS
# =============================================================================

# Bright yellow for visibility against gray conveyor belts.

const ARROW_COLOR: Color = Color(1.0, 0.9, 0.15)

# The arrow lies slightly above the conveyor's top surface.
#
# OutputEndpoint is at Y = 0.5.
# The belt surface is approximately Y = 0.4.
#
# Moving down 0.07 places the arrow at Y = 0.43.
#
# Moving backward 0.25 places it inside the output end.

const ARROW_LOCAL_POSITION: Vector3 = Vector3(
	0.0,
	-0.07,
	0.25
)


# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:

	# Position relative to our parent OutputEndpoint.

	position = ARROW_LOCAL_POSITION

	# Prevent directional markers from casting shadows.

	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Create our arrow geometry.

	mesh = _create_arrow_mesh()

	# =============================================================================
	# CREATE HIGH-VISIBILITY MATERIAL
	# =============================================================================

	var arrow_material := StandardMaterial3D.new()

	arrow_material.albedo_color = ARROW_COLOR

	# Remain bright even in poorly lit factories.

	arrow_material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)

	# Make the arrow visible from either side.

	arrow_material.cull_mode = (
		BaseMaterial3D.CULL_DISABLED
	)

	# Keep the arrow yellow even when its conveyor
	# is displayed as a green or red placement ghost.

	material_override = arrow_material


# =============================================================================
# GENERATE DIRECTION ARROW MESH
# =============================================================================

# Constructs a flat arrow from three triangles:
#
# - Two triangles form the narrow arrow shaft.
# - One triangle forms the arrowhead.
#
# The pointed end faces local -Z.
#
# Because this node is a child of OutputEndpoint,
# the arrow follows the endpoint's rotation.

func _create_arrow_mesh() -> ArrayMesh:

	# =============================================================================
	# DEFINE ARROW VERTICES
	# =============================================================================

	var vertices := PackedVector3Array([

		# -------------------------------------------------------------
		# SHAFT — TRIANGLE 1
		# -------------------------------------------------------------

		Vector3(-0.055, 0.0, 0.14),
		Vector3(0.055, 0.0, 0.14),
		Vector3(0.055, 0.0, -0.03),

		# -------------------------------------------------------------
		# SHAFT — TRIANGLE 2
		# -------------------------------------------------------------

		Vector3(-0.055, 0.0, 0.14),
		Vector3(0.055, 0.0, -0.03),
		Vector3(-0.055, 0.0, -0.03),

		# -------------------------------------------------------------
		# ARROWHEAD — TRIANGLE 3
		# -------------------------------------------------------------

		Vector3(-0.16, 0.0, -0.03),
		Vector3(0.16, 0.0, -0.03),
		Vector3(0.0, 0.0, -0.23)
	])

	# =============================================================================
	# CREATE COMBINED ARROW MESH
	# =============================================================================

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices

	var arrow_mesh := ArrayMesh.new()

	arrow_mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)

	return arrow_mesh
