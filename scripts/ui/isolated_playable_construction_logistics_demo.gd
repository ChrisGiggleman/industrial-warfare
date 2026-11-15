extends Node
## E3d5c5w: explicit one-site tutorial in the real factory sandbox.
## Not attached to the committed normal sandbox or Main.

const SOURCE_POSITION := Vector3(-5, 0, 4)
const SITE_POSITION := Vector3(-5, 0, 0)
const BELT_POSITION := Vector3(-5, 0, 2)
const STORAGE = preload("res://data/buildings/test_storage.tres")
const INGOT = preload("res://data/items/test_ingot.tres")

# Only the tutorial fixture's output is held until the exact empty route
# is bound. Actual transfers still use the original timer and proof helpers.
class LockedSupplyPort:
	extends ItemPortComponent
	var route: WeakRef = null
	var receiver: WeakRef = null

	func can_provide_item(item: ItemDefinition, amount: int = 1) -> bool:
		if route == null or receiver == null:
			return false
		var belt := route.get_ref() as ConveyorSegment
		var port := receiver.get_ref() as BlueprintConstructionAnchoredStagingPort
		if not is_instance_valid(belt) or not is_instance_valid(port):
			return false
		if belt.is_queued_for_deletion() or port.is_queued_for_deletion():
			return false
		if connected_conveyor != belt or belt.input_building_port != self or belt.output_building_port != port or port.connected_conveyor != belt:
			return false
		if not port.matches_attached_site() or not port.enable_isolated_unified_route_adapter or not port.enable_isolated_unified_receiver_consolidation or not port.has_bound_unified_receiver_consolidation() or port.is_escrow_intake_locked() or port.is_output_source_locked():
			return false
		if not port.has_verified_single_belt_route():
			return false
		return super.can_provide_item(item, amount)


@export var enable_isolated_playable_demo: bool = false
var source: Node3D = null
var supply: LockedSupplyPort = null
var registry: BlueprintConstructionSiteStagingRegistry = null
var escrow: BlueprintConstructionMaterialEscrow = null
var gate: SandboxConstructionDroneLifecycleGate = null
var world: Node = null
var site: ConstructionSite = null
var staging: BlueprintConstructionMaterialStaging = null
var receiver: BlueprintConstructionAnchoredStagingPort = null
var bound_belt: ConveyorSegment = null
var _started: bool = false
var _status: String = ""
var _label: Label = null


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)


func _live(node: Node) -> bool:
	return is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()


func start_demo() -> bool:
	var sandbox := get_parent() as Node3D
	if not enable_isolated_playable_demo or _started or not _live(sandbox):
		return false
	if sandbox.scene_file_path != "res://scenes/core/factory_testing_sandbox.tscn":
		return false
	world = sandbox.get_node_or_null("WorldInteraction")
	gate = sandbox.get_node_or_null("ConstructionDroneLifecycleGate") as SandboxConstructionDroneLifecycleGate
	if not _live(world) or not _live(gate) or gate.enable_isolated_bridge:
		return false
	# Only this instance: remove the legacy readiness bypass and avoid
	# planned-port reservations competing with the live tutorial receiver.
	world.set("blueprint_sandbox_debug_requirements", false)
	world.set("enable_planned_storage_conveyor_snap", false)
	world.set("enable_connected_storage_blueprints", false)
	gate.enable_isolated_bridge = true
	gate.enable_isolated_authorization_autowire = true
	gate.enable_isolated_output_enrollment = true
	registry = BlueprintConstructionSiteStagingRegistry.new()
	registry.enable_isolated_site_registry = true
	sandbox.add_child(registry)
	escrow = BlueprintConstructionMaterialEscrow.new()
	sandbox.add_child(escrow)
	if not gate.configure_authorization_autowire(registry, escrow):
		return false
	world.connect(&"blueprint_site_authorized", _on_authorized)
	# Deliberate starter fixture: four visible counted ingots, seeded once.
	# No other stock, worker, energy or authorization is manufactured.
	source = STORAGE.building_scene.instantiate() as Node3D
	var original := source.get_node("OutputPort") as ItemPortComponent
	var stock := source.get_node("InventoryComponent") as InventoryComponent
	supply = LockedSupplyPort.new()
	supply.name = "OutputPort"
	supply.transform = original.transform
	supply.direction = ItemPortComponent.PortDirection.OUTPUT
	supply.inventory = stock
	source.remove_child(original)
	original.free()
	source.add_child(supply)
	source.name = "TutorialStarterStorage"
	sandbox.add_child(source)
	source.global_position = SOURCE_POSITION
	if stock.add_item(INGOT, 4) != 4:
		return false
	_started = true
	_ground_marker(SITE_POSITION, Color(0.12, 0.65, 0.85, 0.35), Vector2(1, 3))
	_ground_marker(BELT_POSITION, Color(0.15, 0.85, 0.35, 0.45), Vector2(1, 1))
	_guide("STARTER: 4 INGOTS", SOURCE_POSITION + Vector3.UP * 1.5, Color(1, 0.75, 0.25))
	_guide("PLACE STORAGE PLAN HERE", SITE_POSITION + Vector3.UP * 1.2, Color(0.35, 0.9, 1))
	_guide("ONE STRAIGHT BELT", BELT_POSITION + Vector3.UP * 0.45, Color(0.35, 1, 0.55))
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 70)
	layer.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	_label = Label.new()
	_label.custom_minimum_size = Vector2(430, 92)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_color_override("font_color", Color(0.9, 0.97, 1))
	_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	rows.add_child(_label)
	var actions := HBoxContainer.new()
	rows.add_child(actions)
	var prepare := Button.new()
	prepare.text = "Prepare marked plan (F7)"
	prepare.pressed.connect(_prepare_marked_plan)
	actions.add_child(prepare)
	var bind := Button.new()
	bind.text = "Bind connected belt (F8)"
	bind.pressed.connect(_bind_connected_belt)
	actions.add_child(bind)
	_status = "Build mode + P: place Test Storage at cyan marker, default rotation. Prepare marked plan."
	set_process(true)
	set_process_unhandled_input(true)
	return true


