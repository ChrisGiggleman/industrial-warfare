extends RefCounted
class_name BuildHotbarConfiguration

# =============================================================================
# BUILD HOTBAR — SLOT ASSIGNMENT DATA MODEL
# =============================================================================

# A standalone model for player-configurable 1–9 build assignments.
# The model stores stable BuildingDefinition.building_id values, not
# positions in WorldInteraction.buildable_definitions.
#
# This first phase does not replace live number-key routing or modify
# conveyor snapping. Build Catalog UI and on-disk persistence come
# after the standalone regression succeeds.

const SLOT_COUNT: int = 9
const SAVE_VERSION: int = 1

var _definitions: Dictionary = {}
var _definition_order: Array[StringName] = []
var _unlocked: Dictionary = {}
var _slots: Array[StringName] = []


func _init() -> void:
	for index: int in range(SLOT_COUNT):
		_slots.append(&"")


# =============================================================================
# CATALOG — REGISTER DEFINITIONS AND DEFAULT PROTOTYPE UNLOCKS
# =============================================================================

# All currently available prototype buildings begin unlocked. Progression
# can later call set_unlocked() to enforce research requirements.

func configure(definitions: Array[BuildingDefinition]) -> void:
	_definitions.clear()
	_definition_order.clear()
	_unlocked.clear()

	for definition: BuildingDefinition in definitions:
		if not is_instance_valid(definition):
			continue
		var identity: StringName = definition.building_id
		if identity == &"" or not is_instance_valid(definition.building_scene):
			continue
		if _definitions.has(identity):
			# Never allow duplicate IDs to produce ambiguous slot mapping.
			continue

		_definitions[identity] = definition
		_definition_order.append(identity)
		_unlocked[identity] = true

	clear_all()


func get_catalog() -> Array[BuildingDefinition]:
	var result: Array[BuildingDefinition] = []
	for identity: StringName in _definition_order:
		result.append(_definitions[identity] as BuildingDefinition)
	return result


func get_unlocked_catalog() -> Array[BuildingDefinition]:
	var result: Array[BuildingDefinition] = []
	for identity: StringName in _definition_order:
		if is_unlocked(identity):
			result.append(_definitions[identity] as BuildingDefinition)
	return result


func is_unlocked(identity: StringName) -> bool:
	return _definitions.has(identity) and _unlocked.get(identity, false)


func set_unlocked(identity: StringName, allowed: bool) -> bool:
	if not _definitions.has(identity):
		return false

	_unlocked[identity] = allowed
	if not allowed:
		# Unequipping a newly locked item must not delete any actual
		# player-built structure or change the rest of the quickbar.
		for index: int in range(SLOT_COUNT):
			if _slots[index] == identity:
				_slots[index] = &""

	return true


# =============================================================================
# DEFAULT HOTBAR — MATCH CURRENT BUILD MODE UNTIL IT IS REPLACED
# =============================================================================

func reset_to_default() -> void:
	clear_all()
	var slot_index: int = 0
	for identity: StringName in _definition_order:
		if slot_index >= SLOT_COUNT:
			break
		if not is_unlocked(identity):
			continue
		_slots[slot_index] = identity
		slot_index += 1


# =============================================================================
# QUICKBAR — LOOKUP, ASSIGN, SWAP AND CLEAR
# =============================================================================

func get_id(slot_index: int) -> StringName:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return &""
	return _slots[slot_index]


func get_definition(slot_index: int) -> BuildingDefinition:
	var identity: StringName = get_id(slot_index)
	if not is_unlocked(identity):
		return null
	return _definitions[identity] as BuildingDefinition


func find_slot(identity: StringName) -> int:
	if identity == &"":
		return -1
	return _slots.find(identity)


func clear_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false
	_slots[slot_index] = &""
	return true


func clear_all() -> void:
	for index: int in range(SLOT_COUNT):
		_slots[index] = &""


# An already assigned building moves to the requested slot; the previous
# occupant swaps into its former slot. A newly equipped building replaces
# only the destination slot, making it available in the full catalog.

func assign(slot_index: int, identity: StringName) -> bool:
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return false
	if not is_unlocked(identity):
		return false

	var previous_slot: int = find_slot(identity)
	if previous_slot == slot_index:
		return true

	var displaced: StringName = _slots[slot_index]
	_slots[slot_index] = identity

	if previous_slot != -1:
		_slots[previous_slot] = displaced

	return true


# =============================================================================
# PERSISTENCE PAYLOAD — STABLE IDENTIFIERS, NO FILE I/O YET
# =============================================================================

# The future save system can persist this JSON-compatible Dictionary.
# Store strings, not a scene array index or a serialized Resource pointer.

func to_save_data() -> Dictionary:
	var ids: Array[String] = []
	for identity: StringName in _slots:
		ids.append(str(identity))
	return {
		"version": SAVE_VERSION,
		"slots": ids
	}


# Reject malformed documents without altering the current assignment.
# Unknown/locked IDs and duplicate IDs are dropped from restored slots.

func restore_save_data(data: Dictionary) -> bool:
	if data.get("version", -1) != SAVE_VERSION:
		return false
	var raw_slots: Variant = data.get("slots")
	if not (raw_slots is Array):
		return false
	if raw_slots.size() != SLOT_COUNT:
		return false

	var restored: Array[StringName] = []
	var used: Dictionary = {}
	for raw_id: Variant in raw_slots:
		if not (raw_id is String or raw_id is StringName):
			return false
		var identity := StringName(str(raw_id))
		if (
			identity == &""
			or not is_unlocked(identity)
			or used.has(identity)
		):
			restored.append(&"")
			continue
		used[identity] = true
		restored.append(identity)

	_slots = restored
	return true
