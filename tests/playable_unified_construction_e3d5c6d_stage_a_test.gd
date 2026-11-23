extends Node3D
## E3d5c6d Stage A — NEW exact-scope unified construction F6.
## Fixture calls ONLY the real playable adapter's _process(0.1), never the
## underlying dispatch, recovery transport, charging, job or site ticks.
## The accepted E3d5c6b / E3d5c6c fixtures remain unchanged.

const Unified = preload("res://scenes/core/playable_unified_construction_e3d5c6d.tscn")
const OriginalMain = preload("res://scenes/core/main.tscn")
const OriginalDirect = preload("res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn")
const OriginalRecovery = preload("res://scenes/core/playable_cancelled_site_recovery_e3d5c6c_stage_c.tscn")
const Demo = preload("res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState

const PRESS_POS := Vector3(4.5, 0, -3.5)
const STORAGE_POS := Vector3(0, 0, -3)
const HIGH_POS := Vector3(4, 0, -1)


func _ready() -> void:
	call_deferred("_checks")


func _site_at(scope: Node3D, at: Vector3) -> ConstructionSite:
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == scope and not node.is_queued_for_deletion():
			var site := node as ConstructionSite
			if Vector2(site.global_position.x, site.global_position.z).is_equal_approx(Vector2(at.x, at.z)):
				return site
	return null


func _place(demo: Demo, definition: BuildingDefinition, at: Vector3, planned: bool = false) -> ConstructionSite:
	var world: Node = demo.world
	world.set("blueprint_mode_active", planned)
	world.set("placement_mode_active", true)
	var index: int = int(world.call("_find_definition_index", definition.building_id))
	assert(index >= 0, "Definition missing in actual build catalog")
	world.call("_select_building", index)
	assert(is_instance_valid(world.get("placement_ghost")))
	var camera := world.get("camera") as Camera3D
	assert(is_instance_valid(camera))
	camera.make_current()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.05
	camera.global_transform = Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), at + Vector3.UP * 8.0)
	camera.force_update_transform()
	world.call("_try_place_object")
	var site := _site_at(demo.get_parent() as Node3D, at)
	assert(is_instance_valid(site), "Real placement refused: %s at %s" % [definition.building_id, at])
	assert(site.target_definition == definition and site.job != null)
	assert(site.job.state == (ConstructionJob.State.PLANNED if planned else ConstructionJob.State.QUEUED))
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	if not planned:
		assert(demo.is_enrolled_site(site) and not site.is_processing())
	return site


func _tick(demo: Demo) -> void:
	var before: int = demo.tick_count
	demo._process(0.1)
	assert(demo.tick_count == before + 1, "One adapter call must own exactly one lifecycle tick")


func _until(demo: Demo, action: StringName, limit: int = 750) -> bool:
	for i: int in range(limit):
		_tick(demo)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _until_docked(demo: Demo, limit: int = 750) -> bool:
	for i: int in range(limit):
		if demo.drone.get_flight_state() == Flight.DOCKED:
			return true
		_tick(demo)
	return demo.drone.get_flight_state() == Flight.DOCKED


func _finish(demo: Demo, job: ConstructionJob, limit: int = 750) -> void:
	for i: int in range(limit):
		if job.state == ConstructionJob.State.COMPLETE:
			break
		_tick(demo)
	assert(job.state == ConstructionJob.State.COMPLETE)


func _new_case() -> Dictionary:
	var scope := Unified.instantiate() as Node3D
	assert(is_instance_valid(scope))
	add_child(scope)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var demo := scope.get_node("AutomaticConstructionSandbox") as Demo
	assert(is_instance_valid(demo) and demo.has_verified_services())
	assert(demo._recovery_configured and demo.is_processing())
	demo.set_process(false)
	demo.world.set_process(false)
	return {"scope": scope, "demo": demo}


func _end_case(scope: Node3D, demo: Demo) -> void:
	demo.world.call("_destroy_placement_ghost")
	scope.free()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame


func _pair(demo: Demo, site: ConstructionSite) -> Dictionary:
	for entry: Dictionary in demo._site_entries:
		if (entry["site"] as WeakRef).get_ref() == site and entry["job"] == site.job:
			var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
			var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
			if is_instance_valid(staging) and is_instance_valid(port):
				return {"staging": staging, "port": port, "inventory": staging.get_staged_inventory()}
	return {}


func _build_then_rearm(demo: Demo, site: ConstructionSite) -> void:
	var job: ConstructionJob = site.job
	assert(_until(demo, &"collected"))
	assert(_until(demo, &"unloaded"))
	assert(_until(demo, &"admitted"))
	assert(_until(demo, &"construction"))
	_finish(demo, job)
	assert(_until(demo, &"rearmed"))
	assert(demo.drone.get_flight_state() == Flight.IDLE)


