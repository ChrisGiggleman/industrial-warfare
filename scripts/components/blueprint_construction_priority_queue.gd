extends Node
class_name BlueprintConstructionPriorityQueue

# =============================================================================
# E3D5 — PRIORITY-ORDERED WAITING CONSTRUCTION JOBS
# =============================================================================
# Bookkeeping ONLY. Never calls authorize(), set_availability(), advance(),
# cancel(), or assigns worker drones. Queued jobs keep their original gates
# and construction timers. Future workers can request this ordered snapshot.

var _entries: Array[Dictionary] = []
var _next_order: int = 0


func register_queued_site(site: ConstructionSite) -> bool:
	if not _is_queued(site):
		return false
	_prune_entries()
	for entry: Dictionary in _entries:
		var existing: ConstructionSite = (
			(entry["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		if existing == site:
			return false
	_entries.append({
		"ref": weakref(site),
		"order": _next_order
	})
	_next_order += 1
	return true


func get_waiting_sites() -> Array[ConstructionSite]:
	_prune_entries()
	var ordered: Array[Dictionary] = _entries.duplicate()
	ordered.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var a: ConstructionSite = (
			(left["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		var b: ConstructionSite = (
			(right["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		var a_priority: int = int(a.job.priority)
		var b_priority: int = int(b.job.priority)
		if a_priority != b_priority:
			return a_priority < b_priority
		return int(left["order"]) < int(right["order"])
	)
	var result: Array[ConstructionSite] = []
	for entry: Dictionary in ordered:
		var site: ConstructionSite = (
			(entry["ref"] as WeakRef).get_ref() as ConstructionSite
		)
		result.append(site)
	return result


func peek_next() -> ConstructionSite:
	var waiting: Array[ConstructionSite] = get_waiting_sites()
	if waiting.is_empty():
		return null
	return waiting[0]


func get_waiting_count() -> int:
	return get_waiting_sites().size()


func get_waiting_counts_by_priority() -> Dictionary:
	var counts := {
		"high": 0,
		"normal": 0,
		"low": 0
	}
	for site: ConstructionSite in get_waiting_sites():
		match site.job.priority:
			ConstructionJob.Priority.HIGH:
				counts["high"] += 1
			ConstructionJob.Priority.NORMAL:
				counts["normal"] += 1
			ConstructionJob.Priority.LOW:
				counts["low"] += 1
	return counts


func _is_queued(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.is_inside_tree()
		and site.job != null
		and site.job.state == ConstructionJob.State.QUEUED
	)


func _prune_entries() -> void:
	var alive: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		var reference: WeakRef = entry["ref"] as WeakRef
		var site: ConstructionSite = reference.get_ref() as ConstructionSite
		if _is_queued(site):
			alive.append(entry)
	_entries = alive
