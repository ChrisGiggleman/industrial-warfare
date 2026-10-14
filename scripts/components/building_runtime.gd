extends Node
class_name BuildingRuntime


# =============================================================================
# RUNTIME BUILDING DATA
# =============================================================================

# The BuildingDefinition that was used to create this building.
# This is assigned by the construction system when the building is placed.
var building_definition: BuildingDefinition = null


# =============================================================================
# INITIALIZATION
# =============================================================================

# Assigns the data definition associated with this building instance.

func initialize(definition: BuildingDefinition) -> void:
	building_definition = definition
