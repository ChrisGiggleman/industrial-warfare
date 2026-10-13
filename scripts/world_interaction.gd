extends Node


@export var camera: Camera3D
@export var ray_length: float = 1000.0


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
				print("Selected ", current_node.name, " at ", hit_position)
				return

			current_node = current_node.get_parent()

		print("Hit ", collider.name, " at ", hit_position)
