extends Node

# =============================================================================
# PROTOTYPE AMMUNITION PRESS — PHYSICAL PRODUCTION REGRESSION
# =============================================================================

# Tests ingot-only input acceptance, conveyor delivery, recipe conversion,
# full-output backpressure, belt-driven unloading, and item conservation.
# The prototype ratio (1 ingot -> 4 rounds) is a temporary balance value.


func _belt(parent: Node3D) -> ConveyorSegment:
	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	parent.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	return belt


func _attach_port(
	port: ItemPortComponent,
	belt: ConveyorSegment
) -> void:
	var preview := ConveyorBuildingSnap.get_preview_transform(port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(port))


func _receive_from_source(
	source: InventoryComponent,
	belt: ConveyorSegment,
	item: ItemDefinition
) -> bool:
	var transport := (
		belt.get_node("ConveyorTransportComponent")
		as ConveyorTransportComponent
	)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	if not transport.try_receive_from_inventory(source, item):
		return false
	return timer.advance_transport(1.01)


func _export_round(
	belt: ConveyorSegment,
	rounds: ItemDefinition
) -> bool:
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var cargo := belt.get_node("CargoInventory") as InventoryComponent
	if not ConveyorBuildingTransfer.try_load_into_belt(belt):
		return false
	assert(cargo.get_amount(rounds) == 1)
	return timer.advance_transport(1.01)


