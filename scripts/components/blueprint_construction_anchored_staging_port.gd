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
# E3d5c5h — explicit single-straight-belt verification only.
@export var enable_isolated_single_belt_route_guard: bool = false
var _direct_belt_ref: WeakRef = null
# E3d5c5i: independent opt-in; an exact linear route of 2–64 belts.
@export var enable_isolated_multi_belt_route_guard: bool = false
# E3d5c5j: allow actual in-place left/right conversions only by separate opt-in.
@export var enable_isolated_corner_route_guard: bool = false
var _linear_route_refs: Array[WeakRef] = []
var _linear_input_transforms: Array[Transform3D] = []
var _linear_output_transforms: Array[Transform3D] = []
var _linear_corner_mode: bool = false
# E3d5c5l: one tracked splitter, one upstream straight belt and downstream straight chain.
@export var enable_isolated_splitter_branch_guard: bool = false
var _branch_splitter_ref: WeakRef = null
var _branch_incoming_ref: WeakRef = null
var _branch_input_ref: WeakRef = null
var _branch_output_ref: WeakRef = null
var _branch_route_refs: Array[WeakRef] = []
# E3d5c5n: one merger crossing with a single enrolled origin and pinned lane.
@export var enable_isolated_merger_route_guard: bool = false
var _merger_route_merger_ref: WeakRef = null
var _merger_route_incoming_ref: WeakRef = null
var _merger_route_input_ref: WeakRef = null
var _merger_route_output_ref: WeakRef = null
var _merger_route_refs: Array[WeakRef] = []
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


# Pin a specific empty straight belt after verifying both physical ends.
# No automatic route placement, stock mutation or construction authority.
func bind_single_belt_route(belt: ConveyorSegment) -> bool:
	if (
		not enable_isolated_single_belt_route_guard or _direct_belt_ref != null
		or _branch_selected() or _merger_selected()
		or enable_isolated_multi_belt_route_guard or not _linear_route_refs.is_empty()
		or enable_isolated_corner_route_guard
		or not matches_attached_site() or _intake_escrow_ref == null
		or _original_output_ref == null or is_output_source_locked()
		or is_escrow_intake_locked() or not _single_belt_geometry_valid(belt)
	):
		return false
	var cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
	if not _live(cargo) or not _live(cargo.cargo_inventory):
		return false
	if cargo.cargo_inventory.max_capacity != 1 or cargo.cargo_inventory.get_total_amount() != 0:
		return false
	_direct_belt_ref = weakref(belt)
	return true


func _single_belt_geometry_valid(belt: ConveyorSegment) -> bool:
	if not _live(belt) or _original_output_ref == null or not _live(get_parent()):
		return false
	var source := _original_output_ref.get_ref() as ItemPortComponent
	if not _live(source) or not _live(source.get_parent()):
		return false
	if (
		belt.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn"
		or belt.has_meta("conveyor_turn")
		or belt.get_parent() != get_parent().get_parent()
		or belt.previous_segment != null or belt.next_segment != null
		or belt.input_building_port != source or source.connected_conveyor != belt
		or belt.output_building_port != self or connected_conveyor != belt
		or direction != ItemPortComponent.PortDirection.INPUT
		or source.direction != ItemPortComponent.PortDirection.OUTPUT
	):
		return false
	var input := belt.get_node_or_null("InputEndpoint") as Marker3D
	var output := belt.get_node_or_null("OutputEndpoint") as Marker3D
	return (
		_live(input) and _live(output)
		and LogisticsConnectionGeometry.are_endpoints_aligned(
			source, input, ConveyorSegment.CONNECTION_GAP
		)
		and LogisticsConnectionGeometry.are_endpoints_aligned(
			output, self, ConveyorSegment.CONNECTION_GAP
		)
	)


func has_verified_single_belt_route() -> bool:
	if (
		not enable_isolated_single_belt_route_guard or _direct_belt_ref == null
		or not matches_attached_site() or is_output_source_locked()
	):
		return false
	return _single_belt_geometry_valid(_direct_belt_ref.get_ref() as ConveyorSegment)


