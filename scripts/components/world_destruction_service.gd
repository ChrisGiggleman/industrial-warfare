extends Node
class_name WorldDestructionService

# =============================================================================
# MAIN-WORLD DESTRUCTION — SALVAGE DESTINATION
# =============================================================================

# Keeps salvage outside destroyed buildings and belts. This service
# does NOT watch health or trigger zombie destruction yet.
# Its removal entrypoint is exercised by an isolated Main-scene test.

const SALVAGE_SCENE: PackedScene = preload(
	"res://scenes/logistics/world_salvage_cache.tscn"
)

var successful_destructions: int = 0


# =============================================================================
# WORLD OWNERSHIP AND TARGET GUARDS
# =============================================================================

func _is_valid_world_target(source: Node3D) -> bool:
	var world := get_parent() as Node3D
	if not is_instance_valid(world):
		return false
	if not is_instance_valid(source):
		return false
	if not source.is_inside_tree() or source.is_queued_for_deletion():
		return false
	if not world.is_ancestor_of(source):
		return false
	if not source.is_in_group("player_built"):
		return false
	if source.is_in_group("construction_preview"):
		return false
	if source is ConveyorSegment:
		return true

	return is_instance_valid(
		source.get_node_or_null("BuildingRuntime") as BuildingRuntime
	)


# =============================================================================
# RECOVER CARGO, REMOVE SOURCE, AND LEAVE WORLD SALVAGE
# =============================================================================

# The new cache is a sibling owned by Main. The destruction transaction
# moves all owned materials into it BEFORE queueing the source for removal.
# A failed transaction removes the empty cache and leaves the source intact.

func try_destroy_with_salvage(source: Node3D) -> WorldSalvageCache:
	if not _is_valid_world_target(source):
		return null

	var world := get_parent() as Node3D
	var cache := SALVAGE_SCENE.instantiate() as WorldSalvageCache
	if not is_instance_valid(cache):
		return null

	world.add_child(cache)
	cache.global_position = source.global_position

	if not is_instance_valid(cache.inventory):
		world.remove_child(cache)
		cache.free()
		return null

	if not DestructionTransaction.try_destroy(source, cache.inventory):
		# No removal was authorized; a failed preflight must not leave
		# behind an empty or duplicate salvage cache.
		world.remove_child(cache)
		cache.free()
		return null

	cache.refresh_display()
	successful_destructions += 1
	return cache
