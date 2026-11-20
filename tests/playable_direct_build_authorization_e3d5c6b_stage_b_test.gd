extends Node3D
## Stage B: actual direct placement and explicit blueprint clicks, one accepted
## adapter lifecycle caller. No test shortcuts for authorization, cargo or work.
const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Direct = preload("res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const RECIPE = preload("res://data/recipes/prototype_ammunition_press.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState
const PRESS_POS := Vector3(4.5, 0, -3.5)
const HIGH_POS := Vector3(0, 0, -3)
const STORAGE_POS := Vector3(4, 0, -1)
# Stage A's direct preview performs full-size physics collision checks.
# The former (2.5, 0, -0.5) shared an exact footprint edge with the
# completed Storage at (4, 0, -1); use the separately accepted open
# LATE_POS from expansion Stage C instead. No gameplay collision changes.
const WAIT_POS := Vector3(-5, 0, 0)
const CANCEL_POS := Vector3(4.5, 0, -3.5)


func _ready() -> void:
	call_deferred("_checks")


func _sites(scope: Node3D) -> Array[ConstructionSite]:
	var sites: Array[ConstructionSite] = []
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == scope and not node.is_queued_for_deletion():
			sites.append(node as ConstructionSite)
	return sites


# Legacy placement may parent buildings at current_scene instead of the
# sandbox child. Count both through the test root, excluding visual ghosts.
func _completed_count(definition: BuildingDefinition) -> int:
	var count: int = 0
	for node: Node in find_children("*", "Node3D", true, false):
		if node.scene_file_path == definition.building_scene.resource_path and not node.is_in_group("construction_preview") and not node.is_queued_for_deletion():
			count += 1
	return count


func _at(scope: Node3D, at: Vector3) -> ConstructionSite:
	for site: ConstructionSite in _sites(scope):
		if Vector2(site.global_position.x, site.global_position.z).is_equal_approx(Vector2(at.x, at.z)):
			return site
	return null


func _select(world: Node, definition: BuildingDefinition) -> void:
	world.set("placement_mode_active", true)
	var index: int = world.call("_find_definition_index", definition.building_id)
	assert(index >= 0)
	world.call("_select_building", index)
	assert(world.get("placement_ghost") != null)


# Actual camera projection and ground ray, without relying on the OS mouse
# position or screenshot pixel coordinates. A narrow orthographic camera
# aimed at the center of a valid tile makes the snapped result stable.
func _point_at(world: Node, at: Vector3) -> void:
	var camera := world.get("camera") as Camera3D
	assert(is_instance_valid(camera))
	camera.make_current()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.05
	camera.global_transform = Transform3D(Basis(Vector3.RIGHT, -PI / 2.0), at + Vector3.UP * 8.0)
	camera.force_update_transform()


func _click(world: Node, at: Vector3) -> void:
	_point_at(world, at)
	# The same entry called by primary_action; no direct job authorization.
	world.call("_try_place_object")


func _buffer(demo: Demo, site: ConstructionSite, amount: int) -> InventoryComponent:
	assert(demo.is_enrolled_site(site) and not site.is_processing())
	var result := demo.registry.inventory_for_site(site)
	assert(result != null and result.max_capacity == amount and result.get_total_amount() == 0)
	return result


func _until(demo: Demo, action: StringName, limit: int = 600) -> bool:
	for i: int in range(limit):
		demo._process(0.1)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _launch(demo: Demo, site: ConstructionSite, amount: int, stock: int) -> void:
	var forecast := demo.dispatch.inspect_next()
	assert(forecast.get("site") == site and forecast.get("amount") == amount)
	assert(demo.stock.get_reserved_amount(INGOT) == 0)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"launched")
	assert(demo.last_tick["selection"]["site"] == site)
	assert(demo.supplier.reservation_count() == 1)
	assert(demo.stock.get_reserved_amount(INGOT) == amount)
	assert(demo.stock.get_amount(INGOT) == stock and demo.drone.cargo_amount() == 0)


func _rearm(demo: Demo, expected: int) -> void:
	assert(_until(demo, &"rearmed"))
	assert(demo.drone.completed_rearms() == expected and not demo.dispatch.has_lifecycle_assignment())
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	assert(is_equal_approx(demo.drone.battery_units(), 40.0))
	assert(demo.drone.global_position.is_equal_approx(demo.hub.global_position + Vector3.UP * 2.0))
	assert(demo.drone.cargo_amount() == 0)
	assert(demo.supplier.reservation_count() == 0 and demo.returns.reservation_count() == 0)
	assert(demo.escrow.held_count() == 0 and demo.scheduler.get_active_count() == 0)


