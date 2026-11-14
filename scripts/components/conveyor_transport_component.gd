
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
# Downstream propagation and complete branch admission are future work.
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
