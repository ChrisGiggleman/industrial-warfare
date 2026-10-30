
extends Node


# =============================================================================
# FACTORY GRID ALIGNMENT TEST
# =============================================================================

func _ready() -> void:

	print("")
	print("===== CHAT 08.3G: FACTORY GRID TEST =====")

	# =============================================================================
	# TEST A — EXTRACTOR FOOTPRINT
	# =============================================================================

	var extractor_size := Vector2i(1, 2)

	var extractor_origin := FactoryGrid.snap_building_origin(
		Vector3(2.2, 0.0, 3.1),
		extractor_size
	)

	assert(is_equal_approx(extractor_origin.x, 2.0))
	assert(is_equal_approx(extractor_origin.z, 3.5))

	print("PASS A: Extractor 1x2 footprint aligned")


	# =============================================================================
	# TEST B — STORAGE FOOTPRINT
	# =============================================================================

	var storage_size := Vector2i(1, 3)

	var storage_origin := FactoryGrid.snap_building_origin(
		Vector3(2.2, 0.0, 3.1),
		storage_size
	)

	assert(is_equal_approx(storage_origin.x, 2.0))
	assert(is_equal_approx(storage_origin.z, 3.0))

	print("PASS B: Storage 1x3 footprint aligned")


	# =============================================================================
	# TEST C — SMELTER FOOTPRINT
	# =============================================================================

	var smelter_size := Vector2i(2, 2)

	var smelter_origin := FactoryGrid.snap_building_origin(
		Vector3(2.2, 0.0, 3.1),
		smelter_size
	)

	assert(is_equal_approx(smelter_origin.x, 2.5))
	assert(is_equal_approx(smelter_origin.z, 3.5))

	print("PASS C: Smelter 2x2 footprint aligned")


	# =============================================================================
	# TEST D — STANDARDIZED SMELTER PORTS
	# =============================================================================

	var input_port := FactoryGrid.get_port_local_position(
		smelter_size,
		FactoryGrid.Side.NEGATIVE_X,
		0
	)

	var output_port := FactoryGrid.get_port_local_position(
		smelter_size,
		FactoryGrid.Side.POSITIVE_X,
		0
	)

	assert(input_port == Vector3(-1.0, 0.5, -0.5))
	assert(output_port == Vector3(1.0, 0.5, -0.5))

	print("PASS D: Smelter input and output ports aligned")


	# =============================================================================
	# TEST E — CONVEYOR CENTERS ALIGN WITH SHARED GRID
	# =============================================================================

	var smelter_transform := Transform3D(
		Basis.IDENTITY,
		smelter_origin
	)

	var conveyor_input_position := FactoryGrid.get_conveyor_center(
		smelter_transform,
		input_port,
		FactoryGrid.Side.NEGATIVE_X
	)

	var conveyor_output_position := FactoryGrid.get_conveyor_center(
		smelter_transform,
		output_port,
		FactoryGrid.Side.POSITIVE_X
	)

	assert(FactoryGrid.is_on_conveyor_grid(
		conveyor_input_position
	))

	assert(FactoryGrid.is_on_conveyor_grid(
		conveyor_output_position
	))

	assert(is_equal_approx(conveyor_input_position.y, 0.0))
	assert(is_equal_approx(conveyor_output_position.y, 0.0))

	print("PASS E: Conveyor centers align with shared grid")


	# =============================================================================
	# TEST F — ROTATED FOOTPRINT
	# =============================================================================

	var rotated_size := FactoryGrid.rotated_footprint(
		Vector2i(2, 3),
		1
	)

	assert(rotated_size == Vector2i(3, 2))

	print("PASS F: Rectangular footprint rotation correct")

	# =============================================================================
	# TEST G — ALL BUILDING ROTATIONS AND PORT LANES
	# =============================================================================

	# Verify all four rotations for the current building
	# footprints and a larger future 2x3 building.
	#
	# Every available port lane must produce a conveyor
	# center that lies on the shared 1-unit grid.

	var footprints: Array[Vector2i] = [
		Vector2i(1, 2), # Extractor
		Vector2i(1, 3), # Storage
		Vector2i(2, 2), # Smelter
		Vector2i(2, 3)  # Future rectangular factory
	]

	for footprint: Vector2i in footprints:

		for quarter_turns: int in range(4):

			
			var rotated_footprint_size: Vector2i = (
				FactoryGrid.rotated_footprint(
					footprint,
					quarter_turns
				)
			)


			var origin: Vector3 = (
				FactoryGrid.snap_building_origin(
					Vector3(4.2, 0.0, 6.1),
					rotated_footprint_size
				)

			)

			var rotation_basis := Basis(
				Vector3.UP,
				float(quarter_turns) * PI / 2.0
			)

			var building_transform := Transform3D(
				rotation_basis,
				origin
			)

			for side_value in [
				FactoryGrid.Side.NEGATIVE_X,
				FactoryGrid.Side.POSITIVE_X,
				FactoryGrid.Side.NEGATIVE_Z,
				FactoryGrid.Side.POSITIVE_Z
			]:

				var side: int = int(side_value)

				var lane_count: int = footprint.x

				if (
					side == FactoryGrid.Side.NEGATIVE_X
					or side == FactoryGrid.Side.POSITIVE_X
				):
					lane_count = footprint.y

				for lane_index: int in range(lane_count):

					var port_position: Vector3 = (
						FactoryGrid.get_port_local_position(
							footprint,
							side,
							lane_index
						)
					)

					var conveyor_center: Vector3 = (
						FactoryGrid.get_conveyor_center(
							building_transform,
							port_position,
							side
						)
					)

					assert(
						FactoryGrid.is_on_conveyor_grid(
							conveyor_center
						)
					)

					assert(
						is_equal_approx(
							conveyor_center.y,
							0.0
						)
					)

	print("PASS G: All rotations and port lanes align")

	# =============================================================================
	# TEST H — BUILDING DEFINITION FOOTPRINTS
	# =============================================================================

	var extractor_def := load(
		"res://data/buildings/test_extractor.tres"
	) as BuildingDefinition

	var storage_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition

	var smelter_def := load(
		"res://data/buildings/test_smelter.tres"
	) as BuildingDefinition

	assert(extractor_def != null)
	assert(storage_def != null)
	assert(smelter_def != null)

	assert(extractor_def.footprint_tiles == Vector2i(1, 2))
	assert(storage_def.footprint_tiles == Vector2i(1, 3))
	assert(smelter_def.footprint_tiles == Vector2i(2, 2))

	print("PASS H: Building footprints configured correctly")


	# =============================================================================
	# TEST I — ACTUAL SMELTER SCENE GRID ALIGNMENT
	# =============================================================================

	# Verify that the real Smelter scene matches
	# our unified 2x2 construction footprint.

	var smelter_grid_scene := load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	assert(smelter_grid_scene != null)

	var grid_smelter := smelter_grid_scene.instantiate() as Node3D
	assert(grid_smelter != null)

	add_child(grid_smelter)

	var grid_mesh := (
		grid_smelter.get_node("BuildingMesh") as MeshInstance3D
	)

	var grid_collision := (
		grid_smelter.get_node(
			"BuildingBody/CollisionShape3D"
		) as CollisionShape3D
	)

	var grid_input := (
		grid_smelter.get_node("InputPort") as ItemPortComponent
	)

	var grid_output := (
		grid_smelter.get_node("OutputPort") as ItemPortComponent
	)

	assert(grid_mesh != null)
	assert(grid_collision != null)
	assert(grid_input != null)
	assert(grid_output != null)

	# Verify physical footprint.

	var box_mesh := grid_mesh.mesh as BoxMesh
	var box_shape := grid_collision.shape as BoxShape3D

	assert(box_mesh != null)
	assert(box_shape != null)

	assert(box_mesh.size == Vector3(2.0, 1.0, 2.0))
	assert(box_shape.size == Vector3(2.0, 1.0, 2.0))

	# Verify standardized physical port positions.

	assert(
		grid_input.position.is_equal_approx(
			Vector3(-1.0, 0.5, -0.5)
		)
	)

	assert(
		grid_output.position.is_equal_approx(
			Vector3(1.0, 0.5, -0.5)
		)
	)

	# Verify every rotation keeps conveyor centers
	# aligned to the unified world grid.

	for smelter_turn in range(4):

		var grid_origin := FactoryGrid.snap_building_origin(
			Vector3(4.2, 0.0, 6.1),
			Vector2i(2, 2)
		)

		grid_smelter.global_transform = Transform3D(
			Basis(
				Vector3.UP,
				float(smelter_turn) * PI / 2.0
			),
			grid_origin
		)

		var input_center := FactoryGrid.get_conveyor_center(
			grid_smelter.global_transform,
			grid_input.position,
			FactoryGrid.Side.NEGATIVE_X
		)

		var output_center := FactoryGrid.get_conveyor_center(
			grid_smelter.global_transform,
			grid_output.position,
			FactoryGrid.Side.POSITIVE_X
		)

		assert(FactoryGrid.is_on_conveyor_grid(input_center))
		assert(FactoryGrid.is_on_conveyor_grid(output_center))

	grid_smelter.queue_free()

	print("PASS I: Actual Smelter geometry and rotations aligned")

	# =============================================================================
	# FINAL RESULT
	# =============================================================================

	print("============================================")
	print("ALL 9 FACTORY GRID TESTS PASSED")
	print("============================================")
