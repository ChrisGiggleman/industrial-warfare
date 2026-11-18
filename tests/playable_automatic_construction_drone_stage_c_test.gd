extends Node3D

const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Sandbox = preload("res://scenes/core/playable_automatic_construction_drone_stage_c.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState


func _ready() -> void:
	call_deferred("_checks")


func _plan(demo: Demo, at: Vector3, priority: int = ConstructionJob.Priority.NORMAL) -> ConstructionSite:
	var site := demo.world.call("_create_blueprint_site", STORAGE, Transform3D(Basis.IDENTITY, at)) as ConstructionSite
	assert(site != null, "Placement failed at %s" % at)
	if site.job.priority != priority:
		assert(site.job.set_priority(priority))
	return site


func _authorize(demo: Demo, site: ConstructionSite) -> InventoryComponent:
	assert(demo.world.call("_authorize_blueprint_site", site))
	assert(demo.is_enrolled_site(site) and not site.is_processing())
	var buffer := demo.registry.inventory_for_site(site)
	assert(buffer != null and buffer.get_total_amount() == 0)
	return buffer


func _until(demo: Demo, action: StringName, limit: int = 500) -> bool:
	for i: int in range(limit):
		demo._process(0.1)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _launch(demo: Demo, site: ConstructionSite) -> void:
	demo._process(0.1)
	assert(demo.last_tick.get("action") == &"launched")
	assert(demo.last_tick["selection"]["site"] == site)
	assert(demo.supplier.reservation_count() == 1 and demo.drone.cargo_amount() == 0)


func _deliver(demo: Demo) -> void:
	assert(_until(demo, &"collected"))
	assert(demo.drone.cargo_amount() == 3)
	assert(_until(demo, &"unloaded"))
	assert(demo.drone.cargo_amount() == 0)


func _rearm(demo: Demo, expected: int) -> void:
	assert(_until(demo, &"rearmed"))
	assert(demo.drone.completed_rearms() == expected)
	assert(not demo.dispatch.has_lifecycle_assignment())
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	assert(is_equal_approx(demo.drone.battery_units(), 40.0))
	assert(demo.drone.global_position.is_equal_approx(demo.hub.global_position + Vector3.UP * 2.0))
	assert(demo.supplier.reservation_count() == 0 and demo.returns.reservation_count() == 0)
	assert(demo.escrow.held_count() == 0 and demo.scheduler.get_active_count() == 0)


func _finish(demo: Demo, job: ConstructionJob) -> void:
	for i: int in range(200):
		if job.state == ConstructionJob.State.COMPLETE:
			break
		demo._process(0.1)
	assert(job.state == ConstructionJob.State.COMPLETE)


func _checks() -> void:
	var sandbox := Sandbox.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo.enable_playable_feedback)
	demo.set_process(false)
	demo.world.set_process(false)
	var planned := _plan(demo, Vector3(-7, 0, 2), ConstructionJob.Priority.HIGH)
	var low := _plan(demo, Vector3(-5, 0, 0), ConstructionJob.Priority.LOW)
	var first := _plan(demo, Demo.GUIDE_A)
	var first_job := first.job
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and demo.registry.claim_count() == 0)
	assert(planned.job.state == ConstructionJob.State.PLANNED)
	assert(demo._status_label.text.contains("Battery 40.0 / 40.0"))
	assert(demo._status_label.text.contains("Cargo 0 / 5"))
	assert(demo._storage_tag.text.contains("15 INGOTS"))
	print("PASS A: Live scene HUD and planned High remain read-only and unauthorized")

	var low_buffer := _authorize(demo, low)
	var first_buffer := _authorize(demo, first)
	assert(demo.network.covers_site(first))
	_launch(demo, first)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.stock.get_reserved_amount(INGOT) == 3)
	_deliver(demo)
	assert(demo.stock.get_amount(INGOT) == 12 and first_buffer.get_amount(INGOT) == 3)
	assert(_until(demo, &"admitted"))
	assert(_until(demo, &"construction"))
	assert(first_job.get_progress() > 0.0 and demo.scheduler.get_active_count() == 1)
	print("PASS B: Normal before older Low, actual reserved pickup/delivery and exclusive work slot")

	var second := _plan(demo, Demo.GUIDE_B, ConstructionJob.Priority.HIGH)
	var third := _plan(demo, Vector3(4, 0, 1), ConstructionJob.Priority.HIGH)
	var second_job := second.job
	var second_buffer := _authorize(demo, second)
	var third_buffer := _authorize(demo, third)
	assert(demo.network.covers_site(second))
	assert(demo.queue.get_waiting_sites()[0] == second)
	var before: float = first_job.get_progress()
	demo._toggle_stage_c_generator()
	assert(not demo.hub.generator_enabled)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"construction_wait")
	assert(first_job.state == ConstructionJob.State.PAUSED and first_job.get_progress() == before)
	assert(demo.dispatch._assigned_job == first_job and second_job.get_progress() == 0.0)
	demo._toggle_stage_c_generator()
	assert(demo.hub.generator_enabled)
	demo._process(0.1)
	assert(first_job.state == ConstructionJob.State.CONSTRUCTING and is_equal_approx(first_job.get_progress() - before, 0.01))
	assert(demo.scheduler.get_active_sites().has(first))
	assert(second_buffer.get_total_amount() == 0 and third_buffer.get_total_amount() == 0)
	print("PASS C: Late High does not preempt; real Hub power pause/resume advances only original job")

	var built: Array[Node3D] = []
	first.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	_finish(demo, first_job)
	assert(built.size() == 1 and built[0].get_parent() == sandbox)
	assert(built[0].scene_file_path == STORAGE.building_scene.resource_path)
	assert(built[0].global_position.is_equal_approx(Demo.GUIDE_A))
	assert(built[0].get_node("BuildingRuntime").building_definition == STORAGE)
	assert(demo.escrow.held_count() == 0 and first_buffer.get_total_amount() == 0)
	assert(demo.stock.get_amount(INGOT) == 12)
	print("PASS D: Real completed Storage activated exactly once; three ingots committed")

	for i: int in range(200):
		if demo.drone.get_flight_state() == Flight.DOCKED:
			break
		demo._process(0.1)
	assert(demo.drone.get_flight_state() == Flight.DOCKED and demo.dispatch.has_lifecycle_assignment())
	assert(demo.drone.global_position.is_equal_approx(demo.hub.global_position + Vector3.UP * 2.0))
	var dock_energy: float = demo.drone.battery_units()
	assert(dock_energy < 40.0)
	demo._toggle_stage_c_generator()
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"dock_wait" and demo.drone.battery_units() == dock_energy)
	assert(not demo.drone.charge_at_home(10.0, true))
	demo._toggle_stage_c_generator()
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"charged")
	assert(is_equal_approx(demo.drone.battery_units() - dock_energy, 0.4))
	_rearm(demo, 1)
	print("PASS E: Metered home return, power-gated finite charging, no legacy bypass, separate rearm")

	_launch(demo, second)
	_deliver(demo)
	assert(_until(demo, &"admitted"))
	second.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	_finish(demo, second_job)
	assert(built.size() == 2 and built[1] != built[0])
	assert(built[1].global_position.is_equal_approx(Demo.GUIDE_B))
	assert(second_buffer.get_total_amount() == 0 and demo.stock.get_amount(INGOT) == 9)
	_rearm(demo, 2)
	print("PASS F: High FIFO successor completes with same drone before other High and Low")
	await get_tree().process_frame

	_launch(demo, third)
	demo._process(0.1)
	assert(demo.world.call("_cancel_blueprint_site", third))
	assert(demo.supplier.reservation_count() == 0 and demo.stock.get_amount(INGOT) == 9)
	assert(third_buffer.get_total_amount() == 0 and demo.drone.cargo_amount() == 0)
	_rearm(demo, 3)
	print("PASS G: Player cancellation before pickup releases exact stock claim and returns empty")
	await get_tree().process_frame

	_launch(demo, low)
	assert(_until(demo, &"collected"))
	assert(demo.stock.get_amount(INGOT) == 6 and demo.drone.cargo_amount() == 3)
	assert(demo.world.call("_cancel_blueprint_site", low))
	demo.dock.allow_returns = false
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"recovery_wait" and demo.returns.reservation_count() == 0)
	assert(demo.stock.get_amount(INGOT) == 6 and demo.drone.cargo_amount() == 3)
	demo.dock.allow_returns = true
	demo._process(0.1)
	assert(demo.returns.reservation_count() == 1 and demo.drone.cargo_amount() == 3)
	assert(demo.stock.get_amount(INGOT) == 6)
	_rearm(demo, 4)
	assert(demo.stock.get_amount(INGOT) == 9 and low_buffer.get_total_amount() == 0)
	print("PASS H: Loaded cancellation waits for valid return dock; physical reserved deposit then rearm")
	await get_tree().process_frame

	var lost := _plan(demo, Vector3(-5, 0, 4))
	var lost_buffer := _authorize(demo, lost)
	_launch(demo, lost)
	assert(_until(demo, &"collected"))
	sandbox.remove_child(lost)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"receiver_wait")
	assert(demo.drone.cargo_amount() == 3 and demo.returns.reservation_count() == 0)
	lost.free()
	_rearm(demo, 5)
	assert(demo.stock.get_amount(INGOT) == 9 and lost_buffer.get_total_amount() == 0)
	print("PASS I: Temporary detachment never authorizes recovery; freed original site permits exact physical return")

	var delivered := _plan(demo, Vector3(4, 0, 1))
	var delivered_buffer := _authorize(demo, delivered)
	_launch(demo, delivered)
	_deliver(demo)
	assert(delivered_buffer.get_amount(INGOT) == 3 and demo.escrow.held_count() == 0)
	assert(demo.world.call("_cancel_blueprint_site", delivered))
	assert(_until(demo, &"cancelled_return"))
	_rearm(demo, 6)
	assert(delivered_buffer.get_amount(INGOT) == 3 and demo.stock.get_amount(INGOT) == 6)
	print("PASS J: Cancellation after unloading preserves locked original buffer and returns empty")
	await get_tree().process_frame

	var working := _plan(demo, Vector3(5, 0, -3))
	var working_buffer := _authorize(demo, working)
	assert(demo.network.covers_site(working))
	_launch(demo, working)
	_deliver(demo)
	assert(_until(demo, &"admitted"))
	assert(_until(demo, &"construction"))
	assert(demo.escrow.held_count() == 1 and working.job.get_progress() > 0.0)
	assert(demo.world.call("_cancel_blueprint_site", working))
	assert(working_buffer.get_amount(INGOT) == 3 and demo.escrow.held_count() == 0)
	_rearm(demo, 7)
	print("PASS K: Cancellation while working refunds exact escrow to original persistent staging")
	await get_tree().process_frame

	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and demo.stock.get_amount(INGOT) == 3)
	assert(demo.stock.get_amount(INGOT) + delivered_buffer.get_amount(INGOT) + working_buffer.get_amount(INGOT) + built.size() * 3 == 15)
	assert(first_buffer.get_total_amount() == 0 and second_buffer.get_total_amount() == 0 and low_buffer.get_total_amount() == 0)
	assert(third_buffer.get_total_amount() == 0 and lost_buffer.get_total_amount() == 0)
	assert(demo.registry.claim_count() == 7 and demo.drone.cargo_amount() == 0)
	assert(planned.job.state == ConstructionJob.State.PLANNED and demo.registry.inventory_for_site(planned) == null)
	assert(demo._storage_tag.text.contains("3 INGOTS") and demo._status_label.text.contains("Rearms: 7"))
	print("PASS L: Seven assignments, two completed buildings, 15 ingots accounted for, no auto-authorization")

	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var ordinary := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("AutomaticConstructionSandbox") == null)
	assert(ordinary.get_node_or_null("AutomaticConstructionSandbox") == null)
	assert(not ordinary.get_node("ConstructionDroneLifecycleGate").enable_isolated_bridge)
	main.free()
	ordinary.free()
	var stage_a := (load("res://scenes/core/playable_automatic_construction_drone_sandbox.tscn") as PackedScene).instantiate()
	var stage_b := (load("res://scenes/core/playable_automatic_construction_drone_stage_b.tscn") as PackedScene).instantiate()
	assert(not stage_a.get_node("AutomaticConstructionSandbox").enable_playable_feedback)
	assert(not stage_b.get_node("AutomaticConstructionSandbox").enable_playable_feedback)
	stage_a.free()
	stage_b.free()
	sandbox.free()
	print("PASS M: Ordinary scenes opt out; Stage A/B remain separate feedback-off fixtures")
	print("ALL 13 PLAYABLE AUTOMATIC CONSTRUCTION DRONE STAGE C TESTS PASSED")
