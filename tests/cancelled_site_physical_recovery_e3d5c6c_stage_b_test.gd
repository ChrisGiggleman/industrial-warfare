extends Node3D
## E3d5c6c Stage B: controlled original one-drone physical return mission
## after cancelled site and completed original construction-drone rearm.
## No test-only teleport, synthetic cargo, fake stock or second driver.
const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Audit = preload("res://scripts/components/prototype_cancelled_site_custody_audit.gd")
const Transport = preload("res://scripts/components/prototype_cancelled_site_recovery_transport.gd")
const Direct = preload("res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const Flight = PrototypeConstructionWorkerDrone.FlightState
const STORAGE_POS := Vector3(0, 0, -3)
const PRESS_POS := Vector3(4.5, 0, -3.5)
const EMPTY_POS := Vector3(-5, 0, 0)

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




func _pair(demo: Demo, site: ConstructionSite) -> Dictionary:
	for entry: Dictionary in demo._site_entries:
		if (entry["site"] as WeakRef).get_ref() == site and entry["job"] == site.job:
			var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
			var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
			if is_instance_valid(staging) and is_instance_valid(port):
				return {"staging": staging, "port": port, "buffer": staging.get_staged_inventory()}
	return {}


func _set_up_audit(sandbox: Node3D, demo: Demo) -> PrototypeCancelledSiteCustodyAudit:
	var audit := Audit.new() as PrototypeCancelledSiteCustodyAudit
	sandbox.add_child(audit)
	assert(not audit.enable_isolated_custody_audit)
	assert(not audit.configure(demo.registry, demo.escrow))
	audit.enable_isolated_custody_audit = true
	assert(audit.configure(demo.registry, demo.escrow))
	assert(not audit.configure(demo.registry, demo.escrow))
	return audit




func _transport(sandbox: Node3D, demo: Demo, audit: PrototypeCancelledSiteCustodyAudit) -> PrototypeCancelledSiteRecoveryTransport:
	var transport := Transport.new() as PrototypeCancelledSiteRecoveryTransport
	sandbox.add_child(transport)
	assert(not transport.enable_isolated_physical_recovery)
	assert(not transport.configure(demo, audit))
	transport.enable_isolated_physical_recovery = true
	demo.drone.enable_isolated_cancelled_staging_flight = true
	audit.enable_isolated_stage_b_source_access = true
	assert(transport.configure(demo, audit))
	assert(not transport.configure(demo, audit))
	return transport


func _reach(transport: PrototypeCancelledSiteRecoveryTransport, drone: PrototypeConstructionWorkerDrone, state: int, max_ticks: int = 400) -> void:
	for i: int in range(max_ticks):
		if drone.get_flight_state() == state:
			return
		var result: Dictionary = transport.tick(0.1)
		assert(result.get("action") in [&"site_flight", &"storage_flight", &"home_flight"], "Recovery cannot advance: %s" % result)
	assert(drone.get_flight_state() == state, "Recovery flight did not reach required state %s" % state)


func _fresh() -> Dictionary:
	var sandbox := Direct.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	return {"sandbox": sandbox, "demo": demo}


func _checks() -> void:
	var first := _fresh()
	var sandbox := first["sandbox"] as Node3D
	var demo := first["demo"] as Demo
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services())
	demo.set_process(false)
	demo.world.set_process(false)
	var audit := _set_up_audit(sandbox, demo)
	var storage := _place(demo, STORAGE, STORAGE_POS)
	assert(demo.network.covers_site(storage))
	var pair := _pair(demo, storage)
	var buffer := pair["buffer"] as InventoryComponent
	var tid: int = audit.capture_site(storage, pair["staging"], pair["port"])
	assert(tid > 0)
	_launch(demo, storage, 3, 15)
	_collect(demo, buffer, 3, 15)
	_deliver(demo, storage, buffer, 3)
	assert(demo.world.call("_cancel_blueprint_site", storage))
	_rearm(demo, 1)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(audit.observe(tid)["status"] == &"ready_read_only")
	assert(demo.stock.get_amount(INGOT) == 12 and buffer.get_amount(INGOT) == 3)
	print("PASS A: Original direct Storage physically delivered, cancelled, and protected 3 ingots")

	var transport := _transport(sandbox, demo, audit)
	assert(transport.active_ticket() == 0 and transport.completed_count() == 0)
	assert(not transport.begin(999) and demo.stock.get_reserved_return_space() == 0)
	assert(not transport.begin(0) and demo.dispatch.has_lifecycle_assignment() == false)
	print("PASS B: Exact original ticket and default-off authority; no fake recovery mission")

	assert(transport.begin(tid))
	assert(not transport.begin(tid) and transport.active_ticket() == tid)
	assert(demo.stock.get_reserved_return_space() == 3 and demo.stock.get_amount(INGOT) == 12)
	assert(buffer.get_amount(INGOT) == 3 and demo.drone.cargo_amount() == 0)
	assert(demo.escrow.held_count() == 0 and demo.registry.claim_count() == 1)
	print("PASS C: Exact destination capacity reserved before any source debit")

	_reach(transport, demo.drone, Flight.STAGED_AT_SITE)
	assert(demo.drone.global_position.is_equal_approx(audit.observe(tid)["hover_position"]))
	assert(demo.drone.battery_units() < 40.0 and buffer.get_amount(INGOT) == 3)
	assert(demo.stock.get_amount(INGOT) == 12 and demo.drone.cargo_amount() == 0)
	print("PASS D: Metered drone travels to original receiver; no remote stock transfer")

	assert(transport.tick(0.1)["action"] == &"collected")
	assert(buffer.get_total_amount() == 0 and demo.drone.cargo_amount() == 3)
	assert(demo.drone.cargo_item() == INGOT and audit.observe(tid)["status"] == &"empty_no_pickup")
	assert(demo.stock.get_amount(INGOT) == 12 and demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	print("PASS E: Exact three-ingot source debit only at original hover; staging lock retained")

	assert(transport.tick(0.1)["action"] == &"return_started")
	demo.dock.available = false
	var held: Vector3 = demo.drone.global_position
	for i: int in range(5):
		assert(transport.tick(0.1)["action"] == &"destination_wait")
	assert(demo.drone.global_position == held and demo.drone.cargo_amount() == 3)
	assert(demo.stock.get_amount(INGOT) == 12 and demo.stock.get_reserved_return_space() == 3)
	demo.dock.available = true
	print("PASS F: Unavailable dock holds real cargo, reserved space and finite position")

	_reach(transport, demo.drone, Flight.STAGED_AT_STORAGE)
	assert(demo.drone.global_position.is_equal_approx(demo.dock.global_position))
	assert(demo.stock.get_amount(INGOT) == 12 and demo.drone.cargo_amount() == 3)
	demo.dock.allow_returns = false
	assert(transport.tick(0.1)["action"] == &"destination_wait")
	assert(demo.stock.get_amount(INGOT) == 12 and demo.drone.cargo_amount() == 3)
	demo.dock.allow_returns = true
	print("PASS G: Actual return flight; blocked unload preserves all physical cargo")

	assert(transport.tick(0.1)["action"] == &"unloaded")
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(buffer.get_total_amount() == 0 and demo.stock.get_reserved_return_space() == 0)
	assert(demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	assert(demo.stock.get_amount(INGOT) + buffer.get_amount(INGOT) == 15)
	print("PASS H: Real dock unload consumes reservation; 12+3 returns to 15, no unlock")

	_reach(transport, demo.drone, Flight.DOCKED)
	var low_battery: float = demo.drone.battery_units()
	assert(low_battery < 40.0 and demo.drone.cargo_amount() == 0)
	assert(demo.hub.set_generator_enabled(false))
	assert(transport.tick(0.1)["action"] == &"dock_wait")
	assert(demo.drone.battery_units() == low_battery)
	assert(demo.hub.set_generator_enabled(true))
	assert(transport.tick(0.1)["action"] == &"charged")
	assert(demo.drone.battery_units() > low_battery)
	print("PASS I: Drone physically returns home; generator OFF blocks finite recharge")

	for i: int in range(350):
		if transport.active_ticket() == 0:
			break
		var result: Dictionary = transport.tick(0.1)
		assert(result["action"] in [&"charged", &"rearmed"])
	assert(transport.active_ticket() == 0 and transport.completed_count() == 1)
	assert(transport.recovered_amount(tid) == 3)
	assert(demo.drone.get_flight_state() == Flight.IDLE and demo.drone.completed_rearms() == 2)
	assert(is_equal_approx(demo.drone.battery_units(), 40.0))
	assert(not transport.begin(tid) and audit.observe(tid)["status"] == &"empty_no_pickup")
	assert(demo.stock.get_amount(INGOT) == 15)
	print("PASS J: Same drone full rearm, one recovery ticket, no duplicate stock or mission")

	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	# Separate fresh canonical Press cancellation with actual 5-unit delivery.
	var second := _fresh()
	sandbox = second["sandbox"] as Node3D
	demo = second["demo"] as Demo
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services())
	demo.set_process(false)
	demo.world.set_process(false)
	audit = _set_up_audit(sandbox, demo)
	var press := _place(demo, PRESS, PRESS_POS)
	pair = _pair(demo, press)
	buffer = pair["buffer"] as InventoryComponent
	tid = audit.capture_site(press, pair["staging"], pair["port"])
	assert(tid > 0)
	_launch(demo, press, 5, 15)
	_collect(demo, buffer, 5, 15)
	_deliver(demo, press, buffer, 5)
	_begin_work(demo, press, buffer)
	assert(demo.world.call("_cancel_blueprint_site", press))
	_rearm(demo, 1)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(audit.observe(tid)["status"] == &"ready_read_only")
	assert(demo.stock.get_amount(INGOT) == 10 and buffer.get_amount(INGOT) == 5)
	transport = _transport(sandbox, demo, audit)
	print("PASS K: Cancelled during-work Press refunds five ingots into protected original staging")

	# A full eligible destination prevents both ticket activation and
	# physical source debit. Restore capacity only after inspecting both.
	demo.stock.max_capacity = 10
	assert(not transport.begin(tid) and demo.stock.get_reserved_return_space() == 0)
	assert(buffer.get_amount(INGOT) == 5 and demo.stock.get_amount(INGOT) == 10)
	demo.stock.max_capacity = 20
	var receiver := pair["port"] as BlueprintConstructionStagingInputPort
	var original_hover: Vector3 = receiver.global_position
	receiver.global_position = original_hover + Vector3.RIGHT
	assert(audit.observe(tid)["status"] == &"quarantined")
	assert(not transport.begin(tid) and demo.drone.cargo_amount() == 0)
	receiver.global_position = original_hover
	assert(transport.begin(tid))
	assert(not transport.begin(tid))
	assert(demo.stock.get_reserved_return_space() == 5 and buffer.get_amount(INGOT) == 5)
	print("PASS L: Full storage and moved original port fail closed; exact Press return slot claimed")
	_reach(transport, demo.drone, Flight.STAGED_AT_SITE)
	assert(transport.tick(0.1)["action"] == &"collected")
	assert(demo.drone.cargo_amount() == 5 and buffer.get_amount(INGOT) == 0)
	assert(transport.tick(0.1)["action"] == &"return_started")
	_reach(transport, demo.drone, Flight.STAGED_AT_STORAGE)
	assert(transport.tick(0.1)["action"] == &"unloaded")
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(demo.stock.get_reserved_return_space() == 0 and demo.registry.has_locked_pair(pair["staging"], pair["port"]))
	_reach(transport, demo.drone, Flight.DOCKED)
	for i: int in range(350):
		if transport.active_ticket() == 0:
			break
		assert(transport.tick(0.1)["action"] in [&"charged", &"rearmed"])
	assert(transport.active_ticket() == 0 and transport.recovered_amount(tid) == 5)
	assert(demo.drone.get_flight_state() == Flight.IDLE and demo.drone.completed_rearms() == 2)
	assert(demo.stock.get_amount(INGOT) + buffer.get_amount(INGOT) == 15)
	assert(not transport.begin(tid))
	print("PASS M: Press five-ingot physical recovery, full recharge and exact conservation")
	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	print("ALL 13 CANCELLED SITE PHYSICAL RECOVERY E3D5C6C STAGE B TESTS PASSED")
