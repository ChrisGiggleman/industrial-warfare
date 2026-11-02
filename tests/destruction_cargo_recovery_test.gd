extends Node

# =============================================================================
# DESTRUCTION CARGO RECOVERY — LOSSLESS ESCROW REGRESSION
# =============================================================================

# First destruction milestone: all items are recovered BEFORE deletion.
# A separate cache represents future world salvage, but is not yet
# a player-pickup object. No zombie damage or Main scene is modified.


func _make_belt(parent: Node3D) -> ConveyorSegment:
	var belt := (
		ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		as ConveyorSegment
	)
	assert(belt != null)
	parent.add_child(belt)
	var timer := belt.get_node(
		"ConveyorTransportTimer"
	) as ConveyorTransportTimer
	assert(timer != null)
	timer.set_process(false)
	return belt


func _ready() -> void:
	print("\n===== DESTRUCTION CARGO RECOVERY REGRESSION =====")

	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	var rounds := load(
		"res://data/items/prototype_ammunition.tres"
	) as ItemDefinition
	var storage_scene := load(
		"res://scenes/buildings/test_storage.tscn"
	) as PackedScene
	var press_scene := load(
		"res://scenes/buildings/prototype_ammunition_press.tscn"
	) as PackedScene
	assert(
		ore != null and ingot != null and rounds != null
		and storage_scene != null and press_scene != null
	)

	var world := Node3D.new()
	add_child(world)
	var cache := InventoryComponent.new()
	cache.name = "TestRecoveryCache"
	cache.max_capacity = 0
	world.add_child(cache)

	assert(not DestructionCargoRecovery.can_recover_all(null, cache))
	assert(not DestructionCargoRecovery.can_recover_all(world, cache))
	assert(not DestructionCargoRecovery.can_recover_all(cache, cache))
	assert(not DestructionCargoRecovery.recover_all(null, cache))
	assert(cache.get_total_amount() == 0)
	print("PASS A: Invalid and same-tree recovery destinations are rejected")

	var storage := storage_scene.instantiate() as Node3D
	assert(storage != null)
	world.add_child(storage)
	var stored := storage.get_node("InventoryComponent") as InventoryComponent
	assert(stored.add_item(ore, 7) == 7)
	assert(stored.add_item(rounds, 4) == 4)
	assert(stored.get_total_amount() == 11)
	var source_inventories := DestructionCargoRecovery.collect_inventories(storage)
	assert(source_inventories.size() == 1)
	assert(source_inventories[0] == stored)
	print("PASS B: Storage inventory is discovered once despite two ports")

	var small_cache := InventoryComponent.new()
	small_cache.max_capacity = 10
	world.add_child(small_cache)
	assert(not DestructionCargoRecovery.can_recover_all(storage, small_cache))
	assert(not DestructionCargoRecovery.recover_all(storage, small_cache))
	assert(stored.get_amount(ore) == 7)
	assert(stored.get_amount(rounds) == 4)
	assert(small_cache.get_total_amount() == 0)
	print("PASS C: Insufficient recovery capacity refuses partial item loss")

	var belt_a := _make_belt(world)
	var belt_b := _make_belt(world)
	var output := storage.get_node("OutputPort") as ItemPortComponent
	var preview := ConveyorBuildingSnap.get_preview_transform(output, belt_a)
	assert(preview.has("transform"))
	belt_a.global_transform = preview["transform"]
	assert(belt_a.try_connect_building_port(output))

	var next_preview := belt_b.get_snap_preview_transform_after(belt_a)
	assert(next_preview.has("transform"))
	belt_b.global_transform = next_preview["transform"]
	assert(belt_a.try_connect_to(belt_b))
	assert(belt_a.input_building_port == output)
	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)
	print("PASS D: Real warehouse port and two independent belts are connected")

	var cargo_a := belt_a.get_node("CargoInventory") as InventoryComponent
	var cargo_b := belt_b.get_node("CargoInventory") as InventoryComponent
	assert(cargo_a.add_item(ingot, 1) == 1)
	assert(cargo_b.add_item(rounds, 1) == 1)
	assert(DestructionCargoRecovery.can_recover_all(storage, cache))
	assert(DestructionCargoRecovery.recover_all(storage, cache))
	assert(stored.get_total_amount() == 0)
	assert(cache.get_amount(ore) == 7)
	assert(cache.get_amount(rounds) == 4)
	assert(cargo_a.get_amount(ingot) == 1)
	assert(cargo_b.get_amount(rounds) == 1)
	print("PASS E: Mixed Storage items move to cache; neighbor cargo untouched")

	assert(DestructionCargoRecovery.recover_all(storage, cache))
	assert(cache.get_amount(ore) == 7)
	assert(cache.get_amount(rounds) == 4)
	assert(cache.get_total_amount() == 11)
	assert(output.connected_conveyor == belt_a)
	print("PASS F: Repeating recovery neither duplicates items nor breaks links")

	storage.queue_free()
	await get_tree().process_frame
	assert(not is_instance_valid(output))
	assert(belt_a.is_inside_tree() and belt_b.is_inside_tree())
	assert(not is_instance_valid(belt_a.input_building_port))
	assert(belt_a.next_segment == belt_b)
	assert(belt_b.previous_segment == belt_a)
	assert(cache.get_total_amount() == 11)
	print("PASS G: After source removal, local port clears; both belts survive")

	var press := press_scene.instantiate() as Node3D
	assert(press != null)
	world.add_child(press)
	var input := press.get_node("InputInventory") as InventoryComponent
	var finished := press.get_node("OutputInventory") as InventoryComponent
	var producer := press.get_node("ProducerComponent") as ProducerComponent
	assert(producer != null)
	producer.set_process(false)
	assert(input.add_item(ingot, 2) == 2)
	assert(finished.add_item(rounds, 4) == 4)
	assert(DestructionCargoRecovery.collect_inventories(press).size() == 2)

	# Unknown item identity must fail BEFORE any source is drained.
	input.items["bad_item_key"] = 1
	assert(not DestructionCargoRecovery.can_recover_all(press, cache))
	assert(not DestructionCargoRecovery.recover_all(press, cache))
	assert(input.get_amount(ingot) == 2)
	assert(finished.get_amount(rounds) == 4)
	assert(cache.get_amount(ingot) == 0)
	input.items.erase("bad_item_key")
	print("PASS H: Invalid item keys fail preflight with no partial transfer")

	assert(DestructionCargoRecovery.recover_all(press, cache))
	assert(input.get_total_amount() == 0)
	assert(finished.get_total_amount() == 0)
	assert(cache.get_amount(ingot) == 2)
	assert(cache.get_amount(rounds) == 8)
	press.queue_free()
	await get_tree().process_frame
	assert(cache.get_total_amount() == 17)
	print("PASS I: Both independent manufacturer buffers recover without loss")

	assert(DestructionCargoRecovery.recover_all(belt_a, cache))
	assert(cargo_a.get_total_amount() == 0)
	assert(cache.get_amount(ingot) == 3)
	assert(cargo_b.get_amount(rounds) == 1)
	belt_a.queue_free()
	await get_tree().process_frame
	assert(belt_b.is_inside_tree())
	assert(not is_instance_valid(belt_b.previous_segment))
	assert(cargo_b.get_amount(rounds) == 1)
	print("PASS J: Destroyed cargo belt clears neighbor link but retains next belt")

	assert(DestructionCargoRecovery.recover_all(belt_b, cache))
	assert(cargo_b.get_total_amount() == 0)
	assert(cache.get_amount(rounds) == 9)
	belt_b.queue_free()
	await get_tree().process_frame
	assert(cache.get_amount(ore) == 7)
	assert(cache.get_amount(ingot) == 3)
	assert(cache.get_amount(rounds) == 9)
	assert(cache.get_total_amount() == 19)
	print("PASS K: All 19 initial item units remain accounted for in salvage")

	var empty_storage := storage_scene.instantiate() as Node3D
	assert(empty_storage != null)
	world.add_child(empty_storage)
	assert(DestructionCargoRecovery.recover_all(empty_storage, cache))
	assert(DestructionCargoRecovery.recover_all(empty_storage, cache))
	assert(cache.get_total_amount() == 19)
	assert((empty_storage.get_node("InventoryComponent") as InventoryComponent).get_total_amount() == 0)
	print("PASS L: Repeated empty-source recovery leaves the cache unchanged")

	world.queue_free()
	print("================================================")
	print("ALL 12 DESTRUCTION CARGO RECOVERY TESTS PASSED")
	print("================================================")
