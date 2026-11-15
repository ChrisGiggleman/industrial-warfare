extends RefCounted
## E3d5c5s: isolated read-only structural description, not delivery authority.
const MAX_BELTS: int = 66
const MAX_RUN: int = 64

var _origin: WeakRef
var _receiver: WeakRef
var _scope: WeakRef
var _source_stock: WeakRef
var _target_stock: WeakRef
var _steps: Array[Dictionary] = []
var _allow_corners: bool = false

# Steps are actual belt nodes or {"input": port, "output": port} crossings.
static func capture(origin: ItemPortComponent, receiver: ItemPortComponent, steps: Array, allow_corners: bool = false) -> RefCounted:
	if not _live(origin) or not _live(receiver) or not _live(origin.inventory) or not _live(receiver.inventory):
		return null
	if not _live(receiver.get_parent()) or not _live(receiver.get_parent().get_parent()) or steps.is_empty() or steps.size() > 68:
		return null
	var result = load("res://scripts/components/unified_factory_route_descriptor.gd").new()
	result._origin = weakref(origin)
	result._receiver = weakref(receiver)
	result._scope = weakref(receiver.get_parent().get_parent())
	result._source_stock = weakref(origin.inventory)
	result._target_stock = weakref(receiver.inventory)
	result._allow_corners = allow_corners
	for value: Variant in steps:
		if value is ConveyorSegment:
			var belt := value as ConveyorSegment
			if not _live(belt):
				return null
			var a := belt.get_node_or_null("InputEndpoint") as Marker3D
			var z := belt.get_node_or_null("OutputEndpoint") as Marker3D
			if not _live(a) or not _live(z):
				return null
			result._steps.append({"kind": "belt", "node": weakref(belt), "a": weakref(a), "z": weakref(z),
				"a_pose": a.transform, "z_pose": z.transform, "turn": belt.get_meta("conveyor_turn", -1)})
		elif value is Dictionary:
			var p := value.get("input") as ItemPortComponent
			var q := value.get("output") as ItemPortComponent
			if not _live(p) or not _live(q) or not _live(p.get_parent()) or p.get_parent() != q.get_parent():
				return null
			if not _live(p.inventory) or not _live(q.inventory):
				return null
			result._steps.append({"kind": "junction", "node": weakref(p.get_parent()), "input": weakref(p),
				"output": weakref(q), "in_stock": weakref(p.inventory), "out_stock": weakref(q.inventory)})
		else:
			return null
	return result if result.validate() else null


static func _live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func _object(step: Dictionary, key: String) -> Object:
	var ref := step.get(key) as WeakRef
	return ref.get_ref() if ref != null else null


func _piece(belt: ConveyorSegment, a: Marker3D, z: Marker3D) -> bool:
	if belt.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn" or not a.position.is_equal_approx(Vector3(0, 0.5, 0.5)):
		return false
	var af: Vector3 = (a.transform.basis * Vector3.FORWARD).normalized()
	var zf: Vector3 = (z.transform.basis * Vector3.FORWARD).normalized()
	if not belt.has_meta("conveyor_turn"):
		return z.position.is_equal_approx(Vector3(0, 0.5, -0.5)) and af.dot(zf) < -0.98
	if not _allow_corners:
		return false
	var turn: int = int(belt.get_meta("conveyor_turn"))
	if turn == ConveyorTurnIntent.Turn.RIGHT:
		return z.position.is_equal_approx(Vector3(0.5, 0.5, 0)) and absf(af.dot(zf)) < 0.02
	if turn == ConveyorTurnIntent.Turn.LEFT:
		return z.position.is_equal_approx(Vector3(-0.5, 0.5, 0)) and absf(af.dot(zf)) < 0.02
	return false


func _link(belt: ConveyorSegment, port: ItemPortComponent, input_side: bool) -> bool:
	if not _live(port) or port.connected_conveyor != belt:
		return false
	if input_side:
		return port.direction == ItemPortComponent.PortDirection.OUTPUT and belt.previous_segment == null and belt.input_building_port == port and LogisticsConnectionGeometry.are_endpoints_aligned(port, belt.get_node_or_null("InputEndpoint"), ConveyorSegment.CONNECTION_GAP)
	return port.direction == ItemPortComponent.PortDirection.INPUT and belt.next_segment == null and belt.output_building_port == port and LogisticsConnectionGeometry.are_endpoints_aligned(belt.get_node_or_null("OutputEndpoint"), port, ConveyorSegment.CONNECTION_GAP)


