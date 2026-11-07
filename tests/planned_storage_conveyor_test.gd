extends Node3D

# =============================================================================
# PLANNED STORAGE CONVEYOR RESERVATION — DELAYED CONNECTION REGRESSION
# =============================================================================

func _ready() -> void:
	var storage := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(storage != null and ore != null)
	var site := ConstructionSite.new()
	assert(site.setup(storage, 10.0))
	site.position = Vector3(5.0, 0.0, 0.0)
	site.rotation_degrees.y = 90.0
	add_child(site)
	site.set_process(false)

	var input_marker := site.get_planned_port(true)
	var output_marker := site.get_planned_port(false)
	assert(input_marker != null and output_marker != null)
	assert(site.get_node_or_null("InputPort") == null)
	assert(site.get_node_or_null("InventoryComponent") == null)
	var sample := storage.building_scene.instantiate() as Node3D
	assert(sample != null)
	var expected_input := sample.get_node("InputPort") as ItemPortComponent
	var expected_output := sample.get_node("OutputPort") as ItemPortComponent
	assert(input_marker.transform.is_equal_approx(expected_input.transform))
	assert(output_marker.transform.is_equal_approx(expected_output.transform))
	sample.free()
	print("PASS A: Planned ports reproduce rotated Storage geometry without active inventories")

	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var cargo := belt.get_node("CargoInventory") as InventoryComponent
	assert(timer != null and cargo != null)
	timer.set_process(false)
	var preview := site.get_planned_belt_transform(belt, true)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(site.reserve_conveyor(belt, true))
	assert(not site.reserve_conveyor(belt, true))
	assert(site.get_reserved_conveyor(true) == belt)
	assert(belt.output_building_port == null)
	assert(belt.input_building_port == null)
	print("PASS B: Aligned belt reserves future input, but remains disconnected")

	var source := InventoryComponent.new()
	source.max_capacity = 10
	add_child(source)
	assert(source.add_item(ore, 2) == 2)
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	assert(transport.try_receive_from_inventory(source, ore))
	timer._process(1.1)
	assert(cargo.get_amount(ore) == 1)
	assert(source.get_amount(ore) == 1)
	assert(source.get_amount(ore) + cargo.get_amount(ore) == 2)
	print("PASS C: Cargo cannot unload into unfinished Storage; no items lost")

	var built: Array[Node3D] = []
	site.building_completed.connect(func(building: Node3D) -> void: built.append(building))
	site.lifecycle.advance(10.0)
	assert(built.size() == 1)
	var building := built[0]
	var input_port := building.get_node("InputPort") as ItemPortComponent
	var storage_inventory := building.get_node("InventoryComponent") as InventoryComponent
	assert(belt.output_building_port == input_port)
	assert(input_port.connected_conveyor == belt)
	assert(storage_inventory.get_amount(ore) == 0)
	print("PASS D: Completion converts reservation into a physical Storage connection")

	timer._process(0.01)
	assert(cargo.get_amount(ore) == 0)
	assert(storage_inventory.get_amount(ore) == 1)
	assert(source.get_amount(ore) + cargo.get_amount(ore) + storage_inventory.get_amount(ore) == 2)
	print("PASS E: Waiting cargo unloads only after completion; inventory conserved")

	# A second site demonstrates that moved belts are rejected at activation.
	var other_site := ConstructionSite.new()
	assert(other_site.setup(storage, 10.0))
	other_site.position = Vector3(-5.0, 0.0, 0.0)
	add_child(other_site)
	other_site.set_process(false)
	var moved_belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	add_child(moved_belt)
	var other_preview := other_site.get_planned_belt_transform(moved_belt, true)
	assert(other_preview.has("transform"))
	moved_belt.global_transform = other_preview["transform"]
	assert(other_site.reserve_conveyor(moved_belt, true))
	moved_belt.position += Vector3(1.0, 0.0, 0.0)
	var second: Array[Node3D] = []
	other_site.building_completed.connect(func(new_building: Node3D) -> void: second.append(new_building))
	other_site.lifecycle.advance(10.0)
	assert(second.size() == 1)
	assert(moved_belt.output_building_port == null)
	assert((second[0].get_node("InputPort") as ItemPortComponent).connected_conveyor == null)
	print("PASS F: Moved reservation cannot force an invalid connection")

	print("ALL 6 PLANNED STORAGE CONVEYOR RESERVATION CHECKS PASSED")
