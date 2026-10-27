
extends RefCounted
class_name ConveyorTurnIntent


# =============================================================================
# CONVEYOR TURN TYPES
# =============================================================================

# Represents the player's intended conveyor direction.
#
# These values describe construction intent only.
# They do not create, move, or connect conveyors.

enum Turn {
	STRAIGHT,
	RIGHT,
	LEFT
}


# =============================================================================
# TURN DETECTION SETTINGS
# =============================================================================

# The mouse must move sufficiently sideways before
# we interpret the position as a requested turn.

const SIDEWAYS_THRESHOLD: float = 0.6


# =============================================================================
# DETECT TURN FROM OUTPUT ENDPOINT
# =============================================================================

# Determines the intended direction relative to an
# existing conveyor's output endpoint.
#
# The method works even when the conveyor is rotated
# or when the output belongs to a corner.
#
# Returns STRAIGHT, RIGHT, or LEFT.
#
# No gameplay state is changed.

static func classify(
	output_endpoint: Marker3D,
	mouse_world_position: Vector3
) -> int:

	# =============================================================================
	# VALIDATE ENDPOINT
	# =============================================================================

	if not is_instance_valid(output_endpoint):
		return Turn.STRAIGHT

	if not output_endpoint.is_inside_tree():
		return Turn.STRAIGHT

	# =============================================================================
	# CALCULATE WORLD-SPACE DIRECTIONS
	# =============================================================================

	# Godot's local -Z represents forward.
	# Local +X represents right.

	var basis: Basis = (
		output_endpoint.global_transform.basis.orthonormalized()
	)

	var forward_direction: Vector3 = (
		-basis.z
	).normalized()

	var right_direction: Vector3 = (
		basis.x
	).normalized()

	var mouse_offset: Vector3 = (
		mouse_world_position
		- output_endpoint.global_position
	)

	# =============================================================================
	# REJECT POSITIONS BEHIND THE OUTPUT
	# =============================================================================

	if mouse_offset.dot(forward_direction) < 0.0:
		return Turn.STRAIGHT

	# =============================================================================
	# CLASSIFY LEFT OR RIGHT
	# =============================================================================

	var sideways_distance: float = (
		mouse_offset.dot(right_direction)
	)

	if sideways_distance > SIDEWAYS_THRESHOLD:
		return Turn.RIGHT

	if sideways_distance < -SIDEWAYS_THRESHOLD:
		return Turn.LEFT

	return Turn.STRAIGHT