func _test_mixed() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	assert(scope.scene_file_path == "res://scenes/core/playable_unified_construction_e3d5c6d.tscn")
	assert(demo.custody != null and demo.recovery != null and demo.recovery.active_ticket() == 0)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.battery_units() == 40.0)
	print("PASS A: Unified exact-scope scene, original accepted adapter and recovery services start")

	var normal_main := OriginalMain.instantiate() as Node3D
	var old_direct := OriginalDirect.instantiate() as Node3D
	var old_recovery := OriginalRecovery.instantiate() as Node3D
	assert(not normal_main.has_node("AutomaticConstructionSandbox"))
	assert(not bool((normal_main.get_node("WorldInteraction") as Node).get("enable_blueprint_planning")))
	assert(old_direct.get_node("AutomaticConstructionSandbox").get_script().resource_path == "res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
	assert(old_recovery.get_node("AutomaticConstructionSandbox").get_script().resource_path == "res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd")
	normal_main.free()
	old_direct.free()
	old_recovery.free()
	print("PASS B: Main and accepted Direct/Recovery scene definitions remain isolated")

	var drones: int = 0
	var dispatchers: int = 0
	var legacy_ticks: int = 0
	var legacy_fleets: int = 0
	for child: Node in scope.get_children():
		if child is PrototypeConstructionWorkerDrone:
			drones += 1
		if child is PrototypeDroneAutomaticDispatch:
			dispatchers += 1
		if child is PrototypeConstructionDroneTickController:
			legacy_ticks += 1
		if child is PrototypeConstructionDroneFleet:
			legacy_fleets += 1
	assert(drones == 1 and dispatchers == 1 and legacy_ticks == 0 and legacy_fleets == 0)
	assert(demo.queue == demo.world.get("_construction_priority_queue"))
	assert(demo.queue.get_parent() == scope and demo.scheduler.uses_priority_queue(demo.queue))
	assert(demo.dispatch._lifecycle_ready())
	_tick(demo)
	assert(demo.last_tick["action"] == &"waiting")
	print("PASS C: One authoritative adapter tick, one drone/dispatcher, original queue, no competing controller")

	var press := _place(demo, PRESS, PRESS_POS)
	var storage := _place(demo, STORAGE, STORAGE_POS)
	assert(demo.queue.get_waiting_sites() == [press, storage])
	assert(press.job.get_remaining_seconds() == 18.0 and storage.job.get_remaining_seconds() == 10.0)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(demo.registry.claim_count() == 2)
	print("PASS D: Direct Press and Storage create original Normal/FIFO jobs and zero free material")

	var high := _place(demo, STORAGE, HIGH_POS, true)
	assert(high.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(high.job.state == ConstructionJob.State.PLANNED and not demo.is_enrolled_site(high))
	assert(demo.queue.get_waiting_sites() == [press, storage])
	assert(demo.stock.get_amount(INGOT) == 15 and demo.custody.ticket_count() == 2)
	print("PASS E: High Blueprint remains PLANNED; changing priority never authorizes or spends stock")

	assert(_until(demo, &"launched"))
	assert(demo.dispatch._assigned_job == press.job and demo.stock.get_reserved_amount(INGOT) == 5)
	assert(_until(demo, &"collected"))
	assert(demo.stock.get_amount(INGOT) == 10 and demo.drone.cargo_amount() == 5)
	assert(demo.drone.global_position.is_equal_approx(demo.dock.global_position))
	assert(demo.escrow.held_count() == 0)
	print("PASS F: Original Normal Direct Press selected; real five-ingot pickup and metered flight")

	var press_pair: Dictionary = _pair(demo, press)
	assert(not press_pair.is_empty())
	var press_buffer := press_pair["inventory"] as InventoryComponent
	assert(_until(demo, &"unloaded"))
	assert(press_buffer.get_amount(INGOT) == 5 and demo.drone.cargo_amount() == 0)
	assert(_until(demo, &"admitted"))
	assert(_until(demo, &"construction"))
	assert(demo.escrow.held_count() == 1 and press_buffer.get_total_amount() == 0)
	assert(demo.power.get_allocated_units(press) == 7 and not press.is_processing())
	var before: float = press.job.get_progress()
	_tick(demo)
	assert(is_equal_approx(press.job.get_progress() - before, 0.1 / 18.0))
	print("PASS G: Original staging -> escrow -> finite power/worker; one construction clock")

	var world: Node = demo.world
	world.set("blueprint_mode_active", true)
	assert(int(world.call("_authorize_all_blueprint_sites")) == 1)
	assert(demo.is_enrolled_site(high) and demo.queue.get_waiting_sites() == [high, storage])
	assert(demo.dispatch._assigned_job == press.job)
	assert(demo.hub.set_generator_enabled(false))
	before = press.job.get_progress()
	_tick(demo)
	assert(press.job.state == ConstructionJob.State.PAUSED and press.job.get_progress() == before)
	assert(high.job.state == ConstructionJob.State.QUEUED and high.job.get_progress() == 0.0)
	assert(demo.hub.set_generator_enabled(true))
	_tick(demo)
	assert(press.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(press.job.get_progress() - before, 0.1 / 18.0))
	print("PASS H: Explicit Blueprint authorization joins shared priority queue; no active preemption; power pause/resume")

	var built: Array[Node3D] = []
	press.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	high.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	storage.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	_finish(demo, press.job)
	assert(built.size() == 1 and built[0].scene_file_path == PRESS.building_scene.resource_path)
	assert(demo.escrow.held_count() == 0 and demo.stock.get_amount(INGOT) == 10)
	var producer := built[0].get_node("ProducerComponent") as ProducerComponent
	assert(is_instance_valid(producer) and producer.is_processing())
	print("PASS I: Direct Press activates once at 18 seconds; escrow committed; producer live")

	assert(_until_docked(demo))
	var dock_energy: float = demo.drone.battery_units()
	assert(dock_energy < 40.0)
	assert(demo.hub.set_generator_enabled(false))
	_tick(demo)
	assert(demo.last_tick["action"] == &"dock_wait" and demo.drone.battery_units() == dock_energy)
	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"rearmed"))
	assert(is_equal_approx(demo.drone.battery_units(), 40.0) and demo.drone.get_flight_state() == Flight.IDLE)
	print("PASS J: Same drone returns, finite generator-OFF charging wait and powered rearm")

	assert(_until(demo, &"launched") and demo.dispatch._assigned_job == high.job)
	_build_then_rearm(demo, high)
	assert(demo.stock.get_amount(INGOT) == 7 and built.size() == 2)
	assert(_until(demo, &"launched") and demo.dispatch._assigned_job == storage.job)
	_build_then_rearm(demo, storage)
	assert(demo.stock.get_amount(INGOT) == 4 and built.size() == 3)
	assert(demo.escrow.held_count() == 0 and demo.recovery.completed_count() == 0)
	assert(demo.drone.completed_rearms() == 3)
	print("PASS K: Explicit High Blueprint precedes waiting Normal Direct; all 3 physical builds, 15 -> 4 ingots")
	await _end_case(scope, demo)


