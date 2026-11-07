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
var _progress_label: Label3D
var _completed_building: Node3D
# Pending belts have no active inventory connection until construction ends.
var _reserved_belts: Dictionary = {}


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
	_build_planned_ports()
	lifecycle.construction_completed.connect(_finish_construction)
	if target_definition != null:
		lifecycle.start()


func _process(delta: float) -> void:
	lifecycle.advance(delta)
	if is_instance_valid(_progress_label):
		_progress_label.text = "CONSTRUCTING %d%%" % int(round(lifecycle.get_progress() * 100.0))


func _build_placeholder() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(float(footprint.x), 0.6, float(footprint.y))
	var body := StaticBody3D.new()
	body.name = "ReservedFootprint"
	body.collision_layer = 6
	body.collision_mask = 0
	add_child(body)
	_collision = CollisionShape3D.new()
	_collision.name = "CollisionShape3D"
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
	label.text = "CONSTRUCTING 0%"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 1.0, 0.0)
	label.font_size = 28
	label.pixel_size = 0.008
	add_child(label)
	_progress_label = label



# =============================================================================
# PLANNED CONVEYOR PORTS — GEOMETRY ONLY
# =============================================================================
# These Marker3D nodes copy the future building's port transforms.
# They are not ItemPortComponents and never expose inventory or cargo.

func _build_planned_ports() -> void:
	if not is_instance_valid(target_definition):
		return
	var prototype := target_definition.building_scene.instantiate() as Node3D
	if prototype == null:
		return
	for name: String in ["InputPort", "OutputPort"]:
		var source := prototype.get_node_or_null(name) as ItemPortComponent
		if source == null:
			continue
		var marker := Marker3D.new()
		marker.name = "Planned" + name
		marker.transform = source.transform
		add_child(marker)
	prototype.free()


func get_planned_port(input_side: bool) -> Marker3D:
	return get_node_or_null(
		"PlannedInputPort" if input_side else "PlannedOutputPort"
	) as Marker3D


func get_planned_belt_transform(
	belt: ConveyorSegment, input_side: bool
) -> Dictionary:
	if not is_instance_valid(belt) or not belt.is_inside_tree():
		return {}
	if lifecycle.state != ConstructionLifecycle.State.CONSTRUCTING:
		return {}
	var marker := get_planned_port(input_side)
	var endpoint := belt.get_node_or_null(
		"OutputEndpoint" if input_side else "InputEndpoint"
	) as Marker3D
	if marker == null or endpoint == null:
		return {}
	var desired_basis := (
		marker.global_transform.basis.orthonormalized()
		* Basis(Vector3.UP, PI)
	)
	var root_basis := (
		desired_basis * endpoint.transform.basis.inverse()
	).orthonormalized()
	return {
		"transform": Transform3D(
			root_basis,
			marker.global_position - root_basis * endpoint.position
		)
	}


func reserve_conveyor(
	belt: ConveyorSegment, input_side: bool
) -> bool:
	if lifecycle.state != ConstructionLifecycle.State.CONSTRUCTING:
		return false
	if not is_instance_valid(belt) or not belt.is_inside_tree():
		return false
	if belt.is_queued_for_deletion():
		return false
	var port_name := "InputPort" if input_side else "OutputPort"
	if _reserved_belts.has(port_name):
		return false
	if input_side:
		if is_instance_valid(belt.next_segment):
			return false
		if is_instance_valid(belt.output_building_port):
			return false
	else:
		if is_instance_valid(belt.previous_segment):
			return false
		if is_instance_valid(belt.input_building_port):
			return false
	var planned := get_planned_port(input_side)
	var endpoint := belt.get_node_or_null(
		"OutputEndpoint" if input_side else "InputEndpoint"
	) as Marker3D
	if planned == null or endpoint == null:
		return false
	var outgoing: Marker3D = endpoint if input_side else planned
	var incoming: Marker3D = planned if input_side else endpoint
	if not LogisticsConnectionGeometry.are_endpoints_aligned(
		outgoing, incoming, ConveyorSegment.CONNECTION_GAP
	):
		return false
	_reserved_belts[port_name] = belt
	return true


func get_reserved_conveyor(input_side: bool) -> ConveyorSegment:
	return _reserved_belts.get(
		"InputPort" if input_side else "OutputPort"
	) as ConveyorSegment


func _connect_reserved_belts(building: Node3D) -> void:
	for port_name: String in ["InputPort", "OutputPort"]:
		var belt := _reserved_belts.get(port_name) as ConveyorSegment
		if not is_instance_valid(belt) or belt.is_queued_for_deletion():
			continue
		var port := building.get_node_or_null(port_name) as ItemPortComponent
		if port == null:
			continue
		# Belt and building endpoint alignment must still be valid now.
		# Failed or moved reservations leave the belt disconnected.
		belt.try_connect_building_port(port)
	_reserved_belts.clear()


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
	_connect_reserved_belts(building)
	_completed_building = building
	building_completed.emit(building)
	queue_free()
