extends Node
class_name PrototypeMainHubStarterStock

# =============================================================================
# E3D5C3C2 — EXPLICIT, ONE-TIME TEST-HUB STARTER STOCK
# =============================================================================
# This service runs only when manually invoked in an isolated test fixture.
# A prebuilt, healthy, online Hub gets a finite initial inventory ONE time.
# There is no per-frame refill, magic material transfer, save/load, or Main
# / Factory Testing Sandbox hookup. The Hub scene starts with EMPTY stock.
#
# This is a prototype bootstrap policy. Before live gameplay, its one-time
# marker and inventory require authoritative persistence across save/load.

const SEEDED_META: StringName = &"iw_prototype_starter_stock_seeded"


func seed_fresh_hub(
	hub: PrototypePowerStructure,
	starting_items: Dictionary
) -> bool:
	if (
		not is_instance_valid(hub) or hub.is_queued_for_deletion()
		or not hub.is_inside_tree()
		or hub.scene_file_path != "res://scenes/buildings/prototype_main_hub.tscn"
	):
		return false
	var node: ConstructionPowerNetworkNode = hub.get_power_node()
	var health: BuildingHealthComponent = hub.get_health()
	var inventory: InventoryComponent = (
		hub.get_node_or_null("InventoryComponent") as InventoryComponent
	)
	if (
		not is_instance_valid(node) or not node.operational
		or not node.is_source or not node.source_online
		or not is_instance_valid(health) or not health.is_intact()
		or not is_instance_valid(inventory)
		or not inventory.is_inside_tree()
		or inventory.is_queued_for_deletion()
	):
		return false
	if hub.has_meta(SEEDED_META) or inventory.get_total_amount() != 0:
		return false
	if starting_items.is_empty():
		return false

	var total: int = 0
	var unique_item_ids: Dictionary = {}
	for key: Variant in starting_items.keys():
		if not key is ItemDefinition or not is_instance_valid(key):
			return false
		var item: ItemDefinition = key as ItemDefinition
		if item.item_id == &"" or unique_item_ids.has(item.item_id):
			return false
		unique_item_ids[item.item_id] = true
		var quantity: Variant = starting_items[key]
		if typeof(quantity) != TYPE_INT or int(quantity) <= 0:
			return false
		total += int(quantity)
		if total > 100000:
			return false

	# This deliberately REQUIRES a finite inventory, never unlimited.
	var available: int = inventory.get_available_space()
	if available < total or available < 0:
		return false

	var added: Array[ItemDefinition] = []
	for key: Variant in starting_items.keys():
		var item: ItemDefinition = key as ItemDefinition
		var amount: int = int(starting_items[key])
		if inventory.add_item(item, amount) != amount:
			# Defensive rollback if inventory behavior changes later.
			for prior: ItemDefinition in added:
				if not inventory.remove_item(prior, int(starting_items[prior])):
					push_error("Starter stock rollback could not restore inventory")
			return false
		added.append(item)

	hub.set_meta(SEEDED_META, true)
	return true


func was_seeded(hub: PrototypePowerStructure) -> bool:
	return (
		is_instance_valid(hub)
		and hub.has_meta(SEEDED_META)
	)


func get_hub_inventory(hub: PrototypePowerStructure) -> InventoryComponent:
	if not is_instance_valid(hub) or hub.is_queued_for_deletion():
		return null
	return hub.get_node_or_null("InventoryComponent") as InventoryComponent
