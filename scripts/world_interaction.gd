extends Node


# =============================================================================
# CONSTANTS
# =============================================================================
# Physics collision masks used by the interaction system.
#
# Layer 1 = Ground / placement surfaces
# Layer 3 = Placement blockers

const GROUND_COLLISION_MASK: int = 1
const RESOURCE_NODE_COLLISION_MASK: int = 2
const PLACEMENT_BLOCKER_COLLISION_MASK: int = 4

# Placement preview settings that currently do not need Inspector adjustment.

const ROTATION_STEP_DEGREES: float = 90.0
const FULL_ROTATION_DEGREES: float = 360.0
const PLACEMENT_GHOST_ALPHA: float = 0.4

# =============================================================================
# MOUSE INTERACTION COLLISION MASK
# =============================================================================

# Layer 2 is used by selectable and demolishable objects.
# Layer 1 ground and Layer 3 placement blockers are excluded.

const SELECTION_COLLISION_MASK: int = 2

# =============================================================================
# EXPORTED SETTINGS
# =============================================================================
# References and values that can be adjusted from the Godot Inspector.

@export var camera: Camera3D

@export var build_hud_panel: Control
@export var build_hud: CanvasLayer

@export var production_debug_hud: ProductionDebugHUD

# Building definitions available to the construction system.
# Each definition contains the data describing a buildable structure.
@export var buildable_definitions: Array[BuildingDefinition] = []

# Legacy scene list retained temporarily while the placement system is
# migrated to BuildingDefinition resources.
# @export var buildable_scenes: Array[PackedScene] = []

@export var ray_length: float = 1000.0
@export var grid_size: float = 1.0

@export var valid_placement_color: Color = Color(0.0, 1.0, 0.0)
@export var invalid_placement_color: Color = Color(1.0, 0.0, 0.0)


# =============================================================================
# RUNTIME STATE
# =============================================================================
# Stores information that changes while the game is running.

# Normal selection state.
var selected_object: Node = null

# Build Mode state.
var placement_mode_active: bool = false
var selected_building_index: int = 0
var current_placement_position: Vector3 = Vector3.ZERO
var placement_is_valid: bool = false
var placement_rotation_degrees: float = 0.0

# Placement ghost state.
var placement_ghost: Node3D = null
var ghost_material: StandardMaterial3D
var placement_ghost_collisions: Array[CollisionShape3D] = []

# =============================================================================
# CONVEYOR SNAP PREVIEW STATE
# =============================================================================

# =============================================================================
# BUILDING-OFFSET CORNER SNAP STATE
# =============================================================================

# Used when an existing conveyor sits off the normal
# grid because it is aligned to a building port.
#
# Preview only. Permanent connections are handled later.

var conveyor_corner_snap_source: ConveyorSegment = null

var conveyor_corner_snap_turn: int = (
	ConveyorTurnIntent.Turn.STRAIGHT
)

# =============================================================================
# TWO-ENDED CONVEYOR BRIDGE SNAP STATE — CHAT 08.3F-6
# =============================================================================

# Valid only when a single ordinary straight segment physically fits
# between TWO existing free conveyor endpoints.
# Preview references are reset every frame and never create links.

var conveyor_bridge_source: ConveyorSegment = null
var conveyor_bridge_destination: ConveyorSegment = null

# Stores the placed conveyor currently providing a
# possible snap location for our placement ghost.
#
# This is preview state only.
# No permanent connections are established here.

var conveyor_snap_source: ConveyorSegment = null
# True when the new belt should connect into an existing input.
# False when the new belt should connect after an existing output.
#
# The next step will use this to establish the correct
# permanent connection when the player clicks.

var conveyor_snap_before: bool = false

# =============================================================================
# BUILDING PORT SNAP PREVIEW STATE
# =============================================================================

# Stores the building port currently offering a
# valid physical connection to the placement ghost.
#
# This is temporary preview state only.
# No permanent connection exists until placement
# is explicitly committed in a later step.

var conveyor_building_snap_port: ItemPortComponent = null

# =============================================================================
# BUILDING-TO-CONVEYOR PLACEMENT SNAP STATE
# =============================================================================

# Stores the existing conveyor and building port
# selected for a potential building placement.
#
# This is preview state only.
# No physical connection is established yet.

var building_placement_snap_belt: ConveyorSegment = null

var building_placement_snap_port: ItemPortComponent = null

# =============================================================================
# ACTIVE CONVEYOR PREVIEW SCENE
# =============================================================================

# Tracks which conveyor scene the current ghost uses.
#
# Later, Build Mode will switch between:
# - Straight conveyor
# - Right 90-degree corner
# - Left 90-degree corner
#
# Null means there is no active conveyor preview.

var conveyor_preview_scene: PackedScene = null

# How close the mouse's grid position must be to a
# valid snapped conveyor position.

const CONVEYOR_SNAP_SEARCH_RADIUS: float = 1.25

# Separate range for machine ports, which can sit off the grid.
const CONVEYOR_BUILDING_PORT_SEARCH_RADIUS: float = 1.75

# Demolition Tool state.
var demolition_mode_active: bool = false
var demolition_hover_target: Node = null


# =============================================================================
# INITIALIZATION
# =============================================================================
# Runs once when WorldInteraction enters the scene.
#
# Build Mode begins disabled, so the Build HUD starts hidden.

func _ready() -> void:
	if build_hud_panel != null:
		build_hud_panel.visible = false


# =============================================================================
# FRAME UPDATE
# =============================================================================
# Runs every rendered frame while Build Mode is active.
#
# Placement Tool:
#   Updates the building placement preview.
#
# Demolition Tool:
#   Updates the structure currently targeted for demolition.

func _process(_delta: float) -> void:
	if not placement_mode_active:
		return

	if demolition_mode_active:
		_update_demolition_hover()
	else:
		_update_placement_preview()


# =============================================================================
# INPUT HANDLING
# =============================================================================
# Handles interaction inputs.
#
# Normal Mode:
#   Left Click  = Select object
#   B           = Enter Build Mode
#
# Build / Placement Mode:
#   Left Click  = Place building
#   Right Click = Exit Build Mode
#   Delete      = Toggle Demolition Tool
#   1           = Select building slot 1
#   2           = Select building slot 2
#   R           = Rotate placement preview
#
# Demolition Tool:
#   Left Click  = Demolish player-built structure
#   Delete      = Return to Placement Tool
#   Right Click = Exit Build Mode

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_placement_mode"):
		_toggle_placement_mode()
		return

	if placement_mode_active:
		if event.is_action_pressed("secondary_action"):
			_toggle_placement_mode()
			return

		if event.is_action_pressed("demolish_selected"):
			_toggle_demolition_mode()
			return

		if demolition_mode_active:
			if event.is_action_pressed("primary_action"):
				_try_demolish_under_mouse()
				return

			return

		if event.is_action_pressed("select_building_1"):
			_select_building(0)
			return

		if event.is_action_pressed("select_building_2"):
			_select_building(1)
			return

		if event.is_action_pressed("select_building_3"):
			_select_building(2)
			return

		if event.is_action_pressed("select_building_4"):
			_select_building(3)
			return

		if event.is_action_pressed("select_building_5"):
			_select_building(4)
			return
			
		if event.is_action_pressed("rotate_placement"):
			_rotate_placement()
			return

		# =============================================================================
		# CHAT 08.3G — INSPECT EXISTING CONVEYOR JUNCTION
		# =============================================================================

		# J inspects nearby existing conveyor connections.
		# Only available with Conveyor Belt selected.
		# Does not modify the factory.

		if (
			selected_building_index == 4
			and event is InputEventKey
			and event.pressed
			and not event.echo
			and event.physical_keycode == KEY_J
		):
			_inspect_existing_conveyor_junction()
			return

		if event.is_action_pressed("primary_action"):
			_try_place_object()
			return

		return

	if event.is_action_pressed("primary_action"):
		_select_under_mouse()


		# =============================================================================
		# CHAT 08.3G — CONNECT EXISTING CONVEYOR JUNCTION
		# =============================================================================

		# K connects an existing receiver-side corner.
		# No new conveyor is placed.
		# The connection is revalidated before committing.

		if (
			selected_building_index == 4
			and event is InputEventKey
			and event.pressed
			and not event.echo
			and event.physical_keycode == KEY_K
		):
			_connect_existing_conveyor_junction()
			return

# =============================================================================
# CHAT 08.3G-3C — EXISTING CONVEYOR JUNCTION INSPECTION
# =============================================================================

# Finds a compatible connection near the mouse cursor.
# Uses the existing, tested endpoint-discovery helper.
#
# This is diagnostic only.
# No connection or corner conversion is committed.

func _inspect_existing_conveyor_junction() -> void:



	if not is_instance_valid(camera):
		print("JUNCTION DEBUG | Camera unavailable.")
		return

	# =============================================================================
	# FIND MOUSE POSITION ON FACTORY FLOOR
	# =============================================================================

	var mouse_position: Vector2 = (
		get_viewport().get_mouse_position()
	)

	var ray_origin: Vector3 = (
		camera.project_ray_origin(mouse_position)
	)

	var ray_direction: Vector3 = (
		camera.project_ray_normal(mouse_position)
	)

	var ray_end: Vector3 = (
		ray_origin + ray_direction * ray_length
	)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = GROUND_COLLISION_MASK

	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(
			query
		)
	)

	if hit.is_empty():
		print("JUNCTION DEBUG | No ground detected.")
		return

	# =============================================================================
	# FIND NEAREST COMPATIBLE EXISTING CONNECTION
	# =============================================================================

	var candidate: Dictionary = (
		ConveyorExistingEndpointFinder.find_nearest_candidate(
			get_tree(),
			hit["position"],
			1.25
		)
	)

	if candidate.is_empty():
		print(
			"JUNCTION DEBUG | No compatible free endpoints near ",
			hit["position"]
		)
		return

	# =============================================================================
	# REPORT CONNECTION TYPE
	# =============================================================================

	var source: ConveyorSegment = (
		candidate["source"] as ConveyorSegment
	)

	var receiver: ConveyorSegment = (
		candidate["receiver"] as ConveyorSegment
	)

	print(
		"JUNCTION FOUND | Source: ",
		source.name,
		" | Receiver: ",
		receiver.name,
		" | Mode: ",
		candidate["mode"],
		" | Turn: ",
		candidate["turn"],
		" | Position: ",
		candidate["junction"]
	)
