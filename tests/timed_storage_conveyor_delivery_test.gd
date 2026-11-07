extends Node3D

# =============================================================================
# TIMED STORAGE — PHYSICAL CONVEYOR DELIVERY REGRESSION
# =============================================================================
# Proves an unfinished site has no usable port, while completed Storage can
# accept a snapped physical belt and receive real cargo without duplication.

func _ready() -> void:
	var storage_definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(storage_definition != null and ore != null)

	var site := ConstructionSite.new()
	assert(site.setup(storage_definition, 10.0))
	site.position = Vector3(6.0, 0.0, 0.0)
	add_child(site)
	site.set_process(false)

	assert(site.get_node_or_null("InputPort") == null)
	assert(site.get_node_or_null("InventoryComponent") == null)
	site.lifecycle.advance(5.0)
	assert(is_equal_approx(site.get_progress(), 0.5))
	assert(not site.is_completed())
	print("PASS A: Half-built Storage exposes no inventory or physical ports")

	var finished: Array[Node3D] = []
	site.building_completed.connect(
		func(building: Node3D) -> void: finished.append(building)
	)
	site.lifecycle.advance(5.0)
	assert(finished.size() == 1)
	var building := finished[0]
	var port := building.get_node("InputPort") as ItemPortComponent
	var inventory := building.get_node("InventoryComponent") as InventoryComponent
	assert(port != null and inventory != null)
	assert(port.connected_conveyor == null)
	assert(inventory.get_amount(ore) == 0)
	print("PASS B: Construction completes with an empty, unconnected Storage port")

	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var cargo := belt.get_node("CargoInventory") as InventoryComponent
	assert(timer != null and cargo != null)
	timer.set_process(false)
	var preview: Dictionary = ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))
	assert(belt.output_building_port == port)
	assert(port.connected_conveyor == belt)
	print("PASS C: Snapped conveyor connects to completed Storage input port")

	var source := InventoryComponent.new()
	source.max_capacity = 10
	add_child(source)
	assert(source.add_item(ore, 3) == 3)
	var cargo_transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	assert(cargo_transport != null)
	# The transport timer first loads the belt, then dispatches its cargo.
	timer._process(0.01)
	assert(cargo.get_amount(ore) == 0)
	# A free-input belt needs a connected source, so load the physical
	# one-item cargo buffer explicitly without inventing source connections.
	assert(cargo_transport.try_receive_from_inventory(source, ore))
	assert(source.get_amount(ore) == 2)
	assert(cargo.get_amount(ore) == 1)
	assert(source.get_amount(ore) + cargo.get_amount(ore) + inventory.get_amount(ore) == 3)
	print("PASS D: One source item loaded into the real belt cargo buffer")

	timer._process(1.01)
	assert(cargo.get_amount(ore) == 0)
	assert(inventory.get_amount(ore) == 1)
	assert(source.get_amount(ore) + cargo.get_amount(ore) + inventory.get_amount(ore) == 3)
	print("PASS E: Physical belt delivered one ore with all three units conserved")

	assert(belt.disconnect_building_port(port))
	assert(port.connected_conveyor == null)
	assert(belt.output_building_port == null)
	assert(inventory.get_amount(ore) == 1)
	print("PASS F: Disconnection leaves completed Storage cargo intact")

	print("ALL 6 TIMED STORAGE PHYSICAL CONVEYOR CHECKS PASSED")
