
extends Node3D
class_name ConveyorSegment


# =============================================================================
# CONVEYOR SELECTION VISUAL SETTINGS
# =============================================================================

# Mesh used for selection and demolition highlighting.
#
# Assign BeltMesh in the ConveyorStraight Inspector.
#
# Keep this behavior inside ConveyorSegment because
# the root must retain its conveyor connection script.

@export var selection_mesh: MeshInstance3D

@export var selected_color: Color = Color(1.0, 0.8, 0.2)
@export var demolition_color: Color = Color(1.0, 0.2, 0.2)


# =============================================================================
# CONVEYOR VISUAL STATE
# =============================================================================

var original_material: Material
var selection_material: StandardMaterial3D
var demolition_material: StandardMaterial3D

var is_selected: bool = false
var is_demolition_hovered: bool = false


# =============================================================================
# CONVEYOR VISUAL INITIALIZATION
# =============================================================================

func _ready() -> void:

	if not is_instance_valid(selection_mesh):
		push_warning(
			"ConveyorSegment: Selection Mesh is missing."
		)
		return

	# Preserve the conveyor's normal material.

	original_material = selection_mesh.material_override

	# Gold selection highlight.

	selection_material = StandardMaterial3D.new()
	selection_material.albedo_color = selected_color

	# Red demolition hover highlight.

	demolition_material = StandardMaterial3D.new()
	demolition_material.albedo_color = demolition_color


# =============================================================================
# CONVEYOR SELECTION
# =============================================================================

# Called by WorldInteraction when a conveyor is selected.

func set_selected(selected: bool) -> void:

	is_selected = selected
	_update_conveyor_visual_state()


# =============================================================================
# CONVEYOR DEMOLITION HOVER
# =============================================================================

# Called by WorldInteraction in demolition mode.

func set_demolition_hover(hovered: bool) -> void:

	is_demolition_hovered = hovered
	_update_conveyor_visual_state()


# =============================================================================
# UPDATE CONVEYOR VISUAL STATE
# =============================================================================

# Demolition highlighting takes priority over selection.

func _update_conveyor_visual_state() -> void:

	if not is_instance_valid(selection_mesh):
		return

	if is_demolition_hovered:
		selection_mesh.material_override = demolition_material

	elif is_selected:
		selection_mesh.material_override = selection_material

	else:
		selection_mesh.material_override = original_material

# =============================================================================
# CONVEYOR CONNECTION SETTINGS
# =============================================================================

# Maximum gap permitted for an established connection.
#
# Stricter than the general geometry discovery tolerance.
# Actual connected endpoints should almost coincide.

const CONNECTION_GAP: float = 0.05


# =============================================================================
# CONNECTION STATE
# =============================================================================

# The conveyor feeding this segment.
var previous_segment: ConveyorSegment = null

# The conveyor receiving items from this segment.
var next_segment: ConveyorSegment = null


# =============================================================================
# CALCULATE CONVEYOR SNAP PREVIEW
# =============================================================================

# Calculates where this segment would snap after
# another conveyor.
#
# Intended for the green Build Mode placement ghost.
#
# Returns an empty Dictionary when snapping is invalid.
# Otherwise returns a Dictionary with a "transform" value.
#
# IMPORTANT:
# - Does not move either conveyor.
# - Does not create a connection.
# - Does not change existing connection state.

