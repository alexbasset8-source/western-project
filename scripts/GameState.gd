extends Node

signal event_logged(message)
signal event_logged_typed(message, event_type)
signal state_changed
signal player_died(death_record)
signal player_respawned(character_name)

var simulation_paused := false

const PLAYER_SPAWN := Vector2(700, 660)

var characters = []
var roles = {}
var locations = []
var event_log = []
var death_history = []
var player_name = "Voyageur"
var player_generation = 1
var world_day = 1

func _ready() -> void:
	load_initial_data()
	if SaveManager.has_save():
		SaveManager.load_game()
		add_event("Frontier Town reprend depuis la sauvegarde.")
	else:
		characters = _load_json_array("res://data/characters.json")
		ensure_player_character()
		add_event("Frontier Town s'eveille.")

func load_initial_data() -> void:
	roles = _load_json_dictionary("res://data/roles.json")
	locations = _load_json_array("res://data/locations.json")

func ensure_player_character() -> void:
	if not find_character(player_name).is_empty():
		return
	characters.append(_build_player_template(player_name))

func create_new_player(new_name: String) -> void:
	var trimmed_name = new_name.strip_edges()
	if trimmed_name == "":
		trimmed_name = _default_player_name()
	if not find_character(trimmed_name).is_empty():
		trimmed_name = "%s %d" % [trimmed_name, player_generation]
	player_generation += 1
	player_name = trimmed_name
	characters.append(_build_player_template(player_name))
	add_event("%s arrive a Frontier Town." % player_name, "player")
	player_respawned.emit(player_name)
	state_changed.emit()
	SaveManager.save_game()

func _build_player_template(name: String) -> Dictionary:
	return {
		"name": name,
		"role_id": "",
		"state": "alive",
		"temperament": "joueur reel",
		"objective": "choisir sa place dans Frontier Town",
		"caution": 50,
		"aggression": 50,
		"money": 25,
		"bounty": 0,
		"wounds": 0,
		"prison_remaining": 0,
		"mission": {},
		"is_player": true,
		"reputation": {"law": 0, "crime": 0, "commerce": 0, "reliability": 0, "combat": 0}
	}

func _default_player_name() -> String:
	if player_generation <= 1:
		return "Voyageur"
	return "Voyageur %d" % player_generation

func add_event(message: String, event_type: String = "") -> void:
	event_log.push_front({"text": message, "type": event_type})
	if event_log.size() > 30:
		event_log.pop_back()
	event_logged.emit(message)
	event_logged_typed.emit(message, event_type)
	state_changed.emit()

func advance_world_day() -> void:
	world_day += 1
	state_changed.emit()

func get_player() -> Dictionary:
	return find_character(player_name)

func is_player_character(character_name: String) -> bool:
	return character_name == player_name

func get_alive_characters() -> Array:
	var alive = []
	for character in characters:
		if character.get("state", "alive") != "dead":
			alive.append(character)
	return alive

func get_characters_by_role(role_id: String) -> Array:
	var results = []
	for character in get_alive_characters():
		if character.get("state", "alive") == "prisoner":
			continue
		if character.get("role_id", "") == role_id:
			results.append(character)
	return results

func get_role_holders(role_id: String) -> Array:
	return get_characters_by_role(role_id)

func get_random_character_by_role(role_id: String) -> Dictionary:
	var candidates = get_characters_by_role(role_id)
	if candidates.is_empty():
		return {}
	return candidates.pick_random()

func find_character(character_name: String) -> Dictionary:
	for character in characters:
		if character.get("name", "") == character_name:
			return character
	return {}

func mark_wanted(character_name: String, bounty_amount: int) -> void:
	var character = find_character(character_name)
	if character.is_empty() or character.get("state", "alive") == "dead":
		return
	if character.get("state", "alive") == "prisoner":
		return
	character["state"] = "wanted"
	character["bounty"] = int(character.get("bounty", 0)) + bounty_amount
	add_event("Une prime de $%d est placee sur %s." % [character.get("bounty", 0), character_name])

func mark_prisoner(character_name: String) -> void:
	PrisonManager.imprison(character_name)

func mark_dead(character_name: String, cause: String = "") -> void:
	var character = find_character(character_name)
	if character.is_empty():
		return
	if character.get("state", "alive") == "dead":
		return
	var role_id = character.get("role_id", "")
	character["state"] = "dead"
	character["wounds"] = InjuryManager.MAX_WOUNDS
	character["prison_remaining"] = 0
	var death_cause = cause if cause != "" else "mort subite"
	add_event("%s est mort definitivement. (%s)" % [character_name, death_cause], "death")
	RoleManager.release_role(character)
	if is_player_character(character_name):
		_record_player_death(character, role_id, death_cause)
		player_died.emit(death_history[0])
	SaveManager.save_game()

func _record_player_death(character: Dictionary, role_id: String, cause: String) -> void:
	var record = {
		"name": character.get("name", player_name),
		"role": RoleManager.get_role_name(role_id) if role_id != "" else "Aucun",
		"cause": cause,
		"world_day": world_day,
		"money": int(character.get("money", 0)),
		"wounds": int(character.get("wounds", 0))
	}
	death_history.push_front(record)

func adjust_money(character_name: String, amount: int) -> void:
	var character = find_character(character_name)
	if character.is_empty() or character.get("state", "alive") == "dead":
		return
	character["money"] = int(character.get("money", 0)) + amount
	state_changed.emit()

func get_money(character_name: String) -> int:
	var character = find_character(character_name)
	if character.is_empty():
		return 0
	return int(character.get("money", 0))

func get_bounty(character_name: String) -> int:
	var character = find_character(character_name)
	if character.is_empty():
		return 0
	return int(character.get("bounty", 0))

func kill_first_holder(role_id: String) -> void:
	var holders = get_role_holders(role_id)
	if holders.is_empty():
		add_event("Aucun titulaire a faire disparaitre pour %s." % RoleManager.get_role_name(role_id))
		return
	InjuryManager.harm_character(holders[0].get("name", ""), "incident de debug", 3)

func _load_json_array(file_path: String) -> Array:
	var data = _load_json(file_path)
	if typeof(data) == TYPE_ARRAY:
		return data
	return []

func _load_json_dictionary(file_path: String) -> Dictionary:
	var data = _load_json(file_path)
	if typeof(data) == TYPE_DICTIONARY:
		return data
	return {}

func _load_json(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_warning("Impossible de lire %s" % file_path)
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_warning("JSON invalide: %s" % file_path)
	return parsed
