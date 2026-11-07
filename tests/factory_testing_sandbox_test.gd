extends Node

# =============================================================================
# FACTORY TESTING SANDBOX — ISOLATION REGRESSION
# =============================================================================

func _ready() -> void:
	var sandbox_scene := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	assert(sandbox_scene != null and main_scene != null)

	var sandbox := sandbox_scene.instantiate() as Node3D
	var main := main_scene.instantiate() as Node3D
	assert(sandbox != null and main != null)
	# Inspect scene settings without activating either scene's gameplay loops.
	var sandbox_zombie := sandbox.get_node("PrototypeMovingZombie") as Node3D
	var main_zombie := main.get_node("PrototypeMovingZombie") as Node3D
	assert(sandbox_zombie.process_mode == Node.PROCESS_MODE_DISABLED)
	assert(main_zombie.process_mode != Node.PROCESS_MODE_DISABLED)
	print("PASS A: Sandbox zombie is disabled, normal Main zombie remains active")

	var sandbox_controller := sandbox.get_node("WorldInteraction")
	var main_controller := main.get_node("WorldInteraction")
	assert(sandbox_controller.enable_timed_storage_construction)
	assert(not main_controller.enable_timed_storage_construction)
	print("PASS B: Timed Storage enabled only in sandbox")

	assert(sandbox.get_node_or_null("BuildHUD") != null)
	assert(sandbox.get_node_or_null("ProductionDebugHUD") != null)
	assert(sandbox_controller.buildable_definitions.size() == main_controller.buildable_definitions.size())
	print("PASS C: Sandbox retains HUD and building definitions")

	sandbox.free()
	main.free()
	print("ALL 3 FACTORY TESTING SANDBOX REGRESSION CHECKS PASSED")
