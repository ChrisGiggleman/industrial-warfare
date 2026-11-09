extends Node3D

# =============================================================================
# UNIVERSAL CONSTRUCTION SITE — JOB-GATED ACTIVATION REGRESSION
# =============================================================================
# Confirms opt-in ConstructionJob integration for Storage and conveyor sites.
# Existing timed-Storage gameplay is unchanged; the site contains no active
# inventory, belt transport or building ports until a real scene is spawned.

func _ready() -> void:
	var storage := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var conveyor := load("res://data/buildings/conveyor_belt.tres") as BuildingDefinition
	var merger := load("res://data/buildings/conveyor_merger.tres") as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(storage != null and conveyor != null and merger != null and ore != null)

	var storage_site := ConstructionSite.new()
	assert(not storage_site.setup_with_job(storage, -1.0))
	assert(storage_site.setup_with_job(storage, 10.0))
	assert(not storage_site.setup_with_job(storage, 5.0))
	storage_site.position = Vector3(4.0, 0.0, 2.0)
	storage_site.rotation_degrees.y = 90.0
	add_child(storage_site)
	storage_site.set_process(false)
	assert(storage_site.job.state == ConstructionJob.State.PLANNED)
	assert(storage_site.lifecycle.state == ConstructionLifecycle.State.PLANNED)
	assert(storage_site.get_progress() == 0.0)
	print("PASS A: Opt-in job sites start planned and reject invalid/repeated setup")

	assert(storage_site.is_in_group("construction_sites"))
	assert(storage_site.get_node_or_null("ReservedFootprint/CollisionShape3D") != null)
	assert(storage_site.get_node_or_null("ConstructionPlaceholder") != null)
	assert(storage_site.get_planned_port(true) != null)
	assert(storage_site.get_planned_port(false) != null)
	assert(storage_site.get_node_or_null("InventoryComponent") == null)
	assert(storage_site.get_node_or_null("InputPort") == null)
	assert(storage_site.get_node_or_null("OutputPort") == null)
	assert((storage_site.get_node("ConstructionLabel") as Label3D).text == "PLANNED 0%")
	print("PASS B: Planned Storage reserves space and exposes geometry, not inventory")

	var inbound := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(inbound != null)
	add_child(inbound)
	var timer := inbound.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := inbound.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var cargo := inbound.get_node("CargoInventory") as InventoryComponent
	assert(timer != null and transport != null and cargo != null)
	timer.set_process(false)
	var proposed := storage_site.get_planned_belt_transform(inbound, true)
	assert(proposed.has("transform"))
	inbound.global_transform = proposed["transform"]
	var found := PlannedConveyorPortFinder.find_nearest_preview(
		inbound, storage_site.get_planned_port(true).global_position
	)
	assert(found.get("site") == storage_site)
	assert(bool(found.get("input_side", false)))
	assert(storage_site.reserve_conveyor(inbound, true))
	assert(not storage_site.reserve_conveyor(inbound, true))
	assert(inbound.output_building_port == null)
	print("PASS C: A blueprint port can be reserved without forming a live link")

	var supply := InventoryComponent.new()
	supply.max_capacity = 10
	add_child(supply)
	assert(supply.add_item(ore, 2) == 2)
	assert(transport.try_receive_from_inventory(supply, ore))
	timer._process(1.1)
	assert(supply.get_amount(ore) == 1)
	assert(cargo.get_amount(ore) == 1)
	assert(inbound.output_building_port == null)
	assert(storage_site.get_node_or_null("InventoryComponent") == null)
	print("PASS D: Blueprint cargo waits on the real belt without entering the site")

	assert(storage_site.job.authorize())
	assert(storage_site.job.state == ConstructionJob.State.QUEUED)
	storage_site._process(100.0)
	assert(is_zero_approx(storage_site.get_progress()))
	assert((storage_site.get_node("ConstructionLabel") as Label3D).text == "QUEUED 0%")
	print("PASS E: Authorized but unpowered Storage stays queued and inactive")

	assert(storage_site.job.set_availability(true, true, true))
	assert(storage_site.job.state == ConstructionJob.State.CONSTRUCTING)
	storage_site._process(3.0)
	assert(is_equal_approx(storage_site.get_progress(), 0.3))
	assert((storage_site.get_node("ConstructionLabel") as Label3D).text == "CONSTRUCTING 30%")
	print("PASS F: Authorized Storage advances using shared construction work time")

	assert(storage_site.job.set_availability(false, true, true))
	assert(storage_site.job.state == ConstructionJob.State.PAUSED)
	storage_site._process(100.0)
	assert(is_equal_approx(storage_site.get_progress(), 0.3))
	assert((storage_site.get_node("ConstructionLabel") as Label3D).text == "PAUSED 30%")
	assert(cargo.get_amount(ore) == 1)
	print("PASS G: A power pause freezes progress and leaves cargo untouched")

	var built_storage: Array[Node3D] = []
	storage_site.building_completed.connect(
		func(building: Node3D) -> void: built_storage.append(building)
	)
	assert(storage_site.job.set_availability(true, true, true))
	storage_site._process(7.0)
	assert(storage_site.job.is_complete())
	assert(built_storage.size() == 1)
	assert(storage_site.is_queued_for_deletion())
	var completed_storage := built_storage[0]
	var input_port := completed_storage.get_node("InputPort") as ItemPortComponent
	var inventory := completed_storage.get_node("InventoryComponent") as InventoryComponent
	assert(input_port != null and inventory != null)
	assert(inbound.output_building_port == input_port)
	assert(input_port.connected_conveyor == inbound)
	assert(completed_storage.global_position.distance_to(Vector3(4, 0, 2)) < 0.01)
	assert(is_equal_approx(completed_storage.rotation_degrees.y, 90.0))
	storage_site._process(100.0)
	assert(built_storage.size() == 1)
	print("PASS H: Completion activates Storage and exactly one reserved physical link")

	timer._process(0.01)
	assert(supply.get_amount(ore) == 1)
	assert(cargo.get_amount(ore) == 0)
	assert(inventory.get_amount(ore) == 1)
	assert(supply.get_amount(ore) + cargo.get_amount(ore)
		+ inventory.get_amount(ore) == 2)
	print("PASS I: Waiting ore reaches completed Storage with total items conserved")

	var belt_site := ConstructionSite.new()
	assert(belt_site.setup_with_job(conveyor, 2.0, false, false, false))
	belt_site.position = Vector3(-6.0, 0.0, 3.0)
	belt_site.rotation_degrees.y = 90.0
	add_child(belt_site)
	belt_site.set_process(false)
	assert(belt_site.get_node_or_null("PlannedInputEndpoint") is Marker3D)
	assert(belt_site.get_node_or_null("PlannedOutputEndpoint") is Marker3D)
	assert(belt_site.get_node_or_null("CargoInventory") == null)
	assert(belt_site.get_node_or_null("ConveyorTransportTimer") == null)
	assert(belt_site.get_node_or_null("ConveyorTransportComponent") == null)
	var template := conveyor.building_scene.instantiate() as ConveyorSegment
	assert(template != null)
	assert((belt_site.get_node("PlannedInputEndpoint") as Marker3D).transform.is_equal_approx(
		(template.get_node("InputEndpoint") as Marker3D).transform
	))
	assert((belt_site.get_node("PlannedOutputEndpoint") as Marker3D).transform.is_equal_approx(
		(template.get_node("OutputEndpoint") as Marker3D).transform
	))
	template.free()
	print("PASS J: Planned conveyor reserves directional endpoints without live transport")

	var built_belts: Array[Node3D] = []
	belt_site.building_completed.connect(
		func(building: Node3D) -> void: built_belts.append(building)
	)
	assert(belt_site.job.authorize())
	assert(belt_site.job.state == ConstructionJob.State.CONSTRUCTING)
	belt_site._process(1.0)
	assert(is_equal_approx(belt_site.get_progress(), 0.5))
	assert(built_belts.is_empty())
	belt_site._process(1.0)
	assert(built_belts.size() == 1)
	var built_belt := built_belts[0] as ConveyorSegment
	assert(built_belt != null)
	assert(built_belt.get_node_or_null("CargoInventory") is InventoryComponent)
	assert(built_belt.get_node_or_null("ConveyorTransportTimer") is ConveyorTransportTimer)
	assert(built_belt.get_node_or_null("InputEndpoint") is Marker3D)
	assert(built_belt.get_node_or_null("OutputEndpoint") is Marker3D)
	assert(built_belt.global_position.distance_to(Vector3(-6, 0, 3)) < 0.01)
	assert(is_equal_approx(built_belt.rotation_degrees.y, 90.0))
	assert(built_belt.can_demolish_safely())
	print("PASS K: Timed conveyor becomes a real functional segment only on completion")

	var merger_site := ConstructionSite.new()
	assert(merger_site.setup_with_job(merger, 5.0))
	merger_site.position = Vector3(13.0, 0.0, -4.0)
	add_child(merger_site)
	merger_site.set_process(false)
	for marker_name: String in [
		"PlannedInputPortA", "PlannedInputPortB",
		"PlannedInputPortC", "PlannedOutputPort"
	]:
		assert(merger_site.get_node_or_null(marker_name) is Marker3D)
	assert(merger_site.get_node_or_null("InputAInventory") == null)
	assert(merger_site.get_node_or_null("MergerComponent") == null)
	print("PASS L: Multi-input merger blueprint reproduces every planned port")

	assert(merger_site.job.cancel())
	assert(merger_site.is_queued_for_deletion())
	assert(not merger_site.job.authorize())
	assert(not merger_site.is_completed())
	print("PASS M: Cancelling a planned multiport structure retires its footprint")

	var queued_site := ConstructionSite.new()
	assert(queued_site.setup_with_job(storage, 8.0))
	queued_site.position = Vector3(17.0, 0.0, -5.0)
	add_child(queued_site)
	queued_site.set_process(false)
	assert(queued_site.job.authorize())
	assert(queued_site.job.state == ConstructionJob.State.QUEUED)
	assert(queued_site.job.cancel())
	queued_site._process(100.0)
	assert(queued_site.is_queued_for_deletion())
	assert(not queued_site.is_completed())
	print("PASS N: Cancelling queued construction never spawns an active building")

	var paused_site := ConstructionSite.new()
	assert(paused_site.setup_with_job(storage, 10.0))
	paused_site.position = Vector3(21.0, 0.0, -5.0)
	add_child(paused_site)
	paused_site.set_process(false)
	assert(paused_site.job.set_availability(true, true, true))
	assert(paused_site.job.authorize())
	paused_site._process(4.0)
	assert(paused_site.job.set_availability(false, true, true))
	assert(paused_site.job.state == ConstructionJob.State.PAUSED)
	assert(paused_site.job.cancel())
	assert(paused_site.is_queued_for_deletion())
	paused_site._process(100.0)
	assert(not paused_site.is_completed())
	assert(is_equal_approx(paused_site.get_progress(), 0.4))
	print("PASS O: Cancelling paused work prevents late activation or lost work state")

	print("ALL 15 UNIVERSAL CONSTRUCTION SITE TESTS PASSED")
