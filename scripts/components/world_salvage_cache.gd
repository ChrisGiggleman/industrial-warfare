extends Node3D
class_name WorldSalvageCache

# =============================================================================
# WORLD SALVAGE — RECOVERED MATERIALS
# =============================================================================

# A world-owned placeholder for materials recovered from destruction.
# No pickup, persistence, or salvage-loss balancing exists yet.
# This node is not player_built, so zombies never treat it as a factory.

@onready var inventory: InventoryComponent = $InventoryComponent
@onready var status_label: Label3D = $SalvageLabel


# =============================================================================
# UPDATE PLACEHOLDER SALVAGE LABEL
# =============================================================================

func refresh_display() -> void:
	if not is_instance_valid(inventory) or not is_instance_valid(status_label):
		return

	var total: int = inventory.get_total_amount()
	if total == 0:
		status_label.text = "WRECKAGE"
	else:
		status_label.text = "SALVAGE: " + str(total)
