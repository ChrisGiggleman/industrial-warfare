extends Node
class_name ConveyorSplitterComponent

# =============================================================================
# ONE INPUT TO THREE PHYSICAL OUTPUTS
# =============================================================================

# The input is one bounded InventoryComponent; each output uses a separate
# one-unit buffer. Items are distributed round-robin only to connected
# outputs with room. A full output is skipped, and when all three are
# unavailable the input retains its item. No inventory is modified unless
# InventoryComponent.transfer_to() succeeds.

@export var input_inventory: InventoryComponent
@export var output_a: InventoryComponent
@export var output_b: InventoryComponent
@export var output_c: InventoryComponent
@export var output_port_a: ItemPortComponent
@export var output_port_b: ItemPortComponent
@export var output_port_c: ItemPortComponent
@export_range(0.05, 10.0, 0.05) var split_interval: float = 0.25

var elapsed: float = 0.0
var next_lane: int = 0
var completed_splits: int = 0
var completed_to_a: int = 0
var completed_to_b: int = 0
var completed_to_c: int = 0

# E3d5c5k: independent opt-in, no changes to normal item distribution.
# Provenance is a per-item FIFO observation, not a second inventory.
@export var enable_isolated_splitter_provenance: bool = false
var _provenance_bound: bool = false
var _pinned_buffers: Array[WeakRef] = []
var _pinned_ports: Array[WeakRef] = []
var _ledgers: Dictionary = {}


func _process(delta: float) -> void:
	if split_interval <= 0.0:
		return
	elapsed += delta
	if elapsed < split_interval:
		return
	elapsed = minf(elapsed - split_interval, split_interval)
	advance_split()


func advance_split() -> bool:
	if not is_instance_valid(input_inventory):
		return false
	if input_inventory.get_total_amount() <= 0:
		return false

	var outputs: Array[InventoryComponent] = [output_a, output_b, output_c]
	var ports: Array[ItemPortComponent] = [
		output_port_a, output_port_b, output_port_c
	]

	for offset: int in range(outputs.size()):
		var lane: int = (next_lane + offset) % outputs.size()
		var inventory: InventoryComponent = outputs[lane]
		var port: ItemPortComponent = ports[lane]

		if not is_instance_valid(inventory) or not is_instance_valid(port):
			continue
		if not is_instance_valid(port.connected_conveyor):
			continue
		if port.connected_conveyor.input_building_port != port:
			continue
		if inventory.get_available_space() == 0:
			continue

		for key in input_inventory.items.keys():
			var item: ItemDefinition = key as ItemDefinition
			if item == null or not input_inventory.has_amount(item, 1):
				continue
			var source_state: Dictionary = {}
			var destination_state: Dictionary = {}
			var proof: Dictionary = {}
			if _provenance_ready():
				source_state = _ledger(input_inventory)
				destination_state = _ledger(inventory)
				proof = _peek(source_state, item)
			if input_inventory.transfer_to(inventory, item, 1) != 1:
				continue
			if not source_state.is_empty() and not destination_state.is_empty():
				_remove_observation(input_inventory, source_state, item)
				if not proof.is_empty():
					proof["splitter"] = weakref(self)
					proof["output_port"] = weakref(port)
				_append_observation(inventory, destination_state, item, proof)

			next_lane = (lane + 1) % outputs.size()
			completed_splits += 1
			match lane:
				0:
					completed_to_a += 1
				1:
					completed_to_b += 1
				2:
					completed_to_c += 1
			return true

	return false

# Observation is deliberately configured only on the real, empty splitter.
# Once attempted successfully, opting out never turns a tracked output
# into a new independent source stamp in the ordinary building helper.
func uses_splitter_provenance() -> bool:
	return enable_isolated_splitter_provenance or _provenance_bound


func configure_splitter_provenance() -> bool:
	if not enable_isolated_splitter_provenance or _provenance_bound or not _shape_valid():
		return false
	var buffers: Array[InventoryComponent] = [input_inventory, output_a, output_b, output_c]
	var ports: Array[ItemPortComponent] = [
		get_parent().get_node("InputPort") as ItemPortComponent,
		output_port_a, output_port_b, output_port_c
	]
	for inventory: InventoryComponent in buffers:
		if inventory.get_total_amount() != 0:
			return false
	for inventory: InventoryComponent in buffers:
		_pinned_buffers.append(weakref(inventory))
	for port: ItemPortComponent in ports:
		_pinned_ports.append(weakref(port))
	_provenance_bound = true
	return true


func _shape_valid() -> bool:
	var owner: Node = get_parent()
	if not is_instance_valid(owner) or not is_inside_tree() or is_queued_for_deletion():
		return false
	if owner.scene_file_path != "res://scenes/buildings/conveyor_splitter.tscn":
		return false
	var buffers: Array[InventoryComponent] = [input_inventory, output_a, output_b, output_c]
	var ports: Array[ItemPortComponent] = [
		owner.get_node_or_null("InputPort") as ItemPortComponent,
		output_port_a, output_port_b, output_port_c
	]
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
		if inventory.max_capacity != (5 if i == 0 else 1):
			return false
		if port.direction != (ItemPortComponent.PortDirection.INPUT if i == 0 else ItemPortComponent.PortDirection.OUTPUT):
			return false
		if _provenance_bound:
			if _pinned_buffers[i].get_ref() != inventory or _pinned_ports[i].get_ref() != port:
				return false
	return true


func _provenance_ready() -> bool:
	if not enable_isolated_splitter_provenance or not _provenance_bound or not _shape_valid():
		# Unknown mutations during a disabled period cannot inherit old proof.
		_ledgers.clear()
		return false
	return true


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


# Called only by the existing physical building-transfer helper, before
# and after successful conserved transfer. Unknown cargo is still movable.
func snapshot_input_arrival(port: ItemPortComponent, transport: ConveyorTransportComponent) -> Dictionary:
	if not _provenance_ready() or port != _pinned_ports[0].get_ref():
		return {}
	var proof: Dictionary = transport.physical_origin_snapshot()
	if not proof.is_empty():
		proof["input_port"] = weakref(port)
		proof["input_belt"] = weakref(transport.get_parent())
	return {"state": _ledger(input_inventory), "proof": proof}


func record_input_arrival(port: ItemPortComponent, item: ItemDefinition, snapshot: Dictionary) -> void:
	if snapshot.is_empty() or not _provenance_ready() or port != _pinned_ports[0].get_ref():
		return
	_append_observation(input_inventory, snapshot["state"], item, snapshot["proof"])


func snapshot_output_departure(port: ItemPortComponent, item: ItemDefinition) -> Dictionary:
	if not _provenance_ready():
		return {}
	if port != output_port_a and port != output_port_b and port != output_port_c:
		return {}
	var state: Dictionary = _ledger(port.inventory)
	return {"state": state, "proof": _peek(state, item)}


func record_output_departure(port: ItemPortComponent, item: ItemDefinition, snapshot: Dictionary) -> void:
	if snapshot.is_empty() or not _provenance_ready():
		return
	if port != output_port_a and port != output_port_b and port != output_port_c:
		return
	_remove_observation(port.inventory, snapshot["state"], item)
