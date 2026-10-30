extends Node


# =============================================================================
# BUILD MODE BRIDGE DISCOVERY REGRESSION
# =============================================================================

# Uses real conveyor scenes. Finds one exactly fitting segment
# without changing any already-placed conveyor or cargo.
#
# Gameplay placement/collision tests follow after this scene passes.


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


func _ready() -> void:

	print("\n===== CHAT 08.3F-6B: BRIDGE DISCOVERY TEST =====")

	var root := Node3D.new()
	add_child(root)

	var ghost := _make_belt(root)
	ghost.add_to_group("construction_preview")
	ghost.process_mode = Node.PROCESS_MODE_DISABLED

	# =============================================================================
	# A — NO REAL ENDPOINTS, NO BRIDGE
	# =============================================================================

	assert(
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1)
		).is_empty()
	)

	print("PASS A: Ghost alone cannot create a bridge")

	# =============================================================================
	# B — DISCOVER A REAL EXACT ONE-PIECE GAP
	# =============================================================================

	var source := _make_belt(root)
	var destination := _make_belt(root)

	source.global_position = Vector3.ZERO
	destination.global_position = Vector3(0, 0, -2)

	var ghost_before: Transform3D = ghost.global_transform
	var source_before: Transform3D = source.global_transform
	var dest_before: Transform3D = destination.global_transform

	var found: Dictionary = (
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1), 1.25
		)
	)

	assert(found.has("transform"))
	assert(found["source"] == source)
	assert(found["destination"] == destination)
	assert(
		found["transform"].origin.is_equal_approx(
			Vector3(0, 0, -1)
		)
	)

	print("PASS B: One-piece source to destination discovered")

	# =============================================================================
	# C — PREVIEW DOES NOT MODIFY ANY NODE
	# =============================================================================

	assert(ghost.global_transform.is_equal_approx(ghost_before))
	assert(source.global_transform.is_equal_approx(source_before))
	assert(destination.global_transform.is_equal_approx(dest_before))
	assert(source.next_segment == null)
	assert(destination.previous_segment == null)

	print("PASS C: Discovery does not mutate the factory")

	# =============================================================================
	# D — ALLOW NEARBY GRID CURSOR POSITION
	# =============================================================================

	found = ConveyorDualEndedBridge.find_nearest_preview(
		ghost, Vector3(0.5, 0, -1), 1.25
	)

	assert(found.has("transform"))
	assert(found["source"] == source)
	assert(found["destination"] == destination)

	print("PASS D: Candidate within snap search radius accepted")

	# =============================================================================
	# E — KEEP R ROTATION UNDER PLAYER CONTROL
	# =============================================================================

	ghost.rotation_degrees.y = 90.0

	assert(
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1), 1.25
		).is_empty()
	)

	ghost.global_transform = ghost_before

	print("PASS E: Wrong player rotation rejected")

	# =============================================================================
	# F — OCCUPIED SOURCE OUTPUT NOT ALLOWED
	# =============================================================================

	source.next_segment = destination

	assert(
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1)
		).is_empty()
	)

	source.next_segment = null

	print("PASS F: Occupied source output rejected")

	# =============================================================================
	# G — OCCUPIED DESTINATION INPUT NOT ALLOWED
	# =============================================================================

	destination.previous_segment = source

	assert(
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1)
		).is_empty()
	)

	destination.previous_segment = null

	print("PASS G: Occupied destination input rejected")

	# =============================================================================
	# H — MISALIGNED OR PARTIAL-CELL GAP NOT FORCE-FITTED
	# =============================================================================

	destination.global_position = Vector3(0.25, 0, -2)

	assert(
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1)
		).is_empty()
	)

	destination.global_position = Vector3(0, 0, -1.6)

	assert(
		ConveyorDualEndedBridge.find_nearest_preview(
			ghost, Vector3(0, 0, -1)
		).is_empty()
	)

	destination.global_transform = dest_before

	print("PASS H: Partial-length and lateral offsets rejected")

	# =============================================================================
	# I — DO NOT DISCOVER TEMPORARY GHOSTS AS REAL BELTS
	# =============================================================================

	var fake_belt := _make_belt(root)
	fake_belt.global_position = Vector3(0, 0, -1)
	fake_belt.add_to_group("construction_preview")

	found = ConveyorDualEndedBridge.find_nearest_preview(
		ghost, Vector3(0, 0, -1)
	)

	assert(found.has("transform"))
	assert(found["source"] == source)
	assert(found["destination"] == destination)

	print("PASS I: Extra construction ghosts ignored")

	# =============================================================================
	# J — FIND ROTATED BRIDGE IN A DIFFERENT FACTORY AREA
	# =============================================================================

	var rotated_source := _make_belt(root)
	var rotated_destination := _make_belt(root)

	var rotated_basis := Basis(Vector3.UP, PI / 2.0)

	rotated_source.global_transform = Transform3D(
		rotated_basis,
		Vector3(20, 0, 0)
	)

	rotated_destination.global_transform = Transform3D(
		rotated_basis,
		Vector3(18, 0, 0)
	)

	ghost.rotation_degrees.y = 90.0

	found = ConveyorDualEndedBridge.find_nearest_preview(
		ghost, Vector3(19, 0, 0), 1.25
	)

	assert(found.has("transform"))
	assert(found["source"] == rotated_source)
	assert(found["destination"] == rotated_destination)

	print("PASS J: Rotated bridge discovered successfully")

	root.queue_free()

	print("===============================================")
	print("ALL 10 BRIDGE DISCOVERY TESTS PASSED")
	print("===============================================")
