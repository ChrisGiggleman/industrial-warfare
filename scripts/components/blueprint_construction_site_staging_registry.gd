extends Node
class_name BlueprintConstructionSiteStagingRegistry

# =============================================================================
# E3D5C4H — TEST-ONLY PER-SITE CONSTRUCTION MATERIAL OWNERSHIP
# =============================================================================
# A staging buffer and physical input port are claimed by exactly ONE
# already-authorized ConstructionSite. A second blueprint cannot claim
# the same staging/port, even if the first is cancelled or deleted.
#
# No registration or lookup authorizes work, runs coordinator.reconcile(),
# changes priority/availability, creates power/workers, or advances timers.
# reserve_for_site() uses only the registered site's exact bill and buffer.
#
# Deliberately NO automatic unregister/retarget operation. Stocked ports and
# cancelled-site escrows require explicit recovery and save/load policies
# before claims can ever be safely reused in production. Neither playable
# scene installs this isolated service.

@export var enable_isolated_site_registry: bool = false

var _claims: Array[Dictionary] = []


func claim_site(
	site: ConstructionSite,
	staging: BlueprintConstructionMaterialStaging,
	port: BlueprintConstructionStagingInputPort
) -> bool:
	if not enable_isolated_site_registry or not _valid_new_claim(site, staging, port):
		return false

	# Keep even stale/cancelled claims locked: a freed site must not let its
	# staging inventory be silently assigned to an unrelated blueprint.
	for entry: Dictionary in _claims:
		if _claimed_ref(entry, "site") == site:
			return false
		if _claimed_ref(entry, "staging") == staging:
			return false
		if _claimed_ref(entry, "port") == port:
			return false
		if _claimed_ref(entry, "inventory") == staging.get_staged_inventory():
			return false

	_claims.append({
		"site": weakref(site),
		"staging": weakref(staging),
		"port": weakref(port),
		"inventory": weakref(staging.get_staged_inventory())
	})
	return true


# Read-only lookup. If the site is cancelled, no longer in the tree, or the
# physical receiver is disabled/rebound, return null rather than shared stock.
func inventory_for_site(site: ConstructionSite) -> InventoryComponent:
	if not enable_isolated_site_registry or not _live(site):
		return null
	if site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return null
	for entry: Dictionary in _claims:
		if _claimed_ref(entry, "site") != site:
			continue
		var staging := (
			_claimed_ref(entry, "staging")
			as BlueprintConstructionMaterialStaging
		)
		var port := (
			_claimed_ref(entry, "port")
			as BlueprintConstructionStagingInputPort
		)
		var inventory := (
			_claimed_ref(entry, "inventory")
			as InventoryComponent
		)
		if (
			not _live(staging)
			or not _live(port)
			or not _live(inventory)
			or not staging.enable_isolated_staging
			or not port.enable_isolated_input
			or not staging.matches_definition(site.target_definition)
			or staging.get_staged_inventory() != inventory
			or port.get_bound_staging() != staging
			or port.inventory != inventory
		):
			return null
		return inventory
	return null


# Read-only check of a site's original buffer after QUEUED -> CONSTRUCTING
# or PAUSED. Does not permit a second reservation or release a claim.
func matches_owned_inventory(
	site: ConstructionSite, expected: InventoryComponent
) -> bool:
	if (
		not enable_isolated_site_registry or not _live(site)
		or not _live(expected) or site.job == null
		or not is_instance_valid(site.target_definition)
		or site.job.state not in [
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.CONSTRUCTING,
			ConstructionJob.State.PAUSED
		]
	):
		return false
	for entry: Dictionary in _claims:
		if _claimed_ref(entry, "site") != site:
			continue
		var staging := _claimed_ref(entry, "staging") as BlueprintConstructionMaterialStaging
		var port := _claimed_ref(entry, "port") as BlueprintConstructionStagingInputPort
		return (
			_claimed_ref(entry, "inventory") == expected
			and _live(staging) and _live(port)
			and staging.enable_isolated_staging
			and port.enable_isolated_input
			and staging.matches_definition(site.target_definition)
			and staging.get_staged_inventory() == expected
			and port.get_bound_staging() == staging
			and port.inventory == expected
		)
	return false


# The ONLY reservation operation exposed by this registry. Never accepts an
# arbitrary destination or item bill from callers. Existing atomic escrow
# still owns debits, job-cancellation refunds and completion commits.
func reserve_for_site(
	site: ConstructionSite,
	escrow: BlueprintConstructionMaterialEscrow
) -> int:
	if not _live(escrow):
		return 0
	var inventory: InventoryComponent = inventory_for_site(site)
	if not _live(inventory):
		return 0
	var bill: Dictionary = ConstructionMaterialBill.get_costs(
		site.target_definition
	)
	if bill.is_empty():
		return 0
	return escrow.reserve(site, inventory, bill)


# Read-only verification for quarantine/recovery inspection, including
# after the original ConstructionSite object was freed. This DOES NOT
# authorize, remove or retarget claims; no deletion API is exposed.
func has_locked_pair(
	staging: BlueprintConstructionMaterialStaging,
	port: BlueprintConstructionStagingInputPort
) -> bool:
	if (
		not enable_isolated_site_registry
		or not _live(staging)
		or not _live(port)
	):
		return false
	var buffer: InventoryComponent = staging.get_staged_inventory()
	if not _live(buffer):
		return false
	for entry: Dictionary in _claims:
		if (
			_claimed_ref(entry, "staging") == staging
			and _claimed_ref(entry, "port") == port
			and _claimed_ref(entry, "inventory") == buffer
		):
			return true
	return false


func claim_count() -> int:
	return _claims.size()


func _valid_new_claim(
	site: ConstructionSite,
	staging: BlueprintConstructionMaterialStaging,
	port: BlueprintConstructionStagingInputPort
) -> bool:
	if not _live(site) or not _live(staging) or not _live(port):
		return false
	if site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return false
	if not is_instance_valid(site.target_definition):
		return false
	var reasons: Array[StringName] = site.job.get_wait_reasons()
	if (
		not reasons.has(&"power")
		or not reasons.has(&"materials")
		or not reasons.has(&"workers")
	):
		return false
	if not staging.enable_isolated_staging or not port.enable_isolated_input:
		return false
	var inventory: InventoryComponent = staging.get_staged_inventory()
	if not _live(inventory) or not staging.matches_definition(site.target_definition):
		return false
	return port.get_bound_staging() == staging and port.inventory == inventory


func _claimed_ref(entry: Dictionary, field: String) -> Object:
	var ref: WeakRef = entry[field] as WeakRef
	if ref == null:
		return null
	return ref.get_ref()


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
