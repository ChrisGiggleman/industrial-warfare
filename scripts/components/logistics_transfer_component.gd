
extends Node
class_name LogisticsTransferComponent


# =============================================================================
# LOGISTICS SETTINGS
# =============================================================================


# Item type this logistics component will transfer.
#
# Assign an ItemDefinition resource in the Godot Inspector.
#
# This keeps logistics independent of the extraction system
# and allows future buildings to transport different items.
#
# Example:
# - Test Extractor transfers Test Ore.
# - A future Copper Extractor transfers Copper Ore.
# - A factory could transfer manufactured components.
#
# Leaving this unassigned will prevent automatic transfers.

@export var transfer_item: ItemDefinition

# Maximum number of item units transferred per cycle.
# This value can be adjusted in the Godot Inspector.

@export_range(1, 1000, 1) var transfer_amount: int = 5


# Number of seconds between transfer attempts.
# A value of 1.0 means one transfer attempt per second.

@export_range(0.1, 60.0, 0.1) var transfer_interval: float = 1.0


# Maximum distance between this building and a destination.
# Measured in 3D world units.

@export_range(0.5, 100.0, 0.5) var transfer_range: float = 5.0


# =============================================================================
# RUNTIME STATE
# =============================================================================

# Inventory belonging to the building that owns this component.
var source_inventory: InventoryComponent = null

# Accumulated time toward the next transfer attempt.
# Transfer processing will be implemented in a later step.

var transfer_timer: float = 0.0

# Tracks the previously detected storage building.
#
# -1 means discovery has not run yet.
#  0 means no valid storage was detected.
# Positive values identify a specific storage instance.
#
# Used to prevent repeated Output messages every second.

var last_detected_storage_id: int = -1

# =============================================================================
# LOGISTICS DEBUG STATE
# =============================================================================

# Describes the current logistics operating condition.
#
# Future status values may include:
# - Initializing
# - Transferring
# - Waiting for Resources
# - No Eligible Storage
#
# The Production Debug HUD will read this value to explain
# what the logistics system is currently doing.

var logistics_status: String = "Initializing"


# Number of items successfully moved during the most recent
# transfer attempt.
#
# This will be updated by the automatic transfer system and
# displayed in the Production Debug HUD.

var last_transfer_amount: int = 0

# Stores the quantity moved during the most recent
# successful transfer.
#
# Unlike last_transfer_amount, this value remains unchanged
# when a transfer attempt fails or storage becomes unavailable.
#
# A value of 0 means no successful transfer has occurred yet.

var last_successful_transfer_amount: int = 0



# =============================================================================
# INITIALIZATION
# =============================================================================

# Locate the source inventory on the parent building.
#
# Our existing building scenes store InventoryComponent and
# ExtractorComponent as sibling nodes under the building root.
#
# This follows the same component structure already used by
# ExtractorComponent.

func _ready() -> void:
	source_inventory = (
		get_parent().get_node_or_null("InventoryComponent")
		as InventoryComponent
	)

	if source_inventory == null:
		push_warning(
			"LogisticsTransferComponent has no source InventoryComponent."
		)


# =============================================================================
# NEARBY STORAGE DISCOVERY
# =============================================================================

# Searches for the nearest eligible storage building.
#
# Requirements:
# - Must belong to the logistics_storage group.
# - Must be a real, active building rather than a placement ghost.
# - Must have an InventoryComponent.
# - Must have available inventory capacity.
# - Must be within the configured transfer range.
#
# Returns null if no eligible storage building exists.

func _find_nearby_storage() -> Node3D:
	var source_building: Node3D = get_parent() as Node3D

	if source_building == null:
		return null

	var nearest_storage: Node3D = null
	var nearest_distance: float = INF

	# Find all registered storage buildings in the active scene.
	var storage_candidates: Array[Node] = (
		get_tree().get_nodes_in_group("logistics_storage")
	)

	for candidate in storage_candidates:

		# Skip invalid or pending-deletion nodes.
		if not is_instance_valid(candidate):
			continue

		if candidate.is_queued_for_deletion():
			continue

		# Only consider actual 3D buildings.
		if not candidate is Node3D:
			continue

		var storage_building: Node3D = candidate as Node3D

		# Prevent a building from detecting itself.
		if storage_building == source_building:
			continue

		# Placement ghosts are disabled during preview.
		# They must not become logistics destinations.
		if storage_building.process_mode == Node.PROCESS_MODE_DISABLED:
			continue

		# Every valid destination must contain an inventory.
		var storage_inventory: InventoryComponent = (
			storage_building.get_node_or_null("InventoryComponent")
			as InventoryComponent
		)

		if storage_inventory == null:
			continue

		# Ignore destinations that have no available capacity.
		if storage_inventory.is_full():
			continue

		# =============================================================================
		# DISTANCE CHECK
		# =============================================================================

		# Calculate the distance between the two building origins.
		var distance: float = source_building.global_position.distance_to(
			storage_building.global_position
		)

		if distance > transfer_range:
			continue

		# Select the nearest eligible storage building.
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_storage = storage_building

	return nearest_storage



