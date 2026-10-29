extends Resource
class_name BuildingDefinition


# =============================================================================
# BUILDING IDENTITY
# =============================================================================

# Unique internal identifier used by game systems.
# Keep this lowercase and stable once the building becomes permanent.
@export var building_id: StringName

# Player-facing building name.
@export var display_name: String = "Building"

# Short description that can later appear in build menus or information panels.
@export_multiline var description: String = ""


# =============================================================================
# BUILDING CLASSIFICATION
# =============================================================================

# General category used for organization in future build menus.
# Examples: Production, Logistics, Storage, Defense, Power.
@export var category: StringName = &"General"


# =============================================================================
# BUILDING SCENE
# =============================================================================

# Scene instantiated when this building is placed in the world.
@export var building_scene: PackedScene

# =============================================================================
# BUILDING GRID FOOTPRINT
# =============================================================================

# Logical construction footprint measured in grid tiles.
#
# Examples:
# - Extractor: 1 x 2
# - Storage:   1 x 3
# - Smelter:   2 x 2
#
# Used by FactoryGrid to calculate placement origins
# and keep conveyor connection ports aligned.
#
# Rotation automatically swaps dimensions when needed.

@export var footprint_tiles: Vector2i = Vector2i.ONE