func _place(demo: Demo, definition: BuildingDefinition, at: Vector3, planned: bool = false) -> ConstructionSite:
	var world := demo.world
	world.set("blueprint_mode_active", planned)
	_select(world, definition)
	_click(world, at)
	var site := _at(demo.get_parent() as Node3D, at)
	if not is_instance_valid(site):
		push_error("Stage B placement refused at %s; preview_valid=%s" % [at, world.get("placement_is_valid")])
		return null
	assert(site.job != null and site.target_definition == definition, "Wrong site at %s" % at)
	assert(site.job.state == (ConstructionJob.State.PLANNED if planned else ConstructionJob.State.QUEUED))
	assert(site.job.priority == ConstructionJob.Priority.NORMAL)
	assert(is_equal_approx(site.job.get_remaining_seconds(), definition.construction_seconds))
	if not planned:
		assert(demo.is_enrolled_site(site) and not site.is_processing())
		assert(site.job.get_wait_reasons().size() == 3 and site.job.get_progress() == 0.0)
	return site


func _collect(demo: Demo, buffer: InventoryComponent, amount: int, initial_stock: int) -> void:
	assert(_until(demo, &"collected"))
	assert(demo.drone.get_flight_state() == Flight.CARGO_HELD)
	assert(demo.drone.cargo_amount() == amount and demo.stock.get_amount(INGOT) == initial_stock - amount)
	assert(demo.drone.global_position.is_equal_approx(demo.dock.global_position))
	assert(buffer.get_total_amount() == 0 and demo.escrow.held_count() == 0)
	assert(demo.drone.battery_units() < 40.0)


func _deliver(demo: Demo, site: ConstructionSite, buffer: InventoryComponent, amount: int) -> void:
	assert(_until(demo, &"unloaded"))
	assert(demo.drone.global_position.is_equal_approx(site.global_position + Vector3.UP * 2.0))
	assert(demo.drone.cargo_amount() == 0 and buffer.get_amount(INGOT) == amount)
	assert(demo.escrow.held_count() == 0 and site.job.get_progress() == 0.0)


func _begin_work(demo: Demo, site: ConstructionSite, buffer: InventoryComponent) -> void:
	assert(_until(demo, &"admitted") and _until(demo, &"construction"))
	assert(demo.escrow.held_count() == 1 and buffer.get_total_amount() == 0)
	assert(demo.scheduler.get_active_sites() == [site])
	assert(demo.power.get_allocated_units(site) == 7 and site.job.get_progress() > 0.0)
	assert(not site.is_processing())


func _finish(demo: Demo, job: ConstructionJob, built: Array[Node3D], prior_count: int) -> void:
	# No activation before the canonical remaining time reaches zero.
	for i: int in range(300):
		if job.get_remaining_seconds() <= 0.11:
			break
		demo._process(0.1)
		assert(demo.last_tick["action"] == &"construction")
		assert(built.size() == prior_count and job.state == ConstructionJob.State.CONSTRUCTING)
	assert(job.get_remaining_seconds() > 0.0 and job.get_remaining_seconds() <= 0.11)
	assert(built.size() == prior_count)
	for i: int in range(3):
		if job.state == ConstructionJob.State.COMPLETE:
			break
		demo._process(0.1)
	assert(job.state == ConstructionJob.State.COMPLETE and job.get_progress() == 1.0)
	assert(demo.escrow.held_count() == 0 and built.size() == prior_count + 1)


func _watch(site: ConstructionSite, built: Array[Node3D]) -> void:
	site.building_completed.connect(func(building: Node3D) -> void: built.append(building))


func _check_built(building: Node3D, sandbox: Node3D, definition: BuildingDefinition, at: Vector3) -> void:
	assert(building.get_parent() == sandbox and building.global_position.is_equal_approx(at))
	assert(building.scene_file_path == definition.building_scene.resource_path)
	assert(building.get_node("BuildingRuntime").building_definition == definition)


func _locked(demo: Demo, site: ConstructionSite, buffer: InventoryComponent) -> void:
	# Claims remain attached to the original entry, not available for new sites.
	for entry: Dictionary in demo._site_entries:
		if (entry["site"] as WeakRef).get_ref() == site and entry["job"] == site.job:
			var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
			var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
			assert(demo.registry.has_locked_pair(staging, port))
			assert(buffer != null and staging != null and port != null)
			return
	assert(false, "Missing protected original staging entry")


