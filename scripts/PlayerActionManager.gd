extends Node

const ACTION_COOLDOWN := 4.0

## Actions disponibles par role, presentees dans un menu au joueur (TCK4/TCK5).
## Toutes les fonctions listees existent deja dans TownActions.gd (BG-001-P2) ;
## ce dictionnaire est la seule source de verite pour savoir quel role voit
## quelles actions - un Sheriff ne voit donc jamais les actions d'un Brigand.
const ROLE_ACTIONS := {
	"sheriff": [
		{"id": "attempt_arrest", "label": "Arreter un brigand recherche"},
		{"id": "patrol_town", "label": "Patrouiller en ville"},
		{"id": "interrogate_witness", "label": "Interroger des temoins"},
		{"id": "organize_posse", "label": "Organiser une posse"},
		{"id": "enforce_curfew", "label": "Imposer un couvre-feu"},
	],
	"deputy": [
		{"id": "assist_arrest", "label": "Assister une arrestation"},
		{"id": "scout_perimeter", "label": "Patrouiller la peripherie"},
		{"id": "deliver_warrant", "label": "Remettre un mandat"},
		{"id": "guard_prisoner", "label": "Surveiller les prisonniers"},
	],
	"merchant": [
		{"id": "transport_goods", "label": "Transporter des marchandises"},
		{"id": "negotiate_prices", "label": "Negocier les prix"},
		{"id": "bribe_officials", "label": "Corrompre des officiels"},
		{"id": "smuggle_contraband", "label": "Faire passer de la contrebande"},
		{"id": "setup_trade_stand", "label": "Installer un stand de commerce"},
	],
	"bounty_hunter": [
		{"id": "track_bounty", "label": "Traquer une prime"},
		{"id": "investigate_bounty", "label": "Enqueter sur une prime"},
		{"id": "set_trap", "label": "Poser un piege"},
		{"id": "follow_trail", "label": "Suivre une piste"},
		{"id": "negotiate_surrender", "label": "Negocier une reddition"},
	],
	"brigand": [
		{"id": "attack_convoy", "label": "Attaquer un convoi"},
		{"id": "ambush_merchants", "label": "Tendre une embuscade aux marchands"},
		{"id": "sabotage_town_infrastructure", "label": "Saboter les infrastructures"},
		{"id": "extort_protection_money", "label": "Extorquer de l'argent de protection"},
		{"id": "hide_loot", "label": "Cacher le butin"},
	],
	"citizen": [
		{"id": "report_crime", "label": "Signaler un crime"},
		{"id": "gossip", "label": "Propager une rumeur"},
		{"id": "form_militia", "label": "Former une milice"},
		{"id": "protest", "label": "Organiser une protestation"},
	],
}

## Emis quand le joueur doit choisir une action parmi celles de son role (TCK4/TCK5).
## L'UI est responsable d'afficher le menu, de griser les actions indisponibles
## (cooldown, mauvaise zone) et d'appeler perform_named_action() sur un choix.
signal action_menu_requested(role_id, actions)

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

## Appelee par la touche E. Ouvre le menu des actions du role actuel s'il en a,
## sinon garde l'ancien comportement (consultation des files) (TCK5).
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

	var role_id = player.get("role_id", "")
	if ROLE_ACTIONS.has(role_id):
		# Le menu affiche toujours les actions du role, meme indisponibles
		# (grisees avec la raison) : c'est l'UI qui decide de l'affichage.
		# Le cooldown et la sauvegarde ne sont declenches que par un choix
		# reellement effectue, dans perform_named_action().
		action_menu_requested.emit(role_id, ROLE_ACTIONS[role_id])
		return

	if is_on_cooldown():
		GameState.add_event("Recuperation en cours (%.0fs)..." % _cooldown_remaining)
		return
	consult_queues()
	_start_cooldown()
	SaveManager.save_game()

## Execute l'action choisie par le joueur dans le menu d'actions (TCK4/TCK5).
## Reverifie systematiquement cooldown/zone : l'UI grise deja les actions
## indisponibles, mais cette fonction reste la garde-fou definitif.
func perform_named_action(action_id: String) -> void:
	var player = GameState.get_player()
	if player.is_empty():
		return
	if player.get("state", "alive") in ["dead", "prisoner"]:
		return
	if is_on_cooldown():
		GameState.add_event("Recuperation en cours (%.0fs)..." % _cooldown_remaining)
		return
	var role_id = player.get("role_id", "")
	if not ZoneManager.can_perform_role_action(role_id):
		GameState.add_event("Vous n'etes pas au bon endroit pour agir.")
		GameState.add_event(ZoneManager.get_zone_requirement_hint(role_id))
		return
	if not TownActions.has_method(action_id):
		return
	TownActions.call(action_id, player)
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
	GameState.add_event("Touches 1-6 pour rejoindre une file.")

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
	if ROLE_ACTIONS.has(role_id):
		base_hint = "E : menu d'actions (%s)" % RoleManager.get_role_name(role_id)
	else:
		base_hint = "E : consulter les files (1-6 pour rejoindre)"

	if is_on_cooldown():
		return "Recuperation : %.0fs" % _cooldown_remaining

	if ZoneManager.can_perform_role_action(role_id):
		var mission_hint = MissionManager.get_mission_text(GameState.player_name)
		if mission_hint != "Aucune mission" and not mission_hint.begins_with("Rejoignez"):
			return "%s | %s" % [base_hint, mission_hint]
		return base_hint
	return "%s — %s" % [base_hint, ZoneManager.get_zone_requirement_hint(role_id)]
