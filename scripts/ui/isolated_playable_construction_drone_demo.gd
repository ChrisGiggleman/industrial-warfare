extends "res://scripts/ui/isolated_playable_construction_power_demo.gd"
## E3d5c5x2: one playable physical construction worker, owned escrow,
## verified finite power and existing lifecycle. No dock charging or reuse.

@export var enable_isolated_drone_demo: bool = false
var queue: BlueprintConstructionPriorityQueue
var scheduler: BlueprintConstructionSlotScheduler
var coordinator: BlueprintConstructionReadinessCoordinator
var fleet: PrototypeConstructionDroneFleet
var driver: PrototypeConstructionDroneTickController
var drone: PrototypeConstructionWorkerDrone
var _drone_started: bool = false
var _site_tracked: bool = false
var _demo_job: ConstructionJob
var _completed_ref: WeakRef
var _drone_label: Label
var _last_tick: Dictionary = {}


func start_drone_demo() -> bool:
	if not enable_isolated_drone_demo or _drone_started or not start_power_demo():
		return false
	var sandbox := get_parent()
	queue = BlueprintConstructionPriorityQueue.new()
	scheduler = BlueprintConstructionSlotScheduler.new()
	coordinator = BlueprintConstructionReadinessCoordinator.new()
	fleet = PrototypeConstructionDroneFleet.new()
	driver = PrototypeConstructionDroneTickController.new()
	for service: Node in [queue, scheduler, coordinator, fleet, driver]:
		sandbox.add_child(service)
	scheduler.enable_isolated_drone_presence = true
	# Hub inventory stays empty; the coordinator is irrevocably bound to
	# site-owned staging and cannot draw the construction bill from the Hub.
	var hub_stock := hub.get_node("InventoryComponent") as InventoryComponent
	if not coordinator.configure(queue, scheduler, escrow, allocator, hub_stock, 1):
		return false
	coordinator.enable_isolated_owned_staging = true
	if not coordinator.configure_owned_staging(registry):
		return false
	fleet.enable_isolated_fleet = true
	if not fleet.configure(queue, scheduler, 2.0, 2.0):
		return false
	drone = PrototypeConstructionWorkerDrone.new()
	drone.name = "TutorialConstructionDrone"
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	sandbox.add_child(drone)
	drone.global_position = HUB_POSITION + Vector3.UP * 1.6
	# Counted initial battery; the sandbox gate always supplies FALSE for
	# dock charging. No invented charging signal or repeat assignment.
	if not drone.configure_battery(40.0, 40.0, 1.0, 4.0):
		return false
	if not fleet.register_drone(drone):
		return false
	driver.enable_isolated_ticks = true
	if not driver.configure(fleet, coordinator, scheduler, escrow) or not gate.bind_verified_driver(driver):
		return false
	var tag := Label3D.new()
	tag.text = "CONSTRUCTION DRONE"
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.font_size = 26
	tag.pixel_size = 0.008
	tag.position = Vector3.UP * 0.65
	drone.add_child(tag)
	var layer := CanvasLayer.new()
	layer.layer = 14
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 795)
	layer.add_child(panel)
	_drone_label = Label.new()
	_drone_label.custom_minimum_size = Vector2(430, 105)
	_drone_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_drone_label)
	_drone_started = true
	_update_drone_hud()
	return true


# The power-only tutorial's direct availability observation must not
# coexist with the actual readiness coordinator or its power tracking.
func _update_site_power_readiness() -> void:
	if not _drone_started or _site_tracked or not enable_isolated_drone_demo or not gate.has_bound_driver():
		return
	if not _live(site) or not _live(receiver) or not receiver.matches_attached_site():
		return
	if not _live(bound_belt) or not receiver.has_bound_unified_receiver_consolidation():
		return
	if not coordinator.track_site(site, DEMAND):
		return
	_site_tracked = true
	_demo_job = site.job
	site.building_completed.connect(_on_demo_building_completed)
	# The existing tick controller is the ONLY job clock in this demo.
	# We separately refresh visual progress, without calling site._process.
	site.set_process(false)


func allocated_power() -> int:
	if not _drone_started or not _site_tracked or not _live(site) or not _live(allocator):
		return 0
	return allocator.get_allocated_units(site)


func _on_demo_building_completed(building: Node3D) -> void:
	if _live(building):
		_completed_ref = weakref(building)


func completed_building() -> Node3D:
	if _completed_ref == null:
		return null
	var building := _completed_ref.get_ref() as Node3D
	return building if _live(building) else null


func held_ingots() -> int:
	if not _live(site) or not _live(escrow):
		return 0
	var id: int = escrow.reservation_for(site)
	if id <= 0:
		return 0
	return int(escrow.held_materials(id).get(INGOT, 0))


func _process(delta: float) -> void:
	super._process(delta)
	if not _drone_started:
		return
	# A long frame cannot skip large chunks of flight or construction.
	if enable_isolated_drone_demo and gate.has_bound_driver() and is_finite(delta) and delta > 0.0:
		_last_tick = gate.tick_once(minf(delta, 0.1))
	if _live(site):
		site.call("_refresh_progress_label")
	_refresh_power()
	_update_drone_hud()


func _update_drone_hud() -> void:
	if not _drone_started or not is_instance_valid(_drone_label):
		return
	var flight: String = "UNAVAILABLE"
	if _live(drone):
		flight = ["IDLE", "OUTBOUND", "AT SITE", "RETURNING", "DOCKED"][drone.get_flight_state()]
	var status: String = "Prepare, authorize, power and bind the route."
	var progress: float = 0.0
	if _demo_job != null:
		progress = _demo_job.get_progress()
		match _demo_job.state:
			ConstructionJob.State.QUEUED: status = "Waiting for escrow, power or drone arrival."
			ConstructionJob.State.CONSTRUCTING: status = "BUILDING"
			ConstructionJob.State.PAUSED: status = "PAUSED — requirements unavailable"
			ConstructionJob.State.CANCELLED: status = "CANCELLED — check refund"
			ConstructionJob.State.COMPLETE: status = "COMPLETE — building activated" if completed_building() != null else "Completion needs inspection"
	var battery: float = drone.battery_units() if _live(drone) else 0.0
	_drone_label.text = "CONSTRUCTION DRONE — %s\n%s | Progress: %d%%\nEscrow: %d/3 | Battery: %.1f/40\nCharging disabled; one assignment only." % [flight, status, int(round(progress * 100)), held_ingots(), battery]
	if is_instance_valid(_power_label):
		_power_label.text = _power_label.text.replace("Worker and escrow readiness not granted.", "Allocation follows reserved materials.")
	if is_instance_valid(_label):
		_label.text = _label.text.replace("Power test below. No worker or material escrow readiness. Cancel with X.", "Drone dispatches automatically when reserved materials and power are ready.")
		_label.text = _label.text.replace("Blueprint waits for power and worker.", "Coordinator checks escrow, power and drone arrival.")
		if _demo_job != null and _demo_job.state == ConstructionJob.State.COMPLETE and completed_building() != null:
			_label.text = _label.text.replace("Site ended — restart to prepare another", "Construction complete")
			_label.text = _label.text.replace("Existing staged stock retained; no further construction intake.", "Three ingots consumed by completed building; surplus retained.")