func _checks() -> void:
	var sandbox := Direct.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo._direct_build_enabled())
	demo.set_process(false)
	demo.world.set_process(false)
	var world := demo.world
	var original_drone := demo.drone
	var initial_storage_count: int = _completed_count(STORAGE)
	var initial_press_count: int = _completed_count(PRESS)
	var built: Array[Node3D] = []
	var press := _place(demo, PRESS, PRESS_POS)
	if not is_instance_valid(press):
		sandbox.free()
		return
	var storage := _place(demo, STORAGE, STORAGE_POS)
	if not is_instance_valid(storage):
		sandbox.free()
		return
	var high := _place(demo, STORAGE, HIGH_POS, true)
	if not is_instance_valid(high):
		sandbox.free()
		return
	var press_job := press.job
	var storage_job := storage.job
	var high_job := high.job
	_watch(press, built)
	_watch(storage, built)
	_watch(high, built)
	assert(demo.network.covers_site(press) and demo.network.covers_site(storage) and demo.network.covers_site(high))
	var a := _buffer(demo, press, 5)
	var b := _buffer(demo, storage, 3)
	assert(a != b and demo.registry.inventory_for_site(high) == null)
	assert(high_job.set_priority(ConstructionJob.Priority.HIGH))
	assert(high_job.state == ConstructionJob.State.PLANNED)
	assert(demo.queue.get_waiting_sites() == [press, storage])
	assert(demo.registry.claim_count() == 2 and demo.stock.get_amount(INGOT) == 15)
	assert(_completed_count(STORAGE) == initial_storage_count and _completed_count(PRESS) == initial_press_count)
	_launch(demo, press, 5, 15)
	print("PASS A: Direct Press and Storage queue Normal FIFO without E; High Blueprint remains planned")

	_collect(demo, a, 5, 15)
	assert(b.get_total_amount() == 0 and press_job.get_progress() == 0.0 and built.is_empty())
	print("PASS B: Physical five-ingot pickup at source with finite battery; no remote material transfer")

	_deliver(demo, press, a, 5)
	assert(b.get_total_amount() == 0 and built.is_empty() and demo.stock.get_amount(INGOT) == 10)
	print("PASS C: Physical delivery to original Press, no premature work or activation")

	assert(demo.hub.set_generator_enabled(false))
	assert(_until(demo, &"admitted"))
	assert(a.get_total_amount() == 0 and demo.escrow.held_count() == 1)
	demo._process(10.0)
	assert(press_job.get_progress() == 0.0 and demo.scheduler.get_active_count() == 0 and built.is_empty())
	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"construction"))
	assert(demo.scheduler.get_active_sites() == [press] and demo.power.get_allocated_units(press) == 7)
	var before: float = press_job.get_progress()
	demo._process(10.0)
	assert(is_equal_approx(press_job.get_progress() - before, 0.1 / 18.0) and not press.is_processing())
	print("PASS D: Exact escrow, finite power and single worker; long frame cannot double-step the job")

	# Authorize the previously planned High job while Direct Press is active.
	assert(world.call("_authorize_all_blueprint_sites") == 1)
	var h := _buffer(demo, high, 3)
	assert(h != a and h != b and demo.queue.get_waiting_sites() == [high, storage])
	before = press_job.get_progress()
	assert(demo.hub.set_generator_enabled(false))
	demo._process(0.1)
	assert(press_job.state == ConstructionJob.State.PAUSED and press_job.get_progress() == before)
	assert(demo.dispatch._assigned_job == press_job and high_job.get_progress() == 0.0 and storage_job.get_progress() == 0.0)
	assert(demo.hub.set_generator_enabled(true))
	demo._process(0.1)
	assert(press_job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(press_job.get_progress() - before, 0.1 / 18.0))
	print("PASS E: Explicit High Blueprint joins shared queue without preempting paused Direct Press")

	_finish(demo, press_job, built, 0)
	_check_built(built[0], sandbox, PRESS, PRESS_POS)
	var press_building := built[0]
	var input := press_building.get_node("InputInventory") as InventoryComponent
	var output := press_building.get_node("OutputInventory") as InventoryComponent
	var producer := press_building.get_node("ProducerComponent") as ProducerComponent
	assert(input != a and output != a and input != output)
	assert(producer.is_processing() and producer.recipe == RECIPE)
	assert(producer.input_inventory == input and producer.output_inventory == output)
	assert((press_building.get_node("InputPort") as ItemPortComponent).inventory == input)
	assert((press_building.get_node("OutputPort") as ItemPortComponent).inventory == output)
	assert(input.get_total_amount() == 0 and output.get_total_amount() == 0)
	assert(not producer.try_complete_recipe_cycle())
	assert(a.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 10)
	assert(_completed_count(PRESS) == initial_press_count + 1)
	print("PASS F: Direct Press activates exactly once after 18 seconds; live production starts empty")

	for i: int in range(300):
		if demo.drone.get_flight_state() == Flight.DOCKED:
			break
		demo._process(0.1)
	assert(demo.drone.get_flight_state() == Flight.DOCKED and demo.dispatch.has_lifecycle_assignment())
	var dock_energy: float = demo.drone.battery_units()
	assert(dock_energy < 40.0)
	assert(demo.hub.set_generator_enabled(false))
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"dock_wait" and demo.drone.battery_units() == dock_energy)
	assert(demo.hub.set_generator_enabled(true))
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"charged")
	assert(is_equal_approx(demo.drone.battery_units() - dock_energy, 0.4))
	_rearm(demo, 1)
	assert(demo.drone == original_drone)
	print("PASS G: Same drone physically returns, charges only with finite power and rearms")

	_launch(demo, high, 3, 10)
	_collect(demo, h, 3, 10)
	_deliver(demo, high, h, 3)
	_begin_work(demo, high, h)
	assert(storage_job.get_progress() == 0.0 and b.get_total_amount() == 0)
	_finish(demo, high_job, built, 1)
	_check_built(built[1], sandbox, STORAGE, HIGH_POS)
	assert((built[1].get_node("InventoryComponent") as InventoryComponent).get_total_amount() == 0)
	_rearm(demo, 2)
	assert(demo.drone == original_drone and demo.stock.get_amount(INGOT) == 7)
	print("PASS H: Explicit High Blueprint Storage completes before queued Normal Direct Storage")

	_launch(demo, storage, 3, 7)
	_collect(demo, b, 3, 7)
	_deliver(demo, storage, b, 3)
	_begin_work(demo, storage, b)
	before = storage_job.get_progress()
	demo._process(10.0)
	assert(is_equal_approx(storage_job.get_progress() - before, 0.1 / 10.0))
	_finish(demo, storage_job, built, 2)
	_check_built(built[2], sandbox, STORAGE, STORAGE_POS)
	assert((built[2].get_node("InventoryComponent") as InventoryComponent).get_total_amount() == 0)
	_rearm(demo, 3)
	assert(demo.drone == original_drone and demo.stock.get_amount(INGOT) == 4)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0 and h.get_total_amount() == 0)
	assert(_completed_count(STORAGE) == initial_storage_count + 2 and _completed_count(PRESS) == initial_press_count + 1)
	print("PASS I: Direct Storage physically completes in 10 seconds; eleven ingots spent across three jobs")

	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var waiting := _place(demo, PRESS, WAIT_POS)
	if not is_instance_valid(waiting):
		sandbox.free()
		return
	assert(demo.network.covers_site(waiting))
	var w := _buffer(demo, waiting, 5)
	_watch(waiting, built)
	for i: int in range(20):
		demo._process(0.1)
		assert(demo.last_tick["action"] == &"waiting")
	assert(waiting.job.state == ConstructionJob.State.QUEUED and waiting.job.get_progress() == 0.0)
	assert(waiting.job.get_wait_reasons().has(&"materials") and demo.queue.get_waiting_sites() == [waiting])
	assert(w.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 4 and demo.drone.cargo_amount() == 0)
	assert(demo.supplier.reservation_count() == 0 and demo.escrow.held_count() == 0 and built.size() == 3)
	assert(5 + 3 + 3 + demo.stock.get_amount(INGOT) == 15)
	print("PASS J: Unaffordable Direct Press waits without partial pickup or fabricated progress; exact conservation")
	world.call("_destroy_placement_ghost")
	sandbox.free()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	# Fresh fixture for all four Direct cancellation phases. No stock reset,
	# injection or unlock inside an active scenario.
	sandbox = Direct.instantiate() as Node3D
	demo = sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services())
	demo.set_process(false)
	demo.world.set_process(false)
	world = demo.world
	original_drone = demo.drone
	var cancelled_builds: Array[Node3D] = []
	assert(demo.stock.get_amount(INGOT) == 15)
	var early := _place(demo, PRESS, CANCEL_POS)
	if not is_instance_valid(early):
		sandbox.free()
		return
	_watch(early, cancelled_builds)
	var early_buffer := _buffer(demo, early, 5)
	_launch(demo, early, 5, 15)
	var early_job := early.job
	assert(world.call("_cancel_blueprint_site", early))
	assert(early_job.state == ConstructionJob.State.CANCELLED and demo.supplier.reservation_count() == 0)
	_locked(demo, early, early_buffer)
	_rearm(demo, 1)
	assert(demo.stock.get_amount(INGOT) == 15 and early_buffer.get_total_amount() == 0 and cancelled_builds.is_empty())
	print("PASS K: Direct cancellation before pickup releases claim without debit")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	var loaded := _place(demo, PRESS, CANCEL_POS)
	if not is_instance_valid(loaded):
		sandbox.free()
		return
	_watch(loaded, cancelled_builds)
	var loaded_buffer := _buffer(demo, loaded, 5)
	_launch(demo, loaded, 5, 15)
	_collect(demo, loaded_buffer, 5, 15)
	var loaded_job := loaded.job
	assert(world.call("_cancel_blueprint_site", loaded))
	assert(loaded_job.state == ConstructionJob.State.CANCELLED)
	demo.dock.allow_returns = false
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"recovery_wait" and demo.returns.reservation_count() == 0)
	assert(demo.drone.cargo_amount() == 5 and demo.stock.get_amount(INGOT) == 10)
	demo.dock.allow_returns = true
	demo._process(0.1)
	assert(demo.returns.reservation_count() == 1 and demo.drone.cargo_amount() == 5)
	_rearm(demo, 2)
	assert(demo.stock.get_amount(INGOT) == 15 and loaded_buffer.get_total_amount() == 0 and cancelled_builds.is_empty())
	print("PASS L: Loaded Direct cancellation waits for dock and physically returns five ingots")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	var delivered := _place(demo, PRESS, CANCEL_POS)
	if not is_instance_valid(delivered):
		sandbox.free()
		return
	_watch(delivered, cancelled_builds)
	var delivered_buffer := _buffer(demo, delivered, 5)
	_launch(demo, delivered, 5, 15)
	_collect(demo, delivered_buffer, 5, 15)
	_deliver(demo, delivered, delivered_buffer, 5)
	var delivered_job := delivered.job
	assert(world.call("_cancel_blueprint_site", delivered))
	assert(delivered_job.state == ConstructionJob.State.CANCELLED)
	_locked(demo, delivered, delivered_buffer)
	assert(_until(demo, &"cancelled_return"))
	_rearm(demo, 3)
	assert(demo.stock.get_amount(INGOT) == 10 and delivered_buffer.get_amount(INGOT) == 5 and cancelled_builds.is_empty())
	print("PASS M: Direct cancellation after unloading keeps exact original staging locked")
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	var working := _place(demo, PRESS, CANCEL_POS)
	if not is_instance_valid(working):
		sandbox.free()
		return
	_watch(working, cancelled_builds)
	var working_buffer := _buffer(demo, working, 5)
	assert(working_buffer != delivered_buffer)
	_launch(demo, working, 5, 10)
	_collect(demo, working_buffer, 5, 10)
	_deliver(demo, working, working_buffer, 5)
	_begin_work(demo, working, working_buffer)
	var working_job := working.job
	assert(world.call("_cancel_blueprint_site", working))
	assert(working_job.state == ConstructionJob.State.CANCELLED)
	assert(working_buffer.get_amount(INGOT) == 5 and demo.escrow.held_count() == 0)
	_locked(demo, working, working_buffer)
	_rearm(demo, 4)
	assert(demo.stock.get_amount(INGOT) == 5 and demo.drone == original_drone)
	assert(delivered_buffer.get_amount(INGOT) == 5 and working_buffer.get_amount(INGOT) == 5)
	assert(early_buffer.get_total_amount() == 0 and loaded_buffer.get_total_amount() == 0)
	assert(demo.stock.get_amount(INGOT) + delivered_buffer.get_amount(INGOT) + working_buffer.get_amount(INGOT) == 15)
	assert(cancelled_builds.is_empty() and demo.registry.claim_count() == 4)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and demo.queue.get_waiting_count() == 0)
	print("PASS N: Direct working cancellation refunds only its locked buffer; four rearms, no building or stock loss")
	world.call("_destroy_placement_ghost")
	sandbox.free()
	print("ALL 14 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE B TESTS PASSED")
