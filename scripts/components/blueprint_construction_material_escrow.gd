extends Node
class_name BlueprintConstructionMaterialEscrow

# =============================================================================
# E3D5C2A — ISOLATED CONSTRUCTION MATERIAL RESERVATIONS
# =============================================================================
# A complete bill is removed from one real inventory into a per-site ledger.
# This never updates ConstructionJob availability, schedules workers, grants
# power, or modifies factory sandbox / Main. Costs are test-only for now.
# No persistent inventory recovery is available yet; keep this isolated.

var _records: Dictionary = {}
var _next_id: int = 1


func reserve(site: ConstructionSite, source: InventoryComponent, costs: Dictionary) -> int:
	if not _queued(site) or not _live(source) or not _valid_costs(costs):
		return 0
	if reservation_for(site) != 0:
		return 0

	# Check the complete bill before the first removal. No await, signals,
	# or deferred work occurs between this check and the synchronous debit.
	for key: Variant in costs.keys():
		var item: ItemDefinition = key as ItemDefinition
		if source.get_amount(item) < int(costs[key]):
			return 0
	var removed: Array[ItemDefinition] = []
	for key: Variant in costs.keys():
		var item: ItemDefinition = key as ItemDefinition
		if not source.remove_item(item, int(costs[key])):
			for previous: ItemDefinition in removed:
				if source.add_item(previous, int(costs[previous])) != int(costs[previous]):
					push_error("Escrow debit rollback could not restore inventory")
			return 0
		removed.append(item)

	var id: int = _next_id
	_next_id += 1
	_records[id] = {
		"site": weakref(site),
		"source": weakref(source),
		"costs": costs.duplicate(),
		"needs_recovery": false
	}
	site.job.job_cancelled.connect(_on_cancelled.bind(id))
	site.building_completed.connect(_on_building_completed.bind(id))
	site.tree_exiting.connect(_on_site_exiting.bind(id))
	return id


# Refund the entire escrow or keep it intact for later recovery.
# An alternative inventory is allowed when the source has filled/vanished.
func recover_to(id: int, destination: InventoryComponent = null) -> bool:
	if not _records.has(id):
		return false
	var record: Dictionary = _records[id]
	var target: InventoryComponent = destination
	if target == null:
		target = (record["source"] as WeakRef).get_ref() as InventoryComponent
	if not _live(target):
		record["needs_recovery"] = true
		return false
	var costs: Dictionary = record["costs"]
	var count: int = 0
	for key: Variant in costs.keys():
		count += int(costs[key])
	var space: int = target.get_available_space()
	if space >= 0 and space < count:
		record["needs_recovery"] = true
		return false

	var restored: Array[ItemDefinition] = []
	for key: Variant in costs.keys():
		var item: ItemDefinition = key as ItemDefinition
		var expected: int = int(costs[key])
		if not is_instance_valid(item):
			record["needs_recovery"] = true
			return false
		var actual: int = target.add_item(item, expected)
		if actual != expected:
			if actual > 0 and not target.remove_item(item, actual):
				push_error("Escrow refund rollback could not remove partial item")
			for previous: ItemDefinition in restored:
				if not target.remove_item(previous, int(costs[previous])):
					push_error("Escrow refund rollback could not restore previous state")
			record["needs_recovery"] = true
			return false
		restored.append(item)
	_records.erase(id)
	return true


# Held materials are consumed ONLY after a real building was activated.
func commit_built(id: int) -> bool:
	if not _records.has(id):
		return false
	var record: Dictionary = _records[id]
	var site: ConstructionSite = (record["site"] as WeakRef).get_ref() as ConstructionSite
	if not is_instance_valid(site) or site.job == null:
		return false
	if site.job.state != ConstructionJob.State.COMPLETE or not site.is_completed():
		return false
	_records.erase(id)
	return true


func has_reservation(id: int) -> bool:
	return _records.has(id)


func reservation_for(site: ConstructionSite) -> int:
	if not is_instance_valid(site):
		return 0
	for id: Variant in _records.keys():
		var record: Dictionary = _records[id]
		if (record["site"] as WeakRef).get_ref() == site:
			return int(id)
	return 0


func held_materials(id: int) -> Dictionary:
	if not _records.has(id):
		return {}
	return (_records[id]["costs"] as Dictionary).duplicate()


func needs_recovery(id: int) -> bool:
	return _records.has(id) and bool(_records[id]["needs_recovery"])


func held_count() -> int:
	return _records.size()


func _on_cancelled(id: int) -> void:
	recover_to(id)


func _on_building_completed(_building: Node3D, id: int) -> void:
	commit_built(id)


func _on_site_exiting(id: int) -> void:
	# Successful site activation has already committed its escrow.
	if _records.has(id):
		recover_to(id)


func _queued(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and is_instance_valid(site.target_definition)
		and site.job != null
		and site.job.state == ConstructionJob.State.QUEUED
	)


func _live(stock: InventoryComponent) -> bool:
	return (
		is_instance_valid(stock)
		and not stock.is_queued_for_deletion()
		and stock.is_inside_tree()
	)


func _valid_costs(costs: Dictionary) -> bool:
	if costs.is_empty():
		return false
	for key: Variant in costs.keys():
		if not key is ItemDefinition or not is_instance_valid(key):
			return false
		var quantity: Variant = costs[key]
		if typeof(quantity) != TYPE_INT or int(quantity) <= 0:
			return false
	return true
