extends Node3D

const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Sandbox = preload("res://scenes/core/playable_automatic_construction_drone_stage_b.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const EXTRACTOR = preload("res://data/buildings/test_extractor.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState


func _ready() -> void:
	call_deferred("_checks")


func _plan(world: Node, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var site := world.call("_create_blueprint_site", definition, Transform3D(Basis.IDENTITY, at)) as ConstructionSite
	assert(site != null)
	return site


func _until(demo: Demo, action: StringName, limit: int = 300) -> bool:
	for i: int in range(limit):
		demo._process(0.1)
		if demo.last_tick.get("action") == action:
			return true
	return false


func _checks() -> void:
	var sandbox := Sandbox.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo.enable_player_site_enrollment)
	demo.set_process(false)
	var world := demo.world
	world.set_process(false)
	var low := _plan(world, STORAGE, Vector3(-5, 0, 0))
	var first := _plan(world, STORAGE, Vector3(4, 0, -3))
	var second := _plan(world, STORAGE, Vector3(4, 0, 1))
	var unsupported := _plan(world, EXTRACTOR, Vector3(-5, 0, 4.5))
	assert(low.is_processing() and first.is_processing() and second.is_processing() and unsupported.is_processing())
	var disabled := Demo.new()
	assert(not disabled.enable_player_site_enrollment)
	disabled.free()
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"waiting" and demo.registry.claim_count() == 0)
	assert(first.job.state == ConstructionJob.State.PLANNED and demo.stock.get_amount(INGOT) == 15)
	print("PASS A: Actual player plans are unowned, unmodified and cannot auto-dispatch")

	# Existing priority/selected authorization handlers with the selected
	# set; physical mouse dragging remains in the accepted UI path.
	world.set("placement_mode_active", true)
	world.set("blueprint_mode_active", true)
	world.set("_blueprint_area_selection_mode", true)
	var selected: Array[ConstructionSite] = [first, second]
	world.set("_area_selected_sites", selected)
	assert(world.call("_set_selected_blueprint_priority", ConstructionJob.Priority.HIGH) == 2)
	assert(first.job.state == ConstructionJob.State.PLANNED and demo.registry.claim_count() == 0)
	assert(low.job.set_priority(ConstructionJob.Priority.LOW))
	assert(world.call("_authorize_blueprint_site", low))
	assert(demo.is_enrolled_site(low) and not low.is_processing())
	assert(world.call("_authorize_selected_blueprint_sites") == 2)
	assert(demo.is_enrolled_site(first) and demo.is_enrolled_site(second))
	assert(not first.is_processing() and not second.is_processing())
	assert(demo.queue.get_waiting_sites() == [first, second, low])
	print("PASS B: Selected authorization and High FIFO over earlier Low; eligible timer handoff")

	assert(world.call("_authorize_all_blueprint_sites") == 1)
	assert(unsupported.job.state == ConstructionJob.State.QUEUED and unsupported.is_processing())
	assert(not demo.is_enrolled_site(unsupported) and demo.registry.inventory_for_site(unsupported) == null)
	assert(demo.registry.claim_count() == 3 and demo.escrow.held_count() == 0)
	assert(not world.call("_authorize_blueprint_site", first))
	print("PASS C: Batch authorization preserved; unsupported multi-item site retains timer")

	var a := demo.registry.inventory_for_site(first)
	var b := demo.registry.inventory_for_site(second)
	var c := demo.registry.inventory_for_site(low)
	assert(a != null and b != null and c != null and a != b and a != c and b != c)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0 and c.get_total_amount() == 0)
	var entry: Dictionary = {}
	for record: Dictionary in demo._site_entries:
		if (record["site"] as WeakRef).get_ref() == first:
			entry = record
	assert(not entry.is_empty())
	var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
	var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
	assert(staging.receive_item(INGOT, 1) == 0 and not port.can_accept_belt_item(null, INGOT, 1))
	assert(port.can_accept_item(INGOT, 3) and demo.stock.get_amount(INGOT) == 15)
	print("PASS D: Distinct empty owned buffers; no belt intake or remote staging shortcut")

	demo._process(0.1)
	assert(demo.last_tick["action"] == &"launched" and demo.last_tick["selection"]["site"] == first)
	assert(demo.supplier.reservation_count() == 1 and demo.stock.get_reserved_amount(INGOT) == 3)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(first.job.get_progress() == 0.0 and second.job.get_progress() == 0.0)
	print("PASS E: High FIFO launches one exact reservation without remote transfer")

	assert(_until(demo, &"collected"))
	assert(demo.drone.get_flight_state() == Flight.CARGO_HELD)
	assert(demo.stock.get_amount(INGOT) == 12 and demo.drone.cargo_amount() == 3)
	assert(a.get_total_amount() == 0 and demo.escrow.held_count() == 0)
	assert(_until(demo, &"unloaded"))
	assert(a.get_amount(INGOT) == 3 and demo.drone.cargo_amount() == 0)
	assert(b.get_total_amount() == 0 and c.get_total_amount() == 0 and first.job.get_progress() == 0.0)
	print("PASS F: Physical pickup and delivery conserve exact stock; other receivers unchanged")

	assert(demo.hub.set_generator_enabled(false))
	assert(_until(demo, &"admitted"))
	assert(demo.escrow.held_count() == 1 and a.get_total_amount() == 0)
	demo._process(10.0)
	assert(first.job.get_progress() == 0.0 and demo.scheduler.get_active_count() == 0)
	assert(demo.hub.set_generator_enabled(true))
	assert(_until(demo, &"construction"))
	var before: float = first.job.get_progress()
	demo._process(10.0)
	assert(demo.last_tick["action"] == &"construction")
	assert(is_equal_approx(first.job.get_progress() - before, 0.01))
	assert(not first.is_processing() and demo.power.get_allocated_units(first) == 7)
	assert(second.job.get_progress() == 0.0 and low.job.get_progress() == 0.0)
	print("PASS G: Escrow and worker still require power; long frame advances one capped clock step")

	var first_job := first.job
	assert(world.call("_cancel_blueprint_site", first))
	assert(first_job.state == ConstructionJob.State.CANCELLED and demo.escrow.held_count() == 0)
	assert(a.get_amount(INGOT) == 3 and demo.registry.has_locked_pair(staging, port))
	assert(demo.stock.get_amount(INGOT) + a.get_amount(INGOT) == 15)
	assert(b.get_total_amount() == 0 and c.get_total_amount() == 0)
	assert(demo.dispatch.has_lifecycle_assignment())
	print("PASS H: Player cancellation refunds only original buffer; assignment guarded")
	sandbox.free()
	print("ALL 8 PLAYABLE AUTOMATIC CONSTRUCTION DRONE STAGE B TESTS PASSED")
