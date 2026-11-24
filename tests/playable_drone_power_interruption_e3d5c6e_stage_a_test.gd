extends Node3D
## E3d5c6e Stage A. New exact-scene F6 isolated acceptance only.
## Every simulation step invokes the inherited one-and-only playable
## adapter _process(0.1). No drone, dispatch, recovery or job is ticked
## directly and no accepted scene/fixture is altered.

const PowerScene = preload("res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn")
const OldUnified = preload("res://scenes/core/playable_unified_construction_e3d5c6d.tscn")
const OldRecovery = preload("res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn")
const OldDirect = preload("res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn")
const Main = preload("res://scenes/core/main.tscn")
const Demo = preload("res://scripts/ui/playable_drone_power_interruption_e3d5c6e.gd")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState
const PRESS_POS := Vector3(4.5, 0, -3.5)


func _ready() -> void:
	call_deferred("_checks")


func _site_at(scope: Node3D, at: Vector3) -> ConstructionSite:
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == scope and not node.is_queued_for_deletion():
			var site := node as ConstructionSite
			if Vector2(site.global_position.x, site.global_position.z).is_equal_approx(Vector2(at.x, at.z)):
				return site
	return null


func _place_press(demo: Demo) -> ConstructionSite:
	var world: Node = demo.world
	world.set("blueprint_mode_active", false)
	world.set("placement_mode_active", true)
	var index: int = int(world.call("_find_definition_index", PRESS.building_id))
	assert(index >= 0)
	world.call("_select_building", index)
	assert(is_instance_valid(world.get("placement_ghost")))
	var camera := world.get("camera") as Camera3D
	assert(is_instance_valid(camera))
	camera.make_current()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.05
	camera.global_transform = Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), PRESS_POS + Vector3.UP * 8.0)
	camera.force_update_transform()
	world.call("_try_place_object")
	var site := _site_at(demo.get_parent() as Node3D, PRESS_POS)
	assert(is_instance_valid(site))
	assert(site.target_definition == PRESS and site.job != null)
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	assert(demo.is_enrolled_site(site) and not site.is_processing())
	return site


func _tick(demo: Demo) -> void:
	var before: int = demo.tick_count
	demo._process(0.1)
	assert(demo.tick_count == before + 1, "Single inherited adapter tick only")


func _until(demo: Demo, action: StringName, limit: int = 800) -> bool:
	for i: int in range(limit):
		_tick(demo)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _until_docked(demo: Demo, limit: int = 800) -> bool:
	for i: int in range(limit):
		if demo.drone.get_flight_state() == Flight.DOCKED:
			return true
		_tick(demo)
	return demo.drone.get_flight_state() == Flight.DOCKED


func _new_case() -> Dictionary:
	var scope := PowerScene.instantiate() as Node3D
	assert(is_instance_valid(scope))
	add_child(scope)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var demo := scope.get_node("AutomaticConstructionSandbox") as Demo
	assert(is_instance_valid(demo) and demo.has_verified_services())
	assert(demo._recovery_configured and demo.is_processing())
	assert(demo.dispatch._parking_enabled() and demo.drone.enable_isolated_power_parking)
	demo.set_process(false)
	demo.world.set_process(false)
	return {"scope": scope, "demo": demo}


func _end_case(scope: Node3D, demo: Demo) -> void:
	demo.world.call("_destroy_placement_ghost")
	scope.free()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame


func _original_pair(demo: Demo, site: ConstructionSite) -> Dictionary:
	for entry: Dictionary in demo._site_entries:
		if (entry["site"] as WeakRef).get_ref() == site and entry["job"] == site.job:
			var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
			var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
			if is_instance_valid(staging) and is_instance_valid(port):
				return {"staging": staging, "port": port, "inventory": staging.get_staged_inventory()}
	return {}


func _admit_press(demo: Demo) -> ConstructionSite:
	var site := _place_press(demo)
	assert(_until(demo, &"launched"))
	assert(_until(demo, &"collected"))
	assert(demo.stock.get_amount(INGOT) == 10 and demo.drone.cargo_amount() == 5)
	assert(_until(demo, &"unloaded"))
	assert(_until(demo, &"admitted"))
	assert(_until(demo, &"construction"))
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(demo.escrow.held_count() == 1 and demo.drone.cargo_amount() == 0)
	return site


