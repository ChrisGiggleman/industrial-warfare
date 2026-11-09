extends RefCounted
class_name ConstructionJob

# =============================================================================
# CONSTRUCTION JOB — AUTHORIZATION AND REQUIREMENT GATES
# =============================================================================
# Isolated construction policy. The existing ConstructionLifecycle owns time;
# this job owns authorization, readiness, pausing and cancellation.
# It never creates buildings, consumes inventory or allocates power.

signal state_changed(new_state: int)
signal job_completed
signal job_cancelled

enum State {
	PLANNED,
	QUEUED,
	CONSTRUCTING,
	PAUSED,
	COMPLETE,
	CANCELLED
}

var state: State = State.PLANNED

var _configured: bool = false
var _requires_power: bool = true
var _requires_materials: bool = true
var _requires_workers: bool = true

var _power_available: bool = false
var _materials_available: bool = false
var _workers_available: bool = false

var _lifecycle: ConstructionLifecycle = ConstructionLifecycle.new()


func _init() -> void:
	_lifecycle.construction_completed.connect(_on_lifecycle_completed)


# =============================================================================
# CONFIGURATION — FAIL-CLOSED UNTIL AUTHORIZED
# =============================================================================

func configure(
	duration: float,
	requires_power: bool = true,
	requires_materials: bool = true,
	requires_workers: bool = true
) -> bool:
	if _configured or state != State.PLANNED:
		return false
	if not _lifecycle.configure(duration):
		return false

	_requires_power = requires_power
	_requires_materials = requires_materials
	_requires_workers = requires_workers
	_configured = true
	return true


func authorize() -> bool:
	if not _configured or state != State.PLANNED:
		return false

	_set_state(State.QUEUED)
	_refresh_readiness()
	return true


# =============================================================================
# REQUIREMENT SNAPSHOT — NO RESOURCE OR POWER SIDE EFFECTS
# =============================================================================
# External services will eventually supply these availability flags. A true
# materials flag does not fabricate, reserve, or deliver actual items.

func set_availability(
	power_available: bool,
	materials_available: bool,
	workers_available: bool
) -> bool:
	if state == State.COMPLETE or state == State.CANCELLED:
		return false

	_power_available = power_available
	_materials_available = materials_available
	_workers_available = workers_available
	_refresh_readiness()
	return true


func get_wait_reasons() -> Array[StringName]:
	var reasons: Array[StringName] = []

	if _requires_power and not _power_available:
		reasons.append(&"power")
	if _requires_materials and not _materials_available:
		reasons.append(&"materials")
	if _requires_workers and not _workers_available:
		reasons.append(&"workers")

	return reasons


func _refresh_readiness() -> void:
	if state == State.PLANNED or state == State.COMPLETE or state == State.CANCELLED:
		return

	if not get_wait_reasons().is_empty():
		if state == State.CONSTRUCTING:
			_set_state(State.PAUSED)
		return

	if state == State.QUEUED:
		_set_state(State.CONSTRUCTING)
		_lifecycle.start()
	elif state == State.PAUSED:
		# Keep elapsed work. ConstructionLifecycle has no PAUSED state:
		# only this wrapper controls whether advance() may be called.
		_set_state(State.CONSTRUCTING)


# =============================================================================
# WORK, COMPLETION AND CANCELLATION
# =============================================================================

func advance(delta: float) -> void:
	if state != State.CONSTRUCTING:
		return
	_lifecycle.advance(delta)


func set_work_multiplier(multiplier: float) -> bool:
	if not _configured or state == State.COMPLETE or state == State.CANCELLED:
		return false
	return _lifecycle.set_work_multiplier(multiplier)


func cancel() -> bool:
	if state == State.COMPLETE or state == State.CANCELLED:
		return false

	# This model owns no delivered materials or placed entities. The future
	# construction site/service must handle salvage and footprint release.
	_set_state(State.CANCELLED)
	job_cancelled.emit()
	return true


func get_progress() -> float:
	return _lifecycle.get_progress()


func get_remaining_seconds() -> float:
	return _lifecycle.get_remaining_seconds()


func is_complete() -> bool:
	return state == State.COMPLETE


func _on_lifecycle_completed() -> void:
	if state != State.CONSTRUCTING:
		return
	_set_state(State.COMPLETE)
	job_completed.emit()


func _set_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(next_state)