# Bind the complete path in source-to-receiver order while every buffer
# is empty. No segment may repeat, branch, or belong to another sandbox.
func bind_multi_belt_route(route: Array[ConveyorSegment]) -> bool:
	if (
		not enable_isolated_multi_belt_route_guard or not _linear_route_refs.is_empty()
		or _branch_selected() or _merger_selected()
		or enable_isolated_single_belt_route_guard or _direct_belt_ref != null
		or not matches_attached_site() or _intake_escrow_ref == null
		or _original_output_ref == null or is_output_source_locked()
		or is_escrow_intake_locked() or not _linear_geometry_valid(route)
	):
		return false
	for segment: ConveyorSegment in route:
		var cargo := segment.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		if not _live(cargo) or not _live(cargo.cargo_inventory):
			return false
		if cargo.cargo_inventory.get_total_amount() != 0 or cargo.cargo_inventory.max_capacity != 1:
			return false
	for segment: ConveyorSegment in route:
		_linear_route_refs.append(weakref(segment))
		var input := segment.get_node("InputEndpoint") as Marker3D
		var output := segment.get_node("OutputEndpoint") as Marker3D
		_linear_input_transforms.append(input.transform)
		_linear_output_transforms.append(output.transform)
	_linear_corner_mode = enable_isolated_corner_route_guard
	return true


func _linear_geometry_valid(route: Array[ConveyorSegment]) -> bool:
	if route.size() < 2 or route.size() > 64 or not _live(get_parent()):
		return false
	if _original_output_ref == null:
		return false
	var source := _original_output_ref.get_ref() as ItemPortComponent
	if not _live(source) or not _live(source.get_parent()):
		return false
	if source.direction != ItemPortComponent.PortDirection.OUTPUT or direction != ItemPortComponent.PortDirection.INPUT:
		return false
	var seen: Dictionary = {}
	for i: int in range(route.size()):
		var segment: ConveyorSegment = route[i]
		if not _live(segment) or seen.has(segment):
			return false
		seen[segment] = true
		if (
			segment.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn"
			or segment.get_parent() != get_parent().get_parent()
		):
			return false
		var incoming := segment.get_node_or_null("InputEndpoint") as Marker3D
		var outgoing := segment.get_node_or_null("OutputEndpoint") as Marker3D
		if not _live(incoming) or not _live(outgoing):
			return false
		if not _valid_linear_piece_geometry(segment, incoming, outgoing):
			return false
		if not _linear_route_refs.is_empty():
			if (
				i >= _linear_input_transforms.size()
				or i >= _linear_output_transforms.size()
				or not incoming.transform.is_equal_approx(_linear_input_transforms[i])
				or not outgoing.transform.is_equal_approx(_linear_output_transforms[i])
			):
				return false
		if i == 0:
			if segment.previous_segment != null or segment.input_building_port != source or source.connected_conveyor != segment:
				return false
			if not LogisticsConnectionGeometry.are_endpoints_aligned(source, incoming, ConveyorSegment.CONNECTION_GAP):
				return false
		else:
			var previous: ConveyorSegment = route[i - 1]
			if segment.previous_segment != previous or previous.next_segment != segment or segment.input_building_port != null:
				return false
			var previous_output := previous.get_node_or_null("OutputEndpoint") as Marker3D
			if not LogisticsConnectionGeometry.are_endpoints_aligned(previous_output, incoming, ConveyorSegment.CONNECTION_GAP):
				return false
		if i == route.size() - 1:
			if segment.next_segment != null or segment.output_building_port != self or connected_conveyor != segment:
				return false
			if not LogisticsConnectionGeometry.are_endpoints_aligned(outgoing, self, ConveyorSegment.CONNECTION_GAP):
				return false
		elif segment.output_building_port != null:
			return false
	return true


