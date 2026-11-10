extends RefCounted
class_name BlueprintWaypointRoute

# =============================================================================
# E3D3C — MULTI-WAYPOINT CONVEYOR BLUEPRINT GEOMETRY
# =============================================================================
# Read-only geometry. The incoming belt owns each bend tile, exactly as in
# BlueprintLRoute. The existing route coordinator converts these to physical
# left/right corners when the outgoing adjacent site is registered.
# No sites, reservations, inventories, or physical connections created here.

const MAX_WAYPOINTS: int = 12


static func get_tiles(
	points: Array[Vector3],
	limit: int = BlueprintStraightRoute.MAX_SEGMENTS
) -> Array[Transform3D]:
	var empty: Array[Transform3D] = []
	if points.size() < 2 or points.size() > MAX_WAYPOINTS:
		return empty
	if limit < 2 or limit > BlueprintStraightRoute.MAX_SEGMENTS:
		return empty

	var result: Array[Transform3D] = []
	var occupied: Dictionary = {}
	var previous_direction: Vector3 = Vector3.ZERO
	for leg_index: int in range(points.size() - 1):
		var leg: Array[Transform3D] = BlueprintStraightRoute.get_tiles_between(
			points[leg_index], points[leg_index + 1], limit
		)
		if leg.size() < 2:
			return empty
		var direction: Vector3 = leg[0].basis * Vector3.FORWARD
		# No reversing through an endpoint. Repeated straight directions are
		# allowed so waypoints can mark points along the same line.
		if (
			leg_index > 0
			and previous_direction.dot(direction) < -0.98
		):
			return empty
		previous_direction = direction
		if result.size() + leg.size() - (0 if leg_index == 0 else 1) > limit:
			return empty

		# Every bend occurs at the final tile of the incoming leg.
		# The outgoing leg skips its first tile to avoid duplicate sites.
		for index: int in range(0 if leg_index == 0 else 1, leg.size()):
			var tile: Transform3D = leg[index]
			var key := Vector3i(
				roundi(tile.origin.x), roundi(tile.origin.y),
				roundi(tile.origin.z)
			)
			if occupied.has(key):
				# Reject a route that crosses or revisits its own footprint.
				return empty
			occupied[key] = true
			result.append(tile)
	return result


static func turn_count(points: Array[Vector3]) -> int:
	if points.size() < 3:
		return 0
	var turns: int = 0
	var previous_direction: Vector3 = Vector3.ZERO
	for i: int in range(points.size() - 1):
		var direction: Vector3 = (
			points[i + 1] - points[i]
		).normalized()
		if (
			i > 0
			and absf(previous_direction.dot(direction)) < 0.01
		):
			turns += 1
		previous_direction = direction
	return turns
