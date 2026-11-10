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
# Opt-in job policy. Null preserves the proven timed-Storage lifecycle.
var job: ConstructionJob = null
var footprint: Vector2i = Vector2i.ONE
var _collision: CollisionShape3D
var compact_blueprint_visuals: bool = false
var _progress_fill: MeshInstance3D = null
var _placeholder_material: StandardMaterial3D = null
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


# =============================================================================
# UNIVERSAL JOB-DRIVEN CONSTRUCTION — OPT-IN
# =============================================================================
# Does not change the original setup() or existing sandbox placement path.
# Call before add_child(). The job keeps the blueprint inactive until the
# player authorizes construction and future services satisfy its gates.

func setup_with_job(
	definition: BuildingDefinition,
	duration: float,
	requires_power: bool = true,
	requires_materials: bool = true,
	requires_workers: bool = true
) -> bool:
	if is_inside_tree() or target_definition != null or job != null:
		return false
	if not setup(definition, duration):
		return false

	var pending := ConstructionJob.new()
	if not pending.configure(
		duration, requires_power, requires_materials, requires_workers
	):
		return false
	job = pending
	return true


# =============================================================================
# DEFINITION-DRIVEN JOB SETUP — OPT-IN
# =============================================================================
# The authoritative duration belongs to the buildable definition, not the
# WorldInteraction hotbar slot. Legacy setup() calls are unaffected.
# Final materials and power requirements will be supplied by later services.

func setup_with_definition_job(
	definition: BuildingDefinition,
	requires_power: bool = true,
	requires_materials: bool = true,
	requires_workers: bool = true
) -> bool:
	if not is_instance_valid(definition):
		return false
	if (
		not is_finite(definition.construction_seconds)
		or definition.construction_seconds <= 0.0
	):
		return false

	return setup_with_job(
		definition,
		definition.construction_seconds,
		requires_power,
		requires_materials,
		requires_workers
	)


func _ready() -> void:
	add_to_group("construction_sites")
	_build_placeholder()
	_build_planned_ports()
	if job != null:
		job.job_completed.connect(_finish_construction)
		job.job_cancelled.connect(_cancel_job_site)
	else:
		lifecycle.construction_completed.connect(_finish_construction)
		if target_definition != null:
			lifecycle.start()
	_refresh_progress_label()


func _process(delta: float) -> void:
	if job != null:
		job.advance(delta)
	else:
		lifecycle.advance(delta)
	_refresh_progress_label()


func _refresh_progress_label() -> void:
	if not is_instance_valid(_progress_label):
		return
	if compact_blueprint_visuals:
		_update_compact_visuals()
		return
	if job == null:
		_progress_label.text = "CONSTRUCTING %d%%" % int(round(get_progress() * 100.0))
		return

	var status: String = ""
	match job.state:
		ConstructionJob.State.PLANNED:
			status = "PLANNED"
		ConstructionJob.State.QUEUED:
			status = "QUEUED"
		ConstructionJob.State.CONSTRUCTING:
			status = "CONSTRUCTING"
		ConstructionJob.State.PAUSED:
			status = "PAUSED"
		ConstructionJob.State.COMPLETE:
			status = "COMPLETE"
		ConstructionJob.State.CANCELLED:
			status = "CANCELLED"
	_progress_label.text = "%s %d%%" % [
		status, int(round(get_progress() * 100.0))
	]


# Compact construction visuals are opt-in for the Factory Testing Sandbox.
# A small 3D progress track replaces overlapping billboard percentages.
func _update_compact_visuals() -> void:
	var state: int = ConstructionJob.State.CONSTRUCTING
	if job != null:
		state = job.state
	var color := Color(0.45, 0.75, 1.0)
	match state:
		ConstructionJob.State.PLANNED:
			color = Color(0.45, 0.75, 1.0)
		ConstructionJob.State.QUEUED:
			color = Color(0.95, 0.7, 0.3)
		ConstructionJob.State.CONSTRUCTING:
			color = Color(0.3, 0.9, 0.55)
		ConstructionJob.State.PAUSED:
			color = Color(0.95, 0.4, 0.3)
	if _placeholder_material != null:
		_placeholder_material.albedo_color = Color(color.r, color.g, color.b, 0.48)
	if is_instance_valid(_progress_fill):
		var progress: float = clampf(get_progress(), 0.0, 1.0)
		_progress_fill.scale.x = maxf(progress, 0.001)
		_progress_fill.position.x = -(1.0 - progress) * 0.45
		var fill_material := _progress_fill.material_override as StandardMaterial3D
		if fill_material != null:
			fill_material.albedo_color = color
	if is_instance_valid(_progress_label):
		# Belt labels are deliberately hidden; direction arrows remain visible.
		_progress_label.visible = (
			not is_instance_valid(target_definition)
			or target_definition.building_id != &"conveyor_belt"
		)
		if _progress_label.visible:
			match state:
				ConstructionJob.State.PLANNED:
					_progress_label.text = "PLAN"
				ConstructionJob.State.QUEUED:
					_progress_label.text = "WAIT"
				ConstructionJob.State.CONSTRUCTING:
					_progress_label.text = "BUILD"
				ConstructionJob.State.PAUSED:
					_progress_label.text = "PAUSED"
				_:
					_progress_label.text = ""


