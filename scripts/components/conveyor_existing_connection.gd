
extends RefCounted
class_name ConveyorExistingConnection


# =============================================================================
# PERMANENT EXISTING CONVEYOR CONNECTION
# =============================================================================

# Connects two ALREADY PLACED conveyor segments.
#
# Uses our tested endpoint finder and corner conversion.
#
# Does not:
# - Create a new conveyor
# - Move either existing conveyor
# - Remove or replace inventory
# - Override occupied building ports
# - Bypass connection geometry
#
# Build Mode integration will be added after regression testing.


# =============================================================================
# CONNECT AN EXISTING SOURCE AND RECEIVER
# =============================================================================

static func try_connect_pair(
	source: ConveyorSegment,
	receiver: ConveyorSegment
) -> bool:

	var candidate: Dictionary = (
		ConveyorExistingEndpointFinder.inspect_pair(
			source,
			receiver
		)
	)

	return try_connect_candidate(candidate)


# =============================================================================
# COMMIT A DISCOVERED CONNECTION SAFELY
# =============================================================================

static func try_connect_candidate(
	candidate: Dictionary
) -> bool:

	# =============================================================================
	# VALIDATE THE SAVED CANDIDATE
	# =============================================================================

	if candidate.is_empty():
		return false

	var source: ConveyorSegment = (
		candidate.get("source") as ConveyorSegment
	)

	var receiver: ConveyorSegment = (
		candidate.get("receiver") as ConveyorSegment
	)

	if not is_instance_valid(source):
		return false

	if not is_instance_valid(receiver):
		return false

	# =============================================================================
	# RECHECK CURRENT PHYSICAL CONNECTION
	# =============================================================================

	# Discovery can become outdated if another connection
	# is established or either conveyor changes position.
	#
	# Never trust a previously saved preview without
	# checking the actual endpoints again.

	var current: Dictionary = (
		ConveyorExistingEndpointFinder.inspect_pair(
			source,
			receiver
		)
	)

	if current.is_empty():
		return false

	if current["mode"] != candidate.get("mode"):
		return false

	if current["turn"] != candidate.get("turn"):
		return false

	var original_junction: Vector3 = (
		candidate.get("junction", Vector3.INF)
	)

	var current_junction: Vector3 = (
		current["junction"]
	)

	if not original_junction.is_equal_approx(
		current_junction
	):
		return false

	# =============================================================================
	# COMMIT THE REQUIRED CONNECTION TYPE
	# =============================================================================

	match current["mode"]:

		"direct":

			# Both physical endpoints already match.
			# Only the directed references are established.

			return source.try_connect_to(receiver)

		"convert_source":

			# Our existing converter preserves node identity,
			# incoming connections and inventory.
			#
			# On connection failure, it restores the original
			# output marker without replacing the belt geometry.

			var turn: int = int(current["turn"])

			return (
				ConveyorCornerConversion.try_convert_and_connect(
					source,
					receiver,
					turn
				)
			)

		"convert_receiver":

			# Convert the receiving conveyor's INPUT into
			# a corner while retaining its existing output.
			#
			# The helper revalidates endpoint geometry and
			# refuses occupied or incompatible connections.

			return (
				ConveyorReceiverCornerConnection.try_connect(
					source,
					receiver
				)
			)

		_:
			return false
