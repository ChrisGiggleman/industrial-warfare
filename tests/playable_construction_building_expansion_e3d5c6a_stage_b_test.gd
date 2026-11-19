extends Node3D

const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Sandbox = preload("res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const AMMO = preload("res://data/items/prototype_ammunition.tres")
const RECIPE = preload("res://data/recipes/prototype_ammunition_press.tres")
const BELT = preload("res://scenes/logistics/conveyor_straight.tscn")
const Flight = PrototypeConstructionWorkerDrone.FlightState
const FIRST_POS := Vector3(2.5, 0, -0.5)
const CANCEL_POS := Vector3(4.5, 0, -3.5)


func _ready() -> void:
	call_deferred("_checks")


func _plan(demo: Demo, at: Vector3) -> ConstructionSite:
	var site := demo.world.call("_create_blueprint_site", PRESS, Transform3D(Basis.IDENTITY, at)) as ConstructionSite
	assert(site != null, "Press placement failed at %s" % at)
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(is_equal_approx(site.job.get_remaining_seconds(), 18.0))
	return site


func _authorize(demo: Demo, site: ConstructionSite) -> InventoryComponent:
	assert(demo.world.call("_authorize_blueprint_site", site))
	assert(demo.is_enrolled_site(site) and not site.is_processing())
	var buffer := demo.registry.inventory_for_site(site)
	assert(buffer != null and buffer.max_capacity == 5 and buffer.get_total_amount() == 0)
	return buffer


func _until(demo: Demo, action: StringName, limit: int = 600) -> bool:
	for i: int in range(limit):
		demo._process(0.1)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _launch(demo: Demo, site: ConstructionSite, initial_stock: int) -> void:
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"launched")
	assert(demo.last_tick["selection"]["site"] == site)
	assert(demo.supplier.reservation_count() == 1)
	assert(demo.stock.get_reserved_amount(INGOT) == 5)
	assert(demo.stock.get_amount(INGOT) == initial_stock and demo.drone.cargo_amount() == 0)


func _collect(demo: Demo, buffer: InventoryComponent, initial_stock: int) -> void:
	assert(_until(demo, &"collected"))
	assert(demo.drone.get_flight_state() == Flight.CARGO_HELD)
	assert(demo.drone.cargo_amount() == 5 and demo.stock.get_amount(INGOT) == initial_stock - 5)
	assert(demo.drone.global_position.is_equal_approx(demo.dock.global_position))
	assert(buffer.get_total_amount() == 0 and demo.escrow.held_count() == 0)
	assert(demo.drone.battery_units() < 40.0)