# Real automatic corner conversion preserves the straight PackedScene path
# and records conveyor_turn on the same node. Check local marker geometry
# as well as that tag, rather than trusting scene_file_path alone.
# The two original turn templates remain the authoritative local shape.
func _valid_linear_piece_geometry(
	segment: ConveyorSegment, incoming: Marker3D, outgoing: Marker3D
) -> bool:
	if not incoming.position.is_equal_approx(Vector3(0.0, 0.5, 0.5)):
		return false
	var in_forward: Vector3 = (incoming.transform.basis * Vector3.FORWARD).normalized()
	var out_forward: Vector3 = (outgoing.transform.basis * Vector3.FORWARD).normalized()
	if not segment.has_meta("conveyor_turn"):
		return (
			outgoing.position.is_equal_approx(Vector3(0.0, 0.5, -0.5))
			and in_forward.dot(out_forward) < -0.98
		)
	if not enable_isolated_corner_route_guard:
		return false
	var turn: int = int(segment.get_meta("conveyor_turn"))
	var expected: Vector3
	if turn == ConveyorTurnIntent.Turn.RIGHT:
		expected = Vector3(0.5, 0.5, 0.0)
	elif turn == ConveyorTurnIntent.Turn.LEFT:
		expected = Vector3(-0.5, 0.5, 0.0)
	else:
		return false
	return outgoing.position.is_equal_approx(expected) and absf(in_forward.dot(out_forward)) < 0.02


func _bound_linear_route() -> Array[ConveyorSegment]:
	var route: Array[ConveyorSegment] = []
	for ref: WeakRef in _linear_route_refs:
		var segment := ref.get_ref() as ConveyorSegment
		if not _live(segment):
			return []
		route.append(segment)
	return route


func has_verified_multi_belt_route() -> bool:
	if (
		not enable_isolated_multi_belt_route_guard or _linear_route_refs.is_empty()
		or enable_isolated_corner_route_guard != _linear_corner_mode
		or enable_isolated_single_belt_route_guard or _direct_belt_ref != null
		or not matches_attached_site() or is_output_source_locked()
	):
		return false
	return _linear_geometry_valid(_bound_linear_route())


func _branch_selected() -> bool:
	return enable_isolated_splitter_branch_guard or _branch_splitter_ref != null


func _other_route_selected() -> bool:
	return (
		enable_isolated_single_belt_route_guard or _direct_belt_ref != null
		or enable_isolated_multi_belt_route_guard or not _linear_route_refs.is_empty()
		or enable_isolated_corner_route_guard
	)


func _branch_straight(belt: ConveyorSegment) -> bool:
	if not _live(belt) or belt.get_parent() != get_parent().get_parent():
		return false
	if belt.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn" or belt.has_meta("conveyor_turn"):
		return false
	var a := belt.get_node_or_null("InputEndpoint") as Marker3D
	var z := belt.get_node_or_null("OutputEndpoint") as Marker3D
	return _live(a) and _live(z) and _valid_linear_piece_geometry(belt, a, z)


func _branch_port_link(belt: ConveyorSegment, port: ItemPortComponent, is_input: bool) -> bool:
	if not _live(port) or port.connected_conveyor != belt:
		return false
	if is_input:
		return (
			port.direction == ItemPortComponent.PortDirection.OUTPUT
			and belt.previous_segment == null and belt.input_building_port == port
			and LogisticsConnectionGeometry.are_endpoints_aligned(
				port, belt.get_node_or_null("InputEndpoint"), ConveyorSegment.CONNECTION_GAP)
		)
	return (
		port.direction == ItemPortComponent.PortDirection.INPUT
		and belt.next_segment == null and belt.output_building_port == port
		and LogisticsConnectionGeometry.are_endpoints_aligned(
			belt.get_node_or_null("OutputEndpoint"), port, ConveyorSegment.CONNECTION_GAP)
	)


