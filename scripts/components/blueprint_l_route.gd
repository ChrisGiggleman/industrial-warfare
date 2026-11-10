extends RefCounted
class_name BlueprintLRoute

# =============================================================================
# E3D3B — THREE-POINT L-SHAPED BLUEPRINT ROUTE GEOMETRY
# =============================================================================
# Read-only planning. The turn tile belongs to the incoming first leg;
# existing PlannedConveyorRouteGeometry converts it to a corner when the
# outgoing neighboring site is registered.
# No sites, reservations, physical belts, or cargo are created here.

static func get_tiles(
	start: Vector3,
	turn: Vector3,
	finish: Vector3,
	limit: int = BlueprintStraightRoute.MAX_SEGMENTS
) -> Array[Transform3D]:
	var empty: Array[Transform3D] = []
	if limit < 3 or limit > BlueprintStraightRoute.MAX_SEGMENTS:
		return empty
	var incoming: Array[Transform3D] = BlueprintStraightRoute.get_tiles_between(
		start, turn, limit
	)
	var outgoing: Array[Transform3D] = BlueprintStraightRoute.get_tiles_between(
		turn, finish, limit
	)
	if incoming.size() < 2 or outgoing.size() < 2:
		return empty
	if incoming.size() + outgoing.size() - 1 > limit:
		return empty

	var entering: Vector3 = incoming[0].basis * Vector3.FORWARD
	var leaving: Vector3 = outgoing[0].basis * Vector3.FORWARD
	# Disallow straight-through and U-turns: this checkpoint has exactly
	# one 90-degree corner, never overlapping or ambiguous route tiles.
	if absf(entering.dot(leaving)) > 0.001:
		return empty
	var route: Array[Transform3D] = []
	route.append_array(incoming)
	# The corner site at 'turn' keeps its incoming transform. A single
	# next tile with the outgoing rotation triggers established corner
	# discovery/claim machinery.
	for i: int in range(1, outgoing.size()):
		route.append(outgoing[i])
	return route
