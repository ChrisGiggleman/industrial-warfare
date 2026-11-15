
extends Node
class_name ConveyorTransportComponent


# =============================================================================
# CONVEYOR CARGO INVENTORY
# =============================================================================

# Each conveyor segment has its own inventory.
#
# For the initial prototype, capacity must be exactly 1.
#
# The same component will eventually work with straight
# conveyors and both corner directions.

@export var cargo_inventory: InventoryComponent


# =============================================================================
# VALIDATE CARGO INVENTORY
# =============================================================================

# Reject missing inventories and incorrect capacities.
#
# This prevents an accidentally unlimited inventory
# from being used as a conveyor cargo slot.

func _has_valid_buffer() -> bool:

    if not is_instance_valid(cargo_inventory):
        return false

    return cargo_inventory.max_capacity == 1


# =============================================================================
# GET CURRENT CARGO ITEM
# =============================================================================

# Returns the ItemDefinition currently carried.
# Returns null when the belt is empty or misconfigured.
#
# This prototype supports one item unit per segment.

func get_held_item() -> ItemDefinition:

    if not _has_valid_buffer():
        return null

    if cargo_inventory.get_total_amount() != 1:
        return null

    for stored_key in cargo_inventory.items.keys():

        var stored_item: ItemDefinition = (
            stored_key as ItemDefinition
        )

        if stored_item == null:
            continue

        if cargo_inventory.get_amount(stored_item) == 1:
            return stored_item

    return null


# =============================================================================
# CHECK CARGO ACCEPTANCE
# =============================================================================

# A segment may receive an item only when:
# - The item definition is valid.
# - The cargo inventory is configured correctly.
# - The cargo slot is empty.
#
# Does not modify inventory quantities.

func can_receive_item(item: ItemDefinition) -> bool:

    if item == null:
        return false

    if not _has_valid_buffer():
        return false

    return cargo_inventory.get_total_amount() == 0


# =============================================================================
# RECEIVE ITEM FROM INVENTORY
# =============================================================================

# Transfers one item from a source inventory into
# this conveyor's cargo inventory.
#
# This is a low-level inventory operation.
# Physical connections and output-port permissions
# must be validated by a future transport controller.
#
# Existing InventoryComponent.transfer_to() protects
# against capacity overflow and lost resources.

func try_receive_from_inventory(
    source_inventory: InventoryComponent,
    item: ItemDefinition
) -> bool:

    if not is_instance_valid(source_inventory):
        return false

    if not can_receive_item(item):
        return false

    if source_inventory == cargo_inventory:
        return false

    if not source_inventory.has_amount(item, 1):
        return false

    var transferred: int = source_inventory.transfer_to(
        cargo_inventory,
        item,
        1
    )

    return transferred == 1


# =============================================================================
# TRANSFER ITEM TO ANOTHER CARGO BUFFER
# =============================================================================

# Moves one item into another conveyor transport buffer.
#
# Does not yet validate conveyor connection geometry,
# travel timing or transport direction.
#
# Those rules will be added before enabling automatic
# gameplay transfers.
#
# A full destination leaves the source unchanged.

func try_move_to_buffer(
    destination: ConveyorTransportComponent
) -> bool:

    if not is_instance_valid(destination):
        return false

    if destination == self:
        return false

    if not _has_valid_buffer():
        return false

    var item: ItemDefinition = get_held_item()

    if item == null:
        return false

    if not destination.can_receive_item(item):
        return false

    if cargo_inventory == destination.cargo_inventory:
        return false

    var transferred: int = cargo_inventory.transfer_to(
        destination.cargo_inventory,
        item,
        1
    )

    return transferred == 1

# E3d5c5h: ephemeral observation of the most recent successful physical
# building load. The inventory revision invalidates a stamp on any later
# add/remove via the public inventory API, even for the same item type.
# E3d5c5i: only the physical link helper can carry a valid stamp forward.
# Each stamp records an ordered segment history (bounded to 64 segments).
# Ordinary buffer transfers remain unstamped.
var _loaded_port_ref: WeakRef = null
var _loaded_stock_ref: WeakRef = null
var _loaded_cargo_ref: WeakRef = null
var _loaded_item: ItemDefinition = null
var _loaded_revision: int = -1
var _loaded_route: Array[WeakRef] = []


