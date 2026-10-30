
extends RefCounted
class_name FactoryGrid


# =============================================================================
# UNIFIED FACTORY GRID
# =============================================================================

# Shared construction geometry for buildings and conveyors.
#
# One tile = one world unit by default.
# Odd-sized building footprints use integer-centered origins.
# Even-sized footprints use half-tile-centered origins.
#
# Ports are positioned on tile edges, while adjacent
# conveyor centers remain on integer grid coordinates.
#
# This helper never moves real objects or inventories.


# =============================================================================
# GRID SETTINGS
# =============================================================================

const CELL_SIZE: float = 1.0
const PORT_HEIGHT: float = 0.5

enum Side {
	NEGATIVE_X,
	POSITIVE_X,
	NEGATIVE_Z,
	POSITIVE_Z
}


# =============================================================================
# ROTATE LOGICAL BUILDING FOOTPRINT
# =============================================================================

# Quarter-turn rotations swap X and Z for rectangular buildings.

static func rotated_footprint(
	footprint: Vector2i,
	quarter_turns: int
) -> Vector2i:

	if posmod(quarter_turns, 2) == 1:
		return Vector2i(footprint.y, footprint.x)

	return footprint


# =============================================================================
# SNAP BUILDING ORIGIN TO FOOTPRINT GRID
# =============================================================================

static func snap_building_origin(
	world_position: Vector3,
	world_footprint: Vector2i,
	cell_size: float = CELL_SIZE
) -> Vector3:

	if (
		world_footprint.x <= 0
		or world_footprint.y <= 0
		or cell_size <= 0.0
	):
		return world_position

	var offset_x: float = 0.0
	var offset_z: float = 0.0

	if world_footprint.x % 2 == 0:
		offset_x = cell_size * 0.5

	if world_footprint.y % 2 == 0:
		offset_z = cell_size * 0.5

	return Vector3(
		snappedf(world_position.x - offset_x, cell_size) + offset_x,
		world_position.y,
		snappedf(world_position.z - offset_z, cell_size) + offset_z
	)


# =============================================================================
# CALCULATE STANDARDIZED BUILDING PORT LOCATION
# =============================================================================

# lane_index chooses a tile-wide lane along a building edge.
#
# Example:
# - A 1-wide edge has one center lane at 0.
# - A 2-wide edge has lanes at -0.5 and +0.5.
# - A 3-wide edge has lanes at -1, 0, and +1.
#
# This handles even-width buildings without forcing
# their conveyors onto an incompatible half-tile line.

static func get_port_local_position(
	footprint: Vector2i,
	side: int,
	lane_index: int = 0,
	cell_size: float = CELL_SIZE
) -> Vector3:

	if (
		footprint.x <= 0
		or footprint.y <= 0
		or cell_size <= 0.0
	):
		return Vector3.INF

	var lane_count: int = footprint.x

	if side == Side.NEGATIVE_X or side == Side.POSITIVE_X:
		lane_count = footprint.y

	if lane_index < 0 or lane_index >= lane_count:
		return Vector3.INF

	var lane_offset: float = (
		float(lane_index) + 0.5
		- float(lane_count) * 0.5
	) * cell_size

	var half_x: float = float(footprint.x) * cell_size * 0.5
	var half_z: float = float(footprint.y) * cell_size * 0.5

	match side:

		Side.NEGATIVE_X:
			return Vector3(-half_x, PORT_HEIGHT, lane_offset)

		Side.POSITIVE_X:
			return Vector3(half_x, PORT_HEIGHT, lane_offset)

		Side.NEGATIVE_Z:
			return Vector3(lane_offset, PORT_HEIGHT, -half_z)

		Side.POSITIVE_Z:
			return Vector3(lane_offset, PORT_HEIGHT, half_z)

	return Vector3.INF


# =============================================================================
# CALCULATE CONVEYOR CENTER NEXT TO BUILDING PORT
# =============================================================================

# Returns the ideal center of a one-tile conveyor
# adjacent to the specified port.
#
# The building transform supplies world rotation.
# This is a read-only geometric calculation.

static func get_conveyor_center(
	building_transform: Transform3D,
	port_local_position: Vector3,
	side: int,
	cell_size: float = CELL_SIZE
) -> Vector3:

	var outward: Vector3 = Vector3.ZERO

	match side:

		Side.NEGATIVE_X:
			outward = Vector3.LEFT

		Side.POSITIVE_X:
			outward = Vector3.RIGHT

		Side.NEGATIVE_Z:
			outward = Vector3.FORWARD

		Side.POSITIVE_Z:
			outward = Vector3.BACK

	
	# The port marker is 0.5 units above the building root.
	# Conveyor endpoints are also 0.5 units above the belt root.
	#
	# Subtract the conveyor endpoint height so the conveyor
	# root remains on the same ground level as the building.

	return building_transform * (
		port_local_position
		+ outward * cell_size * 0.5
		- Vector3.UP * PORT_HEIGHT
	)



# =============================================================================
# CHECK IF CONVEYOR CENTER IS ON THE TILE GRID
# =============================================================================

static func is_on_conveyor_grid(
	world_position: Vector3,
	cell_size: float = CELL_SIZE
) -> bool:

	if cell_size <= 0.0:
		return false

	return (
		is_equal_approx(
			world_position.x,
			snappedf(world_position.x, cell_size)
		)
		and is_equal_approx(
			world_position.z,
			snappedf(world_position.z, cell_size)
		)
	)
