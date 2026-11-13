extends Node3D

# =============================================================================
# E3D5C4X — ISOLATED BATTERY / HOME CHARGING / RETURN-RESERVE FLIGHT
# =============================================================================
# Power for charging is an explicit fixture flag, NOT grid-verified wattage.
# Battery drones remain ONE-SHOT even after charging; no fleet reuse allowed.

func _ready() -> void:
	call_deferred("_run_checks")


func _site(definition: BuildingDefinition, name_text: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = name_text
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.global_position = at
	site.set_process(false)
	return site


func _run_checks() -> void:
	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var drone := PrototypeConstructionWorkerDrone.new()
	add_child(drone)
	var site := _site(definition, "BatteryTestSite", Vector3(6, 0, 0))
	assert(not drone.enable_isolated_drone)
	assert(not drone.enable_isolated_battery)
	assert(not drone.configure_battery(40.0, 6.0, 1.0, 3.0))
	assert(drone.battery_units() == -1.0)
	print("PASS A: Battery mode defaults OFF; no phantom charge is provisioned")

	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: Battery and High priority cannot override missing authorization")

	assert(not drone.configure_battery(0.0, 0.0, 1.0, 3.0))
	assert(not drone.configure_battery(40.0, -1.0, 1.0, 3.0))
	assert(not drone.configure_battery(40.0, 41.0, 1.0, 3.0))
	assert(not drone.configure_battery(40.0, 6.0, 0.0, 3.0))
	assert(not drone.configure_battery(40.0, 6.0, 1.0, 0.0))
	assert(not drone.configure_battery(INF, 6.0, 1.0, 3.0))
	print("PASS C: Invalid capacity, charge, rates and nonfinite values are rejected")

	assert(drone.configure_battery(40.0, 6.0, 1.0, 3.0))
	assert(not drone.configure_battery(40.0, 40.0, 1.0, 3.0))
	assert(is_equal_approx(drone.battery_units(), 6.0))
	assert(is_equal_approx(drone.battery_capacity(), 40.0))
	print("PASS D: Battery config latches once and keeps exact starting energy")

	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(site.job.authorize())
	assert(not drone.has_round_trip_energy(site, 2.0))
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	print("PASS E: Low-charge worker refuses launch even for authorized High job")

	assert(not drone.charge_at_home(5.0, false))
	assert(not drone.charge_at_home(-1.0, true))
	assert(not drone.charge_at_home(INF, true))
	assert(is_equal_approx(drone.battery_units(), 6.0))
	print("PASS F: Unpowered dock and invalid time cannot create battery units")

	assert(drone.charge_at_home(3.0, true))
	assert(is_equal_approx(drone.battery_units(), 15.0))
	assert(drone.has_round_trip_energy(site, 2.0))
	print("PASS G: Powered home dock charges to sufficient round-trip reserve")

	assert(drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(drone.is_bound_to_site(site))
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	print("PASS H: Charged worker makes one exact authorized launch")

	assert(drone.advance_flight(1.0))
	assert(is_equal_approx(drone.global_position.length(), 2.0))
	assert(is_equal_approx(drone.battery_units(), 13.0))
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS I: Actual two-meter flight consumes exactly two battery units")

	var frozen: Vector3 = drone.global_position
	drone.enable_isolated_battery = false
	assert(not drone.advance_flight(1.0))
	assert(drone.global_position == frozen)
	assert(is_equal_approx(drone.battery_units(), 13.0))
	assert(not drone.is_at_site())
	print("PASS J: Turning off configured battery cannot enable free outbound motion")

	drone.enable_isolated_battery = true
	assert(drone.advance_flight(10.0))
	assert(drone.is_at_site())
	var arrival_distance: float = Vector3(6, 2, 0).length()
	assert(is_equal_approx(drone.battery_units(), 15.0 - arrival_distance))
	assert(not drone.grants_worker_readiness())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	print("PASS K: Drone arrives using metered energy; arrival alone has no worker authority")

	var at_site_charge: float = drone.battery_units()
	assert(not drone.charge_at_home(10.0, true))
	assert(is_equal_approx(drone.battery_units(), at_site_charge))
	print("PASS L: Charging is forbidden while airborne, even with power")

	site.global_position = Vector3(30, 0, 0)
	assert(not drone.is_at_site())
	assert(not drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(is_equal_approx(drone.battery_units(), at_site_charge))
	print("PASS M: Distant moved site triggers a conservative return before reserve loss")

	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.global_position == Vector3.ZERO)
	assert(is_equal_approx(drone.battery_units(), 15.0 - 2.0 * arrival_distance))
	print("PASS N: Metered return docks physically and preserves exact energy accounting")

	assert(not drone.charge_at_home(10.0, false))
	assert(drone.battery_units() > 0.0)
	assert(drone.battery_units() < drone.battery_capacity())
	print("PASS O: Docked drone does not recharge without explicit powered supply")

	assert(drone.charge_at_home(50.0, true))
	assert(is_equal_approx(drone.battery_units(), 40.0))
	assert(not drone.charge_at_home(1.0, true))
	print("PASS P: Powered recharge caps at battery capacity with no overfill")

	var second := _site(definition, "SecondAuthorizedJob", Vector3(2, 0, 0))
	assert(second.job.authorize())
	assert(not drone.assign_to_site(second, Vector3.ZERO, 2.0, 2.0))
	assert(not drone.is_bound_to_site(second))
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(second.job.state == ConstructionJob.State.QUEUED)
	print("PASS Q: Recharged one-shot worker cannot inherit another job's assignment")

	assert(site.job.cancel())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(not drone.assign_to_site(second, Vector3.ZERO, 2.0, 2.0))
	assert(not drone.grants_worker_readiness())
	print("PASS R: Site cancellation cannot unlock a docked worker or claim")

	var stock_worker := PrototypeConstructionWorkerDrone.new()
	stock_worker.enable_isolated_drone = true
	add_child(stock_worker)
	assert(not stock_worker.enable_isolated_battery)
	assert(stock_worker.assign_to_site(second, Vector3.ZERO, 2.0, 2.0))
	assert(stock_worker.advance_flight(10.0))
	assert(stock_worker.is_at_site())
	assert(stock_worker.battery_units() == -1.0)
	assert(not stock_worker.grants_worker_readiness())
	print("PASS S: Legacy opt-out drone flight stays unchanged and non-authoritative")

	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	assert(main.get_node_or_null("PrototypeConstructionDroneFleet") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionDroneFleet") == null)
	main.free()
	sandbox.free()
	print("PASS T: Battery experiment changes neither playable scene nor real worker authority")

	print("ALL 20 E3D5C4X DRONE BATTERY AND DOCKING TESTS PASSED")
	print("TEST ONLY: Straight-line flight, externally supplied charging power; no reuse, obstacle avoidance or save.")
