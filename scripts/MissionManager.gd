extends Node

signal mission_updated(character_name)

var missions_by_role: Dictionary = {}

func _ready() -> void:
	_load_missions()
	RoleManager.role_promoted.connect(_on_role_promoted)
	call_deferred("_ensure_active_missions")

func _ensure_active_missions() -> void:
	for character in GameState.characters:
		if character.get("name", "") == GameState.player_name:
			if character.get("role_id", "") != "" and character.get("mission", {}).is_empty():
				assign_mission(character)

func _load_missions() -> void:
	var file = FileAccess.open("res://data/missions.json", FileAccess.READ)
	if file == null:
		push_warning("Impossible de lire missions.json")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		missions_by_role = parsed

func assign_mission(character: Dictionary) -> void:
	var role_id = character.get("role_id", "")
	if role_id == "":
		return
	var pool: Array = missions_by_role.get(role_id, [])
	if pool.is_empty():
		return
	var mission_def: Dictionary = pool.pick_random()
	character["mission"] = {
		"id": mission_def.get("id", ""),
		"title": mission_def.get("title", "Mission"),
		"goal": int(mission_def.get("goal", 1)),
		"progress": 0,
		"action": mission_def.get("action", ""),
		"reward_money": int(mission_def.get("reward_money", 0)),
		"reward_rep": mission_def.get("reward_rep", {})
	}
	GameState.add_event("Nouvelle mission : %s" % mission_def.get("title", "Mission"))
	mission_updated.emit(character.get("name", ""))
	GameState.state_changed.emit()

func record_progress(character_name: String, action_type: String) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty():
		return
	var mission: Dictionary = character.get("mission", {})
	if mission.is_empty():
		return
	if mission.get("action", "") != action_type:
		return
	mission["progress"] = int(mission.get("progress", 0)) + 1
	character["mission"] = mission
	if int(mission.get("progress", 0)) >= int(mission.get("goal", 1)):
		_complete_mission(character)
	else:
		GameState.add_event(
			"Mission %s : %d/%d" % [mission.get("title", ""), mission.get("progress", 0), mission.get("goal", 1)]
		)
		mission_updated.emit(character_name)
		GameState.state_changed.emit()

func _complete_mission(character: Dictionary) -> void:
	var mission: Dictionary = character.get("mission", {})
	var character_name = character.get("name", "")
	var reward_money = int(mission.get("reward_money", 0))
	var reward_rep: Dictionary = mission.get("reward_rep", {})
	GameState.add_event("Mission accomplie : %s (+%d$)" % [mission.get("title", ""), reward_money])
	if reward_money > 0:
		GameState.adjust_money(character_name, reward_money)
	for rep_id in reward_rep.keys():
		ReputationManager.add_reputation(character, rep_id, int(reward_rep[rep_id]))
	character["mission"] = {}
	mission_updated.emit(character_name)
	assign_mission(character)
	SaveManager.save_game()

func get_mission_text(character_name: String) -> String:
	var character = GameState.find_character(character_name)
	if character.is_empty():
		return "Aucune mission"
	var mission: Dictionary = character.get("mission", {})
	if mission.is_empty():
		if character.get("role_id", "") == "":
			return "Rejoignez un role pour recevoir une mission"
		return "Aucune mission active"
	return "%s (%d/%d)" % [mission.get("title", "?"), mission.get("progress", 0), mission.get("goal", 1)]

func _on_role_promoted(character_name: String, _role_id: String) -> void:
	var character = GameState.find_character(character_name)
	if not character.is_empty():
		assign_mission(character)

func _get_mission_def(role_id: String, mission_id: String) -> Dictionary:
	for mission_def in missions_by_role.get(role_id, []):
		if mission_def.get("id", "") == mission_id:
			return mission_def
	return {}