# Check exact physical junction lane shape without calling ledger-mutating readiness.
func _junction(step: Dictionary, scope: Node) -> String:
	var building := _object(step, "node") as Node
	var p := _object(step, "input") as ItemPortComponent
	var q := _object(step, "output") as ItemPortComponent
	if not _live(building) or building.get_parent() != scope or not _live(p) or not _live(q):
		return ""
	if p == q or p.get_parent() != building or q.get_parent() != building:
		return ""
	if p.direction != ItemPortComponent.PortDirection.INPUT or q.direction != ItemPortComponent.PortDirection.OUTPUT:
		return ""
	if not _live(p.inventory) or not _live(q.inventory) or p.inventory == q.inventory:
		return ""
	if p.inventory.get_parent() != building or q.inventory.get_parent() != building or _object(step, "in_stock") != p.inventory or _object(step, "out_stock") != q.inventory:
		return ""
	if p.inventory.max_capacity != 5 or q.inventory.max_capacity != 1:
		return ""
	if building.scene_file_path == "res://scenes/buildings/conveyor_splitter.tscn":
		var s := building.get_node_or_null("SplitterComponent") as ConveyorSplitterComponent
		if not _live(s) or p != building.get_node_or_null("InputPort") or p.inventory != s.input_inventory:
			return ""
		var ports: Array = [s.output_port_a, s.output_port_b, s.output_port_c]
		var buffers: Array = [s.output_a, s.output_b, s.output_c]
		var lane: int = ports.find(q)
		if lane < 0 or q.inventory != buffers[lane]:
			return ""
		return "splitter"
	if building.scene_file_path == "res://scenes/buildings/conveyor_merger.tscn":
		var m := building.get_node_or_null("MergerComponent") as ConveyorMergerComponent
		if not _live(m) or q != building.get_node_or_null("OutputPort") or q.inventory != m.output_inventory:
			return ""
		var ports: Array = [building.get_node_or_null("InputPortA"), building.get_node_or_null("InputPortB"), building.get_node_or_null("InputPortC")]
		var buffers: Array = [m.input_a, m.input_b, m.input_c]
		var lane: int = ports.find(p)
		if lane < 0 or p.inventory != buffers[lane]:
			return ""
		return "merger"
	return ""


func validate() -> bool:
	if _origin == null or _receiver == null or _scope == null or _steps.is_empty():
		return false
	var origin := _origin.get_ref() as ItemPortComponent
	var receiver := _receiver.get_ref() as ItemPortComponent
	var scope := _scope.get_ref() as Node
	if not _live(origin) or not _live(receiver) or not _live(scope) or origin == receiver:
		return false
	if not _live(origin.get_parent()) or not _live(receiver.get_parent()):
		return false
	if origin.get_parent().get_parent() != scope or receiver.get_parent().get_parent() != scope:
		return false
	if not _live(origin.inventory) or not _live(receiver.inventory) or origin.inventory == receiver.inventory:
		return false
	if _source_stock.get_ref() != origin.inventory or _target_stock.get_ref() != receiver.inventory:
		return false
	if origin.get_parent().has_node("SplitterComponent") or origin.get_parent().has_node("MergerComponent"):
		return false
	var seen: Dictionary = {}
	var junctions: Array[String] = []
	var run: int = 0
	var count: int = 0
	var has_corner: bool = false
	var previous: ConveyorSegment = null
	var pending: ItemPortComponent = origin
	for step: Dictionary in _steps:
		var node := _object(step, "node") as Node
		if not _live(node) or node.get_parent() != scope or seen.has(node):
			return false
		seen[node] = true
		if step["kind"] == "belt":
			var belt := node as ConveyorSegment
			if belt == null:
				return false
			var a := belt.get_node_or_null("InputEndpoint") as Marker3D
			var z := belt.get_node_or_null("OutputEndpoint") as Marker3D
			if not _live(a) or not _live(z) or _object(step, "a") != a or _object(step, "z") != z:
				return false
			if not a.transform.is_equal_approx(step["a_pose"]) or not z.transform.is_equal_approx(step["z_pose"]) or belt.get_meta("conveyor_turn", -1) != step["turn"]:
				return false
			if not _piece(belt, a, z):
				return false
			has_corner = has_corner or belt.has_meta("conveyor_turn")
			if pending != null:
				if not _link(belt, pending, true):
					return false
				pending = null
			else:
				if previous == null or previous.next_segment != belt or belt.previous_segment != previous or previous.output_building_port != null or belt.input_building_port != null:
					return false
				if not LogisticsConnectionGeometry.are_endpoints_aligned(previous.get_node_or_null("OutputEndpoint"), a, ConveyorSegment.CONNECTION_GAP):
					return false
			previous = belt
			run += 1
			count += 1
			if run > MAX_RUN or count > MAX_BELTS:
				return false
		elif step["kind"] == "junction":
			if previous == null or run != 1 or junctions.size() >= 2:
				return false
			var kind: String = _junction(step, scope)
			if kind.is_empty() or junctions.has(kind) or not _link(previous, _object(step, "input") as ItemPortComponent, false):
				return false
			junctions.append(kind)
			pending = _object(step, "output") as ItemPortComponent
			previous = null
			run = 0
		else:
			return false
	if previous == null or pending != null or run == 0:
		return false
	if has_corner and (not junctions.is_empty() or count < 2):
		return false
	return _link(previous, receiver, false)


func belt_count() -> int:
	var count: int = 0
	for step: Dictionary in _steps:
		if step["kind"] == "belt":
			count += 1
	return count


func junction_count() -> int:
	return _steps.size() - belt_count()
