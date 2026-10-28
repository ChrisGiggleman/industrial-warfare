
extends Node


# =============================================================================
# CHAT 08.2D-1 — CONVEYOR CARGO VISUAL TEST
# =============================================================================

# Tests generic cargo placeholder rendering against
# a real straight conveyor scene.
#
# No existing conveyor scenes are modified.


func _ready() -> void:

	print("\n===== CHAT 08.2D-1: CARGO VISUAL TEST =====")

	# =============================================================================
	# LOAD TEST RESOURCE
	# =============================================================================

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	assert(ore != null)

	var generic_item := ItemDefinition.new()
	generic_item.item_id = &"visual_generic_item"
	generic_item.display_name = "Generic Factory Item"

	# =============================================================================
	# CREATE REAL CONVEYOR
	# =============================================================================

	var scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	var root := Node3D.new()
	add_child(root)

	var belt := scene.instantiate() as ConveyorSegment
	assert(belt != null)

	root.add_child(belt)

	var transport := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	assert(transport != null)
	assert(timer != null)

	timer.set_process(false)
	timer.travel_interval = 1.0

	# =============================================================================
	# ADD VISUAL COMPONENT FOR TESTING
	# =============================================================================

	
	# =============================================================================
	# REUSE EXISTING CONVEYOR CARGO VISUAL
	# =============================================================================

	var visual: ConveyorCargoVisual = (
		belt.get_node_or_null("CargoVisual")
		as ConveyorCargoVisual
	)

	# Create a temporary visual only if the
	# conveyor scene does not already contain one.

	if not is_instance_valid(visual):

		visual = ConveyorCargoVisual.new()
		visual.name = "CargoVisual"
		belt.add_child(visual)

	# Disable automatic updates for isolated tests.

	visual.set_process(false)


	var source := InventoryComponent.new()
	source.max_capacity = 10

	var destination := InventoryComponent.new()
	destination.max_capacity = 10

	assert(source.add_item(ore, 1) == 1)
	assert(source.add_item(generic_item, 1) == 1)

	# =============================================================================
	# TEST A — EMPTY BELT
	# =============================================================================

	visual.refresh_visual()

	assert(not visual.visible)
	assert(visual.displayed_item == null)

	print("PASS A: Empty belt hides cargo")

	# =============================================================================
	# TEST B — LOAD ITEM AND SHOW PLACEHOLDER
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(
			source, ore
		)
	)

	visual.refresh_visual()

	assert(visual.visible)
	assert(visual.displayed_item == ore)
	assert(visual.mesh is BoxMesh)

	print("PASS B: Loaded item displays placeholder")

	# =============================================================================
	# TEST C — HALF-WAY POSITION
	# =============================================================================

	assert(not timer.advance_transport(0.5))

	visual.refresh_visual()

	var input_marker := belt.get_node(
		"InputEndpoint"
	) as Marker3D

	var output_marker := belt.get_node(
		"OutputEndpoint"
	) as Marker3D

	var expected_middle: Vector3 = (
		input_marker.position.lerp(
			output_marker.position,
			0.5
		)
		+ Vector3.UP * visual.vertical_offset
	)

	assert(
		visual.position.is_equal_approx(
			expected_middle
		)
	)

	print("PASS C: Cargo reaches middle of straight belt")

	# =============================================================================
	# TEST D — BLOCKED AT OUTPUT
	# =============================================================================

	# No connected receiving belt exists.
	# Item reaches the end but cannot disappear.

	assert(not timer.advance_transport(0.5))

	visual.refresh_visual()

	assert(timer.transport_status == "Blocked")
	assert(visual.visible)

	var expected_output: Vector3 = (
		output_marker.position
		+ Vector3.UP * visual.vertical_offset
	)

	assert(
		visual.position.is_equal_approx(
			expected_output
		)
	)

	assert(transport.get_held_item() == ore)

	print("PASS D: Blocked cargo stays at output")

	# =============================================================================
	# TEST E — UNLOADED BELT
	# =============================================================================

	assert(
		transport.cargo_inventory.transfer_to(
			destination, ore, 1
		) == 1
	)

	visual.refresh_visual()

	assert(not visual.visible)
	assert(visual.displayed_item == null)

	# Reset timer after detecting the empty belt.

	assert(not timer.advance_transport(0.01))

	print("PASS E: Unloaded cargo becomes invisible")

	# =============================================================================
	# TEST F — NEW ITEM TYPE
	# =============================================================================

	assert(
		transport.try_receive_from_inventory(
			source, generic_item
		)
	)

	visual.refresh_visual()

	assert(visual.visible)
	assert(visual.displayed_item == generic_item)

	assert(
		transport.cargo_inventory.get_amount(
			generic_item
		) == 1
	)

	print("PASS F: Generic item displays correctly")

	# =============================================================================
	# FINAL RESOURCE CONSERVATION
	# =============================================================================

	for item in [ore, generic_item]:

		var total: int = (
			source.get_amount(item)
			+ destination.get_amount(item)
			+ transport.cargo_inventory.get_amount(item)
		)

		assert(total == 1)

	print("PASS: Visual updates preserve all resources")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	root.queue_free()

	source.free()
	destination.free()

	print("==========================================")
	print("ALL 6 CARGO VISUAL TESTS PASSED")
	print("==========================================")
