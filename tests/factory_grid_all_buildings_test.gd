extends Node

# =============================================================================
# CHAT 08.3G-3J — SHARED GRID AND MULTI-PORT ALIGNMENT
# =============================================================================

# All buildings must land on one footprint-aware grid, including after
# rotations. Every real I/O port must produce an integer-centered conveyor
# lane, even on the two-lane merger.

func _ready() -> void:
	print("\n===== CHAT 08.3G-3J: UNIFIED BUILDING GRID =====")
	var definitions: Array[String] = [
		"res://data/buildings/test_extractor.tres",
		"res://data/buildings/test_storage.tres",
		"res://data/buildings/test_smelter.tres",
		"res://data/buildings/conveyor_merger.tres",
		"res://data/buildings/conveyor_splitter.tres"
	]
	var expected_port_counts: Array[int] = [1, 2, 2, 4, 4]
	var names: Array[String] = [
		"Extractor", "Storage", "Smelter", "Merger", "Splitter"
	]

	for building_index: int in range(definitions.size()):
		var definition := load(definitions[building_index]) as BuildingDefinition
		assert(definition != null)
		assert(definition.building_scene != null)
		var aligned_port_count: int = 0

		for quarter_turns: int in range(4):
			var building := definition.building_scene.instantiate() as Node3D
			assert(building != null)
			add_child(building)

			var footprint: Vector2i = FactoryGrid.rotated_footprint(
				definition.footprint_tiles, quarter_turns
			)
			var origin: Vector3 = FactoryGrid.snap_building_origin(
				Vector3(4.2, 0.0, 6.1), footprint
			)
			building.global_transform = Transform3D(
				Basis(Vector3.UP, float(quarter_turns) * PI / 2.0),
				origin
			)
			assert(
				FactoryGrid.snap_building_origin(origin, footprint)
				.is_equal_approx(origin)
			)

			var actual_ports: int = 0
			var centers: Array[Vector2i] = []
			for child: Node in building.get_children():
				if not child is ItemPortComponent:
					continue
				var port := child as ItemPortComponent
				var outward: Vector3 = (
					port.global_transform.basis * Vector3.FORWARD
				).normalized()

				# A one-unit conveyor attached to this port extends
				# a half unit from the physical building edge.
				var conveyor_center: Vector3 = (
					port.global_position
					+ outward * (FactoryGrid.CELL_SIZE * 0.5)
					- Vector3.UP * FactoryGrid.PORT_HEIGHT
				)
				assert(
					FactoryGrid.is_on_conveyor_grid(conveyor_center),
					"Off-grid port: %s %s at %s" % [
						names[building_index],
						port.name,
						str(conveyor_center)
					]
				)

				var tile := Vector2i(
					roundi(conveyor_center.x),
					roundi(conveyor_center.z)
				)
				assert(not centers.has(tile))
				centers.append(tile)
				actual_ports += 1

			assert(actual_ports == expected_port_counts[building_index])
			aligned_port_count += actual_ports
			building.free()

		print(
			"PASS ", names[building_index],
			": all four rotations and ",
			aligned_port_count,
			" physical port lanes aligned"
		)

	print("================================================")
	print("ALL 5 BUILDING TYPES AND 52 ROTATED PORT LANES PASSED")
	print("================================================")
