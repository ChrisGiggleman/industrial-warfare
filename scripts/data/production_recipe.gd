extends Resource
class_name ProductionRecipe


# =============================================================================
# RECIPE IDENTITY
# =============================================================================

# Unique internal identifier used by gameplay systems.
@export var recipe_id: StringName

# Player-facing recipe name.
@export var display_name: String = "Recipe"


# =============================================================================
# PRODUCTION TIMING
# =============================================================================

# Time required to complete one production cycle.
@export_range(0.1, 3600.0, 0.1) var production_time: float = 1.0


# =============================================================================
# RECIPE INPUTS
# =============================================================================

# Items consumed when one production cycle completes.
@export var inputs: Array[ItemAmount] = []


# =============================================================================
# RECIPE OUTPUTS
# =============================================================================

# Items created when one production cycle completes.
@export var outputs: Array[ItemAmount] = []