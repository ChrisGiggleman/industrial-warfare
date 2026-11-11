extends Node3D

# =============================================================================
# E3D5B — FINITE CONSTRUCTION SLOTS AND PRIORITY DISPATCH
# =============================================================================
# Isolated scheduler: artificial readiness snapshots are provided ONLY by
# this test. Main and Factory Testing Sandbox construction are untouched.

var _definition: BuildingDefinition = null


func _site(label: String, offset: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_job(_definition, 5.0))
	add_child(site)
	site.global_position = offset
	site.set_process(false)
	assert(site.job.authorize())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	return site


func _ready() -> void:
	_definition = load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(_definition != null)
	var queue := BlueprintConstructionPriorityQueue.new()
	queue.name = "WaitingPriorityQueue"
	add_child(queue)
	var scheduler := BlueprintConstructionSlotScheduler.new()
	scheduler.name = "SlotScheduler"
	add_child(scheduler)
	assert(not scheduler.configure(queue, 0))
	assert(not scheduler.configure(queue, 17))
	assert(scheduler.configure(queue, 2))
	assert(not scheduler.configure(queue, 2))
	assert(scheduler.capacity == 2)
	print("PASS A: Capacity rejects invalid limits and configures exactly two slots")

	var low_one: ConstructionSite = _site(
		"LowOne", Vector3(-12, 0, -6)
	)
	var normal: ConstructionSite = _site(
		"Normal", Vector3(-7, 0, -6)
	)
	var high_one: ConstructionSite = _site(
		"HighBlocked", Vector3(-2, 0, -6)
	)
	var high_two: ConstructionSite = _site(
		"HighReady", Vector3(3, 0, -6)
	)
	var low_two: ConstructionSite = _site(
		"LowTwo", Vector3(8, 0, -6)
	)
	assert(low_one.job.set_priority(ConstructionJob.Priority.LOW))
	assert(low_two.job.set_priority(ConstructionJob.Priority.LOW))
	assert(high_one.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(high_two.job.set_priority(ConstructionJob.Priority.HIGH))
	var sites: Array[ConstructionSite] = [
		low_one, normal, high_one, high_two, low_two
	]
	for site: ConstructionSite in sites:
		assert(scheduler.track_authorized_site(site))
		assert(not scheduler.track_authorized_site(site))
	assert(queue.get_waiting_sites() == [
		high_one, high_two, normal, low_one, low_two
	])
	print("PASS B: Five jobs are tracked once, with shared High/Normal/Low order")

	assert(scheduler.reconcile() == 0)
	assert(scheduler.get_active_count() == 0)
	assert(scheduler.get_waiting_count() == 5)
	for site: ConstructionSite in sites:
		assert(site.job.get_wait_reasons().size() == 3)
		assert(site.job.get_progress() == 0.0)
	var unattached := ConstructionSite.new()
	assert(not scheduler.update_requirements(
		unattached, true, true
	))
	unattached.free()
	print("PASS C: Missing readiness snapshots fail closed; nothing builds")

	assert(scheduler.update_requirements(low_one, true, true))
	assert(scheduler.update_requirements(normal, true, true))
	assert(scheduler.update_requirements(high_one, false, true))
	assert(scheduler.update_requirements(high_two, true, true))
	assert(scheduler.update_requirements(low_two, true, false))
	assert(scheduler.reconcile() == 2)
	assert(scheduler.get_active_sites() == [high_two, normal])
	assert(high_two.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(high_one.job.state == ConstructionJob.State.QUEUED)
	assert(low_one.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.get_active_count() == 2)
	assert(scheduler.get_waiting_count() == 3)
	print("PASS D: Two eligible highest-ranked jobs start; unready High is skipped")

	assert(low_one.job.set_priority(ConstructionJob.Priority.HIGH))
	assert(scheduler.reconcile() == 0)
	assert(scheduler.get_active_sites() == [high_two, normal])
	assert(low_one.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.get_active_count() <= scheduler.capacity)
	print("PASS E: Reprioritization cannot preempt active construction")

	normal.job.advance(1.25)
	var preserved_progress: float = normal.job.get_progress()
	assert(preserved_progress > 0.0)
	assert(scheduler.update_requirements(normal, true, false))
	assert(scheduler.reconcile() == 1)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(normal.job.get_progress() == preserved_progress)
	assert(scheduler.get_active_sites() == [high_two, low_one])
	assert(low_one.job.state == ConstructionJob.State.CONSTRUCTING)
	print("PASS F: Materials loss pauses a job and frees its slot for waiting High")

	normal.job.advance(60.0)
	assert(normal.job.get_progress() == preserved_progress)
	assert(scheduler.update_requirements(normal, true, true))
	assert(scheduler.reconcile() == 0)
	assert(normal.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_sites() == [high_two, low_one])
	print("PASS G: Readiness restoration waits for capacity; paused time is conserved")

	# Complete the active High work. Real ConstructionJob transitions to
	# COMPLETE and the ConstructionSite instantiates its building once.
	high_two.job.advance(5.0)
	assert(high_two.job.state == ConstructionJob.State.COMPLETE)
	assert(high_two.is_queued_for_deletion())
	assert(scheduler.reconcile() == 1)
	assert(normal.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_sites() == [low_one, normal])
	assert(normal.job.get_progress() == preserved_progress)
	print("PASS H: Completion releases a slot and the paused Normal job resumes")

	assert(low_one.job.cancel())
	assert(low_one.job.state == ConstructionJob.State.CANCELLED)
	assert(low_one.is_queued_for_deletion())
	assert(scheduler.update_requirements(low_two, true, true))
	assert(scheduler.reconcile() == 1)
	assert(low_two.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_sites() == [normal, low_two])
	assert(scheduler.get_active_count() == 2)
	print("PASS I: Cancellation releases a slot and starts the next eligible Low")

	assert(scheduler.update_requirements(low_two, false, true))
	assert(scheduler.reconcile() == 0)
	assert(low_two.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_sites() == [normal])
	assert(scheduler.get_waiting_count() == 2)
	assert(high_one.job.state == ConstructionJob.State.QUEUED)
	assert(low_two.job.get_wait_reasons().has(&"power"))
	print("PASS J: Power loss pauses only its job; unpowered High stays queued")

	assert(scheduler.update_requirements(high_one, true, false))
	assert(scheduler.reconcile() == 0)
	assert(high_one.job.state == ConstructionJob.State.QUEUED)
	assert(scheduler.update_requirements(high_one, true, true))
	assert(scheduler.reconcile() == 1)
	assert(high_one.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_sites() == [normal, high_one])
	assert(scheduler.get_active_count() == scheduler.capacity)
	print("PASS K: Power/material gates both must be ready before High can start")

	assert(scheduler.update_requirements(low_two, true, true))
	assert(scheduler.reconcile() == 0)
	assert(low_two.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.get_active_count() == 2)
	print("PASS L: Restored Low work cannot exceed finite capacity")

	# Opting out of a job releases its worker; it cannot be resumed by this
	# scheduler until it is explicitly registered again.
	scheduler.stop_tracking(high_one)
	assert(high_one.job.state == ConstructionJob.State.PAUSED)
	assert(scheduler.reconcile() == 1)
	assert(low_two.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(scheduler.get_active_sites() == [normal, low_two])
	assert(high_one.job.state == ConstructionJob.State.PAUSED)
	print("PASS M: Removing a scheduled job frees its slot without bypassing gates")

	assert(normal.job.get_progress() == preserved_progress)
	assert(high_two.job.state == ConstructionJob.State.COMPLETE)
	assert(low_one.job.state == ConstructionJob.State.CANCELLED)
	assert(scheduler.get_active_count() <= scheduler.capacity)
	print("PASS N: Completed and cancelled jobs cannot hold worker capacity")

	var defaults: Node = (
		(load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	)
	assert(defaults.get_node_or_null("BlueprintConstructionSlotScheduler") == null)
	defaults.free()
	print("PASS O: Worker slots remain isolated from Main and the live sandbox")

	print("ALL 15 E3D5B LIMITED CONSTRUCTION WORKER TESTS PASSED")
