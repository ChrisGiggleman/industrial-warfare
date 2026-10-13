extends Node3D


@export var move_speed: float = 10.0
@export var zoom_step: float = 2.0
@export var min_zoom_distance: float = 6.0
@export var max_zoom_distance: float = 24.0

@onready var camera: Camera3D = $Camera3D


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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		_zoom_camera(-zoom_step)

	if event.is_action_pressed("camera_zoom_out"):
		_zoom_camera(zoom_step)


func _zoom_camera(amount: float) -> void:
	var current_distance: float = camera.position.length()

	var new_distance: float = clampf(
		current_distance + amount,
		min_zoom_distance,
		max_zoom_distance
	)

	camera.position = camera.position.normalized() * new_distance
