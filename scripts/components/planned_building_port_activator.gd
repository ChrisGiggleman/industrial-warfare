extends Node
class_name PlannedBuildingPortActivator

# =============================================================================
# PLANNED BUILDING PORTS — DEFERRED PHYSICAL CONNECTIONS
# =============================================================================
# E3c1: consumes completed E3b reservations and delegates to the existing
# ConveyorSegment.try_connect_building_port() physical transaction.
# No connection exists until BOTH blueprint jobs produce real objects.
# This service never moves items, authorizes jobs, or bypasses power gates.

signal connection_committed(
	reservation_id: int,
	building: Node3D,
	belt: ConveyorSegment,
	input_side: bool
)

var _registry: PlannedBuildingPortReservations = null


func bind_registry(registry: PlannedBuildingPortReservations) -> bool:
	if not is_instance_valid(registry) or is_instance_valid(_registry):
		return false
	if registry.reservation_ready.connect(_on_reservation_ready) != OK:
		return false
	_registry = registry
	return true


func unbind_registry() -> void:
	if is_instance_valid(_registry):
		if _registry.reservation_ready.is_connected(_on_reservation_ready):
			_registry.reservation_ready.disconnect(_on_reservation_ready)
	_registry = null


func try_commit(reservation_id: int) -> bool:
	if not is_instance_valid(_registry):
		return false

	# Recheck future-port reservation geometry against BOTH operational
	# endpoints at the instant we attempt the physical connection.
	var candidate: Dictionary = _registry.get_ready_candidate(reservation_id)
	if candidate.is_empty():
		return false

	var raw_building: Variant = candidate.get("building")
	var raw_belt: Variant = candidate.get("belt")
	var raw_port: Variant = candidate.get("port")
	if (
		not is_instance_valid(raw_building)
		or not is_instance_valid(raw_belt)
		or not is_instance_valid(raw_port)
	):
		return false
	var building := raw_building as Node3D
	var belt := raw_belt as ConveyorSegment
	var port := raw_port as ItemPortComponent
	if building == null or belt == null or port == null:
		return false

	var input_side: bool = candidate["input_side"]
	var expected_direction := (
		ItemPortComponent.PortDirection.INPUT if input_side
		else ItemPortComponent.PortDirection.OUTPUT
	)
	if port.direction != expected_direction:
		return false
	if port.get_parent() != building:
		return false

	# Existing operational connection logic validates the port's actual
	# inventory, acceptance policy, free neighboring links, and alignment.
	if not belt.try_connect_building_port(port):
		return false

	var reciprocal := (
		belt.output_building_port == port if input_side
		else belt.input_building_port == port
	)
	if not reciprocal or port.connected_conveyor != belt:
		# Never allow an incomplete link to persist after a failed commit.
		belt.disconnect_building_port(port)
		push_error("Blueprint building-port activation lacked reciprocal links.")
		return false

	# The building-port link is now physical. Consume exactly this pair of
	# claims; unrelated routes (including the other Storage port) remain.
	if not _registry.release(reservation_id):
		belt.disconnect_building_port(port)
		push_error("Blueprint building-port claim could not be released.")
		return false

	connection_committed.emit(reservation_id, building, belt, input_side)
	return true


func _on_reservation_ready(reservation_id: int) -> void:
	try_commit(reservation_id)


func _exit_tree() -> void:
	unbind_registry()
