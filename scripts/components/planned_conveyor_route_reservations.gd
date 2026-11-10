extends Node
class_name PlannedConveyorRouteReservations

# =============================================================================
# PLANNED CONVEYOR CONNECTIONS — EXCLUSIVE ENDPOINT OWNERSHIP
# =============================================================================
# Phase E2b: stores non-operational directed connection intent between two
# blueprint sites. Tracks either construction order, cancellations, and
# invalidation. Does NOT connect conveyors or alter corner geometry.
#
# A ready signal is only a request for the future activation transaction.
# Consumers MUST revalidate get_ready_candidate() at commit time.

signal reservation_ready(reservation_id: int)
signal reservation_released(reservation_id: int)

var _next_id: int = 1
var _reservations: Dictionary = {}
var _endpoint_claims: Dictionary = {}
var _shared_claim_broker: PlannedEndpointClaimBroker = null


func set_claim_broker(broker: PlannedEndpointClaimBroker) -> bool:
	# Reject rebinding with outstanding claims: existing reservations
	# cannot safely migrate to another endpoint authority in flight.
	if not is_instance_valid(broker) or is_instance_valid(_shared_claim_broker):
		return false
	if not _reservations.is_empty():
		return false
	_shared_claim_broker = broker
	return true


func reserve_pair(source: ConstructionSite, receiver: ConstructionSite) -> int:
	var candidate := PlannedConveyorRouteGeometry.inspect_pair(source, receiver)
	if candidate.is_empty():
		return 0

	var outgoing: String = _endpoint_key(source, "out")
	var incoming: String = _endpoint_key(receiver, "in")
	if _endpoint_claims.has(outgoing) or _endpoint_claims.has(incoming):
		return 0

	var reservation_id: int = _next_id
	var broker_owner := ""
	if is_instance_valid(_shared_claim_broker):
		broker_owner = "belt:%d:%d" % [get_instance_id(), reservation_id]
		if not _shared_claim_broker.claim_pair(
			source, PlannedEndpointClaimBroker.BELT_OUTPUT,
			receiver, PlannedEndpointClaimBroker.BELT_INPUT,
			broker_owner
		):
			return 0
	_next_id += 1
	_reservations[reservation_id] = {
		"broker_owner": broker_owner,
		"source": source,
		"receiver": receiver,
		"source_key": outgoing,
		"receiver_key": incoming,
		"mode": candidate["mode"],
		"turn": candidate["turn"],
		"junction": candidate["junction"],
		"source_belt": null,
		"receiver_belt": null,
		"announced": false
	}
	_endpoint_claims[outgoing] = reservation_id
	_endpoint_claims[incoming] = reservation_id

	if not _connect_site(source, reservation_id, true):
		release(reservation_id)
		return 0
	if not _connect_site(receiver, reservation_id, false):
		release(reservation_id)
		return 0
	return reservation_id


func is_reserved(reservation_id: int) -> bool:
	return _reservations.has(reservation_id)


func claim_count() -> int:
	return _endpoint_claims.size()


func has_endpoint_claim(site: ConstructionSite, output_side: bool) -> bool:
	if not is_instance_valid(site):
		return false
	return _endpoint_claims.has(
		_endpoint_key(site, "out" if output_side else "in")
	)


# Read-only status for a directed reservation. The physical endpoint can
# complete independently of its neighbor without claiming a live link.
func has_completed_endpoint(reservation_id: int, output_side: bool) -> bool:
	if not _reservations.has(reservation_id):
		return false
	var record: Dictionary = _reservations[reservation_id]
	var key := "source_belt" if output_side else "receiver_belt"
	var saved_belt: Variant = record[key]
	# A freed Object cannot be cast with 'as', even to its old class.
	if not is_instance_valid(saved_belt):
		return false
	var belt := saved_belt as ConveyorSegment
	return belt != null and not belt.is_queued_for_deletion()


func get_ready_candidate(reservation_id: int) -> Dictionary:
	if not _reservations.has(reservation_id):
		return {}

	var record: Dictionary = _reservations[reservation_id]
	var saved_source: Variant = record["source_belt"]
	var saved_receiver: Variant = record["receiver_belt"]
	if not is_instance_valid(saved_source) or not is_instance_valid(saved_receiver):
		return {}
	var source := saved_source as ConveyorSegment
	var receiver := saved_receiver as ConveyorSegment
	if source == null or receiver == null:
		return {}
	if source.is_queued_for_deletion() or receiver.is_queued_for_deletion():
		return {}

	# Physical discovery is read-only. It rechecks actual positions, port
	# vacancy, and the precise turn type after both jobs finish.
	var candidate := ConveyorExistingEndpointFinder.inspect_pair(
		source, receiver
	)
	if candidate.is_empty():
		return {}
	if candidate.get("mode") != record["mode"]:
		return {}
	if candidate.get("turn") != record["turn"]:
		return {}

	var expected: Vector3 = record["junction"]
	var actual: Vector3 = candidate["junction"]
	if not expected.is_equal_approx(actual):
		return {}

	return candidate


