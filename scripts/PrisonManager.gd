extends Node

const PRISON_CELL := Vector2(575, 465)
const DEFAULT_SENTENCE := 4

func imprison(character_name: String, sentence: int = DEFAULT_SENTENCE) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") == "dead":
		return
	if character.get("role_id", "") != "":
		RoleManager.release_role(character)
	character["state"] = "prisoner"
	character["prison_remaining"] = sentence
	character["bounty"] = 0
	GameState.add_event("%s est enferme a la prison de Frontier Town (%d tours)." % [character_name, sentence])
	if character_name == GameState.player_name:
		_teleport_player_to_cell()
	GameState.state_changed.emit()
	SaveManager.save_game()

func wait_turn(character_name: String) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") != "prisoner":
		return
	var remaining = max(0, int(character.get("prison_remaining", 0)) - 1)
	character["prison_remaining"] = remaining
	GameState.add_event("%s attend en cellule. Liberation dans %d tour(s)." % [character_name, remaining])
	if remaining <= 0:
		release(character_name)
	else:
		GameState.state_changed.emit()

func attempt_escape(character_name: String) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") != "prisoner":
		return
	GameState.add_event("%s tente de s'evader de la prison." % character_name)
	if randf() < 0.35:
		release(character_name)
		GameState.add_event("%s reussit son evasion." % character_name)
		ReputationManager.add_reputation(character, "crime", 3)
	else:
		character["prison_remaining"] = int(character.get("prison_remaining", 0)) + 1
		InjuryManager.harm_character(character_name, "evasion ratee", 1)
		GameState.add_event("Les gardes renforcent la surveillance sur %s." % character_name)

func tick_sentences() -> void:
	for character in GameState.characters:
		if character.get("state", "alive") != "prisoner":
			continue
		var remaining = max(0, int(character.get("prison_remaining", 0)) - 1)
		character["prison_remaining"] = remaining
		if remaining <= 0:
			release(character.get("name", ""))

func release(character_name: String) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") != "prisoner":
		return
	character["state"] = "alive"
	character["prison_remaining"] = 0
	GameState.add_event("%s est libere de prison." % character_name)
	if character_name == GameState.player_name:
		_teleport_player_to_town()
	GameState.state_changed.emit()
	SaveManager.save_game()

func get_sentence_remaining(character_name: String) -> int:
	var character = GameState.find_character(character_name)
	if character.is_empty():
		return 0
	return int(character.get("prison_remaining", 0))

func _teleport_player_to_cell() -> void:
	var player_node = _get_player_node()
	if player_node:
		player_node.global_position = PRISON_CELL

func _teleport_player_to_town() -> void:
	var player_node = _get_player_node()
	if player_node:
		player_node.global_position = GameState.PLAYER_SPAWN

func _get_player_node() -> Node2D:
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null or tree.current_scene == null:
		return null
	return tree.current_scene.get_node_or_null("Player") as Node2D
