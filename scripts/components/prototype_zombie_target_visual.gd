extends Node3D

# =============================================================================
# PROTOTYPE ENEMY HEALTH DISPLAY
# =============================================================================

# Read-only placeholder feedback until proper enemy animations and UI exist.
# This script does not apply combat damage or modify health.

@onready var health: CombatHealthComponent = $HealthComponent
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var health_label: Label3D = $HealthLabel

var last_displayed_health: int = -1


func _ready() -> void:
	_refresh_health_visual()


# =============================================================================
# REFRESH HEALTH AND DEFEATED STATE
# =============================================================================

func _process(_delta: float) -> void:
	if not is_instance_valid(health):
		return
	if health.current_health != last_displayed_health:
		_refresh_health_visual()


func _refresh_health_visual() -> void:
	if not is_instance_valid(health):
		return
	if not is_instance_valid(health_label):
		return

	last_displayed_health = health.current_health
	if health.is_alive():
		health_label.text = (
			"TARGET HP: "
			+ str(health.current_health)
			+ " / "
			+ str(health.max_health)
		)
		if is_instance_valid(body_mesh):
			body_mesh.visible = true
	else:
		health_label.text = "TARGET DEFEATED"
		if is_instance_valid(body_mesh):
			body_mesh.visible = false
