extends Marker3D
class_name PrototypeDroneStorageDock

# Test-only physical waypoint attached to completed Storage. No charging,
# transfer, reservations, or automatic installation on existing buildings.
@export var enable_isolated_dock: bool = false
@export var allow_pickup: bool = true
@export var allow_returns: bool = true
@export var available: bool = true
@export_range(0, 100000, 1) var minimum_retained: int = 0
