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
	inventory.max_capacity = 20
	assert(inventory.add_item(INGOT, stock) == stock)
	var dock := PrototypeDroneStorageDock.new()
	building.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	return dock


func _stock(dock: PrototypeDroneStorageDock) -> InventoryComponent:
	return dock.get_parent().get_node("InventoryComponent") as InventoryComponent


func _drone() -> PrototypeConstructionWorkerDrone:
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	drone.global_position = Vector3(0, 2, 0)
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	assert(drone.configure_battery(40.0, 40.0, 1.0, 4.0))
	return drone


func _site(at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(STORAGE))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _checks() -> void:
	var discovery := PrototypeDroneStorageDiscovery.new()
	add_child(discovery)
	discovery.enable_isolated_discovery = true
	var claims := PrototypeDroneSupplierReservations.new()
	add_child(claims)
	claims.enable_isolated_reservations = true
	assert(claims.configure(discovery))
	var dock := _storage(Vector3(5, 0, 0), 9)
	var stock := _stock(dock)
	assert(discovery.register_dock(dock))
	var worker := _drone()
	var stranger := _drone()
	var site := _site(Vector3(10, 0, 0))
	assert(site.job.authorize())
	var id: int = claims.reserve(worker, site, INGOT, 3, 5)
	assert(id > 0 and not claims.begin_pickup(id, worker, 2.0))
	assert(not claims.collect_pickup(id, worker))
	assert(stock.get_amount(INGOT) == 9 and worker.cargo_amount() == 0)
	print("PASS A: Default-off and no remote pickup")
	worker.enable_isolated_cargo_pickup = true
	stranger.enable_isolated_cargo_pickup = true
	assert(not claims.begin_pickup(id, stranger, 2.0))
	assert(not claims.begin_pickup(id, worker, 0.0))
	assert(claims.begin_pickup(id, worker, 2.0))
	assert(not claims.begin_pickup(id, worker, 2.0))
	assert(not claims.advance_pickup(id, stranger, 1.0))
	assert(not claims.collect_pickup(id, stranger))
	print("PASS B: Exact owner and valid speed")
	assert(not worker.advance_flight(1.0))
	assert(not claims.collect_pickup(id, worker))
	assert(claims.advance_pickup(id, worker, 1.0))
	assert(is_equal_approx(worker.global_position.x, 2.0) and is_equal_approx(worker.battery_units(), 38.0))
	assert(worker.cargo_amount() == 0 and stock.get_amount(INGOT) == 9)
	assert(not claims.collect_pickup(id, worker))
	assert(claims.observe(id)["valid"] and stock.get_reserved_amount(INGOT) == 3)
	print("PASS C: Metered physical movement and protected stock in flight")
	assert(claims.advance_pickup(id, worker, 2.0))
	assert(worker.global_position.is_equal_approx(dock.global_position))
	assert(is_equal_approx(worker.battery_units(), 35.0))
	assert(worker.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_PICKUP)
	assert(worker.cargo_amount() == 0)
	print("PASS D: Physical arrival alone does not debit")
	var rev: int = stock.get_mutation_revision()
	assert(claims.collect_pickup(id, worker))
	assert(worker.cargo_item() == INGOT and worker.cargo_amount() == 3)
	assert(stock.get_amount(INGOT) == 6 and stock.get_reserved_amount(INGOT) == 0)
	assert(stock.get_mutation_revision() == rev + 1 and claims.reservation_count() == 0)
	assert(not claims.collect_pickup(id, worker) and not claims.release(id, worker))
	assert(worker.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.CARGO_HELD)
	print("PASS E: Exactly-once claimed debit becomes finite physical cargo")
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"materials") and site.job.get_wait_reasons().has(&"workers"))
	assert(not worker.grants_worker_readiness() and not worker.advance_flight(1.0))
	assert(claims.reserve(worker, site, INGOT, 3, 5) == 0)
	print("PASS F: No construction readiness, legacy dispatch or repeat assignment")
	assert(site.job.cancel() and worker.cargo_amount() == 3)
	assert(stock.get_amount(INGOT) + worker.cargo_amount() == 9)
	print("PASS G: Post-pickup cancellation retains physical cargo")
	var site2 := _site(Vector3(10, 0, 0))
	assert(site2.job.authorize())
	var id2: int = claims.reserve(stranger, site2, INGOT, 3, 5)
	assert(id2 > id and claims.begin_pickup(id2, stranger, 2.0))
	assert(claims.advance_pickup(id2, stranger, 1.0))
	assert(site2.job.cancel())
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	assert(stranger.cargo_amount() == 0 and stranger.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(stranger.advance_flight(2.0) and stranger.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	print("PASS H: Pre-pickup cancellation releases only claim and returns empty")
	var worker3 := _drone()
	worker3.enable_isolated_cargo_pickup = true
	var site3 := _site(Vector3(10, 0, 0))
	assert(site3.job.authorize())
	var id3: int = claims.reserve(worker3, site3, INGOT, 3, 5)
	assert(id3 > id2 and claims.begin_pickup(id3, worker3, 2.0))
	assert(claims.advance_pickup(id3, worker3, 3.0))
	dock.allow_pickup = false
	assert(not claims.collect_pickup(id3, worker3))
	assert(claims.reconcile() == 1 and stock.get_reserved_amount(INGOT) == 0 and worker3.cargo_amount() == 0)
	assert(stock.get_amount(INGOT) + worker.cargo_amount() == 9)
	print("PASS I: Revoked dock at arrival prevents debit")
	dock.allow_pickup = true
	var worker4 := _drone()
	worker4.enable_isolated_cargo_pickup = true
	var site4 := _site(Vector3(10, 0, 0))
	assert(site4.job.authorize())
	var id4: int = claims.reserve(worker4, site4, INGOT, 3, 5)
	assert(id4 > id3 and claims.begin_pickup(id4, worker4, 2.0))
	assert(claims.advance_pickup(id4, worker4, 3.0))
	worker4.enable_isolated_cargo_pickup = false
	assert(not claims.collect_pickup(id4, worker4))
	assert(claims.reconcile() == 1 and worker4.cargo_amount() == 0)
	assert(stock.get_amount(INGOT) + worker.cargo_amount() == 9)
	print("PASS J: Feature disable blocks pickup, preserves conservation")
	var plain := InventoryComponent.new()
	add_child(plain)
	assert(plain.add_item(INGOT, 3) == 3)
	assert(not plain.consume_drone_stock_claim(RefCounted.new(), INGOT, 3))
	assert(plain.get_amount(INGOT) == 3)
	print("PASS K: Unknown token cannot debit ordinary stock")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneSupplierReservations") == null and sandbox.get_node_or_null("PrototypeDroneSupplierReservations") == null)
	main.free()
	sandbox.free()
	print("PASS L: Normal scenes remain opt-out")
	print("ALL 12 E3D5C5X5A DRONE PHYSICAL PICKUP TESTS PASSED")
