extends Node

const ROUTES := ["route sud", "canyon", "route commerciale Est"]

func transport_goods(actor: Dictionary) -> void:
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un marchand")
	var route = ROUTES.pick_random()
	var is_player = GameState.is_player_character(actor_name)
	GameState.add_event("%s part en transport de marchandises par la %s." % [actor_name, route], "player" if is_player else "")
	if randf() < 0.30:
		var brigand = GameState.get_random_character_by_role("brigand")
		if not brigand.is_empty() and brigand.get("state", "alive") != "dead":
			attack_convoy(brigand, actor)
			return
	# Calcul des gains avec le multiplicateur de prix
	var base_payout = randi_range(15, 30)
	var final_payout = int(base_payout * GameState.get_goods_price())
	GameState.adjust_money(actor_name, final_payout)
	ReputationManager.add_reputation(actor, "commerce", 3)
	ReputationManager.add_reputation(actor, "reliability", 2)
	GameState.add_event("%s livre sa cargaison et gagne $%d." % [actor_name, final_payout])
	# Impact sur la stabilité économique
	GameState.adjust_economy_stability(2)
	MissionManager.record_progress(actor_name, "transport")

func attack_convoy(brigand: Dictionary, merchant: Dictionary = {}) -> void:
	if brigand.is_empty() or brigand.get("state", "alive") == "dead":
		return
	if merchant.is_empty():
		merchant = GameState.get_random_character_by_role("merchant")
	if merchant.is_empty() or merchant.get("state", "alive") == "dead":
		GameState.add_event("Aucun convoi disponible a attaquer.")
		return
	var brigand_name = brigand.get("name", "Un brigand")
	var merchant_name = merchant.get("name", "un marchand")
	var _is_player_brigand = GameState.is_player_character(brigand_name)
	GameState.add_event("%s attaque le convoi de %s dans le canyon." % [brigand_name, merchant_name], "player" if _is_player_brigand else "danger")
	GameState.mark_wanted(brigand_name, 25)
	var raid_success = false
	if randf() < 0.25:
		InjuryManager.harm_character(merchant_name, "convoi attaque", 2)
		raid_success = true
	elif randf() < 0.45:
		InjuryManager.harm_character(merchant_name, "convoi attaque", 1)
		raid_success = true
	else:
		GameState.add_event("Le convoi de %s resiste et s'echappe." % merchant_name)
	if GameState.find_character(merchant_name).get("state", "alive") == "dead":
		var loot = randi_range(10, 25)
		GameState.adjust_money(brigand_name, loot)
		ReputationManager.add_reputation(brigand, "crime", 5)
		GameState.add_event("%s disparait avec $%d du convoi." % [brigand_name, loot])
		raid_success = true
	# Impact sur la criminalité et le moral
	if raid_success:
		GameState.adjust_crime_level(3)
		GameState.adjust_town_morale(-2)
		# Augmenter le prix des marchandises (pénurie)
		GameState.adjust_goods_price(1.1)
	MissionManager.record_progress(brigand_name, "raid")

func track_bounty(hunter: Dictionary, target: Dictionary = {}) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = _find_bounty_target()
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

func attempt_arrest(officer: Dictionary, target: Dictionary = {}) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = _find_wanted_brigand()
	if target.is_empty():
		GameState.add_event("Aucun brigand recherche a arreter.")
		return
	var officer_name = officer.get("name", "Le sheriff")
	var target_name = target.get("name", "un brigand")
	var _is_player_officer = GameState.is_player_character(officer_name)
	GameState.add_event("%s tente d'arreter %s." % [officer_name, target_name], "player" if _is_player_officer else "")
	if randf() < 0.70:
		GameState.mark_prisoner(target_name)
		ReputationManager.add_reputation(officer, "law", 5)
		GameState.add_event("%s est mis en prison par %s." % [target_name, officer_name])
		# Impact sur le moral et la criminalité
		GameState.adjust_town_morale(3)
		GameState.adjust_crime_level(-5)
		MissionManager.record_progress(officer_name, "arrest")
	else:
		if randf() < 0.30:
			InjuryManager.harm_character(target_name, "resistance a l'arrestation", 2)
			if GameState.find_character(target_name).get("state", "alive") != "dead":
				GameState.add_event("%s blesse et s'enfuit de %s." % [target_name, officer_name])
				return
			ReputationManager.add_reputation(officer, "law", 3)
			ReputationManager.add_reputation(officer, "combat", 2)
			GameState.add_event("%s resiste et est abattu par %s." % [target_name, officer_name])
			# Impact sur le moral (moins positif que l'arrestation)
			GameState.adjust_town_morale(1)
			GameState.adjust_crime_level(-2)
			MissionManager.record_progress(officer_name, "arrest")
		else:
			GameState.add_event("%s s'enfuit de %s." % [target_name, officer_name])
			# Impact négatif sur le moral
			GameState.adjust_town_morale(-1)

func duel(a: Dictionary, b: Dictionary) -> void:
	if a.is_empty() or b.is_empty() or a.get("name", "") == b.get("name", ""):
		return
	GameState.add_event("Un duel oppose %s et %s pres du saloon." % [a.get("name", "?"), b.get("name", "?")])
	if randf() < 0.35:
		var loser = [a, b].pick_random()
		InjuryManager.harm_character(loser.get("name", ""), "duel au saloon", 2)
	elif randf() < 0.50:
		InjuryManager.harm_character(a.get("name", ""), "duel au saloon", 1)
		InjuryManager.harm_character(b.get("name", ""), "duel au saloon", 1)

func post_bounty_on_brigand() -> void:
	var brigand = GameState.get_random_character_by_role("brigand")
	if brigand.is_empty():
		return
	GameState.mark_wanted(brigand.get("name", ""), 15)

func deadly_incident() -> void:
	var candidates = GameState.get_alive_characters()
	if candidates.is_empty():
		return
	var character = candidates.pick_random()
	GameState.add_event("Un incident tourne mal a Frontier Town.")
	InjuryManager.harm_character(character.get("name", ""), "incident de ville", 2)

func _find_wanted_brigand() -> Dictionary:
	var candidates = []
	for character in GameState.get_characters_by_role("brigand"):
		if character.get("state", "alive") == "wanted":
			candidates.append(character)
	if candidates.is_empty():
		return GameState.get_random_character_by_role("brigand")
	return candidates.pick_random()

func _find_bounty_target() -> Dictionary:
	var candidates = []
	for character in GameState.get_alive_characters():
		if character.get("state", "alive") == "wanted" and int(character.get("bounty", 0)) > 0:
			candidates.append(character)
	if candidates.is_empty():
		return _find_wanted_brigand()
	return candidates.pick_random()
