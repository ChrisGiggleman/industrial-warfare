extends Node3D

# =============================================================================
# PLANNED CONVEYOR ROUTE ACTIVATION — PHASE E2C1 REGRESSION
# =============================================================================
# Tests physical connection ONLY after both construction jobs finish.
# Uses the existing ConveyorExistingConnection and cargo transport helpers.
# WorldInteraction, Main, power, materials, and blueprint visuals are untouched.

func _make_site(
	root: Node3D,
	definition: BuildingDefinition,
	where: Vector3,
	yaw_degrees: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition, false, false, false))
	root.add_child(site)
	site.set_process(false)
	site.position = where
	site.rotation_degrees.y = yaw_degrees
	return site


func _finish(site: ConstructionSite) -> ConveyorSegment:
	var produced: Array[Node3D] = []
	site.building_completed.connect(
		func(entity: Node3D) -> void: produced.append(entity)
	)
	assert(site.job.authorize())
	site._process(site.target_definition.construction_seconds)
	assert(site.job.is_complete())
	assert(produced.size() == 1)
	var belt := produced[0] as ConveyorSegment
	assert(belt != null)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	return belt


func _cargo(belt: ConveyorSegment) -> InventoryComponent:
	return belt.get_node("CargoInventory") as InventoryComponent


