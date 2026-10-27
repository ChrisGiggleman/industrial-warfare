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

		if event.is_action_pressed("primary_action"):
			_try_place_object()
			return

		return

	if event.is_action_pressed("primary_action"):
		_select_under_mouse()


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
			placement_ghost.global_position = (
				current_placement_position
			)

			placement_ghost.rotation_degrees.y = (
				placement_rotation_degrees
			)

			# =============================================================================
			# CHECK CONVEYOR SNAP PREVIEW
			# =============================================================================

			if placement_ghost is ConveyorSegment:

				var snap_result: Dictionary = (
					_find_conveyor_snap_preview(
						current_placement_position
					)
				)

				if not snap_result.is_empty():

					# Move the ghost only.
					# Do not connect the real conveyors.

					placement_ghost.global_transform = (
						snap_result["transform"]
					)

					conveyor_snap_source = (
						snap_result["source"]
					)

					# Remember which side of the existing conveyor
					# the new segment would connect to.

					conveyor_snap_before = bool(
						snap_result["before"]
					)

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
	# TEMPORARY SNAP DEBUG
	# =============================================================================

	var placed_belts: int = 0

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):
		if node is ConveyorSegment and node != placement_ghost:
			placed_belts += 1

	print(
		"SNAP DEBUG | Slot: ", selected_building_index,
		" | Belts: ", placed_belts,
		" | Ghost conveyor: ", placement_ghost is ConveyorSegment,
		" | Source found: ", is_instance_valid(conveyor_snap_source),
		" | Before: ", conveyor_snap_before,
		" | Placement valid: ", placement_is_valid
	)

	# =============================================================================
	# CORNER SELECTION DEBUG — PRINT ONLY ON CLICK
	# =============================================================================

	if selected_building_index == 4:

		var preview_path: String = "None"

		if conveyor_preview_scene != null:
			preview_path = conveyor_preview_scene.resource_path

		print(
			"CORNER CLICK | Preview: ", preview_path,
			" | Source found: ",
			is_instance_valid(conveyor_snap_source),
			" | Before: ", conveyor_snap_before,
			" | Valid: ", placement_is_valid,
			" | Mouse grid: ", current_placement_position
		)

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

	if selected_building_index == 4 and new_object is ConveyorSegment:

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
	conveyor_preview_scene = null
	placement_ghost = null
	ghost_material = null
	placement_ghost_collisions.clear()