# =============================================================================
# CHAT 08.3G — CONNECT EXISTING RECEIVER CORNER
# =============================================================================

# Temporary explicit construction command.
#
# Connects two existing lines without placing a new belt.
# Only receiver-side corner conversions are enabled here.
#
# Validates the physical junction and checks that the
# receiver tile contains no unrelated placement blockers.

func _connect_existing_conveyor_junction() -> void:

	if not is_instance_valid(camera):
		print("JUNCTION CONNECT | Camera unavailable.")
		return

	# =============================================================================
	# FIND MOUSE POSITION ON GROUND
	# =============================================================================

	var mouse_position: Vector2 = (
		get_viewport().get_mouse_position()
	)

	var ray_origin: Vector3 = (
		camera.project_ray_origin(mouse_position)
	)

	var ray_end: Vector3 = (
		ray_origin
		+ camera.project_ray_normal(mouse_position) * ray_length
	)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = GROUND_COLLISION_MASK

	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(
			query
		)
	)

	if hit.is_empty():
		print("JUNCTION CONNECT | No ground detected.")
		return

	# =============================================================================
	# DISCOVER COMPATIBLE EXISTING ENDPOINTS
	# =============================================================================

	var candidate: Dictionary = (
		ConveyorExistingEndpointFinder.find_nearest_candidate(
			get_tree(),
			hit["position"],
			1.25
		)
	)

	if candidate.is_empty():
		print("JUNCTION CONNECT | No compatible endpoints.")
		return

	# First integration supports receiver-side corners.
	# Direct and source-side connections will follow.

	if candidate.get("mode") != "convert_receiver":
		print(
			"JUNCTION CONNECT | Not enabled for mode: ",
			candidate.get("mode")
		)
		return

	var source: ConveyorSegment = (
		candidate["source"] as ConveyorSegment
	)

	var receiver: ConveyorSegment = (
		candidate["receiver"] as ConveyorSegment
	)

	if (
		not is_instance_valid(source)
		or not is_instance_valid(receiver)
	):
		print("JUNCTION CONNECT | Invalid conveyor.")
		return

	# =============================================================================
	# VALIDATE CORNER TILE CLEARANCE
	# =============================================================================

	# A converted corner occupies the receiving belt's tile.
	# Test a conservative square footprint against Layer 3.
	#
	# Exclude only the receiver's own existing collision body.
	# Other physical obstacles must still be rejected.

	var receiver_body: PhysicsBody3D = (
		receiver.get_node_or_null("ConveyorBody")
		as PhysicsBody3D
	)

	if not is_instance_valid(receiver_body):
		print("JUNCTION CONNECT | Receiver body missing.")
		return

	var clearance_shape := BoxShape3D.new()
	clearance_shape.size = Vector3(0.98, 0.2, 0.98)

	var shape_query := PhysicsShapeQueryParameters3D.new()
	shape_query.shape = clearance_shape
	shape_query.transform = (
		receiver.global_transform
		* Transform3D(
			Basis.IDENTITY,
			Vector3(0.0, 0.3, 0.0)
		)
	)
	shape_query.collision_mask = PLACEMENT_BLOCKER_COLLISION_MASK

	var exclusions: Array[RID] = [
		receiver_body.get_rid()
	]

	shape_query.exclude = exclusions

	var obstacles: Array[Dictionary] = (
		get_viewport().world_3d.direct_space_state.intersect_shape(
			shape_query,
			8
		)
	)

	if not obstacles.is_empty():
		print(
			"JUNCTION CONNECT | Receiver tile obstructed: ",
			obstacles[0].get("collider")
		)
		return

	# =============================================================================
	# COMMIT PERMANENT CONNECTION
	# =============================================================================

	# The shared manager revalidates the candidate.
	# The receiver conversion preserves downstream links
	# and existing item inventories.

	if ConveyorExistingConnection.try_connect_candidate(
		candidate
	):
		print(
			"JUNCTION CONNECTED | Source: ",
			source.name,
			" | Receiver: ",
			receiver.name,
			" | Turn: ",
			candidate["turn"]
		)
	else:
		print(
			"JUNCTION CONNECT FAILED | Geometry or state changed."
		)
# =============================================================================
# BUILD MODE TOGGLE
# =============================================================================
# Enables or disables Build Mode.
#
# Entering Build Mode:
#   - clears normal object selection
#   - creates the building placement ghost
#   - shows the Build HUD
#
# Leaving Build Mode:
#   - clears demolition state
#   - removes demolition hover feedback
#   - destroys the placement ghost
#   - hides the Build HUD

func _toggle_placement_mode() -> void:
	placement_mode_active = not placement_mode_active

	if placement_mode_active:
		_select_object(null)
		_create_placement_ghost()

		if build_hud_panel != null:
			build_hud_panel.visible = true

		if build_hud != null and build_hud.has_method("set_selected_building"):
			build_hud.call(
				"set_selected_building",
				selected_building_index
			)

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", false)

		print("Placement mode enabled")

	else:
		demolition_mode_active = false
		placement_is_valid = false

		_clear_demolition_hover()
		_destroy_placement_ghost()

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", false)

		if build_hud_panel != null:
			build_hud_panel.visible = false

		print("Placement mode disabled")

# =============================================================================
# SELECTED BUILDING DEFINITION
# =============================================================================

# Returns the BuildingDefinition currently selected for construction.
#
# Returns null when:
#   - the building-definition list is empty
#   - the selected index is outside the valid array range
#   - the selected definition is missing

func _get_selected_building_definition() -> BuildingDefinition:
	if buildable_definitions.is_empty():
		return null

	if selected_building_index < 0:
		return null

	if selected_building_index >= buildable_definitions.size():
		return null

	return buildable_definitions[selected_building_index]

# =============================================================================
# SELECTED BUILDING SCENE
# =============================================================================
# Returns the PackedScene currently selected for construction.
#
# Returns null when:
#   - the building-definition list is empty
#   - the selected index is outside the valid array range

func _get_selected_building_scene() -> PackedScene:
	var selected_definition: BuildingDefinition = (
		_get_selected_building_definition()
	)

	if selected_definition == null:
		return null

	return selected_definition.building_scene


# =============================================================================
# BUILDING SELECTION
# =============================================================================
# Changes which building definition is selected for construction.
#
# Changing buildings:
#   - resets placement rotation to 0 degrees
#   - recreates the placement ghost when Build Mode is active
#   - updates the Build HUD selection highlight

func _select_building(index: int) -> void:
	if index < 0 or index >= buildable_definitions.size():
		return

	if buildable_definitions[index] == null:
		return

	if buildable_definitions[index].building_scene == null:
		return

	selected_building_index = index
	placement_rotation_degrees = 0.0

	if placement_mode_active and not demolition_mode_active:
		_create_placement_ghost()

	if build_hud != null and build_hud.has_method("set_selected_building"):
		build_hud.call(
			"set_selected_building",
			selected_building_index
		)

	print(
		"Selected building: ",
		buildable_definitions[index].display_name
	)


# =============================================================================
# DEMOLITION MODE
# =============================================================================
# Toggles between the Placement Tool and Demolition Tool while Build Mode
# remains active.
#
# Entering Demolition Mode:
#   - removes the placement ghost
#   - invalidates placement
#   - changes the HUD to demolition controls
#
# Returning to Placement Mode:
#   - clears demolition hover feedback
#   - recreates the placement ghost
#   - restores the normal Build HUD

func _toggle_demolition_mode() -> void:
	demolition_mode_active = not demolition_mode_active

	if demolition_mode_active:
		_clear_demolition_hover()
		_destroy_placement_ghost()
		placement_is_valid = false

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", true)

		print("Demolition mode enabled")

	else:
		_clear_demolition_hover()
		_create_placement_ghost()

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", false)

		print("Demolition mode disabled")


# =============================================================================
# DEMOLITION HOVER
# =============================================================================
# Finds the player-built structure currently underneath the mouse cursor.
#
# Valid demolition targets receive red hover feedback through their
# set_demolition_hover() method.

func _update_demolition_hover() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# =============================================================================
	# INTERACTIVE OBJECT RAYCAST SETTINGS
	# =============================================================================

	# Detect selectable objects on physics Layer 2.
	# Include both StaticBody3D and Area3D hitboxes.

	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	var new_target: Node = null

	if result:
		var collider: Node = result["collider"]
		var current_node: Node = collider

		while current_node != null:
			if current_node.is_in_group("player_built"):
				new_target = current_node
				break

			current_node = current_node.get_parent()

	# No state change is needed if the mouse remains over the same object.
	if demolition_hover_target == new_target:
		return

	# Remove demolition feedback from the previous target.
	if demolition_hover_target != null:
		if is_instance_valid(demolition_hover_target):
			if demolition_hover_target.has_method("set_demolition_hover"):
				demolition_hover_target.call(
					"set_demolition_hover",
					false
				)

	demolition_hover_target = new_target

	# Apply demolition feedback to the new target.
	if demolition_hover_target != null:
		if demolition_hover_target.has_method("set_demolition_hover"):
			demolition_hover_target.call(
				"set_demolition_hover",
				true
			)


