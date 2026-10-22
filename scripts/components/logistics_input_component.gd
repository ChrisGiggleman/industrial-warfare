
extends Node
class_name LogisticsInputComponent


# =============================================================================
# INPUT LOGISTICS SETTINGS
# =============================================================================

# Inventory that receives materials for manufacturing.
#
# For Test Smelter, this will reference InputInventory.
# Never assign OutputInventory here.

@export var input_inventory: InventoryComponent

# =============================================================================
# MANUFACTURING RECIPE REFERENCE
# =============================================================================

# References the manufacturing component receiving materials.
#
# This lets input logistics check the currently selected recipe
# before requesting any item from nearby storage.
#
# The recipe, rather than the logistics system, determines
# which materials a manufacturing building accepts.
#
# Assign the sibling ProducerComponent in the Godot Inspector.

@export var producer_component: ProducerComponent


# Item this component requests from nearby storage.
#
# Our first smelter will request Test Ore.
# Later factories can request different materials.

@export var transfer_item: ItemDefinition


# Maximum quantity requested during a transfer cycle.

@export_range(1, 1000, 1) var transfer_amount: int = 5


# Time in seconds between transfer attempts.

@export_range(0.1, 60.0, 0.1) var transfer_interval: float = 1.0


# Maximum distance to eligible storage buildings.

@export_range(0.5, 100.0, 0.5) var transfer_range: float = 5.0


# Desired maximum quantity of the requested item in the
# receiving inventory.
#
# This is a target buffer, not the inventory's total capacity.
#
# Example:
# Input inventory capacity: 50
# Target ore buffer: 10
#
# If the smelter holds 7 ore, logistics should request
# no more than 3 additional units.

@export_range(1, 100000, 1) var target_buffer_amount: int = 10


# =============================================================================
# INPUT LOGISTICS RUNTIME STATE
# =============================================================================

# Tracks elapsed time between input transfer attempts.

var transfer_timer: float = 0.0


# Describes what the input logistics system is doing.
#
# Planned statuses include:
# - Waiting for Storage
# - Receiving Materials
# - Waiting for Resources
# - Input Buffer Full
# - Input Inventory Full

var logistics_status: String = "Initializing"


# Number of items moved during the latest transfer attempt.

var last_transfer_amount: int = 0

# Tracks the previously detected storage building.
#
# -1 = No discovery check has occurred yet.
#  0 = No eligible storage detected.
# >0 = Instance ID of the detected storage.
#
# This prevents repeated identical detection messages.

var last_detected_storage_id: int = -1

# =============================================================================
# INITIALIZATION
# =============================================================================

# Confirms that the component has the references required
# to move raw materials into its manufacturing building.
#
# Actual storage discovery and transfer logic will be added
# after the component's initial configuration is verified.

func _ready() -> void:

	if not is_instance_valid(input_inventory):
		push_warning(
			"LogisticsInputComponent: Input inventory is missing."
		)

	if transfer_item == null:
		push_warning(
			"LogisticsInputComponent: Transfer item is missing."
		)

# =============================================================================
# NEARBY STORAGE DISCOVERY
# =============================================================================

# Searches for the nearest storage building containing
# the item requested by this input logistics component.
#
# A valid storage building must:
# - Belong to the logistics_storage group.
# - Be a Node3D.
# - Not be the requesting building.
# - Not be a disabled placement ghost.
# - Not be queued for deletion.
# - Contain an InventoryComponent.
# - Contain at least one requested item.
# - Be within the configured transfer range.
#
# Returns null if no eligible storage can be found.
#
# This function does not move or modify resources.

