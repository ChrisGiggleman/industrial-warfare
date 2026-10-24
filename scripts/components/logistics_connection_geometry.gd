
extends RefCounted
class_name LogisticsConnectionGeometry


# =============================================================================
# PHYSICAL CONNECTION GEOMETRY
# =============================================================================

# Shared alignment checks for logistics endpoints.
#
# Future uses:
# - Machine output -> conveyor input
# - Conveyor output -> conveyor input
# - Conveyor output -> machine input
# - Conveyor output -> storage input
#
# This class checks physical alignment ONLY.
#
# It does NOT:
# - Create a connection.
# - Move inventory items.
# - Validate item recipes.
# - Determine conveyor routing.
# - Modify the existing factory.


# =============================================================================
# CONNECTION TOLERANCES
# =============================================================================

# Dot products close to 1 indicate matching directions.
# A dot product close to -1 indicates opposite directions.

const MIN_ALIGNMENT_DOT: float = 0.98

# Allows endpoints to occupy the same snapped position.
const POSITION_EPSILON_SQUARED: float = 0.000001


# =============================================================================
# ENDPOINT ALIGNMENT VALIDATION
# =============================================================================

# Checks whether two Marker3D endpoints are suitable
# candidates for a physical connection.
#
# The outgoing endpoint must point toward the receiver.
# The receiver must face back toward the sender.
#
# Godot uses local -Z as the forward direction.
#
# max_gap controls the allowed distance between markers.
# It is a temporary prototype tolerance.
#
# Returns true only for geometrically compatible endpoints.

static func are_endpoints_aligned(
	outgoing: Marker3D,
	incoming: Marker3D,
	max_gap: float = 0.75
) -> bool:

	# =============================================================================
	# VALIDATE ENDPOINT REFERENCES
	# =============================================================================

	if not is_instance_valid(outgoing):
		return false

	if not is_instance_valid(incoming):
		return false

	if outgoing == incoming:
		return false

	if max_gap < 0.0:
		return false

	# =============================================================================
	# CHECK PHYSICAL DISTANCE
	# =============================================================================

	var offset: Vector3 = (
		incoming.global_position
		- outgoing.global_position
	)

	var distance: float = offset.length()

	if distance > max_gap:
		return false

	# =============================================================================
	# CALCULATE WORLD-SPACE FACING DIRECTIONS
	# =============================================================================

	# Transform local -Z into world coordinates.
	# Parent building rotation is included automatically.

	var outgoing_forward: Vector3 = (
		outgoing.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	var incoming_forward: Vector3 = (
		incoming.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	# =============================================================================
	# REQUIRE OPPOSITE-FACING ENDPOINTS
	# =============================================================================

	# A source facing right should connect to an
	# endpoint facing left, not another facing right.

	if outgoing_forward.dot(incoming_forward) > -MIN_ALIGNMENT_DOT:
		return false

	# =============================================================================
	# REQUIRE ALIGNMENT ALONG THE OUTGOING DIRECTION
	# =============================================================================

	# Endpoints can share an exact snap position.
	# When separated, the incoming endpoint must lie
	# directly ahead of the outgoing endpoint.
	#
	# This also rejects sideways and height offsets.

	if offset.length_squared() > POSITION_EPSILON_SQUARED:

		var toward_incoming: Vector3 = offset.normalized()

		if outgoing_forward.dot(toward_incoming) < MIN_ALIGNMENT_DOT:
			return false

	# =============================================================================
	# VALID GEOMETRY CANDIDATE
	# =============================================================================

	return true
