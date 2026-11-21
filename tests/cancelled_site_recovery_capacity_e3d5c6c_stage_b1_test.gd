extends Node3D
## E3d5c6c Stage B1 — exact cancelled-site source custody and destination
## Storage capacity reservation; intentionally NO recovered cargo movement.
const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Audit = preload("res://scripts/components/prototype_cancelled_site_custody_audit.gd")
const Capacity = preload("res://scripts/components/prototype_cancelled_site_recovery_capacity.gd")
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
	var audit := _set_up_audit(sandbox, demo)
	var service := Capacity.new() as PrototypeCancelledSiteRecoveryCapacity
	sandbox.add_child(service)
	assert(not service.enable_isolated_recovery_capacity)
	assert(not service.configure(audit, demo.discovery, demo.returns, demo.dispatch, demo.drone))
	service.enable_isolated_recovery_capacity = true
	assert(service.configure(audit, demo.discovery, demo.returns, demo.dispatch, demo.drone))
	assert(not service.configure(audit, demo.discovery, demo.returns, demo.dispatch, demo.drone))
	assert(service.claim_count() == 0)
	print("PASS A: Opt-in exact scene; configured once; no second driver or authority")

	# Original site and actual receiver are established through real Direct
	# click, not caller-selected mock cargo.
	var site := _place(demo, STORAGE, STORAGE_POS)
	assert(is_instance_valid(site))
	var pair := _pair(demo, site)
	assert(pair.size() == 3)
	var staging := pair["staging"] as BlueprintConstructionMaterialStaging
	var port := pair["port"] as BlueprintConstructionStagingInputPort
	var buffer := pair["buffer"] as InventoryComponent
	var job: ConstructionJob = site.job
	var ticket: int = audit.capture_site(site, staging, port)
	assert(ticket > 0 and audit.observe(ticket)["status"] == &"active_not_recoverable")
	assert(service.reserve(ticket, staging, port, buffer, job) == 0)
	assert(service.claim_count() == 0 and demo.stock.get_reserved_return_space() == 0)
	assert(demo.stock.get_amount(INGOT) == 15)
	print("PASS B: Active construction cannot reserve recovery or pre-spend stock")

	_launch(demo, site, 3, 15)
	_collect(demo, buffer, 3, 15)
	_deliver(demo, site, buffer, 3)
	assert(buffer.get_amount(INGOT) == 3 and demo.stock.get_amount(INGOT) == 12)
	assert(demo.world.call("_cancel_blueprint_site", site))
	assert(job.state == ConstructionJob.State.CANCELLED)
	assert(audit.observe(ticket)["status"] == &"ready_read_only")
	_rearm(demo, 1)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(not is_instance_valid(site))
	assert(audit.observe(ticket)["amount"] == 3)
	assert(demo.registry.has_locked_pair(staging, port))
	assert(demo.drone.get_flight_state() == Flight.IDLE)
	print("PASS C: Real three-ingot delivery, terminal cancellation, locked source and empty rearmed drone")

	assert(audit.matches_original_terminal_source(ticket, staging, port, buffer, job))
	assert(not audit.matches_original_terminal_source(ticket, staging, port, demo.stock, job))
	assert(not audit.matches_original_terminal_source(ticket + 1000, staging, port, buffer, job))
	assert(service.reserve(ticket, staging, port, demo.stock, job) == 0)
	assert(service.reserve(ticket + 1000, staging, port, buffer, job) == 0)
	assert(demo.stock.get_reserved_return_space() == 0)
	print("PASS D: Ticket refuses impostor source, wrong inventory and nonexistent provenance")

	# No route can create room in a real Storage. Capacity is physical and
	# all outstanding reservations must be accounted for first.
	demo.stock.max_capacity = 14
	assert(demo.stock.get_available_space() == 2)
	assert(service.reserve(ticket, staging, port, buffer, job) == 0)
	demo.stock.max_capacity = 20
	var external: RefCounted = RefCounted.new()
	assert(demo.stock.reserve_drone_return_space(external, INGOT, 6))
	assert(demo.stock.get_available_space() == 2)
	assert(service.reserve(ticket, staging, port, buffer, job) == 0)
	assert(demo.stock.release_drone_return_space(external))
	assert(demo.stock.get_available_space() == 8 and demo.stock.get_reserved_return_space() == 0)
	print("PASS E: Insufficient destination capacity and competing claims block reservation")

	var home: Vector3 = demo.drone.global_position
	var energy_before: float = demo.drone.battery_units()
	var stock_revision: int = demo.stock.get_mutation_revision()
	var stage_revision: int = buffer.get_mutation_revision()
	var claim: int = service.reserve(ticket, staging, port, buffer, job)
	assert(claim > 0)
	assert(service.claim_count() == 1)
	assert(demo.stock.has_drone_return_claim(service._claims[claim]["token"], INGOT, 3))
	assert(demo.stock.get_reserved_return_space() == 3 and demo.stock.get_available_space() == 5)
	assert(service.observe(claim)["status"] == &"reserved_read_only")
	assert(service.observe(claim)["amount"] == 3 and service.observe(claim)["ticket_id"] == ticket)
	assert(buffer.get_amount(INGOT) == 3 and demo.stock.get_amount(INGOT) == 12)
	assert(demo.stock.get_mutation_revision() == stock_revision and buffer.get_mutation_revision() == stage_revision)
	assert(demo.drone.cargo_amount() == 0 and demo.drone.global_position.is_equal_approx(home))
	assert(demo.drone.battery_units() == energy_before)
	print("PASS F: One true capacity claim; no item, energy, worker, timer or drone motion")

	assert(service.reserve(ticket, staging, port, buffer, job) == 0)
	assert(service.claim_count() == 1 and demo.stock.get_reserved_return_space() == 3)
	var duplicate := Capacity.new() as PrototypeCancelledSiteRecoveryCapacity
	sandbox.add_child(duplicate)
	duplicate.enable_isolated_recovery_capacity = true
	assert(not duplicate.configure(audit, demo.discovery, demo.returns, demo.dispatch, demo.drone))
	duplicate.free()
	assert(service.observe(claim)["status"] == &"reserved_read_only")
	print("PASS G: Duplicate ticket and duplicate scoped capacity authority refused")

	demo.dock.allow_returns = false
	assert(service.observe(claim)["status"] == &"quarantined")
	assert(demo.stock.get_reserved_return_space() == 3)
	demo.dock.allow_returns = true
	assert(service.observe(claim)["status"] == &"reserved_read_only")
	port.global_position += Vector3.RIGHT
	assert(audit.observe(ticket)["status"] == &"quarantined")
	assert(service.observe(claim)["status"] == &"quarantined")
	port.global_position -= Vector3.RIGHT
	assert(service.observe(claim)["status"] == &"reserved_read_only")
	assert(buffer.get_amount(INGOT) == 3)
	print("PASS H: Disabled dock and moved original receiver quarantine without claiming cargo")

	service.enable_isolated_recovery_capacity = false
	assert(service.observe(claim)["status"] == &"quarantined")
	assert(service.reserve(ticket, staging, port, buffer, job) == 0)
	assert(demo.stock.get_reserved_return_space() == 3)
	assert(service.release(claim, demo.drone))
	assert(service.claim_count() == 0 and demo.stock.get_reserved_return_space() == 0)
	assert(demo.stock.get_amount(INGOT) == 12 and buffer.get_amount(INGOT) == 3)
	service.enable_isolated_recovery_capacity = true
	print("PASS I: Turning feature OFF preserves claim; explicit cleanup releases only space")

	var retry: int = service.reserve(ticket, staging, port, buffer, job)
	assert(retry > claim and service.observe(retry)["status"] == &"reserved_read_only")
	assert(not service.release(retry, null))
	assert(service.release(retry, demo.drone))
	assert(not service.release(retry, demo.drone))
	assert(demo.stock.get_reserved_return_space() == 0)
	assert(demo.stock.get_amount(INGOT) + buffer.get_amount(INGOT) == 15)
	assert(demo.registry.has_locked_pair(staging, port))
	assert(demo.drone.battery_units() == energy_before and demo.drone.global_position.is_equal_approx(home))
	print("PASS J: Exact-worker retry and idempotent release; 12 + 3 = 15, no physical movement")
	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	print("ALL 10 CANCELLED SITE RECOVERY CAPACITY E3D5C6C STAGE B1 TESTS PASSED")
