extends Node3D

const Demo = preload("res://scripts/ui/isolated_playable_construction_logistics_demo.gd")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")

func _ready() -> void:
	call_deferred("_checks")


func _checks() -> void:
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PlayableConstructionLogisticsDemo") == null)
	main.free()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate() as Node3D
	var gate := sandbox.get_node("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	assert(not gate.enable_isolated_bridge and sandbox.get_node_or_null("PlayableConstructionLogisticsDemo") == null)
	add_child(sandbox)
	var demo := Demo.new()
	sandbox.add_child(demo)
	assert(not demo.start_demo())
	print("PASS A: Main and normal sandbox unchanged; demo explicitly off")
	demo.enable_isolated_playable_demo = true
	assert(demo.start_demo() and not demo.start_demo())
	var world := sandbox.get_node("WorldInteraction")
	world.set_process(false)
	assert(not bool(world.get("blueprint_sandbox_debug_requirements")))
	assert(demo.supply.inventory.get_amount(INGOT) == 4 and not demo.supply.can_provide_item(INGOT))
	print("PASS B: Starter stock counted once; output held and no debug readiness")
	var wrong := world.call("_create_blueprint_site", STORAGE, Transform3D(Basis.IDENTITY, Vector3(-3, 0, 0))) as ConstructionSite
	assert(wrong != null and not demo.prepare_site(wrong))
	var site := world.call("_create_blueprint_site", STORAGE, Transform3D(Basis.IDENTITY, Demo.SITE_POSITION)) as ConstructionSite
	assert(site != null and site.job.state == ConstructionJob.State.PLANNED)
	# Exercise the actual button callback, not only the direct helper.
	demo._prepare_marked_plan()
	assert(demo.site == site and not demo.prepare_site(site))
	assert(demo.staging.get_staged_inventory().get_total_amount() == 0 and demo.registry.claim_count() == 0)
	print("PASS C: Real planned blueprint prepared once; wrong position rejected")
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(site.job.state == ConstructionJob.State.PLANNED and demo.receiver == null)
	assert(not demo.bind_player_belt(null))
	assert(demo.supply.inventory.get_amount(INGOT) == 4)
	print("PASS D: Priority never authorizes or grants intake")
	assert(world.call("_authorize_blueprint_site", site))
	var receiver := demo.receiver
	assert(receiver != null and receiver.matches_attached_site())
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	assert(not receiver.can_accept_item(INGOT) and not receiver.has_bound_unified_route_adapter())
	assert(demo.registry.claim_count() == 1)
	print("PASS E: Existing authorization signal attaches fail-closed real receiver")
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	sandbox.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(timer.is_processing())
	var snap: Dictionary = ConveyorBuildingSnap.get_preview_transform(demo.supply, belt)
	assert(snap.has("transform"))
	belt.global_transform = snap["transform"]
	assert(belt.try_connect_building_port(demo.supply))
	var cargo := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	timer._process(0.01)
	assert(cargo.get_held_item() == null and demo.supply.inventory.get_amount(INGOT) == 4)
	assert(not demo.bind_player_belt(null))
	print("PASS F: Connected actual live belt remains empty until enrollment")
	# Simulate a committed, aligned live belt for which placement did not
	# establish the source snap. The button can recover this exact link.
	assert(belt.disconnect_building_port(demo.supply))
	assert(demo.supply.connected_conveyor == null)
	demo._bind_connected_belt()
	assert(demo.bound_belt == belt and demo.supply.connected_conveyor == belt)
	assert(not demo.bind_player_belt(belt))
	assert(receiver.has_bound_unified_receiver_consolidation())
	assert(belt.output_building_port == receiver)
	assert(demo.supply.can_provide_item(INGOT))
	print("PASS G: Exact empty belt binds once to consolidated receiver")
	timer.travel_interval = 0.05
	var deadline: int = Time.get_ticks_msec() + 6000
	while demo.staging.get_staged_inventory().get_amount(INGOT) < 3 and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	assert(demo.staging.get_staged_inventory().get_amount(INGOT) == 3)
	assert(timer.successful_transfers == 3)
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	print("PASS H: Actual automatic frame-driven conveyor delivers three units, never builds")
	var deadline_extra: int = Time.get_ticks_msec() + 6000
	while cargo.get_held_item() == null and Time.get_ticks_msec() < deadline_extra:
		await get_tree().process_frame
	assert(cargo.get_held_item() == INGOT)
	assert(not receiver.can_accept_belt_item(belt, INGOT))
	assert(demo.supply.inventory.get_amount(INGOT) == 0)
	print("PASS I: Fourth ingot remains on full receiver belt")
	var reservation: int = demo.registry.reserve_for_site(site, demo.escrow)
	assert(reservation > 0 and not receiver.can_accept_belt_item(belt, INGOT))
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(belt))
	print("PASS J: Active escrow closes intake even with buffer space")
	assert(site.job.cancel())
	assert(demo.escrow.held_count() == 0 and demo.staging.get_staged_inventory().get_amount(INGOT) == 3)
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(belt))
	assert(not demo.supply.can_provide_item(INGOT))
	print("PASS K: Cancellation refunds bill and locks delivery")
	assert(cargo.cargo_inventory.get_amount(INGOT) == 1)
	assert(demo.staging.get_staged_inventory().get_amount(INGOT) + cargo.cargo_inventory.get_amount(INGOT) + demo.supply.inventory.get_amount(INGOT) == 4)
	assert(wrong.job.state == ConstructionJob.State.PLANNED)
	assert(not gate.has_bound_driver())
	print("PASS L: All four ingots conserved; separate site and worker readiness untouched")
	# Cancellation queues the scene node for deletion. Exercise multiple
	# subsequent frames before declaring success, including HUD observation.
	var canceled_ref: WeakRef = weakref(site)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(canceled_ref.get_ref() == null)
	assert(not demo._live(demo.site))
	demo._process(0.0)
	assert(demo._label.text.contains("Site ended"))
	assert(demo._label.text.contains("Starter: 0 | Belt: 1 | Staged: 3 / 3"))
	assert(not demo.prepare_site(wrong) and not demo.bind_player_belt(belt))
	assert(demo.staging.get_staged_inventory().get_amount(INGOT) == 3)
	print("PASS M: Post-deletion HUD is safe and enrollment stays closed")
	print("ALL 13 E3D5C5W PLAYABLE CONSTRUCTION LOGISTICS TESTS PASSED")
