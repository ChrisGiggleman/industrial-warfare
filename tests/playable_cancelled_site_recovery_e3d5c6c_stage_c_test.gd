extends Node3D
## E3d5c6c Stage C: opt-in playable-path single-adapter integration.
## Test drives the real playable adapter's ONE _process tick deterministically;
## never calls transport.begin/tick or fabricates/teleports recovered stock.
const Demo = preload("res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd")
const Playable = preload("res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState
const STORAGE_POS := Vector3(0, 0, -3)
const PRESS_POS := Vector3(4.5, 0, -3.5)


func _ready() -> void:
	call_deferred("_checks")


func _sites(scope: Node3D) -> Array[ConstructionSite]:
	var result: Array[ConstructionSite] = []
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == scope and not node.is_queued_for_deletion():
			result.append(node as ConstructionSite)
	return result


func _at(scope: Node3D, wanted: Vector3) -> ConstructionSite:
	for site: ConstructionSite in _sites(scope):
		if Vector2(site.global_position.x, site.global_position.z).is_equal_approx(Vector2(wanted.x, wanted.z)):
			return site
	return null


func _place(demo: Demo, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var world := demo.world
	world.set("blueprint_mode_active", false)
	world.set("placement_mode_active", true)
	var index: int = int(world.call("_find_definition_index", definition.building_id))
	assert(index >= 0)
	world.call("_select_building", index)
	assert(world.get("placement_ghost") != null)
	var camera := world.get("camera") as Camera3D
	assert(is_instance_valid(camera))
	camera.make_current()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.05
	camera.global_transform = Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), at + Vector3.UP * 8.0)
	camera.force_update_transform()
	world.call("_try_place_object")
	var site := _at(demo.get_parent() as Node3D, at)
	assert(is_instance_valid(site), "Direct placement failed at %s" % at)
	assert(site.job != null and site.job.state == ConstructionJob.State.QUEUED)
	assert(demo.is_enrolled_site(site) and not site.is_processing())
	return site


func _pair(demo: Demo, site: ConstructionSite) -> Dictionary:
	for entry: Dictionary in demo._site_entries:
		if (entry["site"] as WeakRef).get_ref() == site and entry["job"] == site.job:
			var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
			var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
			if is_instance_valid(staging) and is_instance_valid(port):
				return {"staging": staging, "port": port, "buffer": staging.get_staged_inventory()}
	return {}


func _until(demo: Demo, action: StringName, limit: int = 650) -> bool:
	for i: int in range(limit):
		demo._process(0.1)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _get_ready() -> Dictionary:
	var sandbox := Playable.instantiate() as Node3D
	add_child(sandbox)
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	return {"sandbox": sandbox, "demo": demo}