func release(reservation_id: int) -> bool:
	if not _reservations.has(reservation_id):
		return false
	var record: Dictionary = _reservations[reservation_id]

	# A completed blueprint's ConstructionSite is queue_freed while its
	# reservation remains active. Inspect the raw stored Variant BEFORE
	# casting: casting a freed Object raises a Godot runtime error.
	for side: String in ["source", "receiver"]:
		var saved_site: Variant = record[side]
		if is_instance_valid(saved_site):
			var site := saved_site as ConstructionSite
			if site != null:
				_disconnect_site(site, reservation_id, side == "source")

		var saved_belt: Variant = record[side + "_belt"]
		if not is_instance_valid(saved_belt):
			continue
		var belt := saved_belt as ConveyorSegment
		var exit_handler: Callable = record.get(
			side + "_belt_exit_callback", Callable()
		)
		if (
			belt != null
			and exit_handler.is_valid()
			and belt.tree_exiting.is_connected(exit_handler)
		):
			belt.tree_exiting.disconnect(exit_handler)

	# Use immutable keys recorded when reserved; the sites can be freed.
	_endpoint_claims.erase(record["source_key"])
	_endpoint_claims.erase(record["receiver_key"])
	if is_instance_valid(_shared_claim_broker):
		var broker_owner: String = record.get("broker_owner", "")
		if not broker_owner.is_empty():
			_shared_claim_broker.release_owner(broker_owner)
	_reservations.erase(reservation_id)
	reservation_released.emit(reservation_id)
	return true

func _endpoint_key(site: ConstructionSite, side: String) -> String:
	if not is_instance_valid(site):
		return ""
	return "%d:%s" % [site.get_instance_id(), side]


func _connect_site(
	site: ConstructionSite, reservation_id: int, is_source: bool
) -> bool:
	# Distinct closures are required when a transit blueprint owns one
	# incoming reservation and one outgoing reservation simultaneously.
	# Keep the exact Callable identities so release() disconnects cleanly.
	var completed_callback := func(building: Node3D) -> void:
		_on_site_completed(building, reservation_id, is_source)
	var cancelled_callback := func() -> void:
		_on_site_cancelled(reservation_id)
	var exiting_callback := func() -> void:
		_on_site_exiting(reservation_id, is_source)

	var complete_result := site.building_completed.connect(completed_callback)
	var cancel_result := site.job.job_cancelled.connect(cancelled_callback)
	var exit_result := site.tree_exiting.connect(exiting_callback)
	var valid_connections := (
		complete_result == OK
		and cancel_result == OK
		and exit_result == OK
	)

	if not valid_connections:
		if site.building_completed.is_connected(completed_callback):
			site.building_completed.disconnect(completed_callback)
		if site.job.job_cancelled.is_connected(cancelled_callback):
			site.job.job_cancelled.disconnect(cancelled_callback)
		if site.tree_exiting.is_connected(exiting_callback):
			site.tree_exiting.disconnect(exiting_callback)
		push_error("Failed to attach construction-site route observers.")
		return false

	var record: Dictionary = _reservations[reservation_id]
	var side := "source" if is_source else "receiver"
	record[side + "_callbacks"] = {
		"complete": completed_callback,
		"cancel": cancelled_callback,
		"exit": exiting_callback
	}
	_reservations[reservation_id] = record
	return true


func _disconnect_site(
	site: ConstructionSite, reservation_id: int, is_source: bool
) -> void:
	if not is_instance_valid(site):
		return
	if not _reservations.has(reservation_id):
		return

	var record: Dictionary = _reservations[reservation_id]
	var side := "source" if is_source else "receiver"
	var callbacks: Dictionary = record.get(side + "_callbacks", {})
	if callbacks.is_empty():
		return

	var complete: Callable = callbacks["complete"]
	var cancelled: Callable = callbacks["cancel"]
	var exiting: Callable = callbacks["exit"]
	if site.building_completed.is_connected(complete):
		site.building_completed.disconnect(complete)
	if (
		is_instance_valid(site.job)
		and site.job.job_cancelled.is_connected(cancelled)
	):
		site.job.job_cancelled.disconnect(cancelled)
	if site.tree_exiting.is_connected(exiting):
		site.tree_exiting.disconnect(exiting)

func _on_site_completed(
	building: Node3D, reservation_id: int, is_source: bool
) -> void:
	if not _reservations.has(reservation_id):
		return
	if not building is ConveyorSegment:
		release(reservation_id)
		return

	var belt := building as ConveyorSegment
	var record: Dictionary = _reservations[reservation_id]
	if is_source:
		record["source_belt"] = belt
	else:
		record["receiver_belt"] = belt
	_reservations[reservation_id] = record

	# A shared middle conveyor can belong to two reservations. Use a
	# separate closure per route to guarantee both lifecycle events fire.
	var exit_callback := func() -> void:
		_on_completed_belt_exiting(reservation_id)
	if belt.tree_exiting.connect(exit_callback) != OK:
		release(reservation_id)
		push_error("Failed to observe completed planned conveyor removal.")
		return
	var side := "source" if is_source else "receiver"
	record[side + "_belt_exit_callback"] = exit_callback
	_reservations[reservation_id] = record
	_notify_if_ready(reservation_id)


func _notify_if_ready(reservation_id: int) -> void:
	if not _reservations.has(reservation_id):
		return
	var record: Dictionary = _reservations[reservation_id]
	if record["announced"]:
		return
	if get_ready_candidate(reservation_id).is_empty():
		return

	record["announced"] = true
	_reservations[reservation_id] = record
	reservation_ready.emit(reservation_id)


func _on_site_cancelled(reservation_id: int) -> void:
	release(reservation_id)


func _on_site_exiting(reservation_id: int, is_source: bool) -> void:
	if not _reservations.has(reservation_id):
		return
	var record: Dictionary = _reservations[reservation_id]
	var completed: Variant = (
		record["source_belt"] if is_source else record["receiver_belt"]
	)
	# Normal site retirement after completion preserves the claim.
	# Unexpected removal of an unbuilt site cancels its entire route.
	# Test validity before casting because a completed belt might have
	# been removed during a teardown callback.
	if not is_instance_valid(completed):
		release(reservation_id)


func _on_completed_belt_exiting(reservation_id: int) -> void:
	release(reservation_id)
