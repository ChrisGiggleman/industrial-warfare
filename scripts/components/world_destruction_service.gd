extends Node
class_name WorldDestructionService

# =============================================================================
# MAIN-WORLD DESTRUCTION — SALVAGE DESTINATION
# =============================================================================

# Keeps salvage outside destroyed buildings and belts. In the playable
# world, a health-depleted building uses the same guarded transaction
# as the already validated isolated salvage removal.
# Conveyor HP and automatic belt destruction are separate milestones.

const SALVAGE_SCENE: PackedScene = preload(
	"res://scenes/logistics/world_salvage_cache.tscn"
)

@export var destroy_on_zero_hp: bool = true

var successful_destructions: int = 0
var failed_health_destructions: int = 0


# =============================================================================
# HEALTH DEPLETION — GUARDED LIVE BUILDING DESTRUCTION
# =============================================================================

# BuildingHealthComponent connects its health_depleted signal while
# entering the Main scene tree. Legacy isolated tests can switch this
# off without changing the result of manual damage assertions.

func _on_building_health_depleted(source: Node3D) -> void:
	if not destroy_on_zero_hp or not _is_valid_world_target(source):
		return

	var health := source.get_node_or_null(
		"BuildingHealthComponent"
	) as BuildingHealthComponent
	if not is_instance_valid(health) or health.is_intact():
		return

	var cache := try_destroy_with_salvage(source)
	if not is_instance_valid(cache):
		# A failed salvage transaction does not delete the structure.
		# It remains disabled at zero HP for recovery/retry later.
		failed_health_destructions += 1
		return

	# The world still owns both objects until the end of this frame.
	# Release any player selection before queue_free completes.
	var world := get_parent() as Node3D
	var interaction := world.get_node_or_null("WorldInteraction")
	if is_instance_valid(interaction) and interaction.selected_object == source:
		interaction._select_object(null)

	var hud := world.get_node_or_null("ProductionDebugHUD") as ProductionDebugHUD
	if is_instance_valid(hud) and hud.selected_building == source:
		hud.clear_selection()


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
