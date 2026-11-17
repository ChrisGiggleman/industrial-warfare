extends Node3D

const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const ORE = preload("res://data/items/test_ore.tres")


func _ready() -> void:
	call_deferred("_checks")


func _storage(at: Vector3, stock: int) -> PrototypeDroneStorageDock:
	var building := STORAGE.building_scene.instantiate() as Node3D
	add_child(building)
	building.global_position = at
	(building.get_node("BuildingRuntime") as BuildingRuntime).initialize(STORAGE)
	var inventory := building.get_node("InventoryComponent") as InventoryComponent
	inventory.enable_isolated_drone_claims = true
	inventory.enable_isolated_drone_return_claims = true
	inventory.max_capacity = 20
	assert(inventory.add_item(INGOT, stock) == stock)
	var dock := PrototypeDroneStorageDock.new()
	building.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	return dock


func _stock(dock: PrototypeDroneStorageDock) -> InventoryComponent:
	return dock.get_parent().get_node("InventoryComponent") as InventoryComponent


func _drone(energy: float = 40.0) -> PrototypeConstructionWorkerDrone:
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	drone.global_position = Vector3(0, 2, 0)
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	assert(drone.configure_battery(40.0, energy, 1.0, 4.0))
	return drone


func _checks() -> void:
	var discovery := PrototypeDroneStorageDiscovery.new()
	add_child(discovery)
	discovery.enable_isolated_discovery = true
	var claims := PrototypeDroneReturnReservations.new()
	add_child(claims)
	var a := _storage(Vector3(3, 0, 0), 12)
	var b := _storage(Vector3(8, 0, 0), 15)
	var stock := _stock(a)
	var other := _stock(b)
	assert(discovery.register_dock(a) and discovery.register_dock(b))
	var worker := _drone()
	var worker2 := _drone()
	var worker3 := _drone()
	assert(not claims.configure(discovery))
	assert(claims.reserve(worker, INGOT, 5) == 0)
	claims.enable_isolated_reservations = true
	assert(claims.configure(discovery) and not claims.configure(discovery))
	var duplicate := PrototypeDroneReturnReservations.new()
	add_child(duplicate)
	duplicate.enable_isolated_reservations = true
	assert(not duplicate.configure(discovery))
	print("PASS A: Default-off exclusive isolated return claim service")
	assert(claims.reserve(worker, null, 5) == 0)
	assert(claims.reserve(worker, INGOT, 0) == 0)
	assert(claims.reserve(worker, INGOT, 9) == 0)
	var weak := _drone(6.0)
	assert(claims.reserve(weak, INGOT, 1) == 0)
	stock.enable_isolated_drone_return_claims = false
	assert(discovery.find_return(worker, INGOT, 5, true)["dock"] == b)
	stock.enable_isolated_drone_return_claims = true
	print("PASS B: Invalid amounts, disabled destination and insufficient return energy refused")
	var revision: int = stock.get_mutation_revision()
	var first: int = claims.reserve(worker, INGOT, 5)
	assert(first > 0 and claims.observe(first)["dock"] == a and claims.observe(first)["valid"])
	assert(stock.get_amount(INGOT) == 12 and stock.get_total_amount() == 12)
	assert(stock.get_physical_available_space() == 8 and stock.get_reserved_return_space() == 5 and stock.get_available_space() == 3)
	assert(stock.get_mutation_revision() == revision)
	print("PASS C: Space claims reserve no physical items and do not mutate stock")
	assert(claims.reserve(worker, ORE, 1) == 0)
	var second: int = claims.reserve(worker2, ORE, 4)
	assert(second > first and claims.observe(second)["dock"] == b)
	assert(other.get_reserved_return_space() == 4 and other.get_available_space() == 1)
	assert(claims.reserve(worker3, INGOT, 4) == 0)
	print("PASS D: Shared capacity across item types, alternative destination and duplicate refusal")
	# Independent outgoing stock claim can coexist with incoming space.
	var token := RefCounted.new()
	assert(stock.reserve_drone_stock(token, INGOT, 3))
	assert(stock.get_unreserved_amount(INGOT) == 9 and stock.get_reserved_return_space() == 5)
	assert(stock.add_item(ORE, 2) == 2)
	var input := a.get_parent().get_node("InputPort") as ItemPortComponent
	assert(input.can_accept_item(ORE, 1) and not input.can_accept_item(ORE, 2))
	print("PASS E: Ordinary additions and input port honor capacity; stock claims independent")
	# Actual connected belt and travel timer, not a mocked acceptance flag.
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	add_child(belt)
	var preview := ConveyorBuildingSnap.get_preview_transform(input, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(input))
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	timer.set_process(false)
	timer.travel_interval = 1.0
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var supply := InventoryComponent.new()
	add_child(supply)
	assert(supply.add_item(ORE, 2) == 2)
	assert(transport.try_receive_from_inventory(supply, ORE))
	assert(not timer.advance_transport(0.4))
	assert(timer.advance_transport(0.61))
	assert(stock.get_available_space() == 0 and stock.is_full())
	assert(not timer.advance_transport(0.01))
	assert(transport.try_receive_from_inventory(supply, ORE))
	assert(not timer.advance_transport(1.0))
	assert(transport.get_held_item() == ORE and stock.get_amount(ORE) == 3)
	assert(stock.get_physical_available_space() == 5)
	print("PASS F: Real timed conveyor uses last unreserved space then blocks without cargo loss")
	stock.enable_isolated_drone_return_claims = false
	assert(stock.add_item(INGOT, 1) == 0)
	assert(not claims.release(first, worker2))
	assert(claims.release(first, worker) and not claims.release(first, worker))
	assert(stock.get_reserved_amount(INGOT) == 3 and stock.get_reserved_return_space() == 0)
	assert(timer.advance_transport(0.01))
	assert(transport.get_held_item() == null and stock.get_amount(ORE) == 4)
	stock.enable_isolated_drone_return_claims = true
	assert(stock.release_drone_stock(token))
	print("PASS G: Flag disable preserves claim; owner release resumes waiting belt without affecting outgoing claim")
	var third: int = claims.reserve(worker, INGOT, 3)
	assert(third > second and claims.observe(third)["dock"] == a)
	a.allow_returns = false
	assert(not claims.observe(third)["valid"] and stock.get_reserved_return_space() == 3)
	assert(claims.reconcile() == 1 and stock.get_reserved_return_space() == 0)
	a.allow_returns = true
	print("PASS H: Changed return permission invalidates but does not silently release claim")
	var fourth: int = claims.reserve(worker, INGOT, 3)
	assert(fourth > third)
	stock.max_capacity = 18
	assert(not claims.observe(fourth)["valid"] and stock.get_available_space() == 0)
	assert(claims.reconcile() == 1 and stock.get_available_space() == 2)
	stock.max_capacity = 20
	print("PASS I: Reduced capacity fails closed until reconciliation")
	assert(claims.release(second, worker2))
	var fifth: int = claims.reserve(worker, INGOT, 2)
	var sixth: int = claims.reserve(worker2, ORE, 2)
	assert(fifth > fourth and sixth > fifth and claims.observe(sixth)["dock"] == a)
	stock.max_capacity = 18
	assert(claims.reconcile() == 1 and claims.observe(sixth).is_empty() and claims.observe(fifth)["valid"])
	stock.max_capacity = 20
	print("PASS J: Capacity reduction drops newest excess claim first")
	worker.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(claims.reservation_count() == 0 and stock.get_reserved_return_space() == 0)
	var seventh: int = claims.reserve(worker3, INGOT, 3)
	assert(seventh > sixth and claims.observe(seventh)["dock"] == a)
	var health := a.get_parent().get_node("BuildingHealthComponent") as BuildingHealthComponent
	health.take_damage(health.current_health)
	assert(not claims.observe(seventh)["valid"] and claims.reconcile() == 1)
	assert(stock.get_reserved_return_space() == 0)
	print("PASS K: Deleted claimant and depleted destination release capacity without stock loss")
	var eighth: int = claims.reserve(worker3, INGOT, 3)
	assert(eighth > seventh and claims.observe(eighth)["dock"] == b)
	var building: Node = b.get_parent()
	building.remove_child(other)
	assert(claims.reservation_count() == 0 and other.get_reserved_return_space() == 0)
	var replacement := InventoryComponent.new()
	replacement.name = "InventoryComponent"
	replacement.enable_isolated_drone_return_claims = true
	building.add_child(replacement)
	assert(claims.reserve(worker3, INGOT, 3) == 0)
	print("PASS L: Removed inventory releases exact claim; replacement cannot inherit enrollment")
	var unlimited := _storage(Vector3(2, 0, 0), 1)
	var unlimited_stock := _stock(unlimited)
	unlimited_stock.max_capacity = 0
	assert(discovery.register_dock(unlimited))
	var ninth: int = claims.reserve(worker3, INGOT, 100)
	assert(ninth > eighth and claims.observe(ninth)["dock"] == unlimited)
	assert(unlimited_stock.get_available_space() == -1 and unlimited_stock.get_reserved_return_space() == 100)
	assert(unlimited_stock.get_total_amount() == 1)
	assert(worker3.global_position == Vector3(0, 2, 0) and worker3.battery_units() == 40.0)
	claims.free()
	assert(unlimited_stock.get_reserved_return_space() == 0 and unlimited_stock.get_total_amount() == 1)
	assert(stock.get_total_amount() + other.get_total_amount() + unlimited_stock.get_total_amount() == 32)
	other.free()
	print("PASS M: Unlimited storage, teardown and full physical conservation; no flight or fabricated cargo")
	var plain := InventoryComponent.new()
	add_child(plain)
	plain.max_capacity = 2
	assert(not plain.reserve_drone_return_space(RefCounted.new(), INGOT, 1))
	assert(plain.add_item(INGOT, 2) == 2 and plain.is_full())
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneReturnReservations") == null)
	assert(sandbox.get_node_or_null("PrototypeDroneReturnReservations") == null)
	main.free()
	sandbox.free()
	print("PASS N: Ordinary inventories and normal scenes remain opted out")
	print("ALL 14 E3D5C5X4B DRONE RETURN CAPACITY RESERVATION TESTS PASSED")
