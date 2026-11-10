extends CanvasLayer

# =============================================================================
# FACTORY TESTING SANDBOX — BLUEPRINT CONSTRUCTION SUMMARY
# =============================================================================
# Visual-only counter. Does not authorize, progress or cancel jobs.

var _summary: Label = null


func _ready() -> void:
	var panel := PanelContainer.new()
	panel.name = "BlueprintSummaryPanel"
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.offset_left = 12.0
	panel.offset_top = 12.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	_summary = Label.new()
	_summary.name = "BlueprintSummaryLabel"
	_summary.add_theme_font_size_override("font_size", 15)
	_summary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_summary)
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
	_summary.text = (
		"FACTORY BLUEPRINTS\n"
		+ "Planned: %d   Queued: %d\n" % [counts["planned"], counts["queued"]]
		+ "Building: %d   Paused: %d" % [counts["building"], counts["paused"]]
	)
