extends Node

# =============================================================================
# CONVEYOR DURABILITY HUD — SELECTION AND DESTRUCTION REGRESSION
# =============================================================================

# Tests the actual Main-world Production Debug HUD and WorldInteraction
# selection logic with all three conveyor shapes. Combat and transfer
# processing are not changed by this read-only display milestone.


func _make_belt(world: Node3D, scene: PackedScene) -> ConveyorSegment:
	var belt := scene.instantiate() as ConveyorSegment
	assert(belt != null)
	world.add_child(belt)
	var timer := belt.get_node_or_null(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	if is_instance_valid(timer):
		timer.set_process(false)
	return belt


func _ready() -> void:
	print("\n===== CONVEYOR HEALTH AND CARGO HUD REGRESSION =====")

	var main_scene := load("res://scenes/core/main.tscn") as PackedScene
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var rounds := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	assert(
		main_scene != null and storage_scene != null
		and ore != null and rounds != null
	)

	var world := main_scene.instantiate() as Node3D
	add_child(world)
	var hud := world.get_node("ProductionDebugHUD") as ProductionDebugHUD
	var interaction := world.get_node("WorldInteraction")
	var service := world.get_node(
		"WorldDestructionService"
	) as WorldDestructionService
	var zombie := world.get_node("PrototypeMovingZombie") as Node3D
	assert(
		hud != null and interaction != null
		and service != null and zombie != null
	)
	(zombie.get_node("MovementComponent") as ZombieApproachComponent).set_physics_process(false)
	(zombie.get_node("MeleeComponent") as ZombieMeleeComponent).set_physics_process(false)
	hud.clear_selection()
	assert(hud.info_label.text.contains("No object selected"))
	print("PASS A: Main HUD and selection start without a selected object")

	var first := _make_belt(
		world, ConveyorPieceSelector.STRAIGHT_SCENE
	)
	var second := _make_belt(
		world, ConveyorPieceSelector.STRAIGHT_SCENE
	)
	var right := _make_belt(
		world, ConveyorPieceSelector.RIGHT_CORNER_SCENE
	)
	var left := _make_belt(
		world, ConveyorPieceSelector.LEFT_CORNER_SCENE
	)
	right.global_position = Vector3(30, 0, 30)
	left.global_position = Vector3(35, 0, 30)
	for belt: ConveyorSegment in [first, second, right, left]:
		var health := belt.get_node(
			"ConveyorHealthComponent"
		) as ConveyorHealthComponent
		assert(health != null and health.current_health == 50)
		assert(
			belt.get_node_or_null("CargoInventory")
			is InventoryComponent
		)
	print("PASS B: All straight and corner conveyor scenes have health and cargo")

	interaction.call("_select_object", first)
	hud._process(0.0)
	assert(interaction.get("selected_object") == first)
	assert(hud.selected_building == first)
	assert(first.is_selected)
	assert(hud.info_label.text.contains("Type: Conveyor Belt"))
	assert(hud.info_label.text.contains("CONVEYOR DURABILITY"))
	assert(hud.info_label.text.contains("HP: 50 / 50"))
	assert(hud.info_label.text.contains("Status: Intact"))
	print("PASS C: Clicking a straight belt shows its current 50-HP durability")

	assert(hud.info_label.text.contains("CARGO STATUS"))
	assert(hud.info_label.text.contains("Capacity: 0 / 1"))
	assert(hud.info_label.text.contains("Cargo: Empty"))
	assert(hud.info_label.text.contains("Input: Disconnected"))
	assert(hud.info_label.text.contains("Output: Disconnected"))
	assert(not hud.activity_progress_bar.visible)
	print("PASS D: Empty isolated belt shows cargo, links and no production bar")

	var first_health := first.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(first_health.take_damage(10) == 10)
	hud._process(0.0)
	assert(hud.info_label.text.contains("HP: 40 / 50"))
	assert(hud.info_label.text.contains("Status: Intact"))
	assert(first_health.total_damage_taken == 10)
	print("PASS E: Selected conveyor HP updates when zombie-style damage occurs")

	var first_cargo := first.get_node(
		"CargoInventory"
	) as InventoryComponent
	assert(first_cargo.add_item(rounds, 1) == 1)
	hud._process(0.0)
	assert(hud.info_label.text.contains("Capacity: 1 / 1"))
	assert(hud.info_label.text.contains("Cargo: " + rounds.display_name + " x1"))
	assert(first_cargo.get_amount(rounds) == 1)
	print("PASS F: Cargo display updates from actual physical belt inventory")

	var storage := storage_scene.instantiate() as Node3D
	world.add_child(storage)
	storage.global_position = Vector3(24, 0, 24)
	var output_port := storage.get_node("OutputPort") as ItemPortComponent
	var snap := ConveyorBuildingSnap.get_preview_transform(
		output_port, first
	)
	assert(snap.has("transform"))
	first.global_transform = snap["transform"]
	assert(first.try_connect_building_port(output_port))
	var next_snap := second.get_snap_preview_transform_after(first)
	assert(next_snap.has("transform"))
	second.global_transform = next_snap["transform"]
	assert(first.try_connect_to(second))
	hud._process(0.0)
	assert(hud.info_label.text.contains("Input: Building port"))
	assert(hud.info_label.text.contains("Output: Next conveyor"))
	print("PASS G: Selected belt displays real building and downstream links")

	interaction.call("_select_object", second)
	hud._process(0.0)
	assert(hud.selected_building == second)
	assert(second.is_selected and not first.is_selected)
	assert(hud.info_label.text.contains("Input: Previous conveyor"))
	assert(hud.info_label.text.contains("Output: Disconnected"))
	assert(hud.info_label.text.contains("HP: 50 / 50"))
	print("PASS H: Selecting a downstream belt shows previous-belt connection")

	var right_stock := right.get_node(
		"CargoInventory"
	) as InventoryComponent
	assert(right_stock.add_item(ore, 1) == 1)
	interaction.call("_select_object", right)
	hud._process(0.0)
	assert(hud.info_label.text.contains("CONVEYOR DURABILITY"))
	assert(hud.info_label.text.contains("HP: 50 / 50"))
	assert(hud.info_label.text.contains("Cargo: " + ore.display_name + " x1"))
	print("PASS I: Right corner has the same health and cargo HUD")

	interaction.call("_select_object", left)
	var left_hp := left.get_node(
		"ConveyorHealthComponent"
	) as ConveyorHealthComponent
	assert(left_hp.take_damage(20) == 20)
	hud._process(0.0)
	assert(hud.info_label.text.contains("HP: 30 / 50"))
	assert(hud.info_label.text.contains("Cargo: Empty"))
	assert(not hud.activity_progress_bar.visible)
	print("PASS J: Left corner shows partial damage without production progress")

	interaction.call("_select_object", first)
	assert(hud.selected_building == first)
	assert(first_health.take_damage(40) == 40)
	assert(first.is_queued_for_deletion())
	assert(service.successful_destructions == 1)
	assert(hud.selected_building == null)
	assert(interaction.get("selected_object") == null)
	assert(hud.info_label.text.contains("No object selected"))
	assert(output_port.connected_conveyor == null)
	assert(second.previous_segment == null)
	print("PASS K: Zero-HP selected belt clears HUD and unlinks its neighbors")

	await get_tree().process_frame
	assert(not is_instance_valid(first))
	assert(second.is_inside_tree())
	assert(storage.is_inside_tree())
	var caches := get_tree().get_nodes_in_group("salvage_caches")
	assert(caches.size() == 1)
	var salvage := caches[0] as WorldSalvageCache
	assert(salvage != null)
	assert(salvage.inventory.get_amount(rounds) == 1)
	interaction.call("_select_object", second)
	hud._process(0.0)
	assert(hud.info_label.text.contains("HP: 50 / 50"))
	assert(hud.info_label.text.contains("Input: Disconnected"))
	assert(hud.selected_building == second)
	print("PASS L: Destroyed belt's cargo survives; next belt remains selectable")

	world.queue_free()
	print("================================================")
	print("ALL 12 CONVEYOR HEALTH HUD TESTS PASSED")
	print("================================================")
