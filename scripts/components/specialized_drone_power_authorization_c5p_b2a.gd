extends Node
class_name SpecializedDronePowerAuthorizationC5PB2A

# Read-only authorization after one explicit topology setup. No tick driver.
const SCOPE := "res://scenes/core/playable_specialized_drones_e3d5c6f.tscn"
const HUB := "res://scenes/buildings/prototype_main_hub.tscn"
const POLE := "res://scenes/buildings/prototype_power_pole.tscn"
var _controller: WeakRef
var _site: WeakRef
var _job: ConstructionJob
var _definition: BuildingDefinition
var _hub: WeakRef
var _hub_node: WeakRef
var _pole: WeakRef
var _pole_node: WeakRef
var _network: WeakRef
var _allocator: WeakRef
var _demand: int = 0

func _live(value: Variant) -> bool:
	return is_instance_valid(value) and value is Node and value.is_inside_tree() and not value.is_queued_for_deletion()

func _real_structure(value: Variant, scope: Node) -> bool:
	if not _live(value) or not value is PrototypePowerStructure or value.get_parent() != scope or value.scene_file_path not in [HUB, POLE]:
		return false
	var structure := value as PrototypePowerStructure
	var node := structure.get_power_node()
	return _live(node) and node.get_parent() == structure and _live(structure.get_health()) and structure.global_transform.is_finite() and node.global_transform.is_finite()

func configure(controller: Node, pole: PrototypePowerStructure, demand: int) -> bool:
	var scope := get_parent()
	if _controller != null or not _live(scope) or scope.scene_file_path != SCOPE or not _live(controller) or controller != scope.get_node_or_null("B2LogisticsController"):
		return false
	if not controller.c5p_power_mode() or controller._c5p_power_authority != self or not controller._c1_owner() or controller.phase != &"c1_ready" or controller.lease_id != 0 or demand != 7:
		return false
	var site := controller.site as ConstructionSite
	var hub := scope.get_node_or_null("MainHub") as PrototypePowerStructure
	var network := scope.get_node_or_null("PowerNetwork") as ConstructionPowerCoverageNetwork
	var allocator := scope.get_node_or_null("PowerAllocator") as PrototypeConstructionPowerAllocator
	if not _live(site) or site.get_parent() != scope or site.job != controller._c1_job or not _real_structure(hub, scope) or not _real_structure(pole, scope) or pole.scene_file_path != POLE or pole.rated_generation != 0:
		return false
	if not _live(network) or not _live(allocator) or allocator._network != network or not network._registered(hub.get_power_node()) or network._registered(pole.get_power_node()):
		return false
	if not network._can_link(hub.get_power_node(), pole.get_power_node()):
		return false
	if not network.register_node(pole.get_power_node()) or not network.link_nodes(hub.get_power_node(), pole.get_power_node()):
		return false
	_controller = weakref(controller)
	_site = weakref(site)
	_job = site.job
	_definition = site.target_definition
	_hub = weakref(hub)
	_hub_node = weakref(hub.get_power_node())
	_pole = weakref(pole)
	_pole_node = weakref(pole.get_power_node())
	_network = weakref(network)
	_allocator = weakref(allocator)
	_demand = demand
	return true