# =============================================================================
# DEMOLITION HOVER CLEANUP
# =============================================================================
# Removes demolition highlighting from the current hover target and clears
# the stored reference.

func _clear_demolition_hover() -> void:
	if demolition_hover_target != null:
		if is_instance_valid(demolition_hover_target):
			if demolition_hover_target.has_method("set_demolition_hover"):
				demolition_hover_target.call(
					"set_demolition_hover",
					false
				)

	demolition_hover_target = null


# =============================================================================
# DEMOLITION RAYCAST
# =============================================================================
# Casts a ray beneath the mouse cursor.
#
# The collider hierarchy is searched upward until a node in the
# "player_built" group is found.
#
# Objects that are selectable but not player-built remain protected.

func _try_demolish_under_mouse() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# =============================================================================
	# INTERACTIVE OBJECT RAYCAST SETTINGS
	# =============================================================================

	# Detect selectable objects on physics Layer 2.
	# Include both StaticBody3D and Area3D hitboxes.

	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	if result.is_empty():
		print("Nothing to demolish")
		return

	var collider: Node = result["collider"]
	var current_node: Node = collider

	
	while current_node != null:
		if current_node.is_in_group("player_built"):

			# =============================================================================
			# PROTECT CONVEYOR CARGO BEFORE DEMOLITION
			# =============================================================================

			# Prevent player demolition from destroying
			# resources currently stored on a conveyor.
			#
			# Other existing building demolition behavior
			# remains unchanged.

			if current_node is ConveyorSegment:

				var conveyor: ConveyorSegment = (
					current_node as ConveyorSegment
				)

				if not conveyor.can_demolish_safely():

					print(
						"Demolition blocked: Conveyor contains "
						+ "cargo or has an invalid cargo buffer."
					)

					return

			# =============================================================================
			# EXECUTE EXISTING DEMOLITION
			# =============================================================================

			print("Demolished ", current_node.name)

			if current_node == demolition_hover_target:
				demolition_hover_target = null

			current_node.queue_free()
			return

		current_node = current_node.get_parent()

	print("Target cannot be demolished")

# =============================================================================
# PLACEMENT ROTATION
# =============================================================================
# Rotates the active placement preview clockwise in 90-degree increments.
#
# Rotation cycles:
#   0 -> 90 -> 180 -> 270 -> 0

func _rotate_placement() -> void:
	placement_rotation_degrees += ROTATION_STEP_DEGREES

	if placement_rotation_degrees >= FULL_ROTATION_DEGREES:
		placement_rotation_degrees = 0.0

	if placement_ghost != null:
		placement_ghost.rotation_degrees.y = placement_rotation_degrees

	print(
		"Placement rotation: ",
		placement_rotation_degrees,
		" degrees"
	)


# =============================================================================
# OBJECT SELECTION RAYCAST
# =============================================================================
# Casts a ray from the mouse cursor into the 3D world.
#
# If the collider belongs to or exists underneath a node in the "selectable"
# group, that logical object becomes selected.
#
# Clicking non-selectable ground or empty space clears the current selection.

func _select_under_mouse() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# =============================================================================
	# INTERACTIVE OBJECT RAYCAST SETTINGS
	# =============================================================================

	# Detect selectable objects on physics Layer 2.
	# Include both StaticBody3D and Area3D hitboxes.

	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	if result:
		var hit_position: Vector3 = result["position"]
		var collider: Node = result["collider"]

		var current_node: Node = collider

		while current_node != null:
			if current_node.is_in_group("selectable"):
				_select_object(current_node)

				print(
					"Selected ",
					current_node.name,
					" at ",
					hit_position
				)

				return

			current_node = current_node.get_parent()

		_select_object(null)
		print("Hit ", collider.name, " at ", hit_position)

	else:
		_select_object(null)
		print("Hit nothing")


# =============================================================================
# OBJECT SELECTION STATE
# =============================================================================
# Changes the currently selected logical object.
#
# Selectable objects control their own visual feedback through the
# set_selected() method.

func _select_object(object: Node) -> void:
	if selected_object == object:
		return

	if selected_object != null:
		if selected_object.has_method("set_selected"):
			selected_object.call("set_selected", false)

	selected_object = object

	if selected_object != null:
		if selected_object.has_method("set_selected"):
			selected_object.call("set_selected", true)

		if production_debug_hud != null:
			production_debug_hud.set_selected_building(selected_object)
	else:
		if production_debug_hud != null:
			production_debug_hud.clear_selection()


# =============================================================================
# SELECT CONVEYOR PREVIEW SHAPE FROM MOUSE
# =============================================================================

# Finds the nearest placed conveyor with a free output.
#
# The mouse position determines whether to preview:
# - A straight conveyor
# - A right-turn corner
# - A left-turn corner
#
# This only selects a PackedScene.
# It never creates or connects a real conveyor.
#
# The 2-unit search radius is temporary and can be
# adjusted after we test the interaction in gameplay.

