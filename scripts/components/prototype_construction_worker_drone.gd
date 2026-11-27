extends Node3D
class_name PrototypeConstructionWorkerDrone

# =============================================================================
# E3D5C4U — ISOLATED PHYSICAL CONSTRUCTION DRONE MOVEMENT
# =============================================================================
# A visible, test-only drone travels from a fixed home to one explicitly
# authorized ConstructionSite and returns when that site ends.
# Movement is straight-line with no obstacle avoidance. Its travel does NOT
# authorize a job, occupy a worker slot, update availability, advance a timer,
# create a power source, recover items or release any material claim.
# No _process / physics step: F6 fixture explicitly calls advance_flight().
# Not installed in Main or Factory Testing Sandbox.

enum FlightState { IDLE, OUTBOUND, AT_SITE, RETURNING, DOCKED, PICKUP_OUTBOUND, AT_PICKUP, CARGO_HELD, DELIVERY_OUTBOUND, AT_DELIVERY, DELIVERED, RECOVERY_WAIT, RECOVERY_OUTBOUND, AT_RECOVERY, RECOVERY_HOME, STAGED_TO_SITE, STAGED_AT_SITE, STAGED_LOADED, STAGED_TO_STORAGE, STAGED_AT_STORAGE, STAGED_HOME }

const ARRIVAL_EPSILON: float = 0.05
const MAX_SPEED: float = 50.0

@export var enable_isolated_drone: bool = false

# E3d5c4x: experimental battery is OFF by default; once configured, power
# accounting stays latched even if this option is disabled.
@export var enable_isolated_battery: bool = false
# E3d5c4y guarded reuse. Does not release construction inventory ownership.
@export var enable_isolated_reuse: bool = false
# x5a: isolated, single whole-load cargo. No site unload or return deposit.
@export var enable_isolated_cargo_pickup: bool = false
var _pickup_token: RefCounted
var _pickup_dock: WeakRef
var _pickup_capacity: int = 0
var _cargo_item: ItemDefinition
var _cargo_amount: int = 0
# x5b: immutable original pickup assignment; separately enabled delivery.
@export var enable_isolated_cargo_delivery: bool = false
var _cargo_site: WeakRef
var _cargo_job: ConstructionJob
var _cargo_definition: BuildingDefinition
var _delivery_registry: WeakRef
var _delivery_escrow: WeakRef
var _delivery_buffer: WeakRef
# x5c: explicit handoff into the existing physical worker gate.
@export var enable_isolated_delivered_worker: bool = false
var _delivered_worker_latched: bool = false
# x6: default-off return of actual canceled-job cargo.
@export var enable_isolated_cargo_recovery: bool = false
var _return_token: RefCounted
var _return_dock: WeakRef
# x7a: one latched finite charging authority; legacy boolean charge is blocked.
@export var enable_isolated_finite_charging: bool = false
var _charging_owner: WeakRef
var _charging_token: RefCounted
# x7b: explicit cargo rearm, independent of legacy build-only reuse.
@export var enable_isolated_cargo_reuse: bool = false
var _cargo_reuse_latched: bool = false
var _cargo_recovered: bool = false
var _delivered_scheduler: WeakRef
# x7c1: opt-in provenance for a flight canceled before physical debit.
@export var enable_isolated_pre_pickup_rearm: bool = false
var _pre_pickup_rearm_latched: bool = false
var _pre_pickup_cancelled: bool = false
var _pre_pickup_supplier: WeakRef
# x7c2: latch only a genuinely unloaded cargo assignment.
@export var enable_isolated_post_delivery_rearm: bool = false
var _post_delivery_rearm_latched: bool = false
var _post_delivery_cancelled: bool = false
# x7c3: lifetime provenance, latched when the actual pickup flight begins.
@export var enable_isolated_lost_site_rearm: bool = false
var _lost_site_rearm_latched: bool = false
var _lost_pre_pickup: bool = false
var _lost_post_delivery: bool = false

@export var enable_specialized_c4_parking: bool = false
var _c4_parked: bool = false
var _assignment_job: ConstructionJob = null
var _reuse_count: int = 0
const RETURN_MARGIN_UNITS: float = 0.25
var _c5p_automated: bool = false
var _battery_configured: bool = false
var _battery_capacity: float = 0.0
var _battery_units: float = 0.0
var _energy_per_meter: float = 0.0
var _charge_units_per_second: float = 0.0

var _state: FlightState = FlightState.IDLE
var _site_ref: WeakRef = null
var _home: Vector3 = Vector3.ZERO
var _speed: float = 0.0
var _hover_height: float = 0.0
var _site_ended: bool = false

# E3d5c6c B: separately opted-in terminal staging recovery. Existing
# construction delivery states and rearm checks remain unchanged when OFF.
@export var enable_isolated_cancelled_staging_flight: bool = false
# E3d5c6e: default-OFF, exact-scene-only temporary worker parking.
@export var enable_isolated_power_parking: bool = false
var _power_parked_assignment: bool = false
const POWER_PARKING_SCENE := "res://scenes/core/playable_drone_power_interruption_e3d5c6e.tscn"
var _staged_owner: WeakRef
var _staged_token: RefCounted
var _staged_hover: Vector3 = Vector3.ZERO
var _staged_dock: WeakRef


# A delivered worker may leave the site only with its original job/escrow
# retained. Parking cannot free the assignment, worker binding or materials.
func _power_parking_scope() -> bool:
	var scope := get_parent() as Node3D
	return (
		enable_isolated_power_parking and is_inside_tree()
		and not is_queued_for_deletion() and is_instance_valid(scope)
		and scope.scene_file_path == POWER_PARKING_SCENE
		and enable_isolated_delivered_worker and _delivered_worker_latched
		and enable_isolated_cargo_reuse and enable_isolated_finite_charging
		and _battery_configured and enable_isolated_battery
	)


func begin_power_parking(site: ConstructionSite) -> bool:
	if (
		not _power_parking_scope() or _state != FlightState.AT_SITE
		or not _delivered_worker_valid(site) or _bound_site() != site
		or _site_ended or site.job != _assignment_job
		or site.job.state != ConstructionJob.State.PAUSED
		or _cargo_amount != 0 or _cargo_item != null
		or _pickup_token != null or _return_token != null
	):
		return false
	var required: float = global_position.distance_to(_home) * _energy_per_meter + RETURN_MARGIN_UNITS
	if not _c5p_automated and _battery_units + 0.00001 < required:
		return false
	_power_parked_assignment = true
	_state = FlightState.RETURNING
	return true


func can_resume_power_parking(site: ConstructionSite) -> bool:
	if (
		not _power_parking_scope() or not _power_parked_assignment
		or _state != FlightState.DOCKED or not global_position.is_equal_approx(_home)
		or not _delivered_worker_valid(site) or _bound_site() != site
		or _site_ended or site.job != _assignment_job
		or site.job.state != ConstructionJob.State.PAUSED
		or _cargo_amount != 0 or _cargo_item != null
	):
		return false
	# Original has_round_trip_energy needs QUEUED, but this already-funded
	# construction job remains PAUSED; use the existing finite route forecast.
	var target: Vector3 = site.global_position + Vector3.UP * _hover_height
	var waypoints: Array[Vector3] = [target]
	var needed: float = estimate_route_energy(waypoints)
	return needed >= 0.0 and needed <= _battery_units + 0.00001


func begin_power_resume(site: ConstructionSite) -> bool:
	if not can_resume_power_parking(site):
		return false
	_state = FlightState.OUTBOUND
	return true


func abort_power_resume(site: ConstructionSite) -> bool:
	if (
		not _power_parking_scope() or not _power_parked_assignment
		or _state != FlightState.OUTBOUND or _bound_site() != site
		or _site_ended or not _delivered_worker_valid(site)
	):
		return false
	var required: float = global_position.distance_to(_home) * _energy_per_meter + RETURN_MARGIN_UNITS
	if not _c5p_automated and _battery_units + 0.00001 < required:
		return false
	_state = FlightState.RETURNING
	return true


func complete_power_resume(site: ConstructionSite) -> bool:
	if (
		not _power_parking_scope() or not _power_parked_assignment
		or _state != FlightState.AT_SITE or not is_at_site()
		or _bound_site() != site or site.job != _assignment_job
		or site.job.state != ConstructionJob.State.CONSTRUCTING
	):
		return false
	_power_parked_assignment = false
	return true


# Stage B companion is a manually ticked authority, never Main or the
# automatic construction dispatcher. Its token is checked on every step.
func _staged_authority(owner: Node, token: RefCounted) -> bool:
	return (
		enable_isolated_cancelled_staging_flight
		and enable_isolated_drone and _motion_mode_ready()
		and _delivery_live(self) and _delivery_live(owner)
		and owner.get_parent() == get_parent()
		and owner.get_script() != null
		and owner.get_script().resource_path == "res://scripts/components/prototype_cancelled_site_recovery_transport.gd"
		and owner.has_method("_owns_staged_mission")
		and bool(owner.call("_owns_staged_mission", self, token))
		and _staged_owner != null and _staged_owner.get_ref() == owner
		and token != null and _staged_token == token
	)


