extends Node3D
class_name PrototypePowerStructure

# =============================================================================
# E3D5C3B1 — COMPLETED POWER STRUCTURE STATE (ISOLATED)
# =============================================================================
# Real scene ownership supplies operational/source state. Power nodes are
# children of COMPLETED structures, not planned construction footprints.
# Generator output below is a NAMEPLATE RATING, NOT an allocated energy
# budget. This component never grants job availability, drones or materials.

@export_range(0, 1000, 1) var rated_generation: int = 0
@export var starts_service_enabled: bool = true
@export var starts_generator_enabled: bool = true

var service_enabled: bool = false
var generator_enabled: bool = false


func _ready() -> void:
	service_enabled = starts_service_enabled
	generator_enabled = starts_generator_enabled
	var health: BuildingHealthComponent = get_health()
	if is_instance_valid(health):
		health.health_depleted.connect(_on_health_depleted)
	refresh_power_state()


func get_power_node() -> ConstructionPowerNetworkNode:
	return get_node_or_null(
		"ConstructionPowerNetworkNode"
	) as ConstructionPowerNetworkNode


func get_health() -> BuildingHealthComponent:
	return get_node_or_null(
		"BuildingHealthComponent"
	) as BuildingHealthComponent


func set_service_enabled(value: bool) -> void:
	service_enabled = value
	refresh_power_state()


func set_generator_enabled(value: bool) -> bool:
	if rated_generation <= 0:
		return false
	generator_enabled = value
	refresh_power_state()
	return true


func available_nameplate_generation() -> int:
	var node: ConstructionPowerNetworkNode = get_power_node()
	if not is_instance_valid(node) or not node.source_online:
		return 0
	return rated_generation


func refresh_power_state() -> void:
	var node: ConstructionPowerNetworkNode = get_power_node()
	if not is_instance_valid(node):
		return
	var health: BuildingHealthComponent = get_health()
	var intact: bool = (
		is_inside_tree() and not is_queued_for_deletion()
		and is_instance_valid(health) and health.is_intact()
	)
	node.operational = intact and service_enabled
	node.is_source = rated_generation > 0
	node.source_online = (
		node.operational and node.is_source and generator_enabled
	)


func _on_health_depleted() -> void:
	refresh_power_state()


func _exit_tree() -> void:
	var node: ConstructionPowerNetworkNode = get_power_node()
	if is_instance_valid(node):
		node.operational = false
		node.source_online = false
