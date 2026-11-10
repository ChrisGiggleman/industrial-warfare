extends Node


# =============================================================================
# CONSTANTS
# =============================================================================
# Physics collision masks used by the interaction system.
#
# Layer 1 = Ground / placement surfaces
# Layer 3 = Placement blockers

const GROUND_COLLISION_MASK: int = 1
const RESOURCE_NODE_COLLISION_MASK: int = 2
const PLACEMENT_BLOCKER_COLLISION_MASK: int = 4

# Placement preview settings that currently do not need Inspector adjustment.

const ROTATION_STEP_DEGREES: float = 90.0
const FULL_ROTATION_DEGREES: float = 360.0
const PLACEMENT_GHOST_ALPHA: float = 0.4

# =============================================================================
# MOUSE INTERACTION COLLISION MASK
# =============================================================================

# Layer 2 is used by selectable and demolishable objects.
# Layer 1 ground and Layer 3 placement blockers are excluded.

const SELECTION_COLLISION_MASK: int = 2

# =============================================================================
# EXPORTED SETTINGS
# =============================================================================
# References and values that can be adjusted from the Godot Inspector.

@export var camera: Camera3D

@export var build_hud_panel: Control
@export var build_hud: CanvasLayer

@export var production_debug_hud: ProductionDebugHUD

# Building definitions available to the construction system.
# Each definition contains the data describing a buildable structure.
@export var buildable_definitions: Array[BuildingDefinition] = []

# Opt-in construction integration. Disabled until the isolated placement
# regression passes; Main gameplay and existing test suites remain unchanged.
@export var enable_timed_storage_construction: bool = false
# Developer-only: enable planned belt snapping in the factory sandbox.
@export var enable_planned_storage_conveyor_snap: bool = false
@export_range(0.1, 120.0, 0.1) var storage_construction_seconds: float = 8.0

# Sandbox-only: building Blueprint Mode is isolated from Main.
# Debug availability is a test override, not generated electrical power,
# delivered materials or actual construction drones.
@export var enable_blueprint_planning: bool = false
@export var compact_blueprint_visuals: bool = false
@export var enable_blueprint_route_tool: bool = false
@export var blueprint_sandbox_debug_requirements: bool = false
# E2c2 sandbox opt-in. Main remains disconnected from planned belt routes.
@export var enable_connected_conveyor_blueprints: bool = false
# E3c2a opt-in: plan directed conveyor links to unfinished Storage ports.
# Off by default. The real power/material/worker systems are not bypassed.
@export var enable_connected_storage_blueprints: bool = false

# Legacy scene list retained temporarily while the placement system is
# migrated to BuildingDefinition resources.
# @export var buildable_scenes: Array[PackedScene] = []

@export var ray_length: float = 1000.0
@export var grid_size: float = 1.0

@export var valid_placement_color: Color = Color(0.0, 1.0, 0.0)
@export var invalid_placement_color: Color = Color(1.0, 0.0, 0.0)


# =============================================================================
# RUNTIME STATE
# =============================================================================
# Stores information that changes while the game is running.

# Normal selection state.
var selected_object: Node = null

# Build Mode state.
var placement_mode_active: bool = false
var blueprint_mode_active: bool = false
var _route_anchor: Dictionary = {}
var _blueprint_l_route_mode: bool = false
var _planned_route_coordinator: BlueprintConveyorRouteCoordinator = null
var selected_building_index: int = 0

# Player quick-build keys are assigned by stable building_id, not the
# selected definition's array index. The index remains the internal
# placement target to preserve all existing snapping algorithms.
var build_hotbar: BuildHotbarConfiguration = null

var current_placement_position: Vector3 = Vector3.ZERO
var placement_is_valid: bool = false
var placement_rotation_degrees: float = 0.0

# Placement ghost state.
var placement_ghost: Node3D = null
var ghost_material: StandardMaterial3D
var placement_ghost_collisions: Array[CollisionShape3D] = []

# =============================================================================
# CONVEYOR SNAP PREVIEW STATE
# =============================================================================

# =============================================================================
# BUILDING-OFFSET CORNER SNAP STATE
# =============================================================================

# Used when an existing conveyor sits off the normal
# grid because it is aligned to a building port.
#
# Preview only. Permanent connections are handled later.

var conveyor_corner_snap_source: ConveyorSegment = null

var conveyor_corner_snap_turn: int = (
	ConveyorTurnIntent.Turn.STRAIGHT
)

# =============================================================================
# AUTOMATIC MISSING CORNER PREVIEW STATE
# =============================================================================

# Holds a validated one-tile corner candidate.
# Empty means normal conveyor placement.
#
# No permanent conveyor is created during preview.

var missing_corner_preview: Dictionary = {}

# =============================================================================
# EXISTING RECEIVER CORNER PREVIEW STATE
# =============================================================================

var receiver_corner_preview: Dictionary = {}
var receiver_corner_preview_mesh: MeshInstance3D = null

# =============================================================================
# SOURCE-SIDE AUTO CORNER PREVIEW STATE
# =============================================================================
var source_corner_preview: Dictionary = {}
var source_corner_preview_mesh: MeshInstance3D = null

# =============================================================================
# EXISTING CONVEYOR TERMINAL CORNER INTO BUILDING
# =============================================================================

var terminal_corner_preview: Dictionary = {}
var terminal_corner_preview_mesh: MeshInstance3D = null

# =============================================================================
# FRACTIONAL AND OFFSET CONNECTOR PREVIEW
# =============================================================================

var gap_connector_preview: Dictionary = {}
var gap_connector_overlay: MeshInstance3D = null


# =============================================================================
# TWO-ENDED CONVEYOR BRIDGE SNAP STATE
# =============================================================================

# Valid only when a single ordinary straight segment physically fits
# between TWO existing free conveyor endpoints.
# Preview references are reset every frame and never create links.

var conveyor_bridge_source: ConveyorSegment = null
var conveyor_bridge_destination: ConveyorSegment = null

# Stores the placed conveyor currently providing a
# possible snap location for our placement ghost.
#
# This is preview state only.
# No permanent connections are established here.

var conveyor_snap_source: ConveyorSegment = null
# True when the new belt should connect into an existing input.
# False when the new belt should connect after an existing output.
#
# The next step will use this to establish the correct
# permanent connection when the player clicks.

var conveyor_snap_before: bool = false

# =============================================================================
# BUILDING PORT SNAP PREVIEW STATE
# =============================================================================

# Stores the building port currently offering a
# valid physical connection to the placement ghost.
#
# This is temporary preview state only.
# No permanent connection exists until placement
# is explicitly committed in a later step.

var conveyor_building_snap_port: ItemPortComponent = null
var planned_conveyor_preview: Dictionary = {}

# =============================================================================
# BUILDING-TO-CONVEYOR PLACEMENT SNAP STATE
# =============================================================================

# Stores the existing conveyor and building port
# selected for a potential building placement.
#
# This is preview state only.
# No physical connection is established yet.

var building_placement_snap_belt: ConveyorSegment = null

var building_placement_snap_port: ItemPortComponent = null

# =============================================================================
# ACTIVE CONVEYOR PREVIEW SCENE
# =============================================================================

# Tracks which conveyor scene the current ghost uses.
#
# Later, Build Mode will switch between:
# - Straight conveyor
# - Right 90-degree corner
# - Left 90-degree corner
#
# Null means there is no active conveyor preview.

var conveyor_preview_scene: PackedScene = null

# Keep snap discovery within the cursor's intended grid tile.
# A full one-tile range can steal the adjacent parallel lane.

const CONVEYOR_SNAP_SEARCH_RADIUS: float = 0.65

# Allow a half-tile port offset without grabbing another lane
# or a building's port one whole tile away.
const CONVEYOR_BUILDING_PORT_SEARCH_RADIUS: float = 0.65

# Demolition Tool state.
var demolition_mode_active: bool = false
var demolition_hover_target: Node = null


# =============================================================================
# INITIALIZATION
# =============================================================================
# Runs once when WorldInteraction enters the scene.
#
# Build Mode begins disabled, so the Build HUD starts hidden.

func _ready() -> void:
	build_hotbar = BuildHotbarConfiguration.new()
	build_hotbar.configure(buildable_definitions)
	build_hotbar.reset_to_default()

	# The route service exists only in the explicit Factory Testing Sandbox.
	# Existing physical conveyor placement remains on its original path.
	if enable_blueprint_planning and enable_connected_conveyor_blueprints:
		_planned_route_coordinator = BlueprintConveyorRouteCoordinator.new()
		_planned_route_coordinator.name = "BlueprintRouteCoordinator"
		_planned_route_coordinator.enable_storage_port_blueprints = (
			enable_connected_storage_blueprints
		)
		add_child(_planned_route_coordinator)

	if build_hud_panel != null:
		build_hud_panel.visible = false

	# BuildHUD is another child of Main and can enter _ready after this
	# controller. Sync after siblings are ready; direct selection and
	# edit calls also refresh the HUD immediately when it is ready.
	call_deferred("_sync_build_hotbar_hud")


# =============================================================================
# FRAME UPDATE
# =============================================================================
# Runs every rendered frame while Build Mode is active.
#
# Placement Tool:
#   Updates the building placement preview.
#
# Demolition Tool:
#   Updates the structure currently targeted for demolition.

func _process(_delta: float) -> void:
	if not placement_mode_active:
		return

	if demolition_mode_active:
		_update_demolition_hover()
	else:
		_update_placement_preview()


# =============================================================================
# INPUT HANDLING
# =============================================================================
# Handles interaction inputs.
#
# Normal Mode:
#   Left Click  = Select object
#   B           = Enter Build Mode
#
# Build / Placement Mode:
#   Left Click  = Place building
#   Right Click = Exit Build Mode
#   Delete      = Toggle Demolition Tool
#   1           = Select building slot 1
#   2           = Select building slot 2
#   R           = Rotate placement preview
#
# Demolition Tool:
#   Left Click  = Demolish player-built structure
#   Delete      = Return to Placement Tool
#   Right Click = Exit Build Mode

func _unhandled_input(event: InputEvent) -> void:
	if build_hud != null and build_hud.has_method("is_catalog_open"):
		if build_hud.call("is_catalog_open"):
			return

	if event.is_action_pressed("toggle_placement_mode"):
		_toggle_placement_mode()
		return

	if placement_mode_active:
		if event.is_action_pressed("secondary_action"):
			_toggle_placement_mode()
			return

		if event.is_action_pressed("demolish_selected"):
			_toggle_demolition_mode()
			return

		if demolition_mode_active:
			if event.is_action_pressed("primary_action"):
				_try_demolish_under_mouse()
				return

			return

		# =============================================================================
		# BLUEPRINT PLANNING — SANDBOX-ONLY KEYBOARD COMMANDS
		# =============================================================================
		# P switches normal placement vs. non-operational planning.
		# E authorizes the site under the pointer; X cancels it.
		if enable_blueprint_planning and event is InputEventKey:
			if event.pressed and not event.echo:
				var key: int = event.physical_keycode
				if key == KEY_P:
					_toggle_blueprint_mode()
					return
				if key == KEY_E:
					if event.ctrl_pressed:
						_authorize_all_blueprint_sites()
					else:
						_authorize_blueprint_site(_blueprint_site_under_mouse())
					return
				if key == KEY_X:
					_cancel_blueprint_site(_blueprint_site_under_mouse())
					return
				if (
					key == KEY_L
					and enable_blueprint_route_tool
					and blueprint_mode_active
					and _is_conveyor_selected()
				):
					_toggle_blueprint_l_route_mode()
					return

		# =============================================================================
		# PLAYER QUICK-BUILD KEYS — CONFIGURABLE 1–9
		# =============================================================================

		# The first five controls retain their InputMap actions. Later
		# slots keep the existing physical key behavior until the full
		# keybinding menu is introduced. The selected slot now resolves
		# by building_id, not by array position.
		for slot_index: int in range(BuildHotbarConfiguration.SLOT_COUNT):
			if slot_index < 5:
				var action := StringName(
					"select_building_" + str(slot_index + 1)
				)
				if event.is_action_pressed(action):
					_select_hotbar_slot(slot_index)
					return
			elif (
				event is InputEventKey
				and event.pressed
				and not event.echo
				and (
					event.physical_keycode == KEY_1 + slot_index
					or event.keycode == KEY_1 + slot_index
				)
			):
				_select_hotbar_slot(slot_index)
				return

		if event.is_action_pressed("rotate_placement"):
			_rotate_placement()
			return

		# =============================================================================
		# INSPECT CONVEYOR CORNER INTO BUILDING (H)
		# =============================================================================

		# Read-only diagnosis of the conveyor under the mouse and its
		# nearest building input. No connections are modified.
		if (
			_is_conveyor_selected()
			and event is InputEventKey
			and event.pressed
			and not event.echo
			and (
				event.physical_keycode == KEY_H
				or event.keycode == KEY_H
			)
		):
			_inspect_terminal_building_corner()
			return

		# =============================================================================
		# INSPECT EXISTING CONVEYOR JUNCTION
		# =============================================================================

		# J inspects nearby existing conveyor connections.
		# Only available with Conveyor Belt selected.
		# Does not modify the factory.

		if (
			_is_conveyor_selected()
			and event is InputEventKey
			and event.pressed
			and not event.echo
			and event.physical_keycode == KEY_J
		):
			_inspect_existing_conveyor_junction()
			return

		# =============================================================================
		# CONNECT EXISTING CONVEYOR JUNCTION (K)
		# =============================================================================

		# Available only in Build Mode with the Conveyor Belt selected.
		# This connects two existing belts; it does not place a new belt.
		# Keep the command before primary_action and the final return.

		if (
			_is_conveyor_selected()
			and event is InputEventKey
			and event.pressed
			and not event.echo
			and (
				event.physical_keycode == KEY_K
				or event.keycode == KEY_K
			)
		):
			print("K KEY DETECTED | Attempting junction connection")
			_connect_existing_conveyor_junction()
			return

		if event.is_action_pressed("primary_action"):
			if (
				enable_blueprint_route_tool
				and blueprint_mode_active
				and _is_conveyor_selected()
				and event is InputEventMouseButton
				and event.shift_pressed
			):
				_handle_blueprint_route_click()
			else:
				_try_place_object()
			return

		return

	if event.is_action_pressed("primary_action"):
		_select_under_mouse()


# =============================================================================
# INSPECT TERMINAL BUILDING CORNER UNDER CURSOR
# =============================================================================

func _inspect_terminal_building_corner() -> void:
	if not is_instance_valid(camera):
		return
	var screen_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(screen_position)
	var ray_direction: Vector3 = camera.project_ray_normal(screen_position)
	var query := PhysicsRayQueryParameters3D.create(
		ray_origin, ray_origin + ray_direction * ray_length
	)
	query.collision_mask = GROUND_COLLISION_MASK
	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)
	if result.is_empty():
		print("TERMINAL INSPECT | Cursor is not over ground.")
		return

	var hit: Vector3 = result["position"]
	var cursor_grid := Vector3(
		snappedf(hit.x, grid_size),
		hit.y,
		snappedf(hit.z, grid_size)
	)
	ConveyorTerminalBuildingCorner.inspect_at_cursor(
		get_tree(),
		get_viewport().world_3d,
		cursor_grid,
		PLACEMENT_BLOCKER_COLLISION_MASK,
		0.65
	)
	print(
		"TERMINAL INSPECT | Active preview: ",
		not terminal_corner_preview.is_empty(),
		" | placement valid: ", placement_is_valid
	)


# =============================================================================
# EXISTING CONVEYOR JUNCTION INSPECTION
# =============================================================================

# Finds a compatible connection near the mouse cursor.
# Uses the existing, tested endpoint-discovery helper.
#
# This is diagnostic only.
# No connection or corner conversion is committed.

func _inspect_existing_conveyor_junction() -> void:



	if not is_instance_valid(camera):
		print("JUNCTION DEBUG | Camera unavailable.")
		return

	# =============================================================================
	# FIND MOUSE POSITION ON FACTORY FLOOR
	# =============================================================================

	var mouse_position: Vector2 = (
		get_viewport().get_mouse_position()
	)

	var ray_origin: Vector3 = (
		camera.project_ray_origin(mouse_position)
	)

	var ray_direction: Vector3 = (
		camera.project_ray_normal(mouse_position)
	)

	var ray_end: Vector3 = (
		ray_origin + ray_direction * ray_length
	)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = GROUND_COLLISION_MASK

	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(
			query
		)
	)

	if hit.is_empty():
		print("JUNCTION DEBUG | No ground detected.")
		return

	# =============================================================================
	# FIND NEAREST COMPATIBLE EXISTING CONNECTION
	# =============================================================================

	var candidate: Dictionary = (
		ConveyorExistingEndpointFinder.find_nearest_candidate(
			get_tree(),
			hit["position"],
			1.25
		)
	)

	if candidate.is_empty():
		print(
			"JUNCTION DEBUG | No compatible free endpoints near ",
			hit["position"]
		)
		return

	# =============================================================================
	# REPORT CONNECTION TYPE
	# =============================================================================

	var source: ConveyorSegment = (
		candidate["source"] as ConveyorSegment
	)

	var receiver: ConveyorSegment = (
		candidate["receiver"] as ConveyorSegment
	)

	print(
		"JUNCTION FOUND | Source: ",
		source.name,
		" | Receiver: ",
		receiver.name,
		" | Mode: ",
		candidate["mode"],
		" | Turn: ",
		candidate["turn"],
		" | Position: ",
		candidate["junction"]
	)
# =============================================================================
# CONNECT EXISTING RECEIVER CORNER
# =============================================================================

# Temporary explicit construction command.
#
# Connects two existing lines without placing a new belt.
# Only receiver-side corner conversions are enabled here.
#
# Validates the physical junction and checks that the
# receiver tile contains no unrelated placement blockers.

