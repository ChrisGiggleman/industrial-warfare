extends "res://scripts/ui/isolated_playable_construction_logistics_demo.gd"
## E3d5c5x1 — separate power-only playable experiment.
## Real completed Hub/Pole nodes and finite allocation. No drone, escrow
## reservation, material readiness grant, charging, or debug bypass.

const DEMAND: int = 7
const HUB_POSITION := Vector3(2, 0, -3)
const POLE_POSITION := Vector3(-3, 0, 0)
const HUB_SCENE = preload("res://scenes/buildings/prototype_main_hub.tscn")
const POLE_SCENE = preload("res://scenes/buildings/prototype_power_pole.tscn")

@export var enable_isolated_power_demo: bool = false
var network: ConstructionPowerCoverageNetwork
var allocator: PrototypeConstructionPowerAllocator
var hub: PrototypePowerStructure
var pole: PrototypePowerStructure
var _power_started: bool = false
var _tracked: bool = false
var _linked: bool = false
var _power_label: Label
var _generator_button: Button
var _link_button: Button
var _capacity_button: Button
var _wire: MeshInstance3D


func start_power_demo() -> bool:
	if not enable_isolated_power_demo or _power_started or not start_demo():
		return false
	var sandbox := get_parent()
	network = ConstructionPowerCoverageNetwork.new()
	sandbox.add_child(network)
	allocator = PrototypeConstructionPowerAllocator.new()
	sandbox.add_child(allocator)
	if not allocator.configure(network):
		return false
	hub = HUB_SCENE.instantiate() as PrototypePowerStructure
	hub.name = "TutorialPowerHub"
	hub.starts_generator_enabled = false
	sandbox.add_child(hub)
	hub.global_position = HUB_POSITION
	pole = POLE_SCENE.instantiate() as PrototypePowerStructure
	pole.name = "TutorialPowerRelay"
	sandbox.add_child(pole)
	pole.global_position = POLE_POSITION
	if not network.register_node(hub.get_power_node()) or not network.register_node(pole.get_power_node()):
		return false
	_guide("POWER HUB", HUB_POSITION + Vector3.UP * 1.6, Color(1, 0.8, 0.35))
	_guide("RELAY POLE", POLE_POSITION + Vector3.UP * 2.2, Color(0.55, 0.85, 1))
	_wire = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.045, 0.045, HUB_POSITION.distance_to(POLE_POSITION))
	_wire.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.85, 0.75, 0.3)
	_wire.material_override = material
	add_child(_wire)
	_wire.global_position = (HUB_POSITION + POLE_POSITION) * 0.5 + Vector3.UP * 1.1
	_wire.look_at(HUB_POSITION + Vector3.UP * 1.1, Vector3.UP)
	_wire.visible = false
	var layer := CanvasLayer.new()
	layer.layer = 13
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 525)
	layer.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	_power_label = Label.new()
	_power_label.custom_minimum_size = Vector2(430, 115)
	_power_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rows.add_child(_power_label)
	_generator_button = Button.new()
	_generator_button.pressed.connect(_toggle_generator)
	rows.add_child(_generator_button)
	_link_button = Button.new()
	_link_button.pressed.connect(_toggle_link)
	rows.add_child(_link_button)
	_capacity_button = Button.new()
	_capacity_button.pressed.connect(_toggle_capacity)
	rows.add_child(_capacity_button)
	_power_started = true
	_refresh_power()
	return true


func _toggle_generator() -> void:
	if _power_started and _live(hub):
		hub.set_generator_enabled(not hub.generator_enabled)
		_refresh_power()


func _toggle_link() -> void:
	if not _power_started or not _live(hub) or not _live(pole):
		return
	if _linked:
		if network.unlink_nodes(hub.get_power_node(), pole.get_power_node()):
			_linked = false
	else:
		if network.link_nodes(hub.get_power_node(), pole.get_power_node()):
			_linked = true
	_refresh_power()


func _toggle_capacity() -> void:
	if _power_started and _live(hub):
		# Explicit demonstration-only capacity test, not a production upgrade.
		hub.rated_generation = 5 if hub.rated_generation == 12 else 12
		hub.refresh_power_state()
		_refresh_power()


func allocated_power() -> int:
	if not _power_started or not _live(site) or not _tracked or not _live(allocator):
		return 0
	return allocator.get_allocated_units(site)


func _refresh_power() -> void:
	if not _power_started:
		return
	_update_site_power_readiness()
	var online: bool = _live(hub) and hub.available_nameplate_generation() > 0
	var energized: bool = _live(pole) and network.is_energized(pole.get_power_node())
	var generation: int = hub.available_nameplate_generation() if _live(hub) else 0
	var allocated: int = allocated_power()
	_wire.visible = _linked and _live(hub) and _live(pole)
	_generator_button.text = "Turn generator OFF" if online else "Turn generator ON"
	_link_button.text = "Disconnect Hub / Pole" if _linked else "Connect Hub / Pole"
	_capacity_button.text = "Limit generator to 5 units (test)" if _live(hub) and hub.rated_generation == 12 else "Restore 12-unit generator"
	_power_label.text = "CONSTRUCTION POWER — prototype units\nHub output: %d | Relay energized: %s\nSite allocation: %d / %d | Link: %s\nWorker and escrow readiness not granted." % [generation, "YES" if energized else "NO", allocated, DEMAND, "CONNECTED" if _linked else "OPEN"]


func _process(delta: float) -> void:
	super._process(delta)
	if not _power_started:
		return
	_refresh_power()
	if is_instance_valid(_label):
		_label.text = _label.text.replace("No worker or power supplied. Cancel with X; no automatic completion.", "Power test below. No worker or material escrow readiness. Cancel with X.")


# Default power-only behavior; drone tutorial delegates readiness to its coordinator.
func _update_site_power_readiness() -> void:
	if _live(site) and _live(receiver) and receiver.matches_attached_site() and site.job.state == ConstructionJob.State.QUEUED:
		if not _tracked:
			_tracked = allocator.track_site(site, DEMAND)
		# Power-only readiness observation. Materials require separate
		# escrow/worker coordination; neither is granted in this experiment.
		site.job.set_availability(allocated_power() == DEMAND, false, false)