func _ready() -> void:
	print("\n===== PROTOTYPE AMMUNITION PRESS REGRESSION =====")

	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var rounds := load("res://data/items/prototype_ammunition.tres") as ItemDefinition
	var ammo_recipe := load(
		"res://data/recipes/prototype_ammunition_press.tres"
	) as ProductionRecipe
	var building_definition := load(
		"res://data/buildings/prototype_ammunition_press.tres"
	) as BuildingDefinition
	assert(
		ore != null and ingot != null and rounds != null
		and ammo_recipe != null and building_definition != null
	)
	assert(ammo_recipe.inputs.size() == 1 and ammo_recipe.outputs.size() == 1)
	assert(ammo_recipe.inputs[0].item == ingot)
	assert(ammo_recipe.inputs[0].amount == 1)
	assert(ammo_recipe.outputs[0].item == rounds)
	assert(ammo_recipe.outputs[0].amount == 4)
	assert(building_definition.footprint_tiles == Vector2i(2, 2))
	print("PASS A: Data-defined ingot-to-ammunition recipe and building loaded")

	var parent := Node3D.new()
	add_child(parent)
	var press := building_definition.building_scene.instantiate() as Node3D
	assert(press != null)
	parent.add_child(press)
	var input_port := press.get_node("InputPort") as ItemPortComponent
	var output_port := press.get_node("OutputPort") as ItemPortComponent
	var input_inventory := press.get_node("InputInventory") as InventoryComponent
	var output_inventory := press.get_node("OutputInventory") as InventoryComponent
	var producer := press.get_node("ProducerComponent") as ProducerComponent
	assert(
		input_port != null and output_port != null
		and input_inventory != null and output_inventory != null
		and producer != null
	)
	producer.set_process(false)
	assert(producer.recipe == ammo_recipe)
	assert(producer.available_recipes.has(ammo_recipe))
	assert(producer.accepts_input_item(ingot))
	assert(not producer.accepts_input_item(ore))
	assert(not producer.accepts_input_item(rounds))
	assert(input_port.direction == ItemPortComponent.PortDirection.INPUT)
	assert(output_port.direction == ItemPortComponent.PortDirection.OUTPUT)
	print("PASS B: Machine accepts only active-recipe ingots at input")

	var incoming := _belt(parent)
	var outgoing := _belt(parent)
	_attach_port(input_port, incoming)
	_attach_port(output_port, outgoing)
	assert(input_port.connected_conveyor == incoming)
	assert(output_port.connected_conveyor == outgoing)

	var warehouse_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var warehouse := warehouse_scene.instantiate() as Node3D
	assert(warehouse != null)
	parent.add_child(warehouse)
	var destination := warehouse.get_node("InputPort") as ItemPortComponent
	var warehouse_inventory := (
		warehouse.get_node("InventoryComponent") as InventoryComponent
	)
	assert(destination != null and warehouse_inventory != null)
	var outgoing_endpoint := outgoing.get_node("OutputEndpoint") as Marker3D
	var aligned: bool = false
	for quarter: int in range(4):
		warehouse.rotation_degrees.y = float(quarter * 90)
		if (
			(outgoing_endpoint.global_transform.basis * Vector3.FORWARD).normalized().dot(
				(destination.global_transform.basis * Vector3.FORWARD).normalized()
			) > -0.98
		):
			continue
		warehouse.global_position = (
			outgoing_endpoint.global_position
			- warehouse.global_transform.basis * destination.position
		)
		if LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing_endpoint, destination, ConveyorSegment.CONNECTION_GAP
		):
			aligned = true
			break
	assert(aligned)
	assert(outgoing.try_connect_building_port(destination))
	print("PASS C: Two physical ports and receiving warehouse connected")

	var supply := InventoryComponent.new()
	supply.max_capacity = 10
	parent.add_child(supply)
	assert(supply.add_item(ingot, 2) == 2)
	var incoming_cargo := incoming.get_node("CargoInventory") as InventoryComponent
	assert(incoming_cargo != null)
	assert(incoming_cargo.add_item(ore, 1) == 1)
	var incoming_timer := (
		incoming.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	)
	assert(not incoming_timer.advance_transport(1.01))
	assert(incoming_cargo.get_amount(ore) == 1)
	assert(input_inventory.get_amount(ore) == 0)
	assert(incoming_cargo.remove_item(ore, 1))
	print("PASS D: Incorrect raw material is blocked without being consumed")

	assert(_receive_from_source(supply, incoming, ingot))
	assert(_receive_from_source(supply, incoming, ingot))
	assert(input_inventory.get_amount(ingot) == 2)
	assert(supply.get_amount(ingot) == 0)
	assert(not producer.accepts_input_item(ore))
	print("PASS E: Two ingots entered through the connected conveyor")

	# Fixture: allow exactly one four-round batch in output storage.
	output_inventory.max_capacity = 4
	producer._process(2.01)
	assert(input_inventory.get_amount(ingot) == 1)
	assert(output_inventory.get_amount(rounds) == 4)
	assert(producer.has_required_inputs())
	producer._process(2.01)
	assert(producer.production_status == "Output Blocked")
	assert(input_inventory.get_amount(ingot) == 1)
	assert(output_inventory.get_amount(rounds) == 4)
	print("PASS F: Full ammo output retains the next ingot without production")

	for i: int in range(4):
		assert(_export_round(outgoing, rounds))
	assert(output_inventory.get_amount(rounds) == 0)
	assert(warehouse_inventory.get_amount(rounds) == 4)
	assert(producer.can_store_recipe_outputs())
	print("PASS G: Ammo moves by conveyor to warehouse and clears backpressure")

	producer._process(2.01)
	assert(input_inventory.get_amount(ingot) == 0)
	assert(output_inventory.get_amount(rounds) == 4)
	for i: int in range(4):
		assert(_export_round(outgoing, rounds))
	assert(output_inventory.get_amount(rounds) == 0)
	assert(warehouse_inventory.get_amount(rounds) == 8)
	print("PASS H: Production recovers and exports a second four-round batch")

	var ingot_equivalents: int = (
		supply.get_amount(ingot) * 4
		+ input_inventory.get_amount(ingot) * 4
		+ incoming_cargo.get_amount(ingot) * 4
		+ output_inventory.get_amount(rounds)
		+ (outgoing.get_node("CargoInventory") as InventoryComponent).get_amount(rounds)
		+ warehouse_inventory.get_amount(rounds)
	)
	assert(ingot_equivalents == 8)
	assert(warehouse_inventory.get_amount(rounds) == 8)
	assert(supply.get_total_amount() == 0)
	print("PASS I: Two ingots conserved as eight delivered prototype rounds")

	parent.queue_free()
	print("=====================================================")
	print("ALL 9 PROTOTYPE AMMUNITION PRESS TESTS PASSED")
	print("=====================================================")
