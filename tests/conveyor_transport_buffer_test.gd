
extends Node


# =============================================================================
# CONVEYOR CARGO BUFFER TEST
# =============================================================================

# Tests:
# - Empty cargo state
# - Invalid item rejection
# - Loading an item
# - Single-slot capacity
# - Belt-to-belt handoff
# - Backpressure
# - Resource conservation


func _ready() -> void:

    print("\n===== CHAT 08.2A: CARGO BUFFER TEST =====")

    # =============================================================================
    # LOAD TEST ITEM DEFINITIONS
    # =============================================================================

    var ore: ItemDefinition = load(
        "res://data/items/test_ore.tres"
    ) as ItemDefinition

    var ingot: ItemDefinition = load(
        "res://data/items/test_ingot.tres"
    ) as ItemDefinition

    assert(ore != null)
    assert(ingot != null)

    # =============================================================================
    # CREATE ISOLATED INVENTORIES
    # =============================================================================

    var source := InventoryComponent.new()
    source.max_capacity = 10

    var inventory_a := InventoryComponent.new()
    inventory_a.max_capacity = 1

    var inventory_b := InventoryComponent.new()
    inventory_b.max_capacity = 1

    assert(source.add_item(ore, 3) == 3)
    assert(source.add_item(ingot, 2) == 2)

    # =============================================================================
    # CREATE CONVEYOR TRANSPORT COMPONENTS
    # =============================================================================

    var belt_a := ConveyorTransportComponent.new()
    belt_a.cargo_inventory = inventory_a

    var belt_b := ConveyorTransportComponent.new()
    belt_b.cargo_inventory = inventory_b

    # =============================================================================
    # TEST A — EMPTY BUFFER
    # =============================================================================

    assert(belt_a.get_held_item() == null)
    assert(belt_a.can_receive_item(ore))

    print("PASS A: Empty buffer accepts valid items")

    # =============================================================================
    # TEST B — INVALID REQUESTS
    # =============================================================================

    assert(not belt_a.can_receive_item(null))

    assert(
        not belt_a.try_receive_from_inventory(
            source, null
        )
    )

    assert(not belt_a.try_move_to_buffer(belt_b))

    print("PASS B: Invalid requests rejected")

    # =============================================================================
    # TEST C — LOAD ONE RESOURCE
    # =============================================================================

    assert(belt_a.try_receive_from_inventory(source, ore))

    assert(source.get_amount(ore) == 2)
    assert(inventory_a.get_amount(ore) == 1)
    assert(belt_a.get_held_item() == ore)

    print("PASS C: One ore loaded into Belt A")

    # =============================================================================
    # TEST D — CAPACITY ENFORCEMENT
    # =============================================================================

    assert(
        not belt_a.try_receive_from_inventory(
            source, ingot
        )
    )

    assert(inventory_a.get_total_amount() == 1)
    assert(source.get_amount(ingot) == 2)

    print("PASS D: Occupied buffer rejects new items")

    # =============================================================================
    # TEST E — BELT-TO-BELT TRANSFER
    # =============================================================================

    assert(belt_a.try_move_to_buffer(belt_b))

    assert(belt_a.get_held_item() == null)
    assert(belt_b.get_held_item() == ore)

    assert(inventory_a.get_amount(ore) == 0)
    assert(inventory_b.get_amount(ore) == 1)

    print("PASS E: Ore transferred from Belt A to B")

    # =============================================================================
    # TEST F — BACKPRESSURE
    # =============================================================================

    # Reload Belt A while Belt B is occupied.

    assert(belt_a.try_receive_from_inventory(source, ore))

    assert(not belt_a.try_move_to_buffer(belt_b))
    assert(not belt_a.try_move_to_buffer(belt_a))

    assert(source.get_amount(ore) == 1)
    assert(inventory_a.get_amount(ore) == 1)
    assert(inventory_b.get_amount(ore) == 1)

    print("PASS F: Blocked transfer preserves cargo")

    # =============================================================================
    # TEST G — INVALID DESTINATION CAPACITY
    # =============================================================================

    var invalid_inventory := InventoryComponent.new()

    # Zero means unlimited in InventoryComponent.
    # A conveyor buffer must reject this configuration.

    invalid_inventory.max_capacity = 0

    var invalid_belt := ConveyorTransportComponent.new()
    invalid_belt.cargo_inventory = invalid_inventory

    assert(not invalid_belt.can_receive_item(ore))
    assert(not belt_a.try_move_to_buffer(invalid_belt))

    print("PASS G: Invalid cargo capacity rejected")

    # =============================================================================
    # FINAL RESOURCE CONSERVATION
    # =============================================================================

    var total_ore: int = (
        source.get_amount(ore)
        + inventory_a.get_amount(ore)
        + inventory_b.get_amount(ore)
        + invalid_inventory.get_amount(ore)
    )

    assert(total_ore == 3)
    assert(source.get_amount(ingot) == 2)

    print("PASS: All five original item units conserved")

    # =============================================================================
    # CLEAN UP
    # =============================================================================

    belt_a.free()
    belt_b.free()
    invalid_belt.free()

    source.free()
    inventory_a.free()
    inventory_b.free()
    invalid_inventory.free()

    # =============================================================================
    # TEST RESULTS
    # =============================================================================

    print("==========================================")
    print("ALL 7 CONVEYOR BUFFER TESTS PASSED")
    print("==========================================")
