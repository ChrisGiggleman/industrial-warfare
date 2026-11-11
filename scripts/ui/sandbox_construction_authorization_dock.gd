extends CanvasLayer
class_name SandboxConstructionAuthorizationDock

# =============================================================================
# SANDBOX-ONLY EXPLICIT BLUEPRINT AUTHORIZATION DOCK
# =============================================================================
# Uses WorldInteraction's existing guarded E / Ctrl+E commands. Never
# calls ConstructionJob.authorize() directly or changes readiness, escrow,
# electrical allocation, worker capacity, or construction timers.
# Main is not opted in. Real construction readiness remains NOT VERIFIED.

@export var enable_authorization_controls: bool = false

const HOTBAR_GAP: float = 8.0
const SCREEN_MARGIN: float = 4.0

var _sandbox: Node = null
var _controller: Node = null
var _hotbar: Control = null
var _build_hud: Node = null
var _controls: BlueprintConstructionAuthorizationButtons = null
var _confirm_all: bool = false
var _pending_all_ids: Array[int] = []


func _ready() -> void:
	if not enable_authorization_controls:
		return
	_sandbox = get_parent()
	if not is_instance_valid(_sandbox):
		return
	_controller = _sandbox.get_node_or_null("WorldInteraction")
	_hotbar = _sandbox.get_node_or_null("BuildHUD/VisualHotbar") as Control
	_build_hud = _sandbox.get_node_or_null("BuildHUD")
	# Require the dedicated sandbox-only priority/blueprint UI host, too.
	if (
		not is_instance_valid(_controller)
		or not is_instance_valid(_hotbar)
		or not is_instance_valid(_build_hud)
		or _sandbox.get_node_or_null("ConstructionPriorityDock") == null
		or _sandbox.get_node_or_null("BlueprintConstructionSummary") == null
	):
		return
	if not bool(_controller.get("enable_blueprint_planning")):
		return
	layer = 2
	_controls = BlueprintConstructionAuthorizationButtons.new()
	_controls.name = "BlueprintAuthorizationButtons"
	_controls.selected_requested.connect(_on_selected_requested)
	_controls.all_requested.connect(_on_all_requested)
	add_child(_controls)
	_update_dock()


func _process(_delta: float) -> void:
	_update_dock()


func get_controls() -> BlueprintConstructionAuthorizationButtons:
	if is_instance_valid(_controls):
		return _controls
	return null


func is_all_confirmation_pending() -> bool:
	return _confirm_all


func _can_authorize() -> bool:
	if (
		not is_instance_valid(_controller)
		or not is_instance_valid(_hotbar)
		or not is_instance_valid(_build_hud)
	):
		return false
	if _build_hud.has_method("is_catalog_open"):
		if bool(_build_hud.call("is_catalog_open")):
			return false
	return (
		_hotbar.visible
		and bool(_controller.get("enable_blueprint_planning"))
		and bool(_controller.get("placement_mode_active"))
		and bool(_controller.get("blueprint_mode_active"))
		and not bool(_controller.get("demolition_mode_active"))
	)


func _valid_plan(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and site.get_parent() == _sandbox
		and site.job != null
		and site.job.state == ConstructionJob.State.PLANNED
		and is_instance_valid(site.target_definition)
		and bool(_controller.call("_is_managed_blueprint", site))
	)


func _selected_plans() -> Array[ConstructionSite]:
	var found: Array[ConstructionSite] = []
	if not _can_authorize():
		return found
	if not (
		bool(_controller.get("enable_blueprint_area_selection"))
		and bool(_controller.get("_blueprint_area_selection_mode"))
	):
		return found
	var selected: Array = _controller.get("_area_selected_sites")
	for candidate: Variant in selected:
		var site: ConstructionSite = candidate as ConstructionSite
		if _valid_plan(site) and site.is_in_group("blueprint_area_selected"):
			if not found.has(site):
				found.append(site)
	return found


func _all_plans() -> Array[ConstructionSite]:
	var found: Array[ConstructionSite] = []
	if not _can_authorize():
		return found
	for member: Node in get_tree().get_nodes_in_group("construction_sites"):
		if not member is ConstructionSite:
			continue
		var site := member as ConstructionSite
		if _valid_plan(site):
			found.append(site)
	return found


func _all_plan_ids() -> Array[int]:
	var ids: Array[int] = []
	for site: ConstructionSite in _all_plans():
		ids.append(site.get_instance_id())
	ids.sort()
	return ids


func _clear_all_confirmation() -> void:
	_confirm_all = false
	_pending_all_ids.clear()


func _update_dock() -> void:
	if not is_instance_valid(_controls):
		return
	var visible_now: bool = _can_authorize()
	_controls.visible = visible_now
	if not visible_now:
		_clear_all_confirmation()
		_controls.set_available_counts(0, 0)
		return

	var selected_count: int = _selected_plans().size()
	var ids: Array[int] = _all_plan_ids()
	if _confirm_all and ids != _pending_all_ids:
		_clear_all_confirmation()
	_controls.set_available_counts(selected_count, ids.size())
	_controls.set_all_confirmation_pending(_confirm_all)

	var bounds: Rect2 = _hotbar.get_global_rect()
	var size: Vector2 = _controls.get_combined_minimum_size()
	_controls.position = Vector2(
		maxf(SCREEN_MARGIN, bounds.get_center().x - size.x * 0.5),
		maxf(SCREEN_MARGIN, bounds.position.y - size.y - HOTBAR_GAP)
	)


func _on_selected_requested() -> void:
	# Signals can be emitted programmatically: always re-check world state.
	_update_dock()
	if not _can_authorize() or _selected_plans().is_empty():
		return
	var count: int = int(_controller.call("_authorize_selected_blueprint_sites"))
	_clear_all_confirmation()
	_update_dock()
	if count > 0:
		print("SANDBOX AUTHORIZATION: ", count, " selected blueprints authorized")


func _on_all_requested() -> void:
	_update_dock()
	if not _can_authorize():
		return
	var ids: Array[int] = _all_plan_ids()
	if ids.is_empty():
		return
	if not _confirm_all:
		_pending_all_ids = ids.duplicate()
		_confirm_all = true
		_update_dock()
		print("SANDBOX AUTHORIZATION: Confirm All to authorize ", ids.size(), " plans")
		return
	if ids != _pending_all_ids:
		_clear_all_confirmation()
		_update_dock()
		return
	var count: int = int(_controller.call("_authorize_all_blueprint_sites"))
	if count > 0:
		# Match Ctrl+E's existing behavior: release Q-area highlights.
		_controller.call("_clear_blueprint_area_selection")
	_clear_all_confirmation()
	_update_dock()
	if count > 0:
		print("SANDBOX AUTHORIZATION: ", count, " blueprints authorized by All")
