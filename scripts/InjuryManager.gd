extends Node

const MAX_WOUNDS := 3

func harm_character(character_name: String, cause: String = "", severity: int = 1) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") == "dead":
		return
	var wounds = int(character.get("wounds", 0)) + severity
	character["wounds"] = wounds
	if wounds >= MAX_WOUNDS:
		GameState.mark_dead(character_name, cause if cause != "" else "blessures mortelles")
		return
	var wound_label = _wound_label(wounds)
	GameState.add_event("%s est blesse (%s). %s" % [character_name, wound_label, cause])
	GameState.state_changed.emit()

func heal_character(character_name: String, amount: int = 1) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") == "dead":
		return
	var wounds = max(0, int(character.get("wounds", 0)) - amount)
	if wounds == int(character.get("wounds", 0)):
		return
	character["wounds"] = wounds
	GameState.add_event("%s recupere. Blessures : %d/%d." % [character_name, wounds, MAX_WOUNDS])
	GameState.state_changed.emit()

func get_wounds(character_name: String) -> int:
	var character = GameState.find_character(character_name)
	if character.is_empty():
		return 0
	return int(character.get("wounds", 0))

func _wound_label(wounds: int) -> String:
	match wounds:
		1:
			return "legere"
		2:
			return "grave"
		_:
			return "critique"
