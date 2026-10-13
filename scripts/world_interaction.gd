extends Node


# =============================================================================
# EXPORTED SETTINGS
# =============================================================================
# References and values that can be adjusted from the Godot Inspector.

@export var camera: Camera3D
@export var hover_marker: MeshInstance3D
@export var placeable_scene: PackedScene

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

var placement_mode_active: bool = false
var current_placement_position: Vector3 = Vector3.ZERO
var placement_is_valid: bool = false


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
#   Left Click = Select object
#
# Placement Mode:
#   Left Click = Attempt to place building
#
# B / toggle_placement_mode switches between the two modes.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_placement_mode"):
		_toggle_placement_mode()
		return

	if placement_mode_active:
		if event.is_action_pressed("primary_action"):
			_try_place_object()
		return

	if event.is_action_pressed("primary_action"):
		_print_mouse_world_position()


# =============================================================================
# PLACEMENT MODE TOGGLE
# =============================================================================
# Enables or disables build/placement mode.
# Entering placement mode clears the current object selection.

func _toggle_placement_mode() -> void:
	placement_mode_active = not placement_mode_active

	if placement_mode_active:
		_select_object(null)
		print("Placement mode enabled")
	else:
		hover_marker.visible = false
		placement_is_valid = false
		print("Placement mode disabled")


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
# The ray only checks Collision Layer 1, which is reserved for placement
# surfaces such as the ground.
#
# The result is snapped to the configured grid size.

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

		# Store the actual ground-level location where a building would be placed.
		current_placement_position = Vector3(
			snappedf(hit_position.x, grid_size),
			hit_position.y,
			snappedf(hit_position.z, grid_size)
		)

		# The thin preview tile sits slightly above the ground to prevent overlap.
		hover_marker.visible = true
		hover_marker.global_position = (
			current_placement_position + Vector3(0.0, 0.02, 0.0)
		)

		# Check whether the current grid cell is occupied.
		placement_is_valid = _is_placement_clear(current_placement_position)

		if placement_is_valid:
			hover_material.albedo_color = valid_placement_color
		else:
			hover_material.albedo_color = invalid_placement_color

	else:
		hover_marker.visible = false
		placement_is_valid = false


# =============================================================================
# PLACEMENT VALIDITY CHECK
# =============================================================================
# Tests a roughly 1x1 meter area above the requested placement position.
#
# Collision Layer 3 is reserved for objects that block construction.
#
# Returns:
#   true  = area is empty
#   false = another placement-blocking object occupies the cell

func _is_placement_clear(position: Vector3) -> bool:
	var check_shape := BoxShape3D.new()
	check_shape.size = Vector3(0.9, 1.0, 0.9)

	var query := PhysicsShapeQueryParameters3D.new()

	query.shape = check_shape
	query.transform.origin = position + Vector3(0.0, 0.5, 0.0)

	# Collision Layer 3 = Placement blockers.
	query.collision_mask = 4

	var results: Array[Dictionary] = (
		get_viewport().world_3d.direct_space_state.intersect_shape(
			query,
			1
		)
	)

	return results.is_empty()


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

	if placeable_scene == null:
		print("No placeable scene assigned")
		return

	var new_object: Node = placeable_scene.instantiate()

	get_tree().current_scene.add_child(new_object)

	if new_object is Node3D:
		new_object.global_position = current_placement_position

	print("Placed object at ", current_placement_position)
