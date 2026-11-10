extends RefCounted
class_name BlueprintAreaSelectionQuery

# =============================================================================
# BLUEPRINT AREA SELECTION — PROJECTED FOOTPRINT QUERY
# =============================================================================
# Uses the four rotated footprint corners instead of requiring a site center
# inside the drag. SAT prevents false selection at corners of a projected AABB.
# Read-only: no job changes, input, collisions, or temporary route ghosts.

static func find_planned(
	camera: Camera3D,
	screen_rectangle: Rect2,
	world_root: Node3D
) -> Array[ConstructionSite]:
	var selected: Array[ConstructionSite] = []
	if not is_instance_valid(camera) or not is_instance_valid(world_root):
		return selected
	var bounds: Rect2 = screen_rectangle.abs()
	if bounds.size.x < 1.0 or bounds.size.y < 1.0:
		return selected

	for member: Node in world_root.get_tree().get_nodes_in_group(
		"construction_sites"
	):
		if not member is ConstructionSite:
			continue
		var site: ConstructionSite = member as ConstructionSite
		if (
			not is_instance_valid(site)
			or site.is_queued_for_deletion()
			or not site.is_inside_tree()
			or site.get_parent() != world_root
			or site.job == null
			or site.job.state != ConstructionJob.State.PLANNED
		):
			continue
		var footprint: Array[Vector2] = projected_footprint(camera, site)
		if footprint.size() != 4:
			continue
		if footprint_intersects_rectangle(footprint, bounds):
			selected.append(site)
	return selected


static func projected_footprint(
	camera: Camera3D,
	site: ConstructionSite
) -> Array[Vector2]:
	var result: Array[Vector2] = []
	if not is_instance_valid(camera) or not is_instance_valid(site):
		return result
	# Same local X/Z dimensions as ConstructionSite's reserved footprint.
	# Multiplying by the complete transform handles rotated buildings.
	var half_x: float = float(site.footprint.x) * 0.5
	var half_z: float = float(site.footprint.y) * 0.5
	var local_corners: Array[Vector3] = [
		Vector3(-half_x, 0.35, -half_z),
		Vector3(half_x, 0.35, -half_z),
		Vector3(half_x, 0.35, half_z),
		Vector3(-half_x, 0.35, half_z)
	]
	for local_corner: Vector3 in local_corners:
		var world_corner: Vector3 = site.global_transform * local_corner
		# Skip footprints crossing behind the camera. Screen projection
		# cannot represent that polygon without near-plane clipping.
		if camera.is_position_behind(world_corner):
			result.clear()
			return result
		result.append(camera.unproject_position(world_corner))
	return result


static func footprint_intersects_rectangle(
	footprint: Array[Vector2],
	rectangle: Rect2
) -> bool:
	if footprint.size() != 4:
		return false
	var rect: Rect2 = rectangle.abs()
	if rect.size.x < 1.0 or rect.size.y < 1.0:
		return false
	var rect_corners: Array[Vector2] = [
		rect.position, Vector2(rect.end.x, rect.position.y),
		rect.end, Vector2(rect.position.x, rect.end.y)
	]
	# The 2D separating-axis theorem: rectangle normals plus each
	# projected footprint-edge normal. Touching an edge counts as overlap.
	var axes: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN]
	for i: int in range(4):
		var edge: Vector2 = footprint[(i + 1) % 4] - footprint[i]
		if edge.length_squared() < 0.00001:
			continue
		axes.append(Vector2(-edge.y, edge.x).normalized())
	for axis: Vector2 in axes:
		var footprint_min: float = INF
		var footprint_max: float = -INF
		for point: Vector2 in footprint:
			var projection: float = point.dot(axis)
			footprint_min = minf(footprint_min, projection)
			footprint_max = maxf(footprint_max, projection)
		var rect_min: float = INF
		var rect_max: float = -INF
		for point: Vector2 in rect_corners:
			var projection: float = point.dot(axis)
			rect_min = minf(rect_min, projection)
			rect_max = maxf(rect_max, projection)
		if footprint_max < rect_min or rect_max < footprint_min:
			return false
	return true