func _deliver(demo: Demo, site: ConstructionSite, buffer: InventoryComponent) -> void:
	assert(_until(demo, &"unloaded"))
	assert(demo.drone.global_position.is_equal_approx(site.global_position + Vector3.UP * 2.0))
	assert(demo.drone.cargo_amount() == 0 and buffer.get_amount(INGOT) == 5)
	assert(demo.escrow.held_count() == 0 and site.job.get_progress() == 0.0)


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
	# One explicit lifecycle caller; no independent automatic frame driver.
	demo.set_process(false)
	demo.world.set_process(false)
	var site := _plan(demo, FIRST_POS)
	var job := site.job
	var built: Array[Node3D] = []
	site.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	assert(demo.network.covers_site(site))
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and demo.registry.claim_count() == 0)
	assert(job.get_progress() == 0.0 and built.is_empty())
	var buffer := _authorize(demo, site)
	_launch(demo, site, 15)
	print("PASS A: Real Press plan, explicit authorization, 18-second job and exact five-ingot reservation")

	_collect(demo, buffer, 15)
	assert(job.get_progress() == 0.0 and built.is_empty())
	print("PASS B: Physical pickup at dock debits exactly five ingots with finite energy")

	_deliver(demo, site, buffer)
	assert(built.is_empty() and demo.stock.get_amount(INGOT) == 10)
	print("PASS C: Physical hover delivery to original staging; no early construction or activation")

	assert(demo.hub.set_generator_enabled(false))
	assert(_until(demo, &"admitted"))
	assert(buffer.get_total_amount() == 0 and demo.escrow.held_count() == 1)
	demo._process(10.0)
	assert(job.get_progress() == 0.0 and demo.scheduler.get_active_count() == 0)
	assert(built.is_empty())
	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"construction"))
	assert(job.get_progress() > 0.0 and demo.scheduler.get_active_count() == 1)
	assert(demo.power.get_allocated_units(site) == 7)
	var before: float = job.get_progress()
	demo._process(10.0)
	assert(is_equal_approx(job.get_progress() - before, 0.1 / 18.0))
	assert(demo.escrow.held_count() == 1 and buffer.get_total_amount() == 0)
	assert(not site.is_processing())
	print("PASS D: Exact escrow, single worker and finite power gate; one capped construction clock")

	before = job.get_progress()
	assert(demo.hub.set_generator_enabled(false))
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"construction_wait")
	assert(job.state == ConstructionJob.State.PAUSED and job.get_progress() == before)
	assert(demo.hub.set_generator_enabled(true))
	demo._process(0.1)
	assert(job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(job.get_progress() - before, 0.1 / 18.0))
	# Run almost to the measured finish; no completed building before 18 seconds.
	while job.get_remaining_seconds() > 0.11:
		demo._process(0.1)
		assert(demo.last_tick["action"] == &"construction")
		assert(built.is_empty() and job.state == ConstructionJob.State.CONSTRUCTING)
	assert(job.get_remaining_seconds() > 0.0)
	assert(built.is_empty())
	for i: int in range(3):
		if job.state == ConstructionJob.State.COMPLETE:
			break
		demo._process(0.1)
	assert(job.state == ConstructionJob.State.COMPLETE and job.get_progress() == 1.0)
	assert(built.size() == 1 and built[0].get_parent() == sandbox)
	assert(built[0].scene_file_path == PRESS.building_scene.resource_path)
	assert(built[0].global_position.is_equal_approx(FIRST_POS))
	assert(built[0].get_node("BuildingRuntime").building_definition == PRESS)
	assert(demo.escrow.held_count() == 0 and buffer.get_total_amount() == 0)
	assert(demo.stock.get_amount(INGOT) == 10)
	print("PASS E: Pause/resume preserves elapsed work; real Press activated exactly once after 18 seconds")

	var press := built[0]
	var input := press.get_node("InputInventory") as InventoryComponent
	var output := press.get_node("OutputInventory") as InventoryComponent
	var producer := press.get_node("ProducerComponent") as ProducerComponent
	var input_port := press.get_node("InputPort") as ItemPortComponent
	var output_port := press.get_node("OutputPort") as ItemPortComponent
	assert(input != output and input != buffer and output != buffer)
	assert(producer.is_processing() and producer.recipe == RECIPE)
	assert(producer.input_inventory == input and producer.output_inventory == output)
	assert(input_port.inventory == input and output_port.inventory == output)
	assert(input_port.producer_component == producer and output_port.producer_component == producer)
	assert(input.get_total_amount() == 0 and output.get_total_amount() == 0)
	producer.set_process(false)
	producer._process(2.1)
	assert(input.get_total_amount() == 0 and output.get_total_amount() == 0)
	assert(not producer.try_complete_recipe_cycle())
	print("PASS F: Completed machine has real separate inventories and ports; construction material never becomes production stock")

	# Separate, explicitly counted one-ingot production fixture. It is loaded
	# onto a real belt using the existing inventory transfer API, not injected
	# into the press or construction buffer. Existing manual conveyor placement
	# remains a compatibility fixture; automatic conveyor builds are later.
	var supply := InventoryComponent.new()
	sandbox.add_child(supply)
	supply.max_capacity = 1
	assert(supply.add_item(INGOT, 1) == 1)
	var belt := BELT.instantiate() as ConveyorSegment
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	timer.set_process(false)
	timer.travel_interval = 1.0
	var preview := ConveyorBuildingSnap.get_preview_transform(input_port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(input_port))
	assert(transport.try_receive_from_inventory(supply, INGOT))
	assert(supply.get_total_amount() == 0 and input.get_total_amount() == 0)
	assert(not timer.advance_transport(0.4))
	assert(timer.advance_transport(0.61))
	assert(input.get_amount(INGOT) == 1 and transport.get_held_item() == null)
	producer._process(1.0)
	assert(output.get_total_amount() == 0 and input.get_amount(INGOT) == 1)
	producer._process(1.01)
	assert(output.get_amount(AMMO) == 4 and input.get_total_amount() == 0)
	producer._process(2.1)
	assert(output.get_amount(AMMO) == 4 and demo.stock.get_amount(INGOT) == 10)
	print("PASS G: Separate counted ingredient delivered by connected belt; one timed 1-to-4 ammo recipe, no free output")

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
	print("PASS H: Physical home return, metered generator-gated recharge and reusable drone")
	await get_tree().process_frame

	var early := _plan(demo, CANCEL_POS)
	var early_buffer := _authorize(demo, early)
	_launch(demo, early, 10)
	var early_job := early.job
	assert(demo.world.call("_cancel_blueprint_site", early))
	assert(early_job.state == ConstructionJob.State.CANCELLED and demo.supplier.reservation_count() == 0)
	_rearm(demo, 2)
	assert(demo.stock.get_amount(INGOT) == 10 and early_buffer.get_total_amount() == 0)
	print("PASS I: Cancellation before pickup releases reservation without debiting stock")
	await get_tree().process_frame
	await get_tree().process_frame

	var loaded := _plan(demo, CANCEL_POS)
	var loaded_buffer := _authorize(demo, loaded)
	_launch(demo, loaded, 10)
	_collect(demo, loaded_buffer, 10)
	assert(demo.world.call("_cancel_blueprint_site", loaded))
	demo.dock.allow_returns = false
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"recovery_wait" and demo.returns.reservation_count() == 0)
	assert(demo.drone.cargo_amount() == 5 and demo.stock.get_amount(INGOT) == 5)
	demo.dock.allow_returns = true
	demo._process(0.1)
	assert(demo.returns.reservation_count() == 1 and demo.drone.cargo_amount() == 5)
	_rearm(demo, 3)
	assert(demo.stock.get_amount(INGOT) == 10 and loaded_buffer.get_total_amount() == 0)
	print("PASS J: Loaded cancellation waits for return dock and physically deposits five ingots")
	await get_tree().process_frame
	await get_tree().process_frame

	var delivered := _plan(demo, CANCEL_POS)
	var delivered_buffer := _authorize(demo, delivered)
	_launch(demo, delivered, 10)
	_collect(demo, delivered_buffer, 10)
	_deliver(demo, delivered, delivered_buffer)
	assert(demo.world.call("_cancel_blueprint_site", delivered))
	assert(_until(demo, &"cancelled_return"))
	_rearm(demo, 4)
	assert(demo.stock.get_amount(INGOT) == 5 and delivered_buffer.get_amount(INGOT) == 5)
	print("PASS K: Cancellation after unloading preserves five ingots in original locked staging")
	await get_tree().process_frame
	await get_tree().process_frame

	var working := _plan(demo, CANCEL_POS)
	var working_buffer := _authorize(demo, working)
	_launch(demo, working, 5)
	_collect(demo, working_buffer, 5)
	_deliver(demo, working, working_buffer)
	assert(_until(demo, &"admitted") and _until(demo, &"construction"))
	assert(working.job.get_progress() > 0.0 and demo.escrow.held_count() == 1)
	assert(demo.world.call("_cancel_blueprint_site", working))
	assert(working_buffer.get_amount(INGOT) == 5 and demo.escrow.held_count() == 0)
	_rearm(demo, 5)
	assert(demo.stock.get_amount(INGOT) == 0 and built.size() == 1)
	assert(demo.stock.get_amount(INGOT) + delivered_buffer.get_amount(INGOT) + working_buffer.get_amount(INGOT) + built.size() * 5 == 15)
	assert(buffer.get_total_amount() == 0 and early_buffer.get_total_amount() == 0 and loaded_buffer.get_total_amount() == 0)
	assert(output.get_amount(AMMO) == 4)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting")
	print("PASS L: Working cancellation refunds exact escrow; five rearmed assignments and all 15 construction ingots accounted for")
	sandbox.free()
	print("ALL 12 PLAYABLE CONSTRUCTION BUILDING EXPANSION E3D5C6A STAGE B TESTS PASSED")