func _staged_begin(owner: Node, token: RefCounted, hover: Vector3, dock: PrototypeDroneStorageDock, speed: float) -> bool:
	if not enable_isolated_cancelled_staging_flight or not _delivery_live(owner) or owner.get_parent() != get_parent():
		return false
	if owner.get_script() == null or owner.get_script().resource_path != "res://scripts/components/prototype_cancelled_site_recovery_transport.gd" or not owner.has_method("_owns_staged_mission") or not bool(owner.call("_owns_staged_mission", self, token)):
		return false
	if _staged_owner != null or _staged_token != null or _state != FlightState.IDLE or not _finite_cargo_rearm_ready():
		return false
	if _site_ref != null or _assignment_job != null or _cargo_job != null or _cargo_site != null or _pickup_token != null or _return_token != null or _cargo_amount != 0 or _cargo_item != null:
		return false
	if not _delivery_live(dock) or dock.get_parent().get_parent() != get_parent() or not hover.is_finite() or not dock.global_position.is_finite():
		return false
	if not is_finite(speed) or speed <= 0.0 or speed > MAX_SPEED or global_position.distance_to(_home) > 0.00001:
		return false
	var route: Array[Vector3] = [hover, dock.global_position]
	if not route_feasible(route):
		return false
	_staged_owner = weakref(owner)
	_staged_token = token
	_staged_hover = hover
	_staged_dock = weakref(dock)
	_speed = speed
	_state = FlightState.STAGED_TO_SITE
	return true


# Physically metered leg. Every segment retains the energy needed to finish
# the planned route and reach the registered home with the safety margin.
func _staged_step(owner: Node, token: RefCounted, delta: float) -> bool:
	if not _c5p_step_valid(delta):
		return false
	if not _staged_authority(owner, token) or not is_finite(delta) or delta <= 0.0 or delta > 0.1:
		return false
	var dock := _staged_dock.get_ref() as PrototypeDroneStorageDock
	# After a committed specialized deposit, the home leg owns no dock custody.
	var specialized_home: bool = _state == FlightState.STAGED_HOME and owner is PrototypeCancelledSiteRecoveryTransport and owner.enable_specialized_c3
	if not specialized_home and (not _delivery_live(dock) or not dock.global_position.is_finite() or not _staged_hover.is_finite()):
		return false
	var target: Vector3
	var reserve: float
	var next_state: FlightState
	match _state:
		FlightState.STAGED_TO_SITE:
			target = _staged_hover
			reserve = _staged_hover.distance_to(dock.global_position) + dock.global_position.distance_to(_home)
			next_state = FlightState.STAGED_AT_SITE
		FlightState.STAGED_TO_STORAGE:
			target = dock.global_position
			reserve = dock.global_position.distance_to(_home)
			next_state = FlightState.STAGED_AT_STORAGE
		FlightState.STAGED_HOME:
			target = _home
			reserve = 0.0
			next_state = FlightState.DOCKED
		_:
			return false
	var step: float = minf(global_position.distance_to(target), _speed * delta)
	var next: Vector3 = global_position.move_toward(target, step)
	var remaining: float = next.distance_to(target) + reserve
	if not _c5p_automated and _battery_units + 0.00001 < (step + remaining) * _energy_per_meter + RETURN_MARGIN_UNITS:
		return false
	if not _c5p_automated:
		_battery_units = maxf(0.0, _battery_units - step * _energy_per_meter)
	global_position = next
	if global_position.distance_to(target) <= 0.00001:
		global_position = target
		_state = next_state
	return true


# Only the exact terminal controller can convert material present at the
# original anchored receiver into real drone cargo. No remote pickup.
func _staged_collect(owner: Node, token: RefCounted, original: InventoryComponent, item: ItemDefinition, amount: int) -> bool:
	if not _staged_authority(owner, token) or _state != FlightState.STAGED_AT_SITE:
		return false
	if global_position.distance_to(_staged_hover) > 0.00001 or not _delivery_live(original) or not is_instance_valid(item):
		return false
	if amount <= 0 or amount > 5 or original.get_total_amount() != amount or original.get_amount(item) != amount:
		return false
	if not original.remove_item(item, amount):
		return false
	_cargo_item = item
	_cargo_amount = amount
	_state = FlightState.STAGED_LOADED
	return true


func _staged_begin_return(owner: Node, token: RefCounted, dock: PrototypeDroneStorageDock, item: ItemDefinition, amount: int) -> bool:
	if not _staged_authority(owner, token) or _state != FlightState.STAGED_LOADED:
		return false
	if _staged_dock.get_ref() != dock or _cargo_item != item or _cargo_amount != amount:
		return false
	if not _delivery_live(dock) or not dock.available or not dock.allow_returns:
		return false
	_state = FlightState.STAGED_TO_STORAGE
	return true


# Consumes the exact previously reserved destination claim only AFTER
# metered arrival at the real dock. Staging lock is never released.
func _staged_unload(owner: Node, token: RefCounted, dock: PrototypeDroneStorageDock, dest: InventoryComponent, item: ItemDefinition, amount: int) -> bool:
	if not _staged_authority(owner, token) or _state != FlightState.STAGED_AT_STORAGE:
		return false
	if not _delivery_live(dock) or not dock.available or not dock.allow_returns or _staged_dock.get_ref() != dock or not _delivery_live(dest):
		return false
	if global_position.distance_to(dock.global_position) > 0.00001 or _cargo_item != item or _cargo_amount != amount:
		return false
	if not dest.consume_drone_return_claim(token, item, amount):
		return false
	_cargo_item = null
	_cargo_amount = 0
	_state = FlightState.STAGED_HOME
	return true


func _staged_rearm(owner: Node, token: RefCounted) -> bool:
	if not _staged_authority(owner, token) or _state != FlightState.DOCKED or not _finite_cargo_rearm_ready():
		return false
	if _cargo_amount != 0 or _cargo_item != null or global_position.distance_to(_home) > 0.00001:
		return false
	_staged_owner = null
	_staged_token = null
	_staged_dock = null
	_staged_hover = Vector3.ZERO
	_state = FlightState.IDLE
	_reuse_count += 1
	return true


func _ready() -> void:
	# A basic 3D placeholder, deliberately independent of future Blender art.
	var body := MeshInstance3D.new()
	body.name = "DroneBody"
	var shape := SphereMesh.new()
	shape.radius = 0.3
	shape.height = 0.6
	body.mesh = shape
	var surface := StandardMaterial3D.new()
	surface.albedo_color = Color(0.22, 0.78, 0.95)
	body.material_override = surface
	add_child(body)

	var frame := MeshInstance3D.new()
	frame.name = "DroneFrame"
	var frame_mesh := BoxMesh.new()
	frame_mesh.size = Vector3(0.9, 0.09, 0.18)
	frame.mesh = frame_mesh
	frame.position = Vector3(0.0, 0.05, 0.0)
	add_child(frame)


# Configure only at home, before an assignment. The first configuration
# permanently latches metering; it is never safe to switch back to unmetered
# motion for this worker. 'Powered' during charging is caller supplied.
# Only the named specialized controllers may latch this mode before assignment.
# The original dock authority must subsequently enroll the worker.
func configure_c5p_automated(controller: Node) -> bool:
	var scope := get_parent()
	if _c5p_automated or _battery_configured or enable_isolated_battery or enable_isolated_finite_charging or _charging_owner != null or not enable_isolated_drone or _state != FlightState.IDLE or _site_ref != null or _cargo_job != null or _pickup_token != null or _cargo_amount != 0:
		return false
	if not _delivery_live(self) or not _delivery_live(scope) or scope.scene_file_path != SPECIALIZED_SCOPE_E3D5C6F or not _delivery_live(controller) or controller.get_parent() != scope:
		return false
	var b2 := scope.get_node_or_null("B2LogisticsController") as SpecializedDroneLogisticsE3d5c6fB2
	if not _delivery_live(b2) or not b2.c5p_automated_mode():
		return false
	if self == scope.get_node_or_null("LogisticsDrone"):
		if controller != b2 or b2.phase != &"disabled":
			return false
	elif self == scope.get_node_or_null("ConstructionDrone"):
		if controller != scope.get_node_or_null("B3BuilderController") or not scope.has_meta(&"e3d5c6f_single_tick_owner") or (scope.get_meta(&"e3d5c6f_single_tick_owner") as WeakRef).get_ref() != controller:
			return false
	else:
		return false
	if not global_position.is_finite():
		return false
	_home = global_position
	_c5p_automated = true
	return true

func c5p_automated_mode() -> bool:
	return _c5p_automated

func _c5p_enrolled() -> bool:
	if not _c5p_automated or _battery_configured or enable_isolated_battery or enable_isolated_finite_charging or not _delivery_live(self) or _charging_owner == null or _charging_token == null:
		return false
	var owner := _charging_owner.get_ref() as PrototypeDroneHubCharging
	return _delivery_live(owner) and owner.matches_c5p_enrollment(self, _charging_token)

func _bind_c5p_dock(owner: Node, token: RefCounted, at: Vector3) -> bool:
	if not _c5p_automated or not enable_isolated_drone or _battery_configured or enable_isolated_battery or enable_isolated_finite_charging or _charging_owner != null or token == null or _state != FlightState.IDLE:
		return false
	var dock_owner := owner as PrototypeDroneHubCharging
	if not _delivery_live(dock_owner) or dock_owner.get_parent() != get_parent() or not dock_owner.c5p_dock_only():
		return false
	if not at.is_finite() or not global_position.is_finite() or not _home.is_equal_approx(at) or not global_position.is_equal_approx(at):
		return false
	_charging_owner = weakref(owner)
	_charging_token = token
	return true

