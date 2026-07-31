extends Node

signal role_promoted(character_name, role_id)
signal queue_changed

var queues = {
	"sheriff": [],
	"deputy": [],
	"merchant": [],
	"bounty_hunter": [],
	"brigand": [],
	"citizen": []
}

func apply_for_role(character_name, role_id):
	var character = GameState.find_character(character_name)
	if character.is_empty():
		return
	if character.get("state", "alive") == "dead":
		return
	if character.get("state", "alive") == "prisoner":
		return
	if character.get("role_id", "") == role_id:
		GameState.add_event("%s occupe deja le role %s." % [character_name, get_role_name(role_id)])
		return
	remove_from_all_queues(character_name)
	if has_vacancy(role_id):
		assign_role(character, role_id)
	else:
		join_queue(character_name, role_id)

func join_queue(character_name, role_id):
	if not queues.has(role_id):
		queues[role_id] = []
	if queues[role_id].has(character_name):
		return
	queues[role_id].append(character_name)
	GameState.add_event("%s rejoint la file %s." % [character_name, get_role_name(role_id)])
	_emit_queue_changed()

func leave_queue(character_name: String, role_id: String) -> void:
	if not queues.has(role_id):
		return
	if not queues[role_id].has(character_name):
		return
	queues[role_id].erase(character_name)
	GameState.add_event("%s quitte la file %s." % [character_name, get_role_name(role_id)])
	_emit_queue_changed()

func get_queue_position(character_name: String, role_id: String) -> int:
	if not queues.has(role_id):
		return -1
	return queues[role_id].find(character_name)

func is_in_queue(character_name: String, role_id: String) -> bool:
	return get_queue_position(character_name, role_id) >= 0

func get_player_queue_role(character_name: String) -> String:
	for role_id in queues.keys():
		if is_in_queue(character_name, role_id):
			return role_id
	return ""

func remove_from_all_queues(character_name):
	for queue_role in queues.keys():
		queues[queue_role].erase(character_name)
	_emit_queue_changed()

## Vide toutes les files d'attente. Utilise au demarrage d'une nouvelle partie (BG-002).
func reset_queues() -> void:
	for role_id in queues.keys():
		queues[role_id] = []
	_emit_queue_changed()

func has_vacancy(role_id):
	var role = GameState.roles.get(role_id, {})
	var slots = int(role.get("slots", 0))
	return GameState.get_role_holders(role_id).size() < slots

func assign_role(character, role_id):
	var previous_role = character.get("role_id", "")
	if previous_role != "":
		character["role_id"] = ""
		promote_next(previous_role)
	character["role_id"] = role_id
	GameState.add_event("%s devient %s." % [character.get("name", "Quelqu'un"), get_role_name(role_id)], "promotion")
	role_promoted.emit(character.get("name", ""), role_id)
	GameState.state_changed.emit()

func release_role(character):
	var role_id = character.get("role_id", "")
	if role_id == "":
		return
	character["role_id"] = ""
	character["mission"] = {}
	promote_next(role_id)

func promote_next(role_id):
	if not queues.has(role_id):
		return
	while not queues[role_id].is_empty():
		var candidate_name = queues[role_id].pop_front()
		var candidate = GameState.find_character(candidate_name)
		if not candidate.is_empty() and candidate.get("state", "alive") not in ["dead", "prisoner"]:
			assign_role(candidate, role_id)
			_emit_queue_changed()
			return
	GameState.add_event("Le role %s reste vacant." % get_role_name(role_id))

func _emit_queue_changed() -> void:
	queue_changed.emit()
	GameState.state_changed.emit()

func get_role_name(role_id):
	var role = GameState.roles.get(role_id, {})
	return role.get("name", role_id)
