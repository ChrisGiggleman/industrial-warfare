extends Node3D
class_name ConstructionPowerNetworkNode

# =============================================================================
# E3D5C3A — POWER TOPOLOGY NODE (ISOLATED FOUNDATION)
# =============================================================================
# No node is energized by default. A real completed Hub/Power component
# must eventually own operational/source_online; tests set these explicitly.
# This class is NOT placed in Main or the Factory Testing Sandbox.

@export var operational: bool = false
@export var is_source: bool = false
@export var source_online: bool = false
@export_range(0.1, 100.0, 0.1) var link_range: float = 5.0
@export_range(0.1, 100.0, 0.1) var coverage_radius: float = 3.0