func _park_press(demo: Demo) -> ConstructionSite:
	var site := _admit_press(demo)
	assert(demo.hub.set_generator_enabled(false))
	var old_progress: float = site.job.get_progress()
	assert(_until(demo, &"parking_started", 80))
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(site.job.get_progress() == old_progress)
	assert(demo.drone._power_parked_assignment)
	assert(demo.dispatch.has_lifecycle_assignment())
	return site


func _assert_exact_recovery(demo: Demo, ticket: int, buffer: InventoryComponent, amount: int) -> void:
	assert(_until(demo, &"rearmed", 1000))
	assert(demo.drone.get_flight_state() == Flight.IDLE and not demo.dispatch.has_lifecycle_assignment())
	assert(_until(demo, &"site_flight", 1000))
	assert(_until(demo, &"collected", 1000))
	assert(demo.drone.cargo_amount() == amount and buffer.get_total_amount() == 0)
	assert(_until(demo, &"unloaded", 1000))
	assert(demo.stock.get_amount(INGOT) == 15)
	assert(_until(demo, &"rearmed", 1000))
	assert(demo.recovery.completed_count() == 1 and demo.recovery.recovered_amount(ticket) == amount)
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	for i: int in range(6):
		_tick(demo)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.recovery.completed_count() == 1)