func _get_conveyor_preview_scene_for_mouse(
	mouse_world_position: Vector3
) -> PackedScene:

	var chosen_scene: PackedScene = (
		ConveyorPieceSelector.STRAIGHT_SCENE
	)

	var closest_distance_squared: float = 4.0

	# =============================================================================
	# SEARCH AVAILABLE CONVEYOR OUTPUTS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		var source: ConveyorSegment = node as ConveyorSegment

		if source.is_queued_for_deletion():
			continue

		# A completed connection cannot accept another
		# conveyor at the same output.

		if is_instance_valid(source.next_segment):
			continue

		var output: Marker3D = (
			source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		if not is_instance_valid(output):
			continue

		# =============================================================================
		# MEASURE HORIZONTAL MOUSE DISTANCE
		# =============================================================================

		var offset: Vector3 = (
			mouse_world_position - output.global_position
		)

		var distance_squared: float = (
			offset.x * offset.x
			+ offset.z * offset.z
		)

		if distance_squared >= closest_distance_squared:
			continue

		# =============================================================================
		# CLASSIFY CONSTRUCTION DIRECTION
		# =============================================================================

		var candidate_scene: PackedScene = (
			ConveyorPieceSelector.get_scene_for_mouse(
				source,
				mouse_world_position
			)
		)

		if candidate_scene == null:
			continue

		closest_distance_squared = distance_squared
		chosen_scene = candidate_scene

	# =============================================================================
	# RETURN SELECTED SHAPE
	# =============================================================================

	return chosen_scene

# =============================================================================
# PLACEMENT PREVIEW
# =============================================================================
# Projects the mouse onto Collision Layer 1 and snaps the resulting world
# position to the placement grid.
#
# The placement ghost:
#   - follows the snapped position
#   - turns green when placement is valid
#   - turns red when placement is blocked

func _update_placement_preview() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = GROUND_COLLISION_MASK

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	if result:
		var hit_position: Vector3 = result["position"]

		current_placement_position = Vector3(
			snappedf(hit_position.x, grid_size),
			hit_position.y,
			snappedf(hit_position.z, grid_size)
		)
		# =============================================================================
		# PRESERVE ORIGINAL MOUSE GRID POSITION
		# =============================================================================

		# Conveyor snapping may change the current
		# placement position during this frame.
		#
		# Compare competing snap targets against
		# the original cursor position instead.

		var mouse_grid_position: Vector3 = (
			current_placement_position
		)

		# =============================================================================
		# CHAT 08.3G — UNIFIED SMELTER GRID PLACEMENT
		# =============================================================================

		# Use the shared factory grid for our migrated Smelter.
		#
		# A 2x2 building uses a half-tile-centered origin.
		# Calculate from the ORIGINAL mouse hit position,
		# not the already-rounded integer grid position.
		#
		# Other buildings and conveyors keep their current
		# placement behavior until their own migration.

		if (
			is_instance_valid(placement_ghost)
			and not placement_ghost is ConveyorSegment
		):

			var grid_definition: BuildingDefinition = (
				_get_selected_building_definition()
			)

			if (
				grid_definition != null
				and grid_definition.building_id == &"test_smelter"
			):

				# Convert the selected 90-degree rotation
				# into a number of quarter turns.

				var quarter_turns: int = roundi(
					placement_rotation_degrees
					/ ROTATION_STEP_DEGREES
				)

				var world_footprint: Vector2i = (
					FactoryGrid.rotated_footprint(
						grid_definition.footprint_tiles,
						quarter_turns
					)
				)

				current_placement_position = (
					FactoryGrid.snap_building_origin(
						hit_position,
						world_footprint,
						grid_size
					)
				)

		# =============================================================================
		# CONVEYOR PLACEMENT — STRAIGHT GHOST
		# =============================================================================

		# The player always previews a straight conveyor.
		#
		# A previously placed straight conveyor may later
		# convert into a corner when the player places a
		# new perpendicular straight conveyor beside it.
		#
		# The conversion happens during permanent placement,
		# not during ghost preview selection.



		# =============================================================================
		# EXISTING PLACEMENT GHOST POSITIONING
		# =============================================================================

		if placement_ghost != null:

			# =============================================================================
			# RESET NORMAL GRID PREVIEW
			# =============================================================================

			# Start each frame with the ordinary grid position.
			# This prevents the ghost from remaining snapped
			# after the mouse moves away.

			conveyor_snap_source = null
			conveyor_snap_before = false
			conveyor_building_snap_port = null
			building_placement_snap_belt = null
			building_placement_snap_port = null
			conveyor_corner_snap_source = null
			conveyor_corner_snap_turn = ConveyorTurnIntent.Turn.STRAIGHT
			conveyor_bridge_source = null
			conveyor_bridge_destination = null
			placement_ghost.global_position = (
				current_placement_position
			)

			placement_ghost.rotation_degrees.y = (
				placement_rotation_degrees
			)

			# =============================================================================
			# SELECT ONE CONVEYOR SNAP TARGET — CHAT 08.3F
			# =============================================================================

			# Always begin with the original grid position and player rotation.
			# Resolve only one physical target per frame:
			#   1. Exact two-ended conveyor bridge (if one piece fits)
			#   2. Compatible, free building port
			#   3. Compatible existing conveyor endpoint
			#   4. Off-grid perpendicular turn preview
			#
			# Never use an already-snapped ghost position as the mouse
			# position for the next discovery pass. All connections
			# are still committed only during permanent placement.

			if (
				placement_ghost is ConveyorSegment
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):

				var ghost_belt: ConveyorSegment = (
					placement_ghost as ConveyorSegment
				)

				# =============================================================================
				# FIRST: EXACT TWO-ENDED BRIDGE
				# =============================================================================

				# Only select a bridge when ONE unchanged straight conveyor
				# aligns with two free endpoints and the requested rotation.

				if conveyor_preview_scene == ConveyorPieceSelector.STRAIGHT_SCENE:

					var bridge_preview: Dictionary = (
						ConveyorDualEndedBridge.find_nearest_preview(
							ghost_belt,
							mouse_grid_position,
							CONVEYOR_SNAP_SEARCH_RADIUS
						)
					)

					if not bridge_preview.is_empty():

						conveyor_bridge_source = (
							bridge_preview["source"] as ConveyorSegment
						)

						conveyor_bridge_destination = (
							bridge_preview["destination"] as ConveyorSegment
						)

						placement_ghost.global_transform = (
							bridge_preview["transform"]
						)

						current_placement_position = (
							placement_ghost.global_position
						)

				# =============================================================================
				# SECOND: BUILDING PORT — INDEPENDENT IN / OUT
				# =============================================================================

				var port_preview: Dictionary = (
					ConveyorBuildingPortFinder.find_nearest_preview(
						ghost_belt,
						mouse_grid_position,
						CONVEYOR_BUILDING_PORT_SEARCH_RADIUS
					)
				)

				if (
					not is_instance_valid(conveyor_bridge_source)
					and not port_preview.is_empty()
				):

					var port: ItemPortComponent = (
						port_preview["port"] as ItemPortComponent
					)

					if is_instance_valid(port):

						placement_ghost.global_transform = (
							port_preview["transform"]
						)

						conveyor_building_snap_port = port
						current_placement_position = (
							placement_ghost.global_position
						)

				# =============================================================================
				# THIRD: EXISTING CONVEYOR ENDPOINT
				# =============================================================================

				if (
					not is_instance_valid(conveyor_bridge_source)
					and not is_instance_valid(conveyor_building_snap_port)
				):

					var belt_preview: Dictionary = (
						_find_conveyor_snap_preview(
							mouse_grid_position
						)
					)

					if not belt_preview.is_empty():

						placement_ghost.global_transform = (
							belt_preview["transform"]
						)

						conveyor_snap_source = (
							belt_preview["source"] as ConveyorSegment
						)

						conveyor_snap_before = bool(
							belt_preview["before"]
						)

						current_placement_position = (
							placement_ghost.global_position
						)

					# =============================================================================
					# FOURTH: OFF-GRID CORNER PREVIEW
					# =============================================================================

					else:

						var corner_preview: Dictionary = (
							_find_offset_corner_snap_preview(
								mouse_grid_position
							)
						)

						if not corner_preview.is_empty():

							placement_ghost.global_transform = (
								corner_preview["transform"]
							)

							conveyor_corner_snap_source = (
								corner_preview["source"] as ConveyorSegment
							)

							conveyor_corner_snap_turn = int(
								corner_preview["turn"]
							)

							current_placement_position = (
								placement_ghost.global_position
							)

			# =============================================================================
			# BUILDING PLACEMENT SNAP TO EXISTING CONVEYOR
			# =============================================================================

			# Only regular building ghosts use this path.
			#
			# Conveyor ghosts continue using their existing
			# conveyor-to-conveyor and building-port snapping.
			#
			# The existing helper discovers compatible ports,
			# checks occupied endpoints, and preserves the
			# player's selected building rotation.

			if not placement_ghost is ConveyorSegment:

				var building_preview: Dictionary = (
					ConveyorBuildingPlacementSnap.find_nearest_preview(
						placement_ghost,
						current_placement_position,
						1.5
					)
				)

				if not building_preview.is_empty():

					var target_belt: ConveyorSegment = (
						building_preview["belt"]
						as ConveyorSegment
					)

					var target_port: ItemPortComponent = (
						building_preview["port"]
						as ItemPortComponent
					)

					if (
						is_instance_valid(target_belt)
						and is_instance_valid(target_port)
					):

						# Apply the exact preview transform.
						# This also supports fractional positions.

						placement_ghost.global_transform = (
							building_preview["transform"]
						)

						building_placement_snap_belt = target_belt
						building_placement_snap_port = target_port

						current_placement_position = (
							placement_ghost.global_position
						)

			# =============================================================================
			# EXISTING PLACEMENT COLLISION VALIDATION
			# =============================================================================

			placement_is_valid = _is_placement_clear()


		if placement_is_valid and placement_ghost != null:
			var extractor_component: ExtractorComponent = (
				placement_ghost.get_node_or_null("ExtractorComponent")
				as ExtractorComponent
			)

			if extractor_component != null:
				placement_is_valid = _extractor_has_resource_node()

	if ghost_material != null:
		if placement_is_valid:
				ghost_material.albedo_color = Color(
					valid_placement_color.r,
					valid_placement_color.g,
					valid_placement_color.b,
					PLACEMENT_GHOST_ALPHA
			)
		else:
			ghost_material.albedo_color = Color(
				invalid_placement_color.r,
				invalid_placement_color.g,
				invalid_placement_color.b,
				PLACEMENT_GHOST_ALPHA
			)

	else:
		placement_is_valid = false


# =============================================================================
# FIND NEARBY CONVEYOR SNAP PREVIEW
# =============================================================================

# Searches for available conveyor inputs AND outputs.
#
# Supports:
# - Placing a conveyor AFTER an existing output.
# - Placing a conveyor BEFORE an existing input.
#
# Chooses the nearest valid position to the mouse.
#
# This function only calculates preview transforms.
# It never establishes permanent connections.

func _find_conveyor_snap_preview(
	grid_position: Vector3
) -> Dictionary:

	if not placement_ghost is ConveyorSegment:
		return {}

	var ghost_belt: ConveyorSegment = (
		placement_ghost as ConveyorSegment
	)

	# =============================================================================
	# PRESERVE PLAYER-SELECTED CONVEYOR DIRECTION
	# =============================================================================

	# Record the actual direction selected with R.
	# Snapping must not silently override this rotation.

	var requested_forward: Vector3 = (
		ghost_belt.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	var best_preview: Dictionary = {}
	var best_distance: float = CONVEYOR_SNAP_SEARCH_RADIUS

	# =============================================================================
	# SEARCH EXISTING CONVEYORS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if node == placement_ghost:
			continue

		if not node is ConveyorSegment:
			continue

		var source: ConveyorSegment = node as ConveyorSegment

		if source.is_queued_for_deletion():
			continue

		# =============================================================================
		# OPTION A — SNAP AFTER AN EXISTING CONVEYOR
		# =============================================================================

		var after_preview: Dictionary = (
			ghost_belt.get_snap_preview_transform_after(source)
		)

		# =============================================================================
		# REJECT SNAP THAT OVERRIDES SELECTED ROTATION
		# =============================================================================

		if not after_preview.is_empty():

			var proposed_after: Transform3D = (
				after_preview["transform"]
			)

			var after_forward: Vector3 = (
				proposed_after.basis * Vector3.FORWARD
			).normalized()

			if requested_forward.dot(after_forward) < 0.98:
				after_preview.clear()

		if not after_preview.is_empty():

			var after_transform: Transform3D = (
				after_preview["transform"]
			)

			var after_position: Vector3 = (
				after_transform.origin
			)

			var after_distance: float = Vector2(
				grid_position.x - after_position.x,
				grid_position.z - after_position.z
			).length()

			if after_distance < best_distance:

				best_distance = after_distance

				best_preview = {
					"source": source,
					"transform": after_transform,
					"before": false
				}

		# =============================================================================
		# OPTION B — SNAP BEFORE AN EXISTING CONVEYOR
		# =============================================================================

		var before_preview: Dictionary = (
			ghost_belt.get_snap_preview_transform_before(source)
		)

		# =============================================================================
		# PRESERVE SELECTED ROTATION FOR SNAP-BEFORE
		# =============================================================================

		if not before_preview.is_empty():

			var proposed_before: Transform3D = (
				before_preview["transform"]
			)

			var before_forward: Vector3 = (
				proposed_before.basis * Vector3.FORWARD
			).normalized()

			if requested_forward.dot(before_forward) < 0.98:
				before_preview.clear()

		if not before_preview.is_empty():

			var before_transform: Transform3D = (
				before_preview["transform"]
			)

			var before_position: Vector3 = (
				before_transform.origin
			)

			var before_distance: float = Vector2(
				grid_position.x - before_position.x,
				grid_position.z - before_position.z
			).length()

			if before_distance < best_distance:

				best_distance = before_distance

				best_preview = {
					"source": source,
					"transform": before_transform,
					"before": true
				}

	# =============================================================================
	# RETURN NEAREST VALID SNAP CANDIDATE
	# =============================================================================

	return best_preview


# =============================================================================
# PLACEMENT VALIDITY CHECK
# =============================================================================

# Checks the placement ghost's physical building collision shapes against
# objects on Collision Layer 3.
#
# Because each query uses the ghost collision shape's global transform,
# the validity test automatically respects:
#   - building size
#   - building footprint
#   - placement rotation


func _is_placement_clear() -> bool:

	# =============================================================================
	# VALIDATE PLACEMENT FOOTPRINT
	# =============================================================================

	if placement_ghost_collisions.is_empty():
		return false

	# =============================================================================
	# VALIDATE INTENDED CONVEYOR CONNECTION
	# =============================================================================

	# A conveyor being snapped may register a collision
	# with its intended neighbor due to contact tolerances.
	#
	# We may exclude that ONE neighbor from the placement
	# query, but only when the endpoints align correctly.
	#
	# Other buildings and conveyors must still block placement.

	var snap_exclusions: Array[RID] = []

	# =============================================================================
	# VERIFY BOTH INTENDED NEIGHBORS OF A TWO-ENDED BRIDGE
	# =============================================================================

	if (
		is_instance_valid(conveyor_bridge_source)
		and is_instance_valid(conveyor_bridge_destination)
	):

		if not placement_ghost is ConveyorSegment:
			return false

		var bridge_ghost: ConveyorSegment = (
			placement_ghost as ConveyorSegment
		)

		var verified_bridge: Dictionary = (
			ConveyorDualEndedBridge.get_preview_transform(
				conveyor_bridge_source,
				bridge_ghost,
				conveyor_bridge_destination
			)
		)

		if verified_bridge.is_empty():
			return false

		var expected_bridge: Transform3D = (
			verified_bridge["transform"]
		)

		if not bridge_ghost.global_transform.is_equal_approx(
			expected_bridge
		):
			return false

		# Connection helpers require exact directed endpoint geometry.
		# Exclude ONLY these two physical neighbors, and only after
		# both pairs have been independently revalidated.

		var source_output: Marker3D = (
			conveyor_bridge_source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		var bridge_input: Marker3D = (
			bridge_ghost.get_node_or_null("InputEndpoint")
			as Marker3D
		)

		var bridge_output: Marker3D = (
			bridge_ghost.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		var destination_input: Marker3D = (
			conveyor_bridge_destination.get_node_or_null("InputEndpoint")
			as Marker3D
		)

		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			source_output,
			bridge_input,
			ConveyorSegment.CONNECTION_GAP
		):
			return false

		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			bridge_output,
			destination_input,
			ConveyorSegment.CONNECTION_GAP
		):
			return false

		for neighbor: ConveyorSegment in [
			conveyor_bridge_source,
			conveyor_bridge_destination
		]:

			var neighbor_body: PhysicsBody3D = (
				neighbor.get_node_or_null("ConveyorBody")
				as PhysicsBody3D
			)

			if not is_instance_valid(neighbor_body):
				return false

			snap_exclusions.append(neighbor_body.get_rid())

	if (
		placement_ghost is ConveyorSegment
		and is_instance_valid(conveyor_snap_source)
	):

		var outgoing: Marker3D = null
		var incoming: Marker3D = null

		# Determine the directed connection.

		if conveyor_snap_before:

			# New belt output -> Existing belt input.

			outgoing = (
				placement_ghost.get_node_or_null("OutputEndpoint")
				as Marker3D
			)

			incoming = (
				conveyor_snap_source.get_node_or_null("InputEndpoint")
				as Marker3D
			)

		else:

			# Existing belt output -> New belt input.

			outgoing = (
				conveyor_snap_source.get_node_or_null("OutputEndpoint")
				as Marker3D
			)

			incoming = (
				placement_ghost.get_node_or_null("InputEndpoint")
				as Marker3D
			)

		# Only allow an exclusion if connection geometry
		# meets our strict established-link tolerance.

		if LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing,
			incoming,
			ConveyorSegment.CONNECTION_GAP
		):

			var neighbor_body: PhysicsBody3D = (
				conveyor_snap_source.get_node_or_null("ConveyorBody")
				as PhysicsBody3D
			)

			if is_instance_valid(neighbor_body):
				snap_exclusions.append(
					neighbor_body.get_rid()
				)

	# =============================================================================
	# CHECK PLACEMENT COLLISIONS
	# =============================================================================

	for collision_shape: CollisionShape3D in placement_ghost_collisions:

		if collision_shape.shape == null:
			continue

		var query := PhysicsShapeQueryParameters3D.new()

		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform
		query.collision_mask = PLACEMENT_BLOCKER_COLLISION_MASK

		# Ignore only a confirmed connection neighbor.
		# All unrelated obstacles remain detectable.

		query.exclude = snap_exclusions

		var results: Array[Dictionary] = (
			get_viewport().world_3d.direct_space_state.intersect_shape(
				query,
				1
			)
		)

		if not results.is_empty():
			return false

	# =============================================================================
	# PLACEMENT IS CLEAR
	# =============================================================================

	return true


# =============================================================================
# EXTRACTOR RESOURCE CHECK
# =============================================================================

# Returns true when the current extractor placement ghost can reach
# at least one valid resource node through its ExtractionArea.

func _extractor_has_resource_node() -> bool:
	if placement_ghost == null:
		return false

	var extractor_component: ExtractorComponent = (
		placement_ghost.get_node_or_null("ExtractorComponent")
		as ExtractorComponent
	)

	if extractor_component == null:
		return false

	if extractor_component.extraction_area == null:
		return false

	for child in extractor_component.extraction_area.find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	):
		if not child is CollisionShape3D:
			continue

		var collision_shape: CollisionShape3D = child as CollisionShape3D

		if collision_shape.shape == null:
			continue

		var query := PhysicsShapeQueryParameters3D.new()

		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform
		query.collision_mask = RESOURCE_NODE_COLLISION_MASK

		var results: Array[Dictionary] = (
			get_viewport().world_3d.direct_space_state.intersect_shape(
				query,
				32
			)
		)

		for result in results:
			var collider: Node = result["collider"] as Node

			if collider == null:
				continue

			var current_node: Node = collider

			while current_node != null:
				var resource_runtime: ResourceNodeRuntime = (
					current_node.get_node_or_null("ResourceNodeRuntime")
					as ResourceNodeRuntime
				)

				if resource_runtime != null:
					return true

				current_node = current_node.get_parent()

	return false

