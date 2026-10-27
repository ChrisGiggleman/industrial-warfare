
extends RefCounted
class_name ConveyorPieceSelector


# =============================================================================
# CONVEYOR SCENE REFERENCES
# =============================================================================

# All three shapes are available to the same
# Conveyor Belt construction tool.
#
# We are NOT creating separate build-menu slots.

const STRAIGHT_SCENE: PackedScene = preload(
	"res://scenes/logistics/conveyor_straight.tscn"
)

const RIGHT_CORNER_SCENE: PackedScene = preload(
	"res://scenes/logistics/conveyor_corner.tscn"
)

const LEFT_CORNER_SCENE: PackedScene = preload(
	"res://scenes/logistics/conveyor_corner_left.tscn"
)


# =============================================================================
# SELECT CONVEYOR SCENE FROM TURN TYPE
# =============================================================================

# Converts an already-classified player direction
# into the corresponding conveyor scene.
#
# This does not instantiate or place anything.

static func get_scene_for_turn(
	turn: int
) -> PackedScene:

	match turn:

		ConveyorTurnIntent.Turn.RIGHT:
			return RIGHT_CORNER_SCENE

		ConveyorTurnIntent.Turn.LEFT:
			return LEFT_CORNER_SCENE

		ConveyorTurnIntent.Turn.STRAIGHT:
			return STRAIGHT_SCENE

		_:
			return STRAIGHT_SCENE


# =============================================================================
# SELECT CONVEYOR SCENE FROM MOUSE POSITION
# =============================================================================

# Uses the output direction of an existing conveyor
# and the mouse's world position.
#
# Returns the appropriate straight or corner scene.
#
# Does NOT:
# - Change the existing conveyor
# - Move the placement ghost
# - Create connections
# - Place buildings
# - Transfer inventory items

static func get_scene_for_mouse(
	source: ConveyorSegment,
	mouse_world_position: Vector3
) -> PackedScene:

	# =============================================================================
	# VALIDATE SOURCE
	# =============================================================================

	if not is_instance_valid(source):
		return null

	var output_endpoint: Marker3D = (
		source.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	if not is_instance_valid(output_endpoint):
		return null

	if not output_endpoint.is_inside_tree():
		return null

	# =============================================================================
	# CLASSIFY CONSTRUCTION DIRECTION
	# =============================================================================

	var intended_turn: int = (
		ConveyorTurnIntent.classify(
			output_endpoint,
			mouse_world_position
		)
	)

	# =============================================================================
	# RETURN APPROPRIATE CONVEYOR SCENE
	# =============================================================================

	return get_scene_for_turn(intended_turn)
