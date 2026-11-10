extends RefCounted
class_name BlueprintAreaSelectionQuery

# =============================================================================
# BLUEPRINT AREA SELECTION — SCREEN-SPACE QUERY ONLY
# =============================================================================
# Selects the projected centers of persistent, PLANNED construction sites.
# No collision, jobs, reservations, or temporary route ghosts are modified.

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

		# Center of the reserved building footprint projected onto the
		# screen. Camera-facing test prevents selecting sites behind camera.
		var center: Vector3 = site.global_position + Vector3.UP * 0.40
		if camera.is_position_behind(center):
			continue
		var point: Vector2 = camera.unproject_position(center)
		if bounds.has_point(point):
			selected.append(site)
	return selected
