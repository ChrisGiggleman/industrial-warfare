extends Node3D

const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Sandbox = preload("res://scenes/core/playable_automatic_construction_drone_sandbox.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")


func _ready() -> void:
	call_deferred("_checks")


func _checks() -> void:
	var ordinary := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate() as Node3D
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(ordinary.get_node_or_null("AutomaticConstructionSandbox") == null)
	assert(main.get_node_or_null("AutomaticConstructionSandbox") == null)
	assert(not ordinary.get_node("ConstructionDroneLifecycleGate").enable_isolated_bridge)
	assert(ordinary.get_node("WorldInteraction").blueprint_sandbox_debug_requirements)
	main.free()
	add_child(ordinary)
	var foreign := Demo.new()
	ordinary.add_child(foreign)
	assert(not foreign.enable_automatic_sandbox and not foreign.start())
	foreign.enable_automatic_sandbox = true
	assert(not foreign.start() and not foreign.is_processing())
	assert(ordinary.get_node("WorldInteraction").blueprint_sandbox_debug_requirements)
	ordinary.free()
	print("PASS A: Default-off adapter and explicit ordinary-scene rejection; Main unchanged")

	var disabled := Sandbox.instantiate() as Node3D
	var off := disabled.get_node("AutomaticConstructionSandbox") as Demo
	off.enable_automatic_sandbox = false
	add_child(disabled)
	assert(not off.start() and not off.is_processing())
	assert(off.dispatch == null and off.hub == null and off.drone == null)
	disabled.free()
	print("PASS B: Separate scene flag disabled prevents service creation")

	var sandbox := Sandbox.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	var world := sandbox.get_node("WorldInteraction")
	var original_queue := world.get("_construction_priority_queue") as BlueprintConstructionPriorityQueue
	# Test the actual scene's deferred startup before taking manual control
	# of the same frame callback; no second lifecycle driver.
	await get_tree().process_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo.is_processing())
	demo.set_process(false)
	assert(not demo.start() and demo.queue == original_queue)
	assert(demo.queue.get_parent() == sandbox and world.get("_construction_priority_queue") == original_queue)
	assert(demo.scheduler.uses_priority_queue(original_queue) and demo.scheduler.capacity == 1)
	assert(demo.coordinator.matches_tick_services(demo.scheduler, demo.escrow))
	assert(demo.coordinator.matches_owned_registry(demo.registry))
	assert(not world.get("blueprint_sandbox_debug_requirements"))
	assert(not demo.gate.enable_isolated_bridge and not demo.gate.has_bound_driver())
	print("PASS C: Real scene startup, exact original player queue, owned coordinator, one worker slot")

	assert(demo.hub.get_parent() == sandbox and demo.power.get_parent() == sandbox)
	assert(demo.network.is_energized(demo.hub.get_power_node()))
	assert(demo.power.spare_generation_for(demo.hub.get_power_node()) == 12)
	assert(demo.hub.get_node("InventoryComponent").get_total_amount() == 0)
	assert(demo.drone.global_position == demo.hub.global_position + Vector3.UP * 2.0)
	assert(demo.drone.battery_units() == 40.0 and demo.drone.battery_capacity() == 40.0)
	assert(demo.drone._finite_cargo_rearm_ready())
	assert(demo.drone._charging_owner.get_ref() == demo.charging)
	assert(demo.charging.matches_docked_registration(demo.drone, demo.drone._charging_token))
	print("PASS D: Completed powered Hub, exact physical home and finite charging identity")

	assert(demo.storage.get_parent() == sandbox and demo.dock.get_parent() == demo.storage)
	assert(demo.storage.get_node("BuildingRuntime").building_definition == STORAGE)
	assert(demo.stock == demo.storage.get_node("InventoryComponent"))
	assert(demo.stock.get_amount(INGOT) == 15 and demo.stock.get_available_space() == 5)
	assert(demo.supplier._service() == demo.discovery and demo.returns._service() == demo.discovery)
	assert(not demo.discovery.register_dock(demo.dock))
	var forecast: Dictionary = demo.discovery.find_return(demo.drone, INGOT, 3, true)
	assert(forecast.get("dock") == demo.dock and forecast.get("inventory") == demo.stock)
	assert(demo.supplier.reservation_count() == 0 and demo.returns.reservation_count() == 0)
	print("PASS E: Actual initialized Storage/dock, exact stock and return forecast, no claim or transfer")

	var before: int = demo.tick_count
	demo._process(-1.0)
	demo._process(INF)
	assert(demo.tick_count == before and demo.last_tick["action"] == &"blocked")
	demo._process(10.0)
	assert(demo.tick_count == before + 1 and demo.last_tick["action"] == &"waiting")
	assert(demo.drone.battery_units() == 40.0 and not demo.dispatch.has_lifecycle_assignment())
	assert(demo.dispatch.dispatch_next()["reason"] == &"lifecycle_owns_dispatch")
	print("PASS F: One bounded frame delegation, invalid delta rejected, direct dispatch denied")

	var site := world.call("_create_blueprint_site", STORAGE, Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0))) as ConstructionSite
	assert(site != null)
	var initial_process: bool = site.is_processing()
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	demo._process(0.1)
	assert(site.job.state == ConstructionJob.State.PLANNED and demo.queue.get_waiting_count() == 0)
	assert(world.call("_authorize_blueprint_site", site))
	assert(demo.queue.peek_next() == site and site.job.state == ConstructionJob.State.QUEUED)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and not demo.dispatch.has_lifecycle_assignment())
	assert(site.is_processing() == initial_process and site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"materials") and site.job.get_wait_reasons().has(&"power") and site.job.get_wait_reasons().has(&"workers"))
	assert(demo.registry.inventory_for_site(site) == null and demo.escrow.held_count() == 0)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.stock.get_reserved_amount(INGOT) == 0)
	print("PASS G: Real player authorization uses original queue; untracked site and its timer remain untouched")

	before = demo.tick_count
	demo.enable_automatic_sandbox = false
	demo._process(0.1)
	assert(demo.tick_count == before and demo.last_tick["action"] == &"blocked")
	demo.enable_automatic_sandbox = true
	demo.gate.enable_isolated_bridge = true
	demo._process(0.1)
	assert(demo.tick_count == before and not demo.has_verified_services())
	demo.gate.enable_isolated_bridge = false
	var legacy := PrototypeConstructionDroneTickController.new()
	sandbox.add_child(legacy)
	demo._process(0.1)
	assert(demo.tick_count == before and demo.last_tick["action"] == &"blocked")
	legacy.free()
	var duplicate := PrototypeDroneHubCharging.new()
	sandbox.add_child(duplicate)
	demo._process(0.1)
	assert(demo.tick_count == before and not demo.has_verified_services())
	duplicate.free()
	assert(demo.has_verified_services())
	demo._process(0.1)
	assert(demo.tick_count == before + 1 and demo.last_tick["action"] == &"waiting")
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0 and demo.scheduler.get_active_count() == 0)
	print("PASS H: Live gate/legacy driver/duplicate authority fail closed; clean scope resumes without stock movement")
	sandbox.free()
	print("ALL 8 PLAYABLE AUTOMATIC CONSTRUCTION DRONE STAGE A TESTS PASSED")
