extends Node
class_name PlannedConveyorRouteActivator

# =============================================================================
# PLANNED CONVEYOR ROUTES — POST-CONSTRUCTION ACTIVATION
# =============================================================================
# Phase E2c1: an isolated adapter between E2b's exclusive reservation
# registry and the already-tested operational conveyor connection helper.
# It does not spawn sites, authorize jobs, deliver materials, or render turns.
# Only two fully built, currently compatible conveyors can be connected.

signal connection_committed(reservation_id: int, source: ConveyorSegment, receiver: ConveyorSegment)

var _registry: PlannedConveyorRouteReservations


func bind_registry(registry: PlannedConveyorRouteReservations) -> bool:
	if not is_instance_valid(registry):
		return false
	if is_instance_valid(_registry):
		return false
	var connection_result := registry.reservation_ready.connect(
		_on_reservation_ready
	)
	if connection_result != OK:
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
	# This call checks BOTH built belts, their present physical geometry,
	# unoccupied endpoints, and the originally reserved turn/junction.
	var candidate: Dictionary = _registry.get_ready_candidate(reservation_id)
	if candidate.is_empty():
		return false

	var source := candidate.get("source") as ConveyorSegment
	var receiver := candidate.get("receiver") as ConveyorSegment
	if not is_instance_valid(source) or not is_instance_valid(receiver):
		return false

	# Reuses operational transaction: no untested manual port wiring.
	# The helper revalidates geometry immediately before committing.
	if not ConveyorExistingConnection.try_connect_candidate(candidate):
		return false
	if source.next_segment != receiver or receiver.previous_segment != source:
		push_error("Conveyor route committed without reciprocal references.")
		return false

	# Only a successful physical connection consumes the reservation.
	# The registry's unique claims and observers are released together.
	if not _registry.release(reservation_id):
		push_error("Conveyor connected but its route claim was not released.")
		return false

	connection_committed.emit(reservation_id, source, receiver)
	return true


func _on_reservation_ready(reservation_id: int) -> void:
	try_commit(reservation_id)


func _exit_tree() -> void:
	unbind_registry()