func _branch_geometry(splitter: ConveyorSplitterComponent, incoming: ConveyorSegment,
	input: ItemPortComponent, output: ItemPortComponent, route: Array[ConveyorSegment]) -> bool:
	if not _live(splitter) or not _live(get_parent()) or not _live(splitter.get_parent()):
		return false
	var building: Node = splitter.get_parent()
	if building.get_parent() != get_parent().get_parent() or not splitter.is_verified_provenance_ready():
		return false
	if not _live(input) or not _live(output) or input.get_parent() != building or output.get_parent() != building:
		return false
	if input != building.get_node_or_null("InputPort"):
		return false
	if output != splitter.output_port_a and output != splitter.output_port_b and output != splitter.output_port_c:
		return false
	if _original_output_ref == null or route.is_empty() or route.size() > 64:
		return false
	var origin := _original_output_ref.get_ref() as ItemPortComponent
	if not _branch_straight(incoming) or not _branch_port_link(incoming, origin, true):
		return false
	if not _branch_port_link(incoming, input, false):
		return false
	var seen: Dictionary = {incoming: true}
	for i: int in range(route.size()):
		var belt: ConveyorSegment = route[i]
		if not _branch_straight(belt) or seen.has(belt):
			return false
		seen[belt] = true
		if i == 0:
			if not _branch_port_link(belt, output, true):
				return false
		else:
			var prior: ConveyorSegment = route[i - 1]
			if belt.input_building_port != null or prior.output_building_port != null:
				return false
			if prior.next_segment != belt or belt.previous_segment != prior:
				return false
			if not LogisticsConnectionGeometry.are_endpoints_aligned(
				prior.get_node_or_null("OutputEndpoint"), belt.get_node_or_null("InputEndpoint"),
				ConveyorSegment.CONNECTION_GAP):
				return false
	return _branch_port_link(route[-1], self, false)


func bind_splitter_branch(splitter: ConveyorSplitterComponent, incoming: ConveyorSegment,
	input: ItemPortComponent, output: ItemPortComponent, route: Array[ConveyorSegment]) -> bool:
	if (
		not enable_isolated_splitter_branch_guard or _branch_splitter_ref != null
		or _other_route_selected() or _merger_selected() or not matches_attached_site()
		or _intake_escrow_ref == null or _original_output_ref == null
		or is_escrow_intake_locked() or is_output_source_locked()
		or not _branch_geometry(splitter, incoming, input, output, route)
	):
		return false
	var all_belts: Array[ConveyorSegment] = [incoming]
	all_belts.append_array(route)
	for belt: ConveyorSegment in all_belts:
		var cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		if not _live(cargo) or not _live(cargo.cargo_inventory):
			return false
		if cargo.cargo_inventory.max_capacity != 1 or cargo.cargo_inventory.get_total_amount() != 0:
			return false
	for buffer: InventoryComponent in [splitter.input_inventory, splitter.output_a, splitter.output_b, splitter.output_c]:
		if buffer.get_total_amount() != 0:
			return false
	_branch_splitter_ref = weakref(splitter)
	_branch_incoming_ref = weakref(incoming)
	_branch_input_ref = weakref(input)
	_branch_output_ref = weakref(output)
	for belt: ConveyorSegment in route:
		_branch_route_refs.append(weakref(belt))
	return true


func _bound_branch_route() -> Array[ConveyorSegment]:
	var route: Array[ConveyorSegment] = []
	for ref: WeakRef in _branch_route_refs:
		var belt := ref.get_ref() as ConveyorSegment
		if not _live(belt):
			return []
		route.append(belt)
	return route


func has_verified_splitter_branch() -> bool:
	if (
		not enable_isolated_splitter_branch_guard or _branch_splitter_ref == null
		or _other_route_selected() or _merger_selected() or not matches_attached_site() or is_output_source_locked()
	):
		return false
	return _branch_geometry(
		_branch_splitter_ref.get_ref() as ConveyorSplitterComponent,
		_branch_incoming_ref.get_ref() as ConveyorSegment,
		_branch_input_ref.get_ref() as ItemPortComponent,
		_branch_output_ref.get_ref() as ItemPortComponent, _bound_branch_route())


