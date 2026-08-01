extends RefCounted

## Actions du role Chasseur de primes. Extrait de TownActions.gd (dette
## technique BG-001, voir docs/BACKLOG.md). Instancie et expose par
## TownActions.gd (TownActions.bounty_hunter.<action>()).

func track_bounty(hunter: Dictionary, target: Dictionary = {}) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = TownActions.find_bounty_target()
	if target.is_empty():
		GameState.add_event("Aucune prime active a traquer.")
		return
	var hunter_name = hunter.get("name", "Un chasseur")
	var target_name = target.get("name", "un criminel")
	var _is_player_hunter = GameState.is_player_character(hunter_name)
	GameState.add_event("%s traque %s pres de la route Est." % [hunter_name, target_name], "player" if _is_player_hunter else "")
	if randf() < 0.65:
		GameState.mark_prisoner(target_name)
		var reward = int(target.get("bounty", 0))
		if reward > 0:
			GameState.adjust_money(hunter_name, reward)
			target["bounty"] = 0
		ReputationManager.add_reputation(hunter, "combat", 5)
		ReputationManager.add_reputation(hunter, "law", 3)
		GameState.add_event("%s capture %s et encaisse la prime." % [hunter_name, target_name])
		# Impact sur le moral et la criminalité
		GameState.adjust_town_morale(4)
		GameState.adjust_crime_level(-4)
		MissionManager.record_progress(hunter_name, "bounty")
	else:
		if randf() < 0.40:
			InjuryManager.harm_character(target_name, "refus de se rendre", 2)
			if GameState.find_character(target_name).get("state", "alive") != "dead":
				GameState.add_event("%s echappe a %s en blessant." % [target_name, hunter_name])
				return
			var reward = int(target.get("bounty", 0))
			if reward > 0:
				GameState.adjust_money(hunter_name, reward)
				target["bounty"] = 0
			ReputationManager.add_reputation(hunter, "combat", 3)
			GameState.add_event("%s abat %s et recupere la prime." % [hunter_name, target_name])
			# Impact sur le moral (moins positif que la capture)
			GameState.adjust_town_morale(2)
			GameState.adjust_crime_level(-2)
			MissionManager.record_progress(hunter_name, "bounty")
		else:
			GameState.add_event("%s echappe a %s dans le maquis." % [target_name, hunter_name])


func investigate_bounty(hunter: Dictionary, target: Dictionary = {}) -> void:
	"""
	Enquete sur une prime active pour reunir des informations.
	Impact: Legere amelioration du moral, reputation combat/loi.
	Risque: Aucun, mais ne garantit rien de concret par elle-meme.
	"""
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = TownActions.find_bounty_target()
	if target.is_empty():
		GameState.add_event("Aucune prime active a enqueter.")
		return

	var hunter_name = hunter.get("name", "Un chasseur")
	var target_name = target.get("name", "un criminel")
	var is_player = GameState.is_player_character(hunter_name)

	GameState.add_event("%s enquete sur %s." % [hunter_name, target_name], "player" if is_player else "")
	GameState.adjust_town_morale(1)

	ReputationManager.add_reputation(hunter, "combat", 2)
	ReputationManager.add_reputation(hunter, "law", 1)
	MissionManager.record_progress(hunter_name, "investigation")


func set_trap(hunter: Dictionary) -> void:
	"""
	Pose un piege pour capturer automatiquement un criminel recherche.
	Impact: Reduit crime_level, ameliore town_morale en cas de succes.
	Risque: Peut ne rien attraper.
	"""
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	var hunter_name = hunter.get("name", "Un chasseur")
	var is_player = GameState.is_player_character(hunter_name)

	GameState.add_event("%s pose un piege pour les criminels." % hunter_name, "player" if is_player else "")

	if randf() < 0.40:
		var wanted = TownActions.find_wanted_brigand()
		if not wanted.is_empty():
			var wanted_name = wanted.get("name", "un criminel")
			GameState.mark_prisoner(wanted_name)
			var reward = int(wanted.get("bounty", 0))
			if reward > 0:
				GameState.adjust_money(hunter_name, reward)
				wanted["bounty"] = 0
			GameState.add_event("%s a capture %s avec son piege et encaisse $%d !" % [hunter_name, wanted_name, reward])
			GameState.adjust_town_morale(3)
			GameState.adjust_crime_level(-3)
			ReputationManager.add_reputation(hunter, "combat", 4)
			ReputationManager.add_reputation(hunter, "law", 3)
			MissionManager.record_progress(hunter_name, "trap")
		else:
			GameState.add_event("Le piege de %s n'a rien attrape." % hunter_name)
	else:
		GameState.add_event("Le piege de %s n'a rien attrape." % hunter_name)


func follow_trail(hunter: Dictionary) -> void:
	"""
	Suit une piste pour localiser un criminel recherche.
	Impact: Reputation combat/loi en cas de succes.
	Risque: La piste peut se perdre.
	"""
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	var hunter_name = hunter.get("name", "Un chasseur")
	var is_player = GameState.is_player_character(hunter_name)

	GameState.add_event("%s suit une piste de criminel." % hunter_name, "player" if is_player else "")

	if randf() < 0.60:
		var target = TownActions.find_bounty_target()
		if not target.is_empty():
			GameState.add_event("%s a trouve la cachette de %s !" % [hunter_name, target.get("name", "un criminel")])
			ReputationManager.add_reputation(hunter, "combat", 3)
			ReputationManager.add_reputation(hunter, "law", 2)
		else:
			GameState.add_event("%s a trouve des indices, mais pas de criminel." % hunter_name)
			ReputationManager.add_reputation(hunter, "combat", 2)
	else:
		GameState.add_event("%s a perdu la piste." % hunter_name)

	MissionManager.record_progress(hunter_name, "trail")


func negotiate_surrender(hunter: Dictionary, target: Dictionary = {}) -> void:
	"""
	Tente de negocier la reddition d'un criminel plutot que l'affronter.
	Impact: Reduit crime_level, ameliore town_morale en cas de succes.
	Risque: Refus pouvant mener a une fuite ou une attaque surprise.
	"""
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = TownActions.find_bounty_target()
	if target.is_empty():
		GameState.add_event("Aucune cible a negocier.")
		return

	var hunter_name = hunter.get("name", "Un chasseur")
	var target_name = target.get("name", "un criminel")
	var is_player = GameState.is_player_character(hunter_name)

	GameState.add_event("%s tente de negocier la reddition de %s." % [hunter_name, target_name], "player" if is_player else "")

	if randf() < 0.50:
		GameState.mark_prisoner(target_name)
		var reward = int(int(target.get("bounty", 0)) * 0.8)
		if reward > 0:
			GameState.adjust_money(hunter_name, reward)
			target["bounty"] = 0
		GameState.add_event("%s a negocie la reddition de %s et encaisse $%d !" % [hunter_name, target_name, reward])
		GameState.adjust_town_morale(2)
		GameState.adjust_crime_level(-2)
		ReputationManager.add_reputation(hunter, "combat", 2)
		ReputationManager.add_reputation(hunter, "law", 4)
		ReputationManager.add_reputation(hunter, "reliability", 2)
		MissionManager.record_progress(hunter_name, "negotiation")
	else:
		GameState.add_event("%s a refuse de se rendre." % target_name)
		if randf() < 0.50:
			GameState.add_event("%s s'enfuit !" % target_name)
		else:
			InjuryManager.harm_character(hunter_name, "negociation echouee", 1)
			GameState.add_event("%s attaque %s par surprise !" % [target_name, hunter_name])
