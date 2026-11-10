extends RefCounted
class_name PlannedBuildingPortGeometry

# =============================================================================
# BLUEPRINT BUILDING-PORT CONNECTIONS — READ-ONLY GEOMETRY
# =============================================================================
# E3a: inspect a conveyor blueprint against one unfinished building port.
# No reservations, cargo, physical ItemPortComponent links or job mutation.
# input_side refers to the building: true = belt -> building,
# false = building -> belt. Both sites must still be non-operational.

static func inspect_pair(
	building_site: ConstructionSite,
	belt_site: ConstructionSite,
	input_side: bool,
	port_name: StringName = &""
) -> Dictionary:
	if not _is_available_site(building_site):
		return {}
	if not _is_available_site(belt_site):
		return {}
	if building_site == belt_site:
		return {}
	if not _is_belt(belt_site) or _is_belt(building_site):
		return {}

	if port_name == &"":
		port_name = &"InputPort" if input_side else &"OutputPort"
	if not str(port_name).begins_with("InputPort" if input_side else "OutputPort"):
		return {}
	var building_marker := building_site.get_planned_port_named(port_name)
	var belt_marker := belt_site.get_node_or_null(
		"PlannedOutputEndpoint" if input_side else "PlannedInputEndpoint"
	) as Marker3D
	if not is_instance_valid(building_marker):
		return {}
	if not is_instance_valid(belt_marker):
		return {}

	var outgoing: Marker3D = (
		belt_marker if input_side else building_marker
	)
	var incoming: Marker3D = (
		building_marker if input_side else belt_marker
	)
	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		outgoing, incoming, ConveyorSegment.CONNECTION_GAP
	):
		return {}

	return {
		"building_site": building_site,
		"belt_site": belt_site,
		"input_side": input_side,
		"port_name": port_name,
		"building_marker": building_marker,
		"belt_marker": belt_marker,
		"junction": building_marker.global_position
	}


static func _is_available_site(site: ConstructionSite) -> bool:
	if not is_instance_valid(site):
		return false
	if not site.is_inside_tree() or site.is_queued_for_deletion():
		return false
	if site.job == null or not site.accepts_planned_connections():
		return false
	if not is_instance_valid(site.target_definition):
		return false
	return true


static func _is_belt(site: ConstructionSite) -> bool:
	return (
		is_instance_valid(site)
		and is_instance_valid(site.target_definition)
		and site.target_definition.building_id == &"conveyor_belt"
		and site.target_definition.building_scene
			== ConveyorPieceSelector.STRAIGHT_SCENE
	)
