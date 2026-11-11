extends CanvasLayer

# =============================================================================
# FACTORY TESTING SANDBOX — BLUEPRINT CONSTRUCTION SUMMARY
# =============================================================================
# Visual-only counter. Does not authorize, progress or cancel jobs.

var _summary: Label = null


func _ready() -> void:
	# Explicit bounds are necessary for a programmatically created Control.
	# Without right/bottom offsets, it may render as a collapsed rectangle.
	layer = 5
	var panel := PanelContainer.new()
	panel.name = "BlueprintSummaryPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 16.0
	panel.offset_top = 16.0
	panel.offset_right = 392.0
	panel.offset_bottom = 211.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var margin := MarginContainer.new()
	margin.name = "SummaryMargin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	_summary = Label.new()
	_summary.name = "BlueprintSummaryLabel"
	_summary.add_theme_font_size_override("font_size", 15)
	_summary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(_summary)
	_refresh()


func _process(_delta: float) -> void:
	_refresh()


func _refresh() -> void:
	if not is_instance_valid(_summary):
		return
	var counts := {"planned": 0, "queued": 0, "building": 0, "paused": 0}
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		var site := node as ConstructionSite
		if not is_instance_valid(site) or site.is_queued_for_deletion():
			continue
		if site.job == null:
			continue
		match site.job.state:
			ConstructionJob.State.PLANNED:
				counts["planned"] += 1
			ConstructionJob.State.QUEUED:
				counts["queued"] += 1
			ConstructionJob.State.CONSTRUCTING:
				counts["building"] += 1
			ConstructionJob.State.PAUSED:
				counts["paused"] += 1
	var selected_count: int = 0
	var selected_high: int = 0
	var selected_normal: int = 0
	var selected_low: int = 0
	for member: Node in get_tree().get_nodes_in_group("blueprint_area_selected"):
		if not member is ConstructionSite:
			continue
		var chosen: ConstructionSite = member as ConstructionSite
		if (
			is_instance_valid(chosen) and not chosen.is_queued_for_deletion()
			and chosen.job != null
			and chosen.job.state == ConstructionJob.State.PLANNED
		):
			selected_count += 1
			match chosen.job.priority:
				ConstructionJob.Priority.HIGH:
					selected_high += 1
				ConstructionJob.Priority.NORMAL:
					selected_normal += 1
				ConstructionJob.Priority.LOW:
					selected_low += 1
	var selection_active: bool = false
	var controller: Node = get_parent().get_node_or_null("WorldInteraction")
	if is_instance_valid(controller):
		selection_active = bool(controller.get("_blueprint_area_selection_mode"))
	var hint: String = "E: Build Selected" if selection_active else "Q: Area Select"
	var extra_hint: String = (
		"\nShift+Drag: Add | Alt+Drag: Remove"
		if selection_active else ""
	)
	var priority_lines: String = ""
	if (
		is_instance_valid(controller)
		and bool(controller.get("enable_blueprint_construction_priorities"))
	):
		var waiting: int = 0
		var next_label: String = "None"
		var queue: BlueprintConstructionPriorityQueue = (
			controller.get_node_or_null("BlueprintConstructionPriorityQueue")
			as BlueprintConstructionPriorityQueue
		)
		if is_instance_valid(queue):
			waiting = queue.get_waiting_count()
			var next: ConstructionSite = queue.peek_next()
			if is_instance_valid(next) and is_instance_valid(next.target_definition):
				next_label = (
					ConstructionJob.priority_name(int(next.job.priority))
					+ ": " + next.target_definition.display_name
				)
		priority_lines = (
			"\nSelected priority: H %d | N %d | L %d" %
			[selected_high, selected_normal, selected_low]
			+ "\nWaiting queue: %d | Next: %s" % [waiting, next_label]
		)
		if selection_active:
			priority_lines += "\nH: High  |  N: Normal  |  L: Low"
	_summary.text = (
		"FACTORY BLUEPRINTS\n"
		+ "Planned: %d   Queued: %d\n" % [counts["planned"], counts["queued"]]
		+ "Building: %d   Paused: %d\n" % [counts["building"], counts["paused"]]
		+ "Selected: %d   |   %s" % [selected_count, hint]
		+ extra_hint
		+ priority_lines
	)
