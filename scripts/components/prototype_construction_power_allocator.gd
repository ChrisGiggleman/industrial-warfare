extends Node
class_name PrototypeConstructionPowerAllocator

# =============================================================================
# E3D5C3B2 — ISOLATED FINITE ELECTRICAL BUDGET
# =============================================================================
# Evaluates allocation within each explicit, live connected component.
# Only completed PrototypePowerStructure sources contribute their current
# enabled rated generation. Test-only synthetic source flags contribute ZERO.
#
# ConstructionSite demand is all-or-nothing. Existing CONSTRUCTING work is
# served first, then queued/paused High -> Normal -> Low, FIFO per tier.
# No preemption of active work merely because High priority was authorized.
# This service is READ-ONLY with respect to jobs, workers and inventories.
#
# IMPORTANT: nameplate energy is not fuel, actual supply/demand metering, or
# permission to start a construction job. It may be consumed only by a future
# validated coordinator after real material escrow and worker scheduling.
# Main / Factory Testing Sandbox do not instantiate this service.

var _network: ConstructionPowerCoverageNetwork = null
var _requests: Array[Dictionary] = []
var _next_order: int = 0


func configure(network: ConstructionPowerCoverageNetwork) -> bool:
	if is_instance_valid(_network) or not _requests.is_empty():
		return false
	if not is_instance_valid(network) or not network.is_inside_tree():
		return false
	_network = network
	return true


func track_site(site: ConstructionSite, required_units: int) -> bool:
	if not is_instance_valid(_network) or not _valid_site(site):
		return false
	if required_units <= 0 or required_units > 100000:
		return false
	if _tracked(site):
		return false
	_requests.append({
		"site": weakref(site),
		"demand": required_units,
		"order": _next_order
	})
	_next_order += 1
	return true


func stop_tracking(site: ConstructionSite) -> void:
	if not is_instance_valid(site):
		return
	var retained: Array[Dictionary] = []
	for request: Dictionary in _requests:
		if (request["site"] as WeakRef).get_ref() != site:
			retained.append(request)
	_requests = retained


func get_allocated_units(site: ConstructionSite) -> int:
	if not _valid_site(site):
		return 0
	var allocations: Dictionary = get_allocations()
	return int(allocations.get(site, 0))


func is_fully_allocated(site: ConstructionSite) -> bool:
	if not _valid_site(site):
		return false
	var expected: int = 0
	for request: Dictionary in _requests:
		if (request["site"] as WeakRef).get_ref() == site:
			expected = int(request["demand"])
			break
	return expected > 0 and get_allocated_units(site) == expected


func get_allocations() -> Dictionary:
	var allocations: Dictionary = {}
	if not is_instance_valid(_network):
		return allocations

	var energized: Array[ConstructionPowerNetworkNode] = (
		_network.get_energized_nodes()
	)
	var components: Array[Dictionary] = []
	var queued: Array[Dictionary] = []
	for request: Dictionary in _requests:
		var site: ConstructionSite = (
			(request["site"] as WeakRef).get_ref() as ConstructionSite
		)
		if not _valid_site(site):
			continue
		allocations[site] = 0
		var covering: ConstructionPowerNetworkNode = (
			_find_covering_node(site, energized)
		)
		if covering == null:
			continue

		var index: int = -1
		for i: int in range(components.size()):
			var nodes: Array = components[i]["nodes"]
			if nodes.has(covering):
				index = i
				break
		if index < 0:
			var component_nodes: Array[ConstructionPowerNetworkNode] = (
				_network.get_operational_component(covering)
			)
			var generation: int = 0
			for power_node: ConstructionPowerNetworkNode in component_nodes:
				var parent: PrototypePowerStructure = (
					power_node.get_parent() as PrototypePowerStructure
				)
				if (
					is_instance_valid(parent)
					and not parent.is_queued_for_deletion()
					and parent.get_power_node() == power_node
				):
					generation += maxi(
						0, parent.available_nameplate_generation()
					)
			components.append({
				"nodes": component_nodes,
				"capacity": generation,
				"used": 0
			})
			index = components.size() - 1

		var candidate: Dictionary = request.duplicate()
		candidate["component"] = index
		candidate["site_obj"] = site
		queued.append(candidate)

	# Non-preemptive for currently constructing jobs; priorities govern
	# future assignments among jobs not yet constructing.
	queued.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var left: ConstructionSite = a["site_obj"] as ConstructionSite
		var right: ConstructionSite = b["site_obj"] as ConstructionSite
		var left_active: bool = left.job.state == ConstructionJob.State.CONSTRUCTING
		var right_active: bool = right.job.state == ConstructionJob.State.CONSTRUCTING
		if left_active != right_active:
			return left_active
		var left_priority: int = int(left.job.priority)
		var right_priority: int = int(right.job.priority)
		if left_priority != right_priority:
			return left_priority < right_priority
		return int(a["order"]) < int(b["order"])
	)

	for candidate: Dictionary in queued:
		var component_index: int = int(candidate["component"])
		var component: Dictionary = components[component_index]
		var demand: int = int(candidate["demand"])
		if int(component["capacity"]) - int(component["used"]) >= demand:
			component["used"] = int(component["used"]) + demand
			var site: ConstructionSite = candidate["site_obj"] as ConstructionSite
			allocations[site] = demand
	return allocations


func _find_covering_node(
	site: ConstructionSite,
	energized: Array[ConstructionPowerNetworkNode]
) -> ConstructionPowerNetworkNode:
	if not _valid_site(site):
		return null
	var half_x: float = 0.5 * float(site.footprint.x)
	var half_z: float = 0.5 * float(site.footprint.y)
	var corners: Array[Vector3] = [
		Vector3(-half_x, 0.0, -half_z),
		Vector3(-half_x, 0.0, half_z),
		Vector3(half_x, 0.0, -half_z),
		Vector3(half_x, 0.0, half_z)
	]
	for power_node: ConstructionPowerNetworkNode in energized:
		var covered: bool = true
		for corner: Vector3 in corners:
			var position: Vector3 = site.to_global(corner)
			var offset: Vector2 = Vector2(
				position.x - power_node.global_position.x,
				position.z - power_node.global_position.z
			)
			if offset.length() > power_node.coverage_radius + 0.0001:
				covered = false
				break
		if covered:
			return power_node
	return null


func _tracked(site: ConstructionSite) -> bool:
	for request: Dictionary in _requests:
		if (request["site"] as WeakRef).get_ref() == site:
			return true
	return false


func _valid_site(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site) and not site.is_queued_for_deletion()
		and site.is_inside_tree() and site.job != null
		and is_instance_valid(site.target_definition)
		and site.footprint.x > 0 and site.footprint.y > 0
		and site.job.state in [
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.PAUSED,
			ConstructionJob.State.CONSTRUCTING
		]
	)
