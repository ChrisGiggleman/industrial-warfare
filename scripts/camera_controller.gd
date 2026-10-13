extends Node3D


@export var move_speed: float = 10.0


func _ready() -> void:
	print("Camera controller initialized.")


func _process(delta: float) -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var move_direction := Vector3(
		input_direction.x,
		0.0,
		input_direction.y
	)

	position += move_direction * move_speed * delta