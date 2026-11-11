extends CanvasLayer
class_name BlueprintConstructionRequirementsPanel

# =============================================================================
# E3D5C3D2A — CLICKABLE, READ-ONLY CONSTRUCTION REQUIREMENTS PANEL
# =============================================================================
# ISOLATED scene-only foundation. Does not touch WorldInteraction or the
# Factory Testing Sandbox. The toggle button only shows/hides information.
# No job authorization, escrow, power, scheduler, inventory, or timer writes.
# Unknown providers remain UNKNOWN; debug bypass is never presented as real
# construction readiness. Future sandbox integration may attach this layer.

@export var follow_area_selection: bool = true

var _target_ref: WeakRef = null
var _stock_ref: WeakRef = null
var _escrow_ref: WeakRef = null
var _power_ref: WeakRef = null
var _scheduler_ref: WeakRef = null
var _toggle: Button = null
var _panel: PanelContainer = null
var _report: Label = null
var _opened: bool = false
var _last_snapshot: Dictionary = {}


func _ready() -> void:
	layer = 8
	var root := Control.new()
	root.name = "RequirementsCanvas"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_toggle = Button.new()
	_toggle.name = "ToggleRequirements"
	_toggle.text = "Construction Requirements"
	_toggle.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_toggle)
	_toggle.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toggle.offset_left = -320.0
	_toggle.offset_right = -16.0
	_toggle.offset_top = 16.0
	_toggle.offset_bottom = 54.0
	_toggle.pressed.connect(toggle_open)

	_panel = PanelContainer.new()
	_panel.name = "RequirementsPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_panel)
	_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_panel.offset_left = -400.0
	_panel.offset_right = -16.0
	_panel.offset_top = 62.0
	_panel.offset_bottom = 440.0

	var margin := MarginContainer.new()
	margin.name = "RequirementsMargin"
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.name = "RequirementsScroll"
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	_report = Label.new()
	_report.name = "RequirementsText"
	_report.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_report.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_report.add_theme_font_size_override("font_size", 14)
	_report.custom_minimum_size.x = 345.0
	scroll.add_child(_report)

	set_open(false)
	refresh_now()


# Only refresh visible UI; reading a snapshot never advances gameplay.
func _process(_delta: float) -> void:
	if _opened:
		refresh_now()


func set_target(site: ConstructionSite) -> void:
	_target_ref = weakref(site) if is_instance_valid(site) else null
	refresh_now()


func set_providers(
	stock: InventoryComponent = null,
	escrow: BlueprintConstructionMaterialEscrow = null,
	power: PrototypeConstructionPowerAllocator = null,
	scheduler: BlueprintConstructionSlotScheduler = null
) -> void:
	_stock_ref = weakref(stock) if is_instance_valid(stock) else null
	_escrow_ref = weakref(escrow) if is_instance_valid(escrow) else null
	_power_ref = weakref(power) if is_instance_valid(power) else null
	_scheduler_ref = weakref(scheduler) if is_instance_valid(scheduler) else null
	refresh_now()


func toggle_open() -> void:
	set_open(not _opened)


func set_open(value: bool) -> void:
	_opened = value
	if is_instance_valid(_panel):
		_panel.visible = _opened
	if is_instance_valid(_toggle):
		_toggle.text = (
			"Close Construction Requirements"
			if _opened else "Construction Requirements"
		)
	if _opened:
		refresh_now()


func is_open() -> bool:
	return _opened


func get_toggle_button() -> Button:
	return _toggle


func get_display_text() -> String:
	return _report.text if is_instance_valid(_report) else ""


func get_last_snapshot() -> Dictionary:
	return _last_snapshot.duplicate(true)


func refresh_now() -> Dictionary:
	var selected: ConstructionSite = _get_target()
	var stock: InventoryComponent = (
		_stock_ref.get_ref() as InventoryComponent
		if _stock_ref != null else null
	)
	var escrow: BlueprintConstructionMaterialEscrow = (
		_escrow_ref.get_ref() as BlueprintConstructionMaterialEscrow
		if _escrow_ref != null else null
	)
	var power: PrototypeConstructionPowerAllocator = (
		_power_ref.get_ref() as PrototypeConstructionPowerAllocator
		if _power_ref != null else null
	)
	var scheduler: BlueprintConstructionSlotScheduler = (
		_scheduler_ref.get_ref() as BlueprintConstructionSlotScheduler
		if _scheduler_ref != null else null
	)
	_last_snapshot = BlueprintConstructionRequirementsInspector.inspect(
		selected, stock, escrow, power, scheduler
	)
	if is_instance_valid(_report):
		_report.text = _format_report(_last_snapshot)
	return get_last_snapshot()


