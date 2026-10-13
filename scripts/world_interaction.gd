extends Node


@export var camera: Camera3D
@export var hover_marker: MeshInstance3D
@export var ray_length: float = 1000.0

var selected_object: Node = null


func _process(_delta: float) -> void:
	_update_hover_marker()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_action"):
		_print_mouse_world_position()


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


func _select_object(object: Node) -> void:
	if selected_object == object:
		return

	if selected_object != null and selected_object.has_method("set_selected"):
		selected_object.call("set_selected", false)

	selected_object = object

	if selected_object != null and selected_object.has_method("set_selected"):
		selected_object.call("set_selected", true)


func _update_hover_marker() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = 1
	
	var result: Dictionary = get_viewport().world_3d.direct_space_state.intersect_ray(query)

	if result:
		var hit_position: Vector3 = result["position"]

		hover_marker.visible = true
		hover_marker.global_position = hit_position + Vector3(0.0, 0.15, 0.0)

	else:
		hover_marker.visible = false
