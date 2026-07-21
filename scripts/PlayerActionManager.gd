extends Node

const ACTION_COOLDOWN := 4.0

var _cooldown_remaining := 0.0

func _process(delta: float) -> void:
	if _cooldown_remaining > 0.0:
		_cooldown_remaining = max(0.0, _cooldown_remaining - delta)
		# Rafraîchir le HUD uniquement en fin de cooldown pour éviter le spam
		if _cooldown_remaining == 0.0:
			GameState.state_changed.emit()

func get_cooldown_remaining() -> float:
	return _cooldown_remaining

func is_on_cooldown() -> bool:
	return _cooldown_remaining > 0.0

func _start_cooldown() -> void:
	_cooldown_remaining = ACTION_COOLDOWN
	GameState.state_changed.emit()

func perform_role_action() -> void:
	var player = GameState.get_player()
	if player.is_empty():
		return
	if player.get("state", "alive") == "dead":
		GameState.add_event("Vous ne pouvez plus agir.")
		return
	if player.get("state", "alive") == "prisoner":
		PrisonManager.wait_turn(GameState.player_name)
		return

	if is_on_cooldown():
		GameState.add_event("Recuperation en cours (%.0fs)..." % _cooldown_remaining)
		return

	var role_id = player.get("role_id", "")
	if not ZoneManager.can_perform_role_action(role_id):
		GameState.add_event("Vous n'etes pas au bon endroit pour agir.")
		GameState.add_event(ZoneManager.get_zone_requirement_hint(role_id))
		return

	match role_id:
		"sheriff":
			TownActions.attempt_arrest(player)
		"bounty_hunter":
			TownActions.track_bounty(player)
		"merchant":
			TownActions.transport_goods(player)
		"brigand":
			TownActions.attack_convoy(player)
		_:
			consult_queues()
	_start_cooldown()
	SaveManager.save_game()

func attempt_escape() -> void:
	var player = GameState.get_player()
	if player.is_empty() or player.get("state", "alive") != "prisoner":
		return
	PrisonManager.attempt_escape(GameState.player_name)
	SaveManager.save_game()

func consult_queues() -> void:
	GameState.add_event("%s consulte le tableau des roles." % GameState.player_name)
	for role_id in GameState.roles.keys():
		var holder_names = []
		for character in GameState.get_role_holders(role_id):
			holder_names.append(character.get("name", "?"))
		var queue = RoleManager.queues.get(role_id, [])
		var holder_text = "vacant"
		if not holder_names.is_empty():
			holder_text = ", ".join(holder_names)
		var queue_text = "vide"
		if not queue.is_empty():
			queue_text = ", ".join(queue)
		GameState.add_event(
			"%s : %s | File : %s" % [RoleManager.get_role_name(role_id), holder_text, queue_text]
		)
	GameState.add_event("Touches 1-4 pour rejoindre une file.")

func get_action_hint() -> String:
	var player = GameState.get_player()
	if player.is_empty():
		return ""
	if player.get("state", "alive") == "dead":
		return "Mort definitive — creez un nouveau personnage"
	if player.get("state", "alive") == "prisoner":
		var remaining = PrisonManager.get_sentence_remaining(GameState.player_name)
		return "E : attendre (%d tours) | R : tenter l'evasion" % remaining

	var role_id = player.get("role_id", "")
	var base_hint := ""
	match role_id:
		"sheriff":
			base_hint = "E : arreter un brigand recherche"
		"bounty_hunter":
			base_hint = "E : traquer une prime"
		"merchant":
			base_hint = "E : lancer un transport"
		"brigand":
			base_hint = "E : attaquer un convoi"
		_:
			base_hint = "E : consulter les files (1-4 pour rejoindre)"

	if is_on_cooldown():
		return "Recuperation : %.0fs" % _cooldown_remaining

	if ZoneManager.can_perform_role_action(role_id):
		var mission_hint = MissionManager.get_mission_text(GameState.player_name)
		if mission_hint != "Aucune mission" and not mission_hint.begins_with("Rejoignez"):
			return "%s | %s" % [base_hint, mission_hint]
		return base_hint
	return "%s — %s" % [base_hint, ZoneManager.get_zone_requirement_hint(role_id)]
