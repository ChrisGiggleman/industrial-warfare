extends RefCounted
class_name ConveyorBlueprintPlacement

# =============================================================================
# CONVEYOR BLUEPRINT PLACEMENT — ISOLATED STRAIGHT-SEGMENT PHASE
# =============================================================================
# A planned conveyor reserves one grid tile but is not a ConveyorSegment.
# No connection, transport, cargo or corner conversion occurs here.
# Later topology phases must validate both endpoint reservations separately.

static func is_clear(
	tree: SceneTree,
	world: World3D,
	definition: BuildingDefinition,
	placement: Transform3D,
	blocker_mask: int = 4
) -> bool:
	if tree == null or world == null:
		return false
	if not is_instance_valid(definition):
		return false
	if definition.building_id != &"conveyor_belt":
		return false
	if definition.footprint_tiles != Vector2i.ONE:
		return false
	if definition.building_scene != ConveyorPieceSelector.STRAIGHT_SCENE:
		return false
	if not FactoryGrid.is_on_conveyor_grid(placement.origin):
		return false
	if not is_finite(placement.origin.y):
		return false

	# Early phase supports cardinal rotations only. Orthogonal axes and
	# unit basis preserve the exact directional endpoint transforms.
	var right := placement.basis.x
	var forward := placement.basis.z
	if not is_equal_approx(right.length(), 1.0):
		return false
	if not is_equal_approx(forward.length(), 1.0):
		return false
	if absf(right.y) > 0.001 or absf(forward.y) > 0.001:
		return false
	if not is_equal_approx(absf(right.x) + absf(right.z), 1.0):
		return false
	if not is_equal_approx(absf(forward.x) + absf(forward.z), 1.0):
		return false

	# Same-frame plans must reserve tiles even before physics catches up.
	# Include legacy timed sites, new job sites and rectangular footprints.
	for member: Node in tree.get_nodes_in_group("construction_sites"):
		if not member is ConstructionSite:
			continue
		var site := member as ConstructionSite
		if site.is_queued_for_deletion():
			continue

		var other_right := site.global_transform.basis.x.normalized()
		var turns := roundi(
			rad_to_deg(atan2(-other_right.z, other_right.x)) / 90.0
		)
		var other_size := FactoryGrid.rotated_footprint(
			site.footprint, turns
		)
		if (
			absf(site.global_position.x - placement.origin.x)
				< (float(other_size.x) + 1.0) * 0.5 - 0.02
			and absf(site.global_position.z - placement.origin.z)
				< (float(other_size.y) + 1.0) * 0.5 - 0.02
		):
			return false

	# A completed belt can be created in the same frame that a site
	# retires; do not depend on a physics-server synchronization before
	# rejecting a duplicate belt in that tile.
	for member: Node in tree.get_nodes_in_group("player_built"):
		# A conveyor placement ghost keeps its original scene groups, but
		# has no operational footprint and must not block itself.
		if member.is_in_group("construction_preview"):
			continue
		if not member is ConveyorSegment:
			continue
		var completed := member as ConveyorSegment
		if completed.is_queued_for_deletion():
			continue
		if (
			absf(completed.global_position.x - placement.origin.x) < 0.98
			and absf(completed.global_position.z - placement.origin.z) < 0.98
		):
			return false

	# A narrow footprint inset permits side-by-side lanes but rejects
	# intersection with real built structures and completed conveyors.
	var box := BoxShape3D.new()
	box.size = Vector3(0.94, 0.56, 0.94)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	query.transform = Transform3D(
		Basis.IDENTITY,
		placement.origin + Vector3.UP * 0.3
	)
	query.collision_mask = blocker_mask
	return world.direct_space_state.intersect_shape(query, 1).is_empty()