func _test_primary() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	assert(scope.scene_file_path == "res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn")
	assert(demo.custody != null and demo.recovery != null and demo.recovery.active_ticket() == 0)
	assert(demo.drone.battery_units() == 40.0 and demo.stock.get_amount(INGOT) == 15)
	print("PASS A: New exact-scope scene starts existing recovery adapter with parking opt-in")

	var main := Main.instantiate() as Node3D
	var direct := OldDirect.instantiate() as Node3D
	var old_recovery := OldRecovery.instantiate() as Node3D
	var old_unified := OldUnified.instantiate() as Node3D
	assert(not main.has_node("AutomaticConstructionSandbox"))
	assert(not bool(main.get_node("WorldInteraction").get("enable_blueprint_planning")))
	assert(direct.get_node("AutomaticConstructionSandbox").get_script().resource_path == "res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
	assert(old_recovery.get_node("AutomaticConstructionSandbox").get_script().resource_path == "res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd")
	assert(old_unified.get_node("AutomaticConstructionSandbox").get_script().resource_path == "res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd")
	main.free()
	direct.free()
	old_recovery.free()
	old_unified.free()
	print("PASS B: Main and accepted old scenes keep distinct original adapter identities")

	var drones: int = 0
	var dispatchers: int = 0
	var fleets: int = 0
	var tick_controllers: int = 0
	for child: Node in scope.get_children():
		if child is PrototypeConstructionWorkerDrone:
			drones += 1
		if child is PrototypeDroneAutomaticDispatch:
			dispatchers += 1
		if child is PrototypeConstructionDroneFleet:
			fleets += 1
		if child is PrototypeConstructionDroneTickController:
			tick_controllers += 1
	assert(drones == 1 and dispatchers == 1 and fleets == 0 and tick_controllers == 0)
	assert(demo.queue == demo.world.get("_construction_priority_queue"))
	assert(demo.scheduler.uses_priority_queue(demo.queue))
	_tick(demo)
	assert(demo.last_tick["action"] == &"waiting")
	print("PASS C: Original priority queue, one drone, dispatcher and authoritative adapter tick")

	var site := _admit_press(demo)
	var pair: Dictionary = _original_pair(demo, site)
	assert(not pair.is_empty())
	var buffer := pair["inventory"] as InventoryComponent
	assert(buffer.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 10)
	assert(demo.escrow.matches_site_source_bill(site, buffer))
	assert(demo.scheduler.get_active_sites().has(site))
	assert(demo.drone.get_flight_state() == Flight.AT_SITE)
	print("PASS D: Original physical five-ingot Press delivery, pinned escrow and worker admission")

	var before: float = site.job.get_progress()
	assert(demo.hub.set_generator_enabled(false))
	for i: int in range(10):
		_tick(demo)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(is_equal_approx(site.job.get_progress(), before))
	assert(demo.drone.get_flight_state() == Flight.AT_SITE and not demo.drone._power_parked_assignment)
	assert(demo.stock.get_amount(INGOT) == 10 and demo.escrow.held_count() == 1)
	assert(demo.hub.set_generator_enabled(true))
	_tick(demo)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(site.job.get_progress() > before)
	print("PASS E: 1-second power flicker pauses construction without parking or inventory change")

	assert(demo.hub.set_generator_enabled(false))
	before = site.job.get_progress()
	assert(_until(demo, &"parking_started", 80))
	assert(site.job.state == ConstructionJob.State.PAUSED and site.job.get_progress() == before)
	assert(demo.drone._power_parked_assignment and demo.drone.get_flight_state() == Flight.RETURNING)
	assert(demo.dispatch.has_lifecycle_assignment() and demo.stock.get_amount(INGOT) == 10)
	assert(demo.scheduler.get_active_count() == 0)
	assert(demo.escrow.matches_site_source_bill(site, buffer))
	print("PASS F: Sustained blackout starts metered return; original paused job, slot and escrow remain safe")

	var departing: float = demo.drone.battery_units()
	assert(_until(demo, &"parking_return", 100))
	assert(demo.drone.battery_units() < departing)
	assert(_until_docked(demo, 300))
	assert(demo.drone.get_flight_state() == Flight.DOCKED and demo.drone._power_parked_assignment)
	assert(demo.dispatch.has_lifecycle_assignment())
	assert(demo.drone.global_position.is_equal_approx(demo.hub.global_position + Vector3.UP * 2.0))
	print("PASS G: Same drone physically parks at original Hub on finite battery; no assignment release")

	var energy: float = demo.drone.battery_units()
	for i: int in range(15):
		_tick(demo)
		assert(demo.last_tick["action"] == &"park_wait")
	assert(demo.drone.battery_units() == energy and site.job.state == ConstructionJob.State.PAUSED)
	assert(demo.stock.get_amount(INGOT) == 10 and demo.escrow.held_count() == 1)
	assert(demo.custody.ticket_count() == 1 and demo.recovery.completed_count() == 0)
	print("PASS H: Hub generator OFF charges zero; site progress, real material custody and ticket remain unchanged")

	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"resume_started", 800))
	assert(demo.drone.get_flight_state() == Flight.OUTBOUND and demo.drone._power_parked_assignment)
	assert(demo.drone._delivery_buffer.get_ref() == buffer and demo.dispatch._assigned_job == site.job)
	assert(demo.stock.get_amount(INGOT) == 10 and demo.drone.cargo_amount() == 0)
	assert(demo.scheduler.get_active_count() == 0)
	print("PASS I: Real restored power permits route-safe original-site resume, never a second pickup")

	assert(_until(demo, &"resume_flight", 100))
	assert(_until(demo, &"resumed", 300))
	assert(demo.drone.get_flight_state() == Flight.AT_SITE and not demo.drone._power_parked_assignment)
	assert(demo.scheduler.get_active_sites().has(site) and site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(site.job.get_progress() == before)
	assert(demo.stock.get_amount(INGOT) == 10 and demo.escrow.held_count() == 1)
	print("PASS J: Drone reattaches original worker; no remote construction or progress/material reset")

	var completed: Array[Node3D] = []
	site.building_completed.connect(func(building: Node3D) -> void: completed.append(building))
	assert(_until(demo, &"construction", 50))
	for i: int in range(500):
		if site.job.state == ConstructionJob.State.COMPLETE:
			break
		_tick(demo)
	assert(site.job.state == ConstructionJob.State.COMPLETE and completed.size() == 1)
	assert(completed[0].scene_file_path == PRESS.building_scene.resource_path)
	assert(demo.escrow.held_count() == 0 and demo.stock.get_amount(INGOT) == 10)
	assert(_until(demo, &"rearmed", 800))
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	print("PASS K: Original saved Press finishes once and commits escrow once; single drone rearms")
	await _end_case(scope, demo)


func _test_cancel_while_returning() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	var site := _park_press(demo)
	var pair: Dictionary = _original_pair(demo, site)
	var buffer := pair["inventory"] as InventoryComponent
	var ticket: int = demo.recovery_tickets.back()
	assert(demo.drone.get_flight_state() == Flight.RETURNING)
	assert(demo.world.call("_cancel_blueprint_site", site))
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(demo.stock.get_amount(INGOT) == 10 and buffer.get_amount(INGOT) == 5)
	assert(_until_docked(demo, 400))
	assert(demo.dispatch.has_lifecycle_assignment())
	assert(demo.hub.set_generator_enabled(true))
	_assert_exact_recovery(demo, ticket, buffer, 5)
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	print("PASS L: Cancel during blackout return: terminal rearm then physical original-site five-ingot recovery")
	await _end_case(scope, demo)


func _test_cancel_while_parked() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	var site := _park_press(demo)
	var pair: Dictionary = _original_pair(demo, site)
	var buffer := pair["inventory"] as InventoryComponent
	var ticket: int = demo.recovery_tickets.back()
	assert(_until_docked(demo, 400))
	assert(demo.drone._power_parked_assignment and demo.drone.get_flight_state() == Flight.DOCKED)
	assert(demo.world.call("_cancel_blueprint_site", site))
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(demo.stock.get_amount(INGOT) == 10 and buffer.get_amount(INGOT) == 5)
	for i: int in range(10):
		_tick(demo)
	assert(demo.recovery.completed_count() == 0 and demo.stock.get_amount(INGOT) == 10)
	assert(demo.hub.set_generator_enabled(true))
	_assert_exact_recovery(demo, ticket, buffer, 5)
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	print("PASS M: Cancel parked at powerless Hub: retain staging and recover only through original same-drone trip")
	await _end_case(scope, demo)


func _test_abort_and_low_battery() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	var site := _park_press(demo)
	var original: ConstructionJob = site.job
	var prior: float = original.get_progress()
	assert(demo.hub.set_generator_enabled(true))
	# Power restoration mid-return never teleports the drone to site.
	assert(_until_docked(demo, 400))
	assert(demo.drone._power_parked_assignment)
	assert(_until(demo, &"resume_started", 800))
	assert(demo.hub.set_generator_enabled(false))
	assert(_until(demo, &"resume_aborted", 80))
	assert(demo.drone.get_flight_state() == Flight.RETURNING)
	assert(_until_docked(demo, 400))
	assert(demo.drone._power_parked_assignment and original.state == ConstructionJob.State.PAUSED)
	assert(original.get_progress() == prior and demo.stock.get_amount(INGOT) == 10)
	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"resumed", 900))
	assert(original.state == ConstructionJob.State.CONSTRUCTING and original.get_progress() == prior)
	await _end_case(scope, demo)

	instance = await _new_case()
	scope = instance["scope"] as Node3D
	demo = instance["demo"] as Demo
	site = _admit_press(demo)
	assert(demo.hub.set_generator_enabled(false))
	# Isolated negative-test fault injection: reduce existing charge only,
	# never manufacture battery, charge, materials, job time or inventory.
	demo.drone._battery_units = 0.1
	var fixed: Vector3 = demo.drone.global_position
	var paused_progress: float = site.job.get_progress()
	for i: int in range(30):
		_tick(demo)
	assert(site.job.state == ConstructionJob.State.PAUSED)
	assert(demo.drone.get_flight_state() == Flight.AT_SITE)
	assert(demo.drone.global_position.is_equal_approx(fixed))
	assert(demo.drone.battery_units() == 0.1 and site.job.get_progress() == paused_progress)
	assert(not demo.drone._power_parked_assignment and demo.stock.get_amount(INGOT) == 10)
	await _end_case(scope, demo)

	# Cancellation during outbound re-approach must NOT re-deliver material
	# or bypass the locked original-site physical recovery mission.
	instance = await _new_case()
	scope = instance["scope"] as Node3D
	demo = instance["demo"] as Demo
	site = _park_press(demo)
	var pair: Dictionary = _original_pair(demo, site)
	var buffer := pair["inventory"] as InventoryComponent
	var ticket: int = demo.recovery_tickets.back()
	assert(_until_docked(demo, 400))
	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"resume_started", 800))
	assert(demo.drone.get_flight_state() == Flight.OUTBOUND)
	assert(demo.world.call("_cancel_blueprint_site", site))
	assert(demo.drone.get_flight_state() == Flight.RETURNING)
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(demo.stock.get_amount(INGOT) == 10 and buffer.get_amount(INGOT) == 5)
	_assert_exact_recovery(demo, ticket, buffer, 5)
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	await _end_case(scope, demo)
	print("PASS N: Flapping/outbound interruption, low-battery fail-closed and resume-flight cancellation conserve materials")


func _checks() -> void:
	await _test_primary()
	await _test_cancel_while_returning()
	await _test_cancel_while_parked()
	await _test_abort_and_low_battery()
	print("ALL 14 E3D5C6E STAGE A POWER INTERRUPTION TESTS PASSED")
