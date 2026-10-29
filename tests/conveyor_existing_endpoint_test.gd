
extends Node


# =============================================================================
# CHAT 08.3G-3A — EXISTING ENDPOINT TEST
# =============================================================================

func _make_belt(parent: Node3D) -> ConveyorSegment:

	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)

	assert(belt != null)
	parent.add_child(belt)

	var timer := (
		belt.get_node("ConveyorTransportTimer")
		as ConveyorTransportTimer
	)

	timer.set_process(false)

	return belt


func _ready() -> void:

	print("\n===== CHAT 08.3G-3A: EXISTING ENDPOINT TEST =====")

	var root := Node3D.new()
	add_child(root)

	# =============================================================================
	# A — DIRECT EXISTING CONNECTION
	# =============================================================================

	var direct_source := _make_belt(root)
	var direct_target := _make_belt(root)

	direct_source.global_position = Vector3(-20, 0, 0)
	direct_target.global_position = Vector3(-20, 0, -1)

	var result := ConveyorExistingEndpointFinder.inspect_pair(
		direct_source, direct_target
	)

	assert(result.get("mode") == "direct")

	print("PASS A: Direct connection discovered")

	# =============================================================================
	# B — RIGHT CORNER
	# =============================================================================

	var right_source := _make_belt(root)
	var right_target := _make_belt(root)

	right_source.global_position = Vector3.ZERO

	right_target.global_transform = Transform3D(
		Basis(Vector3.UP, -PI / 2.0),
		Vector3(1, 0, 0)
	)

	result = ConveyorExistingEndpointFinder.inspect_pair(
		right_source, right_target
	)

	assert(result.get("mode") == "convert_source")
	assert(result["turn"] == ConveyorTurnIntent.Turn.RIGHT)

	print("PASS B: Right corner discovered")

	# =============================================================================
	# C — LEFT CORNER
	# =============================================================================

	var left_source := _make_belt(root)
	var left_target := _make_belt(root)

	left_source.global_position = Vector3(10, 0, 0)

	left_target.global_transform = Transform3D(
		Basis(Vector3.UP, PI / 2.0),
		Vector3(9, 0, 0)
	)

	result = ConveyorExistingEndpointFinder.inspect_pair(
		left_source, left_target
	)

	assert(result.get("mode") == "convert_source")
	assert(result["turn"] == ConveyorTurnIntent.Turn.LEFT)

	print("PASS C: Left corner discovered")

	# =============================================================================
	# D — DISCOVERY PRESERVES GEOMETRY AND CARGO
	# =============================================================================

	var original_transform := right_source.global_transform

	var source_output := (
		right_source.get_node("OutputEndpoint") as Marker3D
	)

	var original_output := source_output.transform

	var ore := load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var cargo := (
		right_source.get_node("CargoInventory")
		as InventoryComponent
	)

	assert(ore != null)
	assert(cargo.add_item(ore, 1) == 1)

	result = ConveyorExistingEndpointFinder.inspect_pair(
		right_source, right_target
	)

	assert(not result.is_empty())
	assert(right_source.global_transform == original_transform)
	assert(source_output.transform == original_output)
	assert(right_source.next_segment == null)
	assert(right_target.previous_segment == null)
	assert(cargo.get_amount(ore) == 1)

	print("PASS D: Discovery preserves geometry and cargo")

	# =============================================================================
	# E — OCCUPIED SOURCE OUTPUT REJECTED
	# =============================================================================

	assert(direct_source.try_connect_to(direct_target))

	assert(
		ConveyorExistingEndpointFinder.inspect_pair(
			direct_source, direct_target
		).is_empty()
	)

	assert(direct_source.disconnect_next())

	print("PASS E: Occupied source output rejected")

	# =============================================================================
	# F — OCCUPIED RECEIVER INPUT REJECTED
	# =============================================================================

	right_target.previous_segment = right_source

	assert(
		ConveyorExistingEndpointFinder.inspect_pair(
			right_source, right_target
		).is_empty()
	)

	right_target.previous_segment = null

	print("PASS F: Occupied receiver input rejected")

	# =============================================================================
	# G — BUILDING PORT CONNECTIONS PROTECTED
	# =============================================================================

	var dummy_port := ItemPortComponent.new()

	right_source.output_building_port = dummy_port

	assert(
		ConveyorExistingEndpointFinder.inspect_pair(
			right_source, right_target
		).is_empty()
	)

	right_source.output_building_port = null

	right_target.input_building_port = dummy_port

	assert(
		ConveyorExistingEndpointFinder.inspect_pair(
			right_source, right_target
		).is_empty()
	)

	right_target.input_building_port = null
	dummy_port.free()

	print("PASS G: Building port connections protected")

	# =============================================================================
	# H — INCORRECT SPACING AND ROTATION
	# =============================================================================

	var original_target := right_target.global_transform

	right_target.global_position += Vector3(0.25, 0, 0)

	assert(
		ConveyorExistingEndpointFinder.inspect_pair(
			right_source, right_target
		).is_empty()
	)

	right_target.global_transform = Transform3D(
		Basis.IDENTITY,
		original_target.origin
	)

	assert(
		ConveyorExistingEndpointFinder.inspect_pair(
			right_source, right_target
		).is_empty()
	)

	right_target.global_transform = original_target

	print("PASS H: Invalid spacing and rotation rejected")

	# =============================================================================
	# I — ROTATED FACTORY CONNECTION
	# =============================================================================

	var rotated_source := _make_belt(root)
	var rotated_target := _make_belt(root)

	var rotated_basis := Basis(Vector3.UP, PI / 2.0)

	rotated_source.global_transform = Transform3D(
		rotated_basis,
		Vector3(20, 0, 0)
	)

	rotated_target.global_transform = Transform3D(
		rotated_basis * Basis(Vector3.UP, -PI / 2.0),
		rotated_source.global_transform * Vector3(1, 0, 0)
	)

	result = ConveyorExistingEndpointFinder.inspect_pair(
		rotated_source, rotated_target
	)

	assert(result.get("mode") == "convert_source")
	assert(result["turn"] == ConveyorTurnIntent.Turn.RIGHT)

	print("PASS I: Rotated factory corner discovered")

	# =============================================================================
	# J — NEAREST CONNECTION AND GHOST FILTERING
	# =============================================================================

	var ghost := _make_belt(root)
	ghost.add_to_group("construction_preview")
	ghost.global_position = Vector3(0, 0, 0)

	result = ConveyorExistingEndpointFinder.find_nearest_candidate(
		get_tree(),
		Vector3(0.5, 0, 0),
		0.75
	)

	assert(not result.is_empty())
	assert(result["source"] == right_source)
	assert(result["receiver"] == right_target)
	assert(result["mode"] == "convert_source")

	print("PASS J: Nearest real endpoints discovered")

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	assert(cargo.get_amount(ore) == 1)

	root.queue_free()

	print("==============================================")
	print("ALL 10 EXISTING ENDPOINT TESTS PASSED")
	print("==============================================")
