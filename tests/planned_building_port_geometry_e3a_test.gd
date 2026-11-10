extends Node3D

# =============================================================================
# PLANNED BUILDING-PORT CONNECTION GEOMETRY — E3A REGRESSION
# =============================================================================
# Only matches the future conveyor/building port geometry. No site is
# authorized, reserved, linked or given transport inventory by discovery.

func _site(
	container: Node3D,
	definition: BuildingDefinition,
	at: Vector3,
	yaw: float = 0.0
) -> ConstructionSite:
	var site := ConstructionSite.new()
	assert(site.setup_with_definition_job(definition))
	container.add_child(site)
	site.set_process(false)
	site.position = at
	site.rotation_degrees.y = yaw
	return site


func _ready() -> void:
	var storage_def := load(
		"res://data/buildings/test_storage.tres"
	) as BuildingDefinition
	var conveyor_def := load(
		"res://data/buildings/conveyor_belt.tres"
	) as BuildingDefinition
	assert(storage_def != null and conveyor_def != null)
	var container := Node3D.new()
	add_child(container)

	var storage := _site(container, storage_def, Vector3.ZERO)
	var inbound := _site(container, conveyor_def, Vector3(0, 0, 2))
	var outbound := _site(container, conveyor_def, Vector3(0, 0, -2))
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	assert(storage.get_planned_port(true) is Marker3D)
	assert(storage.get_planned_port(false) is Marker3D)
	assert(inbound.get_node_or_null("PlannedOutputEndpoint") is Marker3D)
	assert(outbound.get_node_or_null("PlannedInputEndpoint") is Marker3D)
	print("PASS A: Planned Storage and belts expose geometry, not active ports")

	var input := PlannedBuildingPortGeometry.inspect_pair(
		storage, inbound, true
	)
	assert(input.get("building_site") == storage)
	assert(input.get("belt_site") == inbound)
	assert(input.get("input_side") == true)
	assert(input.get("building_marker") == storage.get_planned_port(true))
	print("PASS B: Incoming conveyor output aligns to unfinished Storage input")

	var output := PlannedBuildingPortGeometry.inspect_pair(
		storage, outbound, false
	)
	assert(output.get("building_site") == storage)
	assert(output.get("belt_site") == outbound)
	assert(output.get("input_side") == false)
	assert(output.get("building_marker") == storage.get_planned_port(false))
	print("PASS C: Unfinished Storage output aligns to outbound belt input")

	assert((input["junction"] as Vector3).is_equal_approx(
		storage.get_planned_port(true).global_position
	))
	assert((output["junction"] as Vector3).is_equal_approx(
		storage.get_planned_port(false).global_position
	))
	assert(not input["junction"].is_equal_approx(output["junction"]))
	print("PASS D: Input and output have separate exact world-space junctions")

	assert(storage.get_node_or_null("InventoryComponent") == null)
	assert(storage.get_node_or_null("InputPort") == null)
	assert(storage.get_node_or_null("OutputPort") == null)
	assert(inbound.get_node_or_null("CargoInventory") == null)
	assert(outbound.get_node_or_null("CargoInventory") == null)
	assert(inbound.get_node_or_null("ConveyorTransportTimer") == null)
	print("PASS E: Discovery does not activate inventory, ports or transport")

	assert(PlannedBuildingPortGeometry.inspect_pair(
		storage, inbound, false
	).is_empty())
	assert(PlannedBuildingPortGeometry.inspect_pair(
		storage, outbound, true
	).is_empty())
	print("PASS F: Swapped input and output directions are rejected")

	var rotated := _site(
		container, storage_def, Vector3(10, 0, 5), 90.0
	)
	var transform_basis := rotated.global_transform.basis
	var rotated_inbound := _site(
		container, conveyor_def,
		rotated.global_position + transform_basis * Vector3(0, 0, 2),
		90.0
	)
	assert(not PlannedBuildingPortGeometry.inspect_pair(
		rotated, rotated_inbound, true
	).is_empty())
	print("PASS G: Ninety-degree rotated Storage input remains connectable")

	var rotated_outbound := _site(
		container, conveyor_def,
		rotated.global_position + transform_basis * Vector3(0, 0, -2),
		90.0
	)
	assert(not PlannedBuildingPortGeometry.inspect_pair(
		rotated, rotated_outbound, false
	).is_empty())
	print("PASS H: Rotated Storage output has independently correct facing")

	var backwards := _site(
		container, conveyor_def, Vector3(20, 0, 2), 180.0
	)
	var backwards_storage := _site(
		container, storage_def, Vector3(20, 0, 0)
	)
	assert(PlannedBuildingPortGeometry.inspect_pair(
		backwards_storage, backwards, true
	).is_empty())
	print("PASS I: Backward conveyor direction cannot attach to Storage")

	var shifted := _site(
		container, conveyor_def, Vector3(30.25, 0, 2)
	)
	var shifted_storage := _site(
		container, storage_def, Vector3(30, 0, 0)
	)
	assert(PlannedBuildingPortGeometry.inspect_pair(
		shifted_storage, shifted, true
	).is_empty())
	print("PASS J: Sideways-misaligned conveyor is rejected")

	var distant := _site(
		container, conveyor_def, Vector3(40, 0, 4)
	)
	var distant_storage := _site(
		container, storage_def, Vector3(40, 0, 0)
	)
	assert(PlannedBuildingPortGeometry.inspect_pair(
		distant_storage, distant, true
	).is_empty())
	print("PASS K: Distant endpoints cannot create a phantom connection")

	var queued_site := _site(
		container, storage_def, Vector3(50, 0, 0)
	)
	var queued_belt := _site(
		container, conveyor_def, Vector3(50, 0, 2)
	)
	assert(queued_site.job.authorize())
	assert(not PlannedBuildingPortGeometry.inspect_pair(
		queued_site, queued_belt, true
	).is_empty())
	assert(queued_site.job.set_availability(true, true, true))
	queued_site._process(3.0)
	assert(queued_site.job.set_availability(false, true, true))
	queued_site._process(0.01)
	assert(queued_site.job.state == ConstructionJob.State.PAUSED)
	assert(not PlannedBuildingPortGeometry.inspect_pair(
		queued_site, queued_belt, true
	).is_empty())
	print("PASS L: Queued and paused construction keeps valid planned geometry")

	assert(queued_belt.job.cancel())
	assert(queued_belt.is_queued_for_deletion())
	assert(PlannedBuildingPortGeometry.inspect_pair(
		queued_site, queued_belt, true
	).is_empty())
	print("PASS M: Cancelled blueprint endpoint is not eligible")

	var finished_site := _site(
		container, storage_def, Vector3(60, 0, 0)
	)
	var waiting_belt := _site(
		container, conveyor_def, Vector3(60, 0, 2)
	)
	assert(finished_site.job.authorize())
	assert(finished_site.job.set_availability(true, true, true))
	finished_site._process(storage_def.construction_seconds)
	assert(finished_site.is_completed())
	assert(finished_site.is_queued_for_deletion())
	assert(PlannedBuildingPortGeometry.inspect_pair(
		finished_site, waiting_belt, true
	).is_empty())
	print("PASS N: Completed building requires real ItemPort activation instead")

	assert(PlannedBuildingPortGeometry.inspect_pair(
		inbound, outbound, true
	).is_empty())
	assert(PlannedBuildingPortGeometry.inspect_pair(
		storage, storage, true
	).is_empty())
	assert(inbound.job.state == ConstructionJob.State.PLANNED)
	assert(outbound.job.state == ConstructionJob.State.PLANNED)
	assert(storage.job.state == ConstructionJob.State.PLANNED)
	print("PASS O: Invalid site types and discovery side effects fail closed")

	print("ALL 15 PLANNED BUILDING PORT GEOMETRY E3A TESTS PASSED")
