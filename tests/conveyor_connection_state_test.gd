
extends Node


# =============================================================================
# CONVEYOR CONNECTION STATE TEST
# =============================================================================

# Tests the actual ConveyorStraight scene:
# - Establish connections
# - Prevent duplicate or occupied connections
# - Reject invalid geometry
# - Disconnect safely
# - Preserve alignment through rotation
# - Clean up links on removal
#
# No inventory or gameplay logistics are modified.


func _ready() -> void:

	print("\n===== CHAT 07: CONNECTION STATE TEST =====")

	var conveyor_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(conveyor_scene != null)

	# =============================================================================
	# CREATE ISOLATED BELT ASSEMBLY
	# =============================================================================

	var test_root := Node3D.new()
	add_child(test_root)

	var belt_a: ConveyorSegment = (
		conveyor_scene.instantiate() as ConveyorSegment
	)

	var belt_b: ConveyorSegment = (
		conveyor_scene.instantiate() as ConveyorSegment
	)

	var belt_c: ConveyorSegment = (
		conveyor_scene.instantiate() as ConveyorSegment
	)

	var belt_d: ConveyorSegment = (
		conveyor_scene.instantiate() as ConveyorSegment
	)

	assert(belt_a != null)
	assert(belt_b != null)
	assert(belt_c != null)
	assert(belt_d != null)

	test_root.add_child(belt_a)
	test_root.add_child(belt_b)
	test_root.add_child(belt_c)
	test_root.add_child(belt_d)

	# A and D occupy the same source position.
	# B and C occupy the same destination position.
	#
	# The overlap is intentional for testing that one
	# endpoint cannot connect to multiple neighbors.

	belt_a.position = Vector3.ZERO
	belt_b.position = Vector3(0.0, 0.0, -1.0)
	belt_c.position = Vector3(0.0, 0.0, -1.0)
	belt_d.position = Vector3.ZERO

	# =============================================================================
	# TEST A — INITIAL STATE
	# =============================================================================

	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null)

	print("PASS A: New conveyors start disconnected")

	# =============================================================================
	# TEST B — ESTABLISH VALID CONNECTION
	# =============================================================================

	assert(belt_a.try_connect_to(belt_b))

	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)

	print("PASS B: Valid connection stored on both segments")

	# =============================================================================
	# TEST C — REPEATED CONNECTION
	# =============================================================================

	assert(belt_a.try_connect_to(belt_b))

	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)

	print("PASS C: Repeated connection is safe")

	# =============================================================================
	# TEST D — OCCUPIED ENDPOINTS
	# =============================================================================

	# A cannot connect to C while already connected to B.
	assert(not belt_a.try_connect_to(belt_c))

	# D cannot feed B while B already receives from A.
	assert(not belt_d.try_connect_to(belt_b))

	print("PASS D: Occupied endpoints reject extra links")

	# =============================================================================
	# TEST E — DISCONNECTION
	# =============================================================================

	assert(belt_a.disconnect_next())

	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null)

	assert(not belt_a.disconnect_next())

	print("PASS E: Disconnect clears both references")

	# =============================================================================
	# TEST F — INVALID CONNECTION GEOMETRY
	# =============================================================================

	belt_b.position.z = -2.0

	assert(not belt_a.try_connect_to(belt_b))

	belt_b.position.z = -1.0
	belt_b.rotation_degrees.y = 180.0

	assert(not belt_a.try_connect_to(belt_b))

	belt_b.rotation_degrees.y = 0.0

	assert(belt_a.next_segment == null)
	assert(belt_b.previous_segment == null)

	print("PASS F: Invalid geometry creates no connection")

	# =============================================================================
	# TEST G — ROTATED CONVEYOR ASSEMBLY
	# =============================================================================

	test_root.rotation_degrees.y = 90.0

	assert(belt_a.try_connect_to(belt_b))

	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)

	print("PASS G: Connections support parent rotation")

	# =============================================================================
	# TEST H — REMOVAL CLEANS UP CONNECTIONS
	# =============================================================================

	# Free B immediately to trigger _exit_tree().
	# A must not retain a link to a removed conveyor.

	belt_b.free()

	assert(belt_a.next_segment == null)

	print("PASS H: Removing a segment clears neighbor links")

	# =============================================================================
	# CLEAN UP TEST SCENE
	# =============================================================================

	test_root.queue_free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 8 CONVEYOR CONNECTION TESTS PASSED")
	print("==========================================")
