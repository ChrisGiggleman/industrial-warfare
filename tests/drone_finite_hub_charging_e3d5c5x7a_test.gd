extends Node3D

const STORAGE = preload("res://data/buildings/test_storage.tres")


func _ready() -> void:
	call_deferred("_checks")


func _drone(start: float, capacity: float, at: Vector3 = Vector3(0, 2, 0)) -> PrototypeConstructionWorkerDrone:
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	drone.global_position = at
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	assert(drone.configure_battery(capacity, start, 1.0, 4.0))
	return drone


func _site(at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(STORAGE))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	assert(site.job.authorize())
	return site


func _checks() -> void:
	var network := ConstructionPowerCoverageNetwork.new()
	var power := PrototypeConstructionPowerAllocator.new()
	var charging := PrototypeDroneHubCharging.new()
	for service: Node in [network, power, charging]:
		add_child(service)
	assert(power.configure(network))
	var hub := (load("res://scenes/buildings/prototype_main_hub.tscn") as PackedScene).instantiate() as PrototypePowerStructure
	add_child(hub)
	hub.global_position = Vector3.ZERO
	assert(network.register_node(hub.get_power_node()))
	var a := _drone(4.0, 10.0)
	var b := _drone(0.0, 20.0)
	assert(not charging.enable_isolated_charging)
	assert(not a.enable_isolated_finite_charging)
	assert(not charging.configure(hub, power))
	assert(charging.advance_charging(1.0) == 0.0)
	print("PASS A: Finite charging defaults off")
	charging.enable_isolated_charging = true
	assert(charging.configure(hub, power))
	assert(not charging.configure(hub, power))
	var duplicate := PrototypeDroneHubCharging.new()
	add_child(duplicate)
	duplicate.enable_isolated_charging = true
	assert(not duplicate.configure(hub, power))
	assert(duplicate.advance_charging(1.0) == 0.0)
	print("PASS B: Only one charging authority in the scope")
	assert(not charging.register_drone(a))
	a.enable_isolated_finite_charging = true
	b.enable_isolated_finite_charging = true
	var wrong := _drone(1.0, 10.0, Vector3(3, 2, 0))
	wrong.enable_isolated_finite_charging = true
	assert(not charging.register_drone(wrong))
	assert(charging.register_drone(a) and charging.register_drone(b))
	assert(not charging.register_drone(a))
	assert(not a.charge_at_home(10.0, true) and not b.charge_at_home(10.0, true))
	print("PASS C: Exact home enrollment and no legacy boolean bypass")
	assert(charging.advance_charging(-1.0) == 0.0)
	assert(charging.advance_charging(INF) == 0.0)
	assert(a.battery_units() == 4.0 and b.battery_units() == 0.0)
	print("PASS D: Invalid ticks do not create energy")
	var build := _site(Vector3(1, 0, 0))
	assert(power.track_site(build, 7))
	assert(power.get_allocated_units(build) == 7)
	assert(power.spare_generation_for(hub.get_power_node()) == 5)
	assert(is_equal_approx(charging.advance_charging(1.0), 5.0))
	assert(is_equal_approx(a.battery_units(), 8.0) and is_equal_approx(b.battery_units(), 1.0))
	assert(power.get_allocated_units(build) == 7 and build.job.get_progress() == 0.0)
	print("PASS E: Construction allocation keeps precedence; drones share five units")
	assert(is_equal_approx(charging.advance_charging(2.0), 10.0))
	assert(is_equal_approx(a.battery_units(), 10.0) and is_equal_approx(b.battery_units(), 9.0))
	print("PASS F: Battery rate and headroom constrain the shared tick budget")
	assert(hub.set_generator_enabled(false))
	assert(power.spare_generation_for(hub.get_power_node()) == 0)
	assert(charging.advance_charging(10.0) == 0.0 and b.battery_units() == 9.0)
	assert(hub.set_generator_enabled(true))
	assert(power.spare_generation_for(hub.get_power_node()) == 5)
	print("PASS G: Generator outage stops charging and restoration restores budget")
	assert(build.job.cancel())
	assert(power.spare_generation_for(hub.get_power_node()) == 12)
	assert(is_equal_approx(charging.advance_charging(1.0), 4.0))
	assert(b.battery_units() == 13.0)
	print("PASS H: Released construction allocation restores spare rate, not free overfill")
	b.global_position.x = 0.5
	assert(charging.advance_charging(1.0) == 0.0)
	b.global_position.x = 0.0
	hub.global_position.x = 1.0
	assert(charging.advance_charging(1.0) == 0.0)
	hub.global_position.x = 0.0
	print("PASS I: Away from registered home or moved Hub refuses charge")
	b.enable_isolated_finite_charging = false
	assert(not b.charge_at_home(10.0, true))
	assert(charging.advance_charging(1.0) == 0.0)
	b.enable_isolated_finite_charging = true
	charging.enable_isolated_charging = false
	assert(charging.advance_charging(1.0) == 0.0)
	assert(not b.charge_at_home(10.0, true))
	charging.enable_isolated_charging = true
	print("PASS J: Feature loss cannot restore boolean charging bypass")
	var foreign_allocator := PrototypeConstructionPowerAllocator.new()
	add_child(foreign_allocator)
	assert(charging.advance_charging(1.0) == 0.0)
	foreign_allocator.free()
	assert(is_equal_approx(charging.advance_charging(10.0), 7.0))
	assert(b.battery_units() == 20.0 and charging.advance_charging(1.0) == 0.0)
	print("PASS K: Ambiguous allocator fails closed; full batteries do not overfill")
	var flight := _site(Vector3(2, 0, 0))
	assert(a.assign_to_site(flight, Vector3(0, 2, 0), 2.0, 2.0))
	assert(a.advance_flight(0.5))
	assert(a.battery_units() == 9.0 and charging.advance_charging(1.0) == 0.0)
	assert(flight.job.cancel())
	assert(a.advance_flight(1.0))
	assert(a.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(a.battery_units() == 8.0)
	assert(is_equal_approx(charging.advance_charging(1.0), 2.0))
	assert(a.battery_units() == 10.0 and a.completed_rearms() == 0)
	print("PASS L: Metered flight, no airborne charging, docked recharge without reuse")
	charging.free()
	assert(not a.charge_at_home(10.0, true))
	assert(not b.charge_at_home(10.0, true))
	var main := (load("res://scenes/core/main.tscn") as PackedScene).instantiate()
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate()
	assert(main.get_node_or_null("PrototypeDroneHubCharging") == null and sandbox.get_node_or_null("PrototypeDroneHubCharging") == null)
	main.free()
	sandbox.free()
	print("PASS M: Service removal stays latched; normal scenes remain opt-out")
	print("ALL 13 E3D5C5X7A FINITE HUB CHARGING TESTS PASSED")
