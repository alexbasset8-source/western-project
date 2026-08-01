extends Node

const REPUTATIONS := ["law", "crime", "commerce", "reliability", "combat"]

## Minimum reputation required for specific actions
const ACTION_REPUTATION_REQUIREMENTS := {
	"extort_protection_money": {"crime": 30},
	"negotiate_surrender": {"law": 20},
	"bribe_officials": {"crime": 25},
	"smuggle_contraband": {"crime": 20},
	"organize_posse": {"law": 15},
	"enforce_curfew": {"law": 25}
}

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

## Decay reputation by 1 point per hour for all factions
func decay_reputation(character: Dictionary) -> void:
	var reputations: Dictionary = character.get("reputation", {})
	var has_decayed := false
	for reputation_id in REPUTATIONS:
		var current = reputations.get(reputation_id, 0)
		if current > 0:
			reputations[reputation_id] = max(0, current - 1)
			has_decayed = true
		elif current < 0:
			reputations[reputation_id] = min(0, current + 1)
			has_decayed = true
	if has_decayed:
		character["reputation"] = reputations
		GameState.state_changed.emit()

## Check if a character can perform an action based on reputation requirements
func can_perform_action(character: Dictionary, action_id: String) -> bool:
	if not ACTION_REPUTATION_REQUIREMENTS.has(action_id):
		return true
	var requirements := ACTION_REPUTATION_REQUIREMENTS[action_id]
	for reputation_id in requirements.keys():
		var required := requirements[reputation_id]
		var current := get_reputation(character, reputation_id)
		if current < required:
			return false
	return true

## Get the missing reputation requirements for an action
func get_missing_requirements(character: Dictionary, action_id: String) -> Dictionary:
	var missing := {}
	if not ACTION_REPUTATION_REQUIREMENTS.has(action_id):
		return missing
	var requirements := ACTION_REPUTATION_REQUIREMENTS[action_id]
	for reputation_id in requirements.keys():
		var required := requirements[reputation_id]
		var current := get_reputation(character, reputation_id)
		if current < required:
			missing[reputation_id] = {"current": current, "required": required}
	return missing

## Get reputation summary as a formatted string
func get_reputation_summary(character: Dictionary) -> String:
	var reputations: Dictionary = character.get("reputation", {})
	var parts := []
	for reputation_id in REPUTATIONS:
		var value := reputations.get(reputation_id, 0)
		parts.append("%s:%d" % [reputation_id, value])
	return "Reputation: %s" % ", ".join(parts)

## Get reputation display with icons for UI
func get_reputation_display(character: Dictionary) -> String:
	var reputations: Dictionary = character.get("reputation", {})
	var parts := []
	for reputation_id in REPUTATIONS:
		var value := reputations.get(reputation_id, 0)
		var icon := _get_reputation_icon(reputation_id, value)
		parts.append("%s %d" % [icon, value])
	return " ".join(parts)

func _get_reputation_icon(reputation_id: String, value: int) -> String:
	match reputation_id:
		"law":
			if value >= 50:
				return "⚖️"
			elif value >= 25:
				return "⚖️"
			elif value >= 0:
				return "⚖️"
			else:
				return "⚠️"
		"crime":
			if value >= 50:
				return "🎭"
			elif value >= 25:
				return "🎭"
			elif value >= 0:
				return "🎭"
			else:
				return "⚠️"
		"commerce":
			if value >= 50:
				return "💰"
			elif value >= 25:
				return "💰"
			elif value >= 0:
				return "💰"
			else:
				return "⚠️"
		"reliability":
			if value >= 50:
				return "🤝"
			elif value >= 25:
				return "🤝"
			elif value >= 0:
				return "🤝"
			else:
				return "⚠️"
		"combat":
			if value >= 50:
				return "⚔️"
			elif value >= 25:
				return "⚔️"
			elif value >= 0:
				return "⚔️"
			else:
				return "⚠️"
		_:
			return "?"
