extends Node
## Stage A: explicit scene-only composition of the accepted x8 authorities.
## Stage B separately opts in to real player-authorized Storage sites.

const SANDBOX_PATH = "res://scenes/core/playable_automatic_construction_drone_sandbox.tscn"
const STAGE_B_PATH = "res://scenes/core/playable_automatic_construction_drone_stage_b.tscn"
const STAGE_C_PATH = "res://scenes/core/playable_automatic_construction_drone_stage_c.tscn"
const EXPANSION_PATH = "res://scenes/core/playable_construction_building_expansion_e3d5c6a.tscn"
const SITE_POWER_DEMAND: int = 7
const GUIDE_A := Vector3(4, 0, -3)
const GUIDE_B := Vector3(0, 0, -3)
const HUB_SCENE = preload("res://scenes/buildings/prototype_main_hub.tscn")
const STORAGE = preload("res://data/buildings/test_storage.tres")
const AMMO_PRESS = preload("res://data/buildings/prototype_ammunition_press.tres")
const CARGO_CAPACITY: int = 5
const INGOT = preload("res://data/items/test_ingot.tres")
const HUB_POSITION := Vector3(2, 0, -3)
const SOURCE_POSITION := Vector3(-2, 0, -3)
const STARTER_STOCK: int = 15
const BATTERY: float = 40.0
const MAX_FRAME_STEP: float = 0.1

@export var enable_playable_feedback: bool = false
@export var enable_player_site_enrollment: bool = false
@export var enable_automatic_sandbox: bool = false
@export var enable_building_expansion: bool = false

# Delivery observation only; accepted x8 checks physical arrival and custody.
class DroneOnlyPort:
	extends BlueprintConstructionStagingInputPort
	var original_site: WeakRef
	var original_job: ConstructionJob
	var original_definition: BuildingDefinition

	func can_accept_item(item: ItemDefinition, amount: int = 1) -> bool:
		var site := original_site.get_ref() as ConstructionSite if original_site != null else null
		if not is_instance_valid(site) or site.is_queued_for_deletion() or not site.is_inside_tree():
			return false
		if site.job == null or site.job != original_job or site.target_definition != original_definition or site.job.state != ConstructionJob.State.QUEUED:
			return false
		if not is_instance_valid(get_parent()) or site.get_parent() != get_parent().get_parent() or connected_conveyor != null:
			return false
		if not global_position.is_equal_approx(site.global_position + Vector3.UP * 2.0):
			return false
		return super.can_accept_item(item, amount)

	func can_accept_belt_item(_belt: ConveyorSegment, _item: ItemDefinition, _amount: int = 1) -> bool:
		return false

# Refuse the older isolated source-to-buffer shortcut.
class DroneOnlyStaging:
	extends BlueprintConstructionMaterialStaging

	func receive_item(_item: ItemDefinition, _count: int) -> int:
		return 0

var world: Node
var gate: SandboxConstructionDroneLifecycleGate
var queue: BlueprintConstructionPriorityQueue
var scheduler: BlueprintConstructionSlotScheduler
var coordinator: BlueprintConstructionReadinessCoordinator
var registry: BlueprintConstructionSiteStagingRegistry
var escrow: BlueprintConstructionMaterialEscrow
var network: ConstructionPowerCoverageNetwork
var power: PrototypeConstructionPowerAllocator
var discovery: PrototypeDroneStorageDiscovery
var supplier: PrototypeDroneSupplierReservations
var returns: PrototypeDroneReturnReservations
var charging: PrototypeDroneHubCharging
var dispatch: PrototypeDroneAutomaticDispatch
var hub: PrototypePowerStructure
var drone: PrototypeConstructionWorkerDrone
var storage: Node3D
var stock: InventoryComponent
var dock: PrototypeDroneStorageDock
var last_tick: Dictionary = {}
var tick_count: int = 0
var _site_entries: Array[Dictionary] = []
var _attempted: bool = false
var _started: bool = false
var _scope: Node3D
var _status_label: Label
var _generator_button: Button
var _storage_tag: Label3D
var _drone_tag: Label3D


func _ready() -> void:
	set_process(false)
	if enable_automatic_sandbox:
		call_deferred("_start_from_scene")


func _start_from_scene() -> void:
	if not _attempted and enable_automatic_sandbox and not start():
		push_error("Automatic construction sandbox Stage A startup refused")


