extends Node
class_name PlannedBuildingPortReservations

# =============================================================================
# PLANNED BUILDING PORTS — EXCLUSIVE FUTURE CONNECTION CLAIMS
# =============================================================================
# E3b: reserves one future building input/output and a matching conveyor
# endpoint. Retains both completed objects across ConstructionSite deletion.
# Never performs a physical connection, transport, or construction work.
#
# This isolated registry owns only its own port claims. Sharing belt endpoint
# claims with E2b's route registry is an E3c integration prerequisite.

signal reservation_ready(reservation_id: int)
signal reservation_released(reservation_id: int)

var _next_id: int = 1
var _records: Dictionary = {}
var _claims: Dictionary = {}


func reserve_pair(
	building_site: ConstructionSite,
	belt_site: ConstructionSite,
	input_side: bool
) -> int:
	var candidate := PlannedBuildingPortGeometry.inspect_pair(
		building_site, belt_site, input_side
	)
	if candidate.is_empty():
		return 0

	# The older live-belt-to-planned-Storage reservation owns this port
	# independently. Do not steal its claim.
	if is_instance_valid(building_site.get_reserved_conveyor(input_side)):
		return 0

	var building_key := _site_key(
		building_site, "building_input" if input_side else "building_output"
	)
	var belt_key := _site_key(
		belt_site, "belt_output" if input_side else "belt_input"
	)
	if _claims.has(building_key) or _claims.has(belt_key):
		return 0

	var id := _next_id
	_next_id += 1
	_records[id] = {
		"building_site": building_site,
		"belt_site": belt_site,
		"building_key": building_key,
		"belt_key": belt_key,
		"input_side": input_side,
		"junction": candidate["junction"],
		"building": null,
		"belt": null,
		"announced": false
	}
	_claims[building_key] = id
	_claims[belt_key] = id

	if not _observe_site(building_site, id, true):
		release(id)
		return 0
	if not _observe_site(belt_site, id, false):
		release(id)
		return 0
	return id


func is_reserved(id: int) -> bool:
	return _records.has(id)


func claim_count() -> int:
	return _claims.size()


func has_building_claim(site: ConstructionSite, input_side: bool) -> bool:
	if not is_instance_valid(site):
		return false
	return _claims.has(_site_key(
		site, "building_input" if input_side else "building_output"
	))


func has_belt_claim(site: ConstructionSite, output_side: bool) -> bool:
	if not is_instance_valid(site):
		return false
	return _claims.has(_site_key(
		site, "belt_output" if output_side else "belt_input"
	))


func has_completed_side(id: int, is_building: bool) -> bool:
	if not _records.has(id):
		return false
	var record: Dictionary = _records[id]
	var raw: Variant = record["building" if is_building else "belt"]
	return is_instance_valid(raw) and not raw.is_queued_for_deletion()


func get_ready_candidate(id: int) -> Dictionary:
	if not _records.has(id):
		return {}
	var record: Dictionary = _records[id]
	var raw_building: Variant = record["building"]
	var raw_belt: Variant = record["belt"]
	# Check raw Variants before casting; their construction sites can
	# already have been freed, and either completed object may be gone.
	if not is_instance_valid(raw_building) or not is_instance_valid(raw_belt):
		return {}
	var building := raw_building as Node3D
	var belt := raw_belt as ConveyorSegment
	if building == null or belt == null:
		return {}
	if building.is_queued_for_deletion() or belt.is_queued_for_deletion():
		return {}
	if not building.is_inside_tree() or not belt.is_inside_tree():
		return {}

	var input_side: bool = record["input_side"]
	var port := building.get_node_or_null(
		"InputPort" if input_side else "OutputPort"
	) as ItemPortComponent
	var endpoint := belt.get_node_or_null(
		"OutputEndpoint" if input_side else "InputEndpoint"
	) as Marker3D
	if port == null or endpoint == null:
		return {}
	if is_instance_valid(port.connected_conveyor):
		return {}
	if input_side:
		if is_instance_valid(belt.next_segment):
			return {}
		if is_instance_valid(belt.output_building_port):
			return {}
	else:
		if is_instance_valid(belt.previous_segment):
			return {}
		if is_instance_valid(belt.input_building_port):
			return {}

	var outgoing: Marker3D = endpoint if input_side else port
	var incoming: Marker3D = port if input_side else endpoint
	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		outgoing, incoming, ConveyorSegment.CONNECTION_GAP
	):
		return {}
	var original_junction: Vector3 = record["junction"]
	if not original_junction.is_equal_approx(port.global_position):
		return {}

	return {
		"building": building,
		"belt": belt,
		"port": port,
		"input_side": input_side,
		"junction": port.global_position
	}


