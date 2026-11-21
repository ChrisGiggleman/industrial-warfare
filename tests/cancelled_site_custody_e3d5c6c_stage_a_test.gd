extends Node3D
## E3d5c6c Stage A — isolated, read-only custody audit against live original
## Direct Build clicks and physical drone delivery. No material recovery yet.
const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Audit = preload("res://scripts/components/prototype_cancelled_site_custody_audit.gd")
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
	# A — no automatic opt-in and no outside-scope authority.
	var foreign := Audit.new() as PrototypeCancelledSiteCustodyAudit
	add_child(foreign)
	foreign.enable_isolated_custody_audit = true
	assert(not foreign.configure(null, null))
	foreign.free()
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
	assert(audit.ticket_count() == 0 and demo.registry.claim_count() == 0)
	print("PASS A: Default-off, exact scene and original service authority; no process driver")

	# B — real Direct placement, independent per-site staging, no impostor pair.
	var storage := _place(demo, STORAGE, STORAGE_POS)
	var press := _place(demo, PRESS, PRESS_POS)
	assert(is_instance_valid(storage) and is_instance_valid(press))
	assert(demo.network.covers_site(storage) and demo.network.covers_site(press))
	var storage_pair := _pair(demo, storage)
	var press_pair := _pair(demo, press)
	assert(storage_pair.size() == 3 and press_pair.size() == 3)
	var storage_buffer := storage_pair["buffer"] as InventoryComponent
	var press_buffer := press_pair["buffer"] as InventoryComponent
	assert(storage_buffer != press_buffer and demo.registry.claim_count() == 2)
	assert(audit.capture_site(storage, press_pair["staging"], press_pair["port"]) == 0)
	assert(audit.capture_site(storage, storage_pair["staging"], press_pair["port"]) == 0)
	assert(audit.capture_site(press, storage_pair["staging"], storage_pair["port"]) == 0)
	print("PASS B: Foreign site-to-staging pair rejected; two original, distinct claims")

	# C — snapshots never authorize or move stock, duplicate capture rejected.
	var sid: int = audit.capture_site(storage, storage_pair["staging"], storage_pair["port"])
	var pid: int = audit.capture_site(press, press_pair["staging"], press_pair["port"])
	assert(sid > 0 and pid > sid and audit.ticket_count() == 2)
	assert(audit.capture_site(storage, storage_pair["staging"], storage_pair["port"]) == 0)
	assert(audit.capture_site(press, press_pair["staging"], press_pair["port"]) == 0)
	assert(audit.observe(sid)["status"] == &"active_not_recoverable")
	assert(audit.observe(pid)["status"] == &"active_not_recoverable")
	assert(audit.observe(999999)["status"] == &"unavailable")
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(demo.escrow.held_count() == 0 and demo.scheduler.get_active_count() == 0)
	print("PASS C: Unique monotonic tickets; active jobs refused; no resource movement")

	# D — physical pickup and delivery of canonical three-ingot bill.
	_launch(demo, storage, 3, 15)
	_collect(demo, storage_buffer, 3, 15)
	_deliver(demo, storage, storage_buffer, 3)
	assert(audit.observe(sid)["status"] == &"active_not_recoverable")
	assert(demo.stock.get_amount(INGOT) == 12 and storage_buffer.get_amount(INGOT) == 3)
	assert(press_buffer.get_total_amount() == 0 and audit.ticket_count() == 2)
	print("PASS D: Real Storage pickup/unload; ledger read-only until terminal cancellation")

	# E — cancel after delivery; original staging, no inventory teleport.
	# The placement ray can set ground-contact Y independently of the
	# requested grid X/Z. Record the exact approved original site and
	# original receiver hover BEFORE queue_free, not a hardcoded Y=0.
	var original_site_id: int = storage.get_instance_id()
	var actual_hover: Vector3 = storage.global_position + Vector3.UP * 2.0
	assert(
		Vector2(storage.global_position.x, storage.global_position.z).is_equal_approx(
			Vector2(STORAGE_POS.x, STORAGE_POS.z)
		)
	)
	assert((storage_pair["port"] as BlueprintConstructionStagingInputPort).global_position.is_equal_approx(actual_hover))
	assert(demo.world.call("_cancel_blueprint_site", storage))
	assert(storage.job.state == ConstructionJob.State.CANCELLED)
	var obs: Dictionary = audit.observe(sid)
	assert(obs["status"] == &"ready_read_only" and obs["amount"] == 3)
	assert(obs["expected"] == 3 and obs["original_site_id"] == original_site_id)
	assert(obs["definition_id"] == STORAGE.building_id)
	assert(
		(obs["hover_position"] as Vector3).is_equal_approx(actual_hover),
		"Custody hover mismatch: recorded=%s actual site hover=%s" % [obs["hover_position"], actual_hover]
	)
	assert(demo.stock.get_amount(INGOT) == 12 and storage_buffer.get_amount(INGOT) == 3)
	assert(demo.registry.has_locked_pair(storage_pair["staging"], storage_pair["port"]))
	assert(demo.escrow.held_count() == 0 and demo.drone.cargo_amount() == 0)
	print("PASS E: Delivered cancellation preserves original three-ingot locked custody")

	# F — the original site is actually freed; same ticket remains bound to
	# exact port+staging+buffer instead of accepting arbitrary null weakrefs.
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(not is_instance_valid(storage))
	assert(audit.observe(sid)["status"] == &"ready_read_only")
	assert(audit.observe(pid)["status"] == &"active_not_recoverable")
	assert(demo.registry.has_locked_pair(storage_pair["staging"], storage_pair["port"]))
	assert(demo.registry.claim_count() == 2)
	assert(demo.stock.get_amount(INGOT) == 12 and storage_buffer.get_amount(INGOT) == 3)
	print("PASS F: Freed original site retains ticket and locked source provenance")

	# G — a moved/detached receiver cannot be accepted as the original pickup.
	var storage_port := storage_pair["port"] as BlueprintConstructionStagingInputPort
	var original_hover: Vector3 = storage_port.global_position
	storage_port.global_position = original_hover + Vector3.RIGHT
	assert(audit.observe(sid)["status"] == &"quarantined")
	storage_port.global_position = original_hover
	assert(audit.observe(sid)["status"] == &"ready_read_only")
	assert(storage_buffer.get_amount(INGOT) == 3)
	print("PASS G: Moved receiver quarantined; position restoration never transfers material")

	# H — the same drone completes its terminal return before dispatching the
	# second site's existing physical delivery; exact identities stay distinct.
	_rearm(demo, 1)
	assert(demo.stock.get_amount(INGOT) == 12 and audit.observe(sid)["amount"] == 3)
	_launch(demo, press, 5, 12)
	_collect(demo, press_buffer, 5, 12)
	_deliver(demo, press, press_buffer, 5)
	assert(demo.stock.get_amount(INGOT) == 7 and press_buffer.get_amount(INGOT) == 5)
	assert(audit.observe(pid)["status"] == &"active_not_recoverable")
	assert(audit.observe(sid)["status"] == &"ready_read_only")
	print("PASS H: Independent Press five-ingot delivery; no cross-ticket adoption")

	# I — during-work cancellation: escrow must refund the original bill into
	# Press staging, never into Starter Storage or the older Storage staging.
	_begin_work(demo, press, press_buffer)
	assert(demo.escrow.held_count() == 1 and press_buffer.get_total_amount() == 0)
	assert(audit.observe(pid)["status"] == &"active_not_recoverable")
	var press_job := press.job
	assert(demo.world.call("_cancel_blueprint_site", press))
	assert(press_job.state == ConstructionJob.State.CANCELLED)
	assert(demo.escrow.held_count() == 0 and press_buffer.get_amount(INGOT) == 5)
	assert(audit.observe(pid)["status"] == &"ready_read_only")
	assert(audit.observe(pid)["expected"] == 5)
	assert(audit.observe(sid)["original_site_id"] != audit.observe(pid)["original_site_id"])
	print("PASS I: Working Press escrow refunds exact five into original protected buffer")

	# J — no committed items or hidden debit. The two separate cancelled site
	# buffers plus Starter Storage account for all 15 physical ingots.
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(not is_instance_valid(press))
	assert(audit.observe(pid)["status"] == &"ready_read_only")
	assert(demo.registry.has_locked_pair(press_pair["staging"], press_pair["port"]))
	assert(demo.stock.get_amount(INGOT) == 7 and storage_buffer.get_amount(INGOT) == 3)
	assert(press_buffer.get_amount(INGOT) == 5 and demo.drone.cargo_amount() == 0)
	assert(demo.stock.get_amount(INGOT) + storage_buffer.get_amount(INGOT) + press_buffer.get_amount(INGOT) == 15)
	_rearm(demo, 2)
	print("PASS J: 7 source + 3 locked Storage + 5 locked Press = exactly 15; two rearms")

	# K — cancelling before pickup creates an empty audit, never a false load.
	var empty_site := _place(demo, STORAGE, EMPTY_POS)
	assert(is_instance_valid(empty_site))
	var empty_pair := _pair(demo, empty_site)
	var eid: int = audit.capture_site(empty_site, empty_pair["staging"], empty_pair["port"])
	assert(eid > pid and audit.observe(eid)["status"] == &"active_not_recoverable")
	assert(demo.world.call("_cancel_blueprint_site", empty_site))
	assert(audit.observe(eid)["status"] == &"empty_no_pickup")
	assert(audit.observe(eid)["amount"] == 0 and audit.observe(eid)["expected"] == 3)
	assert(demo.stock.get_amount(INGOT) == 7 and demo.registry.claim_count() == 3)
	print("PASS K: Pre-pickup cancelled site has zero recoverable physical cargo")

	# L — feature switch is fail-closed even after capture; no releases/refunds.
	audit.enable_isolated_custody_audit = false
	assert(audit.observe(sid)["status"] == &"unavailable")
	assert(audit.capture_site(empty_site, empty_pair["staging"], empty_pair["port"]) == 0)
	audit.enable_isolated_custody_audit = true
	assert(audit.observe(sid)["status"] == &"ready_read_only")
	assert(audit.observe(pid)["status"] == &"ready_read_only")
	assert(demo.stock.get_amount(INGOT) == 7 and demo.registry.claim_count() == 3)
	print("PASS L: Turning audit OFF/ON gives no material or authority side effects")
	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame

	# M — completing a real building commits the construction cost, forever
	# ineligible for cancelled-material pickup even if its old staging remains.
	sandbox = Direct.instantiate() as Node3D
	demo = sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services())
	demo.set_process(false)
	demo.world.set_process(false)
	audit = _set_up_audit(sandbox, demo)
	var built: Array[Node3D] = []
	var completed := _place(demo, STORAGE, STORAGE_POS)
	assert(is_instance_valid(completed))
	var completed_pair := _pair(demo, completed)
	var cid: int = audit.capture_site(completed, completed_pair["staging"], completed_pair["port"])
	assert(cid > 0)
	_watch(completed, built)
	_launch(demo, completed, 3, 15)
	_collect(demo, completed_pair["buffer"], 3, 15)
	_deliver(demo, completed, completed_pair["buffer"], 3)
	_begin_work(demo, completed, completed_pair["buffer"])
	_finish(demo, completed.job, built, 0)
	assert(audit.observe(cid)["status"] == &"complete_not_recoverable")
	assert(demo.stock.get_amount(INGOT) == 12 and built.size() == 1)
	assert((completed_pair["buffer"] as InventoryComponent).get_amount(INGOT) == 0)
	print("PASS M: Completed building consumes three ingots; never yields recovery ticket")
	demo.world.call("_destroy_placement_ghost")
	sandbox.free()
	print("ALL 13 CANCELLED SITE CUSTODY E3D5C6C STAGE A TESTS PASSED")
