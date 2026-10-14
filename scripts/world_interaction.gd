extends Node


# =============================================================================
# EXPORTED SETTINGS
# =============================================================================
# References and values that can be adjusted from the Godot Inspector.

@export var camera: Camera3D
@export var hover_marker: MeshInstance3D
@export var buildable_scenes: Array[PackedScene] = []

@export var ray_length: float = 1000.0
@export var grid_size: float = 1.0

@export var valid_placement_color: Color = Color(0.0, 1.0, 0.0)
@export var invalid_placement_color: Color = Color(1.0, 0.0, 0.0)


# =============================================================================
# RUNTIME STATE
# =============================================================================
# Stores information that changes while the game is running.

var selected_object: Node = null
var hover_material: StandardMaterial3D
var placement_ghost_collisions: Array[CollisionShape3D] = []
var selected_building_index: int = 0

var placement_mode_active: bool = false
var current_placement_position: Vector3 = Vector3.ZERO
var placement_is_valid: bool = false
var placement_rotation_degrees: float = 0.0

var placement_ghost: Node3D = null
var ghost_material: StandardMaterial3D


# =============================================================================
# INITIALIZATION
# =============================================================================
# Runs once when WorldInteraction enters the scene.
# Stores the hover marker material and hides the placement preview initially.

func _ready() -> void:
	hover_material = hover_marker.material_override as StandardMaterial3D
	hover_marker.visible = false


# =============================================================================
# FRAME UPDATE
# =============================================================================
# Runs every rendered frame.
# The placement preview only updates while placement mode is active.

func _process(_delta: float) -> void:
	if placement_mode_active:
		_update_hover_marker()


# =============================================================================
# INPUT HANDLING
# =============================================================================
# Handles interaction inputs.
#
# Normal Mode:
#   Left Click  = Select object
#
# Placement Mode:
#   Left Click  = Attempt to place building
#   Right Click = Cancel placement mode
#   1           = Select building slot 1
#   2           = Select building slot 2
#   R           = Rotate placement preview 90 degrees
#
# B / toggle_placement_mode switches between normal and placement modes.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_placement_mode"):
		_toggle_placement_mode()
		return

	if placement_mode_active:
		if event.is_action_pressed("secondary_action"):
			_toggle_placement_mode()
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
		_print_mouse_world_position()


# =============================================================================
# PLACEMENT MODE TOGGLE
# =============================================================================
# Enables or disables build/placement mode.
# Entering placement mode clears the current object selection and creates
# the temporary building preview.
#
# Leaving placement mode hides the placement tile and removes the ghost.

func _toggle_placement_mode() -> void:
	placement_mode_active = not placement_mode_active

	if placement_mode_active:
		_select_object(null)
		_create_placement_ghost()
		print("Placement mode enabled")
	else:
		hover_marker.visible = false
		placement_is_valid = false
		_destroy_placement_ghost()
		print("Placement mode disabled")

# =============================================================================
# SELECTED BUILDING SCENE
# =============================================================================
# Returns the PackedScene currently selected for construction.
# Returns null if no valid building scene is available.

func _get_selected_building_scene() -> PackedScene:
	if buildable_scenes.is_empty():
		return null

	if selected_building_index < 0 or selected_building_index >= buildable_scenes.size():
		return null

	return buildable_scenes[selected_building_index]

# =============================================================================
# BUILDING SELECTION
# =============================================================================
# Changes which building scene is currently selected for construction.
#
# If Build Mode is already active, the placement ghost is recreated
# immediately using the newly selected building.

func _select_building(index: int) -> void:
	if index < 0 or index >= buildable_scenes.size():
		return

	if buildable_scenes[index] == null:
		return

	selected_building_index = index
	placement_rotation_degrees = 0.0

	if placement_mode_active:
		_create_placement_ghost()

	print("Selected building slot ", index + 1)

# =============================================================================
# PLACEMENT ROTATION
# =============================================================================
# Rotates the current placement preview clockwise in 90-degree increments.
#
# Rotation cycles:
#   0 -> 90 -> 180 -> 270 -> 0

func _rotate_placement() -> void:
	placement_rotation_degrees += 90.0

	if placement_rotation_degrees >= 360.0:
		placement_rotation_degrees = 0.0

	if placement_ghost != null:
		placement_ghost.rotation_degrees.y = placement_rotation_degrees

	print("Placement rotation: ", placement_rotation_degrees, " degrees")

# =============================================================================
# OBJECT SELECTION RAYCAST
# =============================================================================
# Casts a ray from the mouse cursor into the 3D world.
#
# If the collider belongs to or is underneath a node in the "selectable"
# group, that logical object becomes selected.
#
# Clicking ground or empty space deselects the current object.

