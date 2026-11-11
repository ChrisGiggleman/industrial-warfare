extends Node
class_name ConstructionPowerCoverageNetwork

# =============================================================================
# E3D5C3A — EXPLICIT ROOTED NETWORK + FULL-FOOTPRINT COVERAGE
# =============================================================================
# Topology/coverage only: no energy allocation, power production, battery
# charging, worker permission, job availability, inventory or progress.
# Node operational/source_online are controlled by isolated tests for now.
# Do not use this as a real power provider until completed Hub/pole entities
# and actual supply/demand accounting are implemented.
#
# Edges must be explicitly registered. Overlapping coverage circles NEVER
# establish links. Broken, disabled or moved links fail closed at query time.

var _nodes: Array[WeakRef] = []
var _edges: Array[Dictionary] = []


func register_node(node: ConstructionPowerNetworkNode) -> bool:
	if not _valid_node(node) or _registered(node):
		return false
	_nodes.append(weakref(node))
	return true


func link_nodes(a: ConstructionPowerNetworkNode, b: ConstructionPowerNetworkNode) -> bool:
	if a == b or not _registered(a) or not _registered(b):
		return false
	if not _can_link(a, b):
		return false
	for edge: Dictionary in _edges:
		var left: ConstructionPowerNetworkNode = (edge["a"] as WeakRef).get_ref() as ConstructionPowerNetworkNode
		var right: ConstructionPowerNetworkNode = (edge["b"] as WeakRef).get_ref() as ConstructionPowerNetworkNode
		if (left == a and right == b) or (left == b and right == a):
			return false
	_edges.append({"a": weakref(a), "b": weakref(b)})
	return true


func unlink_nodes(a: ConstructionPowerNetworkNode, b: ConstructionPowerNetworkNode) -> bool:
	var removed: bool = false
	var retained: Array[Dictionary] = []
	for edge: Dictionary in _edges:
		var left: ConstructionPowerNetworkNode = (edge["a"] as WeakRef).get_ref() as ConstructionPowerNetworkNode
		var right: ConstructionPowerNetworkNode = (edge["b"] as WeakRef).get_ref() as ConstructionPowerNetworkNode
		if (left == a and right == b) or (left == b and right == a):
			removed = true
		else:
			retained.append(edge)
	_edges = retained
	return removed


func get_energized_nodes() -> Array[ConstructionPowerNetworkNode]:
	var powered: Array[ConstructionPowerNetworkNode] = []
	var pending: Array[ConstructionPowerNetworkNode] = []
	for ref: WeakRef in _nodes:
		var candidate: ConstructionPowerNetworkNode = ref.get_ref() as ConstructionPowerNetworkNode
		if (
			_valid_node(candidate) and candidate.operational
			and candidate.is_source and candidate.source_online
		):
			if not powered.has(candidate):
				powered.append(candidate)
				pending.append(candidate)

	while not pending.is_empty():
		var current: ConstructionPowerNetworkNode = pending.pop_front()
		for edge: Dictionary in _edges:
			var left: ConstructionPowerNetworkNode = (edge["a"] as WeakRef).get_ref() as ConstructionPowerNetworkNode
			var right: ConstructionPowerNetworkNode = (edge["b"] as WeakRef).get_ref() as ConstructionPowerNetworkNode
			if not _can_link(left, right):
				continue
			var next: ConstructionPowerNetworkNode = null
			if left == current:
				next = right
			elif right == current:
				next = left
			if (
				next != null and _registered(next) and next.operational
				and not powered.has(next)
			):
				powered.append(next)
				pending.append(next)
	return powered


func is_energized(node: ConstructionPowerNetworkNode) -> bool:
	return get_energized_nodes().has(node)


# A single energized node must contain the ENTIRE rotated construction
# footprint. This conservative rule avoids falsely reporting coverage for
# a building with an uncovered center or edge between overlapping circles.
# PLANNED sites may be inspected for previews but never get job permission.
func covers_site(site: ConstructionSite) -> bool:
	if (
		not is_instance_valid(site) or site.is_queued_for_deletion()
		or not site.is_inside_tree() or site.job == null
		or not is_instance_valid(site.target_definition)
		or site.job.state in [
			ConstructionJob.State.COMPLETE,
			ConstructionJob.State.CANCELLED
		]
		or site.footprint.x < 1 or site.footprint.y < 1
	):
		return false
	var half_x: float = float(site.footprint.x) * 0.5
	var half_z: float = float(site.footprint.y) * 0.5
	var corners: Array[Vector3] = [
		Vector3(-half_x, 0, -half_z),
		Vector3(-half_x, 0, half_z),
		Vector3(half_x, 0, -half_z),
		Vector3(half_x, 0, half_z)
	]
	for power_node: ConstructionPowerNetworkNode in get_energized_nodes():
		var inside: bool = true
		for corner: Vector3 in corners:
			var world_position: Vector3 = site.to_global(corner)
			var delta: Vector2 = Vector2(
				world_position.x - power_node.global_position.x,
				world_position.z - power_node.global_position.z
			)
			if delta.length() > power_node.coverage_radius + 0.0001:
				inside = false
				break
		if inside:
			return true
	return false


func _registered(node: ConstructionPowerNetworkNode) -> bool:
	if not _valid_node(node):
		return false
	for ref: WeakRef in _nodes:
		if ref.get_ref() == node:
			return true
	return false


func _valid_node(node: ConstructionPowerNetworkNode) -> bool:
	return (
		is_instance_valid(node) and not node.is_queued_for_deletion()
		and node.is_inside_tree()
		and is_finite(node.link_range) and node.link_range > 0.0
		and is_finite(node.coverage_radius) and node.coverage_radius > 0.0
	)


func _can_link(a: ConstructionPowerNetworkNode, b: ConstructionPowerNetworkNode) -> bool:
	if not _valid_node(a) or not _valid_node(b):
		return false
	if not a.operational or not b.operational:
		return false
	var delta: Vector2 = Vector2(
		a.global_position.x - b.global_position.x,
		a.global_position.z - b.global_position.z
	)
	return delta.length() <= minf(a.link_range, b.link_range) + 0.0001
