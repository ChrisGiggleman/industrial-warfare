extends Node

# =============================================================================
# CONSTRUCTION JOB — ISOLATED BLUEPRINT AUTHORIZATION REGRESSION
# =============================================================================
# Tests job policy only. No building scenes, inventories, power network or
# runtime WorldInteraction behavior are modified by these assertions.

func _ready() -> void:
	var job := ConstructionJob.new()
	assert(job.state == ConstructionJob.State.PLANNED)
	assert(not job.authorize())
	assert(not job.configure(-1.0))
	assert(job.configure(10.0))
	assert(not job.configure(5.0))
	assert(not job.is_complete())
	print("PASS A: Unconfigured and invalid construction jobs fail safely")

	assert(job.set_availability(true, true, true))
	job.advance(100.0)
	assert(job.state == ConstructionJob.State.PLANNED)
	assert(is_zero_approx(job.get_progress()))
	print("PASS B: Even ready blueprints cannot build before authorization")

	assert(job.set_availability(false, false, false))
	assert(job.authorize())
	assert(job.state == ConstructionJob.State.QUEUED)
	assert(job.get_wait_reasons() == [
		&"power", &"materials", &"workers"
	])
	job.advance(100.0)
	assert(is_zero_approx(job.get_progress()))
	print("PASS C: Authorized work queues when all three requirements are missing")

	assert(job.set_availability(true, true, false))
	assert(job.state == ConstructionJob.State.QUEUED)
	assert(job.get_wait_reasons() == [&"workers"])
	assert(is_zero_approx(job.get_progress()))
	print("PASS D: Partial readiness reports the remaining worker blocker")

	var finished := [0]
	job.job_completed.connect(func() -> void: finished[0] += 1)
	assert(job.set_availability(true, true, true))
	assert(job.state == ConstructionJob.State.CONSTRUCTING)
	job.advance(3.0)
	assert(is_equal_approx(job.get_progress(), 0.3))
	assert(is_equal_approx(job.get_remaining_seconds(), 7.0))
	print("PASS E: All gates ready starts authorized time-based construction")

	assert(job.set_availability(false, true, true))
	assert(job.state == ConstructionJob.State.PAUSED)
	assert(job.get_wait_reasons() == [&"power"])
	job.advance(100.0)
	assert(is_equal_approx(job.get_progress(), 0.3))
	print("PASS F: Power loss pauses work without discarding progress")

	assert(job.set_availability(true, true, true))
	assert(job.state == ConstructionJob.State.CONSTRUCTING)
	assert(is_equal_approx(job.get_progress(), 0.3))
	assert(job.set_availability(true, true, false))
	assert(job.state == ConstructionJob.State.PAUSED)
	job.advance(4.0)
	assert(is_equal_approx(job.get_progress(), 0.3))
	print("PASS G: Requirements can resume and pause work repeatedly")

	assert(job.set_availability(true, true, true))
	assert(job.set_work_multiplier(2.0))
	assert(not job.set_work_multiplier(0.0))
	job.advance(3.5)
	assert(job.is_complete())
	assert(is_equal_approx(job.get_progress(), 1.0))
	assert(finished[0] == 1)
	print("PASS H: Worker multiplier completes exactly once after resuming")

	job.advance(100.0)
	assert(finished[0] == 1)
	assert(not job.authorize())
	assert(not job.cancel())
	assert(not job.set_availability(false, false, false))
	assert(not job.set_work_multiplier(3.0))
	assert(job.is_complete())
	print("PASS I: Completed jobs reject further mutations or duplicate completion")

	var planned := ConstructionJob.new()
	var cancelled := [0]
	planned.job_cancelled.connect(func() -> void: cancelled[0] += 1)
	assert(planned.configure(10.0))
	assert(planned.cancel())
	assert(planned.state == ConstructionJob.State.CANCELLED)
	assert(not planned.authorize())
	assert(not planned.cancel())
	assert(cancelled[0] == 1)
	print("PASS J: Planned blueprints can cancel only once")

	var queued := ConstructionJob.new()
	assert(queued.configure(10.0))
	assert(queued.authorize())
	assert(queued.state == ConstructionJob.State.QUEUED)
	assert(queued.cancel())
	assert(queued.state == ConstructionJob.State.CANCELLED)
	assert(not queued.set_availability(true, true, true))
	queued.advance(100.0)
	assert(is_zero_approx(queued.get_progress()))
	print("PASS K: Cancelling queued work never starts construction")

	var active := ConstructionJob.new()
	assert(active.configure(10.0, false, false, false))
	assert(active.authorize())
	active.advance(4.0)
	assert(is_equal_approx(active.get_progress(), 0.4))
	assert(active.cancel())
	active.advance(100.0)
	assert(active.state == ConstructionJob.State.CANCELLED)
	assert(is_equal_approx(active.get_progress(), 0.4))
	print("PASS L: Cancelling active work freezes elapsed progress")

	var paused := ConstructionJob.new()
	assert(paused.configure(10.0))
	assert(paused.set_availability(true, true, true))
	assert(paused.authorize())
	paused.advance(2.0)
	assert(paused.set_availability(false, true, true))
	assert(paused.state == ConstructionJob.State.PAUSED)
	assert(paused.cancel())
	assert(not paused.set_availability(true, true, true))
	paused.advance(100.0)
	assert(paused.state == ConstructionJob.State.CANCELLED)
	assert(is_equal_approx(paused.get_progress(), 0.2))
	print("PASS M: Cancelling paused work cannot resume or complete")

	var bootstrap := ConstructionJob.new()
	var immediate := [0]
	bootstrap.job_completed.connect(func() -> void: immediate[0] += 1)
	assert(bootstrap.configure(0.0, false, false, false))
	assert(bootstrap.authorize())
	assert(bootstrap.is_complete())
	assert(immediate[0] == 1)
	bootstrap.advance(100.0)
	assert(immediate[0] == 1)
	print("PASS N: Explicit bootstrap exception supports safe instant test jobs")

	print("ALL 14 CONSTRUCTION JOB FOUNDATION TESTS PASSED")