# Explicit step paths retain the named single controller as tick owner.
# Dock registration itself is independent of which role currently owns work.
func _c5p_tick_owner_ready() -> bool:
	var scope := get_parent()
	if not _delivery_live(scope) or scope.scene_file_path != SPECIALIZED_SCOPE_E3D5C6F or not scope.has_meta(&"e3d5c6f_single_tick_owner"):
		return false
	var ref := scope.get_meta(&"e3d5c6f_single_tick_owner") as WeakRef
	if ref == null:
		return false
	var expected: Node
	if self == scope.get_node_or_null("LogisticsDrone"):
		expected = scope.get_node_or_null("B2LogisticsController")
	elif self == scope.get_node_or_null("ConstructionDrone"):
		expected = scope.get_node_or_null("B3BuilderController")
	else:
		return false
	if not _delivery_live(expected) or ref.get_ref() != expected or expected.is_processing() or expected.is_physics_processing():
		return false
	var b1 := scope.get_node_or_null("SingleTickController") as PlayableSpecializedDronesE3d5c6f
	if not _delivery_live(b1) or b1.enable_b1_controller or b1.is_processing() or b1.is_physics_processing():
		return false
	for child: Node in scope.get_children():
		if not _delivery_live(child):
			continue
		if child is PrototypeDroneAutomaticDispatch or child is PrototypeConstructionDroneFleet or child is PrototypeConstructionDroneTickController:
			return false
		if child is SpecializedDroneLogisticsE3d5c6fB2 and child != scope.get_node_or_null("B2LogisticsController"):
			return false
		if child is SpecializedDroneBuilderE3d5c6fB3 and child != scope.get_node_or_null("B3BuilderController"):
			return false
	return true

func _motion_mode_ready() -> bool:
	if _c5p_automated:
		return _c5p_enrolled() and _c5p_tick_owner_ready()
	return enable_isolated_battery and _battery_configured

# A route score is distance in automated mode, legacy energy otherwise.
# No synthetic battery balance is exposed to either caller.
func route_score(waypoints: Array[Vector3]) -> float:
	if not _c5p_automated:
		return estimate_route_energy(waypoints)
	if not _c5p_enrolled() or not _c5p_tick_owner_ready() or not enable_isolated_drone or waypoints.is_empty() or waypoints.size() > 8 or not global_position.is_finite() or not _home.is_finite():
		return -1.0
	var previous := global_position
	var distance: float = 0.0
	for point: Vector3 in waypoints:
		if not point.is_finite():
			return -1.0
		distance += previous.distance_to(point)
		previous = point
	distance += previous.distance_to(_home)
	return distance if is_finite(distance) else -1.0

func route_feasible(waypoints: Array[Vector3]) -> bool:
	var score := route_score(waypoints)
	return score >= 0.0 and (_c5p_automated or score <= _battery_units + 0.00001)

func _c5p_step_valid(delta: float) -> bool:
	return not _c5p_automated or (_c5p_enrolled() and _c5p_tick_owner_ready() and enable_isolated_drone and is_finite(delta) and delta > 0.0 and delta <= 1.0 and global_position.is_finite() and _home.is_finite() and is_finite(_speed) and _speed > 0.0 and _speed <= MAX_SPEED)

func configure_battery(
	capacity_units: float,
	starting_units: float,
	units_per_meter: float,
	charge_per_second: float
) -> bool:
	if (
		_c5p_automated or not enable_isolated_battery or _battery_configured
		or not is_inside_tree() or _state != FlightState.IDLE
		or not global_position.is_finite()
		or not is_finite(capacity_units) or capacity_units <= 0.0
		or not is_finite(starting_units) or starting_units < 0.0
		or starting_units > capacity_units
		or not is_finite(units_per_meter) or units_per_meter <= 0.0
		or not is_finite(charge_per_second) or charge_per_second <= 0.0
	):
		return false
	_home = global_position
	_battery_capacity = capacity_units
	_battery_units = starting_units
	_energy_per_meter = units_per_meter
	_charge_units_per_second = charge_per_second
	_battery_configured = true
	return true


# A battery-equipped drone must have enough energy for its outward trip,
# a straight-line return to its registered home, and a small safety margin.
# This is NOT a pathfinding/obstacle-safe endurance forecast.
func has_round_trip_energy(site: ConstructionSite, hover_height: float) -> bool:
	if (
		not enable_isolated_battery or not _battery_configured
		or not _valid_queued_site(site)
		or not is_finite(hover_height)
		or hover_height < 0.5 or hover_height > 10.0
	):
		return false
	var destination: Vector3 = site.global_position + Vector3.UP * hover_height
	var needed: float = (
		2.0 * _home.distance_to(destination) * _energy_per_meter
		+ RETURN_MARGIN_UNITS
	)
	return _battery_units + 0.00001 >= needed


# Recharging is allowed ONLY while physically home and stationary.
# The caller must supply a verified charging-power flag; this fixture does
# not pretend to deliver actual electrical power or reserve grid capacity.
func charge_at_home(delta: float, powered: bool) -> bool:
	if enable_isolated_finite_charging or _charging_owner != null:
		return false
	if (
		not enable_isolated_battery or not _battery_configured
		or not powered or not is_finite(delta) or delta <= 0.0
		or _state not in [FlightState.IDLE, FlightState.DOCKED]
		or global_position.distance_to(_home) > ARRIVAL_EPSILON
		or _battery_units >= _battery_capacity
	):
		return false
	_battery_units = minf(
		_battery_capacity,
		_battery_units + _charge_units_per_second * delta
	)
	return true


func battery_units() -> float:
	return _battery_units if _battery_configured else -1.0


func battery_capacity() -> float:
	return _battery_capacity if _battery_configured else 0.0

# E3d5c5x3: read-only straight-line forecast, including registered home
# and return reserve. Never moves the drone, admits a job or spends energy.
func estimate_route_energy(waypoints: Array[Vector3]) -> float:
	if not enable_isolated_drone or not enable_isolated_battery or not _battery_configured or not is_inside_tree() or is_queued_for_deletion():
		return -1.0
	if waypoints.is_empty() or waypoints.size() > 8 or not global_position.is_finite() or not _home.is_finite():
		return -1.0
	var previous: Vector3 = global_position
	var distance: float = 0.0
	for point: Vector3 in waypoints:
		if not point.is_finite():
			return -1.0
		distance += previous.distance_to(point)
		previous = point
	distance += previous.distance_to(_home)
	var needed: float = distance * _energy_per_meter + RETURN_MARGIN_UNITS
	return needed if is_finite(needed) else -1.0



# Bind ONCE to an already-authorized, currently queued site. Subsequent
# cancellation/completion permanently retires this test drone's assignment.
func assign_to_site(
	site: ConstructionSite,
	home_position: Vector3,
	flight_speed: float,
	hover_height: float
) -> bool:
	if (
		not enable_isolated_drone or not is_inside_tree()
		or enable_isolated_cargo_reuse or _cargo_reuse_latched
		or _site_ref != null or _state != FlightState.IDLE
		or not _valid_queued_site(site)
		or not home_position.is_finite()
		or not is_finite(flight_speed)
		or flight_speed <= 0.0 or flight_speed > MAX_SPEED
		or not is_finite(hover_height)
		or hover_height < 0.5 or hover_height > 10.0
	):
		return false
	if _c5p_automated:
		var scope := get_parent()
		var builder_controller := scope.get_node_or_null("B3BuilderController") as SpecializedDroneBuilderE3d5c6fB3
		var route: Array[Vector3] = [site.global_position + Vector3.UP * hover_height]
		if self != scope.get_node_or_null("ConstructionDrone") or not _delivery_live(builder_controller) or not builder_controller.c4_flight_authorized(self, site) or not _c5p_enrolled() or not home_position.is_equal_approx(_home) or not global_position.is_equal_approx(_home) or not route_feasible(route):
			return false
	if _battery_configured:
		if (
			not enable_isolated_battery
			or not home_position.is_equal_approx(_home)
			or not global_position.is_equal_approx(_home)
			or not has_round_trip_energy(site, hover_height)
		):
			return false
	_site_ref = weakref(site)
	_assignment_job = site.job
	_home = home_position
	_speed = flight_speed
	_hover_height = hover_height
	global_position = _home
	_state = FlightState.OUTBOUND
	site.job.job_cancelled.connect(_on_site_ended)
	site.tree_exiting.connect(_on_site_ended)
	return true


# Manual movement only. Returning the drone HOME never unlocks any
# construction resource or claim.
func advance_flight(delta: float) -> bool:
	if not _c5p_step_valid(delta):
		return false
	if _state in [FlightState.PICKUP_OUTBOUND, FlightState.AT_PICKUP, FlightState.CARGO_HELD, FlightState.DELIVERY_OUTBOUND, FlightState.AT_DELIVERY, FlightState.DELIVERED, FlightState.RECOVERY_WAIT, FlightState.RECOVERY_OUTBOUND, FlightState.AT_RECOVERY, FlightState.RECOVERY_HOME]:
		return false # Cargo legs are distinct from legacy worker flight.
	if (
		not is_finite(delta) or delta <= 0.0
		or _state in [FlightState.IDLE, FlightState.DOCKED]
	):
		return false

	if _state == FlightState.RETURNING:
		var distance_allowed: float = _speed * delta
		if _battery_configured:
			# Meter the actual return. If charge runs out, stop in place;
			# never teleport a worker home or invent battery energy.
			distance_allowed = minf(
				distance_allowed, _battery_units / _energy_per_meter
			)
		var next_return: Vector3 = global_position.move_toward(_home, distance_allowed)
		var return_distance: float = global_position.distance_to(next_return)
		if return_distance <= 0.0:
			if _lost_site_rearm_latched and global_position.distance_to(_home) <= 0.00001:
				_state = FlightState.DOCKED
				return true
			return false
		if _battery_configured:
			_battery_units = maxf(
				0.0, _battery_units - return_distance * _energy_per_meter
			)
		global_position = next_return
		if global_position.distance_to(_home) <= (0.00001 if (_pre_pickup_cancelled or _post_delivery_cancelled or _lost_site_rearm_latched or enable_specialized_c4_parking) else ARRIVAL_EPSILON):
			global_position = _home
			_state = FlightState.DOCKED
		return true

	# Disabling experimental movement or a previously configured battery
	# freezes outbound flight, but cannot silently give unlimited energy.
	if not enable_isolated_drone or (_battery_configured and not enable_isolated_battery):
		return false
	var site: ConstructionSite = _bound_site()
	if not _active_site(site):
		_on_site_ended()
		return false
	if _delivered_worker_latched and not _delivered_worker_valid(site):
		return false

	var target: Vector3 = site.global_position + Vector3.UP * _hover_height
	if _c5p_automated and not target.is_finite():
		return false
	if _state == FlightState.AT_SITE:
		if global_position.distance_to(target) <= ARRIVAL_EPSILON:
			return false
		_state = FlightState.OUTBOUND

	var next_position: Vector3 = global_position.move_toward(
		target, _speed * delta
	)
	if _battery_configured:
		var flight_distance: float = global_position.distance_to(next_position)
		var remaining_return: float = next_position.distance_to(_home)
		var required_units: float = (
			(flight_distance + remaining_return) * _energy_per_meter
			+ RETURN_MARGIN_UNITS
		)
		if _battery_units + 0.00001 < required_units:
			# A moved target or an unexpectedly long route must not spend
			# the energy reserved for returning. Retire this trip early.
			_state = FlightState.RETURNING
			return false
		_battery_units = maxf(
			0.0, _battery_units - flight_distance * _energy_per_meter
		)
	global_position = next_position
	if global_position.distance_to(target) <= ARRIVAL_EPSILON:
		global_position = target
		_state = FlightState.AT_SITE
	return true


