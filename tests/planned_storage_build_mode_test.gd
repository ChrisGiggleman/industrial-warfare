extends Node

# =============================================================================
# FACTORY SANDBOX — PLANNED BELT WORLD INTERACTION REGRESSION
# =============================================================================
# Verifies that the sandbox controller creates a waiting conveyor and
# construction completion establishes its port without duplicating cargo.

func _ready() -> void:
	var packed := load(
		"res://scenes/core/factory_testing_sandbox.tscn"
	) as PackedScene
	assert(packed != null)
	var world := packed.instantiate() as Node3D
	add_child(world)
	var controller = world.get_node("WorldInteraction")
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	assert(zombie.process_mode == Node.PROCESS_MODE_DISABLED)
	assert(controller.enable_planned_storage_conveyor_snap)
	assert(controller.enable_timed_storage_construction)
	print("PASS A: Planned snapping enabled only in factory-testing sandbox")

	var definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(definition != null and ore != null)
	controller.storage_construction_seconds = 10.0
	var site := controller._place_timed_storage_site(
		definition,
		Transform3D(
			Basis(Vector3.UP, deg_to_rad(90.0)),
			Vector3(-3.0, 0.0, 1.0)
		)
	) as ConstructionSite
	assert(site != null)
	site.set_process(false)
	assert(site.get_planned_port(true) != null)
	print("PASS B: WorldInteraction places timed Storage with planned ports")

	var preview_belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	world.add_child(preview_belt)
	(preview_belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer).set_process(false)
	var proposed := site.get_planned_belt_transform(preview_belt, true)
	assert(proposed.has("transform"))
	preview_belt.global_transform = proposed["transform"]
	var matched := PlannedConveyorPortFinder.find_nearest_preview(
		preview_belt, preview_belt.global_position
	)
	assert(matched.get("site") == site)
	assert(bool(matched.get("input_side", false)))
	preview_belt.queue_free()
	var pending := controller._commit_planned_storage_belt(
		site, true, proposed["transform"]
	) as ConveyorSegment
	assert(pending != null)
	var timer := pending.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	timer.set_process(false)
	assert(site.get_reserved_conveyor(true) == pending)
	assert(pending.output_building_port == null)
	print("PASS C: Controller reserves a belt without an early building connection")

	var source := InventoryComponent.new()
	source.max_capacity = 10
	world.add_child(source)
	assert(source.add_item(ore, 2) == 2)
	var transport := pending.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var cargo := pending.get_node("CargoInventory") as InventoryComponent
	assert(transport.try_receive_from_inventory(source, ore))
	timer._process(1.1)
	assert(cargo.get_amount(ore) == 1)
	assert(source.get_amount(ore) == 1)
	print("PASS D: Pending belt retains its ore while Storage is unfinished")

	var completed: Array[Node3D] = []
	site.building_completed.connect(
		func(building: Node3D) -> void: completed.append(building)
	)
	site.lifecycle.advance(10.0)
	assert(completed.size() == 1)
	var storage := completed[0]
	var input_port := storage.get_node("InputPort") as ItemPortComponent
	var inventory := storage.get_node("InventoryComponent") as InventoryComponent
	assert(pending.output_building_port == input_port)
	assert(input_port.connected_conveyor == pending)
	timer._process(0.01)
	assert(inventory.get_amount(ore) == 1)
	assert(cargo.get_amount(ore) == 0)
	assert(source.get_amount(ore) + cargo.get_amount(ore) + inventory.get_amount(ore) == 2)
	print("PASS E: Completed Storage receives pending cargo with full conservation")

	var main := load("res://scenes/core/main.tscn") as PackedScene
	var main_instance := main.instantiate() as Node3D
	assert(not main_instance.get_node("WorldInteraction").enable_planned_storage_conveyor_snap)
	main_instance.free()
	print("PASS F: Main scene retains normal conveyor placement settings")

	world.queue_free()
	print("ALL 6 PLANNED STORAGE BUILD MODE INTEGRATION CHECKS PASSED")