# =============================================================================
# FIND BUILDING-OFFSET CONVEYOR CORNER SNAP
# =============================================================================

# Searches for a conveyor with a free output that is
# positioned off-grid because of building-port snapping.
#
# The receiver is our current placement ghost.
#
# Only calculates positions. Does not change connections.


func _find_offset_corner_snap_preview(
	mouse_grid_position: Vector3
) -> Dictionary:

	# =============================================================================
	# VALIDATE CONVEYOR GHOST
	# =============================================================================

	if not placement_ghost is ConveyorSegment:
		return {}

	var receiver: ConveyorSegment = (
		placement_ghost as ConveyorSegment
	)

	var best_preview: Dictionary = {}

	var closest_distance_squared: float = (
		CONVEYOR_SNAP_SEARCH_RADIUS
		* CONVEYOR_SNAP_SEARCH_RADIUS
	)

	# =============================================================================
	# SEARCH EXISTING CONVEYORS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		if node == placement_ghost:
			continue

		var source: ConveyorSegment = (
			node as ConveyorSegment
		)

		if source.is_queued_for_deletion():
			continue

		# An occupied output cannot create another route.

		if is_instance_valid(source.next_segment):
			continue

		if is_instance_valid(source.output_building_port):
			continue

		# =============================================================================
		# RESTRICT TO OFF-GRID CONVEYORS
		# =============================================================================

		# Normal grid-aligned conveyors already have
		# working corner placement logic.
		#
		# Preserve that behavior unchanged.

		var off_grid_x: bool = absf(
			source.global_position.x
			- snappedf(source.global_position.x, grid_size)
		) > 0.05

		var off_grid_z: bool = absf(
			source.global_position.z
			- snappedf(source.global_position.z, grid_size)
		) > 0.05

		if not off_grid_x and not off_grid_z:
			continue

		# =============================================================================
		# CHECK BOTH TURN DIRECTIONS
		# =============================================================================

		for turn_type: int in [
			ConveyorTurnIntent.Turn.RIGHT,
			ConveyorTurnIntent.Turn.LEFT
		]:

			var preview: Dictionary = (
				ConveyorCornerPlacementSnap.get_preview_transform(
					source,
					receiver,
					turn_type
				)
			)

			if preview.is_empty():
				continue

			var proposed: Transform3D = (
				preview["transform"]
			)

			# =============================================================================
			# MEASURE DISTANCE TO MOUSE
			# =============================================================================

			var offset := Vector2(
				mouse_grid_position.x - proposed.origin.x,
				mouse_grid_position.z - proposed.origin.z
			)

			var distance_squared: float = (
				offset.length_squared()
			)

			if distance_squared >= closest_distance_squared:
				continue

			# =============================================================================
			# STORE NEAREST VALID CORNER
			# =============================================================================

			closest_distance_squared = distance_squared

			best_preview = {
				"source": source,
				"turn": turn_type,
				"transform": proposed
			}

	return best_preview

# =============================================================================
# FIND PERPENDICULAR CONVEYOR TURN CANDIDATE
# =============================================================================

# Finds an existing straight conveyor whose free output
# can turn into a newly placed perpendicular straight.
#
# Requirements:
# - Both conveyors occupy neighboring grid cells.
# - The new conveyor faces right or left relative to source.
# - The existing conveyor has no outgoing connection.
# - The existing conveyor has not already become a corner.
#
# This function does not modify or connect anything.
# It returns an empty Dictionary when no match exists.

