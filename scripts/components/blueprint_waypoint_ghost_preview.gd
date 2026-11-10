extends Node3D
class_name BlueprintWaypointGhostPreview

# =============================================================================
# E3D3C — VISUAL-ONLY MULTI-WAYPOINT ROUTE PREVIEW
# =============================================================================
# Translucent, pooled 3D tiles. Never creates collision, construction sites,
# endpoint reservations, inventory, or completed conveyors.
# WorldInteraction supplies the exact BlueprintWaypointRoute geometry.

const MAX_TILES: int = BlueprintStraightRoute.MAX_SEGMENTS

var displayed_count: int = 0
var preview_valid: bool = true

var _tile_nodes: Array[Node3D] = []
var _tile_meshes: Array[MeshInstance3D] = []
var _tile_materials: Array[StandardMaterial3D] = []
var _tile_arrows: Array[Label3D] = []
var _invalid_marker: MeshInstance3D = null


func _ready() -> void:
	_build_pool()
	clear_preview()


func _build_pool() -> void:
	var shared_mesh := BoxMesh.new()
	shared_mesh.size = Vector3(0.92, 0.065, 0.92)
	for index: int in range(MAX_TILES):
		var tile_node := Node3D.new()
		tile_node.name = "PreviewTile%02d" % index
		add_child(tile_node)
		_tile_nodes.append(tile_node)

		var tile_mesh := MeshInstance3D.new()
		tile_mesh.name = "GhostTile"
		tile_mesh.mesh = shared_mesh
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.2, 0.7, 1.0, 0.32)
		tile_mesh.material_override = material
		tile_node.add_child(tile_mesh)
		_tile_meshes.append(tile_mesh)
		_tile_materials.append(material)

		# The same local -Z arrow convention as ConstructionSite.
		var arrow := Label3D.new()
		arrow.name = "FlowArrow"
		arrow.text = "↑"
		arrow.font_size = 52
		arrow.pixel_size = 0.005
		arrow.modulate = Color(1.0, 0.9, 0.28)
		arrow.position.y = 0.12
		arrow.rotation.x = -PI * 0.5
		tile_node.add_child(arrow)
		_tile_arrows.append(arrow)

	_invalid_marker = MeshInstance3D.new()
	_invalid_marker.name = "InvalidEndpoint"
	var invalid_mesh := BoxMesh.new()
	invalid_mesh.size = Vector3(0.96, 0.08, 0.96)
	_invalid_marker.mesh = invalid_mesh
	var invalid_material := StandardMaterial3D.new()
	invalid_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	invalid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	invalid_material.albedo_color = Color(1.0, 0.20, 0.17, 0.60)
	_invalid_marker.material_override = invalid_material
	add_child(_invalid_marker)


func show_route(
	tiles: Array[Transform3D],
	fixed_count: int,
	valid: bool,
	invalid_endpoint: Vector3 = Vector3.INF
) -> void:
	if _tile_nodes.is_empty():
		return
	preview_valid = valid
	displayed_count = mini(tiles.size(), MAX_TILES)
	for index: int in range(MAX_TILES):
		var tile_node: Node3D = _tile_nodes[index]
		tile_node.visible = index < displayed_count
		if index >= displayed_count:
			continue
		var original: Transform3D = tiles[index]
		var render_transform: Transform3D = original
		render_transform.origin += Vector3.UP * 0.19
		tile_node.global_transform = render_transform

		var is_bend: bool = false
		var arrow_basis: Basis = original.basis
		if index + 1 < displayed_count:
			var next_basis: Basis = tiles[index + 1].basis
			var entering: Vector3 = original.basis * Vector3.FORWARD
			var leaving: Vector3 = next_basis * Vector3.FORWARD
			if entering.dot(leaving) < 0.9:
				is_bend = true
				arrow_basis = next_basis

		# Fixed waypoints are blue; the uncommitted next leg is green.
		# Invalid/blocked proposed legs use red without hiding the fixed path.
		var color := Color(0.16, 0.63, 1.0, 0.30)
		if index >= fixed_count:
			color = (
				Color(0.22, 0.96, 0.47, 0.40) if valid
				else Color(1.0, 0.25, 0.20, 0.46)
			)
		if is_bend and valid:
			color = Color(0.99, 0.72, 0.22, 0.45)
		_tile_materials[index].albedo_color = color
		_tile_arrows[index].transform.basis = (
			original.basis.inverse() * arrow_basis
			* Basis(Vector3.RIGHT, -PI * 0.5)
		)

	_invalid_marker.visible = not valid and invalid_endpoint.is_finite()
	if _invalid_marker.visible:
		_invalid_marker.global_position = invalid_endpoint + Vector3.UP * 0.22


func clear_preview() -> void:
	displayed_count = 0
	preview_valid = true
	for node: Node3D in _tile_nodes:
		node.visible = false
	if is_instance_valid(_invalid_marker):
		_invalid_marker.visible = false


func is_invalid_marker_visible() -> bool:
	return is_instance_valid(_invalid_marker) and _invalid_marker.visible
