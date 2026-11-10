extends RefCounted
class_name BlueprintStraightRoute

# =============================================================================
# BLUEPRINT ROUTE — READ-ONLY STRAIGHT PATH GEOMETRY
# =============================================================================
# E3d3a: a cardinal, forward-only path of tile transforms.
# No construction sites, inventory, claims, or gameplay mutations.

const MAX_SEGMENTS: int = 32

static func get_tiles(
	start: Transform3D,
	finish: Vector3,
	limit: int = MAX_SEGMENTS
) -> Array[Transform3D]:
	var result: Array[Transform3D] = []
	if limit <= 0 or limit > MAX_SEGMENTS:
		return result
	if not FactoryGrid.is_on_conveyor_grid(start.origin):
		return result
	if not FactoryGrid.is_on_conveyor_grid(finish):
		return result
	if not start.origin.is_finite() or not finish.is_finite():
		return result
	if absf(start.origin.y - finish.y) > 0.02:
		return result
	var forward: Vector3 = (start.basis * Vector3.FORWARD).normalized()
	if absf(forward.y) > 0.001:
		return result
	if not is_equal_approx(absf(forward.x) + absf(forward.z), 1.0):
		return result
	if not is_equal_approx(absf(forward.x) * absf(forward.z), 0.0):
		return result
	var displacement: Vector3 = finish - start.origin
	var distance: float = displacement.dot(forward)
	if distance < -0.001 or absf(distance - roundf(distance)) > 0.001:
		return result
	if (displacement - forward * distance).length() > 0.02:
		return result
	var tiles: int = roundi(distance) + 1
	if tiles > limit:
		return result
	for index: int in range(tiles):
		var placement := start
		placement.origin = start.origin + forward * float(index)
		result.append(placement)
	return result