func _test_storage() -> void:
	var instance: Dictionary = _get_ready()
	var sandbox := instance["sandbox"] as Node3D
	var demo := instance["demo"] as Demo
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo.is_processing())
	assert(demo._recovery_configured and demo.custody != null and demo.recovery != null)
	assert(demo.recovery.active_ticket() == 0 and demo.recovery.completed_count() == 0)
	assert(demo.drone.get_parent() == sandbox and demo.stock.get_amount(INGOT) == 15)
	assert(demo.get_script().resource_path == "res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd")
	print("PASS A: Separate opt-in playable scene; original single drone and adapter")
	# F6 harness, not an additional simulation owner. The real adapter's
	# _process remains the only entry driven by the test loop.
	demo.set_process(false)
	demo.world.set_process(false)
	var site := _place(demo, STORAGE, STORAGE_POS)
	var pair: Dictionary = _pair(demo, site)
	assert(not pair.is_empty())
	var buffer := pair["buffer"] as InventoryComponent
	assert(buffer.get_total_amount() == 0 and demo.custody.ticket_count() == 1)
	assert(demo.recovery_tickets.size() == 1)
	var ticket: int = demo.recovery_tickets[0]
	assert(demo.custody.observe(ticket)["status"] == &"active_not_recoverable")
	print("PASS B: Real direct authorization automatically captures immutable original custody ticket")
	assert(_until(demo, &"launched") and _until(demo, &"collected") and _until(demo, &"unloaded"))
	assert(buffer.get_amount(INGOT) == 3 and demo.stock.get_amount(INGOT) == 12)
	assert(demo.drone.cargo_amount() == 0)
	print("PASS C: Normal original dispatch physically delivers 3 ingots without recovery interception")
	var cancelled_job: ConstructionJob = site.job
	assert(demo.world.call("_cancel_blueprint_site", site))
	assert(cancelled_job.state == ConstructionJob.State.CANCELLED)
	assert(buffer.get_amount(INGOT) == 3 and demo.stock.get_amount(INGOT) == 12)
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	print("PASS D: X cancellation retains exact 3 ingots in locked original staging, not free Storage stock")
	assert(_until(demo, &"rearmed"))
	assert(demo.drone.get_flight_state() == Flight.IDLE and not demo.dispatch.has_lifecycle_assignment())
	assert(_until(demo, &"site_flight"))
	assert(demo.recovery.active_ticket() == ticket and demo.stock.get_reserved_return_space() == 3)
	assert(buffer.get_amount(INGOT) == 3 and demo.drone.cargo_amount() == 0)
	print("PASS E: Adapter itself starts physical recovery after original drone rearm; exact return capacity reserved")
	assert(_until(demo, &"collected"))
	assert(demo.drone.cargo_amount() == 3 and buffer.get_total_amount() == 0)
	assert(demo.drone.global_position.is_equal_approx(demo.custody.observe(ticket)["hover_position"]))
	assert(demo.drone.battery_units() < 40.0)
	print("PASS F: Original-site flight, finite battery use and physical pickup into the same drone")
	demo.dock.available = false
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"destination_wait" and demo.drone.cargo_amount() == 3)
	assert(demo.stock.get_amount(INGOT) == 12 and demo.stock.get_reserved_return_space() == 3)
	demo.dock.available = true
	print("PASS G: Unavailable Storage dock safely waits with cargo held and source empty")
	assert(_until(demo, &"unloaded"))
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(demo.stock.get_reserved_return_space() == 0 and buffer.get_total_amount() == 0)
	print("PASS H: Arrived at real Storage dock; 12 + 3 physically restored to 15")
	for i: int in range(400):
		if demo.drone.get_flight_state() == Flight.DOCKED:
			break
		demo._process(0.1)
		assert(demo.last_tick.get("action") == &"home_flight")
	assert(demo.drone.get_flight_state() == Flight.DOCKED)
	var battery_before: float = demo.drone.battery_units()
	assert(battery_before < 40.0 and demo.hub.set_generator_enabled(false))
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"dock_wait" and demo.drone.battery_units() == battery_before)
	assert(demo.hub.set_generator_enabled(true))
	print("PASS I: Same drone returns to Hub; generator-OFF prevents free battery recharge")
	assert(_until(demo, &"rearmed", 400))
	assert(demo.recovery.active_ticket() == 0 and demo.recovery.completed_count() == 1)
	assert(demo.recovery.recovered_amount(ticket) == 3 and demo.drone.get_flight_state() == Flight.IDLE)
	assert(demo.stock.get_amount(INGOT) == 15)
	print("PASS J: Finite recharge and one physical return completion; original drone reusable")
	for i: int in range(8):
		demo._process(0.1)
	assert(demo.recovery.completed_count() == 1 and demo.recovery.active_ticket() == 0)
	assert(demo.custody.observe(ticket)["status"] == &"empty_no_pickup")
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	assert(demo.stock.get_amount(INGOT) + buffer.get_total_amount() == 15)
	print("PASS K: No duplicate recovery, no staging unlock, material conservation")
	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	await get_tree().process_frame


func _test_press() -> void:
	var instance: Dictionary = _get_ready()
	var sandbox := instance["sandbox"] as Node3D
	var demo := instance["demo"] as Demo
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo._recovery_configured)
	demo.set_process(false)
	demo.world.set_process(false)
	var press := _place(demo, PRESS, PRESS_POS)
	var pair: Dictionary = _pair(demo, press)
	assert(not pair.is_empty())
	var buffer := pair["buffer"] as InventoryComponent
	assert(demo.custody.ticket_count() == 1 and demo.recovery_tickets.size() == 1)
	var ticket: int = demo.recovery_tickets[0]
	assert(_until(demo, &"launched") and _until(demo, &"collected") and _until(demo, &"unloaded"))
	assert(buffer.get_amount(INGOT) == 5 and demo.stock.get_amount(INGOT) == 10)
	assert(demo.world.call("_cancel_blueprint_site", press))
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	print("PASS L: Separate direct Press captures five original staged ingots and cancels cleanly")
	# No capacity means no claim and no remote source debit. The adapter
	# must wait, not launch a duplicate/fake drone or resume normal work.
	demo.stock.max_capacity = 10
	assert(_until(demo, &"rearmed"))
	assert(_until(demo, &"recovery_wait"))
	assert(demo.recovery.active_ticket() == 0 and demo.drone.cargo_amount() == 0)
	assert(buffer.get_amount(INGOT) == 5 and demo.stock.get_reserved_return_space() == 0)
	print("PASS M: Full eligible Storage safely blocks playable return without losing materials")
	demo.stock.max_capacity = 20
	assert(_until(demo, &"site_flight"))
	assert(demo.recovery.active_ticket() == ticket and demo.stock.get_reserved_return_space() == 5)
	assert(_until(demo, &"collected"))
	assert(buffer.get_amount(INGOT) == 0 and demo.drone.cargo_amount() == 5)
	assert(_until(demo, &"unloaded"))
	assert(demo.stock.get_amount(INGOT) == 15 and demo.stock.get_reserved_return_space() == 0)
	assert(_until(demo, &"rearmed", 400))
	assert(demo.recovery.completed_count() == 1 and demo.recovery.recovered_amount(ticket) == 5)
	assert(demo.drone.get_flight_state() == Flight.IDLE and demo.stock.get_amount(INGOT) == 15)
	print("PASS N: Full capacity restored; adapter auto-flies Press 5 ingots back, recharges and rearms")
	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	await get_tree().process_frame


func _checks() -> void:
	await _test_storage()
	await _test_press()
	print("ALL 14 PLAYABLE CANCELLED SITE RECOVERY E3D5C6C STAGE C TESTS PASSED")