func _ready() -> void:
	var definition := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ore != null)
	var root := Node3D.new()
	add_child(root)

	var registry := PlannedConveyorRouteReservations.new()
	add_child(registry)
	var activator := PlannedConveyorRouteActivator.new()
	add_child(activator)
	assert(activator.bind_registry(registry))
	assert(not activator.bind_registry(registry))
	assert(not activator.try_commit(9999))
	var committed: Array[int] = []
	activator.connection_committed.connect(
		func(id: int, _source: ConveyorSegment, _receiver: ConveyorSegment) -> void:
			committed.append(id)
	)
	print("PASS A: Isolated activator binds once and rejects missing reservations")

	var source_site := _make_site(root, definition, Vector3.ZERO)
	var target_site := _make_site(root, definition, Vector3(0, 0, -1))
	var direct_id := registry.reserve_pair(source_site, target_site)
	assert(direct_id > 0)
	assert(registry.claim_count() == 2)
	assert(not activator.try_commit(direct_id))
	assert(source_site.get_node_or_null("CargoInventory") == null)
	assert(target_site.get_node_or_null("CargoInventory") == null)
	print("PASS B: Unbuilt endpoints cannot connect or carry cargo")

	var target := _finish(target_site)
	assert(registry.is_reserved(direct_id))
	assert(target.previous_segment == null)
	assert(committed.is_empty())
	assert(not activator.try_commit(direct_id))
	print("PASS C: Receiver-first completion retains a pending inactive route")

	var source := _finish(source_site)
	assert(source.next_segment == target)
	assert(target.previous_segment == source)
	assert(not registry.is_reserved(direct_id))
	assert(registry.claim_count() == 0)
	assert(committed == [direct_id])
	print("PASS D: Second completion commits a direct link once and releases claims")

	assert(_cargo(source).add_item(ore, 1) == 1)
	assert(_cargo(target).get_amount(ore) == 0)
	assert(ConveyorTransportLink.try_transfer_forward(source))
	assert(_cargo(source).get_amount(ore) == 0)
	assert(_cargo(target).get_amount(ore) == 1)
	assert(not activator.try_commit(direct_id))
	print("PASS E: Completed route transfers ore exactly once without duplicates")

	var reverse_source_site := _make_site(root, definition, Vector3(5, 0, 0))
	var reverse_target_site := _make_site(root, definition, Vector3(5, 0, -1))
	var reverse_id := registry.reserve_pair(
		reverse_source_site, reverse_target_site
	)
	assert(reverse_id > 0)
	var reverse_source := _finish(reverse_source_site)
	assert(reverse_source.next_segment == null)
	assert(registry.is_reserved(reverse_id))
	var reverse_target := _finish(reverse_target_site)
	assert(reverse_source.next_segment == reverse_target)
	assert(reverse_target.previous_segment == reverse_source)
	assert(committed.count(reverse_id) == 1)
	print("PASS F: Source-first completion also connects exactly once")

	var right_source_site := _make_site(root, definition, Vector3(10, 0, 0))
	var right_target_site := _make_site(
		root, definition, Vector3(11, 0, 0), -90.0
	)
	var right_id := registry.reserve_pair(
		right_source_site, right_target_site
	)
	assert(right_id > 0)
	var right_target := _finish(right_target_site)
	assert(right_target.previous_segment == null)
	var right_source := _finish(right_source_site)
	assert(right_source.next_segment == right_target)
	assert(right_target.previous_segment == right_source)
	assert(right_source.get_meta("conveyor_turn") == ConveyorTurnIntent.Turn.RIGHT)
	assert(right_source.global_position.is_equal_approx(Vector3(10, 0, 0)))
	assert(committed.count(right_id) == 1)
	print("PASS G: Receiver-first right turn uses existing in-place conversion")

	assert(_cargo(right_source).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(right_source))
	assert(_cargo(right_source).get_amount(ore) == 0)
	assert(_cargo(right_target).get_amount(ore) == 1)
	print("PASS H: Right corner physically transports cargo with conservation")

	var left_source_site := _make_site(root, definition, Vector3(20, 0, 0))
	var left_target_site := _make_site(
		root, definition, Vector3(19, 0, 0), 90.0
	)
	var left_id := registry.reserve_pair(left_source_site, left_target_site)
	assert(left_id > 0)
	var left_source := _finish(left_source_site)
	assert(left_source.next_segment == null)
	assert(_cargo(left_source).add_item(ore, 1) == 1)
	assert(not ConveyorTransportLink.try_transfer_forward(left_source))
	assert(_cargo(left_source).get_amount(ore) == 1)
	var left_target := _finish(left_target_site)
	assert(left_source.next_segment == left_target)
	assert(left_target.previous_segment == left_source)
	assert(left_source.get_meta("conveyor_turn") == ConveyorTurnIntent.Turn.LEFT)
	assert(_cargo(left_source).get_amount(ore) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(left_source))
	assert(_cargo(left_target).get_amount(ore) == 1)
	assert(_cargo(left_source).get_amount(ore) == 0)
	print("PASS I: Source-first left turn holds then delivers waiting cargo safely")

	var chain_a := _make_site(root, definition, Vector3(30, 0, 0))
	var chain_b := _make_site(root, definition, Vector3(30, 0, -1))
	var chain_c := _make_site(root, definition, Vector3(30, 0, -2))
	var chain_ab := registry.reserve_pair(chain_a, chain_b)
	var chain_bc := registry.reserve_pair(chain_b, chain_c)
	assert(chain_ab > 0 and chain_bc > 0)
	var built_b := _finish(chain_b)
	assert(built_b.previous_segment == null and built_b.next_segment == null)
	var built_c := _finish(chain_c)
	assert(built_b.next_segment == built_c)
	var built_a := _finish(chain_a)
	assert(built_a.next_segment == built_b)
	assert(built_b.previous_segment == built_a)
	assert(built_b.next_segment == built_c)
	assert(built_c.previous_segment == built_b)
	assert(committed.count(chain_ab) == 1 and committed.count(chain_bc) == 1)
	print("PASS J: Three-belt chain connects both sides regardless of build order")

	assert(_cargo(built_a).add_item(ore, 1) == 1)
	assert(ConveyorTransportLink.try_transfer_forward(built_a))
	assert(ConveyorTransportLink.try_transfer_forward(built_b))
	assert(_cargo(built_a).get_amount(ore) == 0)
	assert(_cargo(built_b).get_amount(ore) == 0)
	assert(_cargo(built_c).get_amount(ore) == 1)
	print("PASS K: Two-hop chain conserves cargo after deferred connections")

	var moved_a := _make_site(root, definition, Vector3(40, 0, 0))
	var moved_b := _make_site(root, definition, Vector3(40, 0, -1))
	var moved_id := registry.reserve_pair(moved_a, moved_b)
	assert(moved_id > 0)
	var moved_source := _finish(moved_a)
	moved_b.position.x += 0.25
	var moved_target := _finish(moved_b)
	assert(moved_source.next_segment == null)
	assert(moved_target.previous_segment == null)
	assert(registry.is_reserved(moved_id))
	assert(not activator.try_commit(moved_id))
	moved_target.position.x -= 0.25
	assert(activator.try_commit(moved_id))
	assert(moved_source.next_segment == moved_target)
	print("PASS L: Moved geometry refuses auto-activation until revalidated")

	var occupied_a := _make_site(root, definition, Vector3(50, 0, 0))
	var occupied_b := _make_site(root, definition, Vector3(50, 0, -1))
	var occupied_id := registry.reserve_pair(occupied_a, occupied_b)
	assert(occupied_id > 0)
	var occupied_source := _finish(occupied_a)
	var dummy_port := ItemPortComponent.new()
	occupied_source.output_building_port = dummy_port
	var occupied_target := _finish(occupied_b)
	assert(occupied_source.next_segment == null)
	assert(occupied_target.previous_segment == null)
	assert(registry.is_reserved(occupied_id))
	assert(not activator.try_commit(occupied_id))
	occupied_source.output_building_port = null
	dummy_port.free()
	assert(activator.try_commit(occupied_id))
	assert(occupied_source.next_segment == occupied_target)
	print("PASS M: Occupied endpoints cannot be stolen by route activation")

	var cancelled_a := _make_site(root, definition, Vector3(60, 0, 0))
	var cancelled_b := _make_site(root, definition, Vector3(60, 0, -1))
	var cancelled_id := registry.reserve_pair(cancelled_a, cancelled_b)
	assert(cancelled_id > 0)
	assert(cancelled_b.job.cancel())
	assert(not registry.is_reserved(cancelled_id))
	assert(not activator.try_commit(cancelled_id))
	assert(registry.claim_count() == 0)
	print("PASS N: Cancelling a blueprint removes its nonoperational route claim")

	var orphan_a := _make_site(root, definition, Vector3(70, 0, 0))
	var orphan_b := _make_site(root, definition, Vector3(70, 0, -1))
	var orphan_id := registry.reserve_pair(orphan_a, orphan_b)
	assert(orphan_id > 0)
	var orphan_belt := _finish(orphan_a)
	assert(registry.is_reserved(orphan_id))
	orphan_belt.free()
	assert(not registry.is_reserved(orphan_id))
	assert(not activator.try_commit(orphan_id))
	assert(registry.claim_count() == 0)
	print("PASS O: Destroyed built endpoint releases waiting claim without connection")

	print("ALL 15 PLANNED CONVEYOR ACTIVATION E2C1 TESTS PASSED")
