
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
	# GET LOCAL ENDPOINT POSITIONS
	# =============================================================================

	var start_position: Vector3 = input_endpoint.position
	var end_position: Vector3 = output_endpoint.position

	var travel_progress: float = clampf(
		progress,
		0.0,
		1.0
	)

	# =============================================================================
	# DETERMINE ENDPOINT DIRECTIONS
	# =============================================================================

	# Godot uses local -Z as forward.
	#
	# Straight endpoints have parallel/opposite axes.
	# Corner output axes are perpendicular to input.

	var input_direction: Vector3 = (
		input_endpoint.transform.basis
		* Vector3.FORWARD
	).normalized()

	var output_direction: Vector3 = (
		output_endpoint.transform.basis
		* Vector3.FORWARD
	).normalized()

	var direction_dot: float = (
		input_direction.dot(output_direction)
	)

	# =============================================================================
	# STRAIGHT CONVEYOR MOVEMENT
	# =============================================================================

	# Straight belts use a single linear path.
	#
	# This also provides a simple fallback for any
	# endpoint configuration that is not a 90-degree
	# corner in our current prototype.

	if absf(direction_dot) >= 0.1:

		return start_position.lerp(
			end_position,
			travel_progress
		)

	# =============================================================================
	# CALCULATE 90-DEGREE CORNER BEND
	# =============================================================================

	# For our existing L-shaped conveyor geometry:
	#
	# - The first half travels along local Z.
	# - The second half travels along local X.
	#
	# Both right and left turns use the same formula.
	# The output endpoint decides the turn direction.

	var bend_position: Vector3 = Vector3(
		start_position.x,
		start_position.y,
		end_position.z
	)

	# =============================================================================
	# FIRST HALF — INPUT TO BEND
	# =============================================================================

	if travel_progress <= 0.5:

		var first_half_progress: float = (
			travel_progress * 2.0
		)

		return start_position.lerp(
			bend_position,
			first_half_progress
		)

	# =============================================================================
	# SECOND HALF — BEND TO OUTPUT
	# =============================================================================

	var second_half_progress: float = (
		(travel_progress - 0.5) * 2.0
	)

	return bend_position.lerp(
		end_position,
		second_half_progress
	)

# =============================================================================
# HIDE CARGO
# =============================================================================

func _hide_cargo() -> void:

	displayed_item = null
	visible = false
