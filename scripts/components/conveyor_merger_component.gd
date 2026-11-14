extends Node
class_name ConveyorMergerComponent

# =============================================================================
# THREE INPUT LANES TO ONE PHYSICAL OUTPUT
# =============================================================================

# Three isolated input buffers and one bounded output buffer.
# Alternates among available inputs without removing any item unless
# the output can accept it. An unavailable input is skipped fairly.
# All external transfers still use ItemPortComponent and conveyors.

@export var input_a: InventoryComponent
@export var input_b: InventoryComponent
@export var input_c: InventoryComponent
@export var output_inventory: InventoryComponent
@export_range(0.05, 10.0, 0.05) var merge_interval: float = 0.25

var elapsed: float = 0.0
var next_lane: int = 0
var completed_merges: int = 0
var completed_from_a: int = 0
var completed_from_b: int = 0
var completed_from_c: int = 0

# Independent opt-in. Observations never determine physical distribution.
@export var enable_isolated_merger_provenance: bool = false:
	set(value):
		if enable_isolated_merger_provenance == value:
			return
		enable_isolated_merger_provenance = value
		_provenance_epoch += 1
		_ledgers.clear()

var _provenance_bound: bool = false
var _provenance_epoch: int = 0
var _pinned_buffers: Array[WeakRef] = []
var _pinned_ports: Array[WeakRef] = []
var _ledgers: Dictionary = {}


func _process(delta: float) -> void:
	if merge_interval <= 0.0:
		return
	elapsed += delta
	if elapsed < merge_interval:
		return
	elapsed = minf(elapsed - merge_interval, merge_interval)
	advance_merge()


func advance_merge() -> bool:
	if (
		not is_instance_valid(input_a)
		or not is_instance_valid(input_b)
		or not is_instance_valid(input_c)
		or not is_instance_valid(output_inventory)
	):
		return false

	if output_inventory.get_available_space() == 0:
		return false

	var lanes: Array[InventoryComponent] = [input_a, input_b, input_c]
	for offset: int in range(lanes.size()):
		var lane: int = (next_lane + offset) % lanes.size()
		var inventory: InventoryComponent = lanes[lane]

		for key in inventory.items.keys():
			var item: ItemDefinition = key as ItemDefinition
			if item == null or not inventory.has_amount(item, 1):
				continue
			var source_state: Dictionary = {}
			var destination_state: Dictionary = {}
			var proof: Dictionary = {}
			if _provenance_ready():
				source_state = _ledger(inventory)
				destination_state = _ledger(output_inventory)
				proof = _peek(source_state, item)
			if inventory.transfer_to(output_inventory, item, 1) != 1:
				continue
			if not source_state.is_empty() and not destination_state.is_empty():
				_remove_observation(inventory, source_state, item)
				if not proof.is_empty():
					proof["merger"] = weakref(self)
					proof["output_port"] = _pinned_ports[3]
					proof["epoch"] = _provenance_epoch
				_append_observation(output_inventory, destination_state, item, proof)

			next_lane = (lane + 1) % lanes.size()
			completed_merges += 1
			match lane:
				0:
					completed_from_a += 1
				1:
					completed_from_b += 1
				2:
					completed_from_c += 1
			return true

	return false

func uses_merger_provenance() -> bool:
	return enable_isolated_merger_provenance or _provenance_bound


func _ports() -> Array[ItemPortComponent]:
	var owner: Node = get_parent()
	return [
		owner.get_node_or_null("InputPortA") as ItemPortComponent,
		owner.get_node_or_null("InputPortB") as ItemPortComponent,
		owner.get_node_or_null("InputPortC") as ItemPortComponent,
		owner.get_node_or_null("OutputPort") as ItemPortComponent
	]


func configure_merger_provenance() -> bool:
	if not enable_isolated_merger_provenance or _provenance_bound or not _shape_valid():
		return false
	var buffers: Array[InventoryComponent] = [input_a, input_b, input_c, output_inventory]
	for inventory: InventoryComponent in buffers:
		if inventory.get_total_amount() != 0:
			return false
	for inventory: InventoryComponent in buffers:
		_pinned_buffers.append(weakref(inventory))
	for port: ItemPortComponent in _ports():
		_pinned_ports.append(weakref(port))
	_provenance_bound = true
	return true


