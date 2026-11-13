extends Node3D

# =============================================================================
# E3D5C4U — ISOLATED VISIBLE CONSTRUCTION WORKER FLIGHT
# =============================================================================
# Verifies path, cancellation and boundary without granting job readiness.
# No real worker capacity, collision avoidance, batteries or save/load.

func _ready() -> void:
	call_deferred("_run_checks")


func _site(definition: BuildingDefinition, label: String, at: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
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
	var site := _site(definition, "DroneTestSite", Vector3(8, 0, 0))
	assert(not drone.enable_isolated_drone)
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.IDLE)
	print("PASS A: Drone remains disabled and unassigned by default")

	drone.enable_isolated_drone = true
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS B: PLANNED blueprint refuses a physical worker assignment")

	assert(site.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: High priority alone cannot launch or authorize a drone")

	assert(site.job.authorize())
	assert(not drone.assign_to_site(site, Vector3.ZERO, 0.0, 2.0))
	assert(not drone.assign_to_site(site, Vector3.ZERO, 51.0, 2.0))
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 0.0))
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 11.0))
	assert(not drone.assign_to_site(site, Vector3(INF, 0, 0), 2.0, 2.0))
	print("PASS D: Invalid speed, altitude and launch coordinates fail closed")

	assert(drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(drone.global_position == Vector3.ZERO)
	assert(not drone.assign_to_site(site, Vector3.ZERO, 2.0, 2.0))
	print("PASS E: Explicit assignment launches one unique bound worker trip")

	assert(drone.get_node_or_null("DroneBody") is MeshInstance3D)
	assert(drone.get_node_or_null("DroneFrame") is MeshInstance3D)
	assert(not drone.is_at_site())
	assert(not drone.grants_worker_readiness())
	print("PASS F: Visible 3D drone has no construction or worker-slot authority")

	assert(not drone.advance_flight(0.0))
	assert(not drone.advance_flight(-1.0))
	assert(not drone.advance_flight(INF))
	assert(drone.global_position == Vector3.ZERO)
	print("PASS G: Invalid flight steps never move the drone")

	assert(drone.advance_flight(1.0))
	assert(is_equal_approx(drone.global_position.length(), 2.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(not drone.is_at_site())
	print("PASS H: Outbound motion is bounded by physical travel speed")

	var frozen: Vector3 = drone.global_position
	drone.enable_isolated_drone = false
	assert(not drone.advance_flight(10.0))
	assert(drone.global_position == frozen)
	assert(not drone.is_at_site())
	print("PASS I: Turning the isolated feature OFF freezes outbound flight")

	drone.enable_isolated_drone = true
	assert(drone.advance_flight(10.0))
	assert(drone.is_at_site())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.AT_SITE)
	assert(drone.global_position.is_equal_approx(site.global_position + Vector3.UP * 2.0))
	print("PASS J: Re-enabled drone reaches actual site's hover destination")

	assert(not drone.advance_flight(1.0))
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	assert(site.job.get_wait_reasons().has(&"workers"))
	print("PASS K: Hovering never starts construction or grants workers")

	site.global_position = Vector3(10, 0, 0)
	assert(not drone.is_at_site())
	assert(drone.advance_flight(0.5))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.OUTBOUND)
	assert(not drone.is_at_site())
	print("PASS L: Moving the site invalidates stale arrival and resumes travel")

	assert(drone.advance_flight(3.0))
	assert(drone.is_at_site())
	assert(drone.global_position.is_equal_approx(site.global_position + Vector3.UP * 2.0))
	print("PASS M: Drone reacquires the moved site without worker authorization")

	var other := _site(definition, "CompetingSite", Vector3(-8, 0, 0))
	assert(other.job.authorize())
	assert(not drone.assign_to_site(other, Vector3.ZERO, 2.0, 2.0))
	assert(other.job.get_wait_reasons().has(&"workers"))
	assert(other.job.state == ConstructionJob.State.QUEUED)
	print("PASS N: One assigned drone cannot be stolen by another blueprint")

	assert(site.job.cancel())
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING)
	assert(not drone.is_at_site())
	assert(not drone.grants_worker_readiness())
	print("PASS O: Cancellation revokes destination and commands safe return home")

	assert(drone.advance_flight(10.0))
	assert(drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED)
	assert(drone.global_position == Vector3.ZERO)
	assert(not drone.advance_flight(1.0))
	assert(not drone.assign_to_site(other, Vector3.ZERO, 2.0, 2.0))
	var main := (
		load("res://scenes/core/main.tscn") as PackedScene
	).instantiate()
	var sandbox := (
		load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	).instantiate()
	assert(main.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	assert(sandbox.get_node_or_null("PrototypeConstructionWorkerDrone") == null)
	main.free()
	sandbox.free()
	print("PASS P: Drone docks, claim cannot be reassigned, playable scenes opt out")

	print("ALL 16 E3D5C4U ISOLATED CONSTRUCTION DRONE FLIGHT TESTS PASSED")
	print("TEST ONLY: No pathfinding, real worker readiness, battery or live construction dispatch.")