func record_physical_building_load(port: ItemPortComponent, item: ItemDefinition) -> void:
    if not is_instance_valid(port) or not is_instance_valid(port.inventory):
        return
    if not is_instance_valid(cargo_inventory) or get_held_item() != item:
        return
    _loaded_port_ref = weakref(port)
    _loaded_stock_ref = weakref(port.inventory)
    _loaded_cargo_ref = weakref(cargo_inventory)
    _loaded_item = item
    _loaded_revision = cargo_inventory.get_mutation_revision()
    _loaded_route.clear()
    var segment := get_parent() as ConveyorSegment
    if is_instance_valid(segment):
        _loaded_route.append(weakref(segment))


func has_physical_building_load(port: ItemPortComponent, item: ItemDefinition) -> bool:
    # Preserve E3d5c5h: a propagated stamp is not a direct building load.
    return (
        _loaded_route.size() == 1
        and _loaded_route[0].get_ref() == get_parent()
        and _matches_origin(port, item)
    )


func _matches_origin(port: ItemPortComponent, item: ItemDefinition) -> bool:
    return (
        is_instance_valid(port) and is_instance_valid(port.inventory)
        and is_instance_valid(cargo_inventory)
        and _loaded_port_ref != null and _loaded_stock_ref != null
        and _loaded_cargo_ref != null
        and _loaded_port_ref.get_ref() == port
        and _loaded_stock_ref.get_ref() == port.inventory
        and _loaded_cargo_ref.get_ref() == cargo_inventory
        and _loaded_item == item and get_held_item() == item
        and _loaded_revision == cargo_inventory.get_mutation_revision()
    )

# Snapshot BEFORE a successful physical forward move invalidates the old
# cargo revision. Returns no proof for an injected/replaced/unknown item.
func physical_origin_snapshot() -> Dictionary:
    if _loaded_port_ref == null or _loaded_stock_ref == null or _loaded_route.is_empty():
        return {}
    var port := _loaded_port_ref.get_ref() as ItemPortComponent
    if not _matches_origin(port, get_held_item()):
        return {}
    if _loaded_route[-1].get_ref() != get_parent():
        return {}
    for ref: WeakRef in _loaded_route:
        if not is_instance_valid(ref.get_ref()):
            return {}
    return {
        "port": _loaded_port_ref,
        "stock": _loaded_stock_ref,
        "item": _loaded_item,
        "route": _loaded_route.duplicate()
    }


# Called after the physical link helper has moved exactly one item.
# Never used by low-level buffer transfers or splitter/merger inventories.
func record_physical_forward_load(proof: Dictionary, source: ConveyorSegment) -> void:
    if proof.is_empty() or not is_instance_valid(source):
        return
    var destination := get_parent() as ConveyorSegment
    if not is_instance_valid(destination) or not is_instance_valid(cargo_inventory):
        return
    if source.next_segment != destination or destination.previous_segment != source:
        return
    var port_ref: WeakRef = proof.get("port") as WeakRef
    var stock_ref: WeakRef = proof.get("stock") as WeakRef
    var item := proof.get("item") as ItemDefinition
    var route: Array = proof.get("route", [])
    if port_ref == null or stock_ref == null or item == null or get_held_item() != item:
        return
    var origin := port_ref.get_ref() as ItemPortComponent
    if not is_instance_valid(origin) or not is_instance_valid(origin.inventory):
        return
    if stock_ref.get_ref() != origin.inventory:
        return
    if route.is_empty() or route.size() >= 64:
        return
    var last: WeakRef = route[-1] as WeakRef
    if last == null or last.get_ref() != source:
        return
    var next_route: Array[WeakRef] = []
    for value: Variant in route:
        var ref: WeakRef = value as WeakRef
        if ref == null or not is_instance_valid(ref.get_ref()) or ref.get_ref() == destination:
            return
        next_route.append(ref)
    next_route.append(weakref(destination))
    _loaded_port_ref = port_ref
    _loaded_stock_ref = stock_ref
    _loaded_item = item
    _loaded_cargo_ref = weakref(cargo_inventory)
    _loaded_revision = cargo_inventory.get_mutation_revision()
    _loaded_route = next_route


func has_verified_physical_route(
    port: ItemPortComponent,
    item: ItemDefinition,
    route: Array[ConveyorSegment]
) -> bool:
    if not _matches_origin(port, item) or route.size() != _loaded_route.size():
        return false
    if route.is_empty() or route[-1] != get_parent():
        return false
    for i: int in range(route.size()):
        if not is_instance_valid(route[i]) or _loaded_route[i].get_ref() != route[i]:
            return false
    return true

