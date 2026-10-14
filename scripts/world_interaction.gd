extends Node


# =============================================================================
# CONSTANTS
# =============================================================================
# Physics collision masks used by the interaction system.
#
# Layer 1 = Ground / placement surfaces
# Layer 3 = Placement blockers

const GROUND_COLLISION_MASK: int = 1
const PLACEMENT_BLOCKER_COLLISION_MASK: int = 4

# Placement preview settings that currently do not need Inspector adjustment.

const ROTATION_STEP_DEGREES: float = 90.0
const FULL_ROTATION_DEGREES: float = 360.0
const PLACEMENT_GHOST_ALPHA: float = 0.4


# =============================================================================
# EXPORTED SETTINGS
# =============================================================================
# References and values that can be adjusted from the Godot Inspector.

@export var camera: Camera3D

@export var build_hud_panel: Control
@export var build_hud: CanvasLayer

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

		if placement_ghost != null:
			placement_ghost.global_position = current_placement_position

		placement_is_valid = _is_placement_clear()

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
# PLACEMENT VALIDITY CHECK
# =============================================================================
# Checks the placement ghost's actual CollisionShape3D nodes against objects
# on Collision Layer 3.
#
# Because each query uses the ghost collision shape's global transform,
# the validity test automatically respects:
#   - building size
#   - building footprint
#   - placement rotation

func _is_placement_clear() -> bool:
	if placement_ghost_collisions.is_empty():
		return false

	for collision_shape in placement_ghost_collisions:
		if collision_shape.shape == null:
			continue

		var query := PhysicsShapeQueryParameters3D.new()

		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform
		query.collision_mask = PLACEMENT_BLOCKER_COLLISION_MASK

		var results: Array[Dictionary] = (
			get_viewport().world_3d.direct_space_state.intersect_shape(
				query,
				1
			)
		)

		if not results.is_empty():
			return false

	return true


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
	if not placement_is_valid:
		print("Placement blocked")
		return

	var selected_scene: PackedScene = _get_selected_building_scene()

	if selected_scene == null:
		print("No buildable scene selected")
		return

	var new_object: Node = selected_scene.instantiate()

	get_tree().current_scene.add_child(new_object)

	var selected_definition: BuildingDefinition = (
		_get_selected_building_definition()
	)

	var building_runtime: BuildingRuntime = (
		new_object.get_node_or_null("BuildingRuntime") as BuildingRuntime
	)

	if building_runtime != null and selected_definition != null:
		building_runtime.initialize(selected_definition)

	if new_object is Node3D:
		new_object.global_position = current_placement_position
		new_object.rotation_degrees.y = placement_rotation_degrees

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

func _create_placement_ghost() -> void:
	_destroy_placement_ghost()

	var selected_scene: PackedScene = _get_selected_building_scene()

	if selected_scene == null:
		return

	var ghost_instance: Node = selected_scene.instantiate()

	if not ghost_instance is Node3D:
		return

	placement_ghost = ghost_instance as Node3D
	placement_ghost.rotation_degrees.y = placement_rotation_degrees

	placement_ghost_collisions.clear()

	# Record and disable the ghost's real collision shapes.
	for child in placement_ghost.find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	):
		if child is CollisionShape3D:
			child.disabled = true
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

	placement_ghost = null
	ghost_material = null
	placement_ghost_collisions.clear()
