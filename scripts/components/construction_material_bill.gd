extends RefCounted
class_name ConstructionMaterialBill

# E3D5C2B: read-only construction bill validation.
# An empty or malformed bill never means zero-cost construction.
# No job, inventory, worker or power state is modified.

static func inspect(definition: BuildingDefinition) -> Dictionary:
	var result: Dictionary = {"valid": false, "error": &"invalid_definition", "costs": {}}
	if not is_instance_valid(definition):
		return result
	if definition.construction_materials.is_empty():
		result["error"] = &"missing_materials"
		return result
	var costs: Dictionary = {}
	var identifiers: Dictionary = {}
	for entry: ItemAmount in definition.construction_materials:
		if not is_instance_valid(entry):
			result["error"] = &"invalid_entry"
			return result
		if not is_instance_valid(entry.item) or entry.item.item_id == &"":
			result["error"] = &"invalid_item"
			return result
		if entry.amount <= 0:
			result["error"] = &"invalid_amount"
			return result
		if identifiers.has(entry.item.item_id):
			result["error"] = &"duplicate_item"
			return result
		identifiers[entry.item.item_id] = true
		costs[entry.item] = entry.amount
	result["valid"] = true
	result["error"] = &""
	result["costs"] = costs
	return result

static func get_costs(definition: BuildingDefinition) -> Dictionary:
	var checked: Dictionary = inspect(definition)
	if not bool(checked["valid"]):
		return {}
	return (checked["costs"] as Dictionary).duplicate()
