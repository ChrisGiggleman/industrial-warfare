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

enum FlightState { IDLE, OUTBOUND, AT_SITE, RETURNING, DOCKED, PICKUP_OUTBOUND, AT_PICKUP, CARGO_HELD, DELIVERY_OUTBOUND, AT_DELIVERY, DELIVERED }

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

var _assignment_job: ConstructionJob = null
var _reuse_count: int = 0
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
	if _state in [FlightState.PICKUP_OUTBOUND, FlightState.AT_PICKUP, FlightState.CARGO_HELD, FlightState.DELIVERY_OUTBOUND, FlightState.AT_DELIVERY, FlightState.DELIVERED]:
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


# Explicit one-worker rearm. All legacy one-shot drones remain unchanged.
# The *whole* escrow ledger must be clear, not just this worker's site;
# this intentionally conservative test-only boundary blocks uncertain refunds.
func release_docked_assignment(
	escrow: BlueprintConstructionMaterialEscrow,
	scheduler: BlueprintConstructionSlotScheduler
) -> bool:
	if (
		not enable_isolated_reuse or not enable_isolated_drone
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
	if not enable_isolated_cargo_pickup or not enable_isolated_drone or not enable_isolated_battery or not _battery_configured or not is_inside_tree() or is_queued_for_deletion():
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
	_speed = speed
	_state = FlightState.PICKUP_OUTBOUND
	return true


func _owns_pickup(token: RefCounted, dock: PrototypeDroneStorageDock) -> bool:
	return enable_isolated_cargo_pickup and enable_isolated_drone and enable_isolated_battery and _battery_configured and token != null and _pickup_token == token and _pickup_dock != null and is_instance_valid(dock) and _pickup_dock.get_ref() == dock and _state in [FlightState.PICKUP_OUTBOUND, FlightState.AT_PICKUP] and _cargo_amount == 0


func _advance_pickup(token: RefCounted, dock: PrototypeDroneStorageDock, delta: float) -> bool:
	if not _owns_pickup(token, dock) or not is_finite(delta) or delta <= 0.0 or not dock.global_position.is_finite():
		return false
	var target: Vector3 = dock.global_position
	var distance: float = global_position.distance_to(target)
	var step: float = minf(distance, _speed * delta)
	var next: Vector3 = global_position.move_toward(target, step)
	var required: float = (step + next.distance_to(_home)) * _energy_per_meter + RETURN_MARGIN_UNITS
	if _battery_units + 0.00001 < required:
		return false
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
	_pickup_token = null
	_pickup_dock = null
	_pickup_capacity = 0
	_state = FlightState.CARGO_HELD
	return true


func _cancel_pickup(token: RefCounted) -> void:
	if token == null or _pickup_token != token:
		return
	_pickup_token = null
	_pickup_dock = null
	_pickup_capacity = 0
	_state = FlightState.DOCKED if global_position.is_equal_approx(_home) else FlightState.RETURNING


# E3d5c5x5b: delivery is never the legacy worker/readiness state.
# The original pickup site/job/definition are pinned by the source service.
# The fixture must have one authoritative registry and one escrow ledger.
func _delivery_live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func _delivery_target(site: ConstructionSite, registry: BlueprintConstructionSiteStagingRegistry, escrow: BlueprintConstructionMaterialEscrow) -> InventoryComponent:
	if not enable_isolated_cargo_delivery or not enable_isolated_cargo_pickup or not enable_isolated_drone or not enable_isolated_battery or not _battery_configured or not _delivery_live(self):
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
	var energy: float = estimate_route_energy(points)
	return energy >= 0.0 and energy <= _battery_units + 0.00001


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
	if _state not in [FlightState.DELIVERY_OUTBOUND, FlightState.AT_DELIVERY] or not is_finite(delta) or delta <= 0.0:
		return false
	var site := _delivery_site()
	if _pinned_delivery_target() == null or not _delivery_energy_ok(site):
		_state = FlightState.CARGO_HELD
		return false
	var target: Vector3 = site.global_position + Vector3.UP * 2.0
	var step: float = minf(global_position.distance_to(target), _speed * delta)
	var next: Vector3 = global_position.move_toward(target, step)
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
	_state = FlightState.DELIVERED
	return true
