extends RefCounted
class_name ConstructionLifecycle

# =============================================================================
# CONSTRUCTION LIFECYCLE — TIME-BASED BUILDING ACTIVATION FOUNDATION
# =============================================================================
# Owns construction timing and state only. Does not instantiate buildings,
# consume materials, start production, or change world placement.
# World integration will attach this model after independent validation.

signal progress_changed(progress: float)
signal construction_completed

enum State {
	PLANNED,
	CONSTRUCTING,
	COMPLETE
}

var state: State = State.PLANNED
var required_seconds: float = 0.0
var elapsed_seconds: float = 0.0
var work_multiplier: float = 1.0


func configure(duration: float) -> bool:
	if not is_finite(duration) or duration < 0.0:
		return false
	state = State.PLANNED
	required_seconds = duration
	elapsed_seconds = 0.0
	work_multiplier = 1.0
	return true


func start() -> bool:
	if state != State.PLANNED:
		return false
	state = State.CONSTRUCTING
	if required_seconds <= 0.0:
		_complete()
	return true


func advance(delta: float) -> void:
	if state != State.CONSTRUCTING:
		return
	if not is_finite(delta) or delta <= 0.0:
		return
	if not is_finite(work_multiplier) or work_multiplier <= 0.0:
		return
	elapsed_seconds = minf(
		required_seconds, elapsed_seconds + delta * work_multiplier
	)
	progress_changed.emit(get_progress())
	if elapsed_seconds >= required_seconds:
		_complete()


func set_work_multiplier(value: float) -> bool:
	if not is_finite(value) or value <= 0.0:
		return false
	work_multiplier = value
	return true


func get_progress() -> float:
	if state == State.COMPLETE:
		return 1.0
	if required_seconds <= 0.0:
		return 0.0
	return clampf(elapsed_seconds / required_seconds, 0.0, 1.0)


func is_operational() -> bool:
	return state == State.COMPLETE


func get_remaining_seconds() -> float:
	return maxf(0.0, required_seconds - elapsed_seconds)


func _complete() -> void:
	if state == State.COMPLETE:
		return
	elapsed_seconds = required_seconds
	state = State.COMPLETE
	progress_changed.emit(1.0)
	construction_completed.emit()
