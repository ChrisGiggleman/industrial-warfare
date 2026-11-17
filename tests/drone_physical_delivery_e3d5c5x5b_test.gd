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


func _buffer(registry: BlueprintConstructionSiteStagingRegistry, site: ConstructionSite, source: InventoryComponent) -> InventoryComponent:
	var staging := BlueprintConstructionMaterialStaging.new()
	add_child(staging)
	staging.enable_isolated_staging = true
	assert(staging.configure(source, STORAGE, 6))
	var root := Node3D.new()
	add_child(root)
	var port := BlueprintConstructionStagingInputPort.new()
	root.add_child(port)
	port.show_port_label = false
	port.enable_isolated_input = true
	assert(port.bind_staging(staging))
	assert(registry.claim_site(site, staging, port))
	return staging.get_staged_inventory()


func _loaded(claims: PrototypeDroneSupplierReservations, site: ConstructionSite) -> PrototypeConstructionWorkerDrone:
	var drone := _drone()
	drone.enable_isolated_cargo_pickup = true
	var id: int = claims.reserve(drone, site, INGOT, 3, 5)
	assert(id > 0)
	assert(claims.begin_pickup(id, drone, 2.0))
	assert(claims.advance_pickup(id, drone, 3.0))
	assert(claims.collect_pickup(id, drone))
	return drone


