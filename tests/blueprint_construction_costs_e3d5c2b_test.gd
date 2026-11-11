extends Node3D

# E3D5C2B: 17 isolated checks. Costs are NOT enforced in live sandbox yet.
const PATHS = [
	"res://data/buildings/test_extractor.tres",
	"res://data/buildings/test_building_large.tres",
	"res://data/buildings/test_storage.tres",
	"res://data/buildings/test_smelter.tres",
	"res://data/buildings/conveyor_belt.tres",
	"res://data/buildings/conveyor_merger.tres",
	"res://data/buildings/conveyor_splitter.tres",
	"res://data/buildings/prototype_ammunition_press.tres",
	"res://data/buildings/prototype_defensive_turret.tres"
]

func _entry(item: ItemDefinition, amount: int) -> ItemAmount:
	var entry := ItemAmount.new()
	entry.item = item
	entry.amount = amount
	return entry

func _site(definition: BuildingDefinition, title: String, location: Vector3) -> ConstructionSite:
	var site := ConstructionSite.new()
	site.name = title
	assert(site.setup_with_definition_job(definition))
	add_child(site)
	site.position = location
	site.set_process(false)
	assert(site.job.authorize())
	assert(site.job.state == ConstructionJob.State.QUEUED)
	return site

func _ready() -> void:
	var ore := load("res://data/items/test_ore.tres") as ItemDefinition
	var ingot := load("res://data/items/test_ingot.tres") as ItemDefinition
	assert(ore != null and ingot != null)
	var definitions: Dictionary = {}
	for path: String in PATHS:
		var definition := load(path) as BuildingDefinition
		assert(is_instance_valid(definition))
		var checked: Dictionary = ConstructionMaterialBill.inspect(definition)
		assert(bool(checked["valid"]))
		assert(not (checked["costs"] as Dictionary).is_empty())
		definitions[definition.building_id] = definition
	assert(definitions.size() == 9)
	print("PASS A: Nine definition-owned material bills are valid and nonempty")

	var storage: BuildingDefinition = definitions[&"test_storage"]
	var smelter: BuildingDefinition = definitions[&"test_smelter"]
	assert(ConstructionMaterialBill.get_costs(storage) == {ingot: 3})
	assert(ConstructionMaterialBill.get_costs(smelter) == {ore: 2, ingot: 4})
	print("PASS B: Storage and Smelter have expected provisional costs")

	var durations: Dictionary = {
		&"test_extractor": 12.0, &"test_building_large": 20.0,
		&"test_storage": 10.0, &"test_smelter": 16.0,
		&"conveyor_belt": 2.0, &"conveyor_merger": 5.0,
		&"conveyor_splitter": 5.0, &"prototype_ammunition_press": 18.0,
		&"prototype_defensive_turret": 15.0
	}
	for building_id: StringName in durations.keys():
		var definition: BuildingDefinition = definitions[building_id]
		assert(is_equal_approx(definition.construction_seconds, float(durations[building_id])))
	print("PASS C: Previously verified construction durations remain unchanged")

	for building_id: StringName in definitions.keys():
		var definition: BuildingDefinition = definitions[building_id]
		var costs: Dictionary = ConstructionMaterialBill.get_costs(definition)
		for item: Variant in costs.keys():
			assert(item == ore or item == ingot)
			assert(int(costs[item]) > 0)
	print("PASS D: Costs reference existing Test Ore/Ingot resources only")

	var copy: Dictionary = ConstructionMaterialBill.get_costs(storage)
	copy[ingot] = 999
	assert(ConstructionMaterialBill.get_costs(storage)[ingot] == 3)
	assert(storage.construction_materials[0].amount == 3)
	print("PASS E: Returned bill is independent of the original definition")

	assert(not bool(ConstructionMaterialBill.inspect(null)["valid"]))
	print("PASS F: Missing building definitions fail closed")

	var invalid := BuildingDefinition.new()
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"missing_materials")
	print("PASS G: Missing material list cannot mean a free building")

	invalid.construction_materials.append(null)
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"invalid_entry")
	print("PASS H: Null material entries are rejected")

	invalid.construction_materials.clear()
	invalid.construction_materials.append(_entry(null, 1))
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"invalid_item")
	print("PASS I: Missing ItemDefinition is rejected")

	invalid.construction_materials.clear()
	invalid.construction_materials.append(_entry(ingot, 0))
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"invalid_amount")
	print("PASS J: Zero quantities are rejected")

	invalid.construction_materials.clear()
	invalid.construction_materials.append(_entry(ingot, -1))
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"invalid_amount")
	print("PASS K: Negative quantities are rejected")

	invalid.construction_materials.clear()
	invalid.construction_materials.append(_entry(ingot, 2))
	invalid.construction_materials.append(_entry(ingot, 1))
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"duplicate_item")
	print("PASS L: Duplicate items cannot be charged ambiguously")

	var duplicate := ItemDefinition.new()
	duplicate.item_id = ingot.item_id
	invalid.construction_materials.clear()
	invalid.construction_materials.append(_entry(ingot, 2))
	invalid.construction_materials.append(_entry(duplicate, 3))
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"duplicate_item")
	print("PASS M: Duplicate item IDs are rejected even for different resources")

	invalid.construction_materials.clear()
	invalid.construction_materials.append(_entry(ItemDefinition.new(), 1))
	assert(ConstructionMaterialBill.inspect(invalid)["error"] == &"invalid_item")
	print("PASS N: Empty logical item IDs are rejected")

	var inventory := InventoryComponent.new()
	inventory.max_capacity = 20
	add_child(inventory)
	assert(inventory.add_item(ingot, 3) == 3)
	var first: ConstructionSite = _site(storage, "StorageA", Vector3(-5, 0, 0))
	var second: ConstructionSite = _site(storage, "StorageB", Vector3(5, 0, 0))
	var escrow := BlueprintConstructionMaterialEscrow.new()
	add_child(escrow)
	var costs: Dictionary = ConstructionMaterialBill.get_costs(storage)
	var first_id: int = escrow.reserve(first, inventory, costs)
	assert(first_id > 0)
	assert(inventory.get_amount(ingot) == 0)
	assert(first.job.state == ConstructionJob.State.QUEUED)
	assert(first.job.get_progress() == 0.0)
	print("PASS O: Definition costs reserve stock without starting work")

	assert(escrow.reserve(second, inventory, costs) == 0)
	assert(first.job.cancel())
	assert(inventory.get_amount(ingot) == 3)
	assert(not escrow.has_reservation(first_id))
	var second_id: int = escrow.reserve(second, inventory, costs)
	assert(second_id > first_id)
	assert(inventory.get_amount(ingot) == 0)
	print("PASS P: Waiting job cannot double-claim; cancellation refunds")

	assert(second.job.set_availability(true, true, true))
	second.job.advance(4.0)
	assert(is_equal_approx(second.job.get_progress(), 0.4))
	assert(second.job.set_availability(false, true, true))
	second.job.advance(100.0)
	assert(is_equal_approx(second.job.get_progress(), 0.4))
	assert(second.job.set_availability(true, true, true))
	second.job.advance(6.0)
	assert(second.job.state == ConstructionJob.State.COMPLETE)
	assert(second.is_completed())
	assert(not escrow.has_reservation(second_id))
	assert(not escrow.commit_built(second_id))
	assert(inventory.get_amount(ingot) == 0)
	print("PASS Q: Pauses preserve progress and real completion consumes once")

	print("ALL 17 E3D5C2B DEFINITION CONSTRUCTION COST TESTS PASSED")
