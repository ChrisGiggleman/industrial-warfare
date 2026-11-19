extends Node3D

const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Sandbox = preload("res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState
const PRESS_POS := Vector3(4.5, 0, -3.5)
const HIGH_POS := Vector3(0, 0, -3)
const LOW_POS := Vector3(4, 0, -1)
const WAIT_POS := Vector3(2.5, 0, -0.5)
const LATE_POS := Vector3(-5, 0, 0)


func _ready() -> void:
	call_deferred("_checks")


func _plan(demo: Demo, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var site := demo.world.call("_create_blueprint_site", definition, Transform3D(Basis.IDENTITY, at)) as ConstructionSite
	assert(site != null, "Mixed placement failed at %s" % at)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	return site


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


func _work(demo: Demo, site: ConstructionSite, buffer: InventoryComponent, amount: int, stock: int) -> void:
	assert(_until(demo, &"collected"))
	assert(demo.stock.get_amount(INGOT) == stock - amount and demo.drone.cargo_amount() == amount)
	assert(buffer.get_total_amount() == 0)
	assert(_until(demo, &"unloaded"))
	assert(demo.drone.cargo_amount() == 0 and buffer.get_amount(INGOT) == amount)
	assert(site.job.get_progress() == 0.0 and demo.escrow.held_count() == 0)
	assert(_until(demo, &"admitted"))
	assert(_until(demo, &"construction"))
	assert(demo.escrow.held_count() == 1 and buffer.get_total_amount() == 0)
	assert(demo.scheduler.get_active_sites() == [site])
	assert(demo.power.get_allocated_units(site) == 7)
	assert(site.job.get_progress() > 0.0)


func _finish(demo: Demo, job: ConstructionJob) -> void:
	for i: int in range(300):
		if job.state == ConstructionJob.State.COMPLETE:
			break
		demo._process(0.1)
	assert(job.state == ConstructionJob.State.COMPLETE and job.get_progress() == 1.0)
	assert(demo.escrow.held_count() == 0)


func _rearm(demo: Demo, expected: int) -> void:
	assert(_until(demo, &"rearmed"))
	assert(demo.drone.completed_rearms() == expected and not demo.dispatch.has_lifecycle_assignment())
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	assert(is_equal_approx(demo.drone.battery_units(), 40.0))
	assert(demo.drone.global_position.is_equal_approx(demo.hub.global_position + Vector3.UP * 2.0))
	assert(demo.drone.cargo_amount() == 0)
	assert(demo.supplier.reservation_count() == 0 and demo.returns.reservation_count() == 0)
	assert(demo.escrow.held_count() == 0 and demo.scheduler.get_active_count() == 0)


func _checks() -> void:
	var sandbox := Sandbox.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo._expansion_enabled())
	demo.set_process(false)
	demo.world.set_process(false)
	var world := demo.world
	var original_drone := demo.drone
	var low := _plan(demo, STORAGE, LOW_POS)
	var first := _plan(demo, PRESS, PRESS_POS)
	var second := _plan(demo, STORAGE, HIGH_POS)
	var waiting := _plan(demo, PRESS, WAIT_POS)
	var first_job := first.job
	var second_job := second.job
	var low_job := low.job
	assert(demo.network.covers_site(first) and demo.network.covers_site(second) and demo.network.covers_site(low))
	assert(demo.network.covers_site(waiting))
	assert(is_equal_approx(first_job.get_remaining_seconds(), 18.0))
	assert(is_equal_approx(second_job.get_remaining_seconds(), 10.0))
	assert(is_equal_approx(low_job.get_remaining_seconds(), 10.0))
	assert(low_job.set_priority(ConstructionJob.Priority.LOW))
	assert(waiting.job.set_priority(ConstructionJob.Priority.HIGH))
	world.set("placement_mode_active", true)
	world.set("blueprint_mode_active", true)
	world.set("_blueprint_area_selection_mode", true)
	var selected: Array[ConstructionSite] = [first, second]
	world.set("_area_selected_sites", selected)
	assert(world.call("_set_selected_blueprint_priority", ConstructionJob.Priority.HIGH) == 2)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and demo.registry.claim_count() == 0)
	assert(demo.queue.get_waiting_count() == 0 and demo.stock.get_amount(INGOT) == 15)
	assert(first_job.state == ConstructionJob.State.PLANNED and second_job.state == ConstructionJob.State.PLANNED)
	print("PASS A: Mixed plans and High priority selection do not authorize either building type")

	assert(world.call("_authorize_blueprint_site", low))
	assert(world.call("_authorize_selected_blueprint_sites") == 2)
	var a := _buffer(demo, first, 5)
	var b := _buffer(demo, second, 3)
	var c := _buffer(demo, low, 3)
	assert(a != b and a != c and b != c)
	assert(demo.queue.get_waiting_sites() == [first, second, low])
	assert(waiting.job.state == ConstructionJob.State.PLANNED and demo.registry.inventory_for_site(waiting) == null)
	assert(demo.registry.claim_count() == 3)
	print("PASS B: Mixed selected authorization preserves High FIFO over older Low; exact independent staging")

	var built: Array[Node3D] = []
	first.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	second.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	low.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	_launch(demo, first, 5, 15)
	_work(demo, first, a, 5, 15)
	assert(b.get_total_amount() == 0 and c.get_total_amount() == 0)
	assert(second_job.get_progress() == 0.0 and low_job.get_progress() == 0.0)
	assert(built.is_empty() and demo.dispatch._assigned_job == first_job)
	print("PASS C: Press receives exactly five ingots; competing Storage jobs make no progress")

	var before: float = first_job.get_progress()
	assert(demo.hub.set_generator_enabled(false))
	demo._process(0.1)
	assert(first_job.state == ConstructionJob.State.PAUSED and first_job.get_progress() == before)
	assert(demo.dispatch._assigned_job == first_job and second_job.get_progress() == 0.0)
	assert(demo.hub.set_generator_enabled(true))
	demo._process(0.1)
	assert(first_job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(first_job.get_progress() - before, 0.1 / 18.0))
	print("PASS D: Mixed queue cannot replace paused Press or advance another job")

	_finish(demo, first_job)
	assert(built.size() == 1 and built[0].global_position.is_equal_approx(PRESS_POS))
	assert(built[0].scene_file_path == PRESS.building_scene.resource_path)
	assert(built[0].get_node("BuildingRuntime").building_definition == PRESS)
	assert((built[0].get_node("InputInventory") as InventoryComponent).get_total_amount() == 0)
	assert((built[0].get_node("OutputInventory") as InventoryComponent).get_total_amount() == 0)
	assert(a.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 10)
	_rearm(demo, 1)
	assert(demo.drone == original_drone)
	print("PASS E: Press activates first, commits five ingots and same drone fully recharges")

	_launch(demo, second, 3, 10)
	_work(demo, second, b, 3, 10)
	assert(low_job.get_progress() == 0.0 and c.get_total_amount() == 0)
	_finish(demo, second_job)
	assert(built.size() == 2 and built[1].global_position.is_equal_approx(HIGH_POS))
	assert(built[1].scene_file_path == STORAGE.building_scene.resource_path)
	assert(built[1].get_node("BuildingRuntime").building_definition == STORAGE)
	assert((built[1].get_node("InventoryComponent") as InventoryComponent).get_total_amount() == 0)
	assert(b.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 7)
	_rearm(demo, 2)
	assert(demo.drone == original_drone)
	print("PASS F: Next High Storage uses three ingots, not previous five-unit Press load")

	_launch(demo, low, 3, 7)
	_work(demo, low, c, 3, 7)
	assert(demo.stock.get_amount(INGOT) == 4)
	# Late High Press (unaffordable) and Storage (affordable) enter while
	# the Low Storage is active. Neither may preempt its worker or escrow.
	assert(world.call("_authorize_blueprint_site", waiting))
	var wait_buffer := _buffer(demo, waiting, 5)
	var late := _plan(demo, STORAGE, LATE_POS)
	assert(late.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(world.call("_authorize_blueprint_site", late))
	var late_buffer := _buffer(demo, late, 3)
	assert(demo.queue.get_waiting_sites() == [waiting, late])
	before = low_job.get_progress()
	demo._process(0.1)
	assert(demo.dispatch._assigned_job == low_job and low_job.get_progress() > before)
	assert(waiting.job.get_progress() == 0.0 and late.job.get_progress() == 0.0)
	assert(wait_buffer.get_total_amount() == 0 and late_buffer.get_total_amount() == 0)
	print("PASS G: Late eligible High Storage and unaffordable High Press cannot preempt active Low")

	_finish(demo, low_job)
	assert(built.size() == 3 and built[2].global_position.is_equal_approx(LOW_POS))
	assert(built[2].scene_file_path == STORAGE.building_scene.resource_path)
	assert(built[2].get_node("BuildingRuntime").building_definition == STORAGE)
	assert((built[2].get_node("InventoryComponent") as InventoryComponent).get_total_amount() == 0)
	_rearm(demo, 3)
	assert(demo.drone == original_drone and demo.stock.get_amount(INGOT) == 4)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0 and c.get_total_amount() == 0)
	print("PASS H: Three mixed buildings completed in intended order; eleven ingots committed, four remain")

	var forecast := demo.dispatch.inspect_next()
	assert(forecast.get("site") == late and forecast.get("amount") == 3)
	var skipped: Array = forecast["skipped"]
	assert(skipped.size() == 1 and skipped[0]["site_id"] == waiting.get_instance_id())
	assert(skipped[0]["reason"] == &"stock_dock_or_route_energy")
	assert(demo.stock.get_reserved_amount(INGOT) == 0)
	_launch(demo, late, 3, 4)
	assert(waiting.job.state == ConstructionJob.State.QUEUED)
	assert(wait_buffer.get_total_amount() == 0)
	print("PASS I: Insufficient five-ingot order is skipped for an affordable three-ingot order")

	var late_job := late.job
	assert(world.call("_cancel_blueprint_site", late))
	assert(late_job.state == ConstructionJob.State.CANCELLED and demo.supplier.reservation_count() == 0)
	_rearm(demo, 4)
	assert(demo.stock.get_amount(INGOT) == 4 and late_buffer.get_total_amount() == 0)
	assert(demo.drone == original_drone)
	print("PASS J: Cancelled mixed successor restores reservation and reuses original drone without stock debit")

	for i: int in range(20):
		demo._process(0.1)
		assert(demo.last_tick["action"] == &"waiting")
	assert(demo.queue.get_waiting_sites() == [waiting])
	assert(waiting.job.state == ConstructionJob.State.QUEUED and waiting.job.get_progress() == 0.0)
	assert(waiting.job.get_wait_reasons().has(&"materials"))
	assert(wait_buffer.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 4)
	assert(demo.registry.claim_count() == 5 and demo.drone.cargo_amount() == 0)
	assert(demo.supplier.reservation_count() == 0 and demo.escrow.held_count() == 0)
	assert(built.size() == 3 and 5 + 3 + 3 + demo.stock.get_amount(INGOT) == 15)
	print("PASS K: Unaffordable Press waits without partial pickup, work or fabricated resources; all stock conserved")
	sandbox.free()
	print("ALL 11 PLAYABLE CONSTRUCTION BUILDING EXPANSION E3D5C6A STAGE C TESTS PASSED")