func _valid() -> bool:
	var scope := get_parent()
	if _controller == null or not _live(scope) or scope.scene_file_path != SCOPE or not _live(self) or is_processing() or is_physics_processing():
		return false
	var controller: Variant = _controller.get_ref()
	var site := _site.get_ref() as ConstructionSite
	var hub := _hub.get_ref() as PrototypePowerStructure
	var pole := _pole.get_ref() as PrototypePowerStructure
	var network := _network.get_ref() as ConstructionPowerCoverageNetwork
	var allocator := _allocator.get_ref() as PrototypeConstructionPowerAllocator
	if not _live(controller) or controller != scope.get_node_or_null("B2LogisticsController") or not controller.c5p_power_mode() or not controller.c5p_automated_mode() or controller._c5p_power_authority != self:
		return false
	if not _live(site) or site != controller.site or site.get_parent() != scope or site.job != _job or site.target_definition != _definition or not site.global_transform.is_finite() or site.footprint.x <= 0 or site.footprint.y <= 0 or _job.state not in [ConstructionJob.State.QUEUED, ConstructionJob.State.PAUSED, ConstructionJob.State.CONSTRUCTING]:
		return false
	if not _real_structure(hub, scope) or hub != scope.get_node_or_null("MainHub") or hub.get_power_node() != _hub_node.get_ref() or not _real_structure(pole, scope) or pole.get_power_node() != _pole_node.get_ref():
		return false
	if not _live(network) or network != scope.get_node_or_null("PowerNetwork") or not _live(allocator) or allocator != scope.get_node_or_null("PowerAllocator") or allocator._network != network:
		return false
	if not network._registered(hub.get_power_node()) or not network._registered(pole.get_power_node()):
		return false
	var owner_count := 0
	var networks := 0
	var allocators := 0
	for child: Node in scope.get_children():
		if not _live(child):
			continue
		if child is SpecializedDronePowerAuthorizationC5PB2A:
			owner_count += 1
		if child is ConstructionPowerCoverageNetwork:
			networks += 1
		if child is PrototypeConstructionPowerAllocator:
			allocators += 1
	if owner_count != 1 or networks != 1 or allocators != 1:
		return false
	# Reject synthetic or foreign network participants, even if their flags
	# would make the legacy topology traversal report energized coverage.
	for reference: WeakRef in network._nodes:
		var node := reference.get_ref() as ConstructionPowerNetworkNode
		if not _live(node) or not _real_structure(node.get_parent(), scope):
			return false
		var structure := node.get_parent() as PrototypePowerStructure
		if structure.get_power_node() != node or not network._valid_node(node):
			return false
		var operational: bool = structure.get_health().is_intact() and structure.service_enabled
		if node.operational != operational or node.is_source != (structure.rated_generation > 0) or node.source_online != (operational and structure.rated_generation > 0 and structure.generator_enabled):
			return false
	return true

func matches_builder_topology(pole: PrototypePowerStructure, network: ConstructionPowerCoverageNetwork, allocator: PrototypeConstructionPowerAllocator) -> bool:
	if not _valid() or pole != _pole.get_ref() or network != _network.get_ref() or allocator != _allocator.get_ref():
		return false
	var hub_node := _hub_node.get_ref() as ConstructionPowerNetworkNode
	var pole_node := _pole_node.get_ref() as ConstructionPowerNetworkNode
	for edge: Dictionary in network._edges:
		var a: Variant = edge["a"].get_ref()
		var b: Variant = edge["b"].get_ref()
		if (a == hub_node and b == pole_node) or (b == hub_node and a == pole_node):
			return true
	return false

func snapshot() -> Dictionary:
	var result := {"reason": &"invalid_authority", "hub_powered": false, "site_covered": false, "forecast_available": false, "actual_allocation_ready": false, "required_units": _demand, "spare_units": 0, "allocated_units": 0}
	if not _valid():
		return result
	var network := _network.get_ref() as ConstructionPowerCoverageNetwork
	var allocator := _allocator.get_ref() as PrototypeConstructionPowerAllocator
	var site := _site.get_ref() as ConstructionSite
	result.hub_powered = network.is_energized(_hub_node.get_ref() as ConstructionPowerNetworkNode)
	var covering := allocator._find_covering_node(site, network.get_energized_nodes())
	result.site_covered = covering != null
	if covering != null:
		result.spare_units = allocator.spare_generation_for(covering)
		result.allocated_units = allocator.get_allocated_units(site)
	# A mismatched tracked demand cannot be treated as our own grant.
	for request: Dictionary in allocator._requests:
		if request["site"].get_ref() == site and int(request["demand"]) != _demand:
			return result
	if not result.hub_powered:
		result.reason = &"hub_offline"
	elif not result.site_covered:
		result.reason = &"site_uncovered"
	else:
		var own_grant: bool = int(result.allocated_units) == _demand and allocator.is_fully_allocated(site)
		result.forecast_available = own_grant or int(result.spare_units) >= _demand
		var escrow := get_parent().get_node_or_null("MaterialEscrow") as BlueprintConstructionMaterialEscrow
		var coordinator := get_parent().get_node_or_null("ReadinessCoordinator") as BlueprintConstructionReadinessCoordinator
		result.actual_allocation_ready = own_grant and _live(escrow) and _live(coordinator) and escrow.reservation_for(site) > 0 and coordinator.get_status(site).get("power_allocated", false)
		result.reason = &"actual_allocation_ready" if result.actual_allocation_ready else (&"forecast_available" if result.forecast_available else &"insufficient_supply")
	return result
