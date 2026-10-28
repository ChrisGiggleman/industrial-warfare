extends Node


# =============================================================================
# CHAT 08.3F — SMELTER DUAL-PORT SNAP REGRESSION
# =============================================================================

# The two physical ports on the same real Smelter must
# remain independently available to different conveyors.
#
# Uses generic port/conveyor components; no ore-type special cases.
# No resource transfer is performed in this scene.


func _ready() -> void:

	print("\n===== CHAT 08.3F: SMELTER DUAL-PORT SNAP TEST =====")

	var smelter_scene: PackedScene = load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	var belt_scene: PackedScene = load(
		"res://scenes/logistics/conveyor_straight.tscn"
	) as PackedScene

	assert(smelter_scene != null)
	assert(belt_scene != null)

	var root := Node3D.new()
	add_child(root)

	var smelter: Node3D = smelter_scene.instantiate() as Node3D
	var input_belt: ConveyorSegment = (
		belt_scene.instantiate() as ConveyorSegment
	)
	var output_belt: ConveyorSegment = (
		belt_scene.instantiate() as ConveyorSegment
	)

	assert(smelter != null)
	assert(input_belt != null)
	assert(output_belt != null)

	root.add_child(smelter)
	root.add_child(input_belt)
	root.add_child(output_belt)

	smelter.global_position = Vector3(10.0, 0.0, 10.0)

	# Disable unrelated proximity logistics / production.
	(
		smelter.get_node("LogisticsInputComponent")
		as LogisticsInputComponent
	).set_process(false)
	(
		smelter.get_node("ProducerComponent")
		as ProducerComponent
	).set_process(false)

	for belt: ConveyorSegment in [input_belt, output_belt]:
		(
			belt.get_node("ConveyorTransportTimer")
			as ConveyorTransportTimer
		).set_process(false)

	var input_port: ItemPortComponent = (
		smelter.get_node("InputPort") as ItemPortComponent
	)
	var output_port: ItemPortComponent = (
		smelter.get_node("OutputPort") as ItemPortComponent
	)

	assert(input_port != null)
	assert(output_port != null)
	assert(input_port != output_port)

	# =============================================================================
	# A — BOTH PORTS START AVAILABLE
	# =============================================================================

	assert(not is_instance_valid(input_port.connected_conveyor))
	assert(not is_instance_valid(output_port.connected_conveyor))
	assert(input_port.direction == ItemPortComponent.PortDirection.INPUT)
	assert(output_port.direction == ItemPortComponent.PortDirection.OUTPUT)

	print("PASS A: Smelter ports start independent and available")

	# =============================================================================
	# B — CONNECT AN INPUT BELT
	# =============================================================================

	var input_preview: Dictionary = (
		ConveyorBuildingSnap.get_preview_transform(
			input_port, input_belt
		)
	)

	assert(input_preview.has("transform"))
	input_belt.global_transform = input_preview["transform"]

	assert(input_belt.try_connect_building_port(input_port))
	assert(input_port.connected_conveyor == input_belt)
	assert(input_belt.output_building_port == input_port)
	assert(not is_instance_valid(output_port.connected_conveyor))

	print("PASS B: Smelter input connection leaves output free")

	# =============================================================================
	# C — DISCOVER OUTPUT FROM A CORRECTLY ROTATED BELT
	# =============================================================================

	var output_preview: Dictionary = (
		ConveyorBuildingSnap.get_preview_transform(
			output_port, output_belt
		)
	)

	assert(output_preview.has("transform"))

	var output_transform: Transform3D = (
		output_preview["transform"]
	)

	# Preserve the intended conveyor rotation, but leave
	# it in the wrong place until the finder returns a snap.
	output_belt.global_transform = Transform3D(
		output_transform.basis,
		Vector3.ZERO
	)

	var discovery: Dictionary = (
		ConveyorBuildingPortFinder.find_nearest_preview(
			output_belt,
			output_transform.origin,
			1.75
		)
	)

	# =============================================================================
	# EXPLAIN A MISSING DISCOVERY CANDIDATE
	# =============================================================================

	# In a test scene, a missing candidate can be caused by
	# group registration, port occupancy, direction, or range.
	# Print all four inputs before the assertion, so the exact
	# cause is visible instead of a bare "Assertion failed".

	if discovery.is_empty():

		var port_recheck: Dictionary = (
			ConveyorBuildingSnap.get_preview_transform(
				output_port,
				output_belt
			)
		)

		var current_forward: Vector3 = (
			output_belt.global_transform.basis
			* Vector3.FORWARD
		).normalized()

		var proposed_forward: Vector3 = (
			output_transform.basis * Vector3.FORWARD
		).normalized()

		var cursor_distance: float = 0.0

		if port_recheck.has("transform"):

			var latest: Transform3D = port_recheck["transform"]

			cursor_distance = Vector2(
				output_transform.origin.x - latest.origin.x,
				output_transform.origin.z - latest.origin.z
			).length()

		print("DIAGNOSTIC C | Smelter group registered: ",
			smelter.is_in_group("player_built"))
		print("DIAGNOSTIC C | Group contains Smelter: ",
			get_tree().get_nodes_in_group("player_built").has(smelter))
		print("DIAGNOSTIC C | Smelter process disabled: ",
			smelter.process_mode == Node.PROCESS_MODE_DISABLED)
		print("DIAGNOSTIC C | Output port occupied: ",
			is_instance_valid(output_port.connected_conveyor))
		print("DIAGNOSTIC C | Output inventory valid: ",
			is_instance_valid(output_port.inventory))
		print("DIAGNOSTIC C | Port direct child: ",
			output_port.get_parent() == smelter)
		print("DIAGNOSTIC C | Preview still available: ",
			port_recheck.has("transform"))
		print("DIAGNOSTIC C | Facing dot: ",
			current_forward.dot(proposed_forward))
		print("DIAGNOSTIC C | Cursor distance: ",
			cursor_distance)

	assert(discovery.has("port"))
	assert(discovery["port"] == output_port)
	assert(discovery["transform"].is_equal_approx(output_transform))

	print("PASS C: OutputPort discovered while InputPort occupied")

	# =============================================================================
	# D — NEARBY CURSOR CAN DISCOVER THE OUTPUT
	# =============================================================================

	discovery = ConveyorBuildingPortFinder.find_nearest_preview(
		output_belt,
		output_transform.origin + Vector3(0.75, 0.0, 0.0),
		1.75
	)

	assert(discovery.has("port"))
	assert(discovery["port"] == output_port)

	print("PASS D: Port stays discoverable within snap radius")

	# =============================================================================
	# E — ACTUAL OUTPUT CONNECTION IS INDEPENDENT
	# =============================================================================

	output_belt.global_transform = output_transform

	assert(output_belt.try_connect_building_port(output_port))
	assert(output_port.connected_conveyor == output_belt)
	assert(output_belt.input_building_port == output_port)
	assert(input_port.connected_conveyor == input_belt)

	print("PASS E: Both Smelter ports connected independently")

	# =============================================================================
	# F — OCCUPIED PORTS DO NOT OFFER NEW CONNECTIONS
	# =============================================================================

	assert(
		ConveyorBuildingPortFinder.find_nearest_preview(
			output_belt,
			output_transform.origin,
			1.75
		).is_empty()
	)

	print("PASS F: Occupied connection endpoints rejected")

	# =============================================================================
	# G — DISCONNECT OUTPUT WITHOUT DISTURBING INPUT
	# =============================================================================

	assert(output_belt.disconnect_building_port(output_port))
	assert(not is_instance_valid(output_port.connected_conveyor))
	assert(input_port.connected_conveyor == input_belt)

	print("PASS G: Output disconnect preserves input connection")

	# =============================================================================
	# H — NO INVENTORY TRANSFERS OCCURRED
	# =============================================================================

	var input_inventory: InventoryComponent = (
		smelter.get_node("InputInventory") as InventoryComponent
	)
	var output_inventory: InventoryComponent = (
		smelter.get_node("OutputInventory") as InventoryComponent
	)

	assert(input_inventory.get_total_amount() == 0)
	assert(output_inventory.get_total_amount() == 0)

	print("PASS H: Connection changes preserve inventories")

	root.queue_free()

	print("==========================================")
	print("ALL 8 SMELTER DUAL-PORT SNAP TESTS PASSED")
	print("==========================================")
