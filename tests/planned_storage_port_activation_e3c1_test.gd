extends Node3D

# =============================================================================
# PLANNED STORAGE PORT ACTIVATION — PHASE E3C1 REGRESSION
# =============================================================================
# Connect real Storage and belt ports ONLY after both jobs complete.
# Check mixed E2b/E3b broker claims, independent build order, failure
# recovery and actual ore conservation across a complete factory path.
# No changes to Main, WorldInteraction or sandbox Blueprint Mode.

func _site(
	root: Node3D,
	definition: BuildingDefinition,
	position: Vector3,
	yaw: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	root.add_child(site)
	site.set_process(false)
	site.global_position = position
	site.rotation_degrees.y = yaw
	return site


func _finish(site: ConstructionSite) -> Node3D:
	var results: Array[Node3D] = []
	site.building_completed.connect(
		func(entity: Node3D) -> void: results.append(entity)
	)
	assert(site.job.authorize())
	assert(site.job.set_availability(true, true, true))
	site._process(site.target_definition.construction_seconds)
	assert(results.size() == 1)
	assert(site.job.is_complete())
	var entity: Node3D = results[0]
	if entity is ConveyorSegment:
		(entity.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return entity


func _cargo(belt: ConveyorSegment) -> InventoryComponent:
	return belt.get_node("CargoInventory") as InventoryComponent


func _ready() -> void:
	var storage_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(storage_def != null and belt_def != null and ore != null)
	var root := Node3D.new()
	add_child(root)
	var broker := PlannedEndpointClaimBroker.new()
	add_child(broker)
	var ports := PlannedBuildingPortReservations.new()
	add_child(ports)
	var routes := PlannedConveyorRouteReservations.new()
	add_child(routes)
	assert(ports.set_claim_broker(broker))
	assert(routes.set_claim_broker(broker))
	var port_activator := PlannedBuildingPortActivator.new()
	add_child(port_activator)
	assert(port_activator.bind_registry(ports))
	assert(not port_activator.bind_registry(ports))
	assert(not port_activator.try_commit(99999))
	var route_activator := PlannedConveyorRouteActivator.new()
	add_child(route_activator)
	assert(route_activator.bind_registry(routes))
	var committed: Array[int] = []
	port_activator.connection_committed.connect(
		func(id: int, _building: Node3D, _belt: ConveyorSegment, _input: bool) -> void:
			committed.append(id)
	)
	print("PASS A: Physical Storage activator and both registries share one broker")

	var storage_site := _site(root, storage_def, Vector3.ZERO)
	var inbound_site := _site(root, belt_def, Vector3(0, 0, 2))
	var outbound_site := _site(root, belt_def, Vector3(0, 0, -2))
	var upstream_site := _site(root, belt_def, Vector3(0, 0, 3))
	var input_id := ports.reserve_pair(storage_site, inbound_site, true)
	var output_id := ports.reserve_pair(storage_site, outbound_site, false)
	var upstream_id := routes.reserve_pair(upstream_site, inbound_site)
	assert(input_id > 0 and output_id > input_id and upstream_id > 0)
	assert(broker.claim_count() == 6)
	assert(not port_activator.try_commit(input_id))
	assert(not port_activator.try_commit(output_id))
	assert(inbound_site.get_node_or_null("CargoInventory") == null)
	print("PASS B: Two Storage ports and upstream belt reserve without transport")

	var storage := _finish(storage_site)
	var input_port := storage.get_node("InputPort") as ItemPortComponent
	var output_port := storage.get_node("OutputPort") as ItemPortComponent
	var inventory := storage.get_node("InventoryComponent") as InventoryComponent
	assert(input_port.connected_conveyor == null)
	assert(output_port.connected_conveyor == null)
	assert(broker.claim_count() == 6)
	print("PASS C: Storage-first completion leaves all unfinished routes pending")

	var inbound := _finish(inbound_site) as ConveyorSegment
	assert(inbound != null)
	assert(inbound.output_building_port == input_port)
	assert(input_port.connected_conveyor == inbound)
	assert(inbound.previous_segment == null)
	assert(ports.is_reserved(output_id))
	assert(broker.claim_count() == 4)
	assert(committed.count(input_id) == 1)
	print("PASS D: Completed inbound belt activates Storage input only")

	var outbound := _finish(outbound_site) as ConveyorSegment
	assert(outbound != null)
	assert(outbound.input_building_port == output_port)
	assert(output_port.connected_conveyor == outbound)
	assert(broker.claim_count() == 2)
	assert(committed.count(output_id) == 1)
	print("PASS E: Storage output completes independently and claims release")

	var upstream := _finish(upstream_site) as ConveyorSegment
	assert(upstream != null)
	assert(upstream.next_segment == inbound)
	assert(inbound.previous_segment == upstream)
	assert(broker.claim_count() == 0)
	assert(routes.claim_count() == 0 and ports.claim_count() == 0)
	assert(not port_activator.try_commit(input_id))
	print("PASS F: Mixed upstream conveyor and both Storage ports activate once")

	assert(_cargo(upstream).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(upstream))
	assert(_cargo(upstream).get_amount(ore) == 0)
	assert(_cargo(inbound).get_amount(ore) == 1)
	assert(ConveyorBuildingTransfer.try_unload_from_belt(inbound))
	assert(_cargo(inbound).get_amount(ore) == 0)
	assert(inventory.get_amount(ore) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(outbound))
	assert(inventory.get_amount(ore) == 0)
	assert(_cargo(outbound).get_amount(ore) == 1)
	print("PASS G: Ore reaches Storage and departs via real reciprocal port links")

	assert(inventory.add_item(ore, 1) == 1)
	assert(not ConveyorBuildingTransfer.try_load_into_belt(outbound))
	assert(inventory.get_amount(ore) == 1)
	assert(_cargo(outbound).get_amount(ore) == 1)
	var sink := InventoryComponent.new()
	sink.max_capacity = 10
	add_child(sink)
	assert(_cargo(outbound).transfer_to(sink, ore, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(outbound))
	assert(inventory.get_amount(ore) == 0)
	assert(_cargo(outbound).get_amount(ore) == 1)
	assert(sink.get_amount(ore) == 1)
	print("PASS H: Full output belt blocks loading without losing either ore")

	var belt_first_site := _site(root, storage_def, Vector3(10, 0, 0))
	var belt_first_plan := _site(root, belt_def, Vector3(10, 0, 2))
	var belt_first_id := ports.reserve_pair(
		belt_first_site, belt_first_plan, true
	)
	assert(belt_first_id > 0)
	var belt_first := _finish(belt_first_plan) as ConveyorSegment
	assert(belt_first.output_building_port == null)
	assert(_cargo(belt_first).add_item(ore, 1) == 1)
	assert(not ConveyorBuildingTransfer.try_unload_from_belt(belt_first))
	assert(_cargo(belt_first).get_amount(ore) == 1)
	var storage_second := _finish(belt_first_site)
	assert(belt_first.output_building_port == storage_second.get_node("InputPort"))
	assert(ConveyorBuildingTransfer.try_unload_from_belt(belt_first))
	assert(_cargo(belt_first).get_amount(ore) == 0)
	assert(
		(storage_second.get_node("InventoryComponent") as InventoryComponent).get_amount(ore)
		== 1
	)
	print("PASS I: Belt-first incoming ore waits until Storage construction completes")

	var output_first_site := _site(root, storage_def, Vector3(20, 0, 0))
	var output_first_plan := _site(root, belt_def, Vector3(20, 0, -2))
	var output_first_id := ports.reserve_pair(
		output_first_site, output_first_plan, false
	)
	assert(output_first_id > 0)
	var output_first_belt := _finish(output_first_plan) as ConveyorSegment
	assert(output_first_belt.input_building_port == null)
	assert(not ConveyorBuildingTransfer.try_load_into_belt(output_first_belt))
	var output_second_storage := _finish(output_first_site)
	assert(output_first_belt.input_building_port
		== output_second_storage.get_node("OutputPort"))
	var output_second_inventory := (
		output_second_storage.get_node("InventoryComponent") as InventoryComponent
	)
	assert(output_second_inventory.add_item(ore, 1) == 1)
	assert(ConveyorBuildingTransfer.try_load_into_belt(output_first_belt))
	assert(output_second_inventory.get_amount(ore) == 0)
	assert(_cargo(output_first_belt).get_amount(ore) == 1)
	print("PASS J: Belt-first output activates only when real Storage exists")

	var rotated_site := _site(
		root, storage_def, Vector3(30, 0, 10), 90.0
	)
	var rotation_basis := rotated_site.global_transform.basis
	var rotated_in_site := _site(
		root, belt_def,
		rotated_site.global_position + rotation_basis * Vector3(0, 0, 2),
		90.0
	)
	var rotated_out_site := _site(
		root, belt_def,
		rotated_site.global_position + rotation_basis * Vector3(0, 0, -2),
		90.0
	)
	assert(ports.reserve_pair(rotated_site, rotated_in_site, true) > 0)
	assert(ports.reserve_pair(rotated_site, rotated_out_site, false) > 0)
	var rotated_out := _finish(rotated_out_site) as ConveyorSegment
	var rotated_in := _finish(rotated_in_site) as ConveyorSegment
	assert(rotated_in.output_building_port == null)
	var rotated_storage := _finish(rotated_site)
	assert(rotated_in.output_building_port == rotated_storage.get_node("InputPort"))
	assert(rotated_out.input_building_port == rotated_storage.get_node("OutputPort"))
	assert(ports.claim_count() == 0)
	print("PASS K: Rotated Storage commits independent ports after belts complete")

	var moved_storage_site := _site(root, storage_def, Vector3(40, 0, 0))
	var moved_belt_site := _site(root, belt_def, Vector3(40, 0, 2))
	var moved_id := ports.reserve_pair(moved_storage_site, moved_belt_site, true)
	assert(moved_id > 0)
	var moved_storage := _finish(moved_storage_site)
	moved_belt_site.position.x += 0.25
	var moved_belt := _finish(moved_belt_site) as ConveyorSegment
	assert(moved_belt.output_building_port == null)
	assert(ports.is_reserved(moved_id))
	assert(not port_activator.try_commit(moved_id))
	moved_belt.position.x -= 0.25
	assert(port_activator.try_commit(moved_id))
	assert(moved_belt.output_building_port == moved_storage.get_node("InputPort"))
	print("PASS L: Misaligned completion leaves claim pending until corrected")

	var occupied_site := _site(root, storage_def, Vector3(50, 0, 0))
	var occupied_belt_site := _site(root, belt_def, Vector3(50, 0, 2))
	var occupied_id := ports.reserve_pair(occupied_site, occupied_belt_site, true)
	assert(occupied_id > 0)
	var occupied_storage := _finish(occupied_site)
	var occupied_port := occupied_storage.get_node("InputPort") as ItemPortComponent
	var dummy := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(dummy != null)
	root.add_child(dummy)
	(dummy.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	var preview := ConveyorBuildingSnap.get_preview_transform(occupied_port, dummy)
	assert(preview.has("transform"))
	dummy.global_transform = preview["transform"]
	assert(dummy.try_connect_building_port(occupied_port))
	var blocked_belt := _finish(occupied_belt_site) as ConveyorSegment
	assert(blocked_belt.output_building_port == null)
	assert(ports.is_reserved(occupied_id))
	assert(not port_activator.try_commit(occupied_id))
	assert(dummy.disconnect_building_port(occupied_port))
	assert(port_activator.try_commit(occupied_id))
	assert(blocked_belt.output_building_port == occupied_port)
	print("PASS M: Occupied real Storage port cannot be stolen or double-linked")

	var occupied_belt_storage := _site(root, storage_def, Vector3(60, 0, 0))
	var occupied_belt_plan := _site(root, belt_def, Vector3(60, 0, 2))
	var occupied_belt_id := ports.reserve_pair(
		occupied_belt_storage, occupied_belt_plan, true
	)
	assert(occupied_belt_id > 0)
	var output_busy := _finish(occupied_belt_plan) as ConveyorSegment
	var other_belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(other_belt != null)
	root.add_child(other_belt)
	output_busy.next_segment = other_belt
	var output_busy_storage := _finish(occupied_belt_storage)
	assert(output_busy.output_building_port == null)
	assert(ports.is_reserved(occupied_belt_id))
	output_busy.next_segment = null
	assert(port_activator.try_commit(occupied_belt_id))
	assert(output_busy.output_building_port == output_busy_storage.get_node("InputPort"))
	print("PASS N: Occupied conveyor output rejects deferred Storage activation")

	var wrong_direction_storage := _site(root, storage_def, Vector3(70, 0, 0))
	var wrong_direction_belt := _site(root, belt_def, Vector3(70, 0, -2))
	var wrong_id := ports.reserve_pair(
		wrong_direction_storage, wrong_direction_belt, false
	)
	assert(wrong_id > 0)
	var wrong_storage := _finish(wrong_direction_storage)
	var wrong_port := wrong_storage.get_node("OutputPort") as ItemPortComponent
	wrong_port.direction = ItemPortComponent.PortDirection.INPUT
	var wrong_belt := _finish(wrong_direction_belt) as ConveyorSegment
	assert(wrong_belt.input_building_port == null)
	assert(ports.is_reserved(wrong_id))
	assert(not port_activator.try_commit(wrong_id))
	wrong_port.direction = ItemPortComponent.PortDirection.OUTPUT
	assert(port_activator.try_commit(wrong_id))
	assert(wrong_port.connected_conveyor == wrong_belt)
	print("PASS O: Incorrect real port direction fails closed until restored")

	var cancel_site := _site(root, storage_def, Vector3(80, 0, 0))
	var cancel_plan := _site(root, belt_def, Vector3(80, 0, 2))
	var cancel_id := ports.reserve_pair(cancel_site, cancel_plan, true)
	assert(cancel_id > 0)
	assert(cancel_plan.job.cancel())
	assert(not ports.is_reserved(cancel_id))
	assert(not port_activator.try_commit(cancel_id))
	assert(broker.claim_count() == 0)
	print("PASS P: Cancelling a pending belt releases its Storage connection")

	var lost_storage_site := _site(root, storage_def, Vector3(90, 0, 0))
	var lost_belt_site := _site(root, belt_def, Vector3(90, 0, 2))
	var lost_id := ports.reserve_pair(lost_storage_site, lost_belt_site, true)
	assert(lost_id > 0)
	var lost_belt := _finish(lost_belt_site)
	lost_belt.free()
	assert(not ports.is_reserved(lost_id))
	assert(not port_activator.try_commit(lost_id))
	var lost_storage_real := _finish(lost_storage_site)
	assert((lost_storage_real.get_node("InputPort") as ItemPortComponent).connected_conveyor == null)
	print("PASS Q: Destroying a completed endpoint prevents later activation")

	await get_tree().process_frame
	assert(broker.claim_count() == 0)
	assert(ports.claim_count() == 0 and routes.claim_count() == 0)
	assert(committed.count(input_id) == 1)
	assert(committed.count(output_id) == 1)
	storage.free()
	assert(inbound.output_building_port == null)
	assert(outbound.input_building_port == null)
	assert(_cargo(outbound).get_amount(ore) == 1)
	assert(sink.get_amount(ore) == 1)
	print("PASS R: Cleanup breaks reciprocal links without deleting buffered cargo")

	print("ALL 18 PLANNED STORAGE PORT ACTIVATION E3C1 TESTS PASSED")