func _accept_owned_item(item: ItemDefinition, amount: int) -> bool:
	return (
		matches_attached_site()
		and not is_escrow_intake_locked()
		and not is_output_source_locked()
		and super.can_accept_item(item, amount)
	)


func can_accept_item(item: ItemDefinition, amount: int = 1) -> bool:
	# A guard-bound receiver requires transport context; direct port-to-port
	# transfer is never an alternate route, even with valid material types.
	if _branch_selected() or _merger_selected():
		return false
	if (
		enable_isolated_single_belt_route_guard or _direct_belt_ref != null
		or enable_isolated_multi_belt_route_guard or not _linear_route_refs.is_empty()
		or enable_isolated_corner_route_guard
	):
		return false
	return _accept_owned_item(item, amount)


func can_accept_belt_item(belt: ConveyorSegment, item: ItemDefinition, amount: int = 1) -> bool:
	if _merger_selected():
		if amount != 1 or not has_verified_merger_route() or not _accept_owned_item(item, amount):
			return false
		var merged_route: Array[ConveyorSegment] = _bound_merger_route()
		if merged_route.is_empty() or merged_route[-1] != belt:
			return false
		var merged_cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		return _live(merged_cargo) and merged_cargo.has_verified_merger_route(
			_original_output_ref.get_ref() as ItemPortComponent, item,
			_merger_route_merger_ref.get_ref() as ConveyorMergerComponent,
			_merger_route_incoming_ref.get_ref() as ConveyorSegment,
			_merger_route_input_ref.get_ref() as ItemPortComponent,
			_merger_route_output_ref.get_ref() as ItemPortComponent, merged_route)
	if _branch_selected():
		if amount != 1 or not has_verified_splitter_branch() or not _accept_owned_item(item, amount):
			return false
		var branch: Array[ConveyorSegment] = _bound_branch_route()
		if branch.is_empty() or branch[-1] != belt:
			return false
		var branch_cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		return _live(branch_cargo) and branch_cargo.has_verified_splitter_branch(
			_original_output_ref.get_ref() as ItemPortComponent, item,
			_branch_splitter_ref.get_ref() as ConveyorSplitterComponent,
			_branch_incoming_ref.get_ref() as ConveyorSegment,
			_branch_input_ref.get_ref() as ItemPortComponent,
			_branch_output_ref.get_ref() as ItemPortComponent, branch)
	if (
		enable_isolated_multi_belt_route_guard or not _linear_route_refs.is_empty()
		or enable_isolated_corner_route_guard
	):
		if amount != 1 or not has_verified_multi_belt_route() or not _accept_owned_item(item, amount):
			return false
		var route: Array[ConveyorSegment] = _bound_linear_route()
		if route.is_empty() or route[-1] != belt:
			return false
		var origin := _original_output_ref.get_ref() as ItemPortComponent
		var final_cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		return _live(final_cargo) and final_cargo.has_verified_physical_route(origin, item, route)
	if not enable_isolated_single_belt_route_guard and _direct_belt_ref == null:
		return can_accept_item(item, amount)
	if (
		amount != 1 or not has_verified_single_belt_route()
		or _direct_belt_ref.get_ref() != belt or not _accept_owned_item(item, amount)
	):
		return false
	var source := _original_output_ref.get_ref() as ItemPortComponent
	var cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
	return _live(cargo) and cargo.has_physical_building_load(source, item)


func has_ended_site() -> bool:
	return _site_ref != null and _site_has_ended


func _disable_on_site_end() -> void:
	_site_has_ended = true
	enable_isolated_input = false


func _merger_selected() -> bool:
	return enable_isolated_merger_route_guard or _merger_route_merger_ref != null