func _test_cargo_cancellation() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	var early := _place(demo, PRESS, PRESS_POS)
	var early_pair: Dictionary = _pair(demo, early)
	assert(_until(demo, &"launched") and demo.stock.get_reserved_amount(INGOT) == 5)
	assert(demo.world.call("_cancel_blueprint_site", early))
	assert(_until(demo, &"rearmed"))
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert((early_pair["inventory"] as InventoryComponent).get_total_amount() == 0)
	assert(demo.recovery.completed_count() == 0)
	print("PASS L: Pre-pickup cancel releases original supplier reservation without debit")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	var loaded := _place(demo, PRESS, PRESS_POS)
	assert(_until(demo, &"launched") and _until(demo, &"collected"))
	assert(demo.stock.get_amount(INGOT) == 10 and demo.drone.cargo_amount() == 5)
	assert(demo.world.call("_cancel_blueprint_site", loaded))
	demo.dock.allow_returns = false
	_tick(demo)
	assert(demo.last_tick["action"] == &"recovery_wait" and demo.drone.cargo_amount() == 5)
	assert(demo.stock.get_amount(INGOT) == 10)
	demo.dock.allow_returns = true
	assert(_until(demo, &"rearmed"))
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(demo.returns.reservation_count() == 0)
	print("PASS M: Loaded-cargo cancellation waits for dock and physically restores exact five ingots")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	var delivered := _place(demo, PRESS, PRESS_POS)
	var delivered_pair: Dictionary = _pair(demo, delivered)
	var buffer := delivered_pair["inventory"] as InventoryComponent
	var ticket: int = demo.recovery_tickets.back()
	assert(_until(demo, &"launched") and _until(demo, &"collected") and _until(demo, &"unloaded"))
	assert(buffer.get_amount(INGOT) == 5 and demo.stock.get_amount(INGOT) == 10)
	assert(demo.world.call("_cancel_blueprint_site", delivered))
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(demo.registry.has_locked_pair(delivered_pair["staging"], delivered_pair["port"]))
	assert(_until(demo, &"rearmed"))
	assert(_until(demo, &"site_flight") and demo.recovery.active_ticket() == ticket)
	assert(_until(demo, &"collected") and buffer.get_total_amount() == 0 and demo.drone.cargo_amount() == 5)
	assert(_until(demo, &"unloaded") and demo.stock.get_amount(INGOT) == 15)
	assert(_until(demo, &"rearmed") and demo.recovery.completed_count() == 1)
	assert(demo.recovery.recovered_amount(ticket) == 5 and demo.drone.cargo_amount() == 0)
	assert(demo.registry.has_locked_pair(delivered_pair["staging"], delivered_pair["port"]))
	print("PASS N: Post-delivery cancel captures original ticket; same drone returns five staged ingots, lock retained")
	await _end_case(scope, demo)


