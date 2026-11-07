extends Node

# =============================================================================
# CONSTRUCTION LIFECYCLE — ISOLATED STATE AND TIMING REGRESSION
# =============================================================================

func _ready() -> void:
	var build := ConstructionLifecycle.new()
	assert(build.configure(10.0))
	assert(build.state == ConstructionLifecycle.State.PLANNED)
	assert(not build.is_operational())
	assert(is_equal_approx(build.get_progress(), 0.0))
	print("PASS A: New construction begins planned and inactive")

	assert(build.start())
	assert(build.state == ConstructionLifecycle.State.CONSTRUCTING)
	build.advance(2.5)
	assert(is_equal_approx(build.get_progress(), 0.25))
	assert(is_equal_approx(build.get_remaining_seconds(), 7.5))
	assert(not build.is_operational())
	print("PASS B: Construction advances with elapsed time")

	assert(build.set_work_multiplier(2.0))
	build.advance(2.5)
	assert(is_equal_approx(build.get_progress(), 0.75))
	assert(not build.is_operational())
	print("PASS C: Worker speed multiplier accelerates construction")

	var completed := [0]
	build.construction_completed.connect(func() -> void: completed[0] += 1)
	build.advance(2.0)
	assert(build.is_operational())
	assert(is_equal_approx(build.get_progress(), 1.0))
	assert(is_equal_approx(build.get_remaining_seconds(), 0.0))
	assert(completed[0] == 1)
	build.advance(100.0)
	assert(completed[0] == 1)
	assert(not build.start())
	print("PASS D: Completion occurs once and unlocks operational state")

	assert(not build.configure(-5.0))
	assert(build.is_operational())
	assert(not build.set_work_multiplier(-1.0))
	assert(not build.set_work_multiplier(0.0))
	assert(build.configure(4.0))
	assert(build.start())
	build.advance(-1.0)
	build.advance(0.0)
	assert(is_equal_approx(build.get_progress(), 0.0))
	print("PASS E: Invalid inputs and nonpositive time cannot corrupt progress")

	var instant := ConstructionLifecycle.new()
	var immediate := [0]
	instant.construction_completed.connect(func() -> void: immediate[0] += 1)
	assert(instant.configure(0.0))
	assert(instant.start())
	assert(instant.is_operational())
	assert(immediate[0] == 1)
	print("PASS F: Zero-duration construction completes safely")

	print("ALL 6 CONSTRUCTION LIFECYCLE FOUNDATION TESTS PASSED")
