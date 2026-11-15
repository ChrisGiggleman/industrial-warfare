extends Node
const Demo = preload("res://scripts/ui/isolated_playable_construction_logistics_demo.gd")
func _ready() -> void:
	call_deferred("_launch")

func _launch() -> void:
	var sandbox := (load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene).instantiate() as Node3D
	var demo := Demo.new()
	demo.name = "PlayableConstructionLogisticsDemo"
	demo.enable_isolated_playable_demo = true
	sandbox.add_child(demo)
	# Keep the exact sandbox as current_scene so WorldInteraction places
	# player buildings and conveyors under the correct scope.
	get_tree().root.add_child(sandbox)
	get_tree().current_scene = sandbox
	if not demo.start_demo():
		push_error("Playable logistics demo setup failed")
	queue_free()