func _test_working_and_capacity() -> void:
	var instance: Dictionary = await _new_case()
	var scope := instance["scope"] as Node3D
	var demo := instance["demo"] as Demo
	var working := _place(demo, STORAGE, STORAGE_POS)
	var working_pair: Dictionary = _pair(demo, working)
	var buffer := working_pair["inventory"] as InventoryComponent
	var ticket: int = demo.recovery_tickets.back()
	var built: Array[Node3D] = []
	working.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	assert(_until(demo, &"launched") and _until(demo, &"collected") and _until(demo, &"unloaded"))
	assert(_until(demo, &"admitted") and _until(demo, &"construction"))
	assert(demo.escrow.held_count() == 1 and demo.stock.get_amount(INGOT) == 12)
	assert(demo.world.call("_cancel_blueprint_site", working))
	assert(demo.escrow.held_count() == 0 and buffer.get_amount(INGOT) == 3)
	assert(demo.custody.observe(ticket)["status"] == &"ready_read_only")
	assert(_until(demo, &"rearmed") and _until(demo, &"site_flight"))
	assert(_until(demo, &"collected") and demo.drone.cargo_amount() == 3)
	assert(_until(demo, &"unloaded") and demo.stock.get_amount(INGOT) == 15)
	assert(_until(demo, &"rearmed") and demo.recovery.completed_count() == 1)
	assert(built.is_empty() and demo.registry.has_locked_pair(working_pair["staging"], working_pair["port"]))
	print("PASS O: Cancellation during construction settles escrow to locked staging, then physically returns three ingots")
	await _end_case(scope, demo)

	instance = await _new_case()
	scope = instance["scope"] as Node3D
	demo = instance["demo"] as Demo
	var full := _place(demo, PRESS, PRESS_POS)
	var full_pair: Dictionary = _pair(demo, full)
	var full_buffer := full_pair["inventory"] as InventoryComponent
	var full_ticket: int = demo.recovery_tickets.back()
	assert(_until(demo, &"launched") and _until(demo, &"collected") and _until(demo, &"unloaded"))
	assert(demo.world.call("_cancel_blueprint_site", full))
	assert(full_buffer.get_amount(INGOT) == 5 and demo.stock.get_amount(INGOT) == 10)
	demo.stock.max_capacity = 10
	assert(_until(demo, &"rearmed") and _until(demo, &"recovery_wait"))
	assert(demo.recovery.active_ticket() == 0 and demo.drone.cargo_amount() == 0)
	assert(full_buffer.get_amount(INGOT) == 5 and demo.stock.get_reserved_return_space() == 0)
	demo.stock.max_capacity = 20
	assert(_until(demo, &"site_flight") and demo.stock.get_reserved_return_space() == 5)
	assert(_until(demo, &"collected") and demo.drone.cargo_amount() == 5)
	assert(_until(demo, &"unloaded") and demo.stock.get_amount(INGOT) == 15)
	assert(_until(demo, &"rearmed") and demo.recovery.recovered_amount(full_ticket) == 5)
	for i: int in range(8):
		_tick(demo)
	assert(demo.recovery.completed_count() == 1 and demo.recovery.active_ticket() == 0)
	assert(demo.stock.get_amount(INGOT) == 15 and full_buffer.get_total_amount() == 0)
	assert(demo.registry.has_locked_pair(full_pair["staging"], full_pair["port"]))
	print("PASS P: Full Storage capacity blocks physical recovery; restoration and repeat ticks conserve stock once")
	await _end_case(scope, demo)


func _checks() -> void:
	await _test_mixed()
	await _test_cargo_cancellation()
	await _test_working_and_capacity()
	print("ALL 16 E3D5C6D STAGE A UNIFIED CONSTRUCTION TESTS PASSED")
