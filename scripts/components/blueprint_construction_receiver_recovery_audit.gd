extends Node
class_name BlueprintConstructionReceiverRecoveryAudit

# =============================================================================
# E3D5C4J — READ-ONLY CANCELLED-RECEIVER RECOVERY AUDIT (TEST ONLY)
# =============================================================================
# Reports why a specifically registered site-aligned receiver cannot be
# decommissioned. Inspection NEVER transfers, refunds, destroys, detaches,
# authorizes, dispatches, or changes power/worker availability.
#
# "drained_observed" means all FOUR KNOWN blockers (site ending, belt link,
# belt cargo, staging inventory and captured escrow) have been checked. It
# does NOT authorize releasing the registry's permanent ownership lock.
# A production-safe transaction and persisted recovery ownership are still
# required. Main and Factory Testing Sandbox must NOT install this service.

@export var enable_isolated_recovery_audit: bool = false

var _registry_ref: WeakRef = null
var _staging_ref: WeakRef = null
var _port_ref: WeakRef = null
var _belt_ref: WeakRef = null
var _escrow_ref: WeakRef = null
var _reservation_id: int = 0


func configure(
	site: ConstructionSite,
	registry: BlueprintConstructionSiteStagingRegistry,
	staging: BlueprintConstructionMaterialStaging,
	port: BlueprintConstructionAnchoredStagingPort,
	belt: ConveyorSegment,
	escrow: BlueprintConstructionMaterialEscrow
) -> bool:
	if (
		not enable_isolated_recovery_audit
		or not is_inside_tree()
		or _port_ref != null
		or not _live(site)
		or not _live(registry)
		or not _live(staging)
		or not _live(port)
		or not _live(belt)
		or not _live(escrow)
	):
		return false
	if (
		site.job == null
		or site.job.state != ConstructionJob.State.QUEUED
		or not port.matches_attached_site()
		or not registry.has_locked_pair(staging, port)
		or registry.inventory_for_site(site) != staging.get_staged_inventory()
		or belt.output_building_port != port
		or port.connected_conveyor != belt
	):
		return false
	var reservation_id: int = escrow.reservation_for(site)
	if reservation_id <= 0 or not escrow.has_reservation(reservation_id):
		return false

	_registry_ref = weakref(registry)
	_staging_ref = weakref(staging)
	_port_ref = weakref(port)
	_belt_ref = weakref(belt)
	_escrow_ref = weakref(escrow)
	_reservation_id = reservation_id
	return true


# Read-only proof required to bind a session UUID to THIS audit. A caller
# must provide the original, live, authorized site while it is still QUEUED.
# The audit's existing registry/receiver/staging links are compared directly;
# an unrelated site cannot borrow its audit by passing an arbitrary label.
func matches_queued_site(site: ConstructionSite) -> bool:
	if (
		not enable_isolated_recovery_audit
		or not _live(site)
		or site.job == null
		or site.job.state != ConstructionJob.State.QUEUED
		or _port_ref == null
	):
		return false
	var registry := _get_node(_registry_ref) as BlueprintConstructionSiteStagingRegistry
	var staging := _get_node(_staging_ref) as BlueprintConstructionMaterialStaging
	var port := _get_node(_port_ref) as BlueprintConstructionAnchoredStagingPort
	if not _live(registry) or not _live(staging) or not _live(port):
		return false
	return (
		port.matches_attached_site()
		and registry.has_locked_pair(staging, port)
		and registry.inventory_for_site(site) == staging.get_staged_inventory()
	)


# Read-only provenance proof for a recovery checkpoint. These must be the
# EXACT services and original escrow ID captured by configure(), not an
# unrelated site's buffer or a caller-selected alternative reservation.
# It continues to match after the belt is detached/site is destroyed.
func matches_material_sources(
	staging: BlueprintConstructionMaterialStaging,
	belt: ConveyorSegment,
	escrow: BlueprintConstructionMaterialEscrow,
	reservation_id: int
) -> bool:
	return (
		enable_isolated_recovery_audit
		and reservation_id > 0
		and _live(staging)
		and _live(belt)
		and _live(escrow)
		and _reservation_id == reservation_id
		and _get_node(_staging_ref) == staging
		and _get_node(_belt_ref) == belt
		and _get_node(_escrow_ref) == escrow
	)


func inspect() -> Dictionary:
	var blockers: Array[StringName] = []
	var result: Dictionary = {
		"known": false,
		"site_ended": false,
		"buffered": -1,
		"belt_cargo": -1,
		"escrow_outstanding": true,
		"belt_connected": true,
		"claim_locked": true,
		"drained_observed": false,
		"safe_to_release": false,
		"blockers": blockers
	}
	if not enable_isolated_recovery_audit or _port_ref == null:
		blockers.append(&"audit_disabled")
		result["blockers"] = blockers
		return result

	var registry := _get_node(_registry_ref) as BlueprintConstructionSiteStagingRegistry
	var staging := _get_node(_staging_ref) as BlueprintConstructionMaterialStaging
	var port := _get_node(_port_ref) as BlueprintConstructionAnchoredStagingPort
	var belt := _get_node(_belt_ref) as ConveyorSegment
	var escrow := _get_node(_escrow_ref) as BlueprintConstructionMaterialEscrow
	if (
		not _live(registry)
		or not _live(staging)
		or not _live(port)
		or not _live(belt)
		or not _live(escrow)
	):
		blockers.append(&"service_unavailable")
		result["blockers"] = blockers
		return result

	var inventory: InventoryComponent = staging.get_staged_inventory()
	var cargo := belt.get_node_or_null(
		"ConveyorTransportComponent"
	) as ConveyorTransportComponent
	if (
		not _live(inventory)
		or not _live(cargo)
		or not _live(cargo.cargo_inventory)
		or not registry.has_locked_pair(staging, port)
		or port.get_bound_staging() != staging
	):
		blockers.append(&"ownership_or_inventory_unverified")
		result["blockers"] = blockers
		return result

	result["known"] = true
	var ended: bool = port.has_ended_site()
	var buffered: int = inventory.get_total_amount()
	var in_flight: int = cargo.cargo_inventory.get_total_amount()
	var has_escrow: bool = escrow.has_reservation(_reservation_id)
	var connected: bool = (
		belt.output_building_port == port
		or port.connected_conveyor == belt
	)

	result["site_ended"] = ended
	result["buffered"] = buffered
	result["belt_cargo"] = in_flight
	result["escrow_outstanding"] = has_escrow
	result["belt_connected"] = connected

	if not ended:
		blockers.append(&"site_not_ended")
	if port.enable_isolated_input:
		blockers.append(&"receiver_still_enabled")
	if connected:
		blockers.append(&"belt_still_connected")
	if in_flight != 0:
		blockers.append(&"belt_cargo_outstanding")
	if buffered != 0:
		blockers.append(&"staging_stock_outstanding")
	if has_escrow:
		blockers.append(&"escrow_outstanding")

	result["blockers"] = blockers
	result["drained_observed"] = blockers.is_empty()
	# Never grant an actual release. Registry claim remains permanently locked.
	result["safe_to_release"] = false
	return result


func _get_node(ref: WeakRef) -> Node:
	if ref == null:
		return null
	return ref.get_ref() as Node


func _live(node: Node) -> bool:
	return (
		is_instance_valid(node)
		and not node.is_queued_for_deletion()
		and node.is_inside_tree()
	)
