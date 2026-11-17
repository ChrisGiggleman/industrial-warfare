extends Node
const Demo = preload("res://scripts/ui/isolated_playable_construction_drone_demo.gd")
func _ready() -> void:
	call_deferred("_launch")

func _launch() -> void:
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate() as Node3D
	var demo := Demo.new()
	demo.name = "PlayableConstructionDroneDemo"
	demo.enable_isolated_playable_demo = true
	demo.enable_isolated_power_demo = true
	demo.enable_isolated_drone_demo = true
	sandbox.add_child(demo)
	get_tree().root.add_child(sandbox)
	get_tree().current_scene = sandbox
	if not demo.start_drone_demo():
		push_error("Playable construction drone demo setup failed")
	queue_free()