# =============================================================================
# STORAGE DISCOVERY AND AUTOMATIC TRANSFER UPDATE
# =============================================================================

# Runs once per frame and attempts item transfers at the
# configured transfer interval.
#
# Responsibilities:
# - Wait for the next transfer cycle.
# - Find a valid nearby storage building.
# - Report changes in storage discovery.
# - Transfer configured items into storage.
# - Respect source inventory and destination capacity.
#
# InventoryComponent.transfer_to() handles item accounting.

func _process(delta: float) -> void:

	# =============================================================================
	# VALIDATE LOGISTICS SETTINGS
	# =============================================================================

	# A source inventory must exist before items can move.
	if source_inventory == null:
		return

	# No transfer item has been configured.
	if transfer_item == null:
		return

	# =============================================================================
	# TRANSFER TIMER
	# =============================================================================

	transfer_timer += delta

	# Wait until enough time has passed.
	if transfer_timer < transfer_interval:
		return

	# Preserve extra elapsed time for more consistent timing.
	transfer_timer -= transfer_interval

	# =============================================================================
	# FIND NEARBY STORAGE
	# =============================================================================

	var nearby_storage: Node3D = _find_nearby_storage()

	# Track the currently discovered storage building.
	var current_storage_id: int = 0

	if nearby_storage != null:
		current_storage_id = nearby_storage.get_instance_id()

	# Print discovery changes without repeating identical messages.
	if current_storage_id != last_detected_storage_id:

		last_detected_storage_id = current_storage_id

		if nearby_storage != null:
			print(
				"Logistics: Nearby storage detected: ",
				nearby_storage.name
			)
		else:
			print("Logistics: No eligible storage within range")

	
	# Stop when no valid destination exists.
	#
	# Record the current logistics condition so the Debug HUD
	# can explain why resources are not moving.

	if nearby_storage == null:
		logistics_status = "No Eligible Storage"
		last_transfer_amount = 0
		return


	# =============================================================================
	# GET DESTINATION INVENTORY
	# =============================================================================

	var destination_inventory: InventoryComponent = (
		nearby_storage.get_node_or_null("InventoryComponent")
		as InventoryComponent
	)
	
	if destination_inventory == null:
		logistics_status = "Destination Inventory Missing"
		last_transfer_amount = 0
		return


	# =============================================================================
	# EXECUTE INVENTORY TRANSFER
	# =============================================================================

	# Attempt to move up to transfer_amount items.
	#
	# transfer_to() automatically handles:
	# - Available source items.
	# - Destination capacity.
	# - Partial transfers.
	# - Resource conservation.

	var transferred_amount: int = source_inventory.transfer_to(
		destination_inventory,
		transfer_item,
		transfer_amount
	)

	# =============================================================================
	# UPDATE LOGISTICS DEBUG STATE
	# =============================================================================

	# Record how many items moved during this transfer attempt.
	# This value will be displayed in the Production Debug HUD.

	last_transfer_amount = transferred_amount

	# Report successful movement when at least one item transferred.
	#
	# If no items moved, the source inventory may be empty.
	# Destination capacity is already checked during discovery.

	
	if transferred_amount > 0:
		logistics_status = "Transferring"

		# Remember the most recent successful transfer.
		# Do not reset this value when future attempts fail.
		last_successful_transfer_amount = transferred_amount

	else:
		logistics_status = "Waiting for Resources"


	# =============================================================================
	# TRANSFER DEBUG OUTPUT
	# =============================================================================

	# Only report successful transfers.
	# These messages will help verify the system before
	# we integrate transfer activity into the Debug HUD.

	if transferred_amount > 0:
		print(
			"Logistics: Transferred ",
			transferred_amount,
			" unit(s) to ",
			nearby_storage.name,
			" | Source: ",
			source_inventory.get_amount(transfer_item),
			" | Storage: ",
			destination_inventory.get_amount(transfer_item)
		)