func _connect_existing_conveyor_junction() -> void:

	if not is_instance_valid(camera):
		print("JUNCTION CONNECT | Camera unavailable.")
		return

	# =============================================================================
	# FIND MOUSE POSITION ON GROUND
	# =============================================================================

	var mouse_position: Vector2 = (
		get_viewport().get_mouse_position()
	)

	var ray_origin: Vector3 = (
		camera.project_ray_origin(mouse_position)
	)

	var ray_end: Vector3 = (
		ray_origin
		+ camera.project_ray_normal(mouse_position) * ray_length
	)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = GROUND_COLLISION_MASK

	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(
			query
		)
	)

	if hit.is_empty():
		print("JUNCTION CONNECT | No ground detected.")
		return

	# =============================================================================
	# DISCOVER COMPATIBLE EXISTING ENDPOINTS
	# =============================================================================

	var candidate: Dictionary = (
		ConveyorExistingEndpointFinder.find_nearest_candidate(
			get_tree(),
			hit["position"],
			1.25
		)
	)

	if candidate.is_empty():
		print("JUNCTION CONNECT | No compatible endpoints.")
		return

	# First integration supports receiver-side corners.
	# Direct and source-side connections will follow.

	if candidate.get("mode") != "convert_receiver":
		print(
			"JUNCTION CONNECT | Not enabled for mode: ",
			candidate.get("mode")
		)
		return

	var source: ConveyorSegment = (
		candidate["source"] as ConveyorSegment
	)

	var receiver: ConveyorSegment = (
		candidate["receiver"] as ConveyorSegment
	)

	if (
		not is_instance_valid(source)
		or not is_instance_valid(receiver)
	):
		print("JUNCTION CONNECT | Invalid conveyor.")
		return

	# =============================================================================
	# VALIDATE CORNER TILE CLEARANCE
	# =============================================================================

	# A converted corner occupies the receiving belt's tile.
	# Test a conservative square footprint against Layer 3.
	#
	# Exclude only the receiver's own existing collision body.
	# Other physical obstacles must still be rejected.

	var receiver_body: PhysicsBody3D = (
		receiver.get_node_or_null("ConveyorBody")
		as PhysicsBody3D
	)

	if not is_instance_valid(receiver_body):
		print("JUNCTION CONNECT | Receiver body missing.")
		return

	var clearance_shape := BoxShape3D.new()
	clearance_shape.size = Vector3(0.98, 0.2, 0.98)

	var shape_query := PhysicsShapeQueryParameters3D.new()
	shape_query.shape = clearance_shape
	shape_query.transform = (
		receiver.global_transform
		* Transform3D(
			Basis.IDENTITY,
			Vector3(0.0, 0.3, 0.0)
		)
	)
	shape_query.collision_mask = PLACEMENT_BLOCKER_COLLISION_MASK

	var exclusions: Array[RID] = [
		receiver_body.get_rid()
	]

	shape_query.exclude = exclusions

	var obstacles: Array[Dictionary] = (
		get_viewport().world_3d.direct_space_state.intersect_shape(
			shape_query,
			8
		)
	)

	if not obstacles.is_empty():
		print(
			"JUNCTION CONNECT | Receiver tile obstructed: ",
			obstacles[0].get("collider")
		)
		return

	# =============================================================================
	# COMMIT PERMANENT CONNECTION
	# =============================================================================

	# The shared manager revalidates the candidate.
	# The receiver conversion preserves downstream links
	# and existing item inventories.

	if ConveyorExistingConnection.try_connect_candidate(
		candidate
	):
		print(
			"JUNCTION CONNECTED | Source: ",
			source.name,
			" | Receiver: ",
			receiver.name,
			" | Turn: ",
			candidate["turn"]
		)
	else:
		print(
			"JUNCTION CONNECT FAILED | Geometry or state changed."
		)
# =============================================================================
# BUILD MODE TOGGLE
# =============================================================================
# Enables or disables Build Mode.
#
# Entering Build Mode:
#   - clears normal object selection
#   - creates the building placement ghost
#   - shows the Build HUD
#
# Leaving Build Mode:
#   - clears demolition state
#   - removes demolition hover feedback
#   - destroys the placement ghost
#   - hides the Build HUD

func _toggle_placement_mode() -> void:
	_route_anchor.clear()
	_blueprint_l_route_mode = false
	placement_mode_active = not placement_mode_active

	if placement_mode_active:
		_select_object(null)
		_create_placement_ghost()

		if build_hud_panel != null:
			build_hud_panel.visible = true

		_sync_build_hotbar_hud()

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", false)

		print("Placement mode enabled")

	else:
		demolition_mode_active = false
		blueprint_mode_active = false
		placement_is_valid = false

		_clear_demolition_hover()
		_destroy_placement_ghost()

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", false)

		if build_hud_panel != null:
			build_hud_panel.visible = false

		print("Placement mode disabled")

# =============================================================================
# SELECTED BUILDING DEFINITION
# =============================================================================

# Returns the BuildingDefinition currently selected for construction.
#
# Returns null when:
#   - the building-definition list is empty
#   - the selected index is outside the valid array range
#   - the selected definition is missing

func _get_selected_building_definition() -> BuildingDefinition:
	if buildable_definitions.is_empty():
		return null

	if selected_building_index < 0:
		return null

	if selected_building_index >= buildable_definitions.size():
		return null

	return buildable_definitions[selected_building_index]

# =============================================================================
# BUILD HOTBAR — CONFIGURABLE SHORTCUT ROUTING
# =============================================================================

# The hotbar slot chooses a stable building_id. Internally the old
# definition index remains the active placement selection so existing
# conveyor and factory snapping code needs no special-case changes.

func _find_definition_index(identity: StringName) -> int:
	for index: int in range(buildable_definitions.size()):
		var definition: BuildingDefinition = buildable_definitions[index]
		if is_instance_valid(definition) and definition.building_id == identity:
			return index
	return -1


func _select_hotbar_slot(slot_index: int) -> bool:
	if build_hotbar == null:
		return false
	var definition: BuildingDefinition = build_hotbar.get_definition(
		slot_index
	)
	if not is_instance_valid(definition):
		# Empty or locked keys are intentionally inert.
		return false

	var definition_index: int = _find_definition_index(
		definition.building_id
	)
	if definition_index < 0:
		return false

	_select_building(definition_index)
	return true


func assign_hotbar_slot(slot_index: int, identity: StringName) -> bool:
	if build_hotbar == null or not build_hotbar.assign(slot_index, identity):
		return false
	_on_hotbar_assignment_changed()
	return true


func clear_hotbar_slot(slot_index: int) -> bool:
	if build_hotbar == null or not build_hotbar.clear_slot(slot_index):
		return false
	_on_hotbar_assignment_changed()
	return true


func set_hotbar_unlocked(identity: StringName, allowed: bool) -> bool:
	if build_hotbar == null or not build_hotbar.set_unlocked(identity, allowed):
		return false
	_on_hotbar_assignment_changed()
	return true


func _on_hotbar_assignment_changed() -> void:
	# If the current building is no longer assigned, select the first
	# available shortcut or leave Build Mode without a placement ghost.
	var selected: BuildingDefinition = _get_selected_building_definition()
	var selected_id: StringName = &""
	if is_instance_valid(selected):
		selected_id = selected.building_id

	if (
		build_hotbar != null
		and build_hotbar.find_slot(selected_id) < 0
	):
		var replaced: bool = false
		for slot_index: int in range(BuildHotbarConfiguration.SLOT_COUNT):
			var next_definition := build_hotbar.get_definition(slot_index)
			if is_instance_valid(next_definition):
				_select_building(
					_find_definition_index(next_definition.building_id)
				)
				replaced = true
				break
		if not replaced:
			selected_building_index = -1
			if placement_mode_active:
				_destroy_placement_ghost()

	_sync_build_hotbar_hud()


func _sync_build_hotbar_hud() -> void:
	if not is_instance_valid(build_hud) or not build_hud.is_node_ready():
		return
	if build_hud.has_method("set_hotbar_controller"):
		build_hud.call("set_hotbar_controller", self)
	if build_hud.has_method("set_hotbar_configuration"):
		build_hud.call("set_hotbar_configuration", build_hotbar)

	var active_slot: int = -1
	var selected: BuildingDefinition = _get_selected_building_definition()
	if is_instance_valid(selected) and build_hotbar != null:
		active_slot = build_hotbar.find_slot(selected.building_id)

	if build_hud.has_method("set_selected_building"):
		build_hud.call("set_selected_building", active_slot)


# =============================================================================
# CONVEYOR TOOL — SELECTED BUILDING IDENTITY
# =============================================================================

# Conveyor snapping, corner placement, bridging and connection tools
# depend on this building's identity rather than the number key or
# its position in the buildable-definitions catalog.
#
# Keep selected_building_index as the active definition index during
# this migration; the customizable hotbar will map slots to definitions
# in its own separate milestone.

func _is_conveyor_selected() -> bool:
	var definition: BuildingDefinition = _get_selected_building_definition()
	return (
		is_instance_valid(definition)
		and definition.building_id == &"conveyor_belt"
	)


# =============================================================================
# SELECTED BUILDING SCENE
# =============================================================================
# Returns the PackedScene currently selected for construction.
#
# Returns null when:
#   - the building-definition list is empty
#   - the selected index is outside the valid array range

func _get_selected_building_scene() -> PackedScene:
	var selected_definition: BuildingDefinition = (
		_get_selected_building_definition()
	)

	if selected_definition == null:
		return null

	return selected_definition.building_scene


# =============================================================================
# BUILDING SELECTION
# =============================================================================
# Changes which building definition is selected for construction.
#
# Changing buildings:
#   - resets placement rotation to 0 degrees
#   - recreates the placement ghost when Build Mode is active
#   - updates the Build HUD selection highlight

func _select_building(index: int) -> void:
	if index < 0 or index >= buildable_definitions.size():
		return

	if buildable_definitions[index] == null:
		return

	if buildable_definitions[index].building_scene == null:
		return

	selected_building_index = index
	_route_anchor.clear()
	_blueprint_l_route_mode = false
	placement_rotation_degrees = 0.0

	if placement_mode_active and not demolition_mode_active:
		_create_placement_ghost()

	_sync_build_hotbar_hud()

	print(
		"Selected building: ",
		buildable_definitions[index].display_name
	)


# =============================================================================
# DEMOLITION MODE
# =============================================================================
# Toggles between the Placement Tool and Demolition Tool while Build Mode
# remains active.
#
# Entering Demolition Mode:
#   - removes the placement ghost
#   - invalidates placement
#   - changes the HUD to demolition controls
#
# Returning to Placement Mode:
#   - clears demolition hover feedback
#   - recreates the placement ghost
#   - restores the normal Build HUD

func _toggle_demolition_mode() -> void:
	demolition_mode_active = not demolition_mode_active

	if demolition_mode_active:
		blueprint_mode_active = false
		_route_anchor.clear()
		_blueprint_l_route_mode = false
		_clear_demolition_hover()
		_destroy_placement_ghost()
		placement_is_valid = false

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", true)

		print("Demolition mode enabled")

	else:
		_clear_demolition_hover()
		_create_placement_ghost()

		if build_hud != null and build_hud.has_method("set_demolition_mode"):
			build_hud.call("set_demolition_mode", false)

		print("Demolition mode disabled")


# =============================================================================
# DEMOLITION HOVER
# =============================================================================
# Finds the player-built structure currently underneath the mouse cursor.
#
# Valid demolition targets receive red hover feedback through their
# set_demolition_hover() method.

func _update_demolition_hover() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# =============================================================================
	# INTERACTIVE OBJECT RAYCAST SETTINGS
	# =============================================================================

	# Detect selectable objects on physics Layer 2.
	# Include both StaticBody3D and Area3D hitboxes.

	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	var new_target: Node = null

	if result:
		var collider: Node = result["collider"]
		var current_node: Node = collider

		while current_node != null:
			if (
				current_node.is_in_group("player_built")
				or current_node is WorldSalvageCache
			):
				new_target = current_node
				break

			current_node = current_node.get_parent()

	# No state change is needed if the mouse remains over the same object.
	if demolition_hover_target == new_target:
		return

	# Remove demolition feedback from the previous target.
	if demolition_hover_target != null:
		if is_instance_valid(demolition_hover_target):
			if demolition_hover_target.has_method("set_demolition_hover"):
				demolition_hover_target.call(
					"set_demolition_hover",
					false
				)

	demolition_hover_target = new_target

	# Apply demolition feedback to the new target.
	if demolition_hover_target != null:
		if demolition_hover_target.has_method("set_demolition_hover"):
			demolition_hover_target.call(
				"set_demolition_hover",
				true
			)


# =============================================================================
# DEMOLITION HOVER CLEANUP
# =============================================================================
# Removes demolition highlighting from the current hover target and clears
# the stored reference.

func _clear_demolition_hover() -> void:
	if demolition_hover_target != null:
		if is_instance_valid(demolition_hover_target):
			if demolition_hover_target.has_method("set_demolition_hover"):
				demolition_hover_target.call(
					"set_demolition_hover",
					false
				)

	demolition_hover_target = null


# =============================================================================
# DEMOLITION RAYCAST
# =============================================================================
# Casts a ray beneath the mouse cursor.
#
# The collider hierarchy is searched upward until a node in the
# "player_built" group is found.
#
# Objects that are selectable but not player-built remain protected.

func _try_demolish_under_mouse() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# =============================================================================
	# INTERACTIVE OBJECT RAYCAST SETTINGS
	# =============================================================================

	# Detect selectable objects on physics Layer 2.
	# Include both StaticBody3D and Area3D hitboxes.

	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	if result.is_empty():
		print("Nothing to demolish")
		return

	var collider: Node = result["collider"]
	var current_node: Node = collider

	
	while current_node != null:
		if current_node is WorldSalvageCache:
			_try_clear_salvage_cache(
				current_node as WorldSalvageCache
			)
			return

		if current_node.is_in_group("player_built"):

			# =============================================================================
			# PROTECT MERGER INVENTORIES BEFORE DEMOLITION
			# =============================================================================

			if (
				current_node.has_method("can_demolish_safely")
				and not bool(current_node.call("can_demolish_safely"))
			):
				print("Demolition blocked: Stored items must be recovered first.")
				return

			# =============================================================================
			# PROTECT CONVEYOR CARGO BEFORE DEMOLITION
			# =============================================================================

			# Prevent player demolition from destroying
			# resources currently stored on a conveyor.
			#
			# Other existing building demolition behavior
			# remains unchanged.

			if current_node is ConveyorSegment:

				var conveyor: ConveyorSegment = (
					current_node as ConveyorSegment
				)

				if not conveyor.can_demolish_safely():

					print(
						"Demolition blocked: Conveyor contains "
						+ "cargo or has an invalid cargo buffer."
					)

					return

			# =============================================================================
			# EXECUTE EXISTING DEMOLITION
			# =============================================================================

			print("Demolished ", current_node.name)

			if current_node == demolition_hover_target:
				demolition_hover_target = null

			current_node.queue_free()
			return

		current_node = current_node.get_parent()

	print("Target cannot be demolished")

# =============================================================================
# WRECKAGE CLEANUP — EMPTY CACHES ONLY
# =============================================================================

# Invoked by the normal demolition raycast when it hits wreckage.
# Never queue_free() a cache that still holds recovered resources.
# Salvage collection will get its own explicit player action later.

func _try_clear_salvage_cache(cache: WorldSalvageCache) -> bool:
	if not is_instance_valid(cache):
		return false
	if not cache.is_inside_tree():
		return false
	if not cache.is_in_group("salvage_caches"):
		return false
	if not cache.can_clear_safely():
		print(
			"Wreckage cleanup blocked: Recover stored materials first."
		)
		return false

	if selected_object == cache:
		_select_object(null)
	if demolition_hover_target == cache:
		demolition_hover_target = null

	cache.queue_free()
	print("Cleared empty wreckage")
	return true


# =============================================================================
# PLACEMENT ROTATION
# =============================================================================
# Rotates the active placement preview clockwise in 90-degree increments.
#
# Rotation cycles:
#   0 -> 90 -> 180 -> 270 -> 0

func _rotate_placement() -> void:
	placement_rotation_degrees += ROTATION_STEP_DEGREES

	if placement_rotation_degrees >= FULL_ROTATION_DEGREES:
		placement_rotation_degrees = 0.0

	if placement_ghost != null:
		placement_ghost.rotation_degrees.y = placement_rotation_degrees

	print(
		"Placement rotation: ",
		placement_rotation_degrees,
		" degrees"
	)


# =============================================================================
# OBJECT SELECTION RAYCAST
# =============================================================================
# Casts a ray from the mouse cursor into the 3D world.
#
# If the collider belongs to or exists underneath a node in the "selectable"
# group, that logical object becomes selected.
#
# Clicking non-selectable ground or empty space clears the current selection.

func _select_under_mouse() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# =============================================================================
	# INTERACTIVE OBJECT RAYCAST SETTINGS
	# =============================================================================

	# Detect selectable objects on physics Layer 2.
	# Include both StaticBody3D and Area3D hitboxes.

	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	if result:
		var hit_position: Vector3 = result["position"]
		var collider: Node = result["collider"]

		var current_node: Node = collider

		while current_node != null:
			if current_node.is_in_group("selectable"):
				_select_object(current_node)

				print(
					"Selected ",
					current_node.name,
					" at ",
					hit_position
				)

				return

			current_node = current_node.get_parent()

		_select_object(null)
		print("Hit ", collider.name, " at ", hit_position)

	else:
		_select_object(null)
		print("Hit nothing")


# =============================================================================
# OBJECT SELECTION STATE
# =============================================================================
# Changes the currently selected logical object.
#
# Selectable objects control their own visual feedback through the
# set_selected() method.

func _select_object(object: Node) -> void:
	if selected_object == object:
		return

	if selected_object != null:
		if selected_object.has_method("set_selected"):
			selected_object.call("set_selected", false)

	selected_object = object

	if selected_object != null:
		if selected_object.has_method("set_selected"):
			selected_object.call("set_selected", true)

		if production_debug_hud != null:
			production_debug_hud.set_selected_building(selected_object)
	else:
		if production_debug_hud != null:
			production_debug_hud.clear_selection()


# =============================================================================
# SELECT CONVEYOR PREVIEW SHAPE FROM MOUSE
# =============================================================================

# Finds the nearest placed conveyor with a free output.
#
# The mouse position determines whether to preview:
# - A straight conveyor
# - A right-turn corner
# - A left-turn corner
#
# This only selects a PackedScene.
# It never creates or connects a real conveyor.
#
# The 2-unit search radius is temporary and can be
# adjusted after we test the interaction in gameplay.