# E3d5c5k: separate proof type for ONE tracked splitter crossing.
# Not a linear-route stamp: old protected receivers must not accept it.
# E3d5c5l: separately propagate ordered downstream belt history.
var _splitter_proof: Dictionary = {}
var _splitter_cargo_ref: WeakRef = null
var _splitter_revision: int = -1


func record_splitter_building_load(proof: Dictionary, port: ItemPortComponent, item: ItemDefinition) -> void:
    _splitter_proof.clear()
    _splitter_cargo_ref = null
    _splitter_revision = -1
    if proof.is_empty() or not is_instance_valid(port) or get_held_item() != item:
        return
    var output_ref: WeakRef = proof.get("output_port") as WeakRef
    if output_ref == null or output_ref.get_ref() != port or proof.get("item") != item:
        return
    _splitter_proof = proof.duplicate()
    _splitter_proof["downstream"] = [weakref(get_parent())]
    _splitter_cargo_ref = weakref(cargo_inventory)
    _splitter_revision = cargo_inventory.get_mutation_revision()


func has_verified_splitter_load(
    origin: ItemPortComponent,
    item: ItemDefinition,
    splitter: ConveyorSplitterComponent,
    incoming: ConveyorSegment,
    output: ItemPortComponent
) -> bool:
    if _splitter_proof.is_empty() or _splitter_cargo_ref == null:
        return false
    if not is_instance_valid(origin) or not is_instance_valid(origin.inventory):
        return false
    if not is_instance_valid(splitter) or not is_instance_valid(incoming) or not is_instance_valid(output):
        return false
    if get_held_item() != item or _splitter_cargo_ref.get_ref() != cargo_inventory:
        return false
    if _splitter_revision != cargo_inventory.get_mutation_revision():
        return false
    var port_ref: WeakRef = _splitter_proof.get("port") as WeakRef
    var stock_ref: WeakRef = _splitter_proof.get("stock") as WeakRef
    var splitter_ref: WeakRef = _splitter_proof.get("splitter") as WeakRef
    var incoming_ref: WeakRef = _splitter_proof.get("input_belt") as WeakRef
    var output_ref: WeakRef = _splitter_proof.get("output_port") as WeakRef
    var input_ref: WeakRef = _splitter_proof.get("input_port") as WeakRef
    if port_ref == null or stock_ref == null or splitter_ref == null or incoming_ref == null or output_ref == null or input_ref == null:
        return false
    if not splitter.accepts_splitter_provenance_epoch(int(_splitter_proof.get("splitter_epoch", -1))):
        return false
    var input := input_ref.get_ref() as ItemPortComponent
    var belt := get_parent() as ConveyorSegment
    return (
        port_ref.get_ref() == origin and stock_ref.get_ref() == origin.inventory
        and splitter_ref.get_ref() == splitter and incoming_ref.get_ref() == incoming
        and output_ref.get_ref() == output and _splitter_proof.get("item") == item
        and is_instance_valid(input) and is_instance_valid(belt)
        and input.get_parent() == splitter.get_parent() and output.get_parent() == splitter.get_parent()
        and input.connected_conveyor == incoming and incoming.output_building_port == input
        and output.connected_conveyor == belt and belt.input_building_port == output
    )

# Separate snapshot; never convert a splitter observation into linear proof.
func splitter_forward_snapshot() -> Dictionary:
    if _splitter_proof.is_empty() or _splitter_cargo_ref == null:
        return {}
    if not is_instance_valid(cargo_inventory) or _splitter_cargo_ref.get_ref() != cargo_inventory:
        return {}
    if _splitter_revision != cargo_inventory.get_mutation_revision() or get_held_item() != _splitter_proof.get("item"):
        return {}
    var origin_ref := _splitter_proof.get("port") as WeakRef
    var stock_ref := _splitter_proof.get("stock") as WeakRef
    if origin_ref == null or stock_ref == null:
        return {}
    var origin := origin_ref.get_ref() as ItemPortComponent
    if not is_instance_valid(origin) or not is_instance_valid(origin.inventory) or stock_ref.get_ref() != origin.inventory:
        return {}
    var splitter_ref := _splitter_proof.get("splitter") as WeakRef
    if splitter_ref == null:
        return {}
    var splitter := splitter_ref.get_ref() as ConveyorSplitterComponent
    if not is_instance_valid(splitter) or not splitter.accepts_splitter_provenance_epoch(int(_splitter_proof.get("splitter_epoch", -1))):
        return {}
    var downstream: Array = _splitter_proof.get("downstream", [])
    if downstream.is_empty() or (downstream[-1] as WeakRef).get_ref() != get_parent():
        return {}
    for ref: WeakRef in downstream:
        if not is_instance_valid(ref.get_ref()):
            return {}
    return _splitter_proof.duplicate()


