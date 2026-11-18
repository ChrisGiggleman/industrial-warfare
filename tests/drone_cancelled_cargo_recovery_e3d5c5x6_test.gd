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
	var returns := PrototypeDroneReturnReservations.new()
	add_child(returns)
	returns.enable_isolated_reservations = true
	assert(returns.configure(discovery))
	var source := _storage(Vector3(5, 0, 0), 18)
	var near := _storage(Vector3(8, 0, 0), 0)
	near.allow_pickup = false
	var stock := _stock(source)
	var receiver := _stock(near)
	receiver.max_capacity = 3
	assert(discovery.register_dock(source) and discovery.register_dock(near))
	var registry := BlueprintConstructionSiteStagingRegistry.new()
	add_child(registry)
	registry.enable_isolated_site_registry = true
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var site := _site(Vector3(10, 0, 0))
	assert(site.job.authorize())
	var buffer := _buffer(registry, site, stock)
	var drone := _loaded(claims, site)
	drone.enable_isolated_cargo_delivery = true
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	returns.enable_isolated_cargo_recovery = true
	drone.enable_isolated_cargo_recovery = true
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.begin_delivery(site, registry, escrow) and drone.advance_delivery(2.0))
	assert(drone.global_position.is_equal_approx(Vector3(9, 2, 0)))
	assert(site.job.cancel())
	drone.enable_isolated_cargo_recovery = false
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.cargo_amount() == 3 and returns.reservation_count() == 0)
	print("PASS A: Default off and healthy delivery cannot be diverted")
	drone.enable_isolated_cargo_recovery = true
	var energy: float = drone.battery_units()
	assert(not returns.advance_cancelled_recovery(drone, -1.0))
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(receiver.get_reserved_return_space() == 3 and stock.get_reserved_return_space() == 0)
	assert(receiver.get_total_amount() == 0 and drone.battery_units() == energy)
	assert(not drone.advance_flight(1.0) and not drone.unload_delivery())
	print("PASS B: Nearest eligible storage reserves actual cargo without remote deposit")
	assert(receiver.add_item(ORE, 1) == 0 and receiver.is_full())
	assert(drone.cargo_amount() == 3 and returns.reservation_count() == 1)
	print("PASS C: Ordinary intake cannot take reserved cargo space")
	assert(returns.advance_cancelled_recovery(drone, 0.25))
	assert(is_equal_approx(drone.global_position.x, 8.5))
	assert(is_equal_approx(drone.battery_units(), energy - 0.5))
	assert(receiver.get_total_amount() == 0)
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_RECOVERY)
	assert(receiver.get_total_amount() == 0)
	print("PASS D: Physical approach is battery metered and not a deposit")
	near.position.x += 1.0
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.global_position.is_equal_approx(near.global_position))
	assert(receiver.get_total_amount() == 0 and drone.cargo_amount() == 3)
	print("PASS E: Moved dock requires renewed arrival")
	var revision: int = receiver.get_mutation_revision()
	assert(returns.advance_cancelled_recovery(drone, 1.0))
	assert(drone.cargo_amount() == 0 and drone.cargo_item() == null)
	assert(receiver.get_amount(INGOT) == 3 and receiver.get_mutation_revision() == revision + 1)
	assert(receiver.get_reserved_return_space() == 0 and returns.reservation_count() == 0)
	print("PASS F: Reserved capacity becomes physical stock exactly once")
	assert(returns.advance_cancelled_recovery(drone, 20.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.global_position.is_equal_approx(Vector3(0, 2, 0)))
	assert(is_equal_approx(drone.battery_units(), 20.0))
	assert(not returns.advance_cancelled_recovery(drone, 1.0))
	assert(receiver.get_amount(INGOT) == 3 and buffer.get_total_amount() == 0)
	print("PASS G: Empty metered home return cannot redeposit or reassign")
	var s2 := _site(Vector3(10, 0, 0))
	assert(s2.job.authorize())
	var b2 := _buffer(registry, s2, stock)
	var d2 := _loaded(claims, s2)
	d2.enable_isolated_cargo_recovery = true
	assert(s2.job.cancel())
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	assert(stock.get_reserved_return_space() == 3)
	source.allow_returns = false
	assert(not returns.advance_cancelled_recovery(d2, 1.0))
	assert(stock.get_reserved_return_space() == 0 and d2.cargo_amount() == 3)
	assert(d2.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RECOVERY_WAIT)
	assert(not returns.advance_cancelled_recovery(d2, 1.0))
	print("PASS H: Full alternate and invalidated source retain cargo safely")
	var recovered := InventoryComponent.new()
	add_child(recovered)
	assert(receiver.transfer_to(recovered, INGOT, 3) == 3)
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	assert(receiver.get_reserved_return_space() == 3)
	returns.enable_isolated_cargo_recovery = false
	assert(not returns.advance_cancelled_recovery(d2, 1.0))
	assert(receiver.get_reserved_return_space() == 0 and d2.cargo_amount() == 3)
	returns.enable_isolated_cargo_recovery = true
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	print("PASS I: Restored eligibility reroutes; disable releases capacity without losing cargo")
	receiver.max_capacity = 2
	assert(not returns.advance_cancelled_recovery(d2, 1.0))
	assert(receiver.get_reserved_return_space() == 0 and d2.cargo_amount() == 3)
	receiver.max_capacity = 3
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	near.queue_free()
	assert(not returns.advance_cancelled_recovery(d2, 1.0))
	assert(d2.cargo_amount() == 3 and returns.reservation_count() == 0)
	print("PASS J: Capacity shrink and deleted dock release stale claims")
	source.allow_returns = true
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	assert(stock.get_reserved_return_space() == 3)
	source.position.x = 100.0
	assert(not returns.advance_cancelled_recovery(d2, 1.0))
	assert(d2.cargo_amount() == 3 and stock.get_reserved_return_space() == 0)
	source.position.x = 0.0
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	assert(returns.advance_cancelled_recovery(d2, 1.0))
	assert(stock.get_amount(INGOT) == 15 and d2.cargo_amount() == 0)
	print("PASS K: Unreachable receiver fails closed; restored route deposits actual stock")
	assert(stock.get_amount(INGOT) + recovered.get_amount(INGOT) + d2.cargo_amount() + drone.cargo_amount() + buffer.get_total_amount() + b2.get_total_amount() == 18)
	assert(not d2.grants_worker_readiness() and not d2.is_bound_to_site(s2))
	print("PASS L: All original ingots conserved and no worker privileges granted")
	var empty := _drone()
	empty.enable_isolated_cargo_recovery = true
	assert(not returns.advance_cancelled_recovery(empty, 1.0))
	assert(returns.reservation_count() == 0)
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneReturnReservations") == null and sandbox.get_node_or_null("PrototypeDroneReturnReservations") == null)
	main.free()
	sandbox.free()
	print("PASS M: Empty drone and normal scenes cannot activate recovery")
	print("ALL 13 E3D5C5X6 CANCELED CARGO RECOVERY TESTS PASSED")