func is_at_site() -> bool:
	if _c5p_automated and (not _c5p_enrolled() or not _c5p_tick_owner_ready()):
		return false
	if not enable_isolated_drone or _state != FlightState.AT_SITE:
		return false
	if _delivered_worker_latched and not _delivered_worker_valid(_bound_site()):
		return false
	if (
		_battery_configured and (
			not enable_isolated_battery
			or _battery_units + 0.00001 < (
				global_position.distance_to(_home) * _energy_per_meter
				+ RETURN_MARGIN_UNITS
			)
		)
	):
		return false
	var site: ConstructionSite = _bound_site()
	if not _active_site(site):
		return false
	var target: Vector3 = site.global_position + Vector3.UP * _hover_height
	return global_position.distance_to(target) <= ARRIVAL_EPSILON


func get_flight_state() -> FlightState:
	return _state


# Observation-only identity check for the opt-in physical worker scheduler.
# Never grants ConstructionJob worker availability by itself.
func is_bound_to_site(site: ConstructionSite) -> bool:
	return (
		enable_isolated_drone
		and not _site_ended
		and (not _delivered_worker_latched or _delivered_worker_valid(site))
		and _site_ref != null
		and _site_ref.get_ref() == site
		and _active_site(site)
		and _state in [FlightState.OUTBOUND, FlightState.AT_SITE]
	)


# Explicit one-worker rearm. All legacy one-shot drones remain unchanged.
# The *whole* escrow ledger must be clear, not just this worker's site;
# this intentionally conservative test-only boundary blocks uncertain refunds.
func release_docked_assignment(
	escrow: BlueprintConstructionMaterialEscrow,
	scheduler: BlueprintConstructionSlotScheduler
) -> bool:
	if (
		not enable_isolated_reuse or not enable_isolated_drone
		or _delivered_worker_latched # x7 will define cargo-worker rearm
		or not enable_isolated_battery or not _battery_configured
		or _state != FlightState.DOCKED or not _site_ended
		or _assignment_job == null
		or _assignment_job.state not in [
			ConstructionJob.State.COMPLETE,
			ConstructionJob.State.CANCELLED
		]
		or not global_position.is_equal_approx(_home)
		or _battery_units + 0.00001 < _battery_capacity
		or not _live_release_service(escrow)
		or not _live_release_service(scheduler)
		or escrow.held_count() != 0
		or scheduler.get_active_count() != 0
		or scheduler.has_drone_binding(self)
	):
		return false
	var old_site: ConstructionSite = _bound_site()
	if is_instance_valid(old_site) and scheduler.is_tracking_site(old_site):
		return false
	# A queued-for-deletion old site may still emit tree_exiting later.
	# Disconnect its callbacks before we allow any successor assignment.
	if is_instance_valid(old_site):
		if _assignment_job.job_cancelled.is_connected(_on_site_ended):
			_assignment_job.job_cancelled.disconnect(_on_site_ended)
		if old_site.tree_exiting.is_connected(_on_site_ended):
			old_site.tree_exiting.disconnect(_on_site_ended)
	_site_ref = null
	_assignment_job = null
	_site_ended = false
	_state = FlightState.IDLE
	_reuse_count += 1
	return true


func completed_rearms() -> int:
	return _reuse_count


func _live_release_service(node: Node) -> bool:
	return (
		is_instance_valid(node) and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)


# Physical arrival is observational ONLY, not a worker authorization token.
func grants_worker_readiness() -> bool:
	return false


func _on_site_ended() -> void:
	_site_ended = true
	# Revoke stale readiness of an admitted cargo worker when its site ends,
	# without manufacturing a cancellation or altering the escrow ledger.
	if _lost_site_rearm_latched and _delivered_worker_latched and _assignment_job != null and _assignment_job.state in [ConstructionJob.State.QUEUED, ConstructionJob.State.CONSTRUCTING, ConstructionJob.State.PAUSED]:
		_assignment_job.set_availability(false, false, false)
	if _state in [FlightState.OUTBOUND, FlightState.AT_SITE]:
		_state = FlightState.RETURNING


func _bound_site() -> ConstructionSite:
	if _site_ref == null:
		return null
	return _site_ref.get_ref() as ConstructionSite


func _active_site(site: ConstructionSite) -> bool:
	return (
		not _site_ended and is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree() and site.job != null
		and site.job.state in [
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.CONSTRUCTING,
			ConstructionJob.State.PAUSED
		]
	)


func _valid_queued_site(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site) and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and is_instance_valid(site.target_definition)
		and site.job != null
		and site.job.state == ConstructionJob.State.QUEUED
		and site.job.get_wait_reasons().has(&"workers")
	)


# x5a: source reservation service is the sole caller with the private token.
func cargo_amount() -> int:
	return _cargo_amount


func cargo_item() -> ItemDefinition:
	return _cargo_item


func _begin_pickup(token: RefCounted, dock: PrototypeDroneStorageDock, capacity: int, speed: float) -> bool:
	if _c5p_automated and (not _c5p_enrolled() or self != get_parent().get_node_or_null("LogisticsDrone")):
		return false
	if not enable_isolated_cargo_pickup or not enable_isolated_drone or not _motion_mode_ready() or not is_inside_tree() or is_queued_for_deletion():
		return false
	if _cargo_reuse_latched and (not enable_isolated_cargo_reuse or not _finite_cargo_rearm_ready()):
		return false
	if _state != FlightState.IDLE or _site_ref != null or _pickup_token != null or _cargo_amount != 0 or not global_position.is_equal_approx(_home):
		return false
	if token == null or not is_instance_valid(dock) or not dock.is_inside_tree() or dock.is_queued_for_deletion() or not dock.global_position.is_finite():
		return false
	if capacity <= 0 or capacity > 100000 or not is_finite(speed) or speed <= 0.0 or speed > MAX_SPEED:
		return false
	_pickup_token = token
	_pickup_dock = weakref(dock)
	_pickup_capacity = capacity
	_pre_pickup_rearm_latched = enable_isolated_pre_pickup_rearm and enable_isolated_cargo_reuse
	_lost_site_rearm_latched = enable_isolated_lost_site_rearm and enable_isolated_cargo_reuse
	_speed = speed
	_state = FlightState.PICKUP_OUTBOUND
	return true


func _owns_pickup(token: RefCounted, dock: PrototypeDroneStorageDock) -> bool:
	return enable_isolated_cargo_pickup and enable_isolated_drone and _motion_mode_ready() and token != null and _pickup_token == token and _pickup_dock != null and is_instance_valid(dock) and _pickup_dock.get_ref() == dock and _state in [FlightState.PICKUP_OUTBOUND, FlightState.AT_PICKUP] and _cargo_amount == 0


func _advance_pickup(token: RefCounted, dock: PrototypeDroneStorageDock, delta: float) -> bool:
	if not _c5p_step_valid(delta):
		return false
	if not _owns_pickup(token, dock) or not is_finite(delta) or delta <= 0.0 or not dock.global_position.is_finite():
		return false
	var target: Vector3 = dock.global_position
	var distance: float = global_position.distance_to(target)
	var step: float = minf(distance, _speed * delta)
	var next: Vector3 = global_position.move_toward(target, step)
	var required: float = (step + next.distance_to(_home)) * _energy_per_meter + RETURN_MARGIN_UNITS
	if not _c5p_automated and _battery_units + 0.00001 < required:
		return false
	if not _c5p_automated:
		_battery_units = maxf(0.0, _battery_units - step * _energy_per_meter)
	global_position = next
	_state = FlightState.AT_PICKUP if global_position.is_equal_approx(target) else FlightState.PICKUP_OUTBOUND
	return true


func _take_pickup(token: RefCounted, dock: PrototypeDroneStorageDock, inventory: InventoryComponent, item: ItemDefinition, amount: int, site: ConstructionSite) -> bool:
	if not _owns_pickup(token, dock) or _state != FlightState.AT_PICKUP or not global_position.is_equal_approx(dock.global_position):
		return false
	if not is_instance_valid(inventory) or amount <= 0 or amount > _pickup_capacity:
		return false
	if not is_instance_valid(site) or not site.is_inside_tree() or site.is_queued_for_deletion() or site.get_parent() != get_parent() or site.job == null or site.job.state != ConstructionJob.State.QUEUED or not is_instance_valid(site.target_definition):
		return false
	if not inventory.consume_drone_stock_claim(token, item, amount):
		return false
	_cargo_item = item
	_cargo_amount = amount
	_cargo_site = weakref(site)
	_cargo_job = site.job
	_cargo_definition = site.target_definition
	_pre_pickup_rearm_latched = false
	_pickup_token = null
	_pickup_dock = null
	_pickup_capacity = 0
	_state = FlightState.CARGO_HELD
	return true


