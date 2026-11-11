extends Node3D

# =============================================================================
# E3D5C3C2 — ONE-TIME MAIN HUB STARTER MATERIALS (ISOLATED)
# =============================================================================
# Prototype loadout: 20 Test Ingots + 8 Test Ore. No real gameplay supply.
# The hub scene starts EMPTY. Bootstrap is explicitly invoked once here.


func _hub() -> PrototypePowerStructure:
	var scene := load(
		"res://scenes/buildings/prototype_main_hub.tscn"
	) as PackedScene
	assert(scene != null)
	var hub := scene.instantiate() as PrototypePowerStructure
	assert(is_instance_valid(hub))
	add_child(hub)
	return hub


func _site(definition: BuildingDefinition, label: String) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = label
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.set_process(false)
	assert(site.job.authorize())
	return site


func _ready() -> void:
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	var bootstrap := PrototypeMainHubStarterStock.new()
	add_child(bootstrap)
	var starter: Dictionary = {ingot: 20, ore: 8}
	var detached_scene := load(
		"res://scenes/buildings/prototype_main_hub.tscn"
	) as PackedScene
	var detached := detached_scene.instantiate() as PrototypePowerStructure
	assert(not bootstrap.seed_fresh_hub(detached, starter))
	detached.free()
	assert(not bootstrap.seed_fresh_hub(null, starter))
	print("PASS A: Missing or detached Hubs cannot receive starting stock")

	var hub: PrototypePowerStructure = _hub()
	var stock: InventoryComponent = bootstrap.get_hub_inventory(hub)
	# Diagnostic gate: report the instantiated scene when the expected
	# typed inventory is missing. Do not fabricate a replacement inventory.
	if stock == null or not stock.is_inside_tree():
		print("E3D5C3C2 DIAGNOSTIC: Hub scene path = ", hub.scene_file_path)
		print("E3D5C3C2 DIAGNOSTIC: Hub children:")
		for child: Node in hub.get_children():
			var script_path: String = "<none>"
			var child_script: Script = child.get_script() as Script
			if is_instance_valid(child_script):
				script_path = child_script.resource_path
			print(
				"  name=", child.name, " class=", child.get_class(),
				" script=", script_path, " inside_tree=", child.is_inside_tree()
			)
		var raw_inventory: Node = hub.get_node_or_null("InventoryComponent")
		print(
			"E3D5C3C2 DIAGNOSTIC: Raw inventory node = ",
			raw_inventory, " typed_as_InventoryComponent = ",
			raw_inventory is InventoryComponent
		)
		push_error(
			"E3D5C3C2 cannot continue: loaded Hub is missing its live typed "
			+ "InventoryComponent. Inspect the diagnostic lines above."
		)
		return
	assert(stock != null and stock.is_inside_tree())
	assert(stock.max_capacity == 40)
	assert(stock.get_total_amount() == 0)
	assert(hub.available_nameplate_generation() == 12)
	assert(not bootstrap.was_seeded(hub))
	print("PASS B: Completed starter Hub begins with finite empty inventory")

	assert(not bootstrap.seed_fresh_hub(hub, {}))
	assert(stock.get_total_amount() == 0)
	print("PASS C: Missing bootstrap bill never creates free resources")

	for invalid: Dictionary in [
		{ingot: 0}, {ingot: -2}, {ingot: 1.5}, {"ingot": 1}
	]:
		assert(not bootstrap.seed_fresh_hub(hub, invalid))
	assert(stock.get_total_amount() == 0)
	print("PASS D: Invalid quantities and non-item keys fail closed")

	var duplicate := ItemDefinition.new()
	duplicate.item_id = ingot.item_id
	assert(not bootstrap.seed_fresh_hub(hub, {ingot: 2, duplicate: 2}))
	var unidentified := ItemDefinition.new()
	assert(not bootstrap.seed_fresh_hub(hub, {unidentified: 2}))
	assert(stock.get_total_amount() == 0)
	print("PASS E: Duplicate logical IDs and unidentified items are rejected")

	assert(not bootstrap.seed_fresh_hub(hub, {ingot: 41}))
	assert(stock.get_total_amount() == 0)
	print("PASS F: Capacity overflow is rejected without partial seeding")

	assert(stock.add_item(ore, 1) == 1)
	assert(not bootstrap.seed_fresh_hub(hub, starter))
	assert(stock.get_amount(ore) == 1)
	assert(stock.remove_item(ore, 1))
	assert(stock.get_total_amount() == 0)
	print("PASS G: A nonempty Hub cannot be mistaken for a fresh start")

	assert(bootstrap.seed_fresh_hub(hub, starter))
	assert(bootstrap.was_seeded(hub))
	assert(stock.get_amount(ingot) == 20)
	assert(stock.get_amount(ore) == 8)
	assert(stock.get_total_amount() == 28)
	assert(stock.get_available_space() == 12)
	print("PASS H: Fresh Hub receives exact finite prototype starter supplies")

	assert(not bootstrap.seed_fresh_hub(hub, starter))
	var second_bootstrap := PrototypeMainHubStarterStock.new()
	add_child(second_bootstrap)
	assert(not second_bootstrap.seed_fresh_hub(hub, starter))
	assert(stock.get_total_amount() == 28)
	print("PASS I: Multiple bootstrap services cannot duplicate starter items")

	var delivered := InventoryComponent.new()
	delivered.max_capacity = 10
	add_child(delivered)
	assert(stock.transfer_to(delivered, ingot, 2) == 2)
	assert(stock.get_amount(ingot) == 18)
	assert(delivered.get_amount(ingot) == 2)
	assert(stock.get_total_amount() + delivered.get_total_amount() == 28)
	print("PASS J: Starter inventory transfers use conserved real items")

	var storage_definition := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	assert(storage_definition != null)
	assert(ConstructionMaterialBill.get_costs(storage_definition) == {ingot: 3})
	var site: ConstructionSite = _site(storage_definition, "ReservedStorage")
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var reservation: int = escrow.reserve(
		site, stock, ConstructionMaterialBill.get_costs(storage_definition)
	)
	assert(reservation > 0)
	assert(stock.get_amount(ingot) == 15)
	assert(escrow.held_materials(reservation) == {ingot: 3})
	assert(site.job.state == ConstructionJob.State.QUEUED)
	assert(site.job.get_progress() == 0.0)
	print("PASS K: Actual definition costs hold stock without free workers")

	var competing: ConstructionSite = _site(storage_definition, "Competing")
	assert(escrow.reserve(competing, stock, {ingot: 16}) == 0)
	assert(stock.get_amount(ingot) == 15)
	assert(escrow.held_count() == 1)
	print("PASS L: Unavailable inventory cannot satisfy competing reservations")

	assert(site.job.cancel())
	assert(not escrow.has_reservation(reservation))
	assert(stock.get_amount(ingot) == 18)
	assert(escrow.held_count() == 0)
	print("PASS M: Cancellation returns exact initial supplies to Hub stock")

	var built: ConstructionSite = _site(storage_definition, "FinishedStorage")
	var built_id: int = escrow.reserve(
		built, stock, ConstructionMaterialBill.get_costs(storage_definition)
	)
	assert(built_id > 0)
	assert(built.job.set_availability(true, true, true))
	built.job.advance(10.0)
	assert(built.job.state == ConstructionJob.State.COMPLETE)
	assert(built.is_completed())
	assert(not escrow.has_reservation(built_id))
	assert(not escrow.commit_built(built_id))
	assert(stock.get_amount(ingot) == 15)
	assert(delivered.get_amount(ingot) == 2)
	assert(stock.get_amount(ore) == 8)
	assert(stock.get_total_amount() + delivered.get_total_amount() + 3 == 28)
	print("PASS N: Completed building consumes exactly once and conserves stock")

	assert(hub.set_generator_enabled(false))
	assert(not bootstrap.seed_fresh_hub(hub, starter))
	assert(stock.get_amount(ingot) == 15)
	assert(hub.set_generator_enabled(true))
	assert(not bootstrap.seed_fresh_hub(hub, starter))
	print("PASS O: Power outage/restart never refills consumed resources")

	var pole_scene := load(
		"res://scenes/buildings/prototype_power_pole.tscn"
	) as PackedScene
	var pole := pole_scene.instantiate() as PrototypePowerStructure
	add_child(pole)
	var unrelated_inventory := InventoryComponent.new()
	pole.add_child(unrelated_inventory)
	assert(not bootstrap.seed_fresh_hub(pole, starter))
	var damaged: PrototypePowerStructure = _hub()
	var health: BuildingHealthComponent = damaged.get_health()
	assert(health.take_damage(100) == 100)
	assert(not bootstrap.seed_fresh_hub(damaged, starter))
	assert(bootstrap.get_hub_inventory(damaged).get_total_amount() == 0)
	assert(stock.get_amount(ingot) == 15)
	print("PASS P: Other structures and damaged Hubs cannot mint starting stock")

	print("ALL 16 E3D5C3C2 MAIN HUB STARTER INVENTORY TESTS PASSED")
