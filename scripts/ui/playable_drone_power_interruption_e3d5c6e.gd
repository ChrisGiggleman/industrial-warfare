extends "res://scripts/ui/playable_cancelled_site_recovery_e3d5c6c_stage_c.gd"
class_name PlayableDronePowerInterruptionE3d5c6e

## E3d5c6e Stage A — existing recovery adapter owns the ONE _process.
## Power-parking flags are set only for this exact newly opted-in scene.
const EXACT_POWER_PARKING := "res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn"


func _is_sandbox_path(path: String) -> bool:
	return path == EXACT_POWER_PARKING


func _direct_build_enabled() -> bool:
	return (
		enable_direct_build_authorization and _live(_scope)
		and _scope.scene_file_path == EXACT_POWER_PARKING
	)


func start() -> bool:
	if not super.start():
		return false
	# Inherited Stage C has fully configured custody/dispatch synchronously.
	# Do not start a new _process or a competing lifecycle dispatcher.
	set_process(false)
	if not has_verified_services() or not _recovery_configured:
		return false
	if _scope.scene_file_path != EXACT_POWER_PARKING or dispatch.has_lifecycle_assignment():
		return false
	drone.enable_isolated_power_parking = true
	dispatch.enable_isolated_power_parking = true
	set_process(true)
	_refresh_feedback()
	print("E3d5c6e Stage A power parking opt-in ready (ONE authoritative adapter tick)")
	return true


func _refresh_feedback() -> void:
	super._refresh_feedback()
	if not is_instance_valid(_status_label) or not is_instance_valid(drone) or not is_instance_valid(dispatch):
		return
	if not dispatch.enable_isolated_power_parking:
		return
	var state: String = "WORKING / IDLE"
	if drone._power_parked_assignment:
		if drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.DOCKED:
			state = "PARKED / AT HUB"
		elif drone.get_flight_state() == PrototypeConstructionWorkerDrone.FlightState.RETURNING:
			state = "PARKING / RETURNING"
		else:
			state = "RESUMING / ASSIGNED"
	_status_label.text += "\nBlackout worker: " + state
