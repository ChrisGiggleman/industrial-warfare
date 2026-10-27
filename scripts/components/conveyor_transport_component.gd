
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
