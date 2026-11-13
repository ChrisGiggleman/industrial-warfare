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

enum FlightState { IDLE, OUTBOUND, AT_SITE, RETURNING, DOCKED }

const ARRIVAL_EPSILON: float = 0.05
const MAX_SPEED: float = 50.0

@export var enable_isolated_drone: bool = false

# E3d5c4x: experimental battery is OFF by default; once configured, power
# accounting stays latched even if this option is disabled.
@export var enable_isolated_battery: bool = false
const RETURN_MARGIN_UNITS: float = 0.25
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
func configure_battery(
	capacity_units: float,
	starting_units: float,
	units_per_meter: float,
	charge_per_second: float
) -> bool:
	if (
		not enable_isolated_battery or _battery_configured
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
		or _site_ref != null or _state != FlightState.IDLE
		or not _valid_queued_site(site)
		or not home_position.is_finite()
		or not is_finite(flight_speed)
		or flight_speed <= 0.0 or flight_speed > MAX_SPEED
		or not is_finite(hover_height)
		or hover_height < 0.5 or hover_height > 10.0
	):
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
			return false
		if _battery_configured:
			_battery_units = maxf(
				0.0, _battery_units - return_distance * _energy_per_meter
			)
		global_position = next_return
		if global_position.distance_to(_home) <= ARRIVAL_EPSILON:
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

	var target: Vector3 = site.global_position + Vector3.UP * _hover_height
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
	if not enable_isolated_drone or _state != FlightState.AT_SITE:
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
		and _site_ref != null
		and _site_ref.get_ref() == site
		and _active_site(site)
		and _state in [FlightState.OUTBOUND, FlightState.AT_SITE]
	)


# Physical arrival is observational ONLY, not a worker authorization token.
func grants_worker_readiness() -> bool:
	return false


func _on_site_ended() -> void:
	_site_ended = true
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