func record_splitter_forward_load(proof: Dictionary, source: ConveyorSegment) -> void:
    if proof.is_empty() or not is_instance_valid(source):
        return
    var destination := get_parent() as ConveyorSegment
    if not is_instance_valid(destination) or not is_instance_valid(cargo_inventory):
        return
    if source.next_segment != destination or destination.previous_segment != source:
        return
    if get_held_item() == null or get_held_item() != proof.get("item"):
        return
    var downstream: Array = proof.get("downstream", [])
    if downstream.is_empty() or downstream.size() >= 64:
        return
    if (downstream[-1] as WeakRef).get_ref() != source:
        return
    for ref: WeakRef in downstream:
        if not is_instance_valid(ref.get_ref()) or ref.get_ref() == destination:
            return
    var upstream: Array = proof.get("route", [])
    for ref: WeakRef in upstream:
        if not is_instance_valid(ref.get_ref()) or ref.get_ref() == destination:
            return
    _splitter_proof = proof.duplicate()
    var next_path: Array = downstream.duplicate()
    next_path.append(weakref(destination))
    _splitter_proof["downstream"] = next_path
    _splitter_cargo_ref = weakref(cargo_inventory)
    _splitter_revision = cargo_inventory.get_mutation_revision()


# Narrow first branch experiment: exactly one upstream belt, one splitter,
# and an exact ordered downstream chain. Geometry checked by the receiver.
func has_verified_splitter_branch(
    origin: ItemPortComponent, item: ItemDefinition,
    splitter: ConveyorSplitterComponent, incoming: ConveyorSegment,
    input: ItemPortComponent, output: ItemPortComponent,
    downstream: Array[ConveyorSegment]
) -> bool:
    var proof: Dictionary = splitter_forward_snapshot()
    if proof.is_empty() or downstream.is_empty() or proof.get("item") != item:
        return false
    var expected: Dictionary = {"port": origin, "splitter": splitter,
        "input_belt": incoming, "input_port": input, "output_port": output}
    for key: Variant in expected:
        var ref := proof.get(key) as WeakRef
        if ref == null or not is_instance_valid(expected[key]) or ref.get_ref() != expected[key]:
            return false
    var upstream: Array = proof.get("route", [])
    var visited: Array = proof.get("downstream", [])
    if upstream.size() != 1 or (upstream[0] as WeakRef).get_ref() != incoming:
        return false
    if visited.size() != downstream.size() or downstream[-1] != get_parent():
        return false
    for i: int in range(downstream.size()):
        if not is_instance_valid(downstream[i]) or (visited[i] as WeakRef).get_ref() != downstream[i]:
            return false
    return true

# E3d5c5m: separate observation for one merger crossing to the first
# outgoing belt and E3d5c5n downstream hops. Never linear or splitter admission.
var _merger_proof: Dictionary = {}
var _merger_cargo_ref: WeakRef = null
var _merger_revision: int = -1


func record_merger_building_load(proof: Dictionary, port: ItemPortComponent, item: ItemDefinition) -> void:
    _merger_proof.clear()
    _merger_cargo_ref = null
    _merger_revision = -1
    if proof.is_empty() or not is_instance_valid(port) or get_held_item() != item:
        return
    var output_ref := proof.get("output_port") as WeakRef
    if output_ref == null or output_ref.get_ref() != port or proof.get("item") != item:
        return
    _merger_proof = proof.duplicate()
    _merger_proof["downstream"] = [weakref(get_parent())]
    _merger_cargo_ref = weakref(cargo_inventory)
    _merger_revision = cargo_inventory.get_mutation_revision()