func _shape_valid() -> bool:
	var owner: Node = get_parent()
	if not is_instance_valid(owner) or not is_inside_tree() or is_queued_for_deletion():
		return false
	if owner.is_queued_for_deletion() or owner.scene_file_path != "res://scenes/buildings/conveyor_merger.tscn":
		return false
	var buffers: Array[InventoryComponent] = [input_a, input_b, input_c, output_inventory]
	var ports: Array[ItemPortComponent] = _ports()
	var seen: Dictionary = {}
	for i: int in range(4):
		var inventory: InventoryComponent = buffers[i]
		var port: ItemPortComponent = ports[i]
		if not is_instance_valid(inventory) or not is_instance_valid(port):
			return false
		if inventory.is_queued_for_deletion() or port.is_queued_for_deletion():
			return false
		if inventory.get_parent() != owner or port.get_parent() != owner or port.inventory != inventory:
			return false
		if seen.has(inventory) or seen.has(port):
			return false
		seen[inventory] = true
		seen[port] = true
		if inventory.max_capacity != (1 if i == 3 else 5):
			return false
		if port.direction != (ItemPortComponent.PortDirection.OUTPUT if i == 3 else ItemPortComponent.PortDirection.INPUT):
			return false
		if _provenance_bound:
			if _pinned_buffers[i].get_ref() != inventory or _pinned_ports[i].get_ref() != port:
				return false
	return true


func _provenance_ready() -> bool:
	if not enable_isolated_merger_provenance or not _provenance_bound or not _shape_valid():
		_ledgers.clear()
		return false
	return true


func accepts_provenance_epoch(epoch: int) -> bool:
	return _provenance_ready() and epoch == _provenance_epoch


# Reconcile a buffer's observation against the REAL inventory revision.
# Any external mutation discards proof for all remaining units in that
# buffer, and yields explicit unknown FIFO entries. No cargo is deleted.
func _ledger(inventory: InventoryComponent) -> Dictionary:
	var id: int = inventory.get_instance_id()
	var state: Dictionary = _ledgers.get(id, {})
	var revision: int = inventory.get_mutation_revision()
	if state.is_empty() or int(state["revision"]) != revision:
		var queues: Dictionary = {}
		for key: Variant in inventory.items.keys():
			var queue: Array[Dictionary] = []
			for i: int in range(inventory.get_amount(key as ItemDefinition)):
				queue.append({})
			queues[key] = queue
		state = {"revision": revision, "queues": queues}
		_ledgers[id] = state
	return state


func _peek(state: Dictionary, item: ItemDefinition) -> Dictionary:
	var queues: Dictionary = state["queues"]
	var queue: Array = queues.get(item, [])
	if queue.is_empty():
		return {}
	var proof: Dictionary = queue[0]
	return proof.duplicate()


func _append_observation(inventory: InventoryComponent, state: Dictionary, item: ItemDefinition, proof: Dictionary) -> void:
	if inventory.get_mutation_revision() != int(state["revision"]) + 1:
		_ledgers.erase(inventory.get_instance_id())
		return
	var queues: Dictionary = state["queues"]
	var queue: Array = queues.get(item, [])
	queue.append(proof.duplicate())
	queues[item] = queue
	state["revision"] = inventory.get_mutation_revision()


func _remove_observation(inventory: InventoryComponent, state: Dictionary, item: ItemDefinition) -> void:
	if inventory.get_mutation_revision() != int(state["revision"]) + 1:
		_ledgers.erase(inventory.get_instance_id())
		return
	var queues: Dictionary = state["queues"]
	var queue: Array = queues.get(item, [])
	if queue.is_empty():
		_ledgers.erase(inventory.get_instance_id())
		return
	queue.pop_front()
	queues[item] = queue
	state["revision"] = inventory.get_mutation_revision()


func _input_lane(port: ItemPortComponent) -> int:
	for i: int in range(3):
		if _pinned_ports[i].get_ref() == port:
			return i
	return -1


func snapshot_input_arrival(port: ItemPortComponent, transport: ConveyorTransportComponent) -> Dictionary:
	if not _provenance_ready() or _input_lane(port) < 0:
		return {}
	var proof: Dictionary = transport.physical_origin_snapshot()
	# A junction proof is not a fresh linear origin; unknown cargo stays movable.
	if not proof.is_empty():
		proof["input_port"] = weakref(port)
		proof["input_belt"] = weakref(transport.get_parent())
	return {"state": _ledger(port.inventory), "proof": proof}


func record_input_arrival(port: ItemPortComponent, item: ItemDefinition, snapshot: Dictionary) -> void:
	if snapshot.is_empty() or not _provenance_ready() or _input_lane(port) < 0:
		return
	_append_observation(port.inventory, snapshot["state"], item, snapshot["proof"])


func snapshot_output_departure(port: ItemPortComponent, item: ItemDefinition) -> Dictionary:
	if not _provenance_ready() or port != _pinned_ports[3].get_ref():
		return {}
	var state: Dictionary = _ledger(output_inventory)
	return {"state": state, "proof": _peek(state, item)}


func record_output_departure(port: ItemPortComponent, item: ItemDefinition, snapshot: Dictionary) -> void:
	if snapshot.is_empty() or not _provenance_ready() or port != _pinned_ports[3].get_ref():
		return
	_remove_observation(output_inventory, snapshot["state"], item)