# Non-colliding ground tiles show the exact required placement centers.
func _ground_marker(at: Vector3, color: Color, size: Vector2) -> void:
	var mesh := PlaneMesh.new()
	mesh.size = size * 0.92
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var marker := MeshInstance3D.new()
	marker.mesh = mesh
	marker.material_override = material
	add_child(marker)
	marker.global_position = at + Vector3.UP * 0.025


func _guide(message: String, at: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = message
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.font_size = 28
	label.pixel_size = 0.008
	label.outline_size = 6
	add_child(label)
	label.global_position = at


func prepare_site(candidate: ConstructionSite) -> bool:
	if not enable_isolated_playable_demo or not _started or site != null or not _live(candidate) or not _live(supply):
		return false
	if not world.call("_is_managed_blueprint", candidate) or candidate.job.state != ConstructionJob.State.PLANNED:
		return false
	if candidate.target_definition != STORAGE or not candidate.global_transform.is_equal_approx(Transform3D(Basis.IDENTITY, SITE_POSITION)):
		return false
	if supply.inventory.get_amount(INGOT) != 4 or supply.connected_conveyor != null:
		return false
	var prepared := gate.prepare_player_site_from_output(candidate, supply)
	if prepared == null:
		return false
	site = candidate
	staging = prepared
	_status = "Prepared. Hover the plan and press E to authorize. F7 does not authorize."
	return true


func _on_authorized(candidate: ConstructionSite) -> void:
	if not _started or candidate != site:
		return
	receiver = gate.receiver_for_authorized_site(candidate)
	if not _live(receiver):
		_status = "Receiver unavailable; restart demo."
		return
	# Close all intake until explicit empty-route enrollment.
	receiver.enable_isolated_unified_route_adapter = true
	receiver.enable_isolated_unified_receiver_consolidation = true
	_status = "Authorized. P off; place one straight belt at green marker, facing starter to plan. Then Bind."


func bind_player_belt(belt: ConveyorSegment) -> bool:
	if not enable_isolated_playable_demo or not _started or bound_belt != null or not _live(receiver) or not _live(supply):
		return false
	if not receiver.matches_attached_site() or not _live(belt) or belt.get_parent() != get_parent() or not belt.is_in_group("player_built") or belt.is_in_group("construction_preview"):
		return false
	if belt.scene_file_path != "res://scenes/logistics/conveyor_straight.tscn" or belt.has_meta("conveyor_turn") or belt.previous_segment != null or belt.next_segment != null:
		return false
	if belt.input_building_port != supply or supply.connected_conveyor != belt:
		return false
	if belt.output_building_port != null and belt.output_building_port != receiver:
		return false
	var cargo := belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
	if not _live(cargo) or not _live(cargo.cargo_inventory) or cargo.cargo_inventory.get_total_amount() != 0:
		return false
	if not LogisticsConnectionGeometry.are_endpoints_aligned(belt.get_node_or_null("OutputEndpoint"), receiver, ConveyorSegment.CONNECTION_GAP):
		return false
	if belt.output_building_port == null and not belt.try_connect_building_port(receiver):
		return false
	receiver.enable_isolated_single_belt_route_guard = true
	if not receiver.has_verified_single_belt_route() and not receiver.bind_single_belt_route(belt):
		return false
	if not receiver.bind_unified_route_adapter():
		return false
	bound_belt = belt
	supply.route = weakref(belt)
	supply.receiver = weakref(receiver)
	_status = "Route bound. Real conveyor timer delivers automatically. Blueprint waits for power and worker."
	return true


func _prepare_marked_plan() -> void:
	for child: Node in get_parent().get_children():
		var candidate := child as ConstructionSite
		if _live(candidate) and candidate.global_transform.is_equal_approx(Transform3D(Basis.IDENTITY, SITE_POSITION)):
			if prepare_site(candidate):
				return
	_status = "Prepare refused: place the unapproved Storage plan at the cyan marker, with no preconnected belt."


func _bind_connected_belt() -> void:
	if not _live(supply) or not bind_player_belt(supply.connected_conveyor):
		_status = "Bind refused: authorize first, place one empty straight belt snapped to starter OUT toward plan."


func _unhandled_input(event: InputEvent) -> void:
	if not enable_isolated_playable_demo or not _started or not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_F7:
		if not prepare_site(world.call("_blueprint_site_under_mouse") as ConstructionSite):
			_status = "F7 refused: hover the unapproved Storage plan at cyan marker; no preconnected belt."
		get_viewport().set_input_as_handled()
	elif event.physical_keycode == KEY_F8:
		_bind_connected_belt()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not _started or not is_instance_valid(_label):
		return
	var stock: int = supply.inventory.get_amount(INGOT) if _live(supply) else 0
	var delivered: int = staging.get_staged_inventory().get_amount(INGOT) if _live(staging) else 0
	var in_transit: int = 0
	if _live(bound_belt):
		var cargo := bound_belt.get_node_or_null("ConveyorTransportComponent") as ConveyorTransportComponent
		if _live(cargo):
			in_transit = cargo.cargo_inventory.get_amount(INGOT)
	_label.text = "CONSTRUCTION LOGISTICS DEMO — Prepare / E authorize / Bind\n%s\nStarter: %d | Belt: %d | Staged: %d / 3\nNo worker or power supplied. Cancel with X; no automatic completion." % [_status, stock, in_transit, delivered]
