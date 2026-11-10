extends Node
class_name BlueprintConveyorRouteCoordinator

# =============================================================================
# BLUEPRINT CONVEYOR ROUTES — SANDBOX-ONLY PLACEMENT COORDINATOR
# =============================================================================
# Discovers directed neighboring blueprint sites immediately after placement.
# E2b owns exclusive claims; E2c1 owns operational connection activation.
# This service changes only an unfinished SOURCE's preview appearance.
# It never manufactures cargo, power, materials, or worker availability.

var registry: PlannedConveyorRouteReservations
var activator: PlannedConveyorRouteActivator

# Optional Storage blueprint integration. Must be configured before
# add_child() calls _ready(); Main and older isolated tests stay opt-out.
var enable_storage_port_blueprints: bool = false
var claim_broker: PlannedEndpointClaimBroker = null
var port_registry: PlannedBuildingPortReservations = null
var port_activator: PlannedBuildingPortActivator = null

# Weak site handles avoid retaining deleted construction placeholders.
var _turn_sources: Dictionary = {}


func _ready() -> void:
	if enable_storage_port_blueprints:
		claim_broker = PlannedEndpointClaimBroker.new()
		claim_broker.name = "SharedBlueprintEndpointClaims"
		add_child(claim_broker)

	registry = PlannedConveyorRouteReservations.new()
	registry.name = "PlannedRouteReservations"
	add_child(registry)
	if is_instance_valid(claim_broker):
		if not registry.set_claim_broker(claim_broker):
			push_error("Cannot share conveyor endpoint reservations.")

	activator = PlannedConveyorRouteActivator.new()
	activator.name = "PlannedRouteActivator"
	add_child(activator)
	if not activator.bind_registry(registry):
		push_error("Cannot initialize blueprint conveyor route activation.")
	registry.reservation_released.connect(_on_route_released)

	if enable_storage_port_blueprints:
		port_registry = PlannedBuildingPortReservations.new()
		port_registry.name = "PlannedStoragePortReservations"
		add_child(port_registry)
		if not port_registry.set_claim_broker(claim_broker):
			push_error("Cannot share planned Storage port reservations.")
		port_activator = PlannedBuildingPortActivator.new()
		port_activator.name = "PlannedStoragePortActivator"
		add_child(port_activator)
		if not port_activator.bind_registry(port_registry):
			push_error("Cannot initialize deferred Storage port activation.")


func register_new_site(site: ConstructionSite) -> Array[int]:
	var result: Array[int] = []
	if not is_instance_valid(site) or not site.is_inside_tree():
		return result
	if site.is_queued_for_deletion():
		return result

	# Storage can be planned before or after its connecting belts.
	# Only the explicit sandbox feature opt-in creates these claims.
	if enable_storage_port_blueprints and _is_storage_plan(site):
		return _reserve_storage_neighbors(site)
	if not _is_active_plan(site) or not is_instance_valid(registry):
		return result

	# The shared broker lets the first valid owner claim a directed end.
	# Prefer a matching building port before trying another belt when a
	# newly placed conveyor borders both an existing building and a belt.
	var neighbors: Array[ConstructionSite] = _neighbors(site)
	if is_instance_valid(port_registry):
		for existing: ConstructionSite in neighbors:
			if not _is_storage_plan(existing):
				continue
			for input_side: bool in [true, false]:
				var port_id := port_registry.reserve_pair(
					existing, site, input_side
				)
				if port_id > 0:
					result.append(port_id)

	# Connect up to one incoming and one outgoing belt endpoint. The
	# registry's shared broker rejects ends owned by a Storage port.
	for existing: ConstructionSite in neighbors:
		if not _is_active_plan(existing):
			continue
		if registry.has_endpoint_claim(site, false):
			break
		var incoming_id := _reserve_and_visualize(existing, site)
		if incoming_id > 0:
			result.append(incoming_id)
			break

	for existing: ConstructionSite in neighbors:
		if not _is_active_plan(existing):
			continue
		if registry.has_endpoint_claim(site, true):
			break
		var outgoing_id := _reserve_and_visualize(site, existing)
		if outgoing_id > 0:
			result.append(outgoing_id)
			break

	return result


func _reserve_storage_neighbors(
	storage_site: ConstructionSite
) -> Array[int]:
	var result: Array[int] = []
	if not is_instance_valid(port_registry):
		return result
	for existing: ConstructionSite in _neighbors(storage_site):
		if not _is_active_plan(existing):
			continue
		for input_side: bool in [true, false]:
			var id := port_registry.reserve_pair(
				storage_site, existing, input_side
			)
			if id > 0:
				result.append(id)
	return result


func _neighbors(site: ConstructionSite) -> Array[ConstructionSite]:
	var result: Array[ConstructionSite] = []
	for candidate: Node in get_tree().get_nodes_in_group("construction_sites"):
		if not candidate is ConstructionSite:
			continue
		var existing := candidate as ConstructionSite
		if existing == site or existing.is_queued_for_deletion():
			continue
		# Avoid accidental connections across separate factory worlds.
		if existing.get_parent() != site.get_parent():
			continue
		result.append(existing)
	return result


func _is_storage_plan(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and site.is_inside_tree()
		and not site.is_queued_for_deletion()
		and site.job != null
		and site.accepts_planned_connections()
		and is_instance_valid(site.target_definition)
		and site.target_definition.building_id == &"test_storage"
	)

func _reserve_and_visualize(
	source: ConstructionSite, receiver: ConstructionSite
) -> int:
	if registry.has_endpoint_claim(source, true):
		return 0
	if registry.has_endpoint_claim(receiver, false):
		return 0

	var candidate := PlannedConveyorRouteGeometry.inspect_pair(
		source, receiver
	)
	if candidate.is_empty():
		return 0
	var reservation_id := registry.reserve_pair(source, receiver)
	if reservation_id == 0:
		return 0

	if candidate.get("mode") == "convert_source":
		# If presentation cannot be updated, roll back the claim. Never
		# silently reserve a visually misleading straight blueprint.
		var turn: int = candidate["turn"]
		if not source.set_planned_conveyor_turn(turn):
			registry.release(reservation_id)
			return 0
		_turn_sources[reservation_id] = weakref(source)

	return reservation_id


func _is_active_plan(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and site.is_inside_tree()
		and not site.is_queued_for_deletion()
		and site.job != null
		and site.accepts_planned_connections()
		and is_instance_valid(site.target_definition)
		and site.target_definition.building_id == &"conveyor_belt"
	)


func _on_route_released(reservation_id: int) -> void:
	if not _turn_sources.has(reservation_id):
		return
	var handle: WeakRef = _turn_sources[reservation_id]
	_turn_sources.erase(reservation_id)
	if handle == null:
		return
	var raw_site: Variant = handle.get_ref()
	if not is_instance_valid(raw_site):
		return
	var site := raw_site as ConstructionSite
	if site != null and site.accepts_planned_connections():
		site.clear_planned_conveyor_turn()
