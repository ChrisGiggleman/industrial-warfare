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
	var a := _storage(Vector3(8, 0, 0), 5)
	var b := _storage(Vector3(3, 0, 0), 6)
	assert(discovery.register_dock(a) and discovery.register_dock(b))
	var stock := _stock(a)
	var other := _stock(b)
	var worker := _drone()
	var worker2 := _drone()
	var site := _site(Vector3(10, 0, 0))
	var site2 := _site(Vector3(11, 0, 0))
	assert(not claims.configure(discovery))
	assert(claims.reserve(worker, site, INGOT, 3, 5) == 0)
	claims.enable_isolated_reservations = true
	assert(claims.configure(discovery) and not claims.configure(discovery))
	var duplicate := PrototypeDroneSupplierReservations.new()
	add_child(duplicate)
	duplicate.enable_isolated_reservations = true
	assert(not duplicate.configure(discovery))
	print("PASS A: Default-off and exclusive scope reservation service")
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(claims.reserve(worker, site, INGOT, 3, 5) == 0)
	assert(site.job.authorize() and site2.job.authorize())
	assert(claims.reserve(worker, site, ORE, 1, 5) == 0)
	assert(claims.reserve(worker, site, INGOT, 4, 5) == 0)
	assert(claims.reserve(worker, site, INGOT, 3, 2) == 0)
	print("PASS B: Authorization, bill and cargo bounds precede claims")
	var revision: int = stock.get_mutation_revision()
	var first: int = claims.reserve(worker, site, INGOT, 3, 5)
	assert(first > 0 and claims.observe(first)["dock"] == a and claims.observe(first)["valid"])
	assert(stock.get_amount(INGOT) == 5 and stock.get_reserved_amount(INGOT) == 3 and stock.get_unreserved_amount(INGOT) == 2)
	assert(stock.get_mutation_revision() == revision and stock.get_available_space() == 15)
	print("PASS C: Reservation counts existing physical stock once; no inventory movement")
	assert(claims.reserve(worker, site2, INGOT, 3, 5) == 0)
	assert(claims.reserve(worker2, site, INGOT, 3, 5) == 0)
	var second: int = claims.reserve(worker2, site2, INGOT, 3, 5)
	assert(second > first and claims.observe(second)["dock"] == b)
	assert(other.get_reserved_amount(INGOT) == 3 and claims.reservation_count() == 2)
	print("PASS D: Competing drone and site claims cannot double promise stock")
	var output := a.get_parent().get_node("OutputPort") as ItemPortComponent
	assert(output.can_provide_item(INGOT, 2) and not output.can_provide_item(INGOT, 3))
	assert(not stock.remove_item(INGOT, 3))
	var sink := InventoryComponent.new()
	add_child(sink)
	assert(stock.transfer_to(sink, INGOT, 5) == 2)
	assert(stock.get_amount(INGOT) == 3 and stock.get_unreserved_amount(INGOT) == 0 and sink.get_amount(INGOT) == 2)
	print("PASS E: Existing port and inventory transfer cannot consume reserved stock")
	stock.enable_isolated_drone_claims = false
	assert(not stock.remove_item(INGOT, 1))
	assert(not claims.release(first, worker2))
	assert(claims.release(first, worker) and not claims.release(first, worker))
	assert(stock.get_unreserved_amount(INGOT) == 3 and stock.get_amount(INGOT) == 3)
	stock.enable_isolated_drone_claims = true
	print("PASS F: Feature disable retains stock protection; exact-owner release is idempotent")
	assert(site2.job.cancel())
	assert(claims.reservation_count() == 0 and other.get_reserved_amount(INGOT) == 0 and other.get_amount(INGOT) == 6)
	print("PASS G: Cancellation releases claim, never fabricates a refund")
	a.minimum_retained = 1
	var third: int = claims.reserve(worker, site, INGOT, 3, 5)
	assert(third > second and claims.observe(third)["dock"] == b)
	b.available = false
	assert(not claims.observe(third)["valid"] and other.get_reserved_amount(INGOT) == 3)
	assert(claims.reconcile() == 1 and other.get_reserved_amount(INGOT) == 0)
	b.available = true
	print("PASS H: Retained stock and invalidated dock revalidation")
	a.minimum_retained = 0
	var fourth: int = claims.reserve(worker, site, INGOT, 3, 5)
	assert(fourth > third and claims.observe(fourth)["dock"] == a)
	worker.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(claims.reservation_count() == 0 and stock.get_reserved_amount(INGOT) == 0)
	print("PASS I: Freed claimant releases unpicked stock")
	var worker3 := _drone()
	var fifth: int = claims.reserve(worker3, site, INGOT, 3, 5)
	assert(fifth > fourth)
	var health := a.get_parent().get_node("BuildingHealthComponent") as BuildingHealthComponent
	health.take_damage(health.current_health)
	assert(not claims.observe(fifth)["valid"])
	assert(claims.reconcile() == 1 and stock.get_reserved_amount(INGOT) == 0)
	print("PASS J: Damaged source invalidates claim without stock movement")
	var sixth: int = claims.reserve(worker3, site, INGOT, 3, 5)
	assert(sixth > fifth and claims.observe(sixth)["dock"] == b)
	assert(worker3.global_position == Vector3(0, 2, 0) and worker3.battery_units() == 40.0)
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"materials") and site.job.get_wait_reasons().has(&"workers"))
	claims.free()
	assert(other.get_reserved_amount(INGOT) == 0 and stock.get_amount(INGOT) + other.get_amount(INGOT) + sink.get_amount(INGOT) == 11)
	print("PASS K: Service teardown preserves all stock and never grants readiness")
	var plain := InventoryComponent.new()
	add_child(plain)
	assert(plain.add_item(INGOT, 3) == 3)
	assert(not plain.reserve_drone_stock(RefCounted.new(), INGOT, 3))
	assert(plain.transfer_to(sink, INGOT, 3) == 3)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneSupplierReservations") == null)
	assert(sandbox.get_node_or_null("PrototypeDroneSupplierReservations") == null)
	main.free()
	sandbox.free()
	print("PASS L: Ordinary inventory and normal scenes remain compatible by default")
	print("ALL 12 E3D5C5X4A DRONE SUPPLIER RESERVATION TESTS PASSED")
