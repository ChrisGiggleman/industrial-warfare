
extends Node
class_name ConveyorTransportTimer


# =============================================================================
# CONVEYOR TRANSPORT SETTINGS
# =============================================================================

# Time required for one item to cross a conveyor segment.
#
# This is configurable and not tied to any item type.
# A future transport-speed upgrade can change this value.

@export_range(0.05, 10.0, 0.05)
var travel_interval: float = 1.0


# =============================================================================
# CONVEYOR TRANSPORT RUNTIME STATE
# =============================================================================

# Tracks the current item's movement progress.

var elapsed_seconds: float = 0.0

# Useful for future conveyor HUD/debugging.

var transport_status: String = "Empty"

# Number of successful outgoing transfers.

var successful_transfers: int = 0


# =============================================================================
# AUTOMATIC TRANSPORT UPDATE
# =============================================================================

# Godot calls this every frame when processing is enabled.
#
# The same method can be tested using manual delta values
# without requiring real-time delays in every unit test.

func _process(delta: float) -> void:

	advance_transport(delta)


# =============================================================================
# ADVANCE TRANSPORT TIMER
# =============================================================================

# Attempts one forward transfer after enough time passes.
#
# Returns true only when an item actually moves.
#
# This method does not inspect ore, ingots, ammunition,
# or any specific item identifier.

func advance_transport(delta: float) -> bool:

	# =============================================================================
	# VALIDATE TRANSPORT SETTINGS
	# =============================================================================

	if travel_interval <= 0.0:
		transport_status = "Invalid Timing"
		return false

	# =============================================================================
	# FIND PARENT CONVEYOR
	# =============================================================================

	var segment: ConveyorSegment = (
		get_parent() as ConveyorSegment
	)

	if not is_instance_valid(segment):
		transport_status = "Segment Missing"
		return false

	if not segment.is_inside_tree():
		transport_status = "Segment Unavailable"
		return false

	# =============================================================================
	# FIND CARGO COMPONENT
	# =============================================================================

	var cargo: ConveyorTransportComponent = (
		segment.get_node_or_null(
			"ConveyorTransportComponent"
		) as ConveyorTransportComponent
	)

	if not is_instance_valid(cargo):
		transport_status = "Cargo Component Missing"
		return false

	# =============================================================================
	# CHECK FOR ITEM
	# =============================================================================

	# No item means no movement progress.
	# Reset elapsed time so a newly loaded item must
	# travel its own full interval.

	if cargo.get_held_item() == null:
		elapsed_seconds = 0.0
		transport_status = "Empty"
		return false

	if delta <= 0.0:
		return false

	# =============================================================================
	# ADVANCE MOVEMENT PROGRESS
	# =============================================================================

	# Cap progress at one full travel interval.
	# This prevents blocked belts from accumulating
	# unlimited time and producing instant bursts.

	elapsed_seconds = minf(
		travel_interval,
		elapsed_seconds + delta
	)

	if elapsed_seconds < travel_interval:
		transport_status = "Moving"
		return false

	# =============================================================================
	# ATTEMPT CONNECTION-AWARE TRANSFER
	# =============================================================================

	# ConveyorTransportLink checks:
	# - Valid source and destination segments
	# - Correct physical connection and direction
	# - Endpoint alignment
	# - Cargo availability and destination capacity
	#
	# InventoryComponent handles resource conservation.

	var transferred: bool = (
		ConveyorTransportLink.try_transfer_forward(
			segment
		)
	)

	# =============================================================================
	# SUCCESSFUL TRANSFER
	# =============================================================================

	if transferred:

		elapsed_seconds = 0.0
		successful_transfers += 1
		transport_status = "Transferred"

		return true

	# =============================================================================
	# BLOCKED TRANSFER
	# =============================================================================

	# Keep the item and its completed travel progress.
	#
	# Once the destination becomes available,
	# another update may complete this transfer.

	transport_status = "Blocked"

	return false