func get_snap_preview_transform_after(
	source: ConveyorSegment
) -> Dictionary:

	# =============================================================================
	# VALIDATE SOURCE AND CONNECTION STATE
	# =============================================================================

	if not is_instance_valid(source):
		return {}

	if source == self:
		return {}

	if not is_inside_tree() or not source.is_inside_tree():
		return {}

	if is_instance_valid(source.next_segment):
		return {}

	if is_instance_valid(previous_segment):
		return {}

	# =============================================================================
	# GET ENDPOINTS
	# =============================================================================

	var source_output: Marker3D = (
		source.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	var own_input: Marker3D = (
		get_node_or_null("InputEndpoint")
		as Marker3D
	)

	if source_output == null or own_input == null:
		return {}

	# =============================================================================
	# CALCULATE PREVIEW TRANSFORM
	# =============================================================================

	# Straight conveyors inherit the source orientation.
	# This prototype assumes unscaled belt geometry.

	
	# =============================================================================
	# ALIGN NEW CONVEYOR WITH SOURCE OUTPUT DIRECTION
	# =============================================================================

	# A straight conveyor's output faces in its root
	# forward direction.
	#
	# A corner's output faces 90 degrees away from
	# its root forward direction.
	#
	# Use the actual OutputEndpoint orientation so
	# snapping works after straight and corner belts,
	# regardless of world rotation.

	var preview_basis: Basis = (
		source_output.global_transform.basis.orthonormalized()
	)


	var preview_position: Vector3 = (
		source_output.global_position
		- preview_basis * own_input.position
	)

	return {
		"transform": Transform3D(
			preview_basis,
			preview_position
		)
	}

# =============================================================================
# CALCULATE SNAP PREVIEW BEFORE AN EXISTING CONVEYOR
# =============================================================================

# Calculates where this new conveyor would be positioned
# BEFORE the input endpoint of an existing conveyor.
#
# This complements get_snap_preview_transform_after().
#
# No permanent connection is established.
# No conveyor is moved by this function.
#
# Returns:
# - Dictionary containing "transform" when valid.
# - Empty Dictionary when invalid.

func get_snap_preview_transform_before(
	target: ConveyorSegment
) -> Dictionary:

	# =============================================================================
	# VALIDATE TARGET
	# =============================================================================

	if not is_instance_valid(target):
		return {}

	if target == self:
		return {}

	if not is_inside_tree() or not target.is_inside_tree():
		return {}

	# The new belt's output and the existing belt's
	# input must both be available.

	if is_instance_valid(next_segment):
		return {}

	if is_instance_valid(target.previous_segment):
		return {}

	# =============================================================================
	# GET CONNECTION ENDPOINTS
	# =============================================================================

	var target_input: Marker3D = (
		target.get_node_or_null("InputEndpoint")
		as Marker3D
	)

	var own_output: Marker3D = (
		get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	if target_input == null or own_output == null:
		return {}

	# =============================================================================
	# CALCULATE PREVIEW TRANSFORM
	# =============================================================================

	# Straight segments inherit the target's orientation.

	var preview_basis: Basis = (
		target.global_transform.basis.orthonormalized()
	)

	# Position this belt so its output marker
	# meets the existing belt's input marker.

	var preview_position: Vector3 = (
		target_input.global_position
		- preview_basis * own_output.position
	)

	return {
		"transform": Transform3D(
			preview_basis,
			preview_position
		)
	}

# =============================================================================
# SNAP AFTER AN EXISTING CONVEYOR
# =============================================================================

# Positions this straight conveyor immediately after
# another conveyor, then attempts a valid connection.
#
# This prototype supports straight-to-straight snapping.
# Corner generation will be added separately.
#
# Call only when placing an actual conveyor segment,
# not during routine production processing.

func snap_after(source: ConveyorSegment) -> bool:

	# =============================================================================
	# VALIDATE SOURCE
	# =============================================================================

	if not is_instance_valid(source):
		return false

	if source == self:
		return false

	if not is_inside_tree() or not source.is_inside_tree():
		return false

	# Do not replace existing connections.

	if is_instance_valid(previous_segment):
		return false

	if is_instance_valid(source.next_segment):
		return false

	# =============================================================================
	# GET CONNECTION MARKERS
	# =============================================================================

	var source_output: Marker3D = (
		source.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	var own_input: Marker3D = (
		get_node_or_null("InputEndpoint")
		as Marker3D
	)

	if source_output == null or own_input == null:
		return false

	# =============================================================================
	# CALCULATE SNAPPED WORLD TRANSFORM
	# =============================================================================

	# Preserve the existing transform if connection fails.

	var original_transform: Transform3D = global_transform

	# Copy the source conveyor's world orientation.
	# This straight prototype assumes unscaled belt segments.

	var snapped_basis: Basis = (
		source.global_transform.basis.orthonormalized()
	)

	# Position this conveyor so its input marker meets
	# the previous conveyor's output marker.

	var snapped_position: Vector3 = (
		source_output.global_position
		- snapped_basis * own_input.position
	)

	global_transform = Transform3D(
		snapped_basis,
		snapped_position
	)

	# =============================================================================
	# ESTABLISH CONNECTION
	# =============================================================================

	# Reuse our previously tested connection validation.

	if not source.try_connect_to(self):
		global_transform = original_transform
		return false

	return true

# =============================================================================
# CONNECT TO NEXT CONVEYOR
# =============================================================================

# Attempts to establish a directed connection.
#
# Conditions:
# - Both segments must exist in the scene tree.
# - A segment cannot connect to itself.
# - The source must have an available output.
# - The target must have an available input.
# - Their endpoints must align physically.
#
# A valid connection updates both segments.
#
# No inventory items move during this operation.

func try_connect_to(
	target: ConveyorSegment
) -> bool:

	# =============================================================================
	# VALIDATE TARGET
	# =============================================================================

	if not is_instance_valid(target):
		return false

	if target == self:
		return false

	if not is_inside_tree() or not target.is_inside_tree():
		return false

	# =============================================================================
	# CHECK EXISTING CONNECTIONS
	# =============================================================================

	# Repeating an existing valid connection is harmless.

	if is_instance_valid(next_segment):
		return (
			next_segment == target
			and target.previous_segment == self
		)

	# A target cannot receive from two conveyor segments.

	if is_instance_valid(target.previous_segment):
		return false

	# =============================================================================
	# GET PHYSICAL ENDPOINTS
	# =============================================================================

	var outgoing: Marker3D = (
		get_node_or_null("OutputEndpoint") as Marker3D
	)

	var incoming: Marker3D = (
		target.get_node_or_null("InputEndpoint")
		as Marker3D
	)

	if outgoing == null or incoming == null:
		return false

	# =============================================================================
	# VALIDATE PHYSICAL ALIGNMENT
	# =============================================================================

	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		outgoing,
		incoming,
		CONNECTION_GAP
	):
		return false

	# =============================================================================
	# ESTABLISH CONNECTION
	# =============================================================================

	next_segment = target
	target.previous_segment = self

	return true


# =============================================================================
# DISCONNECT NEXT CONVEYOR
# =============================================================================

# Removes the outgoing connection from both segments.

func disconnect_next() -> bool:

	if not is_instance_valid(next_segment):
		next_segment = null
		return false

	var old_next: ConveyorSegment = next_segment

	if old_next.previous_segment == self:
		old_next.previous_segment = null

	next_segment = null

	return true


# =============================================================================
# DISCONNECT PREVIOUS CONVEYOR
# =============================================================================

# Removes the incoming connection from both segments.

func disconnect_previous() -> bool:

	if not is_instance_valid(previous_segment):
		previous_segment = null
		return false

	var old_previous: ConveyorSegment = previous_segment

	if old_previous.next_segment == self:
		old_previous.next_segment = null

	previous_segment = null

	return true


# =============================================================================
# DISCONNECT ALL CONNECTIONS
# =============================================================================

func disconnect_all() -> void:

	disconnect_next()
	disconnect_previous()

# =============================================================================
# SAFE CONVEYOR DEMOLITION CHECK
# =============================================================================

# Prevents the player from demolishing a conveyor
# while it contains transported resources.
#
# This check is independent of the item type.
# Ore, ingots, ammunition, and future resources
# receive the same protection.
#
# Missing or misconfigured cargo inventories fail safely.
#
# This does not remove cargo or modify connections.

func can_demolish_safely() -> bool:

	# =============================================================================
	# VALIDATE CONVEYOR STATE
	# =============================================================================

	if is_queued_for_deletion():
		return false

	# =============================================================================
	# FIND CARGO INVENTORY
	# =============================================================================

	var cargo_inventory: InventoryComponent = (
		get_node_or_null("CargoInventory")
		as InventoryComponent
	)

	if not is_instance_valid(cargo_inventory):
		return false

	# Our current conveyors carry one unit each.
	# Reject unexpected cargo configurations.

	if cargo_inventory.max_capacity != 1:
		return false

	# =============================================================================
	# CHECK FOR STORED ITEMS
	# =============================================================================

	# Empty belts are safe to remove.
	# Occupied belts must retain their cargo.

	return cargo_inventory.get_total_amount() == 0


# =============================================================================
# SCENE TREE EXIT
# =============================================================================

# When a conveyor is demolished or removed from the tree,
# its neighbors must no longer reference its connections.

func _exit_tree() -> void:

	disconnect_all()
