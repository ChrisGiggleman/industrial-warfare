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

# E3d5c5c — test-only escrow intake gate. Default OFF preserves the
# earlier E3d5c4i queued-buffer/refund fixture. Once the guard is bound,
# disabling it never silently restores material intake.
@export var enable_isolated_escrow_intake_lock: bool = false
# E3d5c5f — separate, default-OFF guard for source-enrolled receivers.
# Once bound, observed source replacement/deletion permanently closes input.
@export var enable_isolated_output_source_guard: bool = false
var _original_output_ref: WeakRef = null
var _original_output_inventory_ref: WeakRef = null
var _output_source_compromised: bool = false
var _intake_escrow_ref: WeakRef = null

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


# Explicitly bind this already owned construction receiver to a live escrow
# BEFORE materials are reserved. This cannot allocate, withdraw, or restore
# materials; it only allows read-only admission checks from the belt.
func bind_escrow_intake_lock(
	escrow: BlueprintConstructionMaterialEscrow
) -> bool:
	if (
		not enable_isolated_escrow_intake_lock
		or _intake_escrow_ref != null
		or not _live(escrow)
		or not matches_attached_site()
	):
		return false
	var site: ConstructionSite = _site_ref.get_ref() as ConstructionSite
	var registry: BlueprintConstructionSiteStagingRegistry = (
		_registry_ref.get_ref() as BlueprintConstructionSiteStagingRegistry
	)
	if (
		not _live(site) or not _live(registry)
		or not registry.matches_owned_inventory(site, inventory)
		or escrow.reservation_for(site) != 0
	):
		return false
	_intake_escrow_ref = weakref(escrow)
	return true


# Fail CLOSED if a bound guard is turned off, its escrow disappears, or the
# site leaves the original, aligned QUEUED ownership state. Otherwise refuse
# fresh conveyor delivery as soon as the complete bill is in escrow, even
# while a physical drone is traveling to the still-QUEUED site.
func is_escrow_intake_locked() -> bool:
	if _intake_escrow_ref == null:
		return enable_isolated_escrow_intake_lock
	if not enable_isolated_escrow_intake_lock or not matches_attached_site():
		return true
	var escrow: BlueprintConstructionMaterialEscrow = (
		_intake_escrow_ref.get_ref() as BlueprintConstructionMaterialEscrow
	)
	var site: ConstructionSite = _site_ref.get_ref() as ConstructionSite
	if not _live(escrow) or not _live(site):
		return true
	return escrow.reservation_for(site) > 0


# Bind an authenticated source output to the already protected receiver.
# A missing source or unbound opt-in is never permission to accept cargo.
# This guard is observational: it never transfers, creates or reserves items.
func bind_output_source_guard(
	output: ItemPortComponent,
	expected: InventoryComponent
) -> bool:
	if (
		not enable_isolated_output_source_guard
		or _original_output_ref != null
		or _original_output_inventory_ref != null
		or not matches_attached_site()
		or _intake_escrow_ref == null
		or not _live(output) or not _live(expected)
		or output.direction != ItemPortComponent.PortDirection.OUTPUT
		or output.inventory != expected
	):
		return false
	var owner: Node = output.get_parent()
	var sandbox: Node = get_parent().get_parent()
	var staging: BlueprintConstructionMaterialStaging = get_bound_staging()
	if (
		not _live(owner) or not owner is Node3D
		or owner is ConstructionSite or owner.get_parent() != sandbox
		or expected.get_parent() != owner
		or not _live(staging)
		or not staging.matches_source_inventory(expected)
	):
		return false
	if (
		is_instance_valid(output.producer_component)
		and output.producer_component.output_inventory != expected
	):
		return false
	_original_output_ref = weakref(output)
	_original_output_inventory_ref = weakref(expected)
	return true


# Any observed deletion, reroute, replacement, staging rebind or disabled
# guard latches closed for this receiver's lifetime. No silent reopening.
func is_output_source_locked() -> bool:
	if _original_output_ref == null:
		return enable_isolated_output_source_guard
	if _output_source_compromised:
		return true
	var output: ItemPortComponent = (
		_original_output_ref.get_ref() as ItemPortComponent
	)
	var expected: InventoryComponent = (
		_original_output_inventory_ref.get_ref() as InventoryComponent
	)
	var staging: BlueprintConstructionMaterialStaging = get_bound_staging()
	var owner: Node = output.get_parent() if _live(output) else null
	var sandbox: Node = get_parent().get_parent()
	var good: bool = (
		enable_isolated_output_source_guard
		and _live(output) and _live(expected)
		and output.direction == ItemPortComponent.PortDirection.OUTPUT
		and output.inventory == expected
		and _live(owner) and owner is Node3D
		and not owner is ConstructionSite
		and owner.get_parent() == sandbox
		and expected.get_parent() == owner
		and _live(staging) and staging.matches_source_inventory(expected)
	)
	if good and is_instance_valid(output.producer_component):
		good = output.producer_component.output_inventory == expected
	if not good:
		_output_source_compromised = true
	return not good


func can_accept_item(item: ItemDefinition, amount: int = 1) -> bool:
	return (
		matches_attached_site()
		and not is_escrow_intake_locked()
		and not is_output_source_locked()
		and super.can_accept_item(item, amount)
	)


func has_ended_site() -> bool:
	return _site_ref != null and _site_has_ended


func _disable_on_site_end() -> void:
	_site_has_ended = true
	enable_isolated_input = false