func _cancel_pickup(token: RefCounted, supplier: PrototypeDroneSupplierReservations = null, original_site: WeakRef = null, original_job: ConstructionJob = null, original_site_exiting: bool = false) -> void:
	if token == null or _pickup_token != token:
		return
	# Only the exact active claim release can establish terminal provenance.
	# Forecast-only reservations never enter this branch. Source failure or
	# nonterminal site loss does not authorize rearm in x7c1.
	if _pre_pickup_rearm_latched and _cargo_amount == 0 and _cargo_item == null and _cargo_job == null and original_site != null and original_job != null and original_job.state == ConstructionJob.State.CANCELLED and _delivery_live(supplier) and supplier.get_parent() == get_parent():
		_cargo_site = original_site
		_cargo_job = original_job
		_pre_pickup_cancelled = true
		_pre_pickup_supplier = weakref(supplier)
		_pre_pickup_rearm_latched = false
	elif _lost_site_rearm_latched and original_site_exiting and _cargo_amount == 0 and _cargo_item == null and _cargo_job == null and original_site != null and original_job != null and original_job.state in [ConstructionJob.State.QUEUED, ConstructionJob.State.CONSTRUCTING, ConstructionJob.State.PAUSED] and _delivery_live(supplier) and supplier.get_parent() == get_parent():
		_cargo_site = original_site
		_cargo_job = original_job
		_lost_pre_pickup = true
		_pre_pickup_supplier = weakref(supplier)
		_pre_pickup_rearm_latched = false
	_pickup_token = null
	_pickup_dock = null
	_pickup_capacity = 0
	if _pre_pickup_cancelled or _lost_pre_pickup:
		_state = FlightState.DOCKED if global_position.distance_to(_home) <= 0.00001 else FlightState.RETURNING
	else:
		_state = FlightState.DOCKED if global_position.is_equal_approx(_home) else FlightState.RETURNING


# E3d5c5x5b: delivery is never the legacy worker/readiness state.
# The original pickup site/job/definition are pinned by the source service.
# The fixture must have one authoritative registry and one escrow ledger.
func _delivery_live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func _delivery_target(site: ConstructionSite, registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow) -> InventoryComponent:
	if not enable_isolated_cargo_delivery or not enable_isolated_cargo_pickup or not enable_isolated_drone or not _motion_mode_ready() or not _delivery_live(self):
		return null
	if _cargo_amount <= 0 or not is_instance_valid(_cargo_item) or _cargo_site == null or _cargo_site.get_ref() != site:
		return null
	if not _delivery_live(site) or site.get_parent() != get_parent() or site.job == null or site.job != _cargo_job or site.target_definition != _cargo_definition or site.job.state != ConstructionJob.State.QUEUED:
		return null
	if not site.job.get_wait_reasons().has(&"materials"):
		return null
	if not _delivery_live(registry) or not _delivery_live(escrow) or registry.get_parent() != get_parent() or escrow.get_parent() != get_parent() or not registry.enable_isolated_site_registry:
		return null
	var registry_count: int = 0
	var escrow_count: int = 0
	for child: Node in get_parent().get_children():
		if child is BlueprintConstructionSiteStagingRegistry and _delivery_live(child):
			registry_count += 1
		if child is BlueprintConstructionMaterialEscrow and _delivery_live(child):
			escrow_count += 1
	if registry_count != 1 or escrow_count != 1 or escrow.reservation_for(site) != 0:
		return null
	var buffer: InventoryComponent = registry.inventory_for_site(site)
	if not _delivery_live(buffer) or not registry.matches_owned_inventory(site, buffer):
		return null
	if not registry.can_receive_drone_delivery(site, buffer, _cargo_item, _cargo_amount):
		return null
	if _delivery_registry != null and (_delivery_registry.get_ref() != registry or _delivery_escrow.get_ref() != escrow or _delivery_buffer.get_ref() != buffer):
		return null
	return buffer


func _delivery_energy_ok(site: ConstructionSite) -> bool:
	var target: Vector3 = site.global_position + Vector3.UP * 2.0
	var points: Array[Vector3] = [target]
	return route_feasible(points)


func begin_delivery(site: ConstructionSite, registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow) -> bool:
	if _state != FlightState.CARGO_HELD:
		return false
	var buffer := _delivery_target(site, registry, escrow)
	if buffer == null or not _delivery_energy_ok(site):
		return false
	if _delivery_registry == null:
		_delivery_registry = weakref(registry)
		_delivery_escrow = weakref(escrow)
		_delivery_buffer = weakref(buffer)
	_state = FlightState.DELIVERY_OUTBOUND
	return true


func _delivery_site() -> ConstructionSite:
	return _cargo_site.get_ref() as ConstructionSite if _cargo_site != null else null


func _pinned_delivery_target() -> InventoryComponent:
	if _delivery_registry == null or _delivery_escrow == null or _delivery_buffer == null:
		return null
	return _delivery_target(_delivery_site(), _delivery_registry.get_ref() as BlueprintConstructionSiteStagingRegistry, _delivery_escrow.get_ref() as BlueprintConstructionMaterialEscrow)


func advance_delivery(delta: float) -> bool:
	if not _c5p_step_valid(delta):
		return false
	if _state not in [FlightState.DELIVERY_OUTBOUND, FlightState.AT_DELIVERY] or not is_finite(delta) or delta <= 0.0:
		return false
	var site := _delivery_site()
	if _pinned_delivery_target() == null or not _delivery_energy_ok(site):
		_state = FlightState.CARGO_HELD
		return false
	var target: Vector3 = site.global_position + Vector3.UP * 2.0
	var step: float = minf(global_position.distance_to(target), _speed * delta)
	var next: Vector3 = global_position.move_toward(target, step)
	if not _c5p_automated:
		_battery_units = maxf(0.0, _battery_units - step * _energy_per_meter)
	global_position = next
	_state = FlightState.AT_DELIVERY if global_position.distance_to(target) <= 0.00001 else FlightState.DELIVERY_OUTBOUND
	return true


func unload_delivery() -> bool:
	if _state != FlightState.AT_DELIVERY:
		return false
	var buffer := _pinned_delivery_target()
	var site := _delivery_site()
	if buffer == null or not _delivery_energy_ok(site):
		_state = FlightState.CARGO_HELD
		return false
	if global_position.distance_to(site.global_position + Vector3.UP * 2.0) > 0.00001:
		_state = FlightState.DELIVERY_OUTBOUND
		return false
	# Registry checked exact remaining bill and ordinary unreserved capacity.
	# InventoryComponent.add_item is synchronous and has no signals/await.
	# Debit only what was actually accepted, including defensive short writes.
	var accepted: int = buffer.add_item(_cargo_item, _cargo_amount)
	_cargo_amount -= accepted
	if _cargo_amount != 0:
		_state = FlightState.CARGO_HELD
		return false
	_cargo_item = null
	_post_delivery_rearm_latched = enable_isolated_post_delivery_rearm and enable_isolated_cargo_reuse
	_state = FlightState.DELIVERED
	return true


# x5c: observe original job, exact owned buffer and actual escrow. A valid
# handoff is not a readiness grant. The existing scheduler owns that grant.
func _delivered_worker_valid(site: ConstructionSite) -> bool:
	if not enable_isolated_delivered_worker or not enable_isolated_cargo_delivery or not enable_isolated_cargo_pickup or not enable_isolated_drone or not _motion_mode_ready() or not _delivery_live(self):
		return false
	if _cargo_amount != 0 or _cargo_item != null or _cargo_site == null or _cargo_site.get_ref() != site or not _delivery_live(site):
		return false
	if site.get_parent() != get_parent() or site.job == null or site.job != _cargo_job or site.target_definition != _cargo_definition or not _active_site(site):
		return false
	if _delivery_registry == null or _delivery_escrow == null or _delivery_buffer == null:
		return false
	var registry := _delivery_registry.get_ref() as BlueprintConstructionSiteStagingRegistry
	var escrow := _delivery_escrow.get_ref() as BlueprintConstructionMaterialEscrow
	var buffer := _delivery_buffer.get_ref() as InventoryComponent
	if not _delivery_live(registry) or not _delivery_live(escrow) or not _delivery_live(buffer):
		return false
	if registry.get_parent() != get_parent() or escrow.get_parent() != get_parent() or not registry.matches_owned_inventory(site, buffer):
		return false
	return escrow.matches_site_source_bill(site, buffer)


func _promote_delivered_worker(site: ConstructionSite, registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow, scheduler: BlueprintConstructionSlotScheduler) -> bool:
	if _state != FlightState.DELIVERED or _delivered_worker_latched or _site_ref != null or _assignment_job != null:
		return false
	if not _delivered_worker_valid(site) or site.job.state != ConstructionJob.State.QUEUED or not site.job.get_wait_reasons().has(&"workers"):
		return false
	if _delivery_registry.get_ref() != registry or _delivery_escrow.get_ref() != escrow:
		return false
	if not _delivery_energy_ok(site) or global_position.distance_to(site.global_position + Vector3.UP * 2.0) > 0.00001:
		return false
	_site_ref = weakref(site)
	_assignment_job = site.job
	_hover_height = 2.0
	_delivered_worker_latched = true
	_delivered_scheduler = weakref(scheduler)
	_state = FlightState.AT_SITE
	site.job.job_cancelled.connect(_on_site_ended)
	site.tree_exiting.connect(_on_site_ended)
	return true