func _find_perpendicular_corner_candidate(
	placed_straight: ConveyorSegment
) -> Dictionary:

	if not is_instance_valid(placed_straight):
		return {}

	var receiver_output: Marker3D = (
		placed_straight.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	if receiver_output == null:
		return {}

	# The new piece must be an ordinary straight belt.

	if not receiver_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	# =============================================================================
	# SEARCH EXISTING PLAYER CONVEYORS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		if node == placed_straight or node == placement_ghost:
			continue

		var source: ConveyorSegment = node as ConveyorSegment

		if source.is_queued_for_deletion():
			continue

		if is_instance_valid(source.next_segment):
			continue

		var source_output: Marker3D = (
			source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		if source_output == null:
			continue

		# Only an existing straight may be converted.

		if not source_output.position.is_equal_approx(
			Vector3(0.0, 0.5, -0.5)
		):
			continue

		# =============================================================================
		# CHECK NEIGHBORING GRID POSITION
		# =============================================================================

		# Convert the new belt's world position into
		# the existing belt's local coordinate system.
		#
		# This makes the check work with rotated factories.

		var local_offset: Vector3 = (
			source.global_transform.affine_inverse()
			* placed_straight.global_position
		)

		# Both pieces must occupy the same ground level
		# and the same local Z row.

		if absf(local_offset.y) > 0.1:
			continue

		if absf(local_offset.z) > 0.1:
			continue

		# =============================================================================
		# DETERMINE LEFT OR RIGHT TURN
		# =============================================================================

		var turn: int = -1
		var expected_direction: Vector3 = Vector3.ZERO

		var source_right: Vector3 = (
			source.global_transform.basis.x.normalized()
		)

		if absf(local_offset.x - 1.0) < 0.1:
			turn = ConveyorTurnIntent.Turn.RIGHT
			expected_direction = source_right

		elif absf(local_offset.x + 1.0) < 0.1:
			turn = ConveyorTurnIntent.Turn.LEFT
			expected_direction = -source_right

		else:
			continue

		# =============================================================================
		# VERIFY NEW BELT FACING
		# =============================================================================

		# A neighboring belt is not automatically a turn.
		# The player must rotate it to face away from
		# the preceding conveyor in the correct direction.

		var receiver_forward: Vector3 = (
			-receiver_output.global_transform.basis.z
		).normalized()

		if receiver_forward.dot(expected_direction) < 0.98:
			continue

		# =============================================================================
		# VALID CORNER CANDIDATE
		# =============================================================================

		return {
			"source": source,
			"turn": turn
		}

	return {}


# =============================================================================
# OBJECT PLACEMENT
# =============================================================================
# Instantiates the currently selected PackedScene at the current snapped
# placement position.
#
# Placement is refused when:
#   - the current footprint is blocked
#   - no valid buildable scene is selected


func _try_place_object() -> void:
	
	# =============================================================================
	# MANUAL CONVEYOR PLACEMENT — SHIFT OVERRIDE
	# =============================================================================

	# Refresh snap state before the click is processed.
	# This prevents a previous automatic snap from
	# being committed after Shift is pressed.

	if (
		selected_building_index == 4
		and Input.is_physical_key_pressed(KEY_SHIFT)
	):
		_update_placement_preview()

	# =============================================================================
	# SNAP TARGET — CLICK DIAGNOSTIC
	# =============================================================================

	# One concise message makes it clear whether the
	# new object will be physically connected or placed freely.

	if selected_building_index == 4 and placement_ghost is ConveyorSegment:

		if (
			is_instance_valid(conveyor_bridge_source)
			and is_instance_valid(conveyor_bridge_destination)
		):

			print(
				"SNAP TARGET | Two-ended bridge: ",
				conveyor_bridge_source.name,
				" -> NEW -> ",
				conveyor_bridge_destination.name
			)

		elif is_instance_valid(conveyor_building_snap_port):

			print(
				"SNAP TARGET | Building: ",
				conveyor_building_snap_port.get_parent().name,
				" / ", conveyor_building_snap_port.name
			)

		elif is_instance_valid(conveyor_snap_source):

			print(
				"SNAP TARGET | Conveyor: ",
				conveyor_snap_source.name,
				" | Before: ", conveyor_snap_before
			)

		elif is_instance_valid(conveyor_corner_snap_source):

			print("SNAP TARGET | Off-grid corner preview")

		else:

			print("SNAP TARGET | Free grid placement")

	# =============================================================================
	# CORNER PLACEMENT SAFETY CHECK
	# =============================================================================

	# A conveyor corner must connect to the available
	# output of an existing conveyor.
	#
	# Straight conveyors retain their normal placement rules.

	if (
		selected_building_index == 4
		and conveyor_preview_scene != null
		and conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
	):

		# Corners cannot be placed freely or connected
		# before an existing conveyor during this step.

		if (
			not is_instance_valid(conveyor_snap_source)
			or conveyor_snap_before
		):
			print(
				"Corner placement blocked: "
				+ "A free conveyor output is required."
			)
			return

	# =============================================================================
	# VALIDATE PLACEMENT
	# =============================================================================

	if not placement_is_valid:
		print("Placement blocked")
		return

	var selected_scene: PackedScene = _get_selected_building_scene()

	if selected_scene == null:
		print("No buildable scene selected")
		return

	
	# =============================================================================
	# PERMANENT TWO-ENDED CONVEYOR BRIDGE PLACEMENT
	# =============================================================================

	# A new straight conveyor must fill the EXACT free gap between
	# two real existing belts. No endpoint stretching, no extra belt,
	# and no partial route left behind if either connection fails.

	if (
		is_instance_valid(conveyor_bridge_source)
		or is_instance_valid(conveyor_bridge_destination)
	):

		if (
			not placement_ghost is ConveyorSegment
			or selected_building_index != 4
			or conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
			or not is_instance_valid(conveyor_bridge_source)
			or not is_instance_valid(conveyor_bridge_destination)
			or is_instance_valid(conveyor_building_snap_port)
			or is_instance_valid(conveyor_snap_source)
			or is_instance_valid(conveyor_corner_snap_source)
		):
			print("Bridge placement failed: Invalid snap state.")
			return

		# Recheck collision and both endpoint occupancies on click.
		# This prevents a stale green ghost from committing a bridge.

		if not _is_placement_clear():
			print("Bridge placement blocked: Geometry or collision changed.")
			return

		var bridge_check: Dictionary = (
			ConveyorDualEndedBridge.get_preview_transform(
				conveyor_bridge_source,
				placement_ghost as ConveyorSegment,
				conveyor_bridge_destination
			)
		)

		if bridge_check.is_empty():
			print("Bridge placement failed: Endpoints unavailable.")
			return

		var bridge_transform: Transform3D = (
			bridge_check["transform"]
		)

		if not placement_ghost.global_transform.is_equal_approx(
			bridge_transform
		):
			print("Bridge placement failed: Preview moved.")
			return

		var bridge_instance: Node = (
			ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		)

		if not bridge_instance is ConveyorSegment:
			if is_instance_valid(bridge_instance):
				bridge_instance.free()
			print("Bridge placement failed: Invalid conveyor scene.")
			return

		var placed_bridge: ConveyorSegment = (
			bridge_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(placed_bridge)
		placed_bridge.global_transform = bridge_transform

		var bridge_connected: bool = (
			ConveyorDualEndedBridge.try_connect(
				conveyor_bridge_source,
				placed_bridge,
				conveyor_bridge_destination
			)
		)

		if not bridge_connected:
			placed_bridge.queue_free()
			print("Bridge placement failed: Connections rejected.")
			return

		print(
			"TWO-ENDED BRIDGE CONNECTED | Source: ",
			conveyor_bridge_source.name,
			" | Bridge: ", placed_bridge.name,
			" | Destination: ", conveyor_bridge_destination.name,
			" | Position: ", placed_bridge.global_position
		)

		# Both links are now physically connected.
		# Never continue into normal placement on the same click.

		return

	# =============================================================================
	# PERMANENT BUILDING-TO-CONVEYOR PLACEMENT
	# =============================================================================

	# Places a building directly against an existing
	# conveyor's available physical endpoint.
	#
	# Supports:
	# - Conveyor OUTPUT -> Building INPUT
	# - Building OUTPUT -> Conveyor INPUT
	# - Rotated buildings
	# - Fractional world positions
	# - Recipe-controlled and universal inventories
	#
	# The normal placement collision check has
	# already completed before reaching this section.

	if (
		is_instance_valid(building_placement_snap_belt)
		and is_instance_valid(building_placement_snap_port)
	):

		# =============================================================================
		# VALIDATE EXISTING CONVEYOR AND BUILDING GHOST
		# =============================================================================

		if not is_instance_valid(placement_ghost):
			print("Building placement failed: Missing ghost.")
			return

		if placement_ghost is ConveyorSegment:
			print("Building placement failed: Invalid building.")
			return

		if (
			not building_placement_snap_belt.is_inside_tree()
			or building_placement_snap_belt.is_queued_for_deletion()
		):
			print("Building placement failed: Conveyor unavailable.")
			return

		# =============================================================================
		# IDENTIFY PREVIEW PORT
		# =============================================================================

		# The selected port belongs to the ghost.
		# The permanent building must use its own port,
		# never the temporary ghost component.

		if not placement_ghost.is_ancestor_of(
			building_placement_snap_port
		):
			print("Building placement failed: Invalid port.")
			return

		var port_path: NodePath = (
			placement_ghost.get_path_to(
				building_placement_snap_port
			)
		)

		# =============================================================================
		# CREATE PERMANENT BUILDING
		# =============================================================================

		var building_instance: Node = (
			selected_scene.instantiate()
		)

		if not building_instance is Node3D:

			if is_instance_valid(building_instance):
				building_instance.free()

			print("Building placement failed: Invalid scene.")
			return

		var placed_building: Node3D = (
			building_instance as Node3D
		)

		get_tree().current_scene.add_child(
			placed_building
		)

		# =============================================================================
		# APPLY EXACT PREVIEW TRANSFORM
		# =============================================================================

		# Do not round to the integer grid.
		# Preserve the port alignment and rotation.

		placed_building.global_transform = (
			placement_ghost.global_transform
		)

		# =============================================================================
		# INITIALIZE BUILDING DEFINITION
		# =============================================================================

		var definition: BuildingDefinition = (
			_get_selected_building_definition()
		)

		var runtime: BuildingRuntime = (
			placed_building.get_node_or_null(
				"BuildingRuntime"
			) as BuildingRuntime
		)

		if runtime != null and definition != null:
			runtime.initialize(definition)

		# =============================================================================
		# FIND ACTUAL BUILDING PORT
		# =============================================================================

		var actual_port: ItemPortComponent = (
			placed_building.get_node_or_null(
				port_path
			) as ItemPortComponent
		)

		if not is_instance_valid(actual_port):

			placed_building.queue_free()

			print(
				"Building placement failed: "
				+ "Permanent port not found."
			)

			return

		# =============================================================================
		# ESTABLISH PHYSICAL CONNECTION
		# =============================================================================

		# The existing connection method validates:
		# - Correct input/output direction
		# - Free conveyor endpoint
		# - Free building port
		# - Physical endpoint alignment
		# - Compatible inventory configuration

		var connected: bool = (
			building_placement_snap_belt.try_connect_building_port(
				actual_port
			)
		)

		# =============================================================================
		# HANDLE CONNECTION FAILURE
		# =============================================================================

		if not connected:

			# Never leave a building that appears
			# connected but has no physical connection.

			placed_building.queue_free()

			print(
				"Building placement failed: "
				+ "Physical connection rejected."
			)

			return

		# =============================================================================
		# CONFIRM CONNECTION
		# =============================================================================

		print(
			"BUILDING CONNECTED SUCCESSFULLY | Building: ",
			placed_building.name,
			" | Port: ",
			actual_port.name,
			" | Conveyor: ",
			building_placement_snap_belt.name,
			" | Position: ",
			placed_building.global_position
		)

		# =============================================================================
		# PREVENT DUPLICATE PLACEMENT
		# =============================================================================

		# The building and its physical connection
		# have both been created successfully.
		#
		# Do not execute normal placement afterward.

		building_placement_snap_belt = null
		building_placement_snap_port = null

		return


	# =============================================================================
	# PERMANENT BUILDING-OFFSET CONVEYOR CORNER PLACEMENT
	# =============================================================================

	# The snap preview uses the next straight conveyor's
	# exact transform and a free output on an existing straight.
	#
	# When placed, the existing straight is converted IN PLACE
	# into the required left/right corner. This preserves:
	# - incoming building port and conveyor connections
	# - the original conveyor node and cargo inventory
	# - generic item transport, selection and demolition
	#
	# The new conveyor stays a straight segment. Never create
	# an unconnected conveyor if preview revalidation fails.

	if is_instance_valid(conveyor_corner_snap_source):

		# =============================================================================
		# VALIDATE SNAP STATE AND REQUIRED STRAIGHT PREVIEW
		# =============================================================================

		if not placement_ghost is ConveyorSegment:
			print("Off-grid corner failed: Invalid conveyor ghost.")
			return

		if (
			selected_building_index != 4
			or conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
			or is_instance_valid(conveyor_snap_source)
			or is_instance_valid(conveyor_building_snap_port)
		):
			print("Off-grid corner failed: Conflicting snap state.")
			return

		var corner_source: ConveyorSegment = (
			conveyor_corner_snap_source
		)

		if (
			not corner_source.is_inside_tree()
			or corner_source.is_queued_for_deletion()
			or not corner_source.is_in_group("player_built")
		):
			print("Off-grid corner failed: Source unavailable.")
			return

		# =============================================================================
		# RECHECK PREVIEW GEOMETRY AND ENDPOINT AVAILABILITY
		# =============================================================================

		# An adjacent placement or demolition may have changed
		# the source since the last visual preview frame.
		# Recalculate before creating the permanent conveyor.

		var corner_check: Dictionary = (
			ConveyorCornerPlacementSnap.get_preview_transform(
				corner_source,
				placement_ghost as ConveyorSegment,
				conveyor_corner_snap_turn
			)
		)

		if corner_check.is_empty():
			print("Off-grid corner failed: Connection no longer available.")
			return

		var checked_transform: Transform3D = (
			corner_check["transform"]
		)

		if not placement_ghost.global_transform.is_equal_approx(
			checked_transform
		):
			print("Off-grid corner failed: Preview alignment changed.")
			return

		# =============================================================================
		# INSTANTIATE EXACTLY ONE NEW STRAIGHT CONVEYOR
		# =============================================================================

		var corner_instance: Node = (
			ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		)

		if not corner_instance is ConveyorSegment:
			if is_instance_valid(corner_instance):
				corner_instance.free()
			print("Off-grid corner failed: Invalid straight scene.")
			return

		var corner_receiver: ConveyorSegment = (
			corner_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(corner_receiver)

		# Preserve the off-grid transform from the approved ghost.
		corner_receiver.global_transform = checked_transform

		# =============================================================================
		# COMMIT IN-PLACE CORNER CONVERSION AND PHYSICAL LINK
		# =============================================================================

		var corner_connected: bool = (
			ConveyorCornerConversion.try_convert_and_connect(
				corner_source,
				corner_receiver,
				conveyor_corner_snap_turn
			)
		)

		if not corner_connected:
			# Conversion restores its old output when link fails.
			# No disconnected receiver should remain in the scene.
			corner_receiver.queue_free()
			print("Off-grid corner failed: Connection rejected.")
			return

		# =============================================================================
		# CONFIRM SUCCESS — DO NOT RUN NORMAL PLACEMENT
		# =============================================================================

		print(
			"OFF-GRID CORNER CONNECTED | Turn: ",
			"RIGHT" if conveyor_corner_snap_turn == ConveyorTurnIntent.Turn.RIGHT else "LEFT",
			" | Source: ", corner_source.name,
			" | New belt: ", corner_receiver.name,
			" | Position: ", corner_receiver.global_position
		)

		return

	# =============================================================================
	# USE ACTIVE CONVEYOR SHAPE FOR PLACEMENT
	# =============================================================================

	# The placement ghost has already selected the
	# appropriate conveyor shape:
	#
	# - Straight
	# - Right 90-degree corner
	# - Left 90-degree corner
	#
	# Use the same scene for the permanent object.
	#
	# Other building types retain their normal scene.

	if (
		selected_building_index == 4
		and placement_ghost is ConveyorSegment
		and conveyor_preview_scene != null
	):
		selected_scene = conveyor_preview_scene

	
	# =============================================================================
	# PERMANENT BUILDING-TO-CONVEYOR SNAP PLACEMENT
	# =============================================================================

	# Create a physical conveyor connection when the
	# placement ghost is snapped to a valid building port.
	#
	# Supports:
	# - Extractor OUTPUT -> Conveyor INPUT
	# - Conveyor OUTPUT -> Smelter INPUT
	# - Rotated buildings
	# - Generic item transportation
	#
	# Existing collision validation happens earlier
	# in _try_place_object().
	#
	# Do not create duplicate conveyors or bypass
	# the existing belt-to-belt snapping system.

	if is_instance_valid(conveyor_building_snap_port):

		# =============================================================================
		# VALIDATE BUILDING SNAP PREVIEW
		# =============================================================================

		if not placement_ghost is ConveyorSegment:
			print("Building connection failed: Invalid ghost.")
			return

		if (
			not conveyor_building_snap_port.is_inside_tree()
			or conveyor_building_snap_port.is_queued_for_deletion()
		):
			print("Building connection failed: Port unavailable.")
			return

		# =============================================================================
		# CREATE PERMANENT CONVEYOR
		# =============================================================================

		var building_snap_instance: Node = (
			selected_scene.instantiate()
		)

		if not building_snap_instance is ConveyorSegment:

			if is_instance_valid(building_snap_instance):
				building_snap_instance.free()

			print("Building connection failed: Invalid scene.")
			return

		var building_snap_belt: ConveyorSegment = (
			building_snap_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(
			building_snap_belt
		)

		# =============================================================================
		# APPLY EXACT PREVIEW TRANSFORM
		# =============================================================================

		# Use the placement ghost's world transform.
		# This preserves its rotation and port alignment.

		building_snap_belt.global_transform = (
			placement_ghost.global_transform
		)

		# =============================================================================
		# ESTABLISH PHYSICAL BUILDING CONNECTION
		# =============================================================================

		# The existing connection component validates:
		# - Port direction
		# - Port availability
		# - Reciprocal connection state
		# - Endpoint geometry
		# - Inventory configuration

		var building_connected: bool = (
			building_snap_belt.try_connect_building_port(
				conveyor_building_snap_port
			)
		)

		# =============================================================================
		# HANDLE FAILED CONNECTION
		# =============================================================================

		if not building_connected:

			# Remove the new conveyor if the physical
			# connection cannot be established.

			building_snap_belt.queue_free()

			print(
				"Building connection failed: "
				+ "Physical connection rejected."
			)

			return

		# =============================================================================
		# CONFIRM SUCCESSFUL CONNECTION
		# =============================================================================

		print(
			"BUILDING PORT CONNECTED | Port: ",
			conveyor_building_snap_port.name,
			" | Conveyor: ",
			building_snap_belt.name,
			" | Position: ",
			building_snap_belt.global_position
		)

		# The connection is complete.
		# Do not run normal building placement,
		# which would create a second conveyor.

		return


	# =============================================================================
	# PERMANENT CONVEYOR SNAP PLACEMENT
	# =============================================================================

	# Handle snapped conveyors BEFORE normal building placement.
	#
	# This prevents creating two objects during one click.
	#
	# A successful snap creates one conveyor and connects it
	# to an existing conveyor.

	if is_instance_valid(conveyor_snap_source):

		# =============================================================================
		# VALIDATE CONVEYOR PREVIEW
		# =============================================================================

		if not placement_ghost is ConveyorSegment:
			print("Conveyor placement failed: Invalid preview.")
			return

		# =============================================================================
		# CREATE NEW CONVEYOR
		# =============================================================================

		var new_instance: Node = selected_scene.instantiate()

		if not new_instance is ConveyorSegment:
			new_instance.free()
			print("Conveyor placement failed: Invalid scene.")
			return

		var new_belt: ConveyorSegment = (
			new_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(new_belt)

		# Apply the exact snapped preview transform.
		# This preserves both position and rotation.

		new_belt.global_transform = (
			placement_ghost.global_transform
		)

		# =============================================================================
		# ESTABLISH CONVEYOR CONNECTION
		# =============================================================================

		var connection_successful: bool = false

		if conveyor_snap_before:

			# New conveyor feeds an existing conveyor.

			connection_successful = (
				new_belt.try_connect_to(conveyor_snap_source)
			)

		else:

			# Existing conveyor feeds the new conveyor.

			connection_successful = (
				conveyor_snap_source.try_connect_to(new_belt)
			)

		# =============================================================================
		# FAILED CONNECTION — REMOVE TEMPORARY BELT
		# =============================================================================

		if not connection_successful:
			new_belt.queue_free()
			print("Conveyor placement failed: Connection rejected.")
			return

		# =============================================================================
		# SUCCESSFUL CONVEYOR PLACEMENT
		# =============================================================================

		print(
			"Conveyor connected successfully | Before: ",
			conveyor_snap_before,
			" | Position: ",
			new_belt.global_position
		)

		# =============================================================================
		# CONFIRM PERMANENT CONVEYOR SCENE
		# =============================================================================

		# Print the original scene path rather than the automatically
		# generated node name.

		print("CONVEYOR PLACED | Scene: ", selected_scene.resource_path)

		# Important: stop here.
		# Normal building placement must not run afterward.

		return

	# =============================================================================
	# NORMAL BUILDING PLACEMENT
	# =============================================================================

	# This section handles regular buildings and standalone
	# conveyors that are not snapped to another belt.
	#
	# Keep existing BuildingDefinition functionality.

	var new_object: Node = selected_scene.instantiate()

	get_tree().current_scene.add_child(new_object)

	# =============================================================================
	# INITIALIZE BUILDING DEFINITION
	# =============================================================================

	var selected_definition: BuildingDefinition = (
		_get_selected_building_definition()
	)

	var building_runtime: BuildingRuntime = (
		new_object.get_node_or_null("BuildingRuntime")
		as BuildingRuntime
	)

	if building_runtime != null and selected_definition != null:
		building_runtime.initialize(selected_definition)

	# =============================================================================
	# APPLY PLACEMENT TRANSFORM
	# =============================================================================

	if new_object is Node3D:
		new_object.global_position = current_placement_position
		new_object.rotation_degrees.y = placement_rotation_degrees

	# =============================================================================
	# AUTOMATIC CONVEYOR CORNER CONVERSION
	# =============================================================================

	# After the new straight conveyor has been placed,
	# check whether it creates a valid perpendicular turn.
	#
	# The preceding conveyor becomes the corner.
	# The newly placed conveyor remains straight.
	#
	# Other building types are unaffected.

	
	if (
		selected_building_index == 4
		and new_object is ConveyorSegment
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):


		var placed_straight: ConveyorSegment = (
			new_object as ConveyorSegment
		)

		var corner_candidate: Dictionary = (
			_find_perpendicular_corner_candidate(
				placed_straight
			)
		)

		if not corner_candidate.is_empty():

			var source_belt: ConveyorSegment = (
				corner_candidate["source"] as ConveyorSegment
			)

			var turn_direction: int = int(
				corner_candidate["turn"]
			)

			# =============================================================================
			# COMMIT THE CORNER CONNECTION
			# =============================================================================

			var conversion_successful: bool = (
				ConveyorCornerConversion.try_convert_and_connect(
					source_belt,
					placed_straight,
					turn_direction
				)
			)

			if not conversion_successful:

				# Do not leave an invalid newly placed belt.
				# The conversion component restores the
				# previous belt when connection fails.

				placed_straight.queue_free()

				print(
					"Automatic corner failed: "
					+ "Connection rejected."
				)

				return

			# =============================================================================
			# CONFIRM AUTOMATIC CORNER
			# =============================================================================

			var turn_name: String = "RIGHT"

			if turn_direction == ConveyorTurnIntent.Turn.LEFT:
				turn_name = "LEFT"

			print(
				"AUTO CORNER SUCCESS | Turn: ",
				turn_name,
				" | Corner position: ",
				source_belt.global_position,
				" | New straight: ",
				placed_straight.global_position
			)

	# =============================================================================
	# PLACEMENT CONFIRMATION
	# =============================================================================

	print(
		"Placed object at ",
		current_placement_position,
		" with rotation ",
		placement_rotation_degrees,
		" degrees"
	)

# =============================================================================
# PLACEMENT GHOST CREATION
# =============================================================================
# Creates a temporary visual copy of the currently selected buildable scene.
#
# The ghost:
#   - has its actual collision shapes recorded for placement checks
#   - has those physics collisions disabled
#   - uses a translucent material
#   - inherits the current placement rotation


func _create_placement_ghost(
	scene_override: PackedScene = null
) -> void:

	_destroy_placement_ghost()

	# =============================================================================
	# SELECT NORMAL BUILDING SCENE
	# =============================================================================

	var selected_scene: PackedScene = (
		_get_selected_building_scene()
	)

	# =============================================================================
	# OPTIONAL CONVEYOR SCENE OVERRIDE
	# =============================================================================

	# Only the Conveyor Belt tool (index 4 / key 5)
	# may replace its default scene with an alternate
	# conveyor shape.
	#
	# Other building types continue using their
	# normal BuildingDefinition scenes.

	if (
		selected_building_index == 4
		and scene_override != null
	):

		if scene_override in [
			ConveyorPieceSelector.STRAIGHT_SCENE,
			ConveyorPieceSelector.RIGHT_CORNER_SCENE,
			ConveyorPieceSelector.LEFT_CORNER_SCENE
		]:
			selected_scene = scene_override

	if selected_scene == null:
		return


	var ghost_instance: Node = selected_scene.instantiate()

	if not ghost_instance is Node3D:
		return

	placement_ghost = ghost_instance as Node3D
	
	# =============================================================================
	# RECORD CONVEYOR PREVIEW TYPE
	# =============================================================================

	conveyor_preview_scene = null

	if placement_ghost is ConveyorSegment:
		conveyor_preview_scene = selected_scene

	# Placement ghosts are visual previews only.
	# Mark them explicitly for snap discovery before they enter the tree.
	# A real building can also have processing disabled, so discovery
	# must not identify ghosts from process_mode alone.
	placement_ghost.add_to_group("construction_preview")

	# Disable gameplay processing for the ghost and its child components.
	placement_ghost.process_mode = Node.PROCESS_MODE_DISABLED
	placement_ghost.rotation_degrees.y = placement_rotation_degrees

	placement_ghost_collisions.clear()

# Record physical building collision shapes for placement checks.
# Detection Area3D shapes are disabled on the ghost but are not part of
# the building's placement-blocking footprint.
	for child in placement_ghost.find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	):
		if child is CollisionShape3D:
			child.disabled = true

			if child.get_parent() is PhysicsBody3D:
				placement_ghost_collisions.append(child)

	# Create the translucent placement-preview material.
	ghost_material = StandardMaterial3D.new()
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	ghost_material.albedo_color = Color(
		valid_placement_color.r,
		valid_placement_color.g,
		valid_placement_color.b,
		PLACEMENT_GHOST_ALPHA
	)

	# Apply the preview material to every visible mesh inside the ghost.
	for child in placement_ghost.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	):
		if child is MeshInstance3D:
			child.material_override = ghost_material

	get_tree().current_scene.add_child(placement_ghost)


# =============================================================================
# PLACEMENT GHOST CLEANUP
# =============================================================================
# Safely removes the temporary placement preview and clears all references
# associated with it.
#
# Called when:
#   - Build Mode ends
#   - Demolition Mode begins
#   - the selected building type changes
#   - a fresh placement ghost is created



func _destroy_placement_ghost() -> void:
	if placement_ghost != null and is_instance_valid(placement_ghost):
		placement_ghost.queue_free()

	# =============================================================================
	# RESET PLACEMENT GHOST STATE
	# =============================================================================

	conveyor_snap_source = null
	conveyor_snap_before = false
	conveyor_building_snap_port = null
	building_placement_snap_belt = null
	building_placement_snap_port = null
	conveyor_corner_snap_source = null
	conveyor_corner_snap_turn = ConveyorTurnIntent.Turn.STRAIGHT
	conveyor_bridge_source = null
	conveyor_bridge_destination = null
	conveyor_preview_scene = null
	placement_ghost = null
	ghost_material = null
	placement_ghost_collisions.clear()