func has_verified_merger_load(
    origin: ItemPortComponent, item: ItemDefinition,
    merger: ConveyorMergerComponent, incoming: ConveyorSegment,
    input: ItemPortComponent, output: ItemPortComponent
) -> bool:
    if _merger_proof.is_empty() or _merger_cargo_ref == null or _merger_proof.has("splitter_crossing"):
        return false
    if not is_instance_valid(origin) or not is_instance_valid(origin.inventory):
        return false
    if not is_instance_valid(merger) or not merger.accepts_provenance_epoch(int(_merger_proof.get("epoch", -1))):
        return false
    if not is_instance_valid(cargo_inventory) or _merger_cargo_ref.get_ref() != cargo_inventory:
        return false
    if _merger_revision != cargo_inventory.get_mutation_revision() or get_held_item() != item or _merger_proof.get("item") != item:
        return false
    var expected: Dictionary = {"port": origin, "stock": origin.inventory,
        "merger": merger, "input_belt": incoming, "input_port": input, "output_port": output}
    for key: Variant in expected:
        var ref := _merger_proof.get(key) as WeakRef
        if ref == null or not is_instance_valid(expected[key]) or ref.get_ref() != expected[key]:
            return false
    var belt := get_parent() as ConveyorSegment
    if not is_instance_valid(belt):
        return false
    return (
        input.get_parent() == merger.get_parent() and output.get_parent() == merger.get_parent()
        and input.connected_conveyor == incoming and incoming.output_building_port == input
        and output.connected_conveyor == belt and belt.input_building_port == output
    )


# E3d5c5n: preserve a separate merger observation across actual physical hops.
func merger_forward_snapshot() -> Dictionary:
    if _merger_proof.is_empty() or _merger_cargo_ref == null or _merger_proof.has("splitter_crossing"):
        return {}
    if not is_instance_valid(cargo_inventory) or _merger_cargo_ref.get_ref() != cargo_inventory:
        return {}
    if _merger_revision != cargo_inventory.get_mutation_revision() or get_held_item() != _merger_proof.get("item"):
        return {}
    var merger_ref := _merger_proof.get("merger") as WeakRef
    var origin_ref := _merger_proof.get("port") as WeakRef
    var stock_ref := _merger_proof.get("stock") as WeakRef
    if merger_ref == null or origin_ref == null or stock_ref == null:
        return {}
    var merger := merger_ref.get_ref() as ConveyorMergerComponent
    var origin := origin_ref.get_ref() as ItemPortComponent
    if not is_instance_valid(merger) or not merger.accepts_provenance_epoch(int(_merger_proof.get("epoch", -1))):
        return {}
    if not is_instance_valid(origin) or not is_instance_valid(origin.inventory) or stock_ref.get_ref() != origin.inventory:
        return {}
    var downstream: Array = _merger_proof.get("downstream", [])
    if downstream.is_empty() or (downstream[-1] as WeakRef).get_ref() != get_parent():
        return {}
    for ref: WeakRef in downstream:
        if not is_instance_valid(ref.get_ref()):
            return {}
    return _merger_proof.duplicate()


func record_merger_forward_load(proof: Dictionary, source: ConveyorSegment) -> void:
    if proof.is_empty() or not is_instance_valid(source):
        return
    var destination := get_parent() as ConveyorSegment
    if not is_instance_valid(destination) or not is_instance_valid(cargo_inventory):
        return
    if source.next_segment != destination or destination.previous_segment != source:
        return
    if get_held_item() == null or get_held_item() != proof.get("item"):
        return
    var downstream: Array = proof.get("downstream", [])
    if downstream.is_empty() or downstream.size() >= 64 or (downstream[-1] as WeakRef).get_ref() != source:
        return
    for ref: WeakRef in downstream:
        if not is_instance_valid(ref.get_ref()) or ref.get_ref() == destination:
            return
    var upstream: Array = proof.get("route", [])
    for ref: WeakRef in upstream:
        if not is_instance_valid(ref.get_ref()) or ref.get_ref() == destination:
            return
    _merger_proof = proof.duplicate()
    var next_path: Array = downstream.duplicate()
    next_path.append(weakref(destination))
    _merger_proof["downstream"] = next_path
    _merger_cargo_ref = weakref(cargo_inventory)
    _merger_revision = cargo_inventory.get_mutation_revision()


