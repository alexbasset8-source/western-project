extends Node

const SAVE_PATH := "user://frontier_town_save.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var data = {
		"player_name": GameState.player_name,
		"player_generation": GameState.player_generation,
		"characters": GameState.characters,
		"death_history": GameState.death_history,
		"world_day": GameState.world_day,
		"event_log": GameState.event_log,
		"queues": RoleManager.queues
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Impossible d'ecrire la sauvegarde.")
		return
	file.store_string(JSON.stringify(data, "	"))

func load_game() -> bool:
	if not has_save():
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	GameState.player_name = parsed.get("player_name", GameState.player_name)
	GameState.player_generation = int(parsed.get("player_generation", 1))
	GameState.characters = parsed.get("characters", [])
	GameState.death_history = parsed.get("death_history", [])
	GameState.world_day = int(parsed.get("world_day", 1))
	GameState.event_log = parsed.get("event_log", [])
	var queues = parsed.get("queues", {})
	for role_id in RoleManager.queues.keys():
		if queues.has(role_id):
			RoleManager.queues[role_id] = queues[role_id]
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
