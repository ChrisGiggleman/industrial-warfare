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

# Weak site handles avoid retaining deleted construction placeholders.
var _turn_sources: Dictionary = {}


func _ready() -> void:
	registry = PlannedConveyorRouteReservations.new()
	registry.name = "PlannedRouteReservations"
	add_child(registry)

	activator = PlannedConveyorRouteActivator.new()
	activator.name = "PlannedRouteActivator"
	add_child(activator)
	if not activator.bind_registry(registry):
		push_error("Cannot initialize blueprint conveyor route activation.")
	registry.reservation_released.connect(_on_route_released)


func register_new_site(site: ConstructionSite) -> Array[int]:
	var result: Array[int] = []
	if not _is_active_plan(site) or not is_instance_valid(registry):
		return result

	# Connect up to one incoming and one outgoing planned endpoint.
	# Both ends of a middle blueprint are independently reservable.
	var neighbors: Array[ConstructionSite] = []
	for candidate: Node in get_tree().get_nodes_in_group("construction_sites"):
		if not candidate is ConstructionSite:
			continue
		var existing := candidate as ConstructionSite
		if existing == site or not _is_active_plan(existing):
			continue
		# Prevent accidental cross-scene connection when the test runner
		# instantiates more than one factory world at once.
		if existing.get_parent() != site.get_parent():
			continue
		neighbors.append(existing)

	# An already placed source supplies the newly placed destination.
	for existing: ConstructionSite in neighbors:
		if registry.has_endpoint_claim(site, false):
			break
		var id := _reserve_and_visualize(existing, site)
		if id > 0:
			result.append(id)
			break

	# A newly placed source can also supply an existing destination.
	for existing: ConstructionSite in neighbors:
		if registry.has_endpoint_claim(site, true):
			break
		var id := _reserve_and_visualize(site, existing)
		if id > 0:
			result.append(id)
			break

	return result


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
