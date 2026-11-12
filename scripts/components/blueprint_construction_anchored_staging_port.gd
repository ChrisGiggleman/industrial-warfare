extends BlueprintConstructionStagingInputPort
class_name BlueprintConstructionAnchoredStagingPort

# =============================================================================
# E3D5C4I — ISOLATED RECEIVER ALIGNED TO A REAL CONSTRUCTION SITE
# =============================================================================
# A *separate* Node3D receiver hosts this input port at the position of an
# actual ConstructionSite PlannedInputPort. This port must NEVER be parented
# under the ConstructionSite: cancellation queues that site for deletion.
# Staging stock and escrow must survive until explicit, verified recovery.
#
# It is NOT automatically installed by player placement. Only an explicitly
# authorized QUEUED site may attach. The existing registry owns exclusive
# receiver/buffer claims and ConveyorBuildingTransfer owns physical delivery.
# Missing power/workers still prohibit construction; no readiness is granted.

var _site_ref: WeakRef = null
var _planned_ref: WeakRef = null
var _registry_ref: WeakRef = null
# Once cancellation or site destruction has been signalled, this latch stays
# true even after the ConstructionSite object itself is freed.
var _site_has_ended: bool = false


func attach_to_authorized_site(
	site: ConstructionSite,
	staging: BlueprintConstructionMaterialStaging,
	registry: BlueprintConstructionSiteStagingRegistry,
	port_name: StringName = &"InputPort"
) -> bool:
	if (
		not enable_isolated_input
		or not _live(site)
		or not _live(staging)
		or not _live(registry)
		or not registry.enable_isolated_site_registry
		or _site_ref != null
		or site.is_ancestor_of(self)
		or site.job == null
		or site.job.state != ConstructionJob.State.QUEUED
		or not str(port_name).begins_with("InputPort")
	):
		return false
	var planned: Marker3D = site.get_planned_port_named(port_name)
	if not _live(planned) or not staging.matches_definition(site.target_definition):
		return false
	if get_bound_staging() != null:
		return false
	if not bind_staging(staging):
		return false

	# The physical input is separate from the site and is placed at the
	# blueprint port marker. Merely touching a ghost remains non-operational.
	global_transform = planned.global_transform
	if not registry.claim_site(site, staging, self):
		# A failed ownership claim must not turn this port into a general
		# construction receiver. It remains unowned and rejects delivery.
		enable_isolated_input = false
		return false

	_site_ref = weakref(site)
	_planned_ref = weakref(planned)
	_registry_ref = weakref(registry)
	site.job.job_cancelled.connect(_disable_on_site_end)
	site.tree_exiting.connect(_disable_on_site_end)
	return true


func matches_attached_site() -> bool:
	if not enable_isolated_input or _site_ref == null:
		return false
	var site: ConstructionSite = _site_ref.get_ref() as ConstructionSite
	var planned: Marker3D = _planned_ref.get_ref() as Marker3D
	var registry: BlueprintConstructionSiteStagingRegistry = (
		_registry_ref.get_ref() as BlueprintConstructionSiteStagingRegistry
	)
	if not _live(site) or not _live(planned) or not _live(registry):
		return false
	if site.job == null or site.job.state != ConstructionJob.State.QUEUED:
		return false
	if not global_transform.is_equal_approx(planned.global_transform):
		return false
	var staged: BlueprintConstructionMaterialStaging = get_bound_staging()
	if not _live(staged):
		return false
	return registry.inventory_for_site(site) == staged.get_staged_inventory()


func can_accept_item(item: ItemDefinition, amount: int = 1) -> bool:
	return matches_attached_site() and super.can_accept_item(item, amount)


func has_ended_site() -> bool:
	return _site_ref != null and _site_has_ended


func _disable_on_site_end() -> void:
	_site_has_ended = true
	enable_isolated_input = false
