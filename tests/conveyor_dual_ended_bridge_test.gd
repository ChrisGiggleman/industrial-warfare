extends Node


# =============================================================================
# TWO-ENDED CONVEYOR BRIDGE REGRESSION
# =============================================================================

# Verifies read-only preview, both permanent links, safe rejection,
# rollback-friendly state, generic cargo and rotated factories.
#
# No change to the player's Build Mode in this checkpoint.


# =============================================================================
# CREATE A REAL CONVEYOR WITH TRANSPORT PAUSED
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:

	var scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	var belt: ConveyorSegment = (
		scene.instantiate() as ConveyorSegment
	)

	assert(belt != null)
	parent.add_child(belt)

	(
		belt.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	).set_process(false)

	return belt


# =============================================================================
# RUN REGRESSION CASES
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.3F-6A: DUAL-ENDED BRIDGE TEST =====")

	var root := Node3D.new()
	add_child(root)

	var source := _make_belt(root)
	var bridge := _make_belt(root)
	var destination := _make_belt(root)

	source.global_position = Vector3(0, 0, 0)
	destination.global_position = Vector3(0, 0, -2)

	# =============================================================================
	# A — EXACT BRIDGE PREVIEW DOES NOT MOVE ANY OBJECT
	# =============================================================================

	var original_source: Transform3D = source.global_transform
	var original_bridge: Transform3D = bridge.global_transform
	var original_target: Transform3D = destination.global_transform

	var preview: Dictionary = (
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		)
	)

	assert(preview.has("transform"))
	assert(preview["source"] == source)
	assert(preview["destination"] == destination)

	var desired: Transform3D = preview["transform"]

	assert(desired.origin.is_equal_approx(Vector3(0, 0, -1)))
	assert(source.global_transform.is_equal_approx(original_source))
	assert(bridge.global_transform.is_equal_approx(original_bridge))
	assert(destination.global_transform.is_equal_approx(original_target))

	print("PASS A: Two-ended preview aligns without mutation")

	# =============================================================================
	# B — CONNECT BOTH ENDS OF ONE NEW STRAIGHT
	# =============================================================================

	bridge.global_transform = desired

	var connected: bool = ConveyorDualEndedBridge.try_connect(
		source, bridge, destination
	)

	assert(connected)
	assert(source.next_segment == bridge)
	assert(bridge.previous_segment == source)
	assert(bridge.next_segment == destination)
	assert(destination.previous_segment == bridge)

	print("PASS B: Source, bridge and destination connected")

	# =============================================================================
	# C — ANY VALID ITEM TYPE AND AMOUNT ARE PRESERVED
	# =============================================================================

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition

	assert(ore != null)
	assert(ingot != null)

	var source_cargo := (
		source.get_node("CargoInventory") as InventoryComponent
	)

	var bridge_cargo := (
		bridge.get_node("CargoInventory") as InventoryComponent
	)

	var target_cargo := (
		destination.get_node("CargoInventory") as InventoryComponent
	)

	assert(source_cargo.add_item(ore, 1) == 1)
	assert(target_cargo.add_item(ingot, 1) == 1)

	assert(source_cargo.get_amount(ore) == 1)
	assert(bridge_cargo.get_total_amount() == 0)
	assert(target_cargo.get_amount(ingot) == 1)

	print("PASS C: Two different cargo items conserved")

	# =============================================================================
	# D — NO DUPLICATE CONNECTION COMMIT
	# =============================================================================

	assert(
		not ConveyorDualEndedBridge.try_connect(
			source, bridge, destination
		)
	)

	assert(source.next_segment == bridge)
	assert(destination.previous_segment == bridge)

	print("PASS D: Duplicate bridge commit rejected safely")

	# =============================================================================
	# E — CLEAN DISCONNECT RESTORES FREE ENDS
	# =============================================================================

	assert(bridge.disconnect_next())
	assert(source.disconnect_next())

	assert(source.next_segment == null)
	assert(bridge.previous_segment == null)
	assert(bridge.next_segment == null)
	assert(destination.previous_segment == null)

	assert(source_cargo.get_amount(ore) == 1)
	assert(target_cargo.get_amount(ingot) == 1)

	print("PASS E: Disconnect restores endpoints and items")

	# =============================================================================
	# F — BUSY OUTPUT OR INPUT PREVENTS A NEW BRIDGE
	# =============================================================================

	assert(source.try_connect_to(bridge))

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	assert(source.disconnect_next())

	# Simulate an already occupied destination input.
	# We leave the real source and bridge unconnected.

	destination.previous_segment = bridge

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	destination.previous_segment = null

	print("PASS F: Occupied source and destination rejected")

	# =============================================================================
	# G — BUILDING PORT CONNECTIONS OWN THEIR ENDPOINTS
	# =============================================================================

	var port := ItemPortComponent.new()

	source.output_building_port = port

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	source.output_building_port = null

	destination.input_building_port = port

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	destination.input_building_port = null
	port.free()

	print("PASS G: Occupied building-port endpoints protected")

	# =============================================================================
	# H — SHORT OR OFFSET GAPS CANNOT BE FORCED CLOSED
	# =============================================================================

	destination.global_position += Vector3(0.25, 0, 0)

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	destination.global_position = original_target.origin

	destination.global_position += Vector3(0, 0, 0.4)

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	destination.global_position = original_target.origin

	print("PASS H: Misaligned and partial-length gaps rejected")

	# =============================================================================
	# I — WRONG TARGET DIRECTION REJECTED
	# =============================================================================

	destination.rotation_degrees.y = 90.0

	assert(
		ConveyorDualEndedBridge.get_preview_transform(
			source, bridge, destination
		).is_empty()
	)

	destination.global_transform = original_target

	print("PASS I: Incorrect destination facing rejected")

	# =============================================================================
	# J — COMMIT REQUIRES THE EXACT PREVIEW TRANSFORM
	# =============================================================================

	bridge.global_position += Vector3(0.25, 0, 0)

	assert(
		not ConveyorDualEndedBridge.try_connect(
			source, bridge, destination
		)
	)

	assert(source.next_segment == null)
	assert(bridge.previous_segment == null)
	assert(bridge.next_segment == null)
	assert(destination.previous_segment == null)

	bridge.global_transform = desired

	print("PASS J: Failed commit leaves all connections unchanged")

	# =============================================================================
	# K — ROTATED FACTORY ROUTE ALSO SUPPORTS TWO ENDS
	# =============================================================================

	var turned_source := _make_belt(root)
	var turned_bridge := _make_belt(root)
	var turned_target := _make_belt(root)

	var turned_basis := Basis(Vector3.UP, PI / 2.0)

	turned_source.global_transform = Transform3D(
		turned_basis, Vector3(20, 0, 0)
	)

	turned_target.global_transform = Transform3D(
		turned_basis,
		turned_source.global_transform * Vector3(0, 0, -2)
	)

	var turned_preview: Dictionary = (
		ConveyorDualEndedBridge.get_preview_transform(
			turned_source, turned_bridge, turned_target
		)
	)

	assert(turned_preview.has("transform"))

	turned_bridge.global_transform = turned_preview["transform"]

	assert(
		ConveyorDualEndedBridge.try_connect(
			turned_source, turned_bridge, turned_target
		)
	)

	assert(turned_source.next_segment == turned_bridge)
	assert(turned_bridge.next_segment == turned_target)

	print("PASS K: Rotated conveyor network connected")

	# =============================================================================
	# FINAL CARGO CONSERVATION
	# =============================================================================

	assert(source_cargo.get_amount(ore) == 1)
	assert(bridge_cargo.get_total_amount() == 0)
	assert(target_cargo.get_amount(ingot) == 1)

	root.queue_free()

	print("===============================================")
	print("ALL 11 DUAL-ENDED CONVEYOR BRIDGE TESTS PASSED")
	print("===============================================")
