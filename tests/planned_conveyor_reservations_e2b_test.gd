extends Node3D

# =============================================================================
# PLANNED CONVEYOR ROUTE CLAIMS — PHASE E2B REGRESSION
# =============================================================================
# Connections remain uncommitted. Tests exclusive endpoint ownership,
# either construction order, cancellation, geometry revalidation and cleanup.

func _make_site(
	root: Node3D, definition: BuildingDefinition,
	at_position: Vector3, yaw: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition, false, false, false))
	root.add_child(site)
	site.set_process(false)
	site.position = at_position
	site.rotation_degrees.y = yaw
	return site


func _complete(site: ConstructionSite) -> ConveyorSegment:
	var created: Array[Node3D] = []
	site.building_completed.connect(
		func(entity: Node3D) -> void: created.append(entity)
	)
	assert(site.job.authorize())
	site._process(2.0)
	assert(site.job.is_complete())
	assert(created.size() == 1)
	var belt := created[0] as ConveyorSegment
	assert(belt != null)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _ready() -> void:
	var definition := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(definition != null)
	var root := Node3D.new()
	add_child(root)
	var registry := PlannedConveyorRouteReservations.new()
	add_child(registry)
	var ready_ids: Array[int] = []
	registry.reservation_ready.connect(
		func(reservation_id: int) -> void: ready_ids.append(reservation_id)
	)

	var a := _make_site(root, definition, Vector3(0, 0, 0))
	var b := _make_site(root, definition, Vector3(0, 0, -1))
	var c := _make_site(root, definition, Vector3(0, 0, -2))
	var ab: int = registry.reserve_pair(a, b)
	var bc: int = registry.reserve_pair(b, c)
	assert(ab > 0 and bc > ab)
	assert(registry.is_reserved(ab) and registry.is_reserved(bc))
	assert(registry.claim_count() == 4)
	print("PASS A: Chain reserves distinct source output and receiver input claims")

	assert(registry.reserve_pair(a, b) == 0)
	assert(registry.reserve_pair(a, a) == 0)
	assert(registry.reserve_pair(b, c) == 0)
	# A separate competing blueprint at the same geometry still cannot
	# steal a claimed receiver input or source output.
	var rival_source := _make_site(root, definition, Vector3(0, 0, 0))
	var rival_receiver := _make_site(root, definition, Vector3(0, 0, -1))
	assert(registry.reserve_pair(rival_source, b) == 0)
	assert(registry.reserve_pair(a, rival_receiver) == 0)
	assert(registry.claim_count() == 4)
	assert(registry.has_endpoint_claim(a, true))
	assert(registry.has_endpoint_claim(b, false))
	assert(registry.has_endpoint_claim(b, true))
	print("PASS B: Duplicate output/input claims are exclusive; transit site uses both sides")

	assert(registry.get_ready_candidate(ab).is_empty())
	assert(registry.get_ready_candidate(bc).is_empty())
	assert(a.get_node_or_null("CargoInventory") == null)
	assert(b.get_node_or_null("ConveyorTransportTimer") == null)
	assert(ready_ids.is_empty())
	print("PASS C: Pending route claims do not create physical conveyor links")

	var belt_a := _complete(a)
	assert(registry.get_ready_candidate(ab).is_empty())
	assert(registry.claim_count() == 4)
	assert(ready_ids.is_empty())
	print("PASS D: Completing only the source leaves the route reserved and inactive")

	var belt_b := _complete(b)
	assert(ready_ids == [ab])
	var candidate_ab := registry.get_ready_candidate(ab)
	assert(candidate_ab.get("mode") == "direct")
	assert(candidate_ab.get("source") == belt_a)
	assert(candidate_ab.get("receiver") == belt_b)
	assert(registry.get_ready_candidate(bc).is_empty())
	assert(registry.has_completed_endpoint(ab, true))
	assert(registry.has_completed_endpoint(ab, false))
	assert(registry.has_completed_endpoint(bc, true))
	assert(not registry.has_completed_endpoint(bc, false))
	print("PASS E: Middle belt announces its incoming AND outgoing reservations")

	var belt_c := _complete(c)
	assert(registry.has_completed_endpoint(bc, true))
	assert(registry.has_completed_endpoint(bc, false))
	if ready_ids != [ab, bc]:
		print(
			"E2B DIAGNOSTIC: emitted=", ready_ids,
			" | BC claimed=", registry.is_reserved(bc),
			" | completed sides=",
			registry.has_completed_endpoint(bc, true), "/",
			registry.has_completed_endpoint(bc, false),
			" | physical candidate=",
			ConveyorExistingEndpointFinder.inspect_pair(belt_b, belt_c).get(
				"mode", "none"
			),
			" | ready candidate=",
			registry.get_ready_candidate(bc).get("mode", "none")
		)
	assert(ready_ids == [ab, bc])
	assert(registry.get_ready_candidate(bc).get("mode") == "direct")
	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null and belt_b.next_segment == null)
	assert(belt_c.previous_segment == null)
	print("PASS F: Both completed chain links become candidates without auto-transport")

	await get_tree().process_frame
	assert(registry.claim_count() == 4)
	assert(registry.get_ready_candidate(ab).get("source") == belt_a)
	assert(registry.get_ready_candidate(bc).get("receiver") == belt_c)
	print("PASS G: Site retirement preserves stable claim keys and completed belt refs")

	belt_c.position.x += 0.25
	assert(registry.get_ready_candidate(bc).is_empty())
	belt_c.position.x -= 0.25
	assert(registry.get_ready_candidate(bc).get("mode") == "direct")
	assert(ready_ids.size() == 2)
	print("PASS H: Stale physical geometry invalidates commitment without new signals")

	assert(registry.release(ab))
	assert(not registry.is_reserved(ab))
	assert(not registry.release(ab))
	assert(registry.is_reserved(bc))
	assert(registry.claim_count() == 2)
	print("PASS I: Releasing one link preserves the independent downstream claim")

	belt_b.free()
	assert(not registry.is_reserved(bc))
	assert(registry.claim_count() == 0)
	assert(belt_a.next_segment == null)
	print("PASS J: Destroying a completed belt releases its outstanding route claim")

	var r_source := _make_site(root, definition, Vector3(10, 0, 0))
	var r_target := _make_site(root, definition, Vector3(11, 0, 0), -90)
	var right_id := registry.reserve_pair(r_source, r_target)
	assert(right_id > 0)
	var right_receiver := _complete(r_target)
	assert(registry.get_ready_candidate(right_id).is_empty())
	var right_source := _complete(r_source)
	var right_candidate := registry.get_ready_candidate(right_id)
	assert(right_candidate.get("mode") == "convert_source")
	assert(right_candidate.get("turn") == ConveyorTurnIntent.Turn.RIGHT)
	assert(right_candidate.get("source") == right_source)
	assert(right_candidate.get("receiver") == right_receiver)
	assert(right_source.next_segment == null)
	assert(not right_source.has_meta("conveyor_turn"))
	print("PASS K: Right corner reservation survives receiver-first construction")

	var l_source := _make_site(root, definition, Vector3(20, 0, 0))
	var l_target := _make_site(root, definition, Vector3(19, 0, 0), 90)
	var left_id := registry.reserve_pair(l_source, l_target)
	assert(left_id > 0)
	var left_source := _complete(l_source)
	assert(registry.get_ready_candidate(left_id).is_empty())
	var left_target := _complete(l_target)
	var left_candidate := registry.get_ready_candidate(left_id)
	assert(left_candidate.get("mode") == "convert_source")
	assert(left_candidate.get("turn") == ConveyorTurnIntent.Turn.LEFT)
	assert(left_source.next_segment == null)
	assert(left_target.previous_segment == null)
	print("PASS L: Left corner reservation survives source-first construction")

	var cancel_source := _make_site(root, definition, Vector3(30, 0, 0))
	var cancel_target := _make_site(root, definition, Vector3(30, 0, -1))
	var cancel_id := registry.reserve_pair(cancel_source, cancel_target)
	assert(cancel_id > 0)
	assert(cancel_target.job.cancel())
	assert(not registry.is_reserved(cancel_id))
	assert(not registry.has_endpoint_claim(cancel_source, true))
	assert(not registry.has_endpoint_claim(cancel_target, false))
	var new_target := _make_site(root, definition, Vector3(30, 0, -1))
	var replacement_id := registry.reserve_pair(cancel_source, new_target)
	assert(replacement_id > 0)
	assert(registry.release(replacement_id))
	print("PASS M: Cancellation releases both endpoints and allows new reservation")

	var bad_source := _make_site(root, definition, Vector3(40, 0, 0))
	var bad_target := _make_site(root, definition, Vector3(40, 0, -1))
	var bad_id := registry.reserve_pair(bad_source, bad_target)
	assert(bad_id > 0)
	bad_target.position.x += 0.25
	var bad_belt_a := _complete(bad_source)
	var bad_belt_b := _complete(bad_target)
	assert(registry.get_ready_candidate(bad_id).is_empty())
	assert(not ready_ids.has(bad_id))
	assert(bad_belt_a.next_segment == null)
	assert(bad_belt_b.previous_segment == null)
	assert(registry.release(bad_id))
	print("PASS N: Moved endpoints cannot become ready or silently connect")

	var orphan_source := _make_site(root, definition, Vector3(50, 0, 0))
	var orphan_target := _make_site(root, definition, Vector3(50, 0, -1))
	var orphan_id := registry.reserve_pair(orphan_source, orphan_target)
	assert(orphan_id > 0)
	orphan_source.queue_free()
	await get_tree().process_frame
	assert(not registry.is_reserved(orphan_id))
	assert(not registry.has_endpoint_claim(orphan_target, false))
	print("PASS O: Unexpected unfinished-site removal releases the reservation")

	assert(registry.release(right_id))
	assert(registry.release(left_id))
	assert(registry.claim_count() == 0)
	assert(right_source.next_segment == null)
	assert(left_source.next_segment == null)
	print("PASS P: Explicit final cleanup leaves no endpoint claims or live connections")

	print("ALL 16 PLANNED CONVEYOR RESERVATION E2B TESTS PASSED")
