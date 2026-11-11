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


# Keep the clickable panel below the LIVE Production Debug HUD as its
# selected-object text grows and shrinks. This affects UI layout only.
func _process(_delta: float) -> void:
	if not is_instance_valid(_panel):
		return
	var sandbox: Node = get_parent()
	if not is_instance_valid(sandbox):
		return
	var debug_panel: Control = (
		sandbox.get_node_or_null("ProductionDebugHUD/InfoPanel") as Control
	)
	if is_instance_valid(debug_panel):
		_panel.dock_after_production_debug(debug_panel)


func get_panel() -> BlueprintConstructionRequirementsPanel:
	if not is_instance_valid(_panel):
		return null
	return _panel
