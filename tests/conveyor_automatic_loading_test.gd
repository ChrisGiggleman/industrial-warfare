
extends Node


# =============================================================================
# AUTOMATIC BUILDING LOADING TEST
# =============================================================================

# Verifies:
# - Disconnected belts cannot load
# - Alignment alone is insufficient
# - Connected building outputs load automatically
# - New items begin with zero travel progress
# - Timed transport still works
# - Downstream congestion blocks movement
# - Movement resumes after congestion clears
# - Generic items load correctly
# - Disconnection prevents further loading
# - Godot frame processing performs loading
# - Inventory quantities remain conserved


func _ready() -> void:

	print("\n===== CHAT 08.3E-3B: AUTO LOADING TEST =====")

	# =============================================================================
	# LOAD SCENES AND ITEMS
	# =============================================================================

	var extractor_scene := load(
		"res://scenes/buildings/test_extractor.tscn"
	) as PackedScene

	var belt_scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var generic_item := ItemDefinition.new()
	generic_item.item_id = &"automatic_loading_generic"
	generic_item.display_name = "Future Factory Product"

	assert(extractor_scene != null)
	assert(belt_scene != null)
	assert(ore != null)

	# =============================================================================
	# CREATE ISOLATED EXTRACTOR AND TWO CONVEYORS
	# =============================================================================

	var root := Node3D.new()
	add_child(root)

	var extractor := extractor_scene.instantiate() as Node3D
	var belt_a := belt_scene.instantiate() as ConveyorSegment
	var belt_b := belt_scene.instantiate() as ConveyorSegment

	assert(extractor != null)
	assert(belt_a != null)
	assert(belt_b != null)

	root.add_child(extractor)
	root.add_child(belt_a)
	root.add_child(belt_b)

	# =============================================================================
	# DISABLE UNRELATED AUTOMATIC PROCESSING
	# =============================================================================

	(
		extractor.get_node("ExtractorComponent")
		as ExtractorComponent
	).set_process(false)

	(
		extractor.get_node("LogisticsTransferComponent")
		as LogisticsTransferComponent
	).set_process(false)

	var timer_a := belt_a.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	var timer_b := belt_b.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	timer_a.set_process(false)
	timer_b.set_process(false)

	timer_a.travel_interval = 1.0
	timer_b.travel_interval = 1.0

	# =============================================================================
	# GET INVENTORY AND PORT REFERENCES
	# =============================================================================

	var extractor_port := extractor.get_node(
		"OutputPort"
	) as ItemPortComponent

	var extractor_inventory := extractor.get_node(
		"InventoryComponent"
	) as InventoryComponent

	var transport_a := belt_a.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var transport_b := belt_b.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	assert(extractor_port != null)
	assert(extractor_inventory != null)
	assert(transport_a != null)
	assert(transport_b != null)

	var delivered := InventoryComponent.new()
	delivered.max_capacity = 10

	assert(extractor_inventory.add_item(ore, 2) == 2)

	# =============================================================================
	# TEST A — DISCONNECTED BELT
	# =============================================================================

	# Call the normal frame-update method manually.
	# This allows deterministic testing without
	# waiting for real elapsed time.

	timer_a._process(0.25)

	assert(transport_a.get_held_item() == null)
	assert(extractor_inventory.get_amount(ore) == 2)

	print("PASS A: Disconnected belt cannot auto-load")

	# =============================================================================
	# TEST B — GEOMETRY ALONE
	# =============================================================================

	var preview := ConveyorBuildingSnap.get_preview_transform(
		extractor_port,
		belt_a
	)

	assert(preview.has("transform"))

	belt_a.global_transform = preview["transform"]

	timer_a._process(0.25)

	assert(transport_a.get_held_item() == null)
	assert(extractor_inventory.get_amount(ore) == 2)

	print("PASS B: Alignment alone cannot auto-load")

	# =============================================================================
	# TEST C — AUTOMATIC LOADING
	# =============================================================================

	assert(belt_a.try_connect_building_port(extractor_port))

	timer_a._process(0.25)

	assert(transport_a.get_held_item() == ore)
	assert(extractor_inventory.get_amount(ore) == 1)

	print("PASS C: Connected Extractor loads ore automatically")

	# =============================================================================
	# TEST D — RESET TRAVEL PROGRESS
	# =============================================================================

	assert(timer_a.elapsed_seconds == 0.0)
	assert(timer_a.transport_status == "Loaded")

	timer_a._process(0.4)

	assert(is_equal_approx(timer_a.elapsed_seconds, 0.4))
	assert(transport_a.get_held_item() == ore)

	print("PASS D: Newly loaded item starts its own timer")

	# =============================================================================
	# TEST E — BLOCKED WITHOUT DOWNSTREAM BELT
	# =============================================================================

	timer_a._process(0.6)

	assert(timer_a.transport_status == "Blocked")
	assert(transport_a.get_held_item() == ore)
	assert(is_equal_approx(timer_a.elapsed_seconds, 1.0))

	print("PASS E: No downstream connection preserves cargo")

	# =============================================================================
	# TEST F — CONNECT AND TRANSFER FORWARD
	# =============================================================================

	# Position Belt B one grid unit after Belt A.

	belt_b.global_transform = Transform3D(
		belt_a.global_transform.basis,
		belt_a.global_position
		+ belt_a.global_transform.basis * Vector3.FORWARD
	)

	assert(belt_a.try_connect_to(belt_b))

	# Belt A has already completed its travel interval.

	timer_a._process(0.01)

	assert(transport_a.get_held_item() == null)
	assert(transport_b.get_held_item() == ore)

	print("PASS F: Cargo advances after connection is available")

	# =============================================================================
	# TEST G — DOWNSTREAM BACKPRESSURE
	# =============================================================================

	# Belt A is empty and reloads the next ore.
	# Belt B still contains the first ore.

	timer_a._process(0.01)

	assert(transport_a.get_held_item() == ore)
	assert(extractor_inventory.get_amount(ore) == 0)

	timer_a._process(1.0)

	assert(timer_a.transport_status == "Blocked")
	assert(transport_a.get_held_item() == ore)
	assert(transport_b.get_held_item() == ore)

	print("PASS G: Full downstream belt creates backpressure")

	# =============================================================================
	# TEST H — RECOVERY AND GENERIC ITEM LOADING
	# =============================================================================

	assert(
		transport_b.cargo_inventory.transfer_to(
			delivered, ore, 1
		) == 1
	)

	# The second ore can now move into Belt B.

	timer_a._process(0.01)

	assert(transport_a.get_held_item() == null)
	assert(transport_b.get_held_item() == ore)

	# Add a completely new resource type.

	assert(
		extractor_inventory.add_item(generic_item, 1) == 1
	)

	timer_a._process(0.01)

	assert(transport_a.get_held_item() == generic_item)
	assert(extractor_inventory.get_amount(generic_item) == 0)
	assert(timer_a.elapsed_seconds == 0.0)

	print("PASS H: Recovery and generic item auto-loading work")

	# =============================================================================
	# TEST I — DISCONNECTION PREVENTS LOADING
	# =============================================================================

	# Clear the generic item from the conveyor.

	assert(
		transport_a.cargo_inventory.transfer_to(
			delivered, generic_item, 1
		) == 1
	)

	assert(
		belt_a.disconnect_building_port(extractor_port)
	)

	# Add another ore to verify that disconnection
	# prevents additional automatic loading.

	assert(extractor_inventory.add_item(ore, 1) == 1)

	timer_a._process(0.1)

	assert(transport_a.get_held_item() == null)
	assert(extractor_inventory.get_amount(ore) == 1)

	print("PASS I: Disconnection prevents automatic loading")

	# =============================================================================
	# TEST J — REAL GODOT FRAME PROCESSING
	# =============================================================================

	# Restore the connection and enable automatic
	# frame-driven updates rather than manual calls.

	assert(belt_a.try_connect_building_port(extractor_port))

	timer_a.set_process(true)

	var loaded_automatically: bool = false

	for frame_index in range(60):

		await get_tree().process_frame

		if transport_a.get_held_item() == ore:
			loaded_automatically = true
			break

	timer_a.set_process(false)

	assert(loaded_automatically)
	assert(extractor_inventory.get_amount(ore) == 0)

	print("PASS J: Godot frame updates load cargo automatically")

	# =============================================================================
	# FINAL RESOURCE CONSERVATION
	# =============================================================================

	# Total ore created: 3
	# Total generic items created: 1

	var all_inventories: Array[InventoryComponent] = [
		extractor_inventory,
		transport_a.cargo_inventory,
		transport_b.cargo_inventory,
		delivered
	]

	var ore_total: int = 0
	var generic_total: int = 0

	for inventory in all_inventories:

		ore_total += inventory.get_amount(ore)

		generic_total += inventory.get_amount(
			generic_item
		)

	assert(ore_total == 3)
	assert(generic_total == 1)

	print("PASS: All resource quantities conserved")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()
	delivered.free()

	print("==========================================")
	print("ALL 10 AUTOMATIC LOADING TESTS PASSED")
	print("==========================================")
