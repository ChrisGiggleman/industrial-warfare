
extends Node


# =============================================================================
# MACHINE PORT INTEGRATION TEST
# =============================================================================

# Tests physical input and output ports on an actual
# instantiated Test Smelter.
#
# Checks:
# - Scene node references
# - Port direction and inventory configuration
# - Active recipe ingredient acceptance
# - Capacity and output availability
# - World positions and orientation after rotation
# - Inventory and production state preservation
#
# This test does not perform conveyor transfers.


# =============================================================================
# TEST INITIALIZATION
# =============================================================================

func _ready() -> void:

	print("\n===== CHAT 07: PORT INTEGRATION TEST =====")

	var ore: ItemDefinition = load(
		"res://data/items/test_ore.tres"
	) as ItemDefinition

	var ingot: ItemDefinition = load(
		"res://data/items/test_ingot.tres"
	) as ItemDefinition

	var smelter_scene: PackedScene = load(
		"res://scenes/buildings/test_smelter.tscn"
	) as PackedScene

	assert(ore != null)
	assert(ingot != null)
	assert(smelter_scene != null)


	# =============================================================================
	# CREATE ISOLATED TEST SMELTER
	# =============================================================================

	var smelter: Node3D = (
		smelter_scene.instantiate() as Node3D
	)

	assert(smelter != null)

	smelter.position = Vector3(8.0, 0.0, 4.0)

	add_child(smelter)


	# =============================================================================
	# GET EXISTING BUILDING COMPONENTS
	# =============================================================================

	var producer: ProducerComponent = (
		smelter.get_node_or_null("ProducerComponent")
		as ProducerComponent
	)

	var logistics: LogisticsInputComponent = (
		smelter.get_node_or_null("LogisticsInputComponent")
		as LogisticsInputComponent
	)

	var input_inventory: InventoryComponent = (
		smelter.get_node_or_null("InputInventory")
		as InventoryComponent
	)

	var output_inventory: InventoryComponent = (
		smelter.get_node_or_null("OutputInventory")
		as InventoryComponent
	)

	var input_port: ItemPortComponent = (
		smelter.get_node_or_null("InputPort")
		as ItemPortComponent
	)

	var output_port: ItemPortComponent = (
		smelter.get_node_or_null("OutputPort")
		as ItemPortComponent
	)

	assert(producer != null)
	assert(logistics != null)
	assert(input_inventory != null)
	assert(output_inventory != null)


	# =============================================================================
	# DISABLE AUTOMATIC PROCESSING DURING TEST
	# =============================================================================

	# This test checks port rules directly.
	# It must not run the smelter's ordinary production
	# or automatic proximity-transfer behavior.

	producer.set_process(false)
	logistics.set_process(false)


	# =============================================================================
	# TEST A — BOTH PORTS EXIST
	# =============================================================================

	assert(input_port != null)
	assert(output_port != null)

	print("PASS A: Both machine ports loaded")


	# =============================================================================
	# TEST B — CORRECT COMPONENT REFERENCES
	# =============================================================================

	assert(
		input_port.direction
		== ItemPortComponent.PortDirection.INPUT
	)

	assert(
		output_port.direction
		== ItemPortComponent.PortDirection.OUTPUT
	)

	assert(
		input_port.input_policy
		== ItemPortComponent.InputPolicy.RECIPE_INPUTS
	)

	assert(input_port.inventory == input_inventory)
	assert(output_port.inventory == output_inventory)

	assert(input_port.producer_component == producer)
	assert(output_port.producer_component == producer)

	print("PASS B: Port directions and references correct")


	# =============================================================================
	# TEST C — INITIAL PORT POSITION AND DIRECTION
	# =============================================================================

	# Verify local placement on opposite building faces.

	assert(
		input_port.position.distance_to(
			Vector3(-0.85, 0.5, 0.0)
		) < 0.001
	)

	assert(
		output_port.position.distance_to(
			Vector3(0.85, 0.5, 0.0)
		) < 0.001
	)

	# Godot's local forward axis is negative Z.
	# Each port's forward axis must point outward.

	var input_forward: Vector3 = (
		input_port.global_transform.basis * Vector3.FORWARD
	).normalized()

	var output_forward: Vector3 = (
		output_port.global_transform.basis * Vector3.FORWARD
	).normalized()

	assert(input_forward.distance_to(Vector3.LEFT) < 0.001)
	assert(output_forward.distance_to(Vector3.RIGHT) < 0.001)

	print("PASS C: Initial port positions and directions correct")


	# =============================================================================
	# TEST D — RECIPE-BASED INPUT ACCEPTANCE
	# =============================================================================

	assert(input_port.can_accept_item(ore, 2))

	assert(not input_port.can_accept_item(ingot, 1))
	assert(not input_port.can_accept_item(null, 1))

	print("PASS D: Active recipe determines accepted ingredients")


	# =============================================================================
	# TEST E — INPUT INVENTORY CAPACITY
	# =============================================================================

	# The current Test Smelter has 50 input capacity.
	# Fill 49 slots and verify only one more item can fit.

	assert(input_inventory.max_capacity == 50)
	assert(input_inventory.add_item(ore, 49) == 49)

	assert(input_port.can_accept_item(ore, 1))
	assert(not input_port.can_accept_item(ore, 2))

	print("PASS E: Input capacity restrictions enforced")


	# =============================================================================
	# TEST F — OUTPUT PORT AVAILABILITY
	# =============================================================================

	# A smelter output port only offers stored products.
	# Querying available output must not remove anything.

	assert(not output_port.can_provide_item(ingot, 1))

	assert(output_inventory.add_item(ingot, 3) == 3)

	assert(output_port.can_provide_item(ingot, 2))
	assert(not output_port.can_provide_item(ingot, 4))

	# Port direction must also be enforced.

	assert(not output_port.can_accept_item(ore, 1))
	assert(not input_port.can_provide_item(ore, 1))

	print("PASS F: Output availability and direction respected")


	# =============================================================================
	# TEST G — PORT ROTATION WITH BUILDING
	# =============================================================================

	# Rotate the whole building 90 degrees around Y.
	# Child Marker3D ports must rotate and move with it.

	smelter.rotation_degrees.y = 90.0

	# The original left and right ports should now
	# appear on the opposite Z faces of the smelter.

	assert(
		input_port.global_position.distance_to(
			Vector3(8.0, 0.5, 4.85)
		) < 0.001
	)

	assert(
		output_port.global_position.distance_to(
			Vector3(8.0, 0.5, 3.15)
		) < 0.001
	)

	# Confirm outward directions rotate as well.

	input_forward = (
		input_port.global_transform.basis * Vector3.FORWARD
	).normalized()

	output_forward = (
		output_port.global_transform.basis * Vector3.FORWARD
	).normalized()

	assert(input_forward.distance_to(Vector3.BACK) < 0.001)
	assert(output_forward.distance_to(Vector3.FORWARD) < 0.001)

	print("PASS G: Port positions and directions follow rotation")


	# =============================================================================
	# TEST H — PORT CHECKS DO NOT MODIFY GAME STATE
	# =============================================================================

	# Neither acceptance nor availability checks should
	# manufacture, transfer, consume, or delete resources.

	assert(input_inventory.get_amount(ore) == 49)
	assert(output_inventory.get_amount(ingot) == 3)

	assert(producer.production_progress == 0.0)

	print("PASS H: Inventory and production state preserved")


	# =============================================================================
	# CLEAN UP TEST BUILDING
	# =============================================================================

	# The instantiated building is temporary.
	# No permanent world scene is modified.

	smelter.queue_free()


	# =============================================================================
	# FINAL RESULTS
	# =============================================================================

	print("======================================")
	print("ALL 8 PORT INTEGRATION TESTS PASSED")
	print("======================================")
