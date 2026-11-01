extends ItemPortComponent
class_name TurretAmmunitionPort

# =============================================================================
# AMMUNITION-ONLY BUILDING INPUT
# =============================================================================

# This specialized port reuses the same physical connection and inventory
# transfer checks as any other building input, but only accepts one ammo type.
# No generic inventory or recipe-acceptance behavior is changed.

@export var accepted_ammunition: ItemDefinition


func can_accept_item(
	item: ItemDefinition,
	amount: int = 1
) -> bool:
	if not is_instance_valid(accepted_ammunition):
		return false
	if item != accepted_ammunition:
		return false
	return super.can_accept_item(item, amount)