# Defensive synchronous rollback if binding fails after promotion.
func _rollback_delivered_worker(site: ConstructionSite) -> void:
	if not _delivered_worker_latched or _state != FlightState.AT_SITE or _bound_site() != site:
		return
	if _assignment_job.job_cancelled.is_connected(_on_site_ended):
		_assignment_job.job_cancelled.disconnect(_on_site_ended)
	if site.tree_exiting.is_connected(_on_site_ended):
		site.tree_exiting.disconnect(_on_site_ended)
	_site_ref = null
	_assignment_job = null
	_delivered_worker_latched = false
	_delivered_scheduler = null
	_state = FlightState.DELIVERED


# x6: recovery can only adopt an actual load from a canceled or lost
# original assignment, never a healthy queued delivery or an empty drone.
func _recovery_enabled() -> bool:
	return enable_isolated_cargo_recovery and enable_isolated_cargo_pickup and enable_isolated_drone and _motion_mode_ready() and _delivery_live(self)


func _recovery_cargo_valid() -> bool:
	if not _recovery_enabled() or _cargo_amount <= 0 or not is_instance_valid(_cargo_item) or _cargo_job == null or _cargo_site == null:
		return false
	if _state not in [FlightState.CARGO_HELD, FlightState.DELIVERY_OUTBOUND, FlightState.AT_DELIVERY, FlightState.RECOVERY_WAIT, FlightState.RECOVERY_OUTBOUND, FlightState.AT_RECOVERY]:
		return false
	var site := _delivery_site()
	if _lost_site_rearm_latched and _cargo_job.state != ConstructionJob.State.CANCELLED:
		# A temporary disconnect, reparent, or replaced job on a live object
		# is NOT proof that the original nonterminal job is gone.
		return _original_site_freed() and _cargo_job.state in [ConstructionJob.State.QUEUED, ConstructionJob.State.CONSTRUCTING, ConstructionJob.State.PAUSED]
	return _cargo_job.state == ConstructionJob.State.CANCELLED or not _delivery_live(site) or site.get_parent() != get_parent() or site.job != _cargo_job or site.target_definition != _cargo_definition


func _wait_for_recovery() -> bool:
	if not _recovery_cargo_valid() or _return_token != null:
		return false
	_state = FlightState.RECOVERY_WAIT
	return true


func _begin_cargo_return(token: RefCounted, dock: PrototypeDroneStorageDock) -> bool:
	if not _recovery_cargo_valid() or _state != FlightState.RECOVERY_WAIT or _return_token != null or token == null or not _delivery_live(dock):
		return false
	_return_token = token
	_return_dock = weakref(dock)
	_state = FlightState.RECOVERY_OUTBOUND
	return true


func _owns_cargo_return(token: RefCounted, dock: PrototypeDroneStorageDock, item: ItemDefinition, amount: int) -> bool:
	return _recovery_cargo_valid() and token != null and _return_token == token and _return_dock != null and _delivery_live(dock) and _return_dock.get_ref() == dock and _cargo_item == item and _cargo_amount == amount and _state in [FlightState.RECOVERY_OUTBOUND, FlightState.AT_RECOVERY]


func _cancel_cargo_return(token: RefCounted) -> void:
	if token == null or _return_token != token:
		return
	_return_token = null
	_return_dock = null
	_state = FlightState.RECOVERY_WAIT


func _advance_cargo_return(token: RefCounted, dock: PrototypeDroneStorageDock, delta: float) -> bool:
	if not _c5p_step_valid(delta):
		return false
	if not _owns_cargo_return(token, dock, _cargo_item, _cargo_amount) or not is_finite(delta) or delta <= 0.0:
		return false
	var target: Vector3 = dock.global_position
	var points: Array[Vector3] = [target]
	if not route_feasible(points):
		return false
	var step: float = minf(global_position.distance_to(target), _speed * delta)
	global_position = global_position.move_toward(target, step)
	if not _c5p_automated:
		_battery_units = maxf(0.0, _battery_units - step * _energy_per_meter)
	_state = FlightState.AT_RECOVERY if global_position.distance_to(target) <= 0.00001 else FlightState.RECOVERY_OUTBOUND
	return true


func _deposit_cargo_return(token: RefCounted, dock: PrototypeDroneStorageDock, inventory: InventoryComponent) -> bool:
	if not _owns_cargo_return(token, dock, _cargo_item, _cargo_amount) or _state != FlightState.AT_RECOVERY or not _delivery_live(inventory):
		return false
	if global_position.distance_to(dock.global_position) > 0.00001:
		return false
	if not inventory.consume_drone_return_claim(token, _cargo_item, _cargo_amount):
		return false
	_cargo_amount = 0
	_cargo_item = null
	_return_token = null
	_return_dock = null
	_cargo_recovered = true
	_state = FlightState.RECOVERY_HOME
	return true


# Empty return only. Never rearm the canceled cargo assignment in x6.
func _advance_recovery_home(delta: float) -> bool:
	if not _c5p_step_valid(delta):
		return false
	if not _recovery_enabled() or _state != FlightState.RECOVERY_HOME or _cargo_amount != 0 or _return_token != null or not is_finite(delta) or delta <= 0.0:
		return false
	var distance: float = global_position.distance_to(_home)
	var step: float = minf(distance, _speed * delta) if _c5p_automated else minf(distance, minf(_speed * delta, _battery_units / _energy_per_meter))
	global_position = global_position.move_toward(_home, step)
	if not _c5p_automated:
		_battery_units = maxf(0.0, _battery_units - step * _energy_per_meter)
	if global_position.distance_to(_home) <= 0.00001:
		_state = FlightState.DOCKED
		return true
	return step > 0.0


# x7a: bind once at the exact registered home, no battery mutation.
func _bind_finite_charging(owner: Node, token: RefCounted, at: Vector3) -> bool:
	if not enable_isolated_finite_charging or not _battery_configured or not _delivery_live(self) or not _delivery_live(owner):
		return false
	if not enable_isolated_drone or not enable_isolated_battery or _charging_owner != null or token == null or owner.get_parent() != get_parent():
		return false
	if _state not in [FlightState.IDLE, FlightState.DOCKED] or _cargo_amount != 0 or _cargo_item != null or _pickup_token != null or _return_token != null:
		return false
	if not at.is_finite() or global_position.distance_to(_home) > 0.00001 or _home.distance_to(at) > 0.00001:
		return false
	_charging_owner = weakref(owner)
	_charging_token = token
	return true


# Called only by the registered authority with its exact runtime token.
# Both the battery's own rate/headroom and the shared tick budget apply.
func _accept_finite_charge(owner: Node, token: RefCounted, at: Vector3, delta: float, budget: float) -> float:
	if _c5p_automated:
		return 0.0
	if not enable_isolated_finite_charging or not enable_isolated_drone or not enable_isolated_battery or not _battery_configured or not _delivery_live(self) or not _delivery_live(owner):
		return 0.0
	if token == null or token != _charging_token or _charging_owner == null or _charging_owner.get_ref() != owner or owner.get_parent() != get_parent():
		return 0.0
	if _state not in [FlightState.IDLE, FlightState.DOCKED] or _cargo_amount != 0 or _cargo_item != null or _pickup_token != null or _return_token != null:
		return 0.0
	if not at.is_finite() or not global_position.is_finite() or global_position.distance_to(_home) > 0.00001 or _home.distance_to(at) > 0.00001:
		return 0.0
	if not is_finite(delta) or delta <= 0.0 or not is_finite(budget) or budget <= 0.0:
		return 0.0
	var accepted: float = minf(budget, minf(_charge_units_per_second * delta, maxf(0.0, _battery_capacity - _battery_units)))
	_battery_units += accepted
	return accepted


# x7b: live x7a authority and exact registered dock, not a caller's bool.
func _finite_cargo_rearm_ready() -> bool:
	if _c5p_automated:
		if not _c5p_enrolled() or not _c5p_tick_owner_ready() or not enable_isolated_drone:
			return false
		var dock_owner := _charging_owner.get_ref() as PrototypeDroneHubCharging
		return dock_owner.matches_docked_registration(self, _charging_token)
	if not enable_isolated_finite_charging or not enable_isolated_drone or not _motion_mode_ready() or not _delivery_live(self):
		return false
	if _charging_owner == null or _charging_token == null or _battery_units + 0.00001 < _battery_capacity:
		return false
	if not global_position.is_finite() or not _home.is_finite() or global_position.distance_to(_home) > 0.00001:
		return false
	var owner := _charging_owner.get_ref() as PrototypeDroneHubCharging
	return _delivery_live(owner) and owner.matches_docked_registration(self, _charging_token)


