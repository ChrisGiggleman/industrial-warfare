extends Node3D

# =============================================================================
# BLUEPRINT STORAGE PORT RESERVATIONS — PHASE E3B REGRESSION
# =============================================================================
# Exclusive future port claims, independent build order and safe teardown.
# Deliberately no physical ItemPortComponent connection or cargo transport.

func _site(
	root: Node3D, definition: BuildingDefinition,
	location: Vector3, yaw: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	root.add_child(site)
	site.set_process(false)
	site.position = location
	site.rotation_degrees.y = yaw
	return site


func _finish(site: ConstructionSite) -> Node3D:
	var results: Array[Node3D] = []
	site.building_completed.connect(
		func(built: Node3D) -> void: results.append(built)
	)
	assert(site.job.authorize())
	assert(site.job.set_availability(true, true, true))
	site._process(site.target_definition.construction_seconds)
	assert(results.size() == 1)
	assert(site.is_completed())
	var built := results[0]
	if built is ConveyorSegment:
		var timer := built.get_node(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer
		assert(timer != null)
		timer.set_process(false)
	return built


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
	var registry := PlannedBuildingPortReservations.new()
	add_child(registry)
	var ready_ids: Array[int] = []
	registry.reservation_ready.connect(
		func(id: int) -> void: ready_ids.append(id)
	)

	var storage := _site(root, storage_def, Vector3.ZERO)
	var inbound := _site(root, belt_def, Vector3(0, 0, 2))
	var outbound := _site(root, belt_def, Vector3(0, 0, -2))
	var incoming_id := registry.reserve_pair(storage, inbound, true)
	var outgoing_id := registry.reserve_pair(storage, outbound, false)
	assert(incoming_id > 0 and outgoing_id > incoming_id)
	assert(registry.claim_count() == 4)
	assert(registry.has_building_claim(storage, true))
	assert(registry.has_building_claim(storage, false))
	print("PASS A: Input and output claim separate future Storage ports")

	var duplicate_in := _site(root, belt_def, Vector3(0, 0, 2))
	var duplicate_out := _site(root, belt_def, Vector3(0, 0, -2))
	assert(registry.reserve_pair(storage, duplicate_in, true) == 0)
	assert(registry.reserve_pair(storage, duplicate_out, false) == 0)
	assert(registry.reserve_pair(storage, inbound, true) == 0)
	assert(registry.reserve_pair(storage, outbound, false) == 0)
	assert(registry.claim_count() == 4)
	print("PASS B: Competing belts cannot claim an occupied Storage port")

	assert(registry.has_belt_claim(inbound, true))
	assert(registry.has_belt_claim(outbound, false))
	assert(not registry.has_belt_claim(inbound, false))
	assert(not registry.has_belt_claim(outbound, true))
	assert(registry.get_ready_candidate(incoming_id).is_empty())
	assert(registry.get_ready_candidate(outgoing_id).is_empty())
	assert(storage.get_node_or_null("InputPort") == null)
	assert(inbound.get_node_or_null("CargoInventory") == null)
	print("PASS C: Directional belt claims remain nonoperational blueprints")

	var real_storage := _finish(storage)
	assert(real_storage.get_node("InputPort") is ItemPortComponent)
	assert(registry.has_completed_side(incoming_id, true))
	assert(registry.has_completed_side(outgoing_id, true))
	assert(not registry.has_completed_side(incoming_id, false))
	assert(ready_ids.is_empty())
	print("PASS D: Storage-first completion preserves both independent claims")

	var real_inbound := _finish(inbound) as ConveyorSegment
	assert(real_inbound != null)
	assert(ready_ids == [incoming_id])
	assert(registry.get_ready_candidate(incoming_id).get("belt") == real_inbound)
	assert(registry.get_ready_candidate(outgoing_id).is_empty())
	print("PASS E: First finished belt makes only the input route ready")

	var real_outbound := _finish(outbound) as ConveyorSegment
	assert(real_outbound != null)
	assert(ready_ids == [incoming_id, outgoing_id])
	assert(registry.get_ready_candidate(outgoing_id).get("belt") == real_outbound)
	assert(registry.claim_count() == 4)
	print("PASS F: Shared Storage completion reaches both route observers")

	assert(real_inbound.output_building_port == null)
	assert(real_outbound.input_building_port == null)
	assert(
		(real_storage.get_node("InputPort") as ItemPortComponent).connected_conveyor
		== null
	)
	assert(
		(real_storage.get_node("OutputPort") as ItemPortComponent).connected_conveyor
		== null
	)
	print("PASS G: Ready claims never create real ports links or transfer cargo")

	await get_tree().process_frame
	assert(not is_instance_valid(storage))
	assert(not is_instance_valid(inbound))
	assert(not is_instance_valid(outbound))
	assert(registry.get_ready_candidate(incoming_id).get("building") == real_storage)
	assert(registry.get_ready_candidate(outgoing_id).get("belt") == real_outbound)
	print("PASS H: Freed construction sites retain stable completed endpoints")

	real_inbound.position.x += 0.25
	assert(registry.get_ready_candidate(incoming_id).is_empty())
	real_inbound.position.x -= 0.25
	assert(not registry.get_ready_candidate(incoming_id).is_empty())
	assert(ready_ids == [incoming_id, outgoing_id])
	print("PASS I: Moved physical endpoints fail revalidation without extra signals")

	assert(registry.release(incoming_id))
	assert(not registry.is_reserved(incoming_id))
	assert(not registry.release(incoming_id))
	assert(registry.is_reserved(outgoing_id))
	assert(registry.claim_count() == 2)
	assert(real_inbound.output_building_port == null)
	print("PASS J: Releasing a freed-site input leaves independent output reserved")

	var belt_first_storage := _site(
		root, storage_def, Vector3(10, 0, 0)
	)
	var belt_first_plan := _site(
		root, belt_def, Vector3(10, 0, 2)
	)
	var belt_first_id := registry.reserve_pair(
		belt_first_storage, belt_first_plan, true
	)
	assert(belt_first_id > 0)
	var belt_first := _finish(belt_first_plan) as ConveyorSegment
	assert(registry.get_ready_candidate(belt_first_id).is_empty())
	var storage_second := _finish(belt_first_storage)
	assert(registry.get_ready_candidate(belt_first_id).get("building") == storage_second)
	assert(registry.get_ready_candidate(belt_first_id).get("belt") == belt_first)
	assert(ready_ids.count(belt_first_id) == 1)
	print("PASS K: Conveyor-first completion also creates one ready candidate")

	var rotated := _site(
		root, storage_def, Vector3(20, 0, 10), 90.0
	)
	var rotated_basis := rotated.global_transform.basis
	var rotated_in := _site(
		root, belt_def,
		rotated.global_position + rotated_basis * Vector3(0, 0, 2), 90.0
	)
	var rotated_out := _site(
		root, belt_def,
		rotated.global_position + rotated_basis * Vector3(0, 0, -2), 90.0
	)
	var rotated_in_id := registry.reserve_pair(rotated, rotated_in, true)
	var rotated_out_id := registry.reserve_pair(rotated, rotated_out, false)
	assert(rotated_in_id > 0 and rotated_out_id > rotated_in_id)
	_finish(rotated_in)
	_finish(rotated_out)
	assert(registry.get_ready_candidate(rotated_in_id).is_empty())
	_finish(rotated)
	assert(not registry.get_ready_candidate(rotated_in_id).is_empty())
	assert(not registry.get_ready_candidate(rotated_out_id).is_empty())
	print("PASS L: Rotated Storage input/output survive belt-first construction")

	var cancel_storage := _site(
		root, storage_def, Vector3(30, 0, 0)
	)
	var cancel_belt := _site(
		root, belt_def, Vector3(30, 0, 2)
	)
	var cancelled_id := registry.reserve_pair(
		cancel_storage, cancel_belt, true
	)
	assert(cancelled_id > 0)
	assert(cancel_belt.job.cancel())
	assert(not registry.is_reserved(cancelled_id))
	assert(not registry.has_building_claim(cancel_storage, true))
	var replacement := _site(
		root, belt_def, Vector3(30, 0, 2)
	)
	var new_id := registry.reserve_pair(cancel_storage, replacement, true)
	assert(new_id > 0)
	assert(registry.release(new_id))
	print("PASS M: Cancellation frees both claims and permits replanning")

	var orphan_storage := _site(
		root, storage_def, Vector3(40, 0, 0)
	)
	var orphan_belt := _site(
		root, belt_def, Vector3(40, 0, 2)
	)
	var orphan_id := registry.reserve_pair(orphan_storage, orphan_belt, true)
	assert(orphan_id > 0)
	orphan_storage.queue_free()
	await get_tree().process_frame
	assert(not registry.is_reserved(orphan_id))
	assert(not registry.has_belt_claim(orphan_belt, true))
	print("PASS N: Unexpected unbuilt-site removal releases both claims")

	var lost_storage := _site(
		root, storage_def, Vector3(50, 0, 0)
	)
	var lost_plan := _site(
		root, belt_def, Vector3(50, 0, 2)
	)
	var lost_id := registry.reserve_pair(lost_storage, lost_plan, true)
	assert(lost_id > 0)
	var lost_real_belt := _finish(lost_plan)
	assert(registry.is_reserved(lost_id))
	lost_real_belt.free()
	assert(not registry.is_reserved(lost_id))
	print("PASS O: Destroyed finished belt releases pending building-port claim")

	var destroyed_storage := _site(
		root, storage_def, Vector3(60, 0, 0)
	)
	var waiting_belt := _site(
		root, belt_def, Vector3(60, 0, 2)
	)
	var destroyed_id := registry.reserve_pair(
		destroyed_storage, waiting_belt, true
	)
	assert(destroyed_id > 0)
	var built_storage := _finish(destroyed_storage)
	built_storage.free()
	assert(not registry.is_reserved(destroyed_id))
	print("PASS P: Destroyed real Storage releases waiting conveyor claim")

	var legacy_storage := _site(
		root, storage_def, Vector3(70, 0, 0)
	)
	var legacy_belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(legacy_belt != null)
	root.add_child(legacy_belt)
	var legacy_transform := legacy_storage.get_planned_belt_transform(
		legacy_belt, true
	)
	assert(legacy_transform.has("transform"))
	legacy_belt.global_transform = legacy_transform["transform"]
	assert(legacy_storage.reserve_conveyor(legacy_belt, true))
	var competing_plan := _site(
		root, belt_def, Vector3(70, 0, 2)
	)
	assert(registry.reserve_pair(legacy_storage, competing_plan, true) == 0)
	print("PASS Q: Legacy live-belt reservation cannot be stolen by blueprint")

	assert(registry.release(outgoing_id))
	assert(registry.release(belt_first_id))
	assert(registry.release(rotated_in_id))
	assert(registry.release(rotated_out_id))
	assert(registry.claim_count() == 0)
	assert(real_outbound.input_building_port == null)
	print("PASS R: Cleanup removes every claim without connecting live ports")

	print("ALL 18 PLANNED BUILDING PORT RESERVATION E3B TESTS PASSED")
