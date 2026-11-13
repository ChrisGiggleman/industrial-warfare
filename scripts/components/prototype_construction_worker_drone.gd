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
		global_position = global_position.move_toward(_home, _speed * delta)
		if global_position.distance_to(_home) <= ARRIVAL_EPSILON:
			global_position = _home
			_state = FlightState.DOCKED
		return true

	# Disabling experimental movement freezes outbound flight, not job gates.
	if not enable_isolated_drone:
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

	global_position = global_position.move_toward(target, _speed * delta)
	if global_position.distance_to(target) <= ARRIVAL_EPSILON:
		global_position = target
		_state = FlightState.AT_SITE
	return true


func is_at_site() -> bool:
	if not enable_isolated_drone or _state != FlightState.AT_SITE:
		return false
	var site: ConstructionSite = _bound_site()
	if not _active_site(site):
		return false
	var target: Vector3 = site.global_position + Vector3.UP * _hover_height
	return global_position.distance_to(target) <= ARRIVAL_EPSILON


func get_flight_state() -> FlightState:
	return _state


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
