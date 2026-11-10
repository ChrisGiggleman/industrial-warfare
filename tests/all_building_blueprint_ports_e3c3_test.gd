extends Node3D

# =============================================================================
# E3C3 — ALL FACTORY BLUEPRINT PORT DISCOVERY
# =============================================================================
# Checks named future ports, valid belt transforms, and safe cancellation.
# Full connection activation and cargo conservation remain separate gates.

const BUILDING_CASES: Array[Dictionary] = [
	{"path": "res://data/buildings/test_extractor.tres", "inputs": 0, "outputs": 1},
	{"path": "res://data/buildings/test_storage.tres", "inputs": 1, "outputs": 1},
	{"path": "res://data/buildings/test_smelter.tres", "inputs": 1, "outputs": 1},
	{"path": "res://data/buildings/conveyor_merger.tres", "inputs": 3, "outputs": 1},
	{"path": "res://data/buildings/conveyor_splitter.tres", "inputs": 1, "outputs": 3},
	{"path": "res://data/buildings/prototype_ammunition_press.tres", "inputs": 1, "outputs": 1},
	{"path": "res://data/buildings/prototype_defensive_turret.tres", "inputs": 1, "outputs": 0}
]


func _ready() -> void:
	var world_scene := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(world_scene != null)
	var world := world_scene.instantiate() as Node3D
	add_child(world)
	var controller := world.get_node("WorldInteraction")
	controller.set_process(false)
	assert(controller.enable_connected_storage_blueprints)
	var coordinator := controller.get_node(
		"BlueprintRouteCoordinator"
	) as BlueprintConveyorRouteCoordinator
	assert(coordinator != null)
	assert(is_instance_valid(coordinator.port_registry))
	controller._toggle_placement_mode()
	assert(controller._toggle_blueprint_mode())
	controller._select_building(
		controller._find_definition_index(&"conveyor_belt")
	)
	var preview := controller.placement_ghost as ConveyorSegment
	assert(is_instance_valid(preview))
	var total_ports: int = 0

	for case_data: Dictionary in BUILDING_CASES:
		var definition := load(case_data["path"]) as BuildingDefinition
		assert(definition != null)
		var site := controller._create_blueprint_site(
			definition, Transform3D.IDENTITY
		) as ConstructionSite
		assert(site != null)
		site.set_process(false)
		var inputs: Array[StringName] = site.get_planned_port_names(true)
		var outputs: Array[StringName] = site.get_planned_port_names(false)
		assert(inputs.size() == int(case_data["inputs"]))
		assert(outputs.size() == int(case_data["outputs"]))
		for port_name: StringName in inputs + outputs:
			var input_side: bool = str(port_name).begins_with("InputPort")
			var marker := site.get_planned_port_named(port_name)
			assert(is_instance_valid(marker))
			assert(not coordinator.port_registry.has_building_claim(
				site, input_side, port_name
			))
			var proposed: Dictionary = site.get_planned_belt_transform_named(
				preview, port_name
			)
			assert(proposed.has("transform"))
			var transform: Transform3D = proposed["transform"]
			assert(transform.origin.is_finite())
			total_ports += 1
			print("PASS PORT: ", definition.display_name, " / ", port_name)
		assert(controller._cancel_blueprint_site(site))
		await get_tree().process_frame
		assert(not is_instance_valid(site))
	print("PASS: All seven port-bearing factory blueprints discovered")
	assert(total_ports == 16)
	print("ALL 16 E3C3 FACTORY BLUEPRINT PORTS DISCOVERED")
