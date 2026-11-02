extends RefCounted
class_name DestructionTransaction

# =============================================================================
# GUARDED STRUCTURE REMOVAL — DESTRUCTION TRANSACTION
# =============================================================================

# Executes an authorized destruction/removal after source-owned cargo
# can be recovered into an independent salvage inventory.
#
# This is not connected to zombie damage or player demolition yet.
# A future controller will authorize removal only after the target
# reaches zero HP (or after a separately validated demolition action).
#
# The caller must provide a recovery inventory that will remain alive
# after the source disappears. No temporary cache is created here.


# =============================================================================
# VALIDATE A REAL PLAYER-BUILT STRUCTURE
# =============================================================================

static func can_destroy(
	source: Node3D,
	recovery_inventory: InventoryComponent
) -> bool:
	if not is_instance_valid(source):
		return false
	# Salvage must be a live, separately owned inventory, never a
	# temporary unattached buffer that disappears with the source.
	if not is_instance_valid(recovery_inventory):
		return false
	if not recovery_inventory.is_inside_tree():
		return false
	if not source.is_inside_tree() or source.is_queued_for_deletion():
		return false
	if not source.is_in_group("player_built"):
		return false
	if source.is_in_group("construction_preview"):
		return false

	# Accept real conveyor pieces or buildings with a runtime.
	# Reject deposits, enemies, previews and arbitrary scene nodes.
	if not (source is ConveyorSegment):
		var runtime := source.get_node_or_null(
			"BuildingRuntime"
		) as BuildingRuntime
		if not is_instance_valid(runtime):
			return false

	return DestructionCargoRecovery.can_recover_all(
		source, recovery_inventory
	)


# =============================================================================
# DISCONNECT ONLY OWNED BUILDING PORTS
# =============================================================================

static func _disconnect_owned_ports(owner: Node) -> void:
	if owner is ItemPortComponent:
		var port := owner as ItemPortComponent
		if is_instance_valid(port.connected_conveyor):
			port.connected_conveyor.disconnect_building_port(port)

	for child: Node in owner.get_children():
		_disconnect_owned_ports(child)


# =============================================================================
# RECOVER, DISCONNECT, AND QUEUE SOURCE FOR REMOVAL
# =============================================================================

# Safe order:
# 1. Reject invalid targets and insufficient salvage capacity
# 2. Recover every owned inventory before any deletion
# 3. Disable the soon-to-be-removed source's gameplay processing
# 4. Disconnect only its own belt/port links
# 5. Queue the source, never any surviving neighboring conveyor
#
# Repeated calls while queued are rejected by can_destroy().
# For now, the actual queue_free() path is test-only.

static func try_destroy(
	source: Node3D,
	recovery_inventory: InventoryComponent
) -> bool:
	if not can_destroy(source, recovery_inventory):
		return false

	if not DestructionCargoRecovery.recover_all(
		source, recovery_inventory
	):
		# Never delete a source whose contents were not recovered.
		return false

	source.process_mode = Node.PROCESS_MODE_DISABLED

	if source is ConveyorSegment:
		(source as ConveyorSegment).disconnect_all()
	else:
		_disconnect_owned_ports(source)

	source.queue_free()
	return true
