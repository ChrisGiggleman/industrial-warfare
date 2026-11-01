extends Node

# =============================================================================
# PHYSICAL AMMUNITION SUPPLY AND TURRET FIRING REGRESSION
# =============================================================================

# Isolated test of ammunition-only input, physical belt delivery, one-round
# firing, cooldown, magazine backpressure, and safe demolition.
# Target acquisition, projectiles and damage are intentionally out of scope.


func _load_round(
	supply: InventoryComponent,
	belt: ConveyorSegment,
	rounds: ItemDefinition
) -> bool:
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	if not transport.try_receive_from_inventory(supply, rounds):
		return false
	return timer.advance_transport(1.01)


func _ready() -> void:
	print("\n===== PROTOTYPE DEFENSIVE TURRET REGRESSION =====")

	var rounds := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var definition := load(
		"res://data/buildings/prototype_defensive_turret.tres"
	) as BuildingDefinition
	assert(rounds != null and ore != null and ingot != null)
	assert(definition != null and definition.building_scene != null)
	assert(definition.footprint_tiles == Vector2i.ONE)
	print("PASS A: Turret building and ammunition resources loaded")

	var root := Node3D.new()
	add_child(root)
	var turret_building := definition.building_scene.instantiate() as Node3D
	assert(turret_building != null)
	root.add_child(turret_building)
	var magazine := (
		turret_building.get_node("AmmunitionInventory")
		as InventoryComponent
	)
	var turret := (
		turret_building.get_node("TurretComponent")
		as DefensiveTurretComponent
	)
	var ammo_port := (
		turret_building.get_node("InputPort")
		as TurretAmmunitionPort
	)
	assert(magazine != null and turret != null and ammo_port != null)
	turret.set_process(false)
	assert(magazine.max_capacity == 40)
	assert(turret.ammunition_inventory == magazine)
	assert(turret.ammunition_item == rounds)
	assert(ammo_port.inventory == magazine)
	assert(ammo_port.accepted_ammunition == rounds)
	assert(ammo_port.direction == ItemPortComponent.PortDirection.INPUT)
	assert(ammo_port.can_accept_item(rounds, 1))
	assert(not ammo_port.can_accept_item(ore, 1))
	assert(not ammo_port.can_accept_item(ingot, 1))
	assert(not ammo_port.can_accept_item(rounds, 41))
	print("PASS B: Ammo-only port accepts rounds and refuses all other materials")

	var belt := ConveyorPieceSelector.STRAIGHT_SCENE.instantiate() as ConveyorSegment
	assert(belt != null)
	root.add_child(belt)
	var timer := belt.get_node("ConveyorTransportTimer") as ConveyorTransportTimer
	var transport := belt.get_node("ConveyorTransportComponent") as ConveyorTransportComponent
	var cargo := belt.get_node("CargoInventory") as InventoryComponent
	assert(timer != null and transport != null and cargo != null)
	timer.set_process(false)
	timer.travel_interval = 1.0
	var preview := ConveyorBuildingSnap.get_preview_transform(ammo_port, belt)
	assert(preview.has("transform"))
	belt.global_transform = preview["transform"]
	assert(belt.try_connect_building_port(ammo_port))
	assert(ammo_port.connected_conveyor == belt)
	assert(belt.output_building_port == ammo_port)
	print("PASS C: Existing physical conveyor connects to turret ammo input")

	var supply := InventoryComponent.new()
	supply.max_capacity = 10
	root.add_child(supply)
	assert(supply.add_item(rounds, 3) == 3)
	assert(supply.add_item(ore, 1) == 1)
	assert(transport.try_receive_from_inventory(supply, ore))
	assert(not timer.advance_transport(1.01))
	assert(timer.transport_status == "Blocked")
	assert(cargo.get_amount(ore) == 1)
	assert(magazine.get_amount(ore) == 0)
	assert(cargo.transfer_to(supply, ore, 1) == 1)
	assert(not timer.advance_transport(0.01))
	assert(supply.get_amount(ore) == 1)
	print("PASS D: Incorrect ore remains on the belt until recovered")

	assert(not turret.try_fire())
	assert(turret.shots_fired == 0)
	assert(turret.stored_ammunition() == 0)
	assert(turret.firing_status == "Out of Ammo")
	assert(_load_round(supply, belt, rounds))
	assert(magazine.get_amount(rounds) == 1)
	assert(turret.try_fire())
	assert(turret.shots_fired == 1)
	assert(magazine.get_amount(rounds) == 0)
	assert(turret.cooldown_remaining > 0.0)
	print("PASS E: Firing fails empty, then consumes exactly one delivered round")

	assert(_load_round(supply, belt, rounds))
	assert(not turret.try_fire())
	assert(magazine.get_amount(rounds) == 1)
	turret._process(0.5)
	assert(not turret.try_fire())
	turret._process(0.5)
	assert(turret.is_ready_to_fire())
	assert(turret.try_fire())
	assert(turret.shots_fired == 2)
	assert(magazine.get_amount(rounds) == 0)
	print("PASS F: Cooldown blocks repeat shots without consuming extra ammo")

	assert(_load_round(supply, belt, rounds))
	turret._process(1.0)
	assert(turret.try_fire())
	assert(turret.shots_fired == 3)
	assert(magazine.get_amount(rounds) == 0)
	assert(supply.get_amount(rounds) == 0)
	print("PASS G: Three supplied rounds produce exactly three test firings")

	# =============================================================================
	# MAGAZINE BACKPRESSURE AND RECOVERY
	# =============================================================================

	magazine.max_capacity = 1
	assert(supply.add_item(rounds, 2) == 2)
	assert(_load_round(supply, belt, rounds))
	assert(magazine.get_amount(rounds) == 1)
	assert(not ammo_port.can_accept_item(rounds, 1))
	assert(transport.try_receive_from_inventory(supply, rounds))
	assert(not timer.advance_transport(1.01))
	assert(timer.transport_status == "Blocked")
	assert(cargo.get_amount(rounds) == 1)
	assert(magazine.get_amount(rounds) == 1)
	turret._process(1.0)
	assert(turret.try_fire())
	assert(turret.shots_fired == 4)
	assert(magazine.get_amount(rounds) == 0)
	assert(timer.advance_transport(0.01))
	assert(cargo.get_amount(rounds) == 0)
	assert(magazine.get_amount(rounds) == 1)
	print("PASS H: Full magazine retains belt cargo; delivery resumes after firing")

	assert(not turret_building.call("can_demolish_safely"))
	turret._process(1.0)
	assert(turret.try_fire())
	assert(turret.shots_fired == 5)
	assert(turret.stored_ammunition() == 0)
	assert(turret_building.call("can_demolish_safely"))
	assert(supply.get_amount(rounds) == 0)
	assert(cargo.get_amount(rounds) == 0)
	assert(magazine.get_amount(rounds) == 0)
	print("PASS I: Loaded turret blocks demolition and all five rounds are accounted for")

	turret_building.queue_free()
	await get_tree().process_frame
	assert(belt.is_inside_tree())
	assert(not is_instance_valid(belt.output_building_port))
	print("PASS J: Removing an empty turret safely disconnects its conveyor port")

	root.queue_free()
	print("===================================================")
	print("ALL 10 DEFENSIVE TURRET AMMUNITION TESTS PASSED")
	print("===================================================")
