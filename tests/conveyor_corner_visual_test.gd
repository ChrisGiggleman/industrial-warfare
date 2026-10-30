
extends Node3D


# =============================================================================
# CORNER VISUAL GEOMETRY TEST
# =============================================================================

# Validates the generated L-shaped meshes.
#
# Also creates two visible examples in an isolated scene:
# RIGHT on the left side of the screen.
# LEFT on the right side of the screen.
#
# Does not modify construction or existing conveyors.


func _ready() -> void:

	print("\n===== CHAT 07: CORNER VISUAL TEST =====")

	# =============================================================================
	# GENERATE BOTH CORNER MESHES
	# =============================================================================

	var right_mesh: ArrayMesh = (
		ConveyorCornerVisualMesh.build(
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	var left_mesh: ArrayMesh = (
		ConveyorCornerVisualMesh.build(
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	assert(right_mesh != null)
	assert(left_mesh != null)

	print("PASS A: Both corner meshes generated")

	# =============================================================================
	# VERIFY GEOMETRY SURFACES
	# =============================================================================

	assert(right_mesh.get_surface_count() == 1)
	assert(left_mesh.get_surface_count() == 1)

	print("PASS B: Each corner uses one mesh surface")

	# =============================================================================
	# VERIFY RIGHT CORNER EXTENT
	# =============================================================================

	var right_bounds: AABB = right_mesh.get_aabb()

	assert(absf(right_bounds.end.x - 0.5) < 0.01)

	print("PASS C: Right corner reaches +X output")

	# =============================================================================
	# VERIFY LEFT CORNER EXTENT
	# =============================================================================

	var left_bounds: AABB = left_mesh.get_aabb()

	assert(absf(left_bounds.position.x + 0.5) < 0.01)

	print("PASS D: Left corner reaches -X output")

	# =============================================================================
	# VERIFY INPUT EXTENTS
	# =============================================================================

	assert(absf(right_bounds.end.z - 0.5) < 0.01)
	assert(absf(left_bounds.end.z - 0.5) < 0.01)

	print("PASS E: Both corners reach incoming endpoint")

	# =============================================================================
	# VERIFY MESH HEIGHT
	# =============================================================================

	assert(absf(right_bounds.size.y - 0.2) < 0.01)
	assert(absf(left_bounds.size.y - 0.2) < 0.01)

	print("PASS F: Corner height matches straight belt")

	# =============================================================================
	# VERIFY MATERIAL
	# =============================================================================

	assert(right_mesh.surface_get_material(0) != null)
	assert(left_mesh.surface_get_material(0) != null)

	print("PASS G: Both corners have visual materials")

	# =============================================================================
	# VERIFY INVALID TURN REJECTION
	# =============================================================================

	assert(ConveyorCornerVisualMesh.build(-1) == null)

	print("PASS H: Invalid turn safely rejected")

	# =============================================================================
	# DISPLAY BOTH MESHES
	# =============================================================================

	var right_display := MeshInstance3D.new()
	right_display.name = "RightCornerPreview"
	right_display.mesh = right_mesh
	right_display.position = Vector3(-1.3, 0.3, 0.0)
	add_child(right_display)

	var left_display := MeshInstance3D.new()
	left_display.name = "LeftCornerPreview"
	left_display.mesh = left_mesh
	left_display.position = Vector3(1.3, 0.3, 0.0)
	add_child(left_display)

	# =============================================================================
	# ADD TEST CAMERA
	# =============================================================================

	var camera := Camera3D.new()
	camera.name = "CornerTestCamera"

	add_child(camera)

	camera.position = Vector3(0.0, 4.0, 5.0)
	camera.look_at(Vector3(0.0, 0.3, 0.0))
	camera.current = true

	# =============================================================================
	# ADD TEST LIGHT
	# =============================================================================

	var light := DirectionalLight3D.new()
	light.name = "CornerTestLight"

	add_child(light)
	light.rotation_degrees = Vector3(-45.0, -25.0, 0.0)

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 8 CORNER VISUAL TESTS PASSED")
	print("==========================================")