func _checks() -> void:
	var discovery := PrototypeDroneStorageDiscovery.new()
	add_child(discovery)
	discovery.enable_isolated_discovery = true
	var claims := PrototypeDroneSupplierReservations.new()
	add_child(claims)
	claims.enable_isolated_reservations = true
	assert(claims.configure(discovery))
	var dock := _storage(Vector3(5, 0, 0), 18)
	var stock := _stock(dock)
	assert(discovery.register_dock(dock))
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	add_child(registry)
	registry.enable_isolated_site_registry = true
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var site := _site(Vector3(10, 0, 0))
	var other := _site(Vector3(11, 0, 0))
	assert(site.job.authorize() and other.job.authorize())
	var buffer := _buffer(registry, site, stock)
	var other_buffer := _buffer(registry, other, stock)
	var drone := _loaded(claims, site)
	assert(not drone.begin_delivery(site, registry, escrow))
	assert(not drone.unload_delivery() and not drone.advance_delivery(1.0))
	assert(drone.cargo_amount() == 3 and buffer.get_total_amount() == 0)
	print("PASS A: Default-off and no remote delivery")
	drone.enable_isolated_cargo_delivery = true
	assert(not drone.begin_delivery(other, registry, escrow))
	assert(not drone.begin_delivery(site, null, escrow))
	assert(not drone.begin_delivery(site, registry, null))
	assert(other_buffer.get_total_amount() == 0)
	print("PASS B: Original site identity and required services")
	var duplicate := BlueprintConstructionSiteStagingRegistry.new()
	add_child(duplicate)
	duplicate.enable_isolated_site_registry = true
	assert(not drone.begin_delivery(site, registry, escrow))
	duplicate.free()
	assert(drone.begin_delivery(site, registry, escrow))
	assert(not drone.begin_delivery(site, registry, escrow))
	assert(not drone.advance_flight(1.0))
	print("PASS C: Exclusive registry, one delivery and legacy flight isolation")
	assert(not drone.unload_delivery())
	assert(not drone.advance_delivery(-1.0))
	assert(drone.advance_delivery(1.0))
	assert(is_equal_approx(drone.global_position.x, 7.0) and is_equal_approx(drone.battery_units(), 33.0))
	assert(buffer.get_total_amount() == 0 and drone.cargo_amount() == 3)
	assert(not drone.unload_delivery())
	print("PASS D: Physical flight consumes battery and carries real stock")
	assert(drone.advance_delivery(2.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_DELIVERY)
	assert(is_equal_approx(drone.battery_units(), 30.0))
	assert(buffer.get_total_amount() == 0 and not drone.is_at_site())
	print("PASS E: Delivery arrival grants no legacy worker authority")
	site.global_position.x = 11.0
	assert(not drone.unload_delivery())
	assert(drone.cargo_amount() == 3 and drone.advance_delivery(1.0))
	assert(is_equal_approx(drone.battery_units(), 29.0))
	assert(drone.global_position.is_equal_approx(site.global_position + Vector3.UP * 2.0))
	print("PASS F: Moved site requires renewed physical arrival")
	var rev: int = buffer.get_mutation_revision()
	assert(drone.unload_delivery())
	assert(buffer.get_amount(INGOT) == 3 and buffer.get_mutation_revision() == rev + 1)
	assert(drone.cargo_amount() == 0 and drone.cargo_item() == null)
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DELIVERED)
	assert(not drone.unload_delivery() and not drone.begin_delivery(site, registry, escrow))
	assert(other_buffer.get_total_amount() == 0 and stock.get_amount(INGOT) == 15)
	print("PASS G: Exact-once unload into original owned staging")
	assert(site.job.state == ConstructionJob.State.QUEUED and site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"materials") and site.job.get_wait_reasons().has(&"workers") and site.job.get_wait_reasons().has(&"power"))
	assert(not drone.is_bound_to_site(site) and not drone.grants_worker_readiness())
	var eid: int = registry.reserve_for_site(site, escrow)
	assert(eid > 0 and int(escrow.held_materials(eid).get(INGOT, 0)) == 3)
	assert(buffer.get_total_amount() == 0 and site.job.get_progress() == 0.0)
	assert(site.job.cancel() and buffer.get_amount(INGOT) == 3)
	print("PASS H: Existing escrow can reserve delivered bill and refund on cancellation")
	var d2 := _loaded(claims, other)
	d2.enable_isolated_cargo_delivery = true
	assert(d2.begin_delivery(other, registry, escrow))
	assert(d2.advance_delivery(1.0))
	assert(other.job.cancel())
	assert(not d2.advance_delivery(1.0) and not d2.unload_delivery())
	assert(d2.cargo_amount() == 3 and other_buffer.get_total_amount() == 0)
	print("PASS I: Cancellation in flight keeps cargo and stops delivery")
	var s3 := _site(Vector3(10, 0, 0))
	assert(s3.job.authorize())
	var b3 := _buffer(registry, s3, stock)
	var d3 := _loaded(claims, s3)
	d3.enable_isolated_cargo_delivery = true
	assert(d3.begin_delivery(s3, registry, escrow) and d3.advance_delivery(3.0))
	assert(stock.transfer_to(b3, INGOT, 1) == 1)
	assert(not d3.unload_delivery() and d3.cargo_amount() == 3 and b3.get_amount(INGOT) == 1)
	assert(not d3.begin_delivery(s3, registry, escrow))
	print("PASS J: Competing stock reduces outstanding demand; whole load retained")
	var s4 := _site(Vector3(10, 0, 0))
	assert(s4.job.authorize())
	var b4 := _buffer(registry, s4, stock)
	var d4 := _loaded(claims, s4)
	d4.enable_isolated_cargo_delivery = true
	assert(d4.begin_delivery(s4, registry, escrow) and d4.advance_delivery(3.0))
	registry.enable_isolated_site_registry = false
	assert(not d4.unload_delivery() and d4.cargo_amount() == 3 and b4.get_total_amount() == 0)
	registry.enable_isolated_site_registry = true
	assert(d4.begin_delivery(s4, registry, escrow) and d4.advance_delivery(1.0))
	assert(stock.transfer_to(b4, INGOT, 3) == 3)
	var e4: int = registry.reserve_for_site(s4, escrow)
	assert(e4 > 0 and b4.get_total_amount() == 0)
	assert(not d4.unload_delivery() and d4.cargo_amount() == 3)
	print("PASS K: Disabled registry and already-escrowed bill block unload")
	# 18 initial: 2 source, 3 refunded staging, 1 competing staging,
	# 3 held escrow, three loaded drones of 3 each.
	assert(stock.get_amount(INGOT) + buffer.get_amount(INGOT) + other_buffer.get_amount(INGOT) + b3.get_amount(INGOT) + b4.get_amount(INGOT) + int(escrow.held_materials(e4).get(INGOT, 0)) + d2.cargo_amount() + d3.cargo_amount() + d4.cargo_amount() == 18)
	print("PASS L: Physical material conservation across storage, cargo, staging and escrow")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneSupplierReservations") == null and sandbox.get_node_or_null("PrototypeDroneSupplierReservations") == null)
	main.free()
	sandbox.free()
	print("PASS M: Normal scenes remain opt-out")
	print("ALL 13 E3D5C5X5B DRONE PHYSICAL DELIVERY TESTS PASSED")
