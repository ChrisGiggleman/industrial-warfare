extends RefCounted
class_name DestructionCargoRecovery

# =============================================================================
# DESTRUCTION CARGO RECOVERY — TRANSACTION PREPARATION
# =============================================================================

# First destruction checkpoint: a lossless inventory escrow operation.
# This helper does not destroy a building, disconnect conveyors, or
# create a world drop. A later destruction controller will only remove
# the source AFTER its inventories have been recovered successfully.
#
# The destination should be a separate recoverable cache with unlimited
# capacity (max_capacity == 0). Limited caches are also supported if
# the combined source contents fit completely.
#
# Existing InventoryComponent.transfer_to() owns item movement and
# restoration. No special-case ore, ingot or ammunition rules exist.


# =============================================================================
# FIND OWNED INVENTORIES
# =============================================================================

# Collects descendants of the source but never walks out of its tree.
# Each InventoryComponent is collected once even if referenced by
# several item ports or producer components.

static func collect_inventories(source: Node) -> Array[InventoryComponent]:
	var found: Array[InventoryComponent] = []
	if not is_instance_valid(source):
		return found

	_collect_descendant_inventories(source, found)
	return found


static func _collect_descendant_inventories(
	node: Node,
	destination: Array[InventoryComponent]
) -> void:
	if node is InventoryComponent:
		destination.append(node as InventoryComponent)

	for child: Node in node.get_children():
		_collect_descendant_inventories(child, destination)


# =============================================================================
# PREFLIGHT COMPLETE RECOVERY
# =============================================================================

# Refuses partial recovery. A failed preflight does not modify source
# items, ports, or the destination recovery cache.

static func can_recover_all(
	source: Node,
	recovery_inventory: InventoryComponent
) -> bool:
	if not is_instance_valid(source) or not is_instance_valid(recovery_inventory):
		return false
	if source.is_queued_for_deletion() or recovery_inventory.is_queued_for_deletion():
		return false
	if source == recovery_inventory:
		return false
	if source.is_ancestor_of(recovery_inventory):
		return false
	if recovery_inventory.is_ancestor_of(source):
		return false

	var owned: Array[InventoryComponent] = collect_inventories(source)
	if owned.is_empty():
		return false

	var total: int = 0
	for inventory: InventoryComponent in owned:
		if not is_instance_valid(inventory) or inventory.is_queued_for_deletion():
			return false

		for key: Variant in inventory.items.keys():
			# Variant dictionary keys can contain malformed primitive values.
			# Guard the type BEFORE casting: Godot rejects a String assigned
			# to an ItemDefinition-typed variable at runtime.
			if not (key is ItemDefinition):
				return false

			var item: ItemDefinition = key as ItemDefinition
			if not is_instance_valid(item):
				return false

			var amount: int = int(inventory.items[key])
			if amount <= 0:
				return false
			total += amount

	var free_space: int = recovery_inventory.get_available_space()
	if free_space >= 0 and free_space < total:
		return false

	return true


# =============================================================================
# MOVE ALL OWNED ITEMS INTO RECOVERY CACHE
# =============================================================================

# Successful calls leave every source inventory empty and preserve
# the exact total units in the separate recovery cache. Repeating a
# successful call is harmless because no source items remain.
#
# Keep source and recovery cache out of live transport processing while
# this transaction runs. This initial helper is intentionally NOT wired
# into automatic damage or demolition until its regression passes.

static func recover_all(
	source: Node,
	recovery_inventory: InventoryComponent
) -> bool:
	if not can_recover_all(source, recovery_inventory):
		return false

	var owned: Array[InventoryComponent] = collect_inventories(source)
	for inventory: InventoryComponent in owned:
		var keys: Array = inventory.items.keys()
		for key: Variant in keys:
			# Protect the transfer loop as well, even though the preflight
			# has already validated every inventory key.
			if not (key is ItemDefinition):
				return false

			var item: ItemDefinition = key as ItemDefinition
			if not is_instance_valid(item):
				return false

			var amount: int = inventory.get_amount(item)
			if amount <= 0:
				continue

			var transferred: int = inventory.transfer_to(
				recovery_inventory, item, amount
			)
			if transferred != amount:
				# This cannot occur in a single-threaded, paused test
				# following a complete capacity preflight. Fail closed:
				# the caller must NOT delete its source on failure.
				push_error(
					"DestructionCargoRecovery: partial transfer; "
					+ "do not destroy source"
				)
				return false

	return true