func _get_conveyor_preview_scene_for_mouse(
	mouse_world_position: Vector3
) -> PackedScene:

	var chosen_scene: PackedScene = (
		ConveyorPieceSelector.STRAIGHT_SCENE
	)

	var closest_distance_squared: float = 4.0

	# =============================================================================
	# SEARCH AVAILABLE CONVEYOR OUTPUTS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		var source: ConveyorSegment = node as ConveyorSegment

		if source.is_queued_for_deletion():
			continue

		# A completed connection cannot accept another
		# conveyor at the same output.

		if is_instance_valid(source.next_segment):
			continue

		var output: Marker3D = (
			source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		if not is_instance_valid(output):
			continue

		# =============================================================================
		# MEASURE HORIZONTAL MOUSE DISTANCE
		# =============================================================================

		var offset: Vector3 = (
			mouse_world_position - output.global_position
		)

		var distance_squared: float = (
			offset.x * offset.x
			+ offset.z * offset.z
		)

		if distance_squared >= closest_distance_squared:
			continue

		# =============================================================================
		# CLASSIFY CONSTRUCTION DIRECTION
		# =============================================================================

		var candidate_scene: PackedScene = (
			ConveyorPieceSelector.get_scene_for_mouse(
				source,
				mouse_world_position
			)
		)

		if candidate_scene == null:
			continue

		closest_distance_squared = distance_squared
		chosen_scene = candidate_scene

	# =============================================================================
	# RETURN SELECTED SHAPE
	# =============================================================================

	return chosen_scene

# =============================================================================
# PLACEMENT PREVIEW
# =============================================================================
# Projects the mouse onto Collision Layer 1 and snaps the resulting world
# position to the placement grid.
#
# The placement ghost:
#   - follows the snapped position
#   - turns green when placement is valid
#   - turns red when placement is blocked

# =============================================================================
# STRAIGHT CONVEYOR BLUEPRINT PREVIEW — SANDBOX PORT SNAPPING
# =============================================================================
# Storage snapping is opt-in. Manual direction checks remain available for
# regression tests; player previews can auto-orient to free future ports.
# Discovery never creates a live link.

func _get_storage_blueprint_snap_preview(
	mouse_world: Vector3, auto_orient: bool = false
) -> Dictionary:
	if not enable_blueprint_planning or not enable_connected_storage_blueprints:
		return {}
	if not blueprint_mode_active:
		return {}
	if not placement_ghost is ConveyorSegment:
		return {}
	if not is_instance_valid(_planned_route_coordinator):
		return {}
	var port_registry := _planned_route_coordinator.port_registry
	if not is_instance_valid(port_registry):
		return {}
	var proposed := BlueprintStoragePortSnapPreview.find_nearest(
		placement_ghost as ConveyorSegment,
		mouse_world,
		port_registry,
		0.65,
		auto_orient
	)
	if proposed.is_empty():
		return {}
	var definition := _get_selected_building_definition()
	if not is_instance_valid(definition):
		return {}
	var target: Transform3D = proposed["transform"]
	# Preview and final placement must use the same footprint validator.
	if not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d, definition,
		target, PLACEMENT_BLOCKER_COLLISION_MASK
	):
		return {}
	return proposed


func _update_straight_conveyor_blueprint_preview() -> void:
	placement_is_valid = false
	if not is_instance_valid(placement_ghost):
		return
	if not placement_ghost is ConveyorSegment:
		return
	var definition := _get_selected_building_definition()
	if not is_instance_valid(definition) or not is_instance_valid(camera):
		return

	var cursor: Vector2 = get_viewport().get_mouse_position()
	var ray_start: Vector3 = camera.project_ray_origin(cursor)
	var ray_end: Vector3 = (
		ray_start + camera.project_ray_normal(cursor) * ray_length
	)
	var ray := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	ray.collision_mask = GROUND_COLLISION_MASK
	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(ray)
	)
	if not hit.is_empty():
		var ground: Vector3 = hit["position"]
		current_placement_position = Vector3(
			snappedf(ground.x, grid_size),
			ground.y,
			snappedf(ground.z, grid_size)
		)
		placement_ghost.global_position = current_placement_position
		placement_ghost.rotation_degrees.y = placement_rotation_degrees

		# Resolve from the unsnapped cursor and orient the displayed ghost
		# to the free Storage port. R remains the manual rotation choice
		# when the cursor is away from an available port.
		var snapped: Dictionary = _get_storage_blueprint_snap_preview(
			ground, true
		)
		if not snapped.is_empty():
			var transform: Transform3D = snapped["transform"]
			placement_ghost.global_transform = transform
			current_placement_position = transform.origin

		placement_is_valid = ConveyorBlueprintPlacement.is_clear(
			get_tree(),
			get_viewport().world_3d,
			definition,
			placement_ghost.global_transform,
			PLACEMENT_BLOCKER_COLLISION_MASK
		)

	if ghost_material != null:
		var selected_color := (
			valid_placement_color if placement_is_valid else invalid_placement_color
		)
		ghost_material.albedo_color = Color(
			selected_color.r,
			selected_color.g,
			selected_color.b,
			PLACEMENT_GHOST_ALPHA
		)


func _update_placement_preview() -> void:
	# Sandbox blueprints use straight ghosts with optional planned Storage
	# port snapping. Live conveyor corner/bridge previews are unchanged.
	if (
		enable_blueprint_planning
		and blueprint_mode_active
		and _is_conveyor_selected()
	):
		_update_straight_conveyor_blueprint_preview()
		return

	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * ray_length

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	query.collision_mask = GROUND_COLLISION_MASK

	var result: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(query)
	)

	if result:
		var hit_position: Vector3 = result["position"]

		current_placement_position = Vector3(
			snappedf(hit_position.x, grid_size),
			hit_position.y,
			snappedf(hit_position.z, grid_size)
		)
		# =============================================================================
		# PRESERVE ORIGINAL MOUSE GRID POSITION
		# =============================================================================

		# Conveyor snapping may change the current
		# placement position during this frame.
		#
		# Compare competing snap targets against
		# the original cursor position instead.

		var mouse_grid_position: Vector3 = (
			current_placement_position
		)

		# =============================================================================
		# SHARED GRID FOR ALL BUILDING FOOTPRINTS
		# =============================================================================

		# Every building (Extractor, Storage, Smelter, Merger and future
		# buildings with footprint data) uses the same rotated footprint
		# parity convention. Only conveyors use grid-centered tiles.
		#
		# Use the ORIGINAL mouse hit before ordinary integer snapping.
		# Even tile counts use half-unit origins on that axis.

		if (
			is_instance_valid(placement_ghost)
			and not placement_ghost is ConveyorSegment
		):

			var grid_definition: BuildingDefinition = (
				_get_selected_building_definition()
			)

			if (
				grid_definition != null
				and grid_definition.footprint_tiles.x > 0
				and grid_definition.footprint_tiles.y > 0
			):

				# Convert the selected 90-degree rotation
				# into a number of quarter turns.

				var quarter_turns: int = roundi(
					placement_rotation_degrees
					/ ROTATION_STEP_DEGREES
				)

				var world_footprint: Vector2i = (
					FactoryGrid.rotated_footprint(
						grid_definition.footprint_tiles,
						quarter_turns
					)
				)

				current_placement_position = (
					FactoryGrid.snap_building_origin(
						hit_position,
						world_footprint,
						grid_size
					)
				)

		# =============================================================================
		# CONVEYOR PLACEMENT — STRAIGHT GHOST
		# =============================================================================

		# The player always previews a straight conveyor.
		#
		# A previously placed straight conveyor may later
		# convert into a corner when the player places a
		# new perpendicular straight conveyor beside it.
		#
		# The conversion happens during permanent placement,
		# not during ghost preview selection.



		# =============================================================================
		# EXISTING PLACEMENT GHOST POSITIONING
		# =============================================================================

		if placement_ghost != null:

			# =============================================================================
			# AUTOMATIC MISSING CORNER DISCOVERY
			# =============================================================================

			var corner_candidate: Dictionary = {}

			if (
				_is_conveyor_selected()
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):
				corner_candidate = (
					ConveyorMissingCornerPreview.find_nearest(
						get_tree(),
						mouse_grid_position,
						0.65
					)
				)

			if not corner_candidate.is_empty():

				var corner_turn: int = int(
					corner_candidate["turn"]
				)

				var corner_scene: PackedScene = (
					ConveyorPieceSelector.get_scene_for_turn(
						corner_turn
					)
				)

				var previous_turn: int = int(
					missing_corner_preview.get("turn", -1)
				)

				# Only recreate the ghost when the corner
				# type changes. Never recreate every frame.

				if (
					conveyor_preview_scene != corner_scene
					or previous_turn != corner_turn
				):
					_create_placement_ghost(corner_scene)

					var corner_mesh := (
						placement_ghost.get_node_or_null(
							"BeltMesh"
						) as MeshInstance3D
					)

					if corner_mesh != null:
						corner_mesh.mesh = (
							ConveyorCornerVisualMesh.build(
								corner_turn
							)
						)

				missing_corner_preview = corner_candidate

			else:

				# Restore our ordinary straight conveyor
				# when the mouse leaves the valid corner.

				if not missing_corner_preview.is_empty():
					_create_placement_ghost(
						ConveyorPieceSelector.STRAIGHT_SCENE
					)

				missing_corner_preview.clear()

			# =============================================================================
			# EXISTING STRAIGHT RECEIVER AUTO SNAP
			# =============================================================================

			var receiver_candidate: Dictionary = {}
			if (
				_is_conveyor_selected()
				and missing_corner_preview.is_empty()
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):
				receiver_candidate = (
					ConveyorReceiverCornerAutoSnap.find_nearest_preview(
						get_tree(),
						mouse_grid_position,
						0.65
					)
				)

			if not receiver_candidate.is_empty():
				_clear_source_corner_preview()
				if not _show_receiver_corner_preview(receiver_candidate):
					_clear_receiver_corner_preview()
			else:
				_clear_receiver_corner_preview()

			# =============================================================================
			# SOURCE CORNER DISCOVERY
			# =============================================================================
			var source_candidate: Dictionary = {}
			if (
				_is_conveyor_selected()
				and missing_corner_preview.is_empty()
				and receiver_corner_preview.is_empty()
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):
				source_candidate = (
					ConveyorSourceCornerAutoSnap.find_nearest_preview(
						get_tree(), mouse_grid_position, 0.65
					)
				)

			if not source_candidate.is_empty():
				if not _show_source_corner_preview(source_candidate):
					_clear_source_corner_preview()
			else:
				_clear_source_corner_preview()

			# =============================================================================
			# TERMINAL CORNER INTO AN EXISTING BUILDING INPUT
			# =============================================================================
			# Hover the last existing straight conveyor, not the
			# occupied building tile. Its output can bend into a
			# free, exactly aligned side input without placing a new belt.

			var terminal_candidate: Dictionary = {}
			if (
				_is_conveyor_selected()
				and missing_corner_preview.is_empty()
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):
				terminal_candidate = ConveyorTerminalBuildingCorner.find_nearest(
					get_tree(), mouse_grid_position, 0.65
				)

			if not terminal_candidate.is_empty():
				_clear_receiver_corner_preview()
				_clear_source_corner_preview()
				if not _show_terminal_corner_preview(terminal_candidate):
					_clear_terminal_corner_preview()
			else:
				_clear_terminal_corner_preview()

			# =============================================================================
			# CONNECT TWO FREE OFF-GRID ENDPOINTS
			# =============================================================================
			# One L-shaped connector for perpendicular free endpoints,
			# or one fractional straight for aligned free endpoints.
			# Never reinterpret a two-input merger as a simple corner.

			var gap_candidate: Dictionary = {}
			if (
				_is_conveyor_selected()
				and missing_corner_preview.is_empty()
				and receiver_corner_preview.is_empty()
				and source_corner_preview.is_empty()
				and terminal_corner_preview.is_empty()
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):
				gap_candidate = ConveyorOffsetCornerBridge.find_nearest_preview(
					get_tree(), mouse_grid_position, 0.65
				)
				if not gap_candidate.is_empty():
					gap_candidate["kind"] = "offset_corner"
				else:
					gap_candidate = ConveyorFractionalBridge.find_nearest_preview(
						get_tree(), mouse_grid_position, 0.65
					)
					if not gap_candidate.is_empty():
						gap_candidate["kind"] = "fractional_straight"

			if not gap_candidate.is_empty():
				if not _show_gap_connector_preview(gap_candidate):
					_clear_gap_connector_preview()
			else:
				_clear_gap_connector_preview()

			# =============================================================================
			# RESET NORMAL GRID PREVIEW
			# =============================================================================

			# Start each frame with the ordinary grid position.
			# This prevents the ghost from remaining snapped
			# after the mouse moves away.

			conveyor_snap_source = null
			conveyor_snap_before = false
			conveyor_building_snap_port = null
			planned_conveyor_preview.clear()
			building_placement_snap_belt = null
			building_placement_snap_port = null
			conveyor_corner_snap_source = null
			conveyor_corner_snap_turn = ConveyorTurnIntent.Turn.STRAIGHT
			conveyor_bridge_source = null
			conveyor_bridge_destination = null
			
			placement_ghost.global_position = (
				current_placement_position
			)

			placement_ghost.rotation_degrees.y = (
				placement_rotation_degrees
			)

			# =============================================================================
			# APPLY AUTOMATIC MISSING CORNER TRANSFORM
			# =============================================================================

			# Apply the detected corner transform LAST.
			# Otherwise normal player rotation can overwrite it.

			if not missing_corner_preview.is_empty():

				placement_ghost.global_transform = (
					missing_corner_preview["transform"]
				)

				current_placement_position = (
					placement_ghost.global_position
				)


			# =============================================================================
			# SELECT ONE CONVEYOR SNAP TARGET
			# =============================================================================

			# Always begin with the original grid position and player rotation.
			# Resolve only one physical target per frame:
			#   1. Exact two-ended conveyor bridge (if one piece fits)
			#   2. Compatible, free building port
			#   3. Compatible existing conveyor endpoint
			#   4. Off-grid perpendicular turn preview
			#
			# Never use an already-snapped ghost position as the mouse
			# position for the next discovery pass. All connections
			# are still committed only during permanent placement.

			
			if (
				placement_ghost is ConveyorSegment
				and missing_corner_preview.is_empty()
				and receiver_corner_preview.is_empty()
				and source_corner_preview.is_empty()
				and terminal_corner_preview.is_empty()
				and gap_connector_preview.is_empty()
				and not Input.is_physical_key_pressed(KEY_SHIFT)
			):


				var ghost_belt: ConveyorSegment = (
					placement_ghost as ConveyorSegment
				)

				# =============================================================================
				# FIRST: EXACT TWO-ENDED BRIDGE
				# =============================================================================

				# Only select a bridge when ONE unchanged straight conveyor
				# aligns with two free endpoints and the requested rotation.

				if conveyor_preview_scene == ConveyorPieceSelector.STRAIGHT_SCENE:

					var bridge_preview: Dictionary = (
						ConveyorDualEndedBridge.find_nearest_preview(
							ghost_belt,
							mouse_grid_position,
							CONVEYOR_SNAP_SEARCH_RADIUS
						)
					)

					if not bridge_preview.is_empty():

						conveyor_bridge_source = (
							bridge_preview["source"] as ConveyorSegment
						)

						conveyor_bridge_destination = (
							bridge_preview["destination"] as ConveyorSegment
						)

						placement_ghost.global_transform = (
							bridge_preview["transform"]
						)

						current_placement_position = (
							placement_ghost.global_position
						)

				# =============================================================================
				# SECOND: BUILDING PORT — INDEPENDENT IN / OUT
				# =============================================================================

				var port_preview: Dictionary = (
					ConveyorBuildingPortFinder.find_nearest_preview(
						ghost_belt,
						mouse_grid_position,
						CONVEYOR_BUILDING_PORT_SEARCH_RADIUS
					)
				)

				if (
					not is_instance_valid(conveyor_bridge_source)
					and not port_preview.is_empty()
				):

					var port: ItemPortComponent = (
						port_preview["port"] as ItemPortComponent
					)

					if is_instance_valid(port):

						placement_ghost.global_transform = (
							port_preview["transform"]
						)

						conveyor_building_snap_port = port
						current_placement_position = (
							placement_ghost.global_position
						)

				# =============================================================================
				# PLANNED STORAGE PORT — SANDBOX OPT-IN
				# =============================================================================

				if (
					enable_planned_storage_conveyor_snap
					and conveyor_preview_scene == ConveyorPieceSelector.STRAIGHT_SCENE
					and not is_instance_valid(conveyor_bridge_source)
					and not is_instance_valid(conveyor_building_snap_port)
				):
					planned_conveyor_preview = (
						PlannedConveyorPortFinder.find_nearest_preview(
							ghost_belt,
							hit_position,
							CONVEYOR_BUILDING_PORT_SEARCH_RADIUS
						)
					)
					if not planned_conveyor_preview.is_empty():
						placement_ghost.global_transform = (
							planned_conveyor_preview["transform"]
						)
						current_placement_position = placement_ghost.global_position

				# =============================================================================
				# THIRD: EXISTING CONVEYOR ENDPOINT
				# =============================================================================

				if (
					not is_instance_valid(conveyor_bridge_source)
					and not is_instance_valid(conveyor_building_snap_port)
					and planned_conveyor_preview.is_empty()
				):

					var belt_preview: Dictionary = (
						_find_conveyor_snap_preview(
							mouse_grid_position
						)
					)

					if not belt_preview.is_empty():

						placement_ghost.global_transform = (
							belt_preview["transform"]
						)

						conveyor_snap_source = (
							belt_preview["source"] as ConveyorSegment
						)

						conveyor_snap_before = bool(
							belt_preview["before"]
						)

						current_placement_position = (
							placement_ghost.global_position
						)

					# =============================================================================
					# FOURTH: OFF-GRID CORNER PREVIEW
					# =============================================================================

					else:

						var corner_preview: Dictionary = (
							_find_offset_corner_snap_preview(
								mouse_grid_position
							)
						)

						if not corner_preview.is_empty():

							placement_ghost.global_transform = (
								corner_preview["transform"]
							)

							conveyor_corner_snap_source = (
								corner_preview["source"] as ConveyorSegment
							)

							conveyor_corner_snap_turn = int(
								corner_preview["turn"]
							)

							current_placement_position = (
								placement_ghost.global_position
							)

			# =============================================================================
			# BUILDING PLACEMENT SNAP TO EXISTING CONVEYOR
			# =============================================================================

			# Only regular building ghosts use this path.
			#
			# Conveyor ghosts continue using their existing
			# conveyor-to-conveyor and building-port snapping.
			#
			# The existing helper discovers compatible ports,
			# checks occupied endpoints, and preserves the
			# player's selected building rotation.

			if (
				not placement_ghost is ConveyorSegment
				and not (
					enable_blueprint_planning and blueprint_mode_active
				)
			):

				var selected_footprint: Vector2i = Vector2i.ZERO
				var placement_definition: BuildingDefinition = (
					_get_selected_building_definition()
				)
				if placement_definition != null:
					selected_footprint = FactoryGrid.rotated_footprint(
						placement_definition.footprint_tiles,
						roundi(placement_rotation_degrees / ROTATION_STEP_DEGREES)
					)

				var building_preview: Dictionary = (
					ConveyorBuildingPlacementSnap.find_nearest_preview(
						placement_ghost,
						current_placement_position,
						0.65,
						selected_footprint
					)
				)

				if not building_preview.is_empty():

					var target_belt: ConveyorSegment = (
						building_preview["belt"]
						as ConveyorSegment
					)

					var target_port: ItemPortComponent = (
						building_preview["port"]
						as ItemPortComponent
					)

					if (
						is_instance_valid(target_belt)
						and is_instance_valid(target_port)
					):

						# Apply the exact preview transform.
						# This also supports fractional positions.

						placement_ghost.global_transform = (
							building_preview["transform"]
						)

						building_placement_snap_belt = target_belt
						building_placement_snap_port = target_port

						current_placement_position = (
							placement_ghost.global_position
						)

			# =============================================================================
			# EXISTING PLACEMENT COLLISION VALIDATION
			# =============================================================================

			if not terminal_corner_preview.is_empty():
				placement_is_valid = ConveyorTerminalBuildingCorner.is_clear(
					get_viewport().world_3d,
					terminal_corner_preview,
					PLACEMENT_BLOCKER_COLLISION_MASK
				)
			elif not receiver_corner_preview.is_empty():
				placement_is_valid = (
					ConveyorReceiverCornerBuildPreview.is_clear(
						get_viewport().world_3d,
						receiver_corner_preview,
						PLACEMENT_BLOCKER_COLLISION_MASK
					)
				)
			elif not source_corner_preview.is_empty():
				placement_is_valid = (
					ConveyorSourceCornerBuildPreview.is_clear(
						get_viewport().world_3d,
						source_corner_preview,
						PLACEMENT_BLOCKER_COLLISION_MASK
					)
				)
			elif not gap_connector_preview.is_empty():
				placement_is_valid = _is_gap_connector_clear(
					gap_connector_preview
				)
			else:
				placement_is_valid = _is_placement_clear()


		if placement_is_valid and placement_ghost != null:
			var extractor_component: ExtractorComponent = (
				placement_ghost.get_node_or_null("ExtractorComponent")
				as ExtractorComponent
			)

			if extractor_component != null:
				placement_is_valid = _extractor_has_resource_node()
	else:
		# Never retain a stale conversion candidate after the mouse leaves
		# the ground, or allow a click to commit it at an old location.
		_clear_receiver_corner_preview()
		_clear_source_corner_preview()
		_clear_terminal_corner_preview()
		_clear_gap_connector_preview()
		placement_is_valid = false

	if ghost_material != null:
		if placement_is_valid:
				ghost_material.albedo_color = Color(
					valid_placement_color.r,
					valid_placement_color.g,
					valid_placement_color.b,
					PLACEMENT_GHOST_ALPHA
			)
		else:
			ghost_material.albedo_color = Color(
				invalid_placement_color.r,
				invalid_placement_color.g,
				invalid_placement_color.b,
				PLACEMENT_GHOST_ALPHA
			)

	else:
		placement_is_valid = false