func has_verified_merger_route(
    origin: ItemPortComponent, item: ItemDefinition,
    merger: ConveyorMergerComponent, incoming: ConveyorSegment,
    input: ItemPortComponent, output: ItemPortComponent,
    downstream: Array[ConveyorSegment]
) -> bool:
    var proof: Dictionary = merger_forward_snapshot()
    if proof.is_empty() or downstream.is_empty() or proof.get("item") != item:
        return false
    var expected: Dictionary = {"port": origin, "merger": merger,
        "input_belt": incoming, "input_port": input, "output_port": output}
    for key: Variant in expected:
        var ref := proof.get(key) as WeakRef
        if ref == null or not is_instance_valid(expected[key]) or ref.get_ref() != expected[key]:
            return false
    var upstream: Array = proof.get("route", [])
    var visited: Array = proof.get("downstream", [])
    if upstream.size() != 1 or (upstream[0] as WeakRef).get_ref() != incoming:
        return false
    if visited.size() != downstream.size() or downstream[-1] != get_parent():
        return false
    for i: int in range(downstream.size()):
        if not is_instance_valid(downstream[i]) or (visited[i] as WeakRef).get_ref() != downstream[i]:
            return false
    return true


# E3d5c5o: exactly one upstream belt, one splitter, one inter-junction belt.
# Build a nested history only from an actual verified splitter output.
func splitter_merger_arrival_snapshot() -> Dictionary:
    var proof: Dictionary = splitter_forward_snapshot()
    if proof.is_empty():
        return {}
    var upstream: Array = proof.get("route", [])
    var between: Array = proof.get("downstream", [])
    if upstream.size() != 1 or between.size() != 1:
        return {}
    var origin := _proof_node(proof, "port") as ItemPortComponent
    var splitter := _proof_node(proof, "splitter") as ConveyorSplitterComponent
    var incoming := _proof_node(proof, "input_belt") as ConveyorSegment
    var output := _proof_node(proof, "output_port") as ItemPortComponent
    if not has_verified_splitter_load(origin, get_held_item(), splitter, incoming, output):
        return {}
    if (upstream[0] as WeakRef).get_ref() != incoming or (between[0] as WeakRef).get_ref() == incoming:
        return {}
    var belt := get_parent() as ConveyorSegment
    if not is_instance_valid(belt) or belt.has_meta("conveyor_turn") or belt.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn":
        return {}
    if not LogisticsConnectionGeometry.are_endpoints_aligned(output, belt.get_node_or_null("InputEndpoint"), ConveyorSegment.CONNECTION_GAP):
        return {}
    return {"port": proof["port"], "stock": proof["stock"], "item": proof["item"],
        "splitter_crossing": proof.duplicate(true)}


func _proof_node(proof: Dictionary, key: String) -> Object:
    var ref := proof.get(key) as WeakRef
    return ref.get_ref() if ref != null else null


# Composite history is not eligible for direct, linear, splitter or
# single-merger admission. E3d5c5p permits bounded straight downstream hops.
func composite_forward_snapshot() -> Dictionary:
    if not _merger_proof.has("splitter_crossing") or _merger_cargo_ref == null:
        return {}
    if not is_instance_valid(cargo_inventory) or _merger_cargo_ref.get_ref() != cargo_inventory:
        return {}
    if _merger_revision != cargo_inventory.get_mutation_revision() or get_held_item() != _merger_proof.get("item"):
        return {}
    var merger := _proof_node(_merger_proof, "merger") as ConveyorMergerComponent
    if not is_instance_valid(merger) or not merger.accepts_composite_epoch(int(_merger_proof.get("epoch", -1))):
        return {}
    var first: Dictionary = _merger_proof["splitter_crossing"]
    var splitter := _proof_node(first, "splitter") as ConveyorSplitterComponent
    if not is_instance_valid(splitter) or not splitter.accepts_splitter_provenance_epoch(int(first.get("splitter_epoch", -1))):
        return {}
    var origin := _proof_node(_merger_proof, "port") as ItemPortComponent
    if not is_instance_valid(origin) or not is_instance_valid(origin.inventory) or _proof_node(_merger_proof, "stock") != origin.inventory:
        return {}
    if _proof_node(first, "port") != origin or _proof_node(first, "stock") != origin.inventory or first.get("item") != get_held_item():
        return {}
    var upstream: Array = first.get("route", [])
    var between: Array = first.get("downstream", [])
    var downstream: Array = _merger_proof.get("downstream", [])
    if upstream.size() != 1 or between.size() != 1 or downstream.is_empty() or downstream.size() > 64:
        return {}
    var entry := _proof_node(first, "input_belt") as ConveyorSegment
    var middle := _proof_node(_merger_proof, "input_belt") as ConveyorSegment
    var final_belt := get_parent() as ConveyorSegment
    if not is_instance_valid(entry) or not is_instance_valid(middle) or not is_instance_valid(final_belt):
        return {}
    if entry == middle or middle == final_belt or entry == final_belt:
        return {}
    if (upstream[0] as WeakRef).get_ref() != entry or (between[0] as WeakRef).get_ref() != middle or (downstream[-1] as WeakRef).get_ref() != final_belt:
        return {}
    var seen: Dictionary = {entry: true, middle: true}
    for value: Variant in downstream:
        var ref := value as WeakRef
        if ref == null:
            return {}
        var belt := ref.get_ref() as ConveyorSegment
        if not is_instance_valid(belt) or seen.has(belt) or belt.has_meta("conveyor_turn") or belt.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn":
            return {}
        seen[belt] = true
    var split_input := _proof_node(first, "input_port") as ItemPortComponent
    var split_output := _proof_node(first, "output_port") as ItemPortComponent
    var merge_input := _proof_node(_merger_proof, "input_port") as ItemPortComponent
    var merge_output := _proof_node(_merger_proof, "output_port") as ItemPortComponent
    if not is_instance_valid(split_input) or not is_instance_valid(split_output) or not is_instance_valid(merge_input) or not is_instance_valid(merge_output):
        return {}
    if split_input.get_parent() != splitter.get_parent() or split_output.get_parent() != splitter.get_parent():
        return {}
    if merge_input.get_parent() != merger.get_parent() or merge_output.get_parent() != merger.get_parent():
        return {}
    return _merger_proof.duplicate(true)


