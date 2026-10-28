
extends Node


# =============================================================================
# CHAT 08.2D-2 — CORNER CARGO VISUAL REGRESSION
# =============================================================================

# Tests:
# - Empty corner visuals
# - Right corner first and second path sections
# - Blocked cargo at the corner output
# - Visual cleanup after successful transfer
# - Left corner path with a rotated parent
# - Generic item compatibility
# - Resource conservation


# =============================================================================
# CREATE REAL CONVEYOR
# =============================================================================

func _make_belt(
	parent: Node3D,
	scene: PackedScene,
	belt_position: Vector3,
	y_rotation: float
) -> ConveyorSegment:

	var belt := scene.instantiate() as ConveyorSegment
	assert(belt != null)

	parent.add_child(belt)

	belt.position = belt_position
	belt.rotation_degrees.y = y_rotation

	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	assert(timer != null)

	timer.set_process(false)
	timer.travel_interval = 1.0

	return belt


# =============================================================================
# GET TRANSPORT COMPONENT
# =============================================================================

func _transport(
	belt: ConveyorSegment
) -> ConveyorTransportComponent:

	var component := belt.get_node(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent

	assert(component != null)
	assert(component.cargo_inventory != null)

	return component


# =============================================================================
# CREATE TEST VISUAL
# =============================================================================


func _make_visual(
	belt: ConveyorSegment
) -> ConveyorCargoVisual:

	# =============================================================================
	# REUSE EXISTING VISUAL COMPONENT
	# =============================================================================

	var visual: ConveyorCargoVisual = (
		belt.get_node_or_null("CargoVisual")
		as ConveyorCargoVisual
	)

	if not is_instance_valid(visual):

		visual = ConveyorCargoVisual.new()
		visual.name = "CargoVisual"
		belt.add_child(visual)

	# Keep test movement deterministic.

	visual.set_process(false)

	return visual



# =============================================================================
# RUN CORNER VISUAL TEST
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 08.2D-2: CORNER VISUAL TEST =====")

	# =============================================================================
	# PREPARE ITEMS
	# =============================================================================

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot := load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var generic_item := ItemDefinition.new()
	generic_item.item_id = &"corner_visual_generic"
	generic_item.display_name = "Generic Factory Component"

	assert(ore != null)
	assert(ingot != null)

	var supply := InventoryComponent.new()
	supply.max_capacity = 10

	var destination := InventoryComponent.new()
	destination.max_capacity = 10

	assert(supply.add_item(ore, 1) == 1)
	assert(supply.add_item(ingot, 1) == 1)
	assert(supply.add_item(generic_item, 1) == 1)

	# =============================================================================
	# LOAD REAL CONVEYOR SCENE
	# =============================================================================

	var scene := load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(scene != null)

	# =============================================================================
	# CREATE RIGHT CORNER
	# =============================================================================

	var right_root := Node3D.new()
	add_child(right_root)

	var right_corner := _make_belt(
		right_root, scene, Vector3.ZERO, 0.0
	)

	var right_receiver := _make_belt(
		right_root, scene, Vector3(1, 0, 0), -90.0
	)

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			right_corner,
			right_receiver,
			ConveyorTurnIntent.Turn.RIGHT
		)
	)

	var right_transport := _transport(right_corner)
	var right_destination := _transport(right_receiver)

	var right_timer := right_corner.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	var right_visual := _make_visual(right_corner)

	# =============================================================================
	# TEST A — EMPTY CORNER
	# =============================================================================

	right_visual.refresh_visual()

	assert(not right_visual.visible)
	assert(right_visual.displayed_item == null)

	print("PASS A: Empty corner hides cargo")

	# =============================================================================
	# LOAD TWO ITEMS TO TEST BACKPRESSURE
	# =============================================================================

	assert(
		right_transport.try_receive_from_inventory(
			supply, ore
		)
	)

	assert(
		right_destination.try_receive_from_inventory(
			supply, ingot
		)
	)

	# =============================================================================
	# TEST B — RIGHT CORNER AT 25 PERCENT
	# =============================================================================

	assert(not right_timer.advance_transport(0.25))

	right_visual.refresh_visual()

	var right_first: Vector3 = (
		Vector3(0.0, 0.5, 0.25)
		+ Vector3.UP * right_visual.vertical_offset
	)

	assert(right_visual.visible)
	assert(right_visual.displayed_item == ore)
	assert(right_visual.position.is_equal_approx(right_first))

	print("PASS B: Right corner first path section correct")

	# =============================================================================
	# TEST C — RIGHT CORNER AT 75 PERCENT
	# =============================================================================

	assert(not right_timer.advance_transport(0.5))

	right_visual.refresh_visual()

	var right_second: Vector3 = (
		Vector3(0.25, 0.5, 0.0)
		+ Vector3.UP * right_visual.vertical_offset
	)

	assert(right_visual.position.is_equal_approx(right_second))

	print("PASS C: Right corner second path section correct")

	# =============================================================================
	# TEST D — BLOCKED AT RIGHT CORNER OUTPUT
	# =============================================================================

	assert(not right_timer.advance_transport(0.25))

	right_visual.refresh_visual()

	var right_output: Vector3 = (
		Vector3(0.5, 0.5, 0.0)
		+ Vector3.UP * right_visual.vertical_offset
	)

	assert(right_timer.transport_status == "Blocked")
	assert(right_visual.position.is_equal_approx(right_output))
	assert(right_transport.get_held_item() == ore)

	print("PASS D: Blocked cargo remains at right output")

	# =============================================================================
	# TEST E — OUTPUT BECOMES AVAILABLE
	# =============================================================================

	assert(
		right_destination.cargo_inventory.transfer_to(
			destination, ingot, 1
		) == 1
	)

	assert(right_timer.advance_transport(0.01))

	right_visual.refresh_visual()

	assert(not right_visual.visible)
	assert(right_transport.get_held_item() == null)
	assert(right_destination.get_held_item() == ore)

	print("PASS E: Successful handoff hides source visual")

	# =============================================================================
	# CREATE ROTATED LEFT CORNER
	# =============================================================================

	var left_root := Node3D.new()
	add_child(left_root)

	var left_corner := _make_belt(
		left_root, scene, Vector3(5, 0, 0), 0.0
	)

	var left_receiver := _make_belt(
		left_root, scene, Vector3(4, 0, 0), 90.0
	)

	left_root.rotation_degrees.y = 90.0

	assert(
		ConveyorCornerConversion.try_convert_and_connect(
			left_corner,
			left_receiver,
			ConveyorTurnIntent.Turn.LEFT
		)
	)

	var left_transport := _transport(left_corner)
	var left_destination := _transport(left_receiver)

	var left_timer := left_corner.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer

	var left_visual := _make_visual(left_corner)

	assert(
		left_transport.try_receive_from_inventory(
			supply, generic_item
		)
	)

	# =============================================================================
	# TEST F — LEFT CORNER AT 25 PERCENT
	# =============================================================================

	assert(not left_timer.advance_transport(0.25))

	left_visual.refresh_visual()

	var left_first: Vector3 = (
		Vector3(0.0, 0.5, 0.25)
		+ Vector3.UP * left_visual.vertical_offset
	)

	assert(left_visual.position.is_equal_approx(left_first))

	print("PASS F: Left corner first path section correct")

	# =============================================================================
	# TEST G — ROTATED LEFT CORNER AT 75 PERCENT
	# =============================================================================

	assert(not left_timer.advance_transport(0.5))

	left_visual.refresh_visual()

	var left_second: Vector3 = (
		Vector3(-0.25, 0.5, 0.0)
		+ Vector3.UP * left_visual.vertical_offset
	)

	assert(left_visual.position.is_equal_approx(left_second))

	assert(
		left_visual.global_position.is_equal_approx(
			left_corner.to_global(left_second)
		)
	)

	assert(left_visual.displayed_item == generic_item)

	print("PASS G: Rotated left corner displays generic item")

	# =============================================================================
	# TEST H — TRANSFER AND CONSERVATION
	# =============================================================================

	assert(left_timer.advance_transport(0.25))

	left_visual.refresh_visual()

	assert(not left_visual.visible)

	assert(
		left_destination.get_held_item() == generic_item
	)

	var all_belts: Array[ConveyorSegment] = [
		right_corner,
		right_receiver,
		left_corner,
		left_receiver
	]

	for item in [ore, ingot, generic_item]:

		var total: int = (
			supply.get_amount(item)
			+ destination.get_amount(item)
		)

		for belt in all_belts:
			total += _transport(belt).cargo_inventory.get_amount(
				item
			)

		assert(total == 1)

	print("PASS H: Generic transport and conservation verified")

	# =============================================================================
	# CLEANUP
	# =============================================================================

	right_root.queue_free()
	left_root.queue_free()

	supply.free()
	destination.free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 8 CORNER VISUAL TESTS PASSED")
	print("==========================================")
