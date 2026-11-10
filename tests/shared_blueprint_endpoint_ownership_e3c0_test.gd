extends Node3D

# =============================================================================
# MIXED BLUEPRINT ENDPOINT OWNERSHIP — PHASE E3C0 REGRESSION
# =============================================================================
# E2b belt routes and E3b Storage ports share a single atomic claim broker.
# This scene intentionally does not activate physical building connections.
# No connected-conveyor sandbox flags or Main runtime are changed.

func _site(
	root: Node3D,
	definition: BuildingDefinition,
	position: Vector3,
	yaw_degrees: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	root.add_child(site)
	site.set_process(false)
	site.global_position = position
	site.rotation_degrees.y = yaw_degrees
	return site


func _finish(site: ConstructionSite) -> Node3D:
	var built: Array[Node3D] = []
	site.building_completed.connect(
		func(entity: Node3D) -> void: built.append(entity)
	)
	assert(site.job.authorize())
	assert(site.job.set_availability(true, true, true))
	site._process(site.target_definition.construction_seconds)
	assert(built.size() == 1)
	assert(site.is_queued_for_deletion())
	var real := built[0]
	if real is ConveyorSegment:
		(real.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return real


func _ready() -> void:
	var storage_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var belt_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(storage_def != null and belt_def != null)
	var root := Node3D.new()
	add_child(root)
	var broker := PlannedEndpointClaimBroker.new()
	add_child(broker)
	var routes := PlannedConveyorRouteReservations.new()
	add_child(routes)
	var ports := PlannedBuildingPortReservations.new()
	add_child(ports)
	assert(routes.set_claim_broker(broker))
	assert(ports.set_claim_broker(broker))
	assert(not routes.set_claim_broker(broker))
	assert(not ports.set_claim_broker(broker))
	assert(broker.claim_count() == 0)
	print("PASS A: Both reservation managers join exactly one shared authority")

	var storage := _site(root, storage_def, Vector3.ZERO)
	var incoming := _site(root, belt_def, Vector3(0, 0, 2))
	var next := _site(root, belt_def, Vector3(0, 0, 1))
	var belt_route := routes.reserve_pair(incoming, next)
	assert(belt_route > 0)
	assert(broker.claim_count() == 2)
	assert(broker.is_claimed(incoming, PlannedEndpointClaimBroker.BELT_OUTPUT))
	print("PASS B: Belt-to-belt route claims its outgoing endpoint atomically")

	assert(ports.reserve_pair(storage, incoming, true) == 0)
	assert(ports.claim_count() == 0)
	assert(routes.claim_count() == 2)
	assert(broker.claim_count() == 2)
	print("PASS C: Storage input cannot steal a conveyor output held by E2b")

	assert(routes.release(belt_route))
	assert(broker.claim_count() == 0)
	var storage_input := ports.reserve_pair(storage, incoming, true)
	assert(storage_input > 0)
	assert(broker.claim_count() == 2)
	assert(not broker.owner_of(incoming, "out").is_empty())
	print("PASS D: Released route lets Storage input claim the same belt output")

	assert(routes.reserve_pair(incoming, next) == 0)
	assert(broker.claim_count() == 2)
	assert(ports.is_reserved(storage_input))
	print("PASS E: Belt route cannot steal an output claimed by a Storage port")

	var previous := _site(root, belt_def, Vector3(0, 0, 3))
	var previous_route := routes.reserve_pair(previous, incoming)
	assert(previous_route > 0)
	assert(broker.claim_count() == 4)
	assert(broker.is_claimed(incoming, "in"))
	assert(broker.is_claimed(incoming, "out"))
	assert(broker.owner_of(incoming, "in") != broker.owner_of(incoming, "out"))
	print("PASS F: Incoming and outgoing sides of a transit belt remain independent")

	var outgoing := _site(root, belt_def, Vector3(0, 0, -2))
	var storage_output := ports.reserve_pair(storage, outgoing, false)
	assert(storage_output > 0)
	assert(broker.claim_count() == 6)
	assert(broker.is_claimed(storage, "building_input"))
	assert(broker.is_claimed(storage, "building_output"))
	print("PASS G: Storage input and output independently reserve different belts")

	var competitor := _site(root, belt_def, Vector3(0, 0, 2))
	assert(ports.reserve_pair(storage, competitor, true) == 0)
	assert(ports.reserve_pair(storage, outgoing, false) == 0)
	assert(broker.claim_count() == 6)
	assert(broker.owner_count() == 3)
	print("PASS H: Repeated and competing building-port claims fail closed")

	assert(ports.release(storage_input))
	assert(broker.claim_count() == 4)
	assert(broker.is_claimed(incoming, "in"))
	assert(not broker.is_claimed(incoming, "out"))
	assert(broker.is_claimed(storage, "building_output"))
	assert(routes.reserve_pair(incoming, next) > 0)
	assert(broker.claim_count() == 6)
	print("PASS I: Releasing Storage input restores belt output without clearing other claims")

	# Keep the upstream route and Storage output, then cancel Storage.
	# The outgoing claim releases but unrelated conveyor links survive.
	assert(storage.job.cancel())
	assert(storage.is_queued_for_deletion())
	assert(not ports.is_reserved(storage_output))
	assert(broker.claim_count() == 4)
	assert(routes.is_reserved(previous_route))
	print("PASS J: Storage cancellation releases only its own claim owners")

	assert(incoming.job.cancel())
	assert(broker.claim_count() == 0)
	assert(routes.claim_count() == 0)
	assert(ports.claim_count() == 0)
	print("PASS K: Shared transit-belt cancellation cleans all independent claims")

	var s2 := _site(root, storage_def, Vector3(10, 0, 0))
	var belt2 := _site(root, belt_def, Vector3(10, 0, -2))
	var source2 := _site(root, belt_def, Vector3(10, 0, -1))
	var other_route := routes.reserve_pair(source2, belt2)
	assert(other_route > 0)
	assert(ports.reserve_pair(s2, belt2, false) == 0)
	assert(broker.is_claimed(belt2, "in"))
	assert(routes.release(other_route))
	var other_port := ports.reserve_pair(s2, belt2, false)
	assert(other_port > 0)
	assert(routes.reserve_pair(source2, belt2) == 0)
	print("PASS L: Opposite belt-input contention is exclusive in either claim order")

	assert(not broker.claim_pair(
		belt2, "out", s2, "out", "invalid"
	))
	assert(not broker.claim_pair(
		belt2, "in", belt2, "in", "duplicate"
	))
	assert(not broker.claim_pair(
		s2, "building_input", belt2, "in", "occupied"
	))
	assert(broker.claim_count() == 2)
	print("PASS M: Invalid and occupied atomic claims never partially commit")

	assert(ports.release(other_port))
	assert(broker.claim_count() == 0)
	var released_route := routes.reserve_pair(source2, belt2)
	assert(released_route > 0)
	source2.queue_free()
	await get_tree().process_frame
	assert(not routes.is_reserved(released_route))
	assert(broker.claim_count() == 0)
	print("PASS N: Unexpected unbuilt-site deletion releases shared ownership")

	var s3 := _site(root, storage_def, Vector3(20, 0, 0))
	var belt3 := _site(root, belt_def, Vector3(20, 0, 2))
	var completed_id := ports.reserve_pair(s3, belt3, true)
	assert(completed_id > 0)
	var storage_real := _finish(s3)
	var belt_real := _finish(belt3) as ConveyorSegment
	assert(belt_real != null)
	assert(not ports.get_ready_candidate(completed_id).is_empty())
	assert(broker.claim_count() == 2)
	print("PASS O: Completing both objects retains their exclusive pending claims")

	await get_tree().process_frame
	assert(not is_instance_valid(s3))
	assert(not is_instance_valid(belt3))
	assert(ports.get_ready_candidate(completed_id).get("belt") == belt_real)
	assert(ports.release(completed_id))
	assert(broker.claim_count() == 0)
	assert(belt_real.output_building_port == null)
	print("PASS P: Explicit release after site retirement is safe and nonoperational")

	var s4 := _site(root, storage_def, Vector3(30, 0, 0))
	var belt4 := _site(root, belt_def, Vector3(30, 0, 2))
	var destruction_id := ports.reserve_pair(s4, belt4, true)
	assert(destruction_id > 0)
	var completed_belt := _finish(belt4)
	completed_belt.free()
	assert(not ports.is_reserved(destruction_id))
	assert(broker.claim_count() == 0)
	print("PASS Q: Destroying a completed belt frees both shared endpoint keys")

	assert(routes.claim_count() == 0)
	assert(ports.claim_count() == 0)
	assert(broker.claim_count() == 0)
	assert(broker.owner_count() == 0)
	assert(belt_real.previous_segment == null)
	assert(belt_real.next_segment == null)
	assert(storage_real.get_node("InputPort") is ItemPortComponent)
	print("PASS R: Final cleanup leaves no claims and never connects physical ports")

	print("ALL 18 SHARED BLUEPRINT ENDPOINT OWNERSHIP E3C0 TESTS PASSED")
