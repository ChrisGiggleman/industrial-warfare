extends Node3D

# =============================================================================
# E3D2 — COMPACT BLUEPRINT VISUALS AND SUMMARY HUD
# =============================================================================
# Confirms sandbox-only optics and unchanged authorization behavior.

func _ready() -> void:
	var packed := load("res://scenes/core/factory_testing_sandbox.tscn") as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.compact_blueprint_visuals)
	var summary := world.get_node_or_null("BlueprintConstructionSummary")
	assert(summary != null)
	print("PASS A: Sandbox opts into compact visuals and construction summary")

	var definition := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	assert(definition != null)
	var site := controller._create_blueprint_site(
		definition, Transform3D(Basis.IDENTITY, Vector3(-6, 0, 0))
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	assert(site.compact_blueprint_visuals)
	assert(site.get_node_or_null("ConstructionProgressTrack") != null)
	assert(site.get_node_or_null("ConstructionProgressFill") != null)
	print("PASS B: Planned building has a compact progress bar")

	var label := site.get_node("ConstructionLabel") as Label3D
	assert(label != null and label.text == "PLAN")
	assert(site.job.state == ConstructionJob.State.PLANNED)
	print("PASS C: Planned building uses short readable status")

	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	assert(controller._authorize_blueprint_site(site))
	site._process(3.0)
	assert(site.job.state == ConstructionJob.State.CONSTRUCTING)
	assert(label.text == "BUILD")
	var fill := site.get_node("ConstructionProgressFill") as MeshInstance3D
	assert(fill.scale.x > 0.0 and fill.scale.x < 1.0)
	print("PASS D: Authorizing updates building bar without skipping time")

	var belt_def := load("res://data/buildings/conveyor_belt.tres") as BuildingDefinition
	assert(belt_def != null)
	var belt := controller._create_straight_conveyor_blueprint(
		belt_def, Transform3D(Basis.IDENTITY, Vector3(4, 0, 4))
	) as ConstructionSite
	assert(belt != null)
	belt.set_process(false)
	assert(belt.compact_blueprint_visuals)
	assert(not (belt.get_node("ConstructionLabel") as Label3D).visible)
	assert(belt.get_node_or_null("PlannedDirectionArrow") != null)
	print("PASS E: Belt keeps direction arrow but hides overlapping label")

	var defaults: Node = (load("res://scripts/world_interaction.gd") as GDScript).new() as Node
	assert(not defaults.compact_blueprint_visuals)
	defaults.free()
	print("PASS F: Main default remains opt-out")
	print("ALL 6 E3D2 COMPACT BLUEPRINT VISUAL TESTS PASSED")