func _find_nearby_storage() -> Node3D:

	# =============================================================================
	# IDENTIFY REQUESTING BUILDING
	# =============================================================================

	var source_building: Node3D = get_parent() as Node3D

	if source_building == null:
		return null

	if transfer_item == null:
		return null

	# =============================================================================
	# STORAGE SEARCH STATE
	# =============================================================================

	var nearest_storage: Node3D = null
	var nearest_distance: float = INF

	# Find buildings registered as logistics storage.
	var storage_candidates: Array[Node] = (
		get_tree().get_nodes_in_group("logistics_storage")
	)

	# =============================================================================
	# VALIDATE STORAGE CANDIDATES
	# =============================================================================

	for candidate in storage_candidates:

		if not is_instance_valid(candidate):
			continue

		if candidate.is_queued_for_deletion():
			continue

		if not candidate is Node3D:
			continue

		var storage_building: Node3D = candidate as Node3D

		if storage_building == source_building:
			continue

		# Ignore disabled placement ghosts.
		if storage_building.process_mode == Node.PROCESS_MODE_DISABLED:
			continue

		# =============================================================================
		# CHECK STORAGE INVENTORY
		# =============================================================================

		var storage_inventory: InventoryComponent = (
			storage_building.get_node_or_null("InventoryComponent")
			as InventoryComponent
		)

		if not is_instance_valid(storage_inventory):
			continue

		# Only consider storage containing the requested item.
		if storage_inventory.get_amount(transfer_item) <= 0:
			continue

		# =============================================================================
		# CHECK TRANSFER DISTANCE
		# =============================================================================

		var distance: float = (
			source_building.global_position.distance_to(
				storage_building.global_position
			)
		)

		if distance > transfer_range:
			continue

		# =============================================================================
		# SELECT NEAREST ELIGIBLE STORAGE
		# =============================================================================

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_storage = storage_building

	return nearest_storage


# =============================================================================
# INPUT LOGISTICS DISCOVERY UPDATE
# =============================================================================

# Checks nearby storage once per configured transfer interval.
#
# For Step 5C, this only identifies eligible storage.
# It does not perform resource transfers.
#
# Actual inventory movement will be added in Step 5D.

func _process(delta: float) -> void:

	if not is_instance_valid(input_inventory):
		logistics_status = "Input Inventory Missing"
		return

	if transfer_item == null:
		logistics_status = "Transfer Item Missing"
		return

	# =============================================================================
	# VALIDATE MANUFACTURING RECIPE ACCEPTANCE
	# =============================================================================

	# Input logistics must have a valid manufacturing component
	# before it can determine which materials are allowed.
	#
	# Fail safely when the reference is missing.

	if not is_instance_valid(producer_component):
		logistics_status = "Producer Missing"
		last_transfer_amount = 0
		return

	# =============================================================================
	# CHECK SELECTED RECIPE
	# =============================================================================

	# The active recipe determines whether the requested item
	# may enter this manufacturing building.
	#
	# If the item is not required, stop before:
	# - Searching nearby storage.
	# - Calculating transfer quantities.
	# - Removing resources from storage.
	# - Adding resources to the input inventory.
	#
	# This protects against incorrect transfers when recipes
	# change and prepares logistics for future conveyor ports.

	if not producer_component.accepts_input_item(transfer_item):
		logistics_status = "Item Not Required by Recipe"
		last_transfer_amount = 0
		return

	# =============================================================================
	# DISCOVERY TIMER
	# =============================================================================

	transfer_timer += delta

	if transfer_timer < transfer_interval:
		return

	transfer_timer -= transfer_interval

	# =============================================================================
	# FIND NEARBY STORAGE
	# =============================================================================

	var nearby_storage: Node3D = _find_nearby_storage()

	var current_storage_id: int = 0

	if nearby_storage != null:
		current_storage_id = nearby_storage.get_instance_id()

	# =============================================================================
	# REPORT STORAGE DISCOVERY CHANGES
	# =============================================================================

	if current_storage_id != last_detected_storage_id:

		last_detected_storage_id = current_storage_id

		if nearby_storage != null:
			print(
				"Input Logistics: Storage detected: ",
				nearby_storage.name
			)
		else:
			print(
				"Input Logistics: No stocked storage in range"
			)