func release(id: int) -> bool:
	if not _records.has(id):
		return false
	var record: Dictionary = _records[id]
	for role: String in ["building", "belt"]:
		var raw_site: Variant = record[role + "_site"]
		if is_instance_valid(raw_site):
			var site := raw_site as ConstructionSite
			if site != null:
				_disconnect_site(site, id, role)

		var raw_built: Variant = record[role]
		if not is_instance_valid(raw_built):
			continue
		var built := raw_built as Node3D
		var on_exit: Callable = record.get(role + "_built_exit", Callable())
		if (
			built != null
			and on_exit.is_valid()
			and built.tree_exiting.is_connected(on_exit)
		):
			built.tree_exiting.disconnect(on_exit)

	_claims.erase(record["building_key"])
	_claims.erase(record["belt_key"])
	_records.erase(id)
	reservation_released.emit(id)
	return true


func _site_key(site: ConstructionSite, side: String) -> String:
	return "%d:%s" % [site.get_instance_id(), side]


func _observe_site(site: ConstructionSite, id: int, is_building: bool) -> bool:
	# Separate closures per claim allow a building to own both input and
	# output reservations without losing either completion notification.
	var completed_callback := func(built: Node3D) -> void:
		_on_completed(built, id, is_building)
	var cancelled_callback := func() -> void:
		release(id)
	var exiting_callback := func() -> void:
		_on_site_exiting(id, is_building)

	var done_result := site.building_completed.connect(completed_callback)
	var cancel_result := site.job.job_cancelled.connect(cancelled_callback)
	var exit_result := site.tree_exiting.connect(exiting_callback)
	if done_result != OK or cancel_result != OK or exit_result != OK:
		if site.building_completed.is_connected(completed_callback):
			site.building_completed.disconnect(completed_callback)
		if site.job.job_cancelled.is_connected(cancelled_callback):
			site.job.job_cancelled.disconnect(cancelled_callback)
		if site.tree_exiting.is_connected(exiting_callback):
			site.tree_exiting.disconnect(exiting_callback)
		push_error("Could not observe planned building-port connection.")
		return false

	var record: Dictionary = _records[id]
	var role := "building" if is_building else "belt"
	record[role + "_callbacks"] = {
		"completed": completed_callback,
		"cancelled": cancelled_callback,
		"exiting": exiting_callback
	}
	_records[id] = record
	return true


func _disconnect_site(
	site: ConstructionSite, id: int, role: String
) -> void:
	if not _records.has(id):
		return
	var record: Dictionary = _records[id]
	var callbacks: Dictionary = record.get(role + "_callbacks", {})
	if callbacks.is_empty():
		return
	var completed: Callable = callbacks["completed"]
	var cancelled: Callable = callbacks["cancelled"]
	var exiting: Callable = callbacks["exiting"]
	if site.building_completed.is_connected(completed):
		site.building_completed.disconnect(completed)
	if (
		is_instance_valid(site.job)
		and site.job.job_cancelled.is_connected(cancelled)
	):
		site.job.job_cancelled.disconnect(cancelled)
	if site.tree_exiting.is_connected(exiting):
		site.tree_exiting.disconnect(exiting)


func _on_completed(built: Node3D, id: int, is_building: bool) -> void:
	if not _records.has(id):
		return
	if is_building:
		if not is_instance_valid(built.get_node_or_null("InputPort")):
			release(id)
			return
		if not is_instance_valid(built.get_node_or_null("OutputPort")):
			release(id)
			return
	elif not built is ConveyorSegment:
		release(id)
		return

	var record: Dictionary = _records[id]
	var role := "building" if is_building else "belt"
	record[role] = built
	_records[id] = record

	var on_exit := func() -> void:
		release(id)
	if built.tree_exiting.connect(on_exit) != OK:
		release(id)
		push_error("Could not observe completed building-port endpoint.")
		return
	record[role + "_built_exit"] = on_exit
	_records[id] = record

	# Signals do not activate links. E3c must revalidate this candidate
	# and commit the physical ItemPortComponent connection explicitly.
	if not record["announced"] and not get_ready_candidate(id).is_empty():
		record["announced"] = true
		_records[id] = record
		reservation_ready.emit(id)


func _on_site_exiting(id: int, is_building: bool) -> void:
	if not _records.has(id):
		return
	var record: Dictionary = _records[id]
	var built: Variant = record["building" if is_building else "belt"]
	# A completed site retires normally. Unfinished removal releases
	# both endpoint claims without ever spawning an operational link.
	if not is_instance_valid(built):
		release(id)