# =============================================================================
# FRACTIONAL AND OFFSET BRIDGE GHOST
# =============================================================================

func _clear_gap_connector_preview() -> void:
	if is_instance_valid(gap_connector_overlay):
		gap_connector_overlay.queue_free()
	gap_connector_overlay = null
	gap_connector_preview.clear()
	if (
		is_instance_valid(placement_ghost)
		and source_corner_preview.is_empty()
		and receiver_corner_preview.is_empty()
		and terminal_corner_preview.is_empty()
	):
		placement_ghost.visible = true


func _show_gap_connector_preview(candidate: Dictionary) -> bool:
	if not is_instance_valid(placement_ghost):
		return false

	# A single overlay is reused for stable candidates; the overlay
	# is NOT a conveyor and carries no inventory or physics connections.
	var kind: String = str(candidate.get("kind", ""))
	var mesh_resource: Mesh = null
	if kind == "offset_corner":
		mesh_resource = ConveyorOffsetCornerBridge.make_preview_mesh(candidate)
	elif kind == "fractional_straight":
		var box := BoxMesh.new()
		box.size = Vector3(0.8, 0.2, float(candidate["length"]))
		mesh_resource = box
	else:
		return false

	if mesh_resource == null:
		return false

	if (
		not is_instance_valid(gap_connector_overlay)
		or gap_connector_preview.get("kind") != kind
		or gap_connector_preview.get("source") != candidate.get("source")
		or gap_connector_preview.get("destination") != candidate.get("destination")
	):
		_clear_gap_connector_preview()
		gap_connector_overlay = MeshInstance3D.new()
		gap_connector_overlay.cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
		gap_connector_overlay.material_override = ghost_material
		get_tree().current_scene.add_child(gap_connector_overlay)

	gap_connector_overlay.mesh = mesh_resource
	gap_connector_overlay.global_transform = (
		(candidate["transform"] as Transform3D)
		* Transform3D(Basis.IDENTITY, Vector3(0.0, 0.3, 0.0))
	)
	gap_connector_preview = candidate
	placement_ghost.visible = false
	return true


func _is_gap_connector_clear(candidate: Dictionary) -> bool:
	match str(candidate.get("kind", "")):
		"offset_corner":
			return ConveyorOffsetCornerBridge.is_clear(
				get_viewport().world_3d,
				candidate,
				PLACEMENT_BLOCKER_COLLISION_MASK
			)
		"fractional_straight":
			return ConveyorFractionalBridge.is_clear(
				get_viewport().world_3d,
				candidate,
				PLACEMENT_BLOCKER_COLLISION_MASK
			)
	return false


# =============================================================================
# EXISTING CONVEYOR TERMINAL CORNER PREVIEW
# =============================================================================

func _clear_terminal_corner_preview() -> void:
	if is_instance_valid(terminal_corner_preview_mesh):
		terminal_corner_preview_mesh.queue_free()
	terminal_corner_preview_mesh = null
	terminal_corner_preview.clear()
	if (
		is_instance_valid(placement_ghost)
		and receiver_corner_preview.is_empty()
		and source_corner_preview.is_empty()
	):
		placement_ghost.visible = true


func _show_terminal_corner_preview(candidate: Dictionary) -> bool:
	if not is_instance_valid(placement_ghost):
		return false
	var belt: ConveyorSegment = candidate.get("belt") as ConveyorSegment
	var port: ItemPortComponent = candidate.get("port") as ItemPortComponent
	if not is_instance_valid(belt) or not is_instance_valid(port):
		return false
	var needs_overlay: bool = (
		not is_instance_valid(terminal_corner_preview_mesh)
		or terminal_corner_preview.get("belt") != belt
		or terminal_corner_preview.get("port") != port
		or int(terminal_corner_preview.get("turn", -1)) != int(candidate.get("turn", -1))
	)
	if needs_overlay:
		_clear_terminal_corner_preview()
		var overlay := ConveyorTerminalBuildingCorner.make_overlay(
			candidate, ghost_material
		)
		if overlay == null:
			return false
		var world_transform: Transform3D = overlay.transform
		get_tree().current_scene.add_child(overlay)
		overlay.global_transform = world_transform
		terminal_corner_preview_mesh = overlay
	terminal_corner_preview = candidate
	placement_ghost.visible = false
	return true


# =============================================================================
# EXISTING SOURCE CORNER VISUAL PREVIEW
# =============================================================================

func _clear_source_corner_preview() -> void:
	if is_instance_valid(source_corner_preview_mesh):
		source_corner_preview_mesh.queue_free()
	source_corner_preview_mesh = null
	source_corner_preview.clear()
	if (
		is_instance_valid(placement_ghost)
		and receiver_corner_preview.is_empty()
	):
		placement_ghost.visible = true


func _show_source_corner_preview(candidate: Dictionary) -> bool:
	if not is_instance_valid(placement_ghost):
		return false
	var source: ConveyorSegment = candidate.get("source") as ConveyorSegment
	if not is_instance_valid(source):
		return false
	var needs_overlay: bool = (
		not is_instance_valid(source_corner_preview_mesh)
		or source_corner_preview.get("source") != source
		or int(source_corner_preview.get("turn", -1)) != int(candidate.get("turn", -1))
	)
	if needs_overlay:
		_clear_source_corner_preview()
		var overlay: MeshInstance3D = (
			ConveyorSourceCornerBuildPreview.make_overlay(candidate, ghost_material)
		)
		if overlay == null:
			return false
		var saved_transform: Transform3D = overlay.transform
		get_tree().current_scene.add_child(overlay)
		overlay.global_transform = saved_transform
		source_corner_preview_mesh = overlay
	source_corner_preview = candidate
	placement_ghost.visible = false
	return true


# =============================================================================
# EXISTING RECEIVER CORNER VISUAL PREVIEW
# =============================================================================

# The real straight belt remains untouched until a click commits the link.
# The other conveyor placement rules are unchanged.

func _clear_receiver_corner_preview() -> void:
	if is_instance_valid(receiver_corner_preview_mesh):
		receiver_corner_preview_mesh.queue_free()
	receiver_corner_preview_mesh = null
	receiver_corner_preview.clear()
	if (
		is_instance_valid(placement_ghost)
		and source_corner_preview.is_empty()
	):
		placement_ghost.visible = true


func _show_receiver_corner_preview(candidate: Dictionary) -> bool:
	if not is_instance_valid(placement_ghost):
		return false

	var receiver: ConveyorSegment = candidate.get("receiver") as ConveyorSegment
	if not is_instance_valid(receiver):
		return false

	var needs_overlay: bool = (
		not is_instance_valid(receiver_corner_preview_mesh)
		or receiver_corner_preview.get("receiver") != receiver
		or int(receiver_corner_preview.get("turn", -1)) != int(candidate.get("turn", -1))
	)

	if needs_overlay:
		_clear_receiver_corner_preview()
		var overlay: MeshInstance3D = (
			ConveyorReceiverCornerBuildPreview.make_overlay(
				candidate, ghost_material
			)
		)
		if overlay == null:
			return false

		var world_transform: Transform3D = overlay.transform
		get_tree().current_scene.add_child(overlay)
		overlay.global_transform = world_transform
		receiver_corner_preview_mesh = overlay

	receiver_corner_preview = candidate
	placement_ghost.visible = false
	return true


# =============================================================================
# FIND NEARBY CONVEYOR SNAP PREVIEW
# =============================================================================

# Searches for available conveyor inputs AND outputs.
#
# Supports:
# - Placing a conveyor AFTER an existing output.
# - Placing a conveyor BEFORE an existing input.
#
# Chooses the nearest valid position to the mouse.
#
# This function only calculates preview transforms.
# It never establishes permanent connections.

func _find_conveyor_snap_preview(
	grid_position: Vector3
) -> Dictionary:

	if not placement_ghost is ConveyorSegment:
		return {}

	var ghost_belt: ConveyorSegment = (
		placement_ghost as ConveyorSegment
	)

	# =============================================================================
	# PRESERVE PLAYER-SELECTED CONVEYOR DIRECTION
	# =============================================================================

	# Record the actual direction selected with R.
	# Snapping must not silently override this rotation.

	var requested_forward: Vector3 = (
		ghost_belt.global_transform.basis
		* Vector3.FORWARD
	).normalized()

	var best_preview: Dictionary = {}
	var best_distance: float = CONVEYOR_SNAP_SEARCH_RADIUS

	# =============================================================================
	# SEARCH EXISTING CONVEYORS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if node == placement_ghost:
			continue

		if not node is ConveyorSegment:
			continue

		var source: ConveyorSegment = node as ConveyorSegment

		if source.is_queued_for_deletion():
			continue

		# =============================================================================
		# OPTION A — SNAP AFTER AN EXISTING CONVEYOR
		# =============================================================================

		var after_preview: Dictionary = (
			ghost_belt.get_snap_preview_transform_after(source)
		)

		# =============================================================================
		# REJECT SNAP THAT OVERRIDES SELECTED ROTATION
		# =============================================================================

		if not after_preview.is_empty():

			var proposed_after: Transform3D = (
				after_preview["transform"]
			)

			var after_forward: Vector3 = (
				proposed_after.basis * Vector3.FORWARD
			).normalized()

			if requested_forward.dot(after_forward) < 0.98:
				after_preview.clear()

		if not after_preview.is_empty():

			var after_transform: Transform3D = (
				after_preview["transform"]
			)

			var after_position: Vector3 = (
				after_transform.origin
			)

			var after_distance: float = Vector2(
				grid_position.x - after_position.x,
				grid_position.z - after_position.z
			).length()

			if after_distance < best_distance:

				best_distance = after_distance

				best_preview = {
					"source": source,
					"transform": after_transform,
					"before": false
				}

		# =============================================================================
		# OPTION B — SNAP BEFORE AN EXISTING CONVEYOR
		# =============================================================================

		var before_preview: Dictionary = (
			ghost_belt.get_snap_preview_transform_before(source)
		)

		# =============================================================================
		# PRESERVE SELECTED ROTATION FOR SNAP-BEFORE
		# =============================================================================

		if not before_preview.is_empty():

			var proposed_before: Transform3D = (
				before_preview["transform"]
			)

			var before_forward: Vector3 = (
				proposed_before.basis * Vector3.FORWARD
			).normalized()

			if requested_forward.dot(before_forward) < 0.98:
				before_preview.clear()

		if not before_preview.is_empty():

			var before_transform: Transform3D = (
				before_preview["transform"]
			)

			var before_position: Vector3 = (
				before_transform.origin
			)

			var before_distance: float = Vector2(
				grid_position.x - before_position.x,
				grid_position.z - before_position.z
			).length()

			if before_distance < best_distance:

				best_distance = before_distance

				best_preview = {
					"source": source,
					"transform": before_transform,
					"before": true
				}

	# =============================================================================
	# RETURN NEAREST VALID SNAP CANDIDATE
	# =============================================================================

	return best_preview


# =============================================================================
# PLACEMENT VALIDITY CHECK
# =============================================================================

# Checks the placement ghost's physical building collision shapes against
# objects on Collision Layer 3.
#
# Because each query uses the ghost collision shape's global transform,
# the validity test automatically respects:
#   - building size
#   - building footprint
#   - placement rotation


