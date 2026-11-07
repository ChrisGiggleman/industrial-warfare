extends Node3D
class_name ConstructionSite

# =============================================================================
# CONSTRUCTION SITE — RESERVED FOOTPRINT AND DELAYED ACTIVATION
# =============================================================================
# Standalone prototype. Live placement routing remains unchanged until tested.

signal building_completed(building: Node3D)

@export var construction_duration: float = 5.0
var target_definition: BuildingDefinition
var lifecycle: ConstructionLifecycle = ConstructionLifecycle.new()
var footprint: Vector2i = Vector2i.ONE
var _collision: CollisionShape3D
var _progress_bar: ProgressBar
var _completed_building: Node3D


func setup(definition: BuildingDefinition, duration: float = 5.0) -> bool:
	if not is_instance_valid(definition) or not is_instance_valid(definition.building_scene):
		return false
	if not lifecycle.configure(duration):
		return false
	target_definition = definition
	construction_duration = duration
	footprint = definition.footprint_tiles
	return true


func _ready() -> void:
	add_to_group("construction_sites")
	_build_placeholder()
	lifecycle.construction_completed.connect(_finish_construction)
	if target_definition != null:
		lifecycle.start()


func _process(delta: float) -> void:
	lifecycle.advance(delta)
	if is_instance_valid(_progress_bar):
		_progress_bar.value = lifecycle.get_progress() * 100.0


func _build_placeholder() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(float(footprint.x), 0.6, float(footprint.y))
	var body := StaticBody3D.new()
	body.name = "ReservedFootprint"
	body.collision_layer = 6
	body.collision_mask = 0
	add_child(body)
	_collision = CollisionShape3D.new()
	_collision.shape = shape
	_collision.position.y = 0.3
	body.add_child(_collision)

	var mesh := MeshInstance3D.new()
	mesh.name = "ConstructionPlaceholder"
	var box := BoxMesh.new()
	box.size = shape.size
	mesh.mesh = box
	mesh.position.y = 0.3
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.26, 0.58, 0.82, 0.48)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = material
	add_child(mesh)

	var label := Label3D.new()
	label.name = "ConstructionLabel"
	label.text = "CONSTRUCTING"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 1.0, 0.0)
	label.font_size = 28
	label.pixel_size = 0.008
	add_child(label)

	# World-space progress text is intentionally separate from debug HUD.
	_progress_bar = null


func get_progress() -> float:
	return lifecycle.get_progress()


func is_completed() -> bool:
	return is_instance_valid(_completed_building)


func _finish_construction() -> void:
	if not is_instance_valid(target_definition):
		return
	var instance := target_definition.building_scene.instantiate()
	if not instance is Node3D:
		if is_instance_valid(instance):
			instance.free()
		push_error("Construction failed: target scene root is not Node3D.")
		return
	var building := instance as Node3D
	var parent_node := get_parent()
	if parent_node == null:
		building.free()
		return
	var final_transform := global_transform
	# Remove the footprint before activating the completed building.
	_collision.disabled = true
	parent_node.add_child(building)
	building.global_transform = final_transform
	var runtime := building.get_node_or_null("BuildingRuntime") as BuildingRuntime
	if runtime != null:
		runtime.initialize(target_definition)
	_completed_building = building
	building_completed.emit(building)
	queue_free()
