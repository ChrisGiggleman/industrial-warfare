extends RefCounted
class_name BlueprintConstructionReadinessProbe

# =============================================================================
# E3D5C1 — READ-ONLY POWER AND MATERIAL STOCK INSPECTION (ISOLATED)
# =============================================================================
# This is NOT a dispatch authorization service. A matching warehouse stock
# count is not proof that materials have been reserved for this job. Multiple
# jobs may inspect the same items. Until a material escrow/reservation service
# and a real power-coverage provider exist, NEVER forward these observations
# to BlueprintConstructionSlotScheduler.update_requirements().
#
# No ConstructionJob, ConstructionSite, inventory, power grid, or worker slot
# is mutated. The sandbox's existing debug construction path is untouched.


func inspect(
	site: ConstructionSite,
	power_report: Variant,
	stock: InventoryComponent,
	required_materials: Dictionary
) -> Dictionary:
	var result: Dictionary = {
		"authorized": false,
		"power_known": false,
		"power_covered": false,
		"bill_valid": false,
		"stock_known": false,
		"stock_sufficient": false,
		"missing_materials": {}
	}
	if not _is_authorized_site(site):
		return result

	result["authorized"] = true
	# A null or malformed report is UNKNOWN, not powered.
	if typeof(power_report) == TYPE_BOOL:
		result["power_known"] = true
		result["power_covered"] = bool(power_report)

	# BuildingDefinition does not yet carry a construction bill of materials.
	# Require a NONEMPTY, explicit, fully valid bill supplied by the caller.
	# Empty/invalid bills never count as free construction.
	if required_materials.is_empty():
		return result
	for key: Variant in required_materials.keys():
		if not key is ItemDefinition:
			return result
		var item: ItemDefinition = key as ItemDefinition
		if not is_instance_valid(item):
			return result
		var quantity: Variant = required_materials[key]
		if typeof(quantity) != TYPE_INT or int(quantity) <= 0:
			return result

	result["bill_valid"] = true
	if (
		not is_instance_valid(stock)
		or stock.is_queued_for_deletion()
		or not stock.is_inside_tree()
	):
		return result

	result["stock_known"] = true
	var missing: Dictionary = {}
	for key: Variant in required_materials.keys():
		var item: ItemDefinition = key as ItemDefinition
		var deficit: int = maxi(
			0, int(required_materials[key]) - stock.get_amount(item)
		)
		if deficit > 0:
			missing[item] = deficit
	result["missing_materials"] = missing
	result["stock_sufficient"] = missing.is_empty()
	return result


func _is_authorized_site(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and is_instance_valid(site.target_definition)
		and site.job != null
		and site.job.state in [
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.CONSTRUCTING,
			ConstructionJob.State.PAUSED
		]
	)
