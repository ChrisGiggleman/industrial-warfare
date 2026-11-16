extends Node3D

const Demo = preload("res://scripts/ui/isolated_playable_construction_power_demo.gd")
const Logistics = preload("res://scripts/ui/isolated_playable_construction_logistics_demo.gd")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")

func _ready() -> void:
	call_deferred("_checks")


func _checks() -> void:
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate() as Node3D
	add_child(sandbox)
	var demo := Demo.new()
	sandbox.add_child(demo)
	demo.enable_isolated_playable_demo = true
	assert(not demo.start_power_demo())
	demo.enable_isolated_power_demo = true
	assert(demo.start_power_demo() and not demo.start_power_demo())
	var world := sandbox.get_node("WorldInteraction")
	world.set_process(false)
	assert(not bool(world.get("blueprint_sandbox_debug_requirements")))
	assert(demo.hub.available_nameplate_generation() == 0)
	assert(not demo.network.is_energized(demo.pole.get_power_node()))
	print("PASS A: Explicit demo starts with real Hub and pole off and disconnected")
	var site := world.call("_create_blueprint_site", STORAGE, Transform3D(Basis.IDENTITY, Logistics.SITE_POSITION)) as ConstructionSite
	assert(site != null)
	demo._prepare_marked_plan()
	assert(demo.site == site)
	demo._toggle_generator()
	assert(demo.hub.available_nameplate_generation() == 12)
	assert(demo.allocated_power() == 0 and site.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Generator cannot allocate power or authorize planned work")
	assert(world.call("_authorize_blueprint_site", site))
	demo._refresh_power()
	assert(demo.allocated_power() == 0 and site.job.get_wait_reasons().has(&"power"))
	print("PASS C: Online Hub alone cannot cover the blueprint")
	demo._toggle_link()
	assert(demo.network.is_energized(demo.pole.get_power_node()))
	assert(demo.allocated_power() == 7 and not site.job.get_wait_reasons().has(&"power"))
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	print("PASS D: Connected relay allocates exactly seven units; no construction")
	demo._toggle_capacity()
	assert(demo.hub.available_nameplate_generation() == 5 and demo.allocated_power() == 0)
	assert(site.job.get_wait_reasons().has(&"power"))
	demo._toggle_capacity()
	assert(demo.allocated_power() == 7)
	print("PASS E: Insufficient finite generation denies entire grant; restoration works")
	demo._toggle_generator()
	assert(demo.allocated_power() == 0 and not demo.network.is_energized(demo.pole.get_power_node()))
	demo._toggle_generator()
	assert(demo.allocated_power() == 7)
	demo._toggle_link()
	assert(demo.allocated_power() == 0)
	demo._toggle_link()
	assert(demo.allocated_power() == 7)
	print("PASS F: Generator and network link outages remove allocation and recover")
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	sandbox.add_child(belt)
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(demo.supply, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	demo._bind_connected_belt()
	assert(demo.bound_belt == belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	timer.travel_interval = 0.05
	var cargo := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var deadline: int = Time.get_ticks_msec() + 6000
	while (demo.staging.get_staged_inventory().get_amount(INGOT) < 3 or cargo.get_held_item() == null) and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	assert(demo.staging.get_staged_inventory().get_amount(INGOT) == 3)
	assert(cargo.get_held_item() == INGOT and demo.supply.inventory.get_amount(INGOT) == 0)
	assert(demo.allocated_power() == 7 and demo.escrow.held_count() == 0)
	assert(site.job.get_wait_reasons().has(&"workers") and site.job.get_wait_reasons().has(&"materials"))
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	print("PASS G: Powered site receives three ingots but never starts without worker/escrow")
	demo._toggle_generator()
	assert(demo.allocated_power() == 0 and demo.staging.get_staged_inventory().get_amount(INGOT) == 3)
	demo._toggle_generator()
	assert(demo.allocated_power() == 7)
	demo.pole.set_service_enabled(false)
	demo._refresh_power()
	assert(demo.allocated_power() == 0)
	demo.pole.set_service_enabled(true)
	demo._refresh_power()
	assert(demo.allocated_power() == 7)
	print("PASS H: Power and relay failures never consume materials or advance work")
	assert(site.job.cancel())
	await get_tree().process_frame
	await get_tree().process_frame
	assert(demo.allocated_power() == 0 and demo.allocator.get_allocations().is_empty())
	assert(demo.staging.get_staged_inventory().get_amount(INGOT) == 3 and cargo.get_held_item() == INGOT)
	assert(demo._label.text.contains("Site ended") and not demo.gate.has_bound_driver())
	print("PASS I: Cancelled/deleted site releases allocation; HUD and all four ingots preserved")
	print("ALL 9 E3D5C5X1 PLAYABLE CONSTRUCTION POWER TESTS PASSED")