func _get_target() -> ConstructionSite:
	if _target_ref != null:
		var selected: ConstructionSite = (
			_target_ref.get_ref() as ConstructionSite
		)
		if is_instance_valid(selected) and not selected.is_queued_for_deletion():
			return selected
		return null
	if not follow_area_selection:
		return null
	# Follow the existing blueprint drag-selection group without changing it.
	for candidate: Node in get_tree().get_nodes_in_group("blueprint_area_selected"):
		if candidate is ConstructionSite:
			var site: ConstructionSite = candidate as ConstructionSite
			if is_instance_valid(site) and not site.is_queued_for_deletion():
				return site
	return null


func _format_report(snapshot: Dictionary) -> String:
	var lines: Array[String] = [
		"CONSTRUCTION REQUIREMENTS",
		"Read-only prototype inspection",
		""
	]
	if not bool(snapshot.get("site_valid", false)):
		lines.append("Blueprint: No selected site")
		lines.append("In sandbox: Q, then drag to select a plan.")
		lines.append("No inventory or power is assumed.")
		lines.append("")
		lines.append("Live readiness: NOT VERIFIED")
		return "\n".join(lines)

	lines.append("Building: %s" % str(snapshot["building_name"]))
	lines.append("State: %s" % _state_name(int(snapshot["state"])))
	lines.append("Priority: %s" % str(snapshot["priority"]))
	lines.append("Progress: %d%%" % int(round(
		clampf(float(snapshot["progress"]), 0.0, 1.0) * 100.0
	)))
	lines.append("")
	lines.append("MATERIAL BILL")
	if not bool(snapshot["bill_valid"]):
		lines.append("Invalid or missing - cannot authorize supply")
	else:
		var item_lines: Array[String] = []
		var bill: Dictionary = snapshot["required_materials"]
		for key: Variant in bill.keys():
			var item: ItemDefinition = key as ItemDefinition
			if is_instance_valid(item):
				item_lines.append(
					"%s x%d" % [item.display_name, int(bill[key])]
				)
		item_lines.sort()
		for item_line: String in item_lines:
			lines.append(item_line)

	if not bool(snapshot["stock_known"]):
		lines.append("Stock: UNKNOWN (no inventory connected)")
	elif bool(snapshot["stock_sufficient"]):
		lines.append("Stock: Enough on hand (not reserved)")
	else:
		lines.append("Stock: INSUFFICIENT")
		var shortage_lines: Array[String] = []
		var missing: Dictionary = snapshot["missing_materials"]
		for key: Variant in missing.keys():
			var item: ItemDefinition = key as ItemDefinition
			if is_instance_valid(item):
				shortage_lines.append(
					"  Missing %s x%d" % [item.display_name, int(missing[key])]
				)
		shortage_lines.sort()
		for line: String in shortage_lines:
			lines.append(line)

	lines.append(
		"Reserved: %s" % _status(
			bool(snapshot["escrow_known"]),
			bool(snapshot["materials_reserved"])
		)
	)
	lines.append(
		"Power: %s" % _status(
			bool(snapshot["power_known"]),
			bool(snapshot["prototype_power_allocated"])
		)
	)
	lines.append(
		"Worker: %s" % _status(
			bool(snapshot["worker_known"]),
			bool(snapshot["worker_active"])
		)
	)
	lines.append("")
	lines.append("Live readiness: NOT VERIFIED")
	lines.append("Prototype power != delivered electricity.")
	lines.append("Sandbox debug builds may bypass gates.")
	return "\n".join(lines)


func _status(known: bool, granted: bool) -> String:
	if not known:
		return "UNKNOWN (service not connected)"
	return "YES (prototype only)" if granted else "NO / waiting"


func _state_name(state: int) -> String:
	match state:
		ConstructionJob.State.PLANNED:
			return "Planned"
		ConstructionJob.State.QUEUED:
			return "Queued"
		ConstructionJob.State.CONSTRUCTING:
			return "Constructing"
		ConstructionJob.State.PAUSED:
			return "Paused"
		ConstructionJob.State.COMPLETE:
			return "Complete"
		ConstructionJob.State.CANCELLED:
			return "Cancelled"
		_:
			return "Unknown"