# Whole-scope quiescence is deliberately conservative for this single-drone
# gate. This method releases no stock, escrow, receiver or worker claim.
# Existing services must have resolved those records before rearming.
func release_docked_cargo_assignment(supplier: PrototypeDroneSupplierReservations, returns: PrototypeDroneReturnReservations, coordinator: BlueprintConstructionReadinessCoordinator, escrow: BlueprintConstructionMaterialEscrow, scheduler: BlueprintConstructionSlotScheduler) -> bool:
	if not enable_isolated_cargo_reuse or not enable_isolated_cargo_pickup or not _finite_cargo_rearm_ready() or _state != FlightState.DOCKED:
		return false
	if _cargo_amount != 0 or _cargo_item != null or _pickup_token != null or _pickup_dock != null or _pickup_capacity != 0 or _return_token != null or _return_dock != null or _cargo_job == null or _cargo_site == null:
		return false
	for service: Node in [supplier, returns, coordinator, escrow, scheduler]:
		if not _delivery_live(service) or service.get_parent() != get_parent():
			return false
	# Enforce exact live authoritative service identities; no replacement empty ledger.
	if supplier._service() == null or returns._service() == null or supplier._service() != returns._service():
		return false
	if not coordinator.matches_tick_services(scheduler, escrow):
		return false
	var coordinator_count: int = 0
	var escrow_count: int = 0
	var scheduler_count: int = 0
	for child: Node in get_parent().get_children():
		if not _delivery_live(child):
			continue
		if child is BlueprintConstructionReadinessCoordinator:
			coordinator_count += 1
		if child is BlueprintConstructionMaterialEscrow:
			escrow_count += 1
		if child is BlueprintConstructionSlotScheduler:
			scheduler_count += 1
	if coordinator_count != 1 or escrow_count != 1 or scheduler_count != 1:
		return false
	if supplier.reservation_count() != 0 or returns.reservation_count() != 0 or escrow.held_count() != 0 or scheduler.get_active_count() != 0 or scheduler.has_drone_binding(self):
		return false
	var old_site := _delivery_site()
	if is_instance_valid(old_site) and scheduler.is_tracking_site(old_site):
		return false
	if _lost_site_rearm_latched and _original_site_freed() and (_cargo_job.state in [ConstructionJob.State.QUEUED, ConstructionJob.State.CONSTRUCTING, ConstructionJob.State.PAUSED] or ((_lost_pre_pickup or _lost_post_delivery) and _cargo_job.state == ConstructionJob.State.CANCELLED)):
		if not enable_isolated_lost_site_rearm or not _lost_assignment_cleanup_valid(supplier, coordinator, escrow, scheduler):
			return false
	elif _delivered_worker_latched:
		if not _site_ended or _assignment_job != _cargo_job or _cargo_job.state not in [ConstructionJob.State.COMPLETE, ConstructionJob.State.CANCELLED]:
			return false
		if _delivery_escrow == null or _delivery_escrow.get_ref() != escrow or _delivered_scheduler == null or _delivered_scheduler.get_ref() != scheduler:
			return false
	elif _post_delivery_cancelled:
		if not enable_isolated_post_delivery_rearm or _cargo_job.state != ConstructionJob.State.CANCELLED or _assignment_job != null or _site_ref != null or _cargo_recovered:
			return false
		if _delivery_registry == null or _delivery_buffer == null or _delivery_escrow == null or _delivery_escrow.get_ref() != escrow:
			return false
		var original_registry := _delivery_registry.get_ref() as BlueprintConstructionSiteStagingRegistry
		var original_buffer := _delivery_buffer.get_ref() as InventoryComponent
		if not _delivery_live(original_registry) or original_registry.get_parent() != get_parent() or not _delivery_live(original_buffer):
			return false
		if not coordinator.matches_owned_registry(original_registry) or not original_registry.has_locked_delivery_inventory(_cargo_site, original_buffer):
			return false
	elif _pre_pickup_cancelled:
		if not enable_isolated_pre_pickup_rearm or _pre_pickup_supplier == null or _pre_pickup_supplier.get_ref() != supplier or _cargo_job.state != ConstructionJob.State.CANCELLED or _assignment_job != null or _site_ref != null or _cargo_recovered:
			return false
	elif not _cargo_recovered or _cargo_job.state != ConstructionJob.State.CANCELLED or _assignment_job != null or _site_ref != null:
		return false
	if _delivery_escrow != null and _delivery_escrow.get_ref() != escrow:
		return false
	# Disconnect from the exact old job even if its site has been freed.
	if _cargo_job.job_cancelled.is_connected(_on_site_ended):
		_cargo_job.job_cancelled.disconnect(_on_site_ended)
	var old_bound := _bound_site()
	if is_instance_valid(old_bound) and old_bound.tree_exiting.is_connected(_on_site_ended):
		old_bound.tree_exiting.disconnect(_on_site_ended)
	_site_ref = null
	_assignment_job = null
	_site_ended = false
	_cargo_site = null
	_cargo_job = null
	_cargo_definition = null
	_delivery_registry = null
	_delivery_escrow = null
	_delivery_buffer = null
	_delivered_scheduler = null
	_delivered_worker_latched = false
	_power_parked_assignment = false
	_cargo_recovered = false
	_pre_pickup_cancelled = false
	_pre_pickup_supplier = null
	_pre_pickup_rearm_latched = false
	_post_delivery_rearm_latched = false
	_post_delivery_cancelled = false
	_lost_site_rearm_latched = false
	_lost_pre_pickup = false
	_lost_post_delivery = false
	_cargo_reuse_latched = true
	_state = FlightState.IDLE
	_reuse_count += 1
	return true


# x7c2: the exact terminal job and a successful unload are the proof.
# No material or claim mutation here. The original registry retains its
# receiver lock, and any escrow refund/recovery is the ledger's concern.
# A terminal cancellation permits a safe empty return even if the opt-in
# has since been disabled; current opt-in still gates rearm at home.
func begin_cancelled_delivery_return() -> bool:
	if not _post_delivery_rearm_latched or _post_delivery_cancelled or _state != FlightState.DELIVERED or not _delivery_live(self) or (not _battery_configured and not _c5p_enrolled()):
		return false
	if _cargo_amount != 0 or _cargo_item != null or _cargo_job == null or _cargo_job.state != ConstructionJob.State.CANCELLED or _cargo_site == null:
		return false
	if _delivered_worker_latched or _site_ref != null or _assignment_job != null or _pickup_token != null or _return_token != null:
		return false
	if _delivery_registry == null or _delivery_escrow == null or _delivery_buffer == null:
		return false
	var original_site := _delivery_site()
	if is_instance_valid(original_site) and (original_site.job != _cargo_job or original_site.target_definition != _cargo_definition or original_site.get_parent() != get_parent()):
		return false
	if not global_position.is_finite() or not _home.is_finite() or not is_finite(_battery_units) or not is_finite(_speed) or _speed <= 0.0:
		return false
	_post_delivery_cancelled = true
	_post_delivery_rearm_latched = false
	_state = FlightState.DOCKED if global_position.distance_to(_home) <= 0.00001 else FlightState.RETURNING
	return true


# x7c3: WeakRef null means the original Node object has actually been
# freed, not merely detached, queued for deletion, moved or replaced.
func _original_site_freed() -> bool:
	return _cargo_site != null and _cargo_site.get_ref() == null


# An empty, fully unloaded drone may take the existing metered return
# route when its original nonterminal site is irreversibly gone.
func begin_lost_delivery_return() -> bool:
	if not _lost_site_rearm_latched or _lost_post_delivery or _state != FlightState.DELIVERED or not _delivery_live(self) or (not _battery_configured and not _c5p_enrolled()):
		return false
	if not _original_site_freed() or _cargo_job == null or _cargo_job.state not in [ConstructionJob.State.QUEUED, ConstructionJob.State.CONSTRUCTING, ConstructionJob.State.PAUSED]:
		return false
	if _cargo_amount != 0 or _cargo_item != null or _delivered_worker_latched or _site_ref != null or _assignment_job != null or _pickup_token != null or _return_token != null:
		return false
	if _delivery_registry == null or _delivery_escrow == null or _delivery_buffer == null:
		return false
	if not global_position.is_finite() or not _home.is_finite() or not is_finite(_battery_units) or not is_finite(_speed) or _speed <= 0.0:
		return false
	_lost_post_delivery = true
	_state = FlightState.DOCKED if global_position.distance_to(_home) <= 0.00001 else FlightState.RETURNING
	return true


# Called only from the existing full-charge, whole-scope rearm gate.
# Never change stock, receiver locks, escrow or other worker records.
func _lost_assignment_cleanup_valid(supplier: PrototypeDroneSupplierReservations, coordinator: BlueprintConstructionReadinessCoordinator, escrow: BlueprintConstructionMaterialEscrow, scheduler: BlueprintConstructionSlotScheduler) -> bool:
	if _lost_pre_pickup:
		return _pre_pickup_supplier != null and _pre_pickup_supplier.get_ref() == supplier and not _cargo_recovered and not _delivered_worker_latched and _assignment_job == null and _site_ref == null
	if _delivered_worker_latched:
		if not _site_ended or _assignment_job != _cargo_job or _delivered_scheduler == null or _delivered_scheduler.get_ref() != scheduler:
			return false
		if _cargo_job.state == ConstructionJob.State.CONSTRUCTING:
			return false # Stale worker readiness must have been revoked.
	elif not (_lost_post_delivery or _cargo_recovered) or _assignment_job != null or _site_ref != null:
		return false
	if _delivery_registry == null:
		# Actual loaded cargo recovered before any delivery was begun.
		return _cargo_recovered and not _lost_post_delivery and not _delivered_worker_latched
	if _delivery_escrow == null or _delivery_escrow.get_ref() != escrow or _delivery_buffer == null:
		return false
	var original_registry := _delivery_registry.get_ref() as BlueprintConstructionSiteStagingRegistry
	var original_buffer := _delivery_buffer.get_ref() as InventoryComponent
	return _delivery_live(original_registry) and original_registry.get_parent() == get_parent() and _delivery_live(original_buffer) and coordinator.matches_owned_registry(original_registry) and original_registry.has_locked_delivery_inventory(_cargo_site, original_buffer)


# E3d5c6f B2: fail-closed nonterminal return of a logistics-only delivery.
# No worker admission, escrow mutation, inventory refund, charge, or second tick.
# The original cargo/site/registry/escrow and Stage A receipt must all match.
const SPECIALIZED_SCOPE_E3D5C6F := "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn"
var _specialized_logistics_receipt: int = 0
var _specialized_return_finalized: bool = false

