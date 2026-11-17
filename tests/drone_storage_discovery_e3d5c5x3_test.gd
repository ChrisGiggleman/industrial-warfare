extends Node3D

const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")
const ORE = preload("res://data/items/test_ore.tres")

func _ready() -> void:
	call_deferred("_checks")


func _storage(scope: Node3D, at: Vector3, stock: int) -> PrototypeDroneStorageDock:
	var building := STORAGE.building_scene.instantiate() as Node3D
	scope.add_child(building)
	building.global_position = at
	(building.get_node("BuildingRuntime") as BuildingRuntime).initialize(STORAGE)
	var inventory := building.get_node("InventoryComponent") as InventoryComponent
	inventory.max_capacity = 20
	if stock > 0:
		assert(inventory.add_item(INGOT, stock) == stock)
	var dock := PrototypeDroneStorageDock.new()
	building.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	return dock


func _stock(dock: PrototypeDroneStorageDock) -> InventoryComponent:
	return dock.get_parent().get_node("InventoryComponent") as InventoryComponent


func _drone(energy: float) -> PrototypeConstructionWorkerDrone:
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	drone.global_position = Vector3(0, 2, 0)
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	assert(drone.configure_battery(40.0, energy, 1.0, 4.0))
	return drone


func _checks() -> void:
	var service := PrototypeDroneStorageDiscovery.new()
	add_child(service)
	var far := _storage(self, Vector3(-4, 0, 0), 10)
	var mid := _storage(self, Vector3(3, 0, 0), 10)
	var near := _storage(self, Vector3(8, 0, 0), 10)
	var drone := _drone(40.0)
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(STORAGE))
	add_child(site)
	site.global_position = Vector3(10, 0, 0)
	site.set_process(false)
	assert(not service.register_dock(far))
	assert(service.find_pickup(drone, site, INGOT, 3, 5).is_empty())
	service.enable_isolated_discovery = true
	print("PASS A: Discovery defaults off and has no automatic enrollment")
	var ghost := _storage(self, Vector3(9, 0, 0), 10)
	ghost.get_parent().add_to_group("construction_preview")
	var foreign := Node3D.new()
	add_child(foreign)
	var outside := _storage(foreign, Vector3(9, 0, 0), 10)
	assert(not service.register_dock(ghost) and not service.register_dock(outside))
	assert(service.register_dock(far) and service.register_dock(mid) and service.register_dock(near))
	assert(not service.register_dock(near))
	print("PASS B: Explicit same-world completed Storage and exclusive dock identity")
	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(service.find_pickup(drone, site, INGOT, 3, 5).is_empty())
	assert(site.job.state == ConstructionJob.State.PLANNED)
	assert(site.job.authorize())
	assert(service.find_pickup(drone, site, ORE, 1, 5).is_empty())
	assert(service.find_pickup(drone, site, INGOT, 4, 5).is_empty())
	assert(service.find_pickup(drone, site, INGOT, 3, 2).is_empty())
	print("PASS C: Explicit authorization, correct bill item, amount and cargo bound")
	var result := service.find_pickup(drone, site, INGOT, 3, 5)
	assert(result["dock"] == near and is_equal_approx(float(result["energy_required"]), 20.25))
	print("PASS D: Full trip energy then distance to site favors nearby eligible Storage")
	near.minimum_retained = 8
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == mid)
	near.minimum_retained = 0
	near.available = false
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == mid)
	near.available = true
	near.allow_pickup = false
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == mid)
	near.allow_pickup = true
	assert(_stock(near).remove_item(INGOT, 8))
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == mid)
	assert(_stock(near).add_item(INGOT, 8) == 8)
	print("PASS E: Retained stock, busy dock, permissions and insufficient inventory exclude suppliers")
	var twin := _storage(self, Vector3(8, 0, 0), 10)
	assert(service.register_dock(twin))
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == near)
	print("PASS F: Equal travel metrics retain stable registration order")
	var weak := _drone(20.0)
	assert(service.find_pickup(weak, site, INGOT, 3, 5).is_empty())
	var exact := _drone(20.25)
	assert(service.find_pickup(exact, site, INGOT, 3, 5)["dock"] == near)
	var invalid: Array[Vector3] = [Vector3(INF, 0, 0)]
	assert(drone.estimate_route_energy(invalid) < 0.0)
	print("PASS G: Real battery forecast includes home return and safety margin")
	var returned := service.find_return(drone, INGOT, 3)
	assert(returned["dock"] == mid)
	assert(_stock(mid).add_item(INGOT, 9) == 9)
	assert(service.find_return(drone, INGOT, 3)["dock"] == far)
	far.allow_returns = false
	assert(service.find_return(drone, INGOT, 3)["dock"] == near)
	far.allow_returns = true
	print("PASS H: Return chooses nearest compatible available whole-load space")
	var health := near.get_parent().get_node("BuildingHealthComponent") as BuildingHealthComponent
	health.take_damage(health.current_health)
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == twin)
	twin.enable_isolated_dock = false
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == mid)
	print("PASS I: Depleted buildings and disabled docks are rejected dynamically")
	var pinned := _stock(mid)
	mid.get_parent().remove_child(pinned)
	var replacement := InventoryComponent.new()
	replacement.name = "InventoryComponent"
	mid.get_parent().add_child(replacement)
	assert(replacement.add_item(INGOT, 10) == 10)
	assert(service.find_pickup(drone, site, INGOT, 3, 5)["dock"] == far)
	pinned.free()
	far.get_parent().queue_free()
	assert(service.find_pickup(drone, site, INGOT, 3, 5).is_empty())
	assert(service.find_return(drone, INGOT, 3).is_empty())
	print("PASS J: Replaced stock identity and queued deletion cannot reuse stale enrollment")
	assert(site.job.cancel())
	assert(service.find_pickup(drone, site, INGOT, 3, 5).is_empty())
	service.enable_isolated_discovery = false
	assert(service.find_return(drone, INGOT, 1).is_empty())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	assert(drone.global_position == Vector3(0, 2, 0) and drone.battery_units() == 40.0)
	assert(_stock(near).get_amount(INGOT) == 10 and _stock(twin).get_amount(INGOT) == 10)
	assert(site.job.get_progress() == 0.0)
	print("PASS K: Queries never move drones, debit inventory, or grant job readiness")
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneStorageDiscovery") == null)
	assert(sandbox.get_node_or_null("PrototypeDroneStorageDiscovery") == null)
	main.free()
	sandbox.free()
	print("PASS L: Production scenes remain opted out")
	print("ALL 12 E3D5C5X3 DRONE STORAGE DISCOVERY TESTS PASSED")
