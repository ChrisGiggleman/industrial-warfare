extends Node
class_name PlannedEndpointClaimBroker

# =============================================================================
# SHARED BLUEPRINT ENDPOINT CLAIMS — E3C0
# =============================================================================
# Atomic ownership for planned conveyor/belt and conveyor/building routes.
# A conveyor's "in" or "out" key is identical across E2b and E3b.
# Owner tokens are registry-scoped, never plain numeric reservation IDs.
# The broker does not connect real ports, move cargo, or own construction.

const BELT_INPUT = "in"
const BELT_OUTPUT = "out"
const BUILDING_INPUT = "building_input"
const BUILDING_OUTPUT = "building_output"

var _claims: Dictionary = {}
var _owner_keys: Dictionary = {}


func claim_pair(
	first_site: ConstructionSite,
	first_side: String,
	second_site: ConstructionSite,
	second_side: String,
	owner_token: String
) -> bool:
	if owner_token.is_empty() or _owner_keys.has(owner_token):
		return false
	if not _eligible(first_site, first_side):
		return false
	if not _eligible(second_site, second_side):
		return false
	var first_key := _key(first_site, first_side)
	var second_key := _key(second_site, second_side)
	if first_key == second_key:
		return false
	if _claims.has(first_key) or _claims.has(second_key):
		return false

	# Both entries are inserted together or neither is inserted.
	_claims[first_key] = owner_token
	_claims[second_key] = owner_token
	_owner_keys[owner_token] = [first_key, second_key]
	return true


func release_owner(owner_token: String) -> bool:
	if not _owner_keys.has(owner_token):
		return false
	var keys: Array = _owner_keys[owner_token]
	for value: Variant in keys:
		var key: String = value
		# An old owner must not release a subsequently reassigned key.
		if _claims.get(key, "") == owner_token:
			_claims.erase(key)
	_owner_keys.erase(owner_token)
	return true


func is_claimed(site: ConstructionSite, side: String) -> bool:
	if not is_instance_valid(site):
		return false
	if not _valid_side(side):
		return false
	return _claims.has(_key(site, side))


func owner_of(site: ConstructionSite, side: String) -> String:
	if not is_instance_valid(site) or not _valid_side(side):
		return ""
	return _claims.get(_key(site, side), "")


func claim_count() -> int:
	return _claims.size()


func owner_count() -> int:
	return _owner_keys.size()


func _eligible(site: ConstructionSite, side: String) -> bool:
	if not is_instance_valid(site):
		return false
	if not site.is_inside_tree() or site.is_queued_for_deletion():
		return false
	if not site.accepts_planned_connections():
		return false
	if not _valid_side(side) or not is_instance_valid(site.target_definition):
		return false
	var is_belt := site.target_definition.building_id == &"conveyor_belt"
	if is_belt:
		return side == BELT_INPUT or side == BELT_OUTPUT
	return (
		side == BUILDING_INPUT or side == BUILDING_OUTPUT
		or side.begins_with(BUILDING_INPUT + ":InputPort")
		or side.begins_with(BUILDING_OUTPUT + ":OutputPort")
	)


func _valid_side(side: String) -> bool:
	return (
		side in [BELT_INPUT, BELT_OUTPUT, BUILDING_INPUT, BUILDING_OUTPUT]
		or side.begins_with(BUILDING_INPUT + ":InputPort")
		or side.begins_with(BUILDING_OUTPUT + ":OutputPort")
	)


func _key(site: ConstructionSite, side: String) -> String:
	# Immutable string: release_owner() is safe after the site is freed.
	return "%d:%s" % [site.get_instance_id(), side]
