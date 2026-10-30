
extends MeshInstance3D
class_name ConveyorCargoVisual


# =============================================================================
# CONVEYOR CARGO VISUAL SETTINGS
# =============================================================================

# Generic placeholder geometry for any ItemDefinition.
# Item-specific meshes can replace this later.

@export var placeholder_size: Vector3 = Vector3(
	0.28, 0.18, 0.28
)

# Keeps the cargo above the conveyor surface.

@export var vertical_offset: float = 0.16


# =============================================================================
# DISPLAYED ITEM STATE
# =============================================================================

# Tracks which item this visual currently represents.
# This does not own or modify inventory resources.

var displayed_item: ItemDefinition = null


# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:

	# =============================================================================
	# CREATE PLACEHOLDER MESH
	# =============================================================================

	var placeholder := BoxMesh.new()
	placeholder.size = placeholder_size

	mesh = placeholder

	# =============================================================================
	# CONFIGURE PLACEHOLDER MATERIAL
	# =============================================================================

	var material := StandardMaterial3D.new()

	material.albedo_color = Color(
		0.93, 0.68, 0.30
	)

	material.metallic = 0.25
	material.roughness = 0.55

	material_override = material

	# Empty conveyors do not display cargo.

	visible = false


# =============================================================================
# VISUAL FRAME UPDATE
# =============================================================================

# Reads existing transportation state.
# Does not perform item transfers or advance timers.

func _process(_delta: float) -> void:

	refresh_visual()


# =============================================================================
# REFRESH CARGO VISUAL
# =============================================================================

func refresh_visual() -> void:

	# =============================================================================
	# FIND PARENT CONVEYOR
	# =============================================================================

	var segment: ConveyorSegment = (
		get_parent() as ConveyorSegment
	)

	if not is_instance_valid(segment):
		_hide_cargo()
		return

	if segment.is_queued_for_deletion():
		_hide_cargo()
		return

	# =============================================================================
	# FIND CARGO AND TIMER COMPONENTS
	# =============================================================================

	var transport: ConveyorTransportComponent = (
		segment.get_node_or_null(
			"ConveyorTransportComponent"
		) as ConveyorTransportComponent
	)

	var timer: ConveyorTransportTimer = (
		segment.get_node_or_null(
			"ConveyorTransportTimer"
		) as ConveyorTransportTimer
	)

	if not is_instance_valid(transport):
		_hide_cargo()
		return

	if not is_instance_valid(timer):
		_hide_cargo()
		return

	# =============================================================================
	# CHECK CURRENT ITEM
	# =============================================================================

	var item: ItemDefinition = (
		transport.get_held_item()
	)

	if item == null:
		_hide_cargo()
		return

	# =============================================================================
	# FIND PHYSICAL ENDPOINTS
	# =============================================================================

	var input_endpoint: Marker3D = (
		segment.get_node_or_null(
			"InputEndpoint"
		) as Marker3D
	)

	var output_endpoint: Marker3D = (
		segment.get_node_or_null(
			"OutputEndpoint"
		) as Marker3D
	)

	if (
		not is_instance_valid(input_endpoint)
		or not is_instance_valid(output_endpoint)
	):
		_hide_cargo()
		return

	if timer.travel_interval <= 0.0:
		_hide_cargo()
		return

	# =============================================================================
	# CALCULATE TRANSPORT PROGRESS
	# =============================================================================

	# Convert elapsed time into a value from 0 to 1.
	#
	# 0.0 = input
	# 0.5 = middle
	# 1.0 = output

	var progress: float = clampf(
		timer.elapsed_seconds / timer.travel_interval,
		0.0,
		1.0
	)

	
	# =============================================================================
	# POSITION CARGO ALONG STRAIGHT OR CORNER PATH
	# =============================================================================

	# Calculate the appropriate cargo position using
	# the conveyor's existing endpoint geometry.
	#
	# Straight: Input -> Output
	# Corner:   Input -> Bend -> Output
	#
	# This does not affect actual resource transportation.

	var cargo_position: Vector3 = _get_cargo_path_position(
		input_endpoint,
		output_endpoint,
		progress
	)

	position = (
		cargo_position
		+ Vector3.UP * vertical_offset
	)


	# =============================================================================
	# SHOW CARGO
	# =============================================================================

	displayed_item = item
	visible = true


# =============================================================================
# CALCULATE CONVEYOR CARGO PATH
# =============================================================================

# Returns the local position of an item traveling
# between the conveyor's input and output endpoints.
#
# Straight conveyors use linear movement.
#
# Right and left corners use two connected straight
# sections that meet at the center of the bend.
#
# The current corner geometry enters along local Z
# and exits along local X. Root Y rotation is handled
# automatically because positions remain local.
#
# No item names or resource identifiers are required.


func _get_cargo_path_position(
	input_endpoint: Marker3D,
	output_endpoint: Marker3D,
	progress: float
) -> Vector3:

	# =============================================================================
	# DISTANCE-WEIGHTED STRAIGHT AND CORNER MOVEMENT — CHAT 08.3G-3H
	# =============================================================================

	# Follow the actual endpoint-to-endpoint path.
	# For a corner with unequal legs, the longer leg gets a
	# proportional share of the travel interval.
	# The displayed item keeps the same physical speed before
	# and after the bend.

	return ConveyorPathMotion.position_at_progress(
		input_endpoint,
		output_endpoint,
		progress
	)

# =============================================================================
# HIDE CARGO
# =============================================================================

func _hide_cargo() -> void:

	displayed_item = null
	visible = false