func _specialized_logistics_authorized(contracts: SpecializedDroneRoleContractsE3d5c6f, receipt: int, escrow: BlueprintConstructionMaterialEscrow) -> bool:
	var scope := get_parent() as Node3D
	if not _delivery_live(self) or not _delivery_live(scope) or scope.scene_file_path != SPECIALIZED_SCOPE_E3D5C6F:
		return false
	if name != "LogisticsDrone" or scope.get_node_or_null("LogisticsDrone") != self:
		return false
	if not _delivery_live(contracts) or contracts != scope.get_node_or_null("RoleContracts") or not contracts.receipt_valid(receipt):
		return false
	var site := _delivery_site()
	if not _delivery_live(site) or site.get_parent() != scope or site.job != _cargo_job or site.job.state != ConstructionJob.State.QUEUED:
		return false
	if _delivery_registry == null or _delivery_buffer == null or _delivery_escrow == null:
		return false
	var registry := _delivery_registry.get_ref() as BlueprintConstructionSiteStagingRegistry
	var buffer := _delivery_buffer.get_ref() as InventoryComponent
	if not _delivery_live(registry) or not _delivery_live(buffer) or registry != scope.get_node_or_null("StagingRegistry"):
		return false
	if not _delivery_live(escrow) or escrow != _delivery_escrow.get_ref() or escrow != scope.get_node_or_null("MaterialEscrow"):
		return false
	if not registry.matches_owned_inventory(site, buffer) or not escrow.matches_site_source_bill(site, buffer):
		return false
	var id: int = escrow.reservation_for(site)
	return id > 0 and escrow.held_materials(id) == ConstructionMaterialBill.get_costs(site.target_definition) and _cargo_amount == 0 and _cargo_item == null and not _delivered_worker_latched and _assignment_job == null and _site_ref == null

func begin_specialized_logistics_return(contracts: SpecializedDroneRoleContractsE3d5c6f, receipt: int, escrow: BlueprintConstructionMaterialEscrow) -> bool:
	if receipt <= 0 or _specialized_logistics_receipt != 0 or _state != FlightState.DELIVERED:
		return false
	if not enable_isolated_cargo_pickup or not enable_isolated_cargo_delivery or not enable_isolated_drone or not _motion_mode_ready():
		return false
	if not _specialized_logistics_authorized(contracts, receipt, escrow):
		return false
	if _c5p_automated and not _c5p_enrolled():
		return false
	if not _c5p_automated and _battery_units + 0.00001 < global_position.distance_to(_home) * _energy_per_meter + RETURN_MARGIN_UNITS:
		return false
	_specialized_logistics_receipt = receipt
	_state = FlightState.RETURNING
	return true

# Finishing return is NOT a release of original site material custody.
# Stage B2 is limited to one full-load delivery; do not recycle its receipt.
func finish_specialized_logistics_return(contracts: SpecializedDroneRoleContractsE3d5c6f, receipt: int, escrow: BlueprintConstructionMaterialEscrow) -> bool:
	if _specialized_return_finalized or _specialized_logistics_receipt != receipt or receipt <= 0 or _state != FlightState.DOCKED:
		return false
	if not global_position.is_equal_approx(_home) or not _specialized_logistics_authorized(contracts, receipt, escrow):
		return false
	if _c5p_automated and not _finite_cargo_rearm_ready():
		return false
	if not _c5p_automated and _battery_units + 0.00001 < RETURN_MARGIN_UNITS:
		return false
	# Keep original provenance pinned for later builder handoff and cancellation
	# audit, rather than silently clearing/refunding the reservation.
	_specialized_return_finalized = true
	return true

# C3 terminal empty-return bridge. Receipt is revoked, never reused.
func begin_c3_cancelled_empty_return(controller: SpecializedDroneLogisticsE3d5c6fB2) -> bool:
	if not _delivery_live(controller) or not controller.c3_empty_return_authorized(self):
		return false
	if _state not in [FlightState.DELIVERED, FlightState.RETURNING, FlightState.DOCKED] or _cargo_amount != 0 or _cargo_item != null or _cargo_job == null or _cargo_job.state != ConstructionJob.State.CANCELLED:
		return false
	if _delivered_worker_latched or _site_ref != null or _assignment_job != null or _pickup_token != null or _return_token != null:
		return false
	if not _post_delivery_rearm_latched or _delivery_registry == null or _delivery_buffer == null or _delivery_escrow == null:
		return false
	_post_delivery_cancelled = true
	_post_delivery_rearm_latched = false
	_specialized_logistics_receipt = 0
	_specialized_return_finalized = false
	_state = FlightState.DOCKED if global_position.distance_to(_home) <= 0.00001 else FlightState.RETURNING
	return true

# Dedicated build-only parking path; never set the delivered cargo-worker latch.
func c4_begin_parking(controller: SpecializedDroneBuilderE3d5c6fB3, site: ConstructionSite) -> bool:
	if not enable_specialized_c4_parking or not _delivery_live(controller) or not controller.c4_flight_authorized(self, site) or _bound_site() != site or _assignment_job != site.job or _site_ended:
		return false
	if _state not in [FlightState.OUTBOUND, FlightState.AT_SITE] or site.job.state not in [ConstructionJob.State.QUEUED, ConstructionJob.State.PAUSED] or _cargo_amount != 0 or _cargo_item != null:
		return false
	if _c5p_automated and not _c5p_enrolled():
		return false
	if not _c5p_automated and _battery_units + 0.00001 < global_position.distance_to(_home) * _energy_per_meter + RETURN_MARGIN_UNITS:
		return false
	_c4_parked = true
	_state = FlightState.DOCKED if global_position.distance_to(_home) <= 0.00001 else FlightState.RETURNING
	return true

func c4_can_resume(controller: SpecializedDroneBuilderE3d5c6fB3, site: ConstructionSite) -> bool:
	if not enable_specialized_c4_parking or not _c4_parked or not _delivery_live(controller) or not controller.c4_flight_authorized(self, site) or _bound_site() != site or _assignment_job != site.job or _site_ended:
		return false
	if _state != FlightState.DOCKED or not global_position.is_equal_approx(_home) or site.job.state not in [ConstructionJob.State.QUEUED, ConstructionJob.State.PAUSED] or _cargo_amount != 0 or _cargo_item != null:
		return false
	var points: Array[Vector3] = [site.global_position + Vector3.UP * _hover_height]
	return route_feasible(points)

func c4_begin_resume(controller: SpecializedDroneBuilderE3d5c6fB3, site: ConstructionSite) -> bool:
	if not c4_can_resume(controller, site) or not controller.c4_resume_power_authorized(self, site) or not _finite_cargo_rearm_ready():
		return false
	_state = FlightState.OUTBOUND
	return true

func c4_finish_resume(controller: SpecializedDroneBuilderE3d5c6fB3, site: ConstructionSite) -> bool:
	if not enable_specialized_c4_parking or not _delivery_live(controller) or not controller.c4_flight_authorized(self, site) or not is_at_site() or _bound_site() != site or site.job.state != ConstructionJob.State.CONSTRUCTING:
		return false
	_c4_parked = false
	return true

# C4B: only the original terminal builder controller can retire this
# exact assignment. No material, charging or worker entitlement is created.
var _c4b_retired: bool = false

func c4b_begin_terminal_return(controller: SpecializedDroneBuilderE3d5c6fB3, job: ConstructionJob) -> bool:
	if not enable_specialized_c4_parking or _c4b_retired or not _delivery_live(controller) or not controller.c4b_terminal_flight_authorized(self, job) or job != _assignment_job or not _site_ended:
		return false
	if _state not in [FlightState.OUTBOUND, FlightState.AT_SITE, FlightState.RETURNING, FlightState.DOCKED] or _cargo_amount != 0 or _cargo_item != null or _pickup_token != null or _return_token != null:
		return false
	if _c5p_automated and not _c5p_enrolled():
		return false
	if not _c5p_automated and _battery_units + 0.00001 < global_position.distance_to(_home) * _energy_per_meter:
		return false
	_state = FlightState.DOCKED if global_position.distance_to(_home) <= 0.00001 else FlightState.RETURNING
	return true

func c4b_retire(controller: SpecializedDroneBuilderE3d5c6fB3, job: ConstructionJob) -> bool:
	if _c4b_retired or not _delivery_live(controller) or not controller.c4b_terminal_flight_authorized(self, job) or job != _assignment_job or not _site_ended or _state != FlightState.DOCKED:
		return false
	if global_position.distance_to(_home) > 0.00001 or _cargo_amount != 0 or _cargo_item != null or _pickup_token != null or _return_token != null:
		return false
	if _c5p_automated and not _finite_cargo_rearm_ready():
		return false
	if job.job_cancelled.is_connected(_on_site_ended):
		job.job_cancelled.disconnect(_on_site_ended)
	var old_site := _bound_site()
	if is_instance_valid(old_site) and old_site.tree_exiting.is_connected(_on_site_ended):
		old_site.tree_exiting.disconnect(_on_site_ended)
	_site_ref = null
	_assignment_job = null
	_c4_parked = false
	enable_specialized_c4_parking = false
	enable_isolated_drone = false
	enable_isolated_battery = false
	enable_isolated_finite_charging = false
	_c4b_retired = true
	return true

func c4b_is_retired() -> bool:
	return _c4b_retired and _state == FlightState.DOCKED and global_position.distance_to(_home) <= 0.00001 and _assignment_job == null and _site_ref == null and not _c4_parked and not enable_isolated_drone and not enable_isolated_cargo_pickup and not enable_isolated_cargo_delivery and _cargo_amount == 0 and _cargo_item == null
