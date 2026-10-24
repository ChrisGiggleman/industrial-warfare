
extends Node


# =============================================================================
# CHAT 07 — PHYSICAL CONNECTION GEOMETRY TEST
# =============================================================================

# Tests endpoint position, orientation, rotation,
# and invalid connection candidates.
#
# No inventory or gameplay systems are changed.


func _ready() -> void:

	print("\n===== CHAT 07: CONNECTION GEOMETRY TEST =====")

	# =============================================================================
	# CREATE TEST ENDPOINTS
	# =============================================================================

	var source_parent := Node3D.new()
	var target_parent := Node3D.new()

	add_child(source_parent)
	add_child(target_parent)

	var outgoing := Marker3D.new()
	var incoming := Marker3D.new()

	source_parent.add_child(outgoing)
	target_parent.add_child(incoming)

	# Outgoing points toward +X.
	# Incoming points toward -X.

	outgoing.position = Vector3(0.0, 0.5, 0.0)
	outgoing.rotation_degrees.y = -90.0

	incoming.position = Vector3(0.5, 0.5, 0.0)
	incoming.rotation_degrees.y = 90.0

	# =============================================================================
	# TEST A — INVALID REFERENCES
	# =============================================================================

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			null, incoming
		)
	)

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, outgoing
		)
	)

	print("PASS A: Invalid endpoints rejected")

	# =============================================================================
	# TEST B — VALID ALIGNED CONNECTION
	# =============================================================================

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	print("PASS B: Correctly aligned endpoints accepted")

	# =============================================================================
	# TEST C — TOO FAR APART
	# =============================================================================

	incoming.position.x = 2.0

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	incoming.position.x = 0.5

	print("PASS C: Distant endpoints rejected")

	# =============================================================================
	# TEST D — WRONG FACING DIRECTION
	# =============================================================================

	incoming.rotation_degrees.y = -90.0

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	incoming.rotation_degrees.y = 90.0

	print("PASS D: Incorrect facing rejected")

	# =============================================================================
	# TEST E — SIDEWAYS MISALIGNMENT
	# =============================================================================

	incoming.position.z = 0.5

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	incoming.position.z = 0.0

	print("PASS E: Sideways offset rejected")

	# =============================================================================
	# TEST F — HEIGHT MISALIGNMENT
	# =============================================================================

	incoming.position.y = 0.8

	assert(
		not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	incoming.position.y = 0.5

	print("PASS F: Height offset rejected")

	# =============================================================================
	# TEST G — EXACT SNAP POSITION
	# =============================================================================

	# Opposite-facing endpoints can meet at one position.

	incoming.position = outgoing.position

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	incoming.position = Vector3(0.5, 0.5, 0.0)

	print("PASS G: Coincident connection markers supported")

	# =============================================================================
	# TEST H — PARENT BUILDING ROTATION
	# =============================================================================

	# Rotate both endpoint parents by 90 degrees.
	# Their world positions and directions must
	# remain compatible after the transformation.

	source_parent.rotation_degrees.y = 90.0
	target_parent.rotation_degrees.y = 90.0

	assert(
		LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming
		)
	)

	print("PASS H: Endpoint geometry follows parent rotation")

	# =============================================================================
	# CLEAN UP
	# =============================================================================

	source_parent.queue_free()
	target_parent.queue_free()

	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("==========================================")
	print("ALL 8 CONNECTION GEOMETRY TESTS PASSED")
	print("==========================================")