func _is_sandbox_path(path: String) -> bool:
	return path == SANDBOX_PATH or path == STAGE_B_PATH or path == STAGE_C_PATH or path == EXPANSION_PATH


func _player_scene() -> bool:
	return _scope.scene_file_path == STAGE_B_PATH or _scope.scene_file_path == STAGE_C_PATH or _scope.scene_file_path == EXPANSION_PATH


func _feedback_enabled() -> bool:
	return enable_playable_feedback and _live(_scope) and (_scope.scene_file_path == STAGE_C_PATH or _expansion_enabled())


func _expansion_enabled() -> bool:
	return enable_building_expansion and _live(_scope) and _scope.scene_file_path == EXPANSION_PATH


func _live(node: Variant) -> bool:
	return is_instance_valid(node) and node is Node and node.is_inside_tree() and not node.is_queued_for_deletion()


func _is_authority(child: Node) -> bool:
	return (
		child.get_script() == get_script()
		or child is PrototypeConstructionDroneTickController
		or child is PrototypeConstructionDroneFleet
		or child is PrototypeDroneAutomaticDispatch
		or child is PrototypeDroneHubCharging
		or child is PrototypeConstructionWorkerDrone
		or child is BlueprintConstructionPriorityQueue
		or child is BlueprintConstructionSlotScheduler
		or child is BlueprintConstructionReadinessCoordinator
		or child is BlueprintConstructionSiteStagingRegistry
		or child is BlueprintConstructionMaterialEscrow
		or child is ConstructionPowerCoverageNetwork
		or child is PrototypeConstructionPowerAllocator
		or child is PrototypeDroneStorageDiscovery
		or child is PrototypeDroneSupplierReservations
		or child is PrototypeDroneReturnReservations
		or (child is PrototypePowerStructure and child.scene_file_path == HUB_SCENE.resource_path)
	)


func _no_other_authorities(allowed: Array) -> bool:
	for child: Node in _scope.get_children():
		if _live(child) and _is_authority(child) and not allowed.has(child):
			return false
	return true


func _legacy_bridge_off() -> bool:
	return (
		_live(gate) and gate.get_parent() == _scope
		and not gate.enable_isolated_bridge
		and not gate.enable_isolated_authorization_autowire
		and not gate.enable_isolated_output_enrollment
		and not gate.enable_isolated_supplier_discovery
	)


func _services() -> Array:
	return [queue, scheduler, coordinator, registry, escrow, network, power, discovery, supplier, returns, charging, dispatch, hub, drone]