func _is_placement_clear() -> bool:

	# =============================================================================
	# VALIDATE PLACEMENT FOOTPRINT
	# =============================================================================

	if placement_ghost_collisions.is_empty():
		return false

	# =============================================================================
	# VALIDATE INTENDED CONVEYOR CONNECTION
	# =============================================================================

	# A conveyor being snapped may register a collision
	# with its intended neighbor due to contact tolerances.
	#
	# We may exclude that ONE neighbor from the placement
	# query, but only when the endpoints align correctly.
	#
	# Other buildings and conveyors must still block placement.

	var snap_exclusions: Array[RID] = []

	# =============================================================================
	# VALIDATE MISSING CORNER PLACEMENT
	# =============================================================================

	if not missing_corner_preview.is_empty():

		if not placement_ghost is ConveyorSegment:
			return false

		var corner_source: ConveyorSegment = (
			missing_corner_preview.get("source") as ConveyorSegment
		)

		var corner_destination: ConveyorSegment = (
			missing_corner_preview.get("destination") as ConveyorSegment
		)

		if (
			not is_instance_valid(corner_source)
			or not is_instance_valid(corner_destination)
		):
			return false

		var corner_turn: int = int(
			missing_corner_preview.get("turn", -1)
		)

		# Revalidate endpoints and the exact proposed transform.

		var fresh_corner: Dictionary = (
			ConveyorMissingCornerPreview.preview_for_pair(
				corner_source,
				corner_destination,
				corner_turn
			)
		)

		if fresh_corner.is_empty():
			return false

		var expected_corner: Transform3D = (
			fresh_corner["transform"]
		)

		if not placement_ghost.global_transform.is_equal_approx(
			expected_corner
		):
			return false

		var source_output := (
			corner_source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		var ghost_input := (
			placement_ghost.get_node_or_null("InputEndpoint")
			as Marker3D
		)

		var ghost_output := (
			placement_ghost.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		var destination_input := (
			corner_destination.get_node_or_null("InputEndpoint")
			as Marker3D
		)

		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			source_output,
			ghost_input,
			ConveyorSegment.CONNECTION_GAP
		):
			return false

		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			ghost_output,
			destination_input,
			ConveyorSegment.CONNECTION_GAP
		):
			return false

		# Both intended neighbors are verified.
		# Exclude only their collision bodies.
		# All unrelated obstacles must still block placement.

		for neighbor: ConveyorSegment in [
			corner_source,
			corner_destination
		]:

			var neighbor_body := (
				neighbor.get_node_or_null("ConveyorBody")
				as PhysicsBody3D
			)

			if not is_instance_valid(neighbor_body):
				return false

			snap_exclusions.append(
				neighbor_body.get_rid()
			)

	# =============================================================================
	# VERIFY BOTH INTENDED NEIGHBORS OF A TWO-ENDED BRIDGE
	# =============================================================================

	if (
		is_instance_valid(conveyor_bridge_source)
		and is_instance_valid(conveyor_bridge_destination)
	):

		if not placement_ghost is ConveyorSegment:
			return false

		var bridge_ghost: ConveyorSegment = (
			placement_ghost as ConveyorSegment
		)

		var verified_bridge: Dictionary = (
			ConveyorDualEndedBridge.get_preview_transform(
				conveyor_bridge_source,
				bridge_ghost,
				conveyor_bridge_destination
			)
		)

		if verified_bridge.is_empty():
			return false

		var expected_bridge: Transform3D = (
			verified_bridge["transform"]
		)

		if not bridge_ghost.global_transform.is_equal_approx(
			expected_bridge
		):
			return false

		# Connection helpers require exact directed endpoint geometry.
		# Exclude ONLY these two physical neighbors, and only after
		# both pairs have been independently revalidated.

		var source_output: Marker3D = (
			conveyor_bridge_source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		var bridge_input: Marker3D = (
			bridge_ghost.get_node_or_null("InputEndpoint")
			as Marker3D
		)

		var bridge_output: Marker3D = (
			bridge_ghost.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		var destination_input: Marker3D = (
			conveyor_bridge_destination.get_node_or_null("InputEndpoint")
			as Marker3D
		)

		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			source_output,
			bridge_input,
			ConveyorSegment.CONNECTION_GAP
		):
			return false

		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			bridge_output,
			destination_input,
			ConveyorSegment.CONNECTION_GAP
		):
			return false

		for neighbor: ConveyorSegment in [
			conveyor_bridge_source,
			conveyor_bridge_destination
		]:

			var neighbor_body: PhysicsBody3D = (
				neighbor.get_node_or_null("ConveyorBody")
				as PhysicsBody3D
			)

			if not is_instance_valid(neighbor_body):
				return false

			snap_exclusions.append(neighbor_body.get_rid())

	if (
		placement_ghost is ConveyorSegment
		and is_instance_valid(conveyor_snap_source)
	):

		var outgoing: Marker3D = null
		var incoming: Marker3D = null

		# Determine the directed connection.

		if conveyor_snap_before:

			# New belt output -> Existing belt input.

			outgoing = (
				placement_ghost.get_node_or_null("OutputEndpoint")
				as Marker3D
			)

			incoming = (
				conveyor_snap_source.get_node_or_null("InputEndpoint")
				as Marker3D
			)

		else:

			# Existing belt output -> New belt input.

			outgoing = (
				conveyor_snap_source.get_node_or_null("OutputEndpoint")
				as Marker3D
			)

			incoming = (
				placement_ghost.get_node_or_null("InputEndpoint")
				as Marker3D
			)

		# Only allow an exclusion if connection geometry
		# meets our strict established-link tolerance.

		if LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing,
			incoming,
			ConveyorSegment.CONNECTION_GAP
		):

			var neighbor_body: PhysicsBody3D = (
				conveyor_snap_source.get_node_or_null("ConveyorBody")
				as PhysicsBody3D
			)

			if is_instance_valid(neighbor_body):
				snap_exclusions.append(
					neighbor_body.get_rid()
				)

	# Planned Storage snap may touch only its intended construction site.
	# Revalidate exact transform and directed endpoint geometry before
	# excluding that one reserved footprint body from collision queries.
	if not planned_conveyor_preview.is_empty():
		if not enable_planned_storage_conveyor_snap:
			return false
		if not placement_ghost is ConveyorSegment:
			return false
		var site := planned_conveyor_preview.get("site") as ConstructionSite
		if not is_instance_valid(site) or site.is_queued_for_deletion():
			return false
		var input_side: bool = bool(planned_conveyor_preview.get("input_side", true))
		var fresh := site.get_planned_belt_transform(
			placement_ghost as ConveyorSegment, input_side
		)
		if fresh.is_empty():
			return false
		if not placement_ghost.global_transform.is_equal_approx(
			fresh["transform"]
		):
			return false
		if is_instance_valid(site.get_reserved_conveyor(input_side)):
			return false
		var marker := site.get_planned_port(input_side)
		var endpoint := placement_ghost.get_node_or_null(
			"OutputEndpoint" if input_side else "InputEndpoint"
		) as Marker3D
		var outgoing: Marker3D = endpoint if input_side else marker
		var incoming: Marker3D = marker if input_side else endpoint
		if not LogisticsConnectionGeometry.are_endpoints_aligned(
			outgoing, incoming, ConveyorSegment.CONNECTION_GAP
		):
			return false
		var reserved_body := site.get_node_or_null(
			"ReservedFootprint"
		) as PhysicsBody3D
		if not is_instance_valid(reserved_body):
			return false
		snap_exclusions.append(reserved_body.get_rid())

	# =============================================================================
	# CHECK PLACEMENT COLLISIONS
	# =============================================================================

	for collision_shape: CollisionShape3D in placement_ghost_collisions:

		if collision_shape.shape == null:
			continue

		var query := PhysicsShapeQueryParameters3D.new()

		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform
		query.collision_mask = PLACEMENT_BLOCKER_COLLISION_MASK

		# Ignore only a confirmed connection neighbor.
		# All unrelated obstacles remain detectable.

		query.exclude = snap_exclusions

		var results: Array[Dictionary] = (
			get_viewport().world_3d.direct_space_state.intersect_shape(
				query,
				1
			)
		)

		if not results.is_empty():
			return false

	# =============================================================================
	# PLACEMENT IS CLEAR
	# =============================================================================

	return true


# =============================================================================
# EXTRACTOR RESOURCE CHECK
# =============================================================================

# Returns true when the current extractor placement ghost can reach
# at least one valid resource node through its ExtractionArea.

func _extractor_has_resource_node() -> bool:
	if placement_ghost == null:
		return false

	var extractor_component: ExtractorComponent = (
		placement_ghost.get_node_or_null("ExtractorComponent")
		as ExtractorComponent
	)

	if extractor_component == null:
		return false

	if extractor_component.extraction_area == null:
		return false

	for child in extractor_component.extraction_area.find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	):
		if not child is CollisionShape3D:
			continue

		var collision_shape: CollisionShape3D = child as CollisionShape3D

		if collision_shape.shape == null:
			continue

		var query := PhysicsShapeQueryParameters3D.new()

		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform
		query.collision_mask = RESOURCE_NODE_COLLISION_MASK

		var results: Array[Dictionary] = (
			get_viewport().world_3d.direct_space_state.intersect_shape(
				query,
				32
			)
		)

		for result in results:
			var collider: Node = result["collider"] as Node

			if collider == null:
				continue

			var current_node: Node = collider

			while current_node != null:
				var resource_runtime: ResourceNodeRuntime = (
					current_node.get_node_or_null("ResourceNodeRuntime")
					as ResourceNodeRuntime
				)

				if resource_runtime != null:
					return true

				current_node = current_node.get_parent()

	return false

# =============================================================================
# FIND BUILDING-OFFSET CONVEYOR CORNER SNAP
# =============================================================================

# Searches for a conveyor with a free output that is
# positioned off-grid because of building-port snapping.
#
# The receiver is our current placement ghost.
#
# Only calculates positions. Does not change connections.


func _find_offset_corner_snap_preview(
	mouse_grid_position: Vector3
) -> Dictionary:

	# =============================================================================
	# VALIDATE CONVEYOR GHOST
	# =============================================================================

	if not placement_ghost is ConveyorSegment:
		return {}

	var receiver: ConveyorSegment = (
		placement_ghost as ConveyorSegment
	)

	var best_preview: Dictionary = {}

	var closest_distance_squared: float = (
		CONVEYOR_SNAP_SEARCH_RADIUS
		* CONVEYOR_SNAP_SEARCH_RADIUS
	)

	# =============================================================================
	# SEARCH EXISTING CONVEYORS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		if node == placement_ghost:
			continue

		var source: ConveyorSegment = (
			node as ConveyorSegment
		)

		if source.is_queued_for_deletion():
			continue

		# An occupied output cannot create another route.

		if is_instance_valid(source.next_segment):
			continue

		if is_instance_valid(source.output_building_port):
			continue

		# =============================================================================
		# RESTRICT TO OFF-GRID CONVEYORS
		# =============================================================================

		# Normal grid-aligned conveyors already have
		# working corner placement logic.
		#
		# Preserve that behavior unchanged.

		var off_grid_x: bool = absf(
			source.global_position.x
			- snappedf(source.global_position.x, grid_size)
		) > 0.05

		var off_grid_z: bool = absf(
			source.global_position.z
			- snappedf(source.global_position.z, grid_size)
		) > 0.05

		if not off_grid_x and not off_grid_z:
			continue

		# =============================================================================
		# CHECK BOTH TURN DIRECTIONS
		# =============================================================================

		for turn_type: int in [
			ConveyorTurnIntent.Turn.RIGHT,
			ConveyorTurnIntent.Turn.LEFT
		]:

			var preview: Dictionary = (
				ConveyorCornerPlacementSnap.get_preview_transform(
					source,
					receiver,
					turn_type
				)
			)

			if preview.is_empty():
				continue

			var proposed: Transform3D = (
				preview["transform"]
			)

			# =============================================================================
			# MEASURE DISTANCE TO MOUSE
			# =============================================================================

			var offset := Vector2(
				mouse_grid_position.x - proposed.origin.x,
				mouse_grid_position.z - proposed.origin.z
			)

			var distance_squared: float = (
				offset.length_squared()
			)

			if distance_squared >= closest_distance_squared:
				continue

			# =============================================================================
			# STORE NEAREST VALID CORNER
			# =============================================================================

			closest_distance_squared = distance_squared

			best_preview = {
				"source": source,
				"turn": turn_type,
				"transform": proposed
			}

	return best_preview

# =============================================================================
# FIND PERPENDICULAR CONVEYOR TURN CANDIDATE
# =============================================================================

# Finds an existing straight conveyor whose free output
# can turn into a newly placed perpendicular straight.
#
# Requirements:
# - Both conveyors occupy neighboring grid cells.
# - The new conveyor faces right or left relative to source.
# - The existing conveyor has no outgoing connection.
# - The existing conveyor has not already become a corner.
#
# This function does not modify or connect anything.
# It returns an empty Dictionary when no match exists.

func _find_perpendicular_corner_candidate(
	placed_straight: ConveyorSegment
) -> Dictionary:

	if not is_instance_valid(placed_straight):
		return {}

	var receiver_output: Marker3D = (
		placed_straight.get_node_or_null("OutputEndpoint")
		as Marker3D
	)

	if receiver_output == null:
		return {}

	# The new piece must be an ordinary straight belt.

	if not receiver_output.position.is_equal_approx(
		Vector3(0.0, 0.5, -0.5)
	):
		return {}

	# =============================================================================
	# SEARCH EXISTING PLAYER CONVEYORS
	# =============================================================================

	for node: Node in get_tree().get_nodes_in_group(
		"player_built"
	):

		if not node is ConveyorSegment:
			continue

		if node == placed_straight or node == placement_ghost:
			continue

		var source: ConveyorSegment = node as ConveyorSegment

		if source.is_queued_for_deletion():
			continue

		if is_instance_valid(source.next_segment):
			continue

		var source_output: Marker3D = (
			source.get_node_or_null("OutputEndpoint")
			as Marker3D
		)

		if source_output == null:
			continue

		# Only an existing straight may be converted.

		if not source_output.position.is_equal_approx(
			Vector3(0.0, 0.5, -0.5)
		):
			continue

		# =============================================================================
		# CHECK NEIGHBORING GRID POSITION
		# =============================================================================

		# Convert the new belt's world position into
		# the existing belt's local coordinate system.
		#
		# This makes the check work with rotated factories.

		var local_offset: Vector3 = (
			source.global_transform.affine_inverse()
			* placed_straight.global_position
		)

		# Both pieces must occupy the same ground level
		# and the same local Z row.

		if absf(local_offset.y) > 0.1:
			continue

		if absf(local_offset.z) > 0.1:
			continue

		# =============================================================================
		# DETERMINE LEFT OR RIGHT TURN
		# =============================================================================

		var turn: int = -1
		var expected_direction: Vector3 = Vector3.ZERO

		var source_right: Vector3 = (
			source.global_transform.basis.x.normalized()
		)

		if absf(local_offset.x - 1.0) < 0.1:
			turn = ConveyorTurnIntent.Turn.RIGHT
			expected_direction = source_right

		elif absf(local_offset.x + 1.0) < 0.1:
			turn = ConveyorTurnIntent.Turn.LEFT
			expected_direction = -source_right

		else:
			continue

		# =============================================================================
		# VERIFY NEW BELT FACING
		# =============================================================================

		# A neighboring belt is not automatically a turn.
		# The player must rotate it to face away from
		# the preceding conveyor in the correct direction.

		var receiver_forward: Vector3 = (
			-receiver_output.global_transform.basis.z
		).normalized()

		if receiver_forward.dot(expected_direction) < 0.98:
			continue

		# =============================================================================
		# VALID CORNER CANDIDATE
		# =============================================================================

		return {
			"source": source,
			"turn": turn
		}

	return {}


# =============================================================================
# OBJECT PLACEMENT
# =============================================================================
# Instantiates the currently selected PackedScene at the current snapped
# placement position.
#
# Placement is refused when:
#   - the current footprint is blocked
#   - no valid buildable scene is selected


# =============================================================================
# BLUEPRINT PLANNING — SANDBOX BUILDINGS AND CONNECTED STRAIGHT BELT PLANS
# =============================================================================
# A plan is a non-operational ConstructionSite whose ConstructionJob remains
# PLANNED until explicitly authorized. All controls are disabled in Main.
# Connected blueprints are opt-in; the validated E2b/E2c1 services own
# pending route claims and physical links only after construction.

func _toggle_blueprint_mode() -> bool:
	_route_anchor.clear()
	_blueprint_l_route_mode = false
	if not enable_blueprint_planning or not placement_mode_active:
		return false
	if demolition_mode_active:
		return false
	blueprint_mode_active = not blueprint_mode_active
	# Drop any previously selected live corner/bridge ghost as this phase
	# deliberately plans straight segments only.
	if _is_conveyor_selected():
		_create_placement_ghost(ConveyorPieceSelector.STRAIGHT_SCENE)
	if is_instance_valid(build_hud) and build_hud.has_method(
		"set_blueprint_mode"
	):
		build_hud.call("set_blueprint_mode", blueprint_mode_active)
	print(
		"BLUEPRINT MODE: ",
		"PLAN (buildings + connected conveyors)"
		if blueprint_mode_active else "OFF"
	)
	return true


func _blueprint_site_under_mouse() -> ConstructionSite:
	if not enable_blueprint_planning or not is_instance_valid(camera):
		return null
	var cursor := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(cursor)
	var ray_end := ray_origin + camera.project_ray_normal(cursor) * ray_length
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = SELECTION_COLLISION_MASK
	query.collide_with_areas = true
	var result := get_viewport().world_3d.direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var node := result.get("collider") as Node
	while is_instance_valid(node):
		if node is ConstructionSite:
			return node as ConstructionSite
		node = node.get_parent()
	return null


func _is_managed_blueprint(site: ConstructionSite) -> bool:
	return (
		enable_blueprint_planning
		and is_instance_valid(site)
		and not site.is_queued_for_deletion()
		and site.get_parent() == get_parent()
		and site.job != null
	)


func _authorize_blueprint_site(site: ConstructionSite) -> bool:
	if not _is_managed_blueprint(site):
		return false
	if not site.job.authorize():
		return false
	if blueprint_sandbox_debug_requirements:
		# Explicit factory-testing override. Do not enable in Main:
		# the actual power graph, delivered cargo and drone capacity
		# must eventually set these three availability values.
		site.job.set_availability(true, true, true)
		print("BLUEPRINT DEBUG: Requirements bypassed in testing sandbox")
	print("BLUEPRINT AUTHORIZED: ", site.target_definition.display_name)
	return true


# =============================================================================
# BATCH BLUEPRINT AUTHORIZATION — SANDBOX PLANNING TOOL
# =============================================================================
# Ctrl+E authorizes all still-planned sites in the current factory world.
# Every site uses the existing authorization and readiness gates.
# No resources, power, workers, or construction time are fabricated here.

func _authorize_all_blueprint_sites() -> int:
	if not enable_blueprint_planning or not placement_mode_active:
		return 0
	if demolition_mode_active or not blueprint_mode_active:
		return 0
	var count: int = 0
	# Snapshot the group: authorization can emit signals that change state.
	var candidates: Array[Node] = get_tree().get_nodes_in_group(
		"construction_sites"
	)
	for candidate: Node in candidates:
		if not candidate is ConstructionSite:
			continue
		var site := candidate as ConstructionSite
		if not _is_managed_blueprint(site):
			continue
		if site.job.state != ConstructionJob.State.PLANNED:
			continue
		if _authorize_blueprint_site(site):
			count += 1
	print("BLUEPRINT BATCH AUTHORIZED: ", count, " planned sites")
	return count


func _cancel_blueprint_site(site: ConstructionSite) -> bool:
	if not _is_managed_blueprint(site):
		return false
	if not site.job.cancel():
		return false
	print("BLUEPRINT CANCELLED")
	return true


func _blueprint_placement_clear(
	definition: BuildingDefinition, placement: Transform3D
) -> bool:
	if not is_instance_valid(definition):
		return false
	if not is_instance_valid(definition.building_scene):
		return false
	if definition.building_id == &"conveyor_belt":
		return false
	if definition.footprint_tiles.x <= 0 or definition.footprint_tiles.y <= 0:
		return false

	var right: Vector3 = placement.basis.x.normalized()
	var turns: int = roundi(
		rad_to_deg(atan2(-right.z, right.x)) / ROTATION_STEP_DEGREES
	)
	var footprint := FactoryGrid.rotated_footprint(
		definition.footprint_tiles, turns
	)
	var origin := FactoryGrid.snap_building_origin(
		placement.origin, footprint
	)
	if Vector2(origin.x - placement.origin.x, origin.z - placement.origin.z).length() > 0.02:
		return false

	# Explicit site overlap guard handles placements in the same physics
	# frame and protects footprints before the physics server catches up.
	for node: Node in get_tree().get_nodes_in_group("construction_sites"):
		if not node is ConstructionSite:
			continue
		var other := node as ConstructionSite
		if other.is_queued_for_deletion():
			continue
		var other_right: Vector3 = other.global_transform.basis.x.normalized()
		var other_turns: int = roundi(
			rad_to_deg(atan2(-other_right.z, other_right.x))
			/ ROTATION_STEP_DEGREES
		)
		var other_size := FactoryGrid.rotated_footprint(
			other.footprint, other_turns
		)
		if (
			absf(other.global_position.x - placement.origin.x)
				< float(other_size.x + footprint.x) * 0.5 - 0.02
			and absf(other.global_position.z - placement.origin.z)
				< float(other_size.y + footprint.y) * 0.5 - 0.02
		):
			return false

	# Existing completed structures and obstacle bodies also block plans.
	# A small inset allows two adjacent tile footprints to share an edge.
	var shape := BoxShape3D.new()
	shape.size = Vector3(
		float(footprint.x) - 0.04,
		0.56,
		float(footprint.y) - 0.04
	)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(
		Basis.IDENTITY,
		placement.origin + Vector3.UP * 0.3
	)
	query.collision_mask = PLACEMENT_BLOCKER_COLLISION_MASK
	var obstacles := get_viewport().world_3d.direct_space_state.intersect_shape(
		query, 1
	)
	return obstacles.is_empty()


