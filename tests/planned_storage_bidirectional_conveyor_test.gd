extends Node3D

# =============================================================================
# PLANNED STORAGE — BIDIRECTIONAL CONVEYOR ACTIVATION REGRESSION
# =============================================================================
# Verifies that planned input and output reservations remain non-operational
# until the same Storage site completes. Checks transport and cargo conservation
# without changing live Build Mode or existing conveyor timing behavior.

func _ready() -> void:
	var storage := load("res://data/buildings/test_storage.tres") as BuildingDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	assert(storage != null and ore != null)

	var site := ConstructionSite.new()
	assert(site.setup(storage, 10.0))
	site.position = Vector3(4.0, 0.0, 2.0)
	site.rotation_degrees.y = 90.0
	add_child(site)
	site.set_process(false)
	assert(site.get_planned_port(true) != null)
	assert(site.get_planned_port(false) != null)
	assert(site.get_node_or_null("InventoryComponent") == null)
	assert(site.get_node_or_null("InputPort") == null)
	assert(site.get_node_or_null("OutputPort") == null)
	print("PASS A: Rotated site exposes two planned markers, no active ports")

	var inbound := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	var outbound := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(inbound != null and outbound != null)
	add_child(inbound)
	add_child(outbound)
	var inbound_timer := inbound.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var outbound_timer := outbound.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(inbound_timer != null and outbound_timer != null)
	inbound_timer.set_process(false)
	outbound_timer.set_process(false)

	var input_preview := site.get_planned_belt_transform(inbound, true)
	var output_preview := site.get_planned_belt_transform(outbound, false)
	assert(input_preview.has("transform") and output_preview.has("transform"))
	inbound.global_transform = input_preview["transform"]
	outbound.global_transform = output_preview["transform"]
	var input_found := PlannedConveyorPortFinder.find_nearest_preview(
		inbound, site.get_planned_port(true).global_position
	)
	var output_found := PlannedConveyorPortFinder.find_nearest_preview(
		outbound, site.get_planned_port(false).global_position
	)
	assert(input_found.get("site") == site and bool(input_found.get("input_side", false)))
	assert(output_found.get("site") == site and not bool(output_found.get("input_side", true)))
	assert(site.reserve_conveyor(inbound, true))
	assert(site.reserve_conveyor(outbound, false))
	assert(not site.reserve_conveyor(inbound, true))
	assert(not site.reserve_conveyor(outbound, false))
	print("PASS B: Input and output hard-snap independently with exclusive reservations")

	var supply := InventoryComponent.new()
	supply.max_capacity = 10
	add_child(supply)
	assert(supply.add_item(ore, 3) == 3)
	var inbound_transport := inbound.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var inbound_cargo := inbound.get_node("CargoInventory") as InventoryComponent
	var outbound_cargo := outbound.get_node("CargoInventory") as InventoryComponent
	assert(inbound_transport != null and inbound_cargo != null and outbound_cargo != null)
	assert(inbound_transport.try_receive_from_inventory(supply, ore))
	inbound_timer._process(1.1)
	outbound_timer._process(1.1)
	assert(inbound_cargo.get_amount(ore) == 1)
	assert(outbound_cargo.get_amount(ore) == 0)
	assert(supply.get_amount(ore) == 2)
	assert(inbound.output_building_port == null)
	assert(outbound.input_building_port == null)
	assert(not ConveyorBuildingTransfer.try_load_into_belt(outbound))
	print("PASS C: Unfinished Storage neither receives nor supplies operational cargo")

	var completed: Array[Node3D] = []
	site.building_completed.connect(
		func(building: Node3D) -> void: completed.append(building)
	)
	site.lifecycle.advance(10.0)
	assert(completed.size() == 1)
	var building := completed[0]
	var input_port := building.get_node("InputPort") as ItemPortComponent
	var output_port := building.get_node("OutputPort") as ItemPortComponent
	var inventory := building.get_node("InventoryComponent") as InventoryComponent
	assert(input_port != null and output_port != null and inventory != null)
	assert(inbound.output_building_port == input_port)
	assert(outbound.input_building_port == output_port)
	assert(input_port.connected_conveyor == inbound)
	assert(output_port.connected_conveyor == outbound)
	assert(inventory.get_amount(ore) == 0)
	print("PASS D: Completion activates both valid reciprocal physical port links")

	inbound_timer._process(0.01)
	assert(inbound_cargo.get_amount(ore) == 0)
	assert(inventory.get_amount(ore) == 1)
	assert(supply.get_amount(ore) + inbound_cargo.get_amount(ore)
		+ inventory.get_amount(ore) + outbound_cargo.get_amount(ore) == 3)
	print("PASS E: Waiting input cargo enters completed Storage without duplication")

	outbound_timer._process(0.01)
	assert(inventory.get_amount(ore) == 0)
	assert(outbound_cargo.get_amount(ore) == 1)
	assert(supply.get_amount(ore) + inbound_cargo.get_amount(ore)
		+ inventory.get_amount(ore) + outbound_cargo.get_amount(ore) == 3)
	print("PASS F: Completed Storage output loads the reserved belt and conserves cargo")

	outbound_timer._process(1.1)
	assert(outbound_cargo.get_amount(ore) == 1)
	assert(not outbound.can_demolish_safely())
	assert(inbound.can_demolish_safely())
	print("PASS G: Unrouted output cargo stays buffered and is protected from demolition")

	assert(outbound.disconnect_building_port(output_port))
	assert(outbound.input_building_port == null)
	assert(output_port.connected_conveyor == null)
	assert(inbound.output_building_port == input_port)
	assert(outbound_cargo.get_amount(ore) == 1)
	assert(supply.get_amount(ore) + inbound_cargo.get_amount(ore)
		+ inventory.get_amount(ore) + outbound_cargo.get_amount(ore) == 3)
	print("PASS H: Disconnect preserves cargo and the independent input connection")

	print("ALL 8 PLANNED STORAGE BIDIRECTIONAL CONVEYOR CHECKS PASSED")
