extends CanvasLayer
class_name SandboxConstructionPriorityDock

# =============================================================================
# E3D5C3E1B — SANDBOX-ONLY COMPACT PRIORITY DOCK BESIDE BUILD HOTBAR
# =============================================================================
# This adapter owns the UI location and calls only the EXISTING validated
# selected-blueprint priority command. The button view never edits jobs.
# No construction authorization, material transfer, power, workers or time.

@export var enable_priority_controls: bool = false

const HOTBAR_GAP := 8.0
const SCREEN_MARGIN := 4.0

var _controller: Node = null
var _hotbar: Control = null
var _controls: BlueprintConstructionPriorityButtons = null


func _ready() -> void:
	if not enable_priority_controls:
		return
	var sandbox: Node = get_parent()
	if not is_instance_valid(sandbox):
		return
	_controller = sandbox.get_node_or_null("WorldInteraction")
	_hotbar = sandbox.get_node_or_null("BuildHUD/VisualHotbar") as Control
	if not is_instance_valid(_controller) or not is_instance_valid(_hotbar):
		return
	if not bool(_controller.get("enable_blueprint_construction_priorities")):
		return
	# The sandbox HUD is layer 1. Keep these buttons above the hotbar,
	# while full-screen overlays (e.g. the build catalog) retain priority.
	layer = 2
	_controls = BlueprintConstructionPriorityButtons.new()
	_controls.name = "CompactPriorityButtons"
	_controls.priority_requested.connect(_on_priority_requested)
	add_child(_controls)
	_update_dock()


func _process(_delta: float) -> void:
	_update_dock()


func get_controls() -> BlueprintConstructionPriorityButtons:
	if is_instance_valid(_controls):
		return _controls
	return null


func _eligible_selection_count() -> int:
	if not is_instance_valid(_controller):
		return 0
	if not (
		bool(_controller.get("enable_blueprint_construction_priorities"))
		and bool(_controller.get("enable_blueprint_area_selection"))
		and bool(_controller.get("_blueprint_area_selection_mode"))
		and bool(_controller.get("placement_mode_active"))
		and bool(_controller.get("blueprint_mode_active"))
		and not bool(_controller.get("demolition_mode_active"))
	):
		return 0
	var chosen: Array = _controller.get("_area_selected_sites")
	var count := 0
	for candidate: Variant in chosen:
		var site: ConstructionSite = candidate as ConstructionSite
		if (
			not is_instance_valid(site)
			or site.is_queued_for_deletion()
			or not site.is_inside_tree()
			or site.job == null
			or site.job.state != ConstructionJob.State.PLANNED
			or not site.is_in_group("blueprint_area_selected")
		):
			continue
		count += 1
	return count


func _update_dock() -> void:
	if (
		not is_instance_valid(_controls)
		or not is_instance_valid(_controller)
		or not is_instance_valid(_hotbar)
	):
		return
	_controls.visible = (
		_hotbar.visible
		and bool(_controller.get("placement_mode_active"))
		and bool(_controller.get("blueprint_mode_active"))
		and not bool(_controller.get("demolition_mode_active"))
	)
	_controls.set_selection_available(
		_controls.visible and _eligible_selection_count() > 0
	)
	if not _controls.visible:
		return
	var bar_bounds: Rect2 = _hotbar.get_global_rect()
	var buttons_size: Vector2 = _controls.get_combined_minimum_size()
	_controls.position = Vector2(
		maxf(SCREEN_MARGIN, bar_bounds.position.x - buttons_size.x - HOTBAR_GAP),
		bar_bounds.get_center().y - buttons_size.y * 0.5
	)


func _on_priority_requested(priority: int) -> void:
	# Treat programmatic signal injections like mouse clicks: fail closed.
	if not is_instance_valid(_controls):
		return
	if not _controls.is_selection_available():
		return
	if _eligible_selection_count() == 0:
		return
	if priority not in [
		ConstructionJob.Priority.HIGH,
		ConstructionJob.Priority.NORMAL,
		ConstructionJob.Priority.LOW
	]:
		return
	# WorldInteraction retains its original Q-mode and PLANNED-only guards.
	_controller.call("_set_selected_blueprint_priority", priority)
	_update_dock()
