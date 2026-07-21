extends Node

const REPUTATIONS := ["law", "crime", "commerce", "reliability", "combat"]

func add_reputation(character: Dictionary, reputation_id: String, amount: int) -> void:
	if not reputation_id in REPUTATIONS:
		return
	var reputations: Dictionary = character.get("reputation", {})
	reputations[reputation_id] = int(reputations.get(reputation_id, 0)) + amount
	character["reputation"] = reputations
	GameState.state_changed.emit()

func get_reputation(character: Dictionary, reputation_id: String) -> int:
	var reputations: Dictionary = character.get("reputation", {})
	return int(reputations.get(reputation_id, 0))