func _build_compact_progress_bar() -> void:
	var track := MeshInstance3D.new()
	track.name = "ConstructionProgressTrack"
	var track_mesh := BoxMesh.new()
	track_mesh.size = Vector3(1.0, 0.035, 0.1)
	track.mesh = track_mesh
	track.position = Vector3(0, 0.78, 0)
	var track_material := StandardMaterial3D.new()
	track_material.albedo_color = Color(0.13, 0.15, 0.2)
	track.material_override = track_material
	add_child(track)
	_progress_fill = MeshInstance3D.new()
	_progress_fill.name = "ConstructionProgressFill"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(0.9, 0.04, 0.1)
	_progress_fill.mesh = fill_mesh
	_progress_fill.position = Vector3(-0.45, 0.81, 0)
	_progress_fill.material_override = StandardMaterial3D.new()
	add_child(_progress_fill)


func _cancel_job_site() -> void:
	# The isolated job owns no delivered items. Future cancellation of
	# stocked sites must perform a guarded material recovery transaction.
	_reserved_belts.clear()
	queue_free()


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
	_placeholder_material = material
	add_child(mesh)
	if compact_blueprint_visuals:
		_build_compact_progress_bar()

	# Standalone conveyor plans must show their eventual cargo direction.
	# The local -Z axis matches the completed belt's OutputEndpoint; a
	# horizontal arrow makes rotation legible before the transport exists.
	if (
		is_instance_valid(target_definition)
		and target_definition.building_id == &"conveyor_belt"
	):
		var direction := Label3D.new()
		direction.name = "PlannedDirectionArrow"
		direction.text = "↑"
		direction.font_size = 48
		direction.pixel_size = 0.005
		direction.modulate = Color(1.0, 0.85, 0.2)
		direction.position = Vector3(0.0, 0.63, 0.0)
		direction.rotation.x = -PI * 0.5
		add_child(direction)

	var label := Label3D.new()
	label.name = "ConstructionLabel"
	label.text = "CONSTRUCTING 0%"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 1.0, 0.0)
	label.font_size = 28
	label.pixel_size = 0.008
	add_child(label)
	# Several neighboring belts otherwise overlay large "PLANNED 0%"
	# labels. Scale conveyor labels independently from building labels.
	if (
		is_instance_valid(target_definition)
		and target_definition.building_id == &"conveyor_belt"
	):
		label.font_size = 15
		label.pixel_size = 0.005
		label.position.y = 0.82
	if compact_blueprint_visuals:
		label.font_size = 18
		label.pixel_size = 0.004
		label.position.y = 0.98
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
	# Copy every direct building item port, including multi-input mergers
	# and multi-output splitters. Also copy both conveyor endpoints.
	# Marker geometry cannot expose inventory or activate transport.
	for child: Node in prototype.get_children():
		if not child is Marker3D:
			continue
		if not child is ItemPortComponent and child.name not in [
			&"InputEndpoint", &"OutputEndpoint"
		]:
			continue
		var marker := Marker3D.new()
		marker.name = "Planned" + str(child.name)
		marker.transform = (child as Marker3D).transform
		add_child(marker)
	prototype.free()


# =============================================================================
# VISUAL CONVEYOR TURN INTENT — NON-OPERATIONAL BLUEPRINTS
# =============================================================================
# This is presentation only. The physical conveyor is still instantiated as
# a straight scene and converted after BOTH endpoints complete by E2c1.
# Keeping the existing ConstructionSite and cargo lifecycle unchanged allows
# the player to see a proposed corner without transporting items early.

