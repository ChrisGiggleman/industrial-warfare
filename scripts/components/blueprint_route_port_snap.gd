extends RefCounted
class_name BlueprintRoutePortSnap

# =============================================================================
# BLUEPRINT ROUTE START/END — READ-ONLY BUILDING PORT TARGETS
# =============================================================================
# Works with planned and completed factory buildings. Route direction is
# validated by the caller against the final generated tile transform.
# This helper does not create sites, claims, connections, or cargo.

static func find_nearest(
	preview: ConveyorSegment,
	mouse_world: Vector3,
	port_registry: PlannedBuildingPortReservations,
	building_input: bool,
	search_radius: float = 0.85
) -> Dictionary:
	if not is_instance_valid(preview) or not preview.is_inside_tree():
		return {}
	if preview.is_queued_for_deletion() or search_radius <= 0.0:
		return {}

	var best: Dictionary = {}
	var best_distance_sq: float = search_radius * search_radius

	# A blueprint building offers a named future port whose claims are
	# owned by the pre-existing shared endpoint broker.
	if is_instance_valid(port_registry):
		var planned: Dictionary = BlueprintStoragePortSnapPreview.find_nearest(
			preview, mouse_world, port_registry,
			search_radius, true, 1 if building_input else 0
		)
		if not planned.is_empty():
			best = planned.duplicate()
			best["kind"] = "planned"
			best_distance_sq = float(best["distance_squared"])

	# Completed ports need a separate deferred physical connection when
	# the new blueprint belt finishes. Never snap to occupied live ports.
	var wanted: int = (
		ItemPortComponent.PortDirection.INPUT if building_input
		else ItemPortComponent.PortDirection.OUTPUT
	)
	for candidate: Node in preview.get_tree().get_nodes_in_group("player_built"):
		if not candidate is Node3D:
			continue
		if candidate.is_queued_for_deletion():
			continue
		if candidate.is_in_group("construction_preview"):
			continue
		if candidate is ConveyorSegment:
			continue
		for child: Node in candidate.get_children():
			if not child is ItemPortComponent:
				continue
			var port := child as ItemPortComponent
			if port.direction != wanted or not is_instance_valid(port.inventory):
				continue
			if is_instance_valid(port.connected_conveyor):
				continue
			var proposed: Dictionary = ConveyorBuildingSnap.get_preview_transform(
				port, preview
			)
			if not proposed.has("transform"):
				continue
			var transform: Transform3D = proposed["transform"]
			if not FactoryGrid.is_on_conveyor_grid(transform.origin):
				continue
			var delta := Vector2(
				mouse_world.x - transform.origin.x,
				mouse_world.z - transform.origin.z
			)
			var distance_sq: float = delta.length_squared()
			if distance_sq >= best_distance_sq:
				continue
			best_distance_sq = distance_sq
			best = {
				"kind": "live",
				"port": port,
				"input_side": building_input,
				"transform": transform,
				"distance_squared": distance_sq
			}
	return best


static func matches_route_end(
	route_tile: Transform3D, port_candidate: Dictionary
) -> bool:
	if port_candidate.is_empty():
		return true
	if not port_candidate.has("transform"):
		return false
	var offered: Transform3D = port_candidate["transform"]
	return (
		route_tile.origin.is_equal_approx(offered.origin)
		and route_tile.basis.is_equal_approx(offered.basis)
	)


static func has_pending_live_claim(
	tree: SceneTree, port: ItemPortComponent
) -> bool:
	if not is_instance_valid(port) or tree == null:
		return true
	var port_id: int = port.get_instance_id()
	for node: Node in tree.get_nodes_in_group("construction_sites"):
		if not node is ConstructionSite:
			continue
		var site := node as ConstructionSite
		if site.is_queued_for_deletion():
			continue
		if site.job == null:
			continue
		if int(site.get_meta("route_live_port_id", -1)) == port_id:
			return true
	return false