func _create_blueprint_site(
	definition: BuildingDefinition, placement: Transform3D
) -> ConstructionSite:
	if not enable_blueprint_planning:
		return null
	if not buildable_definitions.has(definition):
		return null
	if not _blueprint_placement_clear(definition, placement):
		return null
	var scene_root := get_parent() as Node3D
	if not is_instance_valid(scene_root):
		return null
	var site := ConstructionSite.new()
	site.compact_blueprint_visuals = compact_blueprint_visuals
	if not site.setup_with_definition_job(definition):
		site.free()
		return null
	scene_root.add_child(site)
	site.global_transform = placement
	if (
		enable_connected_storage_blueprints
		and is_instance_valid(_planned_route_coordinator)
		and (
			not site.get_planned_port_names(true).is_empty()
			or not site.get_planned_port_names(false).is_empty()
		)
	):
		# Building-first planning also discovers neighboring belt plans.
		_planned_route_coordinator.register_new_site(site)
	return site


# =============================================================================
# E3D3A — SANDBOX TWO-CLICK STRAIGHT BLUEPRINT ROUTE
# =============================================================================
# Shift+Left Click chooses a starting transform, then an endpoint.
# Preflight every tile. A failure does not leave a partial factory route.
# Single-click placement, corners, and Main remain unchanged.

func _blueprint_route_cursor_grid() -> Dictionary:
	# Route selection deliberately uses the raw ground grid, not the
	# placement ghost: nearby building ports can move and rotate that ghost.
	if not is_instance_valid(camera):
		return {}
	var cursor: Vector2 = get_viewport().get_mouse_position()
	var start: Vector3 = camera.project_ray_origin(cursor)
	var end: Vector3 = start + camera.project_ray_normal(cursor) * ray_length
	var ray := PhysicsRayQueryParameters3D.create(start, end)
	ray.collision_mask = GROUND_COLLISION_MASK
	var hit: Dictionary = (
		get_viewport().world_3d.direct_space_state.intersect_ray(ray)
	)
	if hit.is_empty():
		return {}
	var point: Vector3 = hit["position"]
	return {
		"position": Vector3(
			snappedf(point.x, grid_size),
			point.y,
			snappedf(point.z, grid_size)
		),
		"ground": point
	}


func _blueprint_route_port_target(
	world_cursor: Vector3, building_input: bool
) -> Dictionary:
	if not enable_connected_storage_blueprints:
		return {}
	if not is_instance_valid(placement_ghost):
		return {}
	if not placement_ghost is ConveyorSegment:
		return {}
	if not is_instance_valid(_planned_route_coordinator):
		return {}
	var proposed: Dictionary = BlueprintRoutePortSnap.find_nearest(
		placement_ghost as ConveyorSegment,
		world_cursor,
		_planned_route_coordinator.port_registry,
		building_input
	)
	if proposed.is_empty():
		return {}
	if proposed.get("kind") == "live":
		var port: ItemPortComponent = proposed.get("port") as ItemPortComponent
		if BlueprintRoutePortSnap.has_pending_live_claim(get_tree(), port):
			return {}
	var definition: BuildingDefinition = _get_selected_building_definition()
	if not is_instance_valid(definition):
		return {}
	var candidate: Transform3D = proposed["transform"]
	if not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		definition, candidate, PLACEMENT_BLOCKER_COLLISION_MASK
	):
		return {}
	return proposed


func _handle_blueprint_route_click() -> int:
	if not (
		enable_blueprint_route_tool
		and enable_blueprint_planning
		and blueprint_mode_active
		and placement_mode_active
		and not demolition_mode_active
		and _is_conveyor_selected()
	):
		return 0

	var clicked: Dictionary = _blueprint_route_cursor_grid()
	if clicked.is_empty():
		print("BLUEPRINT ROUTE: Point at an open ground tile.")
		return 0
	var position: Vector3 = clicked["position"]
	var ground: Vector3 = clicked["ground"]
	if _blueprint_l_route_mode:
		return _handle_blueprint_l_route_position(position, ground)
	var endpoint_target: Dictionary = _blueprint_route_port_target(
		ground, not _route_anchor.is_empty()
	)
	if not endpoint_target.is_empty():
		var snapped: Transform3D = endpoint_target["transform"]
		position = snapped.origin
	var definition: BuildingDefinition = _get_selected_building_definition()
	if not is_instance_valid(definition):
		return 0
	if _route_anchor.is_empty():
		# The first click must be placeable. No resources or claims change yet.
		if not ConveyorBlueprintPlacement.is_clear(
			get_tree(), get_viewport().world_3d, definition,
			Transform3D(Basis.IDENTITY, position),
			PLACEMENT_BLOCKER_COLLISION_MASK
		):
			print("BLUEPRINT ROUTE: Start tile blocked.")
			return 0
		_route_anchor = {"position": position, "port": endpoint_target}
		print("BLUEPRINT ROUTE: Start selected at ", position,
			"; Shift-click a different tile in the same row or column.")
		return 0

	var anchor: Vector3 = _route_anchor["position"]
	var start_target: Dictionary = _route_anchor.get("port", {})
	_route_anchor.clear()
	if anchor.is_equal_approx(position):
		print("BLUEPRINT ROUTE: Start and endpoint are the same tile.")
		return 0
	# Route direction is derived from the two clicks, not the R rotation
	# or any automatic building-port snap applied to the placement ghost.
	var tiles: Array[Transform3D] = BlueprintStraightRoute.get_tiles_between(
		anchor, position
	)
	if tiles.is_empty():
		print("BLUEPRINT ROUTE: Choose a straight row or column (2–32 tiles).")
		return 0

	var placed: int = _commit_blueprint_route_tiles(
		tiles, definition, start_target, endpoint_target
	)
	if placed > 0:
		print("BLUEPRINT ROUTE PLANNED: ", placed, " conveyor tiles.")
	return placed


# =============================================================================
# E3D3B — THREE-CLICK L-SHAPED ROUTE PLACEMENT
# =============================================================================
# L toggles an isolated L-route tool. Shift-click start, turn, and finish.
# The outgoing leg uses the same straight-site creation path: the existing
# blueprint route coordinator converts the pivot site into a 90-degree turn.

func _toggle_blueprint_l_route_mode() -> bool:
	if not (
		enable_blueprint_route_tool
		and enable_blueprint_planning
		and blueprint_mode_active
		and placement_mode_active
		and not demolition_mode_active
		and _is_conveyor_selected()
	):
		return false
	_blueprint_l_route_mode = not _blueprint_l_route_mode
	_route_anchor.clear()
	if _blueprint_l_route_mode:
		print("BLUEPRINT L-ROUTE: ON | Shift-click start, corner, endpoint.")
	else:
		print("BLUEPRINT L-ROUTE: OFF | Shift-click straight routes.")
	return _blueprint_l_route_mode


func _handle_blueprint_l_route_position(
	position: Vector3, raw_ground: Vector3 = Vector3.INF
) -> int:
	# Separate testable handler: input device raycast is handled by caller.
	if not (
		_blueprint_l_route_mode
		and enable_blueprint_route_tool
		and enable_blueprint_planning
		and blueprint_mode_active
		and placement_mode_active
		and not demolition_mode_active
		and _is_conveyor_selected()
	):
		return 0
	var definition: BuildingDefinition = _get_selected_building_definition()
	if not is_instance_valid(definition):
		return 0

	var endpoint_target: Dictionary = {}
	if _route_anchor.is_empty() or _route_anchor.has("turn"):
		var cursor: Vector3 = raw_ground if raw_ground.is_finite() else position
		endpoint_target = _blueprint_route_port_target(
			cursor, not _route_anchor.is_empty()
		)
		if not endpoint_target.is_empty():
			var snapped: Transform3D = endpoint_target["transform"]
			position = snapped.origin

	if _route_anchor.is_empty():
		if not ConveyorBlueprintPlacement.is_clear(
			get_tree(), get_viewport().world_3d, definition,
			Transform3D.IDENTITY.translated(position),
			PLACEMENT_BLOCKER_COLLISION_MASK
		):
			print("BLUEPRINT L-ROUTE: Start tile blocked.")
			return 0
		_route_anchor = {"position": position, "port": endpoint_target}
		print("BLUEPRINT L-ROUTE: Start selected; Shift-click corner.")
		return 0

	var start: Vector3 = _route_anchor["position"]
	if not _route_anchor.has("turn"):
		var incoming: Array[Transform3D] = (
			BlueprintStraightRoute.get_tiles_between(start, position)
		)
		if incoming.size() < 2 or incoming.size() >= BlueprintStraightRoute.MAX_SEGMENTS:
			print("BLUEPRINT L-ROUTE: Corner must be on a different tile in a straight row or column.")
			return 0
		_route_anchor["turn"] = position
		print("BLUEPRINT L-ROUTE: Corner selected; Shift-click endpoint at 90 degrees.")
		return 0

	var pivot: Vector3 = _route_anchor["turn"]
	var tiles: Array[Transform3D] = BlueprintLRoute.get_tiles(
		start, pivot, position
	)
	if tiles.is_empty():
		# Retain the two points so the player can retry the endpoint.
		print("BLUEPRINT L-ROUTE: Endpoint must form a 90-degree turn (max 32 tiles).")
		return 0
	var start_target: Dictionary = _route_anchor.get("port", {})
	var placed: int = _commit_blueprint_route_tiles(
		tiles, definition, start_target, endpoint_target
	)
	if placed > 0:
		_route_anchor.clear()
		print("BLUEPRINT L-ROUTE PLANNED: ", placed,
			" conveyor tiles including one automatic corner.")
	return placed


func _commit_blueprint_route_tiles(
	tiles: Array[Transform3D],
	definition: BuildingDefinition,
	start_target: Dictionary = {},
	end_target: Dictionary = {}
) -> int:
	if tiles.is_empty() or not is_instance_valid(definition):
		return 0
	if not BlueprintRoutePortSnap.matches_route_end(tiles[0], start_target):
		print("BLUEPRINT ROUTE: Start port faces a different direction.")
		return 0
	if not BlueprintRoutePortSnap.matches_route_end(
		tiles[tiles.size() - 1], end_target
	):
		print("BLUEPRINT ROUTE: End port faces a different direction.")
		return 0
	for target: Dictionary in [start_target, end_target]:
		if target.get("kind") != "live":
			continue
		var port: ItemPortComponent = target.get("port") as ItemPortComponent
		if (
			port == null or not port.is_inside_tree()
			or is_instance_valid(port.connected_conveyor)
			or BlueprintRoutePortSnap.has_pending_live_claim(get_tree(), port)
		):
			print("BLUEPRINT ROUTE: Completed building port unavailable.")
			return 0
	# No partial route should be created when a tile is already reserved.
	for tile: Transform3D in tiles:
		if not ConveyorBlueprintPlacement.is_clear(
			get_tree(), get_viewport().world_3d,
			definition, tile, PLACEMENT_BLOCKER_COLLISION_MASK
		):
			print("BLUEPRINT ROUTE: Blocked tile at ",
				tile.origin, "; no route placed.")
			return 0
	var created: Array[ConstructionSite] = []
	for tile: Transform3D in tiles:
		var site: ConstructionSite = _create_straight_conveyor_blueprint(
			definition, tile
		)
		if not is_instance_valid(site):
			for previous: ConstructionSite in created:
				if is_instance_valid(previous) and previous.job != null:
					previous.job.cancel()
			print("BLUEPRINT ROUTE: Placement failed; sites cancelled.")
			return 0
		created.append(site)
	# The standard coordinator already owns claims to unfinished building
	# ports. Completed ports need deferred physical activation on the
	# corresponding edge belt once construction finishes.
	for entry: Dictionary in [
		{"target": start_target, "site": created[0]},
		{"target": end_target, "site": created[created.size() - 1]}
	]:
		var target: Dictionary = entry["target"]
		if target.get("kind") == "planned":
			var plan: ConstructionSite = target.get("site") as ConstructionSite
			if (
				not is_instance_valid(plan)
				or not is_instance_valid(_planned_route_coordinator)
				or not _planned_route_coordinator.port_registry.has_building_claim(
					plan, bool(target["input_side"]), target["port_name"]
				)
			):
				for previous: ConstructionSite in created:
					if is_instance_valid(previous):
						previous.job.cancel()
				print("BLUEPRINT ROUTE: Planned building port claim failed; route cancelled.")
				return 0
		elif target.get("kind") == "live":
			var port: ItemPortComponent = target.get("port") as ItemPortComponent
			if not _bind_blueprint_route_live_port(entry["site"] as ConstructionSite, port):
				for previous: ConstructionSite in created:
					if is_instance_valid(previous):
						previous.job.cancel()
				print("BLUEPRINT ROUTE: Completed building port binding failed; route cancelled.")
				return 0
	return created.size()


func _bind_blueprint_route_live_port(
	site: ConstructionSite, port: ItemPortComponent
) -> bool:
	if not is_instance_valid(site) or not is_instance_valid(port):
		return false
	if is_instance_valid(port.connected_conveyor):
		return false
	if BlueprintRoutePortSnap.has_pending_live_claim(get_tree(), port):
		return false
	site.set_meta("route_live_port_id", port.get_instance_id())
	var port_ref: WeakRef = weakref(port)
	site.building_completed.connect(func(built: Node3D) -> void:
		var raw: Variant = port_ref.get_ref()
		if not is_instance_valid(raw) or not built is ConveyorSegment:
			return
		var live_port: ItemPortComponent = raw as ItemPortComponent
		var belt: ConveyorSegment = built as ConveyorSegment
		if not belt.try_connect_building_port(live_port):
			print("BLUEPRINT ROUTE: Completed building port connection rejected.")
		else:
			print("BLUEPRINT ROUTE: Connected completed building port ",
				live_port.name)
	)
	return true


# =============================================================================
# STRAIGHT CONVEYOR BLUEPRINT COMMIT — OPTIONAL E2C2 ROUTE DISCOVERY
# =============================================================================
# A site is a plan, never an operational belt. Its two endpoints are markers
# until the authorized two-second construction job creates a ConveyorSegment.
# The sandbox-only route coordinator can reserve adjacent blueprint sites.

func _create_straight_conveyor_blueprint(
	definition: BuildingDefinition,
	placement: Transform3D
) -> ConstructionSite:
	if not enable_blueprint_planning:
		return null
	if not buildable_definitions.has(definition):
		return null
	if not ConveyorBlueprintPlacement.is_clear(
		get_tree(), get_viewport().world_3d,
		definition, placement, PLACEMENT_BLOCKER_COLLISION_MASK
	):
		return null
	var scene_root := get_parent() as Node3D
	if not is_instance_valid(scene_root):
		return null
	var site := ConstructionSite.new()
	site.compact_blueprint_visuals = compact_blueprint_visuals
	if not site.setup_with_definition_job(definition):
		site.free()
		return null
	scene_root.add_child(site)
	site.global_transform = placement
	if is_instance_valid(_planned_route_coordinator):
		_planned_route_coordinator.register_new_site(site)
	return site


func _commit_blueprint_from_preview() -> void:
	if not is_instance_valid(placement_ghost):
		return
	var definition := _get_selected_building_definition()
	if not is_instance_valid(definition):
		return
	if _is_conveyor_selected():
		# Refresh the actual cursor position before committing any belt.
		# Preview may be grid-aligned or snapped to an unfinished Storage
		# port. Placement rechecks the exact displayed belt transform.
		_update_placement_preview()
		if (
			not placement_is_valid
			or conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
		):
			print("BLUEPRINT: Straight belt tile blocked or preview invalid.")
			return
		var belt_site := _create_straight_conveyor_blueprint(
			definition, placement_ghost.global_transform
		)
		if not is_instance_valid(belt_site):
			print("BLUEPRINT: Straight belt footprint reservation rejected.")
			return
		print("BLUEPRINT BELT PLANNED: 2-second job | E authorize | X cancel")
		return
	# Refresh before evaluating the snap/collision state. A mouse movement
	# since the last rendered frame must never commit a stale blueprint.
	_update_placement_preview()
	if is_instance_valid(building_placement_snap_belt):
		print("BLUEPRINT: Port-linked planning awaits connection reservation gate.")
		return
	if not placement_is_valid or not _is_placement_clear():
		print("BLUEPRINT: Footprint blocked or preview invalid.")
		return
	var site := _create_blueprint_site(
		definition, placement_ghost.global_transform
	)
	if not is_instance_valid(site):
		print("BLUEPRINT: Placement rejected by footprint reservation.")
		return
	print("BLUEPRINT PLANNED: ", definition.display_name,
		" | P toggle | E authorize | X cancel")


# =============================================================================
# TIMED STORAGE CONSTRUCTION — TESTABLE SITE CREATION
# =============================================================================

func _place_timed_storage_site(
	definition: BuildingDefinition, placement_transform: Transform3D
) -> ConstructionSite:
	if not is_instance_valid(definition):
		return null
	if definition.building_id != &"test_storage":
		return null
	var scene_root := get_parent() as Node3D
	if not is_instance_valid(scene_root):
		return null
	var site := ConstructionSite.new()
	if not site.setup(definition, storage_construction_seconds):
		site.free()
		return null
	scene_root.add_child(site)
	site.global_transform = placement_transform
	return site


# =============================================================================
# COMMIT A PLANNED STORAGE BELT
# =============================================================================

