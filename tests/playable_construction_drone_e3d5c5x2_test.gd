extends Node3D

const Demo = preload("res://scripts/ui/isolated_playable_construction_drone_demo.gd")
const Logistics = preload("res://scripts/ui/isolated_playable_construction_logistics_demo.gd")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState

func _ready() -> void:
	call_deferred("_checks")


func _fixture() -> Node:
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate() as Node3D
	add_child(sandbox)
	var demo := Demo.new()
	sandbox.add_child(demo)
	demo.enable_isolated_playable_demo = true
	demo.enable_isolated_power_demo = true
	assert(not demo.start_drone_demo())
	demo.enable_isolated_drone_demo = true
	assert(demo.start_drone_demo() and not demo.start_drone_demo())
	# Deterministic steps through the SAME frame callback used in play.
	demo.set_process(false)
	sandbox.get_node("WorldInteraction").set_process(false)
	return demo


func _step(demo: Node, count: int) -> void:
	for i: int in range(count):
		demo._process(0.1)


func _plan(demo: Node) -> ConstructionSite:
	var world := demo.get_parent().get_node("WorldInteraction")
	var site := world.call("_create_blueprint_site", STORAGE, Transform3D(Basis.IDENTITY, Logistics.SITE_POSITION)) as ConstructionSite
	assert(site != null)
	demo._prepare_marked_plan()
	assert(demo.site == site)
	return site


func _belt(demo: Node) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	demo.get_parent().add_child(belt)
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(demo.supply, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	demo._bind_connected_belt()
	assert(demo.bound_belt == belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	timer.travel_interval = 0.05
	return belt


func _deliver(demo: Node) -> bool:
	# Real timed conveyor movement. The driver is paused during filling so
	# we can inspect the exact stock before escrow reconciliation.
	var deadline: int = Time.get_ticks_msec() + 6000
	while demo.staging.get_staged_inventory().get_amount(INGOT) < 3 and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	return demo.staging.get_staged_inventory().get_amount(INGOT) == 3


func _surplus(demo: Node, belt: ConveyorSegment) -> int:
	var cargo := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	return demo.supply.inventory.get_amount(INGOT) + cargo.cargo_inventory.get_amount(INGOT)


func _checks() -> void:
	var demo := _fixture()
	assert(demo.gate.has_bound_driver())
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	assert(demo.drone.battery_units() == 40.0)
	assert(demo.escrow.held_count() == 0)
	print("PASS A: Opt-in real services and one charged worker, no debug bypass")
	var site := _plan(demo)
	demo._toggle_generator()
	demo._toggle_link()
	_step(demo, 10)
	assert(site.job.state == ConstructionJob.State.PLANNED and demo.fleet.assigned_count() == 0)
	assert(demo.allocated_power() == 0 and demo.escrow.held_count() == 0)
	print("PASS B: Powered planned site cannot dispatch or reserve")
	assert(demo.get_parent().get_node("WorldInteraction").call("_authorize_blueprint_site", site))
	_step(demo, 10)
	assert(site.job.state == ConstructionJob.State.QUEUED and demo.fleet.assigned_count() == 0)
	var belt := _belt(demo)
	_step(demo, 1)
	assert(demo._site_tracked and not site.is_processing())
	assert(demo.allocated_power() == 0 and demo.escrow.held_count() == 0)
	print("PASS C: Authorized and bound empty site cannot dispatch; single clock")
	demo._toggle_generator()
	assert(await _deliver(demo))
	_step(demo, 5)
	assert(demo.held_ingots() == 3 and demo.staging.get_staged_inventory().get_amount(INGOT) == 0)
	assert(demo.allocated_power() == 0 and demo.drone.get_flight_state() == Flight.IDLE)
	assert(_surplus(demo, belt) == 1 and site.job.get_progress() == 0.0)
	print("PASS D: Actual delivered stock reserved once, no power means no launch")
	demo._toggle_generator()
	_step(demo, 1)
	assert(demo.allocated_power() == 7 and demo.fleet.assigned_count() == 1)
	assert(demo.drone.get_flight_state() == Flight.OUTBOUND and site.job.get_progress() == 0.0)
	assert(demo.drone.battery_units() < 40.0)
	print("PASS E: Full escrow and power launch one physical metered drone")
	_step(demo, 15)
	assert(not demo.drone.is_at_site() and site.job.get_progress() == 0.0)
	_step(demo, 30)
	assert(demo.drone.is_at_site() and site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(site.job.get_progress() > 0.0 and site.job.get_progress() < 0.2)
	print("PASS F: Flight cannot advance work; arrival starts a single bounded clock")
	var before: float = site.job.get_progress()
	demo._toggle_generator()
	_step(demo, 10)
	assert(site.job.state == ConstructionJob.State.PAUSED and is_equal_approx(site.job.get_progress(), before))
	assert(demo.held_ingots() == 3 and demo.allocated_power() == 0)
	print("PASS G: Generator outage pauses progress and retains escrow")
	demo._toggle_generator()
	_step(demo, 10)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(site.job.get_progress() - before, 0.1))
	print("PASS H: Restoration resumes same job at definition-driven rate")
	var job := site.job
	_step(demo, 110)
	assert(job.state == ConstructionJob.State.COMPLETE and demo.completed_building() != null)
	assert(demo.escrow.held_count() == 0 and demo.allocated_power() == 0)
	assert(demo.completed_building().scene_file_path == STORAGE.building_scene.resource_path)
	assert(_surplus(demo, belt) == 1 and demo.staging.get_staged_inventory().get_amount(INGOT) == 0)
	print("PASS I: Completed real Storage commits three ingots once and releases power")
	await get_tree().process_frame
	await get_tree().process_frame
	_step(demo, 60)
	assert(demo.drone.get_flight_state() == Flight.DOCKED)
	assert(demo.drone.battery_units() < 40.0 and demo.fleet.assigned_count() == 1)
	assert(demo._drone_label.text.contains("COMPLETE"))
	print("PASS J: Worker returns home; no fabricated charge or reuse after deletion")
	demo.get_parent().free()
	demo = _fixture()
	site = _plan(demo)
	assert(demo.get_parent().get_node("WorldInteraction").call("_authorize_blueprint_site", site))
	demo._toggle_generator()
	demo._toggle_link()
	belt = _belt(demo)
	assert(await _deliver(demo))
	_step(demo, 1)
	assert(demo.held_ingots() == 3 and demo.drone.get_flight_state() == Flight.OUTBOUND)
	assert(site.job.cancel())
	await get_tree().process_frame
	await get_tree().process_frame
	_step(demo, 60)
	assert(demo.allocated_power() == 0 and demo.escrow.held_count() == 0)
	assert(demo.staging.get_staged_inventory().get_amount(INGOT) == 3 and _surplus(demo, belt) == 1)
	assert(demo.completed_building() == null and demo.drone.get_flight_state() == Flight.DOCKED)
	assert(demo._drone_label.text.contains("CANCELLED"))
	print("PASS K: In-flight cancellation refunds all stock, releases allocation and returns worker")
	print("ALL 11 E3D5C5X2 PLAYABLE CONSTRUCTION DRONE TESTS PASSED")