func _print_mouse_world_position() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	var result: Dictionary = get_viewport().world_3d.direct_space_state.intersect_ray(query)

	if result:
		var hit_position: Vector3 = result["position"]
		var collider: Node = result["collider"]

		var current_node: Node = collider

		while current_node != null:
			if current_node.is_in_group("selectable"):
				_select_object(current_node)
				print("Selected ", current_node.name, " at ", hit_position)
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
# If the object provides a set_selected() method, that object controls its
# own visual selection feedback.

func _select_object(object: Node) -> void:
	if selected_object == object:
		return

	if selected_object != null and selected_object.has_method("set_selected"):
		selected_object.call("set_selected", false)

	selected_object = object

	if selected_object != null and selected_object.has_method("set_selected"):
		selected_object.call("set_selected", true)


# =============================================================================
# PLACEMENT PREVIEW
# =============================================================================
# Tracks the mouse over valid placement surfaces.
#
# The placement ghost follows the grid-snapped ground position.
# The ghost turns green when placement is valid and red when blocked.

func _update_hover_marker() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# Collision Layer 1 = Ground / placement surfaces.
	query.collision_mask = 1

	var result: Dictionary = get_viewport().world_3d.direct_space_state.intersect_ray(query)

	if result:
		var hit_position: Vector3 = result["position"]

		# Store the snapped ground-level position where the building would be placed.
		current_placement_position = Vector3(
			snappedf(hit_position.x, grid_size),
			hit_position.y,
			snappedf(hit_position.z, grid_size)
		)

		# The old placement tile is hidden because the building ghost
		# now provides the placement preview.
		hover_marker.visible = false

		# Move the building ghost to the snapped placement position.
		if placement_ghost != null:
			placement_ghost.global_position = current_placement_position

		# Check whether the current grid cell is occupied.
		placement_is_valid = _is_placement_clear(current_placement_position)

		# Change the ghost color based on placement validity.
		if ghost_material != null:
			if placement_is_valid:
				ghost_material.albedo_color = Color(
					valid_placement_color.r,
					valid_placement_color.g,
					valid_placement_color.b,
					0.4
				)
			else:
				ghost_material.albedo_color = Color(
					invalid_placement_color.r,
					invalid_placement_color.g,
					invalid_placement_color.b,
					0.4
				)

	else:
		hover_marker.visible = false
		placement_is_valid = false


# =============================================================================
# PLACEMENT VALIDITY CHECK
# =============================================================================
# Checks the placement ghost's actual collision shapes against objects on
# Collision Layer 3.
#
# Because the query uses each ghost collision shape's global transform,
# building rotation is automatically included in the validity check.

func _is_placement_clear(_position: Vector3) -> bool:
	if placement_ghost_collisions.is_empty():
		return false

	for collision_shape in placement_ghost_collisions:
		if collision_shape.shape == null:
			continue

		var query := PhysicsShapeQueryParameters3D.new()

		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform

		# Collision Layer 3 = Placement blockers.
		query.collision_mask = 4

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
# Attempts to instantiate the configured PackedScene at the current
# grid-snapped placement position.
#
# Placement is refused when:
#   - the current cell is blocked
#   - no PackedScene has been assigned

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
# Creates a temporary visual copy of the currently placeable scene.
#
# Collision is disabled so the ghost does not block its own placement check.
# A transparent material is applied to the ghost's mesh.

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

	# Disable all collision shapes inside the preview object.
	placement_ghost_collisions.clear()

	for child in placement_ghost.find_children("*", "CollisionShape3D", true, false):
		if child is CollisionShape3D:
			child.disabled = true
			placement_ghost_collisions.append(child)

	# Create a transparent preview material.
	ghost_material = StandardMaterial3D.new()
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_material.albedo_color = Color(
	valid_placement_color.r,
	valid_placement_color.g,
	valid_placement_color.b,
	0.4
)

	# Apply the preview material to every mesh inside the ghost.
	for child in placement_ghost.find_children("*", "MeshInstance3D", true, false):
		if child is MeshInstance3D:
			child.material_override = ghost_material

	get_tree().current_scene.add_child(placement_ghost)

# =============================================================================
# PLACEMENT GHOST CLEANUP
# =============================================================================
# Removes the temporary placement preview from the scene.
# Called when placement mode ends or before a new ghost is created.

func _destroy_placement_ghost() -> void:
	if placement_ghost != null and is_instance_valid(placement_ghost):
		placement_ghost.queue_free()

	placement_ghost = null
	ghost_material = null
	placement_ghost_collisions.clear()
