extends Node3D
## Stage A checks the actual WorldInteraction click, not a second construction driver.
const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Direct = preload("res://scenes/core/playable_direct_build_authorization_e3d5c6b.tscn")
const Expansion = preload("res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const SPLITTER = preload("res://data/buildings/conveyor_splitter.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const STORAGE_POS := Vector3(0, 0, -3)
const PRESS_POS := Vector3(4.5, 0, -3.5)
const HIGH_POS := Vector3(4, 0, -1)
const LOW_POS := Vector3(-5, 0, 0)
const FAILURE_POS := Vector3(-5, 0, 4)


func _ready() -> void:
	call_deferred("_checks")


func _sites(scope: Node3D) -> Array[ConstructionSite]:
	var sites: Array[ConstructionSite] = []
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if node is ConstructionSite and node.get_parent() == scope and not node.is_queued_for_deletion():
			sites.append(node as ConstructionSite)
	return sites


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


func _checks() -> void:
	var standalone := Demo.new()
	assert(not standalone.enable_direct_build_authorization)
	standalone.free()
	var old := Expansion.instantiate() as Node3D
	var old_demo := old.get_node("AutomaticConstructionSandbox") as Demo
	old_demo.enable_direct_build_authorization = true
	add_child(old)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(old_demo.has_verified_services() and old_demo._expansion_enabled())
	assert(not old_demo.world.call("_direct_build_scope"))
	assert(not old_demo.can_authorize_direct_definition(STORAGE, old_demo.world))
	old_demo.set_process(false)
	old_demo.world.set_process(false)
	old.free()
	print("PASS A: Switch defaults off and accepted expansion cannot activate direct authorization")

	var off := Direct.instantiate() as Node3D
	var off_demo := off.get_node("AutomaticConstructionSandbox") as Demo
	off_demo.enable_direct_build_authorization = false
	off_demo.enable_automatic_sandbox = false
	add_child(off)
	var off_world := off.get_node("WorldInteraction")
	off_world.set_process(false)
	assert(off_world.call("_direct_build_scope"))
	assert(not bool(off_world.get("blueprint_sandbox_debug_requirements")))
	_select(off_world, STORAGE)
	await get_tree().physics_frame
	await get_tree().process_frame
	_point_at(off_world, STORAGE_POS)
	off_world.set("placement_is_valid", true)
	off_world.call("_try_place_object")
	assert(_sites(off).is_empty())
	assert(not off_demo.has_verified_services())
	off_world.call("_destroy_placement_ghost")
	off.free()
	print("PASS B: Disabled exact scene blocks legacy click fallback and debug readiness")

	var sandbox := Direct.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo._direct_build_enabled())
	demo.set_process(false)
	var world := demo.world
	world.set_process(false)
	assert(world.get("_construction_priority_queue") == demo.queue)
	assert(not bool(world.get("enable_blueprint_route_tool")))
	assert(not bool(world.get("enable_connected_conveyor_blueprints")))
	assert(not bool(world.get("blueprint_sandbox_debug_requirements")))
	assert(demo.can_authorize_direct_definition(STORAGE, world))
	assert(demo.can_authorize_direct_definition(PRESS, world))
	assert(not demo.can_authorize_direct_definition(SPLITTER, world))
	assert(not demo.can_authorize_direct_definition(PRESS.duplicate() as BuildingDefinition, world))
	assert(not demo.can_authorize_direct_definition(STORAGE, self))
	print("PASS C: Exact scope, original queue, canonical definitions and verified authority")

	_select(world, SPLITTER)
	_click(world, LOW_POS)
	assert(_sites(sandbox).is_empty() and demo.queue.get_waiting_count() == 0)
	world.set("blueprint_mode_active", true)
	_click(world, LOW_POS)
	assert(_sites(sandbox).is_empty())
	world.set("blueprint_mode_active", false)
	_select(world, STORAGE)
	# A previously valid preview must not be reused after cursor/ground loss.
	_point_at(world, STORAGE_POS)
	world.call("_update_placement_preview")
	assert(bool(world.get("placement_is_valid")))
	_click(world, Vector3(100, 0, 100))
	assert(not bool(world.get("placement_is_valid")))
	assert(_sites(sandbox).is_empty() and demo.queue.get_waiting_count() == 0)
	_click(world, demo.storage.global_position)
	assert(_sites(sandbox).is_empty() and demo.registry.claim_count() == 0)
	print("PASS D: Unsupported, stale off-ground and occupied footprint clicks fail closed")

	_click(world, STORAGE_POS)
	var first := _at(sandbox, STORAGE_POS)
	assert(is_instance_valid(first) and first.job != null)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.priority == ConstructionJob.Priority.NORMAL)
	assert(demo.is_enrolled_site(first) and not first.is_processing())
	assert(is_equal_approx(first.construction_duration, 10.0))
	assert(first.job.get_wait_reasons().size() == 3)
	assert(first.job.get_progress() == 0.0)
	assert(demo.queue.get_waiting_sites() == [first])
	# Second click in the same frame must not depend on physics sync.
	_click(world, STORAGE_POS)
	assert(_sites(sandbox).size() == 1 and demo.registry.claim_count() == 1)
	assert(not world.call("_authorize_blueprint_site", first))
	print("PASS E: Real direct Storage click queues once at Normal without E; duplicates refused")

	_select(world, PRESS)
	_click(world, PRESS_POS)
	var second := _at(sandbox, PRESS_POS)
	assert(is_instance_valid(second) and second.job != null)
	assert(second.job.state == ConstructionJob.State.QUEUED and second.job.priority == ConstructionJob.Priority.NORMAL)
	assert(is_equal_approx(second.construction_duration, 18.0))
	assert(demo.is_enrolled_site(second) and not second.is_processing())
	assert(demo.queue.get_waiting_sites() == [first, second])
	var a := demo.registry.inventory_for_site(first)
	var b := demo.registry.inventory_for_site(second)
	assert(a != null and b != null and a != b)
	assert(a.max_capacity == 3 and b.max_capacity == 5)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.escrow.held_count() == 0)
	assert(demo.drone.cargo_amount() == 0 and demo.scheduler.get_active_count() == 0)
	print("PASS F: Direct Press shares Normal FIFO, original bill/duration and empty owned staging")

	world.set("blueprint_mode_active", true)
	_select(world, STORAGE)
	_click(world, HIGH_POS)
	var high := _at(sandbox, HIGH_POS)
	assert(is_instance_valid(high) and high.job.state == ConstructionJob.State.PLANNED)
	assert(high.is_processing() and not demo.is_enrolled_site(high))
	world.set("_blueprint_area_selection_mode", true)
	var selected: Array[ConstructionSite] = [high]
	world.set("_area_selected_sites", selected)
	assert(world.call("_set_selected_blueprint_priority", ConstructionJob.Priority.HIGH) == 1)
	assert(high.job.state == ConstructionJob.State.PLANNED and demo.registry.claim_count() == 2)
	assert(demo.queue.get_waiting_sites() == [first, second])
	assert(world.call("_authorize_selected_blueprint_sites") == 1)
	assert(demo.is_enrolled_site(high) and not high.is_processing())
	world.set("_blueprint_area_selection_mode", false)
	print("PASS G: Blueprint click and priority remain PLANNED until explicit selected authorization")

	_click(world, LOW_POS)
	var low := _at(sandbox, LOW_POS)
	assert(is_instance_valid(low) and low.job.state == ConstructionJob.State.PLANNED)
	assert(low.job.set_priority(ConstructionJob.Priority.LOW))
	assert(demo.queue.get_waiting_sites() == [high, first, second])
	assert(world.call("_authorize_all_blueprint_sites") == 1)
	assert(demo.is_enrolled_site(low) and not low.is_processing())
	assert(demo.queue.get_waiting_sites() == [high, first, second, low])
	assert(demo.registry.claim_count() == 4)
	print("PASS H: Ctrl+E batch authorization shares High/Normal FIFO/Low queue")

	world.set("blueprint_mode_active", false)
	# Force synchronous enrollment failure after the original authorization.
	# Capture the original job/site while the real listener is disconnected.
	var observed: Array[ConstructionSite] = []
	var capture := func(site: ConstructionSite) -> void: observed.append(site)
	world.disconnect(&"blueprint_site_authorized", demo._on_player_authorized)
	assert(world.connect(&"blueprint_site_authorized", capture) == OK)
	_click(world, FAILURE_POS)
	assert(observed.size() == 1)
	var rejected := observed[0]
	assert(rejected.job.state == ConstructionJob.State.CANCELLED and rejected.is_queued_for_deletion())
	assert(demo.queue.get_waiting_sites() == [high, first, second, low])
	assert(demo.registry.claim_count() == 4 and _sites(sandbox).size() == 4)
	world.disconnect(&"blueprint_site_authorized", capture)
	assert(world.connect(&"blueprint_site_authorized", demo._on_player_authorized) == OK)
	print("PASS I: Failed synchronous enrollment cancels original job without legacy placement")

	demo.enable_player_site_enrollment = false
	_click(world, FAILURE_POS)
	assert(_sites(sandbox).size() == 4 and demo.queue.get_waiting_count() == 4)
	demo.enable_player_site_enrollment = true
	demo.enable_direct_build_authorization = false
	_click(world, FAILURE_POS)
	assert(_sites(sandbox).size() == 4 and demo.queue.get_waiting_count() == 4)
	demo.enable_direct_build_authorization = true
	assert(demo.has_verified_services())
	print("PASS J: Disabled admission after startup cannot fall back or create orphan jobs")

	var selection := demo.dispatch.inspect_next()
	assert(selection.get("site") == high and selection.get("amount") == 3)
	demo._process(0.1)
	assert(demo.last_tick.get("action") == &"launched")
	assert(demo.supplier.reservation_count() == 1 and demo.stock.get_reserved_amount(INGOT) == 3)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(demo.escrow.held_count() == 0 and demo.scheduler.get_active_count() == 0)
	for site: ConstructionSite in [first, second, high, low]:
		assert(site.job.get_progress() == 0.0)
		assert(demo.registry.inventory_for_site(site).get_total_amount() == 0)
	print("PASS K: One existing dispatcher reserves exact load; no instant building, stock or time bypass")
	world.call("_destroy_placement_ghost")
	sandbox.free()
	print("ALL 11 PLAYABLE DIRECT BUILD AUTHORIZATION E3D5C6B STAGE A TESTS PASSED")
