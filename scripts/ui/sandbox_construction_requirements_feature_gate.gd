extends Node
class_name SandboxConstructionRequirementsFeatureGate

# =============================================================================
# E3D5C3D2B — FACTORY TESTING SANDBOX READ-ONLY PANEL GATE
# =============================================================================
# This component's SCRIPT default is OFF, but Factory Testing Sandbox
# explicitly enables the read-only UI in its scene. Other instances remain
# off unless opted in. Does not change WorldInteraction, authorization,
# debug construction bypass, materials, power, worker slots, cargo or combat.
#
# When enabled, it attaches only the existing read-only RequirementsPanel
# and follows the existing blueprint_area_selected group. No fake providers
# are installed; unavailable services correctly show UNKNOWN.
# Live readiness remains NOT VERIFIED.

@export var enable_read_only_requirements_panel: bool = false

var _panel: BlueprintConstructionRequirementsPanel = null
var _was_area_selecting: bool = false


func _ready() -> void:
	if not enable_read_only_requirements_panel:
		return
	var sandbox: Node = get_parent()
	if not is_instance_valid(sandbox):
		return
	# An explicit host check prevents accidental activation in an
	# unrelated game scene with the gate toggled on.
	if (
		sandbox.get_node_or_null("WorldInteraction") == null
		or sandbox.get_node_or_null("BlueprintConstructionSummary") == null
	):
		return
	if is_instance_valid(_panel):
		return

	_panel = BlueprintConstructionRequirementsPanel.new()
	_panel.name = "ReadOnlyConstructionRequirements"
	_panel.follow_area_selection = true
	add_child(_panel)
	# The world controller owns all click/raycast decisions. Only this
	# sandbox UI listens and opens an informational target. Area selection
	# remains independent and can still be used for group operations.
	var controller: Node = sandbox.get_node("WorldInteraction")
	if controller.has_signal("blueprint_inspection_requested"):
		controller.connect(
			"blueprint_inspection_requested",
			Callable(self, "_on_blueprint_inspection_requested")
		)


func _on_blueprint_inspection_requested(site: ConstructionSite) -> void:
	if not is_instance_valid(_panel) or not is_instance_valid(site):
		return
	if site.is_queued_for_deletion():
		return
	_panel.set_target(site)
	_panel.set_open(true)


# Keep the clickable panel below the LIVE Production Debug HUD as its
# selected-object text grows and shrinks. This affects UI layout only.
func _process(_delta: float) -> void:
	if not is_instance_valid(_panel):
		return
	var sandbox: Node = get_parent()
	if not is_instance_valid(sandbox):
		return
	# Starting Q-area selection releases any single-click pinned target,
	# so its multi-selection can drive the same read-only panel.
	var controller: Node = sandbox.get_node_or_null("WorldInteraction")
	if is_instance_valid(controller):
		var selecting: bool = bool(
			controller.get("_blueprint_area_selection_mode")
		)
		if selecting and not _was_area_selecting:
			_panel.set_target(null)
		_was_area_selecting = selecting
	var debug_panel: Control = (
		sandbox.get_node_or_null("ProductionDebugHUD/InfoPanel") as Control
	)
	if is_instance_valid(debug_panel):
		_panel.dock_after_production_debug(debug_panel)


func get_panel() -> BlueprintConstructionRequirementsPanel:
	if not is_instance_valid(_panel):
		return null
	return _panel