func _commit_planned_storage_belt(
	site: ConstructionSite, input_side: bool,
	placement_transform: Transform3D
) -> ConveyorSegment:
	if not enable_planned_storage_conveyor_snap:
		return null
	if not is_instance_valid(site) or site.is_queued_for_deletion():
		return null
	var root := get_parent() as Node3D
	if root == null:
		return null
	var scene := ConveyorPieceSelector.STRAIGHT_SCENE
	var belt := scene.instantiate() as ConveyorSegment
	if belt == null:
		return null
	root.add_child(belt)
	belt.global_transform = placement_transform
	if not site.reserve_conveyor(belt, input_side):
		belt.queue_free()
		return null
	return belt


func _try_place_object() -> void:
	# Blueprint clicks never enter legacy conveyor/building placement paths.
	# E1 adds independent straight belts only. Physical belt graph links,
	# bridge previews, and 90-degree corner conversions remain a later gate.
	if enable_blueprint_planning and blueprint_mode_active:
		_commit_blueprint_from_preview()
		return

	# =============================================================================
	# MANUAL CONVEYOR PLACEMENT — SHIFT OVERRIDE
	# =============================================================================

	# Refresh snap state before the click is processed.
	# This prevents a previous automatic snap from
	# being committed after Shift is pressed.

	if (
		_is_conveyor_selected()
		and Input.is_physical_key_pressed(KEY_SHIFT)
	):
		_update_placement_preview()

	# =============================================================================
	# COMPLETE A CONVEYOR CORNER DIRECTLY INTO A BUILDING INPUT
	# =============================================================================

	if (
		_is_conveyor_selected()
		and not terminal_corner_preview.is_empty()
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):
		_update_placement_preview()
		if terminal_corner_preview.is_empty():
			print("TERMINAL CORNER | Cursor or target changed.")
			return
		var candidate: Dictionary = terminal_corner_preview.duplicate()
		if not ConveyorTerminalBuildingCorner.is_clear(
			get_viewport().world_3d,
			candidate,
			PLACEMENT_BLOCKER_COLLISION_MASK
		):
			print("TERMINAL CORNER | Blocked or port unavailable.")
			return
		if not ConveyorTerminalBuildingCorner.try_connect(candidate):
			print("TERMINAL CORNER | Physical connection rejected.")
			return
		print(
			"TERMINAL CORNER CONNECTED | Belt: ",
			(candidate["belt"] as ConveyorSegment).name,
			" | Port: ",
			(candidate["port"] as ItemPortComponent).name
		)
		_clear_terminal_corner_preview()
		return

	# =============================================================================
	# PLACE TWO-ENDED VARIABLE GEOMETRY
	# =============================================================================

	if (
		_is_conveyor_selected()
		and not gap_connector_preview.is_empty()
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):
		_update_placement_preview()
		if gap_connector_preview.is_empty():
			print("GAP CONNECTOR | Candidate changed or cursor moved.")
			return
		var candidate: Dictionary = gap_connector_preview.duplicate()
		if not _is_gap_connector_clear(candidate):
			print("GAP CONNECTOR | Physical placement blocked.")
			return
		var parent := get_tree().current_scene as Node3D
		if parent == null:
			return
		var new_belt: ConveyorSegment = null
		match str(candidate.get("kind", "")):
			"offset_corner":
				new_belt = ConveyorOffsetCornerBridge.try_place(
					parent, candidate, PLACEMENT_BLOCKER_COLLISION_MASK
				)
			"fractional_straight":
				new_belt = ConveyorFractionalBridge.try_place(
					parent, candidate
				)
		if not is_instance_valid(new_belt):
			print("GAP CONNECTOR | Both endpoints must remain free and aligned.")
			return
		print(
			"GAP CONNECTOR CONNECTED | Kind: ", candidate["kind"],
			" | Position: ", new_belt.global_position
		)
		_clear_gap_connector_preview()
		return

	# =============================================================================
	# COMMIT SOURCE CORNER ON CLICK
	# =============================================================================
	if (
		_is_conveyor_selected()
		and not source_corner_preview.is_empty()
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):
		_update_placement_preview()
		if source_corner_preview.is_empty():
			print("SOURCE CORNER | Target changed or cursor moved.")
			return
		var candidate: Dictionary = source_corner_preview.duplicate()
		if not ConveyorSourceCornerBuildPreview.is_clear(
			get_viewport().world_3d, candidate, PLACEMENT_BLOCKER_COLLISION_MASK
		):
			print("SOURCE CORNER | Blocked or endpoint changed.")
			return
		if not ConveyorExistingConnection.try_connect_candidate(candidate):
			print("SOURCE CORNER | Connection rejected safely.")
			return
		var source: ConveyorSegment = candidate["source"] as ConveyorSegment
		var receiver: ConveyorSegment = candidate["receiver"] as ConveyorSegment
		print(
			"SOURCE CORNER CONNECTED | Source: ", source.name,
			" | Receiver: ", receiver.name, " | Turn: ", candidate["turn"]
		)
		_clear_source_corner_preview()
		return

	# =============================================================================
	# REFRESH RECEIVER CORNER ON CLICK
	# =============================================================================

	# A queued mouse event can arrive after the last preview update.
	# Require the target to remain under the current pointer.
	if (
		_is_conveyor_selected()
		and not receiver_corner_preview.is_empty()
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):
		_update_placement_preview()
		if receiver_corner_preview.is_empty():
			print("RECEIVER CORNER | Target no longer under cursor.")
			return

	# =============================================================================
	# CONVERT EXISTING RECEIVER ON ONE CLICK
	# =============================================================================

	# A selected straight receiver already occupies this tile.
	# Connect in place; do NOT instantiate another belt.
	if (
		_is_conveyor_selected()
		and not receiver_corner_preview.is_empty()
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):
		var candidate: Dictionary = receiver_corner_preview.duplicate()
		if not ConveyorReceiverCornerBuildPreview.is_clear(
			get_viewport().world_3d,
			candidate,
			PLACEMENT_BLOCKER_COLLISION_MASK
		):
			print("RECEIVER CORNER | Blocked or connection changed.")
			return

		if not ConveyorExistingConnection.try_connect_candidate(candidate):
			print("RECEIVER CORNER | Connection rejected; no belt placed.")
			return

		var source: ConveyorSegment = candidate["source"] as ConveyorSegment
		var receiver: ConveyorSegment = candidate["receiver"] as ConveyorSegment
		print(
			"RECEIVER CORNER CONNECTED | Source: ", source.name,
			" | Receiver: ", receiver.name,
			" | Turn: ", candidate["turn"],
			" | Position: ", receiver.global_position
		)
		_clear_receiver_corner_preview()
		return

	# =============================================================================
	# PERMANENT MISSING CORNER PLACEMENT
	# =============================================================================

	# A valid one-tile missing corner has priority over
	# ordinary conveyor placement.
	#
	# Shift continues to bypass automatic corner snapping.

	if (
		_is_conveyor_selected()
		and not missing_corner_preview.is_empty()
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):

		if not placement_ghost is ConveyorSegment:
			print("MISSING CORNER | Invalid placement ghost.")
			return

		# Validate collisions again when the player clicks.

		if not placement_is_valid or not _is_placement_clear():
			print("MISSING CORNER | Placement blocked.")
			return

		var corner_parent: Node3D = (
			get_tree().current_scene as Node3D
		)

		if not is_instance_valid(corner_parent):
			print("MISSING CORNER | Invalid scene root.")
			return

		var placed_corner: ConveyorSegment = (
			ConveyorMissingCornerPlacement.try_place(
				corner_parent,
				missing_corner_preview
			)
		)

		if not is_instance_valid(placed_corner):
			print(
				"MISSING CORNER | Connection rejected or "
				+ "candidate changed."
			)
			return

		print(
			"MISSING CORNER CONNECTED | Position: ",
			placed_corner.global_position,
			" | Turn: ",
			placed_corner.get_meta("conveyor_turn")
		)

		# Successful placement is complete.
		# The next preview update will restore the
		# normal straight ghost automatically.

		return

	# =============================================================================
	# SNAP TARGET — CLICK DIAGNOSTIC
	# =============================================================================

	# One concise message makes it clear whether the
	# new object will be physically connected or placed freely.

	if _is_conveyor_selected() and placement_ghost is ConveyorSegment:

		if (
			is_instance_valid(conveyor_bridge_source)
			and is_instance_valid(conveyor_bridge_destination)
		):

			print(
				"SNAP TARGET | Two-ended bridge: ",
				conveyor_bridge_source.name,
				" -> NEW -> ",
				conveyor_bridge_destination.name
			)

		elif is_instance_valid(conveyor_building_snap_port):

			print(
				"SNAP TARGET | Building: ",
				conveyor_building_snap_port.get_parent().name,
				" / ", conveyor_building_snap_port.name
			)

		elif is_instance_valid(conveyor_snap_source):

			print(
				"SNAP TARGET | Conveyor: ",
				conveyor_snap_source.name,
				" | Before: ", conveyor_snap_before
			)

		elif is_instance_valid(conveyor_corner_snap_source):

			print("SNAP TARGET | Off-grid corner preview")

		else:

			print("SNAP TARGET | Free grid placement")

	# =============================================================================
	# CORNER PLACEMENT SAFETY CHECK
	# =============================================================================

	# A conveyor corner must connect to the available
	# output of an existing conveyor.
	#
	# Straight conveyors retain their normal placement rules.

	if (
		_is_conveyor_selected()
		and conveyor_preview_scene != null
		and conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
	):

		# Corners cannot be placed freely or connected
		# before an existing conveyor during this step.

		if (
			not is_instance_valid(conveyor_snap_source)
			or conveyor_snap_before
		):
			print(
				"Corner placement blocked: "
				+ "A free conveyor output is required."
			)
			return

	# =============================================================================
	# VALIDATE PLACEMENT
	# =============================================================================

	if not placement_is_valid:
		print("Placement blocked")
		return

	var selected_scene: PackedScene = _get_selected_building_scene()

	if selected_scene == null:
		print("No buildable scene selected")
		return

	
	# =============================================================================
	# TIMED STORAGE CONSTRUCTION — OPT-IN FREE PLACEMENT
	# =============================================================================
	# Preserve the specialized port-snapping path until delayed connections
	# have their own tests. Only standalone Storage uses a construction site.

	var selected_definition_for_site: BuildingDefinition = (
		_get_selected_building_definition()
	)
	if (
		enable_timed_storage_construction
		and is_instance_valid(selected_definition_for_site)
		and selected_definition_for_site.building_id == &"test_storage"
		and not is_instance_valid(building_placement_snap_belt)
		and not is_instance_valid(building_placement_snap_port)
	):
		if not _is_placement_clear():
			print("Storage construction blocked: footprint occupied.")
			return
		var construction_site := _place_timed_storage_site(
			selected_definition_for_site,
			Transform3D(
				Basis(Vector3.UP, deg_to_rad(placement_rotation_degrees)),
				current_placement_position
			)
		)
		if not is_instance_valid(construction_site):
			print("Storage construction failed: site unavailable.")
		return

	# =============================================================================
	# PERMANENT TWO-ENDED CONVEYOR BRIDGE PLACEMENT
	# =============================================================================

	# A new straight conveyor must fill the EXACT free gap between
	# two real existing belts. No endpoint stretching, no extra belt,
	# and no partial route left behind if either connection fails.

	if (
		is_instance_valid(conveyor_bridge_source)
		or is_instance_valid(conveyor_bridge_destination)
	):

		if (
			not placement_ghost is ConveyorSegment
			or not _is_conveyor_selected()
			or conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
			or not is_instance_valid(conveyor_bridge_source)
			or not is_instance_valid(conveyor_bridge_destination)
			or is_instance_valid(conveyor_building_snap_port)
			or is_instance_valid(conveyor_snap_source)
			or is_instance_valid(conveyor_corner_snap_source)
		):
			print("Bridge placement failed: Invalid snap state.")
			return

		# Recheck collision and both endpoint occupancies on click.
		# This prevents a stale green ghost from committing a bridge.

		if not _is_placement_clear():
			print("Bridge placement blocked: Geometry or collision changed.")
			return

		var bridge_check: Dictionary = (
			ConveyorDualEndedBridge.get_preview_transform(
				conveyor_bridge_source,
				placement_ghost as ConveyorSegment,
				conveyor_bridge_destination
			)
		)

		if bridge_check.is_empty():
			print("Bridge placement failed: Endpoints unavailable.")
			return

		var bridge_transform: Transform3D = (
			bridge_check["transform"]
		)

		if not placement_ghost.global_transform.is_equal_approx(
			bridge_transform
		):
			print("Bridge placement failed: Preview moved.")
			return

		var bridge_instance: Node = (
			ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		)

		if not bridge_instance is ConveyorSegment:
			if is_instance_valid(bridge_instance):
				bridge_instance.free()
			print("Bridge placement failed: Invalid conveyor scene.")
			return

		var placed_bridge: ConveyorSegment = (
			bridge_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(placed_bridge)
		placed_bridge.global_transform = bridge_transform

		var bridge_connected: bool = (
			ConveyorDualEndedBridge.try_connect(
				conveyor_bridge_source,
				placed_bridge,
				conveyor_bridge_destination
			)
		)

		if not bridge_connected:
			placed_bridge.queue_free()
			print("Bridge placement failed: Connections rejected.")
			return

		print(
			"TWO-ENDED BRIDGE CONNECTED | Source: ",
			conveyor_bridge_source.name,
			" | Bridge: ", placed_bridge.name,
			" | Destination: ", conveyor_bridge_destination.name,
			" | Position: ", placed_bridge.global_position
		)

		# Both links are now physically connected.
		# Never continue into normal placement on the same click.

		return

	# =============================================================================
	# PERMANENT BUILDING-TO-CONVEYOR PLACEMENT
	# =============================================================================

	# Places a building directly against an existing
	# conveyor's available physical endpoint.
	#
	# Supports:
	# - Conveyor OUTPUT -> Building INPUT
	# - Building OUTPUT -> Conveyor INPUT
	# - Rotated buildings
	# - Fractional world positions
	# - Recipe-controlled and universal inventories
	#
	# The normal placement collision check has
	# already completed before reaching this section.

	if (
		is_instance_valid(building_placement_snap_belt)
		and is_instance_valid(building_placement_snap_port)
	):

		# =============================================================================
		# VALIDATE EXISTING CONVEYOR AND BUILDING GHOST
		# =============================================================================

		if not is_instance_valid(placement_ghost):
			print("Building placement failed: Missing ghost.")
			return

		if placement_ghost is ConveyorSegment:
			print("Building placement failed: Invalid building.")
			return

		if (
			not building_placement_snap_belt.is_inside_tree()
			or building_placement_snap_belt.is_queued_for_deletion()
		):
			print("Building placement failed: Conveyor unavailable.")
			return

		# =============================================================================
		# IDENTIFY PREVIEW PORT
		# =============================================================================

		# The selected port belongs to the ghost.
		# The permanent building must use its own port,
		# never the temporary ghost component.

		if not placement_ghost.is_ancestor_of(
			building_placement_snap_port
		):
			print("Building placement failed: Invalid port.")
			return

		var port_path: NodePath = (
			placement_ghost.get_path_to(
				building_placement_snap_port
			)
		)

		# =============================================================================
		# CREATE PERMANENT BUILDING
		# =============================================================================

		var building_instance: Node = (
			selected_scene.instantiate()
		)

		if not building_instance is Node3D:

			if is_instance_valid(building_instance):
				building_instance.free()

			print("Building placement failed: Invalid scene.")
			return

		var placed_building: Node3D = (
			building_instance as Node3D
		)

		get_tree().current_scene.add_child(
			placed_building
		)

		# =============================================================================
		# APPLY EXACT PREVIEW TRANSFORM
		# =============================================================================

		# Do not round to the integer grid.
		# Preserve the port alignment and rotation.

		placed_building.global_transform = (
			placement_ghost.global_transform
		)

		# =============================================================================
		# INITIALIZE BUILDING DEFINITION
		# =============================================================================

		var definition: BuildingDefinition = (
			_get_selected_building_definition()
		)

		var runtime: BuildingRuntime = (
			placed_building.get_node_or_null(
				"BuildingRuntime"
			) as BuildingRuntime
		)

		if runtime != null and definition != null:
			runtime.initialize(definition)

		# =============================================================================
		# FIND ACTUAL BUILDING PORT
		# =============================================================================

		var actual_port: ItemPortComponent = (
			placed_building.get_node_or_null(
				port_path
			) as ItemPortComponent
		)

		if not is_instance_valid(actual_port):

			placed_building.queue_free()

			print(
				"Building placement failed: "
				+ "Permanent port not found."
			)

			return

		# =============================================================================
		# ESTABLISH PHYSICAL CONNECTION
		# =============================================================================

		# The existing connection method validates:
		# - Correct input/output direction
		# - Free conveyor endpoint
		# - Free building port
		# - Physical endpoint alignment
		# - Compatible inventory configuration

		var connected: bool = (
			building_placement_snap_belt.try_connect_building_port(
				actual_port
			)
		)

		# =============================================================================
		# HANDLE CONNECTION FAILURE
		# =============================================================================

		if not connected:

			# Never leave a building that appears
			# connected but has no physical connection.

			placed_building.queue_free()

			print(
				"Building placement failed: "
				+ "Physical connection rejected."
			)

			return

		# =============================================================================
		# CONFIRM CONNECTION
		# =============================================================================

		print(
			"BUILDING CONNECTED SUCCESSFULLY | Building: ",
			placed_building.name,
			" | Port: ",
			actual_port.name,
			" | Conveyor: ",
			building_placement_snap_belt.name,
			" | Position: ",
			placed_building.global_position
		)

		# =============================================================================
		# PREVENT DUPLICATE PLACEMENT
		# =============================================================================

		# The building and its physical connection
		# have both been created successfully.
		#
		# Do not execute normal placement afterward.

		building_placement_snap_belt = null
		building_placement_snap_port = null

		return


	# =============================================================================
	# PERMANENT BUILDING-OFFSET CONVEYOR CORNER PLACEMENT
	# =============================================================================

	# The snap preview uses the next straight conveyor's
	# exact transform and a free output on an existing straight.
	#
	# When placed, the existing straight is converted IN PLACE
	# into the required left/right corner. This preserves:
	# - incoming building port and conveyor connections
	# - the original conveyor node and cargo inventory
	# - generic item transport, selection and demolition
	#
	# The new conveyor stays a straight segment. Never create
	# an unconnected conveyor if preview revalidation fails.

	if is_instance_valid(conveyor_corner_snap_source):

		# =============================================================================
		# VALIDATE SNAP STATE AND REQUIRED STRAIGHT PREVIEW
		# =============================================================================

		if not placement_ghost is ConveyorSegment:
			print("Off-grid corner failed: Invalid conveyor ghost.")
			return

		if (
			not _is_conveyor_selected()
			or conveyor_preview_scene != ConveyorPieceSelector.STRAIGHT_SCENE
			or is_instance_valid(conveyor_snap_source)
			or is_instance_valid(conveyor_building_snap_port)
		):
			print("Off-grid corner failed: Conflicting snap state.")
			return

		var corner_source: ConveyorSegment = (
			conveyor_corner_snap_source
		)

		if (
			not corner_source.is_inside_tree()
			or corner_source.is_queued_for_deletion()
			or not corner_source.is_in_group("player_built")
		):
			print("Off-grid corner failed: Source unavailable.")
			return

		# =============================================================================
		# RECHECK PREVIEW GEOMETRY AND ENDPOINT AVAILABILITY
		# =============================================================================

		# An adjacent placement or demolition may have changed
		# the source since the last visual preview frame.
		# Recalculate before creating the permanent conveyor.

		var corner_check: Dictionary = (
			ConveyorCornerPlacementSnap.get_preview_transform(
				corner_source,
				placement_ghost as ConveyorSegment,
				conveyor_corner_snap_turn
			)
		)

		if corner_check.is_empty():
			print("Off-grid corner failed: Connection no longer available.")
			return

		var checked_transform: Transform3D = (
			corner_check["transform"]
		)

		if not placement_ghost.global_transform.is_equal_approx(
			checked_transform
		):
			print("Off-grid corner failed: Preview alignment changed.")
			return

		# =============================================================================
		# INSTANTIATE EXACTLY ONE NEW STRAIGHT CONVEYOR
		# =============================================================================

		var corner_instance: Node = (
			ConveyorPieceSelector.STRAIGHT_SCENE.instantiate()
		)

		if not corner_instance is ConveyorSegment:
			if is_instance_valid(corner_instance):
				corner_instance.free()
			print("Off-grid corner failed: Invalid straight scene.")
			return

		var corner_receiver: ConveyorSegment = (
			corner_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(corner_receiver)

		# Preserve the off-grid transform from the approved ghost.
		corner_receiver.global_transform = checked_transform

		# =============================================================================
		# COMMIT IN-PLACE CORNER CONVERSION AND PHYSICAL LINK
		# =============================================================================

		var corner_connected: bool = (
			ConveyorCornerConversion.try_convert_and_connect(
				corner_source,
				corner_receiver,
				conveyor_corner_snap_turn
			)
		)

		if not corner_connected:
			# Conversion restores its old output when link fails.
			# No disconnected receiver should remain in the scene.
			corner_receiver.queue_free()
			print("Off-grid corner failed: Connection rejected.")
			return

		# =============================================================================
		# CONFIRM SUCCESS — DO NOT RUN NORMAL PLACEMENT
		# =============================================================================

		print(
			"OFF-GRID CORNER CONNECTED | Turn: ",
			"RIGHT" if conveyor_corner_snap_turn == ConveyorTurnIntent.Turn.RIGHT else "LEFT",
			" | Source: ", corner_source.name,
			" | New belt: ", corner_receiver.name,
			" | Position: ", corner_receiver.global_position
		)

		return

	# =============================================================================
	# USE ACTIVE CONVEYOR SHAPE FOR PLACEMENT
	# =============================================================================

	# The placement ghost has already selected the
	# appropriate conveyor shape:
	#
	# - Straight
	# - Right 90-degree corner
	# - Left 90-degree corner
	#
	# Use the same scene for the permanent object.
	#
	# Other building types retain their normal scene.

	if (
		_is_conveyor_selected()
		and placement_ghost is ConveyorSegment
		and conveyor_preview_scene != null
	):
		selected_scene = conveyor_preview_scene

	
	# =============================================================================
	# PLANNED STORAGE BELT PLACEMENT — SANDBOX OPT-IN
	# =============================================================================
	# Revalidate the selected site and current cursor before committing.
	# The belt remains physically disconnected until construction completes.

	if not planned_conveyor_preview.is_empty():
		if not enable_planned_storage_conveyor_snap:
			return
		if not placement_ghost is ConveyorSegment:
			return
		if not _is_placement_clear():
			print("Planned Storage belt blocked: Collision or reservation changed.")
			return
		var site := planned_conveyor_preview.get("site") as ConstructionSite
		if not is_instance_valid(site):
			return
		var input_side: bool = bool(
			planned_conveyor_preview.get("input_side", true)
		)
		var belt := _commit_planned_storage_belt(
			site, input_side, placement_ghost.global_transform
		)
		if belt == null:
			print("Planned Storage belt connection was not reserved.")
		else:
			print("PLANNED STORAGE BELT RESERVED | ", belt.global_position)
		return

	# =============================================================================
	# PERMANENT BUILDING-TO-CONVEYOR SNAP PLACEMENT
	# =============================================================================

	# Create a physical conveyor connection when the
	# placement ghost is snapped to a valid building port.
	#
	# Supports:
	# - Extractor OUTPUT -> Conveyor INPUT
	# - Conveyor OUTPUT -> Smelter INPUT
	# - Rotated buildings
	# - Generic item transportation
	#
	# Existing collision validation happens earlier
	# in _try_place_object().
	#
	# Do not create duplicate conveyors or bypass
	# the existing belt-to-belt snapping system.

	if is_instance_valid(conveyor_building_snap_port):

		# =============================================================================
		# VALIDATE BUILDING SNAP PREVIEW
		# =============================================================================

		if not placement_ghost is ConveyorSegment:
			print("Building connection failed: Invalid ghost.")
			return

		if (
			not conveyor_building_snap_port.is_inside_tree()
			or conveyor_building_snap_port.is_queued_for_deletion()
		):
			print("Building connection failed: Port unavailable.")
			return

		# =============================================================================
		# CREATE PERMANENT CONVEYOR
		# =============================================================================

		var building_snap_instance: Node = (
			selected_scene.instantiate()
		)

		if not building_snap_instance is ConveyorSegment:

			if is_instance_valid(building_snap_instance):
				building_snap_instance.free()

			print("Building connection failed: Invalid scene.")
			return

		var building_snap_belt: ConveyorSegment = (
			building_snap_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(
			building_snap_belt
		)

		# =============================================================================
		# APPLY EXACT PREVIEW TRANSFORM
		# =============================================================================

		# Use the placement ghost's world transform.
		# This preserves its rotation and port alignment.

		building_snap_belt.global_transform = (
			placement_ghost.global_transform
		)

		# =============================================================================
		# ESTABLISH PHYSICAL BUILDING CONNECTION
		# =============================================================================

		# The existing connection component validates:
		# - Port direction
		# - Port availability
		# - Reciprocal connection state
		# - Endpoint geometry
		# - Inventory configuration

		var building_connected: bool = (
			building_snap_belt.try_connect_building_port(
				conveyor_building_snap_port
			)
		)

		# =============================================================================
		# HANDLE FAILED CONNECTION
		# =============================================================================

		if not building_connected:

			# Remove the new conveyor if the physical
			# connection cannot be established.

			building_snap_belt.queue_free()

			print(
				"Building connection failed: "
				+ "Physical connection rejected."
			)

			return

		# =============================================================================
		# CONFIRM SUCCESSFUL CONNECTION
		# =============================================================================

		print(
			"BUILDING PORT CONNECTED | Port: ",
			conveyor_building_snap_port.name,
			" | Conveyor: ",
			building_snap_belt.name,
			" | Position: ",
			building_snap_belt.global_position
		)

		# Short gaps may place the second free endpoint directly
		# against another building port or pre-existing conveyor.
		# Connect only uniquely matched, physically aligned endpoints.
		ConveyorNearbyConnection.complete_open_ends(building_snap_belt)

		# Do not create a duplicate conveyor on the same click.
		return


	# =============================================================================
	# PERMANENT CONVEYOR SNAP PLACEMENT
	# =============================================================================

	# Handle snapped conveyors BEFORE normal building placement.
	#
	# This prevents creating two objects during one click.
	#
	# A successful snap creates one conveyor and connects it
	# to an existing conveyor.

	if is_instance_valid(conveyor_snap_source):

		# =============================================================================
		# VALIDATE CONVEYOR PREVIEW
		# =============================================================================

		if not placement_ghost is ConveyorSegment:
			print("Conveyor placement failed: Invalid preview.")
			return

		# =============================================================================
		# CREATE NEW CONVEYOR
		# =============================================================================

		var new_instance: Node = selected_scene.instantiate()

		if not new_instance is ConveyorSegment:
			new_instance.free()
			print("Conveyor placement failed: Invalid scene.")
			return

		var new_belt: ConveyorSegment = (
			new_instance as ConveyorSegment
		)

		get_tree().current_scene.add_child(new_belt)

		# Apply the exact snapped preview transform.
		# This preserves both position and rotation.

		new_belt.global_transform = (
			placement_ghost.global_transform
		)

		# =============================================================================
		# ESTABLISH CONVEYOR CONNECTION
		# =============================================================================

		var connection_successful: bool = false

		if conveyor_snap_before:

			# New conveyor feeds an existing conveyor.

			connection_successful = (
				new_belt.try_connect_to(conveyor_snap_source)
			)

		else:

			# Existing conveyor feeds the new conveyor.

			connection_successful = (
				conveyor_snap_source.try_connect_to(new_belt)
			)

		# =============================================================================
		# FAILED CONNECTION — REMOVE TEMPORARY BELT
		# =============================================================================

		if not connection_successful:
			new_belt.queue_free()
			print("Conveyor placement failed: Connection rejected.")
			return

		# =============================================================================
		# SUCCESSFUL CONVEYOR PLACEMENT
		# =============================================================================

		print(
			"Conveyor connected successfully | Before: ",
			conveyor_snap_before,
			" | Position: ",
			new_belt.global_position
		)

		# =============================================================================
		# CONFIRM PERMANENT CONVEYOR SCENE
		# =============================================================================

		# Print the original scene path rather than the automatically
		# generated node name.

		print("CONVEYOR PLACED | Scene: ", selected_scene.resource_path)

		# A second building port may meet the remaining free
		# endpoint. Complete that connection without moving the belt.
		ConveyorNearbyConnection.complete_open_ends(new_belt)

		# Normal building placement must not run afterward.
		return

	# =============================================================================
	# NORMAL BUILDING PLACEMENT
	# =============================================================================

	# This section handles regular buildings and standalone
	# conveyors that are not snapped to another belt.
	#
	# Keep existing BuildingDefinition functionality.

	var new_object: Node = selected_scene.instantiate()

	get_tree().current_scene.add_child(new_object)

	# =============================================================================
	# INITIALIZE BUILDING DEFINITION
	# =============================================================================

	var selected_definition: BuildingDefinition = (
		_get_selected_building_definition()
	)

	var building_runtime: BuildingRuntime = (
		new_object.get_node_or_null("BuildingRuntime")
		as BuildingRuntime
	)

	if building_runtime != null and selected_definition != null:
		building_runtime.initialize(selected_definition)

	# =============================================================================
	# APPLY PLACEMENT TRANSFORM
	# =============================================================================

	if new_object is Node3D:
		new_object.global_position = current_placement_position
		new_object.rotation_degrees.y = placement_rotation_degrees

	# =============================================================================
	# AUTOMATIC CONVEYOR CORNER CONVERSION
	# =============================================================================

	# After the new straight conveyor has been placed,
	# check whether it creates a valid perpendicular turn.
	#
	# The preceding conveyor becomes the corner.
	# The newly placed conveyor remains straight.
	#
	# Other building types are unaffected.

	
	if (
		_is_conveyor_selected()
		and new_object is ConveyorSegment
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):


		var placed_straight: ConveyorSegment = (
			new_object as ConveyorSegment
		)

		var corner_candidate: Dictionary = (
			_find_perpendicular_corner_candidate(
				placed_straight
			)
		)

		if not corner_candidate.is_empty():

			var source_belt: ConveyorSegment = (
				corner_candidate["source"] as ConveyorSegment
			)

			var turn_direction: int = int(
				corner_candidate["turn"]
			)

			# =============================================================================
			# COMMIT THE CORNER CONNECTION
			# =============================================================================

			var conversion_successful: bool = (
				ConveyorCornerConversion.try_convert_and_connect(
					source_belt,
					placed_straight,
					turn_direction
				)
			)

			if not conversion_successful:

				# Do not leave an invalid newly placed belt.
				# The conversion component restores the
				# previous belt when connection fails.

				placed_straight.queue_free()

				print(
					"Automatic corner failed: "
					+ "Connection rejected."
				)

				return

			# =============================================================================
			# CONFIRM AUTOMATIC CORNER
			# =============================================================================

			var turn_name: String = "RIGHT"

			if turn_direction == ConveyorTurnIntent.Turn.LEFT:
				turn_name = "LEFT"

			print(
				"AUTO CORNER SUCCESS | Turn: ",
				turn_name,
				" | Corner position: ",
				source_belt.global_position,
				" | New straight: ",
				placed_straight.global_position
			)

	# =============================================================================
	# CONNECT EXACT ADJACENT ENDPOINTS AFTER FREE PLACEMENT
	# =============================================================================

	# A free-placed belt may sit exactly between building ports.
	# Parallel lanes remain independent unless endpoints align.
	if (
		new_object is ConveyorSegment
		and not Input.is_physical_key_pressed(KEY_SHIFT)
	):
		ConveyorNearbyConnection.complete_open_ends(
			new_object as ConveyorSegment
		)

	# =============================================================================
	# PLACEMENT CONFIRMATION
	# =============================================================================

	print(
		"Placed object at ",
		current_placement_position,
		" with rotation ",
		placement_rotation_degrees,
		" degrees"
	)

# =============================================================================
# PLACEMENT GHOST CREATION
# =============================================================================
# Creates a temporary visual copy of the currently selected buildable scene.
#
# The ghost:
#   - has its actual collision shapes recorded for placement checks
#   - has those physics collisions disabled
#   - uses a translucent material
#   - inherits the current placement rotation


func _create_placement_ghost(
	scene_override: PackedScene = null
) -> void:

	_destroy_placement_ghost()

	# =============================================================================
	# SELECT NORMAL BUILDING SCENE
	# =============================================================================

	var selected_scene: PackedScene = (
		_get_selected_building_scene()
	)

	# =============================================================================
	# OPTIONAL CONVEYOR SCENE OVERRIDE
	# =============================================================================

	# Only the Conveyor Belt tool (identified by building_id)
	# may replace its default scene with an alternate
	# conveyor shape.
	#
	# Other building types continue using their
	# normal BuildingDefinition scenes.

	if (
		_is_conveyor_selected()
		and scene_override != null
	):

		if scene_override in [
			ConveyorPieceSelector.STRAIGHT_SCENE,
			ConveyorPieceSelector.RIGHT_CORNER_SCENE,
			ConveyorPieceSelector.LEFT_CORNER_SCENE
		]:
			selected_scene = scene_override

	if selected_scene == null:
		return


	var ghost_instance: Node = selected_scene.instantiate()

	if not ghost_instance is Node3D:
		return

	placement_ghost = ghost_instance as Node3D
	
	# =============================================================================
	# RECORD CONVEYOR PREVIEW TYPE
	# =============================================================================

	conveyor_preview_scene = null

	if placement_ghost is ConveyorSegment:
		conveyor_preview_scene = selected_scene

	# Placement ghosts are visual previews only.
	# Mark them explicitly for snap discovery before they enter the tree.
	# A real building can also have processing disabled, so discovery
	# must not identify ghosts from process_mode alone.
	placement_ghost.add_to_group("construction_preview")

	# Disable gameplay processing for the ghost and its child components.
	placement_ghost.process_mode = Node.PROCESS_MODE_DISABLED
	placement_ghost.rotation_degrees.y = placement_rotation_degrees

	placement_ghost_collisions.clear()

# Record physical building collision shapes for placement checks.
# Detection Area3D shapes are disabled on the ghost but are not part of
# the building's placement-blocking footprint.
	for child in placement_ghost.find_children(
		"*",
		"CollisionShape3D",
		true,
		false
	):
		if child is CollisionShape3D:
			child.disabled = true

			if child.get_parent() is PhysicsBody3D:
				placement_ghost_collisions.append(child)

	# Create the translucent placement-preview material.
	ghost_material = StandardMaterial3D.new()
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	ghost_material.albedo_color = Color(
		valid_placement_color.r,
		valid_placement_color.g,
		valid_placement_color.b,
		PLACEMENT_GHOST_ALPHA
	)

	# Apply the preview material to every visible mesh inside the ghost.
	for child in placement_ghost.find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	):
		if child is MeshInstance3D:
			child.material_override = ghost_material

	get_tree().current_scene.add_child(placement_ghost)


# =============================================================================
# PLACEMENT GHOST CLEANUP
# =============================================================================
# Safely removes the temporary placement preview and clears all references
# associated with it.
#
# Called when:
#   - Build Mode ends
#   - Demolition Mode begins
#   - the selected building type changes
#   - a fresh placement ghost is created



func _destroy_placement_ghost() -> void:
	_clear_receiver_corner_preview()
	_clear_source_corner_preview()
	_clear_terminal_corner_preview()
	_clear_gap_connector_preview()
	if placement_ghost != null and is_instance_valid(placement_ghost):
		placement_ghost.queue_free()

	# =============================================================================
	# RESET PLACEMENT GHOST STATE
	# =============================================================================

	conveyor_snap_source = null
	conveyor_snap_before = false
	conveyor_building_snap_port = null
	planned_conveyor_preview.clear()
	building_placement_snap_belt = null
	building_placement_snap_port = null
	conveyor_corner_snap_source = null
	conveyor_corner_snap_turn = ConveyorTurnIntent.Turn.STRAIGHT
	conveyor_bridge_source = null
	conveyor_bridge_destination = null
	conveyor_preview_scene = null
	placement_ghost = null
	ghost_material = null
	missing_corner_preview.clear()
	placement_ghost_collisions.clear()
