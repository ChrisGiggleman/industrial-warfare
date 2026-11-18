extends Node3D

const Demo = preload("res://scripts/ui/playable_automatic_construction_drone_sandbox.gd")
const Expansion = preload("res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn")
const StageC = preload("res://scenes/core/playable_automatic_construction_drone_stage_c.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const SPLITTER = preload("res://data/buildings/conveyor_splitter.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const ORE = preload("res://data/items/test_ore.tres")


func _ready() -> void:
	call_deferred("_checks")


func _plan(world: Node, definition: BuildingDefinition, at: Vector3) -> ConstructionSite:
	var site := world.call("_create_blueprint_site", definition, Transform3D(Basis.IDENTITY, at)) as ConstructionSite
	assert(site != null)
	return site


func _checks() -> void:
	var fresh := Demo.new()
	assert(not fresh.enable_building_expansion)
	fresh.free()
	var old_scene := StageC.instantiate() as Node3D
	var old_demo := old_scene.get_node("AutomaticConstructionSandbox") as Demo
	old_demo.enable_building_expansion = true
	add_child(old_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(old_demo.has_verified_services())
	old_demo.set_process(false)
	old_demo.world.set_process(false)
	var old_press := _plan(old_demo.world, PRESS, Vector3(4.5, 0, -3.5))
	assert(old_demo.world.call("_authorize_blueprint_site", old_press))
	assert(not old_demo.is_enrolled_site(old_press) and old_press.is_processing())
	assert(old_demo.registry.claim_count() == 0 and old_demo.stock.get_amount(INGOT) == 15)
	old_scene.free()
	print("PASS A: Expansion default-off; accepted Stage C refuses Press even with switch on")

	var sandbox := Expansion.instantiate() as Node3D
	var demo := sandbox.get_node("AutomaticConstructionSandbox") as Demo
	add_child(sandbox)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(demo.has_verified_services() and demo._expansion_enabled())
	demo.set_process(false)
	var world := demo.world
	world.set_process(false)
	assert(demo._eligible_material_amount(STORAGE) == 3)
	assert(demo._eligible_material_amount(PRESS) == 5)
	assert(demo._eligible_material_amount(SPLITTER) == 0)
	var duplicate := PRESS.duplicate() as BuildingDefinition
	assert(demo._eligible_material_amount(duplicate) == 0)
	demo.enable_building_expansion = false
	assert(demo._eligible_material_amount(PRESS) == 0)
	demo.enable_building_expansion = true
	print("PASS B: Canonical allowlist and explicit scene switch; no same-ID or size-only admission")

	var press := _plan(world, PRESS, Vector3(4.5, 0, -3.5))
	var storage := _plan(world, STORAGE, Vector3(0, 0, -3))
	var splitter := _plan(world, SPLITTER, Vector3(-5, 0, 0))
	assert(press.job.state == ConstructionJob.State.PLANNED and press.is_processing())
	assert(press.job.set_priority(ConstructionJob.Priority.HIGH))
	demo._process(0.1)
	assert(demo.registry.claim_count() == 0 and demo.queue.get_waiting_count() == 0)
	assert(demo.last_tick["action"] == &"waiting" and demo.stock.get_amount(INGOT) == 15)
	print("PASS C: Plans and priority do not enroll or authorize")

	assert(world.call("_authorize_blueprint_site", storage))
	assert(world.call("_authorize_blueprint_site", press))
	assert(world.call("_authorize_blueprint_site", splitter))
	assert(demo.is_enrolled_site(storage) and demo.is_enrolled_site(press))
	assert(not storage.is_processing() and not press.is_processing())
	assert(not demo.is_enrolled_site(splitter) and splitter.is_processing())
	assert(demo.registry.claim_count() == 2 and demo.escrow.held_count() == 0)
	assert(demo.queue.get_waiting_sites() == [press, storage, splitter])
	assert(not world.call("_authorize_blueprint_site", press))
	print("PASS D: Explicit authorization preserves priority queue and transfers only approved site clocks")

	var a := demo.registry.inventory_for_site(press)
	var b := demo.registry.inventory_for_site(storage)
	assert(a != null and b != null and a != b)
	assert(a.max_capacity == 5 and b.max_capacity == 3)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0)
	assert(demo.registry.inventory_for_site(splitter) == null)
	assert(demo.registry.can_receive_drone_delivery(press, a, INGOT, 5))
	assert(not demo.registry.can_receive_drone_delivery(press, a, INGOT, 6))
	assert(not demo.registry.can_receive_drone_delivery(press, a, ORE, 1))
	assert(not demo.registry.can_receive_drone_delivery(press, b, INGOT, 3))
	print("PASS E: Exact empty per-definition staging and receiver custody")

	var entry: Dictionary = {}
	for record: Dictionary in demo._site_entries:
		if (record["site"] as WeakRef).get_ref() == press:
			entry = record
	assert(not entry.is_empty())
	var port := (entry["port"] as WeakRef).get_ref() as BlueprintConstructionStagingInputPort
	var staging := (entry["staging"] as WeakRef).get_ref() as BlueprintConstructionMaterialStaging
	assert(staging.matches_definition(PRESS) and not staging.matches_definition(STORAGE))
	assert(staging.receive_item(INGOT, 5) == 0 and not port.can_accept_belt_item(null, INGOT, 1))
	assert(demo.stock.get_amount(INGOT) == 15 and a.get_total_amount() == 0)
	print("PASS F: No remote or conveyor shortcut to drone-only staging")

	var selection := demo.dispatch.inspect_next()
	assert(selection.get("site") == press and selection.get("amount") == 5)
	assert(demo.supplier.reservation_count() == 0 and demo.stock.get_reserved_amount(INGOT) == 0)
	demo._process(0.1)
	assert(demo.last_tick["action"] == &"launched")
	assert(demo.supplier.reservation_count() == 1 and demo.stock.get_reserved_amount(INGOT) == 5)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0)
	assert(press.job.get_progress() == 0.0 and storage.job.get_progress() == 0.0)
	print("PASS G: Existing dispatcher reserves exact full load without teleporting stock")

	var press_job := press.job
	assert(world.call("_cancel_blueprint_site", press))
	assert(press_job.state == ConstructionJob.State.CANCELLED)
	assert(demo.stock.get_amount(INGOT) == 15 and demo.drone.cargo_amount() == 0)
	assert(a.get_total_amount() == 0 and b.get_total_amount() == 0 and demo.escrow.held_count() == 0)
	assert(demo.registry.has_locked_pair(staging, port))
	print("PASS H: Original cancellation protects empty staging without stock mutation")
	sandbox.free()
	print("ALL 8 PLAYABLE CONSTRUCTION BUILDING EXPANSION E3D5C6A TESTS PASSED")
