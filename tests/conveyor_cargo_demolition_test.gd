
extends Node


# =============================================================================
# CHAT 08.2C-2 — CONVEYOR CARGO DEMOLITION SAFETY TEST
# =============================================================================

# Validates that:
# - Empty belts permit demolition.
# - Occupied belts reject demolition.
# - Rejected demolition leaves cargo untouched.
# - Clearing cargo permits demolition.
# - Invalid cargo configurations fail safely.
# - Different item types receive equal protection.


func _ready() -> void:

	print("\n===== CHAT 08.2C-2: DEMOLITION SAFETY TEST =====")

	# =============================================================================
	# CREATE REAL CONVEYOR
	# =============================================================================

	var scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	var belt := scene.instantiate() as ConveyorSegment
	assert(belt != null)

	add_child(belt)

	var cargo := belt.get_node_or_null(
		"CargoInventory"
	) as InventoryComponent

	var transport := belt.get_node_or_null(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var timer := belt.get_node_or_null(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	assert(cargo != null)
	assert(transport != null)
	assert(timer != null)

	timer.set_process(false)

	# =============================================================================
	# PREPARE INVENTORY AND ITEMS
	# =============================================================================

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var future_item := ItemDefinition.new()
	future_item.item_id = &"demolition_test_item"
	future_item.display_name = "Future Item"

	assert(ore != null)

	var source := InventoryComponent.new()
	source.max_capacity = 10

	assert(source.add_item(ore, 1) == 1)
	assert(source.add_item(future_item, 1) == 1)

	# =============================================================================
	# TEST A — EMPTY CONVEYOR
	# =============================================================================

	assert(belt.can_demolish_safely())

	print("PASS A: Empty conveyor permits demolition")

	# =============================================================================
	# TEST B — OCCUPIED CONVEYOR
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(
			source, ore
		)
	)

	assert(not belt.can_demolish_safely())

	print("PASS B: Occupied conveyor blocks demolition")

	# =============================================================================
	# TEST C — CARGO REMAINS UNCHANGED
	# =============================================================================

	assert(cargo.get_amount(ore) == 1)
	assert(source.get_amount(ore) == 0)

	print("PASS C: Blocked demolition preserves cargo")

	# =============================================================================
	# TEST D — EMPTY AFTER UNLOADING
	# =============================================================================

	assert(cargo.transfer_to(source, ore, 1) == 1)

	assert(belt.can_demolish_safely())

	print("PASS D: Unloaded conveyor permits demolition")

	# =============================================================================
	# TEST E — INVALID CAPACITY
	# =============================================================================

	cargo.max_capacity = 0

	assert(not belt.can_demolish_safely())

	cargo.max_capacity = 1

	print("PASS E: Invalid cargo configuration rejected")

	# =============================================================================
	# TEST F — GENERIC ITEM PROTECTION
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(
			source, future_item
		)
	)

	assert(not belt.can_demolish_safely())

	assert(cargo.get_amount(future_item) == 1)

	print("PASS F: Generic items receive equal protection")

	# =============================================================================
	# FINAL RESOURCE CONSERVATION
	# =============================================================================

	assert(
		source.get_amount(ore)
		+ cargo.get_amount(ore)
		== 1
	)

	assert(
		source.get_amount(future_item)
		+ cargo.get_amount(future_item)
		== 1
	)

	print("PASS: All original resources conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	# Explicit test teardown intentionally bypasses
	# the player demolition tool.

	belt.queue_free()
	source.free()

	print("==========================================")
	print("ALL 6 DEMOLITION SAFETY TESTS PASSED")
	print("==========================================")