func start() -> bool:
	if not enable_automatic_sandbox or _attempted or not is_inside_tree():
		return false
	var scope := get_parent() as Node3D
	if not _live(scope) or not _is_sandbox_path(scope.scene_file_path):
		return false
	_attempted = true
	_scope = scope
	world = scope.get_node_or_null("WorldInteraction")
	gate = scope.get_node_or_null("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	if not _live(world):
		return false
	# Only this experimental scene: never allow debug readiness on failure.
	world.set("blueprint_sandbox_debug_requirements", false)
	if not bool(world.get("enable_blueprint_planning")) or not _legacy_bridge_off() or not _no_other_authorities([self]):
		return false
	# Reuse the exact WorldInteraction queue. Its original reference is
	# retained by the player authorization/UI path; x8 requires scope peers.
	queue = world.get("_construction_priority_queue") as BlueprintConstructionPriorityQueue
	if not _live(queue) or queue.get_parent() != world or queue.get_waiting_count() != 0:
		return false
	queue.reparent(scope)
	scheduler = BlueprintConstructionSlotScheduler.new()
	coordinator = BlueprintConstructionReadinessCoordinator.new()
	registry = BlueprintConstructionSiteStagingRegistry.new()
	escrow = BlueprintConstructionMaterialEscrow.new()
	network = ConstructionPowerCoverageNetwork.new()
	power = PrototypeConstructionPowerAllocator.new()
	discovery = PrototypeDroneStorageDiscovery.new()
	supplier = PrototypeDroneSupplierReservations.new()
	returns = PrototypeDroneReturnReservations.new()
	charging = PrototypeDroneHubCharging.new()
	dispatch = PrototypeDroneAutomaticDispatch.new()
	for service: Node in [scheduler, coordinator, registry, escrow, network, power, discovery, supplier, returns, charging, dispatch]:
		scope.add_child(service)
	registry.enable_isolated_site_registry = true
	scheduler.enable_isolated_drone_presence = true
	discovery.enable_isolated_discovery = true
	supplier.enable_isolated_reservations = true
	returns.enable_isolated_reservations = true
	returns.enable_isolated_cargo_recovery = true
	if not supplier.configure(discovery) or not returns.configure(discovery) or not power.configure(network):
		return false
	hub = HUB_SCENE.instantiate() as PrototypePowerStructure
	hub.name = "AutomaticConstructionHub"
	scope.add_child(hub)
	hub.global_position = HUB_POSITION
	if not network.register_node(hub.get_power_node()):
		return false
	storage = STORAGE.building_scene.instantiate() as Node3D
	storage.name = "AutomaticStarterStorage"
	scope.add_child(storage)
	storage.global_position = SOURCE_POSITION
	(storage.get_node("BuildingRuntime") as BuildingRuntime).initialize(STORAGE)
	stock = storage.get_node("InventoryComponent") as InventoryComponent
	stock.max_capacity = 20
	stock.enable_isolated_drone_claims = true
	stock.enable_isolated_drone_return_claims = true
	# Explicit counted fixture stock, once; never seed staging or Hub stock.
	if stock.add_item(INGOT, STARTER_STOCK) != STARTER_STOCK:
		return false
	dock = PrototypeDroneStorageDock.new()
	dock.name = "ConstructionStorageDock"
	storage.add_child(dock)
	dock.position = Vector3.UP * 2.0
	dock.enable_isolated_dock = true
	if not discovery.register_dock(dock):
		return false
	if not coordinator.configure(queue, scheduler, escrow, power, stock, 1):
		return false
	coordinator.enable_isolated_owned_staging = true
	if not coordinator.configure_owned_staging(registry):
		return false
	charging.enable_isolated_charging = true
	if not charging.configure(hub, power):
		return false
	drone = PrototypeConstructionWorkerDrone.new()
	drone.name = "AutomaticConstructionDrone"
	drone.enable_isolated_drone = true
	drone.enable_isolated_battery = true
	drone.enable_isolated_finite_charging = true
	drone.enable_isolated_cargo_pickup = true
	drone.enable_isolated_cargo_delivery = true
	drone.enable_isolated_delivered_worker = true
	drone.enable_isolated_cargo_recovery = true
	drone.enable_isolated_cargo_reuse = true
	drone.enable_isolated_pre_pickup_rearm = true
	drone.enable_isolated_post_delivery_rearm = true
	drone.enable_isolated_lost_site_rearm = true
	scope.add_child(drone)
	drone.global_position = HUB_POSITION + Vector3.UP * 2.0
	if not drone.configure_battery(BATTERY, BATTERY, 1.0, 4.0) or not charging.register_drone(drone):
		return false
	dispatch.enable_isolated_dispatch = true
	if not dispatch.configure(drone, queue, scheduler, coordinator, registry, escrow, discovery, supplier, returns, CARGO_CAPACITY, 2.0):
		return false
	dispatch.enable_isolated_lifecycle = true
	if not dispatch.configure_lifecycle(charging):
		return false
	_started = true
	if not has_verified_services():
		_started = false
		return false
	_tag(hub, "CONSTRUCTION HUB", 1.4)
	_storage_tag = _tag(storage, "STARTER STORAGE / 15 INGOTS", 1.5)
	if _player_scene() and enable_player_site_enrollment:
		if world.connect(&"blueprint_site_authorized", _on_player_authorized) != OK:
			_started = false
			return false
	_drone_tag = _tag(drone, "AUTOMATIC CONSTRUCTION DRONE", 0.65)
	if _feedback_enabled():
		_build_feedback()
		_refresh_feedback()
	set_process(true)
	print("Automatic construction sandbox ready; player enrollment: ", _player_scene() and enable_player_site_enrollment)
	return true


func _tag(parent: Node3D, message: String, height: float) -> Label3D:
	var tag := Label3D.new()
	tag.text = message
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.font_size = 26
	tag.pixel_size = 0.008
	parent.add_child(tag)
	tag.position = Vector3.UP * height
	return tag


func has_verified_services() -> bool:
	if not _started or not enable_automatic_sandbox or not _live(self) or not _live(_scope) or get_parent() != _scope or not _is_sandbox_path(_scope.scene_file_path):
		return false
	if not _live(world) or world.get_parent() != _scope or world.get("_construction_priority_queue") != queue or bool(world.get("blueprint_sandbox_debug_requirements")) or not _legacy_bridge_off():
		return false
	var services: Array = _services()
	for service: Variant in services:
		if not _live(service) or service.get_parent() != _scope:
			return false
	services.append(self)
	return _no_other_authorities(services) and dispatch._lifecycle_ready()


# Sole automatic lifecycle caller. No independent charge, drone, scheduler
# or job time step. Do not replay excess frame delta; Stage B owns only the
# eligible sites' process handoff. Stage A never changes a site's timer.
func _process(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0 or not has_verified_services():
		last_tick = {"action": &"blocked"}
		_refresh_feedback()
		return
	last_tick = dispatch.tick(minf(delta, MAX_FRAME_STEP))
	tick_count += 1
	# Presentation only: never invoke ConstructionSite._process().
	for entry: Dictionary in _site_entries:
		var site := (entry["site"] as WeakRef).get_ref() as ConstructionSite
		if _live(site) and site.get_parent() == _scope and site.job == entry["job"]:
			site.call("_refresh_progress_label")
	_refresh_feedback()


## E3d5c6a: canonical-definition allowlist; no material bill mutation or
## generic admission based on a building ID or cargo size alone. Stage B/C
## remain Storage-only even if the new exported switch is accidentally set.
func _eligible_material_amount(definition: BuildingDefinition) -> int:
	var expected: int = 0
	if definition == STORAGE:
		expected = 3
	elif _expansion_enabled() and definition == AMMO_PRESS:
		expected = 5
	else:
		return 0
	var bill: Dictionary = ConstructionMaterialBill.get_costs(definition)
	if bill.size() != 1 or int(bill.get(INGOT, 0)) != expected or expected > CARGO_CAPACITY:
		return 0
	return expected


# Synchronous genuine player authorization, after the original queue entry.
# Only one enrollment attempt per original site; claimed failures quarantine.
func _on_player_authorized(site: ConstructionSite) -> void:
	if not has_verified_services() or not enable_player_site_enrollment or not _player_scene():
		return
	if not _live(site) or site.get_parent() != _scope or not world.call("_is_managed_blueprint", site):
		return
	if site.job == null or site.job.state != ConstructionJob.State.QUEUED or not queue.get_waiting_sites().has(site):
		return
	for entry: Dictionary in _site_entries:
		if (entry["site"] as WeakRef).get_ref() == site:
			return
	var missing: Array[StringName] = site.job.get_wait_reasons()
	var amount: int = _eligible_material_amount(site.target_definition)
	if not missing.has(&"power") or not missing.has(&"materials") or not missing.has(&"workers"):
		return
	if amount <= 0 or not _live(stock) or stock.get_parent() != storage:
		return
	var entry: Dictionary = {"site": weakref(site), "job": site.job, "enrolled": false}
	_site_entries.append(entry)
	var staging := DroneOnlyStaging.new()
	staging.name = "DroneSiteStaging"
	staging.enable_isolated_staging = true
	_scope.add_child(staging)
	if not staging.configure(stock, site.target_definition, amount):
		staging.free()
		return
	# Independent hover receiver, not a planned belt endpoint or building.
	var receiver := Node3D.new()
	receiver.name = "DroneOnlyReceiver"
	_scope.add_child(receiver)
	var port := DroneOnlyPort.new()
	port.show_port_label = false
	port.enable_isolated_input = true
	port.original_site = weakref(site)
	port.original_job = site.job
	port.original_definition = site.target_definition
	receiver.add_child(port)
	port.global_position = site.global_position + Vector3.UP * 2.0
	if not port.bind_staging(staging) or not registry.claim_site(site, staging, port):
		receiver.free()
		staging.free()
		return
	entry["staging"] = weakref(staging)
	entry["port"] = weakref(port)
	if not coordinator.track_site(site, SITE_POWER_DEMAND):
		# Preserve the claimed empty pair; no registry release API.
		port.enable_isolated_input = false
		return
	# Only eligible, successfully tracked sites transfer timer ownership.
	site.set_process(false)
	entry["enrolled"] = true


func is_enrolled_site(site: ConstructionSite) -> bool:
	if not _live(site):
		return false
	for entry: Dictionary in _site_entries:
		if (entry["site"] as WeakRef).get_ref() == site and entry["job"] == site.job:
			return bool(entry["enrolled"])
	return false


# Stage C presentation only. No process callback of its own, no second
# simulation driver, no source seeding or readiness edits from the HUD.
func _build_feedback() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 230)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	var rows := VBoxContainer.new()
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(rows)
	_status_label = Label.new()
	_status_label.custom_minimum_size = Vector2(425, 170)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(_status_label)
	_generator_button = Button.new()
	_generator_button.pressed.connect(_toggle_stage_c_generator)
	rows.add_child(_generator_button)
	var hint := Label.new()
	hint.custom_minimum_size = Vector2(425, 0)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _expansion_enabled():
		hint.text = "Blueprint test only: Storage (3) or Ammunition Press (5). Q + drag, L/N/H, E or Ctrl+E; X cancels. Build mode remains legacy. Full footprint must be covered."
		_guide_site(Vector3(4.5, 0, -3.5), "AMMO PRESS SITE")
		_guide_site(GUIDE_B, "STORAGE SITE")
	else:
		hint.text = "Test Storage only. Plan at A/B with default rotation. Q + drag, L/N/H, E or Ctrl+E. X cancels. Hub coverage must include the full footprint."
		_guide_site(GUIDE_A, "STORAGE SITE A")
		_guide_site(GUIDE_B, "STORAGE SITE B")
	rows.add_child(hint)


func _guide_site(at: Vector3, message: String) -> void:
	var marker := Node3D.new()
	marker.name = "OptionalStorageGuide"
	_scope.add_child(marker)
	marker.global_position = at
	_tag(marker, message, 0.2)


func _toggle_stage_c_generator() -> void:
	# The real completed Hub owns generator state and the finite allocator
	# determines coverage/headroom. Never set ConstructionJob availability.
	if _feedback_enabled() and has_verified_services() and _live(hub):
		hub.set_generator_enabled(not hub.generator_enabled)
		_refresh_feedback()


func _refresh_feedback() -> void:
	if not is_instance_valid(_status_label):
		return
	if not _feedback_enabled() or not has_verified_services() or not _live(stock) or not _live(hub) or not _live(drone):
		_status_label.text = "AUTOMATIC CONSTRUCTION — BLOCKED / service unavailable"
		_generator_button.disabled = true
		return
	_generator_button.disabled = false
	_generator_button.text = "Turn generator OFF (test)" if hub.generator_enabled else "Turn generator ON (test)"
	var action: String = str(last_tick.get("action", "waiting")).replace("_", " ").to_upper()
	var phase: String = str(PrototypeConstructionWorkerDrone.FlightState.keys()[drone.get_flight_state()]).replace("_", " ")
	var counts := queue.get_waiting_counts_by_priority()
	var detail: String = ""
	var selected: Dictionary = last_tick.get("selection", {})
	if last_tick.get("action") == &"waiting":
		detail = str(selected.get("reason", "")).replace("_", " ")
		var skipped: Array = selected.get("skipped", [])
		if not skipped.is_empty():
			detail += " / " + str(skipped[0].get("reason", "")).replace("_", " ")
	var job: ConstructionJob = dispatch._assigned_job
	if job != null:
		detail = "Job progress: %d%%" % int(round(job.get_progress() * 100.0))
		var missing := job.get_wait_reasons()
		if not missing.is_empty():
			detail += " | Waiting: " + ", ".join(PackedStringArray(missing))
	_status_label.text = "AUTOMATIC CONSTRUCTION — %s\n%s | %s\nBattery %.1f / %.1f | Cargo %d / 5\nStorage: %d ingots (%d reserved) | Returns: %d\nHub output %d | Spare %d | Worker slots %d/1\nQueue H/N/L: %d / %d / %d | Rearms: %d" % [
		action, phase, detail, drone.battery_units(), drone.battery_capacity(), drone.cargo_amount(),
		stock.get_amount(INGOT), stock.get_reserved_amount(INGOT), returns.reservation_count(),
		hub.available_nameplate_generation(), power.spare_generation_for(hub.get_power_node()), scheduler.get_active_count(),
		counts["high"], counts["normal"], counts["low"], drone.completed_rearms()
	]
	if is_instance_valid(_storage_tag):
		_storage_tag.text = "STARTER STORAGE / %d INGOTS" % stock.get_amount(INGOT)
	if is_instance_valid(_drone_tag):
		_drone_tag.text = "%s / CARGO %d" % [phase, drone.cargo_amount()]
