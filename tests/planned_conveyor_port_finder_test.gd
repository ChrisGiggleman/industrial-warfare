extends Node3D

# =============================================================================
# PLANNED CONVEYOR SNAP DISCOVERY — GEOMETRY REGRESSION
# =============================================================================

func _ready() -> void:
	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(definition != null)
	var site := ConstructionSite.new()
	assert(site.setup(definition, 10.0))
	site.position = Vector3(6.0, 0.0, 2.0)
	site.rotation_degrees.y = 90.0
	add_child(site)
	site.set_process(false)

	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	(belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	var target := site.get_planned_belt_transform(belt, true)
	assert(target.has("transform"))
	belt.global_transform = target["transform"]
	var choice := PlannedConveyorPortFinder.find_nearest_preview(
		belt, belt.global_position
	)
	assert(choice.get("site") == site)
	assert(choice.get("input_side") == true)
	assert((choice["transform"] as Transform3D).is_equal_approx(belt.global_transform))
	print("PASS A: Finder locates rotated unfinished Storage input geometry")

	var distant := PlannedConveyorPortFinder.find_nearest_preview(
		belt, belt.global_position + Vector3(2, 0, 0)
	)
	assert(distant.is_empty())
	print("PASS B: Finder rejects cursors outside the snap radius")

	belt.rotation_degrees.y += 90.0
	assert(PlannedConveyorPortFinder.find_nearest_preview(
		belt, target["transform"].origin
	).is_empty())
	belt.global_transform = target["transform"]
	print("PASS C: Finder honors the player's requested conveyor direction")

	# The mouse is often aimed at the port on the blueprint rather than
	# at the center of the belt that will be created next to it.
	var planned_input := site.get_planned_port(true)
	assert(planned_input != null)
	var aimed_at_port := PlannedConveyorPortFinder.find_nearest_preview(
		belt, planned_input.global_position
	)
	assert(aimed_at_port.get("site") == site)
	assert(bool(aimed_at_port.get("input_side", false)))
	assert(
		(aimed_at_port["transform"] as Transform3D).is_equal_approx(
			target["transform"]
		)
	)
	print("PASS D: Cursor on visible blueprint port offers correct conveyor snap")

	assert(site.reserve_conveyor(belt, true))
	assert(PlannedConveyorPortFinder.find_nearest_preview(
		belt, target["transform"].origin
	).is_empty())
	assert(belt.output_building_port == null)
	print("PASS E: Reserved port cannot offer another preview or transfer")

	site.lifecycle.advance(10.0)
	assert(PlannedConveyorPortFinder.find_nearest_preview(
		belt, target["transform"].origin
	).is_empty())
	print("PASS F: Completed construction is no longer a planned snap target")

	print("ALL 6 PLANNED CONVEYOR PORT DISCOVERY CHECKS PASSED")