func _merger_geometry(merger: ConveyorMergerComponent, incoming: ConveyorSegment,
	input: ItemPortComponent, output: ItemPortComponent, route: Array[ConveyorSegment]) -> bool:
	if not _live(merger) or not _live(get_parent()) or not _live(merger.get_parent()):
		return false
	var building: Node = merger.get_parent()
	if building.get_parent() != get_parent().get_parent() or not merger.is_verified_merger_provenance_ready():
		return false
	if not _live(input) or not _live(output) or input.get_parent() != building or output.get_parent() != building:
		return false
	if input != building.get_node_or_null("InputPortA") and input != building.get_node_or_null("InputPortB") and input != building.get_node_or_null("InputPortC"):
		return false
	if output != building.get_node_or_null("OutputPort"):
		return false
	if _original_output_ref == null or route.is_empty() or route.size() > 64:
		return false
	var origin := _original_output_ref.get_ref() as ItemPortComponent
	if not _branch_straight(incoming) or not _branch_port_link(incoming, origin, true):
		return false
	if not _branch_port_link(incoming, input, false):
		return false
	var seen: Dictionary = {incoming: true}
	for i: int in range(route.size()):
		var belt: ConveyorSegment = route[i]
		if not _branch_straight(belt) or seen.has(belt):
			return false
		seen[belt] = true
		if i == 0:
			if not _branch_port_link(belt, output, true):
				return false
		else:
			var prior: ConveyorSegment = route[i - 1]
			if belt.input_building_port != null or prior.output_building_port != null:
				return false
			if prior.next_segment != belt or belt.previous_segment != prior:
				return false
			if not LogisticsConnectionGeometry.are_endpoints_aligned(
				prior.get_node_or_null("OutputEndpoint"), belt.get_node_or_null("InputEndpoint"),
				ConveyorSegment.CONNECTION_GAP):
				return false
	return _branch_port_link(route[-1], self, false)


func bind_merger_route(merger: ConveyorMergerComponent, incoming: ConveyorSegment,
	input: ItemPortComponent, output: ItemPortComponent, route: Array[ConveyorSegment]) -> bool:
	if (
		not enable_isolated_merger_route_guard or _merger_route_merger_ref != null
		or _other_route_selected() or _branch_selected() or not matches_attached_site()
		or _intake_escrow_ref == null or _original_output_ref == null
		or is_escrow_intake_locked() or is_output_source_locked()
		or not _merger_geometry(merger, incoming, input, output, route)
	):
		return false
	var all_belts: Array[ConveyorSegment] = [incoming]
	all_belts.append_array(route)
	for belt: ConveyorSegment in all_belts:
		var cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		if not _live(cargo) or not _live(cargo.cargo_inventory):
			return false
		if cargo.cargo_inventory.max_capacity != 1 or cargo.cargo_inventory.get_total_amount() != 0:
			return false
	for buffer: InventoryComponent in [merger.input_a, merger.input_b, merger.input_c, merger.output_inventory]:
		if buffer.get_total_amount() != 0:
			return false
	_merger_route_merger_ref = weakref(merger)
	_merger_route_incoming_ref = weakref(incoming)
	_merger_route_input_ref = weakref(input)
	_merger_route_output_ref = weakref(output)
	for belt: ConveyorSegment in route:
		_merger_route_refs.append(weakref(belt))
	return true


func _bound_merger_route() -> Array[ConveyorSegment]:
	var route: Array[ConveyorSegment] = []
	for ref: WeakRef in _merger_route_refs:
		var belt := ref.get_ref() as ConveyorSegment
		if not _live(belt):
			return []
		route.append(belt)
	return route


func has_verified_merger_route() -> bool:
	if (
		not enable_isolated_merger_route_guard or _merger_route_merger_ref == null
		or _other_route_selected() or _branch_selected()
		or not matches_attached_site() or is_output_source_locked()
	):
		return false
	return _merger_geometry(
		_merger_route_merger_ref.get_ref() as ConveyorMergerComponent,
		_merger_route_incoming_ref.get_ref() as ConveyorSegment,
		_merger_route_input_ref.get_ref() as ItemPortComponent,
		_merger_route_output_ref.get_ref() as ItemPortComponent, _bound_merger_route())