# =============================================================================
# AUTOMATIC INPUT INVENTORY TRANSFER
# =============================================================================

# Moves raw materials from nearby storage into the
# manufacturing building's dedicated input inventory.
#
# Transfer limits:
# - Source inventory must contain the requested item.
# - Transfer amount cannot exceed the configured maximum.
# - Transfer cannot exceed the target input buffer.
# - Transfer cannot exceed available input inventory capacity.
#
# InventoryComponent.transfer_to() performs the actual
# resource movement and protects against item loss.

# Reset the amount moved during this transfer attempt.
	last_transfer_amount = 0


# =============================================================================
# CHECK INPUT BUFFER REQUIREMENTS
# =============================================================================

# Determine how much of the requested material is
# already stored inside the smelter's input inventory.

	var current_buffer_amount: int = (
		input_inventory.get_amount(transfer_item)
	)

# Calculate how much more material is needed to reach
# the configured buffer target.
#
# Example:
# Target: 10
# Stored: 7
# Needed: 3

	var missing_buffer_amount: int = maxi(
		0,
		target_buffer_amount - current_buffer_amount
	)

# Do not pull more materials when the buffer is full.
	if missing_buffer_amount <= 0:
		logistics_status = "Input Buffer Full"
		return


# =============================================================================
# CHECK INPUT INVENTORY CAPACITY
# =============================================================================

# Get remaining space in the smelter's input inventory.
# -1 means the inventory has unlimited capacity.

	var available_input_space: int = (
		input_inventory.get_available_space()
	)

	if available_input_space == 0:
		logistics_status = "Input Inventory Full"
		return


# =============================================================================
# CALCULATE REQUESTED TRANSFER AMOUNT
# =============================================================================

# Begin with the maximum amount configured in the Inspector.
#
# Never request more materials than the buffer needs.

	var requested_amount: int = mini(
		transfer_amount,
		missing_buffer_amount
	)

# Apply the input inventory's physical capacity limit.
	if available_input_space >= 0:
		requested_amount = mini(
			requested_amount,
			available_input_space
		)

	if requested_amount <= 0:
		logistics_status = "Input Inventory Full"
		return


# =============================================================================
# VALIDATE NEARBY STORAGE
# =============================================================================

# No suitable storage was found by our discovery system.

	if nearby_storage == null:
		logistics_status = "Waiting for Storage or Materials"
		return

# Find the inventory belonging to the detected storage.

	var storage_inventory: InventoryComponent = (
		nearby_storage.get_node_or_null("InventoryComponent")
		as InventoryComponent
	)

	if not is_instance_valid(storage_inventory):
		logistics_status = "Storage Inventory Missing"
		return


# =============================================================================
# EXECUTE STORAGE-TO-SMELTER TRANSFER
# =============================================================================

# Transfer the requested material from storage into
# the smelter's input inventory.
#
# The existing transfer_to() function handles:
# - Available source quantities.
# - Destination capacity.
# - Partial transfers.
# - Resource conservation.
# - Unaccepted item restoration.

	var transferred_amount: int = storage_inventory.transfer_to(
		input_inventory,
		transfer_item,
		requested_amount
	)

	last_transfer_amount = transferred_amount


# =============================================================================
# UPDATE INPUT LOGISTICS STATUS
# =============================================================================

	if transferred_amount > 0:

		logistics_status = "Receiving Materials"

		# Display successful transfers for development testing.
		print(
			"Input Logistics: Pulled ",
			transferred_amount,
			" ",
			transfer_item.display_name,
			" from ",
			nearby_storage.name,
			" | Storage: ",
			storage_inventory.get_amount(transfer_item),
			" | Smelter Input: ",
			input_inventory.get_amount(transfer_item)
		)

	else:
		logistics_status = "Waiting for Storage or Materials"