# Only called after reciprocal physical transfer, never a raw buffer move.
func record_composite_forward_load(proof: Dictionary, source: ConveyorSegment) -> void:
    if not proof.has("splitter_crossing") or not is_instance_valid(source):
        return
    var destination := get_parent() as ConveyorSegment
    if not is_instance_valid(destination) or not is_instance_valid(cargo_inventory):
        return
    if source.next_segment != destination or destination.previous_segment != source:
        return
    if destination.has_meta("conveyor_turn") or destination.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn":
        return
    if get_held_item() == null or get_held_item() != proof.get("item"):
        return
    var first: Dictionary = proof["splitter_crossing"]
    if _proof_node(first, "input_belt") == destination or _proof_node(proof, "input_belt") == destination:
        return
    var downstream: Array = proof.get("downstream", [])
    if downstream.is_empty() or downstream.size() >= 64 or (downstream[-1] as WeakRef).get_ref() != source:
        return
    for ref: WeakRef in downstream:
        if not is_instance_valid(ref.get_ref()) or ref.get_ref() == destination:
            return
    _merger_proof = proof.duplicate(true)
    var next_path: Array = downstream.duplicate()
    next_path.append(weakref(destination))
    _merger_proof["downstream"] = next_path
    _merger_cargo_ref = weakref(cargo_inventory)
    _merger_revision = cargo_inventory.get_mutation_revision()


func has_verified_composite_route(origin: ItemPortComponent, item: ItemDefinition,
    splitter: ConveyorSplitterComponent, entry: ConveyorSegment,
    split_input: ItemPortComponent, split_output: ItemPortComponent,
    middle: ConveyorSegment, merger: ConveyorMergerComponent,
    merge_input: ItemPortComponent, merge_output: ItemPortComponent,
    downstream: Array[ConveyorSegment]) -> bool:
    var proof: Dictionary = composite_forward_snapshot()
    if proof.is_empty() or proof.get("item") != item or downstream.is_empty():
        return false
    var first: Dictionary = proof["splitter_crossing"]
    var first_expected: Dictionary = {"port": origin, "splitter": splitter,
        "input_belt": entry, "input_port": split_input, "output_port": split_output}
    var second_expected: Dictionary = {"port": origin, "merger": merger,
        "input_belt": middle, "input_port": merge_input, "output_port": merge_output}
    for key: String in first_expected:
        if not is_instance_valid(first_expected[key]) or _proof_node(first, key) != first_expected[key]:
            return false
    for key: String in second_expected:
        if not is_instance_valid(second_expected[key]) or _proof_node(proof, key) != second_expected[key]:
            return false
    var visited: Array = proof.get("downstream", [])
    if visited.size() != downstream.size() or downstream[-1] != get_parent():
        return false
    for i: int in range(downstream.size()):
        if not is_instance_valid(downstream[i]) or (visited[i] as WeakRef).get_ref() != downstream[i]:
            return false
    return true
