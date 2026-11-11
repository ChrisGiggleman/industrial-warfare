extends RefCounted
class_name BlueprintConstructionRequirementsInspector

# =============================================================================
# E3D5C3D1 — READ-ONLY CONSTRUCTION REQUIREMENTS SNAPSHOT
# =============================================================================
# For future clickable sandbox UI. No construction authorization, timers,
# material transfer, escrow reservation, worker assignment or power changes.
#
# Missing services and missing bills fail closed. A stock snapshot is not a
# reserved bill. Prototype generator nameplate allocation is not verified
# production electricity. The current Factory Testing Sandbox debug bypass
# MUST NOT be presented to players as genuine construction readiness.


static func inspect(
	site: ConstructionSite,
	stock: InventoryComponent = null,
	escrow: BlueprintConstructionMaterialEscrow = null,
	power: PrototypeConstructionPowerAllocator = null,
	scheduler: BlueprintConstructionSlotScheduler = null
) -> Dictionary:
	var result: Dictionary = {
		"site_valid": false,
		"building_name": "",
		"state": -1,
		"priority": "",
		"progress": 0.0,
		"bill_valid": false,
		"required_materials": {},
		"stock_known": false,
		"stock_sufficient": false,
		"missing_materials": {},
		"escrow_known": false,
		"materials_reserved": false,
		"power_known": false,
		"prototype_power_allocated": false,
		"worker_known": false,
		"worker_active": false,
		"prototype_gates_observed": false,
		"live_construction_ready": false
	}
	if not _valid_site(site):
		return result

	result["site_valid"] = true
	result["building_name"] = site.target_definition.display_name
	result["state"] = int(site.job.state)
	result["priority"] = ConstructionJob.priority_name(int(site.job.priority))
	result["progress"] = site.job.get_progress()

	var bill_result: Dictionary = ConstructionMaterialBill.inspect(
		site.target_definition
	)
	if not bool(bill_result["valid"]):
		return result
	var bill: Dictionary = (bill_result["costs"] as Dictionary).duplicate()
	result["bill_valid"] = true
	result["required_materials"] = bill.duplicate()

	if _live(stock):
		result["stock_known"] = true
		var shortages: Dictionary = {}
		for key: Variant in bill.keys():
			var item: ItemDefinition = key as ItemDefinition
			var missing: int = maxi(0, int(bill[key]) - stock.get_amount(item))
			if missing > 0:
				shortages[item] = missing
		result["missing_materials"] = shortages
		result["stock_sufficient"] = shortages.is_empty()

	var eligible: bool = site.job.state in [
		ConstructionJob.State.QUEUED,
		ConstructionJob.State.CONSTRUCTING,
		ConstructionJob.State.PAUSED
	]
	if _live(escrow):
		result["escrow_known"] = true
		if eligible:
			var reservation: int = escrow.reservation_for(site)
			result["materials_reserved"] = (
				reservation > 0
				and escrow.has_reservation(reservation)
				and not escrow.needs_recovery(reservation)
				and escrow.held_materials(reservation) == bill
			)

	if _live(power):
		result["power_known"] = true
		if eligible:
			result["prototype_power_allocated"] = power.is_fully_allocated(site)

	if _live(scheduler):
		result["worker_known"] = true
		if eligible:
			result["worker_active"] = (
				scheduler.get_active_sites().has(site)
			)

	result["prototype_gates_observed"] = (
		eligible
		and bool(result["materials_reserved"])
		and bool(result["prototype_power_allocated"])
		and bool(result["worker_active"])
		and site.job.state == ConstructionJob.State.CONSTRUCTING
		and site.job.get_wait_reasons().is_empty()
	)
	# Deliberately ALWAYS false. Production-ready requires metered energy,
	# persisted escrow and real worker drone service, not these prototypes.
	result["live_construction_ready"] = false
	return result


static func _valid_site(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and site.job != null
		and is_instance_valid(site.target_definition)
	)


static func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
