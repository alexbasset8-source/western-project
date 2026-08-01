extends Node

var elapsed = 0.0
var event_interval = 8.0

func _process(delta):
	if GameState.simulation_paused:
		return
	elapsed += delta
	if elapsed >= event_interval:
		elapsed = 0.0
		trigger_simulated_event()

func trigger_simulated_event():
	GameState.advance_world_day()
	PrisonManager.tick_sentences()
	# "role_action" pese 3x pour garder une frequence d'activite liee aux
	# roles proche de l'ancien systeme (transport_goods/convoy_attack/arrest
	# valaient 3 entrees sur 6). Elle couvre maintenant TOUTES les actions de
	# TOUS les roles (BG-001-P2), pas seulement les 3 actions historiques.
	var event_types = ["role_action", "role_action", "role_action", "bounty_posted", "duel", "death"]
	var event_type = event_types.pick_random()
	match event_type:
		"role_action":
			_trigger_random_role_action()
		"bounty_posted":
			TownActions.post_bounty_on_brigand()
		"duel":
			var a = _random_non_prisoner()
			var b = _random_non_prisoner()
			TownActions.duel(a, b)
		"death":
			TownActions.deadly_incident()
	SaveManager.save_game()

## Choisit un personnage vivant ayant un role a actions, puis une de ses
## actions au hasard (parmi PlayerActionManager.ROLE_ACTIONS), et l'execute
## via le module correspondant. Couvre les 6 roles et leurs ~28 actions au
## lieu des 3 actions historiques uniquement (dette technique BG-001-P2).
## Note : comme pour l'ancien systeme, le personnage tire au sort peut etre
## le joueur lui-meme (get_alive_characters() ne l'exclut pas).
func _trigger_random_role_action() -> void:
	var candidates = []
	for character in GameState.get_alive_characters():
		var role_id = character.get("role_id", "")
		if PlayerActionManager.ROLE_ACTIONS.has(role_id):
			candidates.append(character)
	if candidates.is_empty():
		return
	var actor = candidates.pick_random()
	var role_id = actor.get("role_id", "")
	var actions = PlayerActionManager.ROLE_ACTIONS[role_id]
	var action_id: String = actions.pick_random().get("id", "")
	var module = TownActions.get_module(role_id)
	if module == null or not module.has_method(action_id):
		return
	module.call(action_id, actor)

func _random_non_prisoner():
	var candidates = []
	for character in GameState.get_alive_characters():
		if character.get("state", "alive") != "prisoner":
			candidates.append(character)
	if candidates.is_empty():
		return {}
	return candidates.pick_random()