func set_planned_conveyor_turn(turn: int) -> bool:
	if not is_instance_valid(target_definition):
		return false
	if target_definition.building_id != &"conveyor_belt":
		return false
	if job == null or not accepts_planned_connections():
		return false
	if turn not in [
		ConveyorTurnIntent.Turn.RIGHT,
		ConveyorTurnIntent.Turn.LEFT
	]:
		return false
	if has_meta("planned_conveyor_turn"):
		return false

	var mesh := get_node_or_null("ConstructionPlaceholder") as MeshInstance3D
	var output := get_node_or_null("PlannedOutputEndpoint") as Marker3D
	var arrow := get_node_or_null("PlannedDirectionArrow") as Label3D
	if mesh == null or output == null or arrow == null:
		return false

	var corner_mesh := ConveyorCornerVisualMesh.build(turn)
	var corner_scene := ConveyorPieceSelector.get_scene_for_turn(turn)
	if corner_mesh == null or corner_scene == null:
		return false
	var prototype := corner_scene.instantiate() as ConveyorSegment
	if prototype == null:
		return false
	var corner_output := prototype.get_node_or_null("OutputEndpoint") as Marker3D
	if corner_output == null:
		prototype.free()
		return false

	# Retain the previous local transform for lossless cancellation.
	set_meta("planned_conveyor_straight_output", output.transform)
	set_meta("planned_conveyor_turn", turn)
	output.transform = corner_output.transform
	mesh.mesh = corner_mesh
	mesh.position.y = 0.3
	arrow.text = "↱" if turn == ConveyorTurnIntent.Turn.RIGHT else "↰"
	prototype.free()
	return true


func clear_planned_conveyor_turn() -> bool:
	if not has_meta("planned_conveyor_turn"):
		return false
	if not is_instance_valid(target_definition):
		return false
	if target_definition.building_id != &"conveyor_belt":
		return false
	if job == null or not accepts_planned_connections():
		return false

	var mesh := get_node_or_null("ConstructionPlaceholder") as MeshInstance3D
	var output := get_node_or_null("PlannedOutputEndpoint") as Marker3D
	var arrow := get_node_or_null("PlannedDirectionArrow") as Label3D
	if mesh == null or output == null or arrow == null:
		return false

	var straight_box := BoxMesh.new()
	straight_box.size = Vector3(float(footprint.x), 0.6, float(footprint.y))
	mesh.mesh = straight_box
	mesh.position.y = 0.3
	output.transform = get_meta("planned_conveyor_straight_output")
	arrow.text = "↑"
	remove_meta("planned_conveyor_turn")
	remove_meta("planned_conveyor_straight_output")
	return true


func get_planned_port_names(input_side: bool) -> Array[StringName]:
	var result: Array[StringName] = []
	for child: Node in get_children():
		if not child is Marker3D:
			continue
		var port_name := StringName(str(child.name).trim_prefix("Planned"))
		if not str(child.name).begins_with("Planned"):
			continue
		if input_side and str(port_name).begins_with("InputPort"):
			result.append(port_name)
		elif not input_side and str(port_name).begins_with("OutputPort"):
			result.append(port_name)
	return result


func get_planned_port_named(port_name: StringName) -> Marker3D:
	if not str(port_name).begins_with("InputPort") and not str(port_name).begins_with("OutputPort"):
		return null
	return get_node_or_null("Planned" + str(port_name)) as Marker3D


func get_planned_port(input_side: bool) -> Marker3D:
	return get_node_or_null(
		"PlannedInputPort" if input_side else "PlannedOutputPort"
	) as Marker3D


func accepts_planned_connections() -> bool:
	if job != null:
		return job.state in [
			ConstructionJob.State.PLANNED,
			ConstructionJob.State.QUEUED,
			ConstructionJob.State.CONSTRUCTING,
			ConstructionJob.State.PAUSED
		]
	return lifecycle.state == ConstructionLifecycle.State.CONSTRUCTING


func get_planned_belt_transform(
	belt: ConveyorSegment, input_side: bool
) -> Dictionary:
	return get_planned_belt_transform_named(
		belt, &"InputPort" if input_side else &"OutputPort"
	)


func get_planned_belt_transform_named(
	belt: ConveyorSegment, port_name: StringName
) -> Dictionary:
	if not is_instance_valid(belt) or not belt.is_inside_tree():
		return {}
	if not accepts_planned_connections():
		return {}
	var input_side := str(port_name).begins_with("InputPort")
	var marker := get_planned_port_named(port_name)
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
	if not accepts_planned_connections():
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
	if job != null:
		return job.get_progress()
	return lifecycle.get_progress()


func is_completed() -> bool:
	return is_instance_valid(_completed_building)


func _finish_construction() -> void:
	if is_queued_for_deletion() or is_completed():
		return
	if job != null and not job.is_complete():
		return
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
