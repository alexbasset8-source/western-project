extends RefCounted

## Actions du role Sheriff. Extrait de TownActions.gd (dette technique BG-001,
## voir docs/BACKLOG.md). Instancie et expose par TownActions.gd
## (TownActions.sheriff.<action>()).

func attempt_arrest(officer: Dictionary, target: Dictionary = {}) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = TownActions.find_wanted_brigand()
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


func patrol_town(actor: Dictionary) -> void:
	"""
	Patrouille dans la ville pour dissuader les criminels.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Peut déclencher un affrontement avec des brigands.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s commence sa patrouille dans les rues de Frontier Town." % actor_name, "player" if is_player else "law")
	
	# Effet de base: réduction de la criminalité
	var crime_reduction = 2
	if GameState.crime_level > 70:
		crime_reduction = 4  # Plus efficace si criminalité élevée
	elif GameState.crime_level < 30:
		crime_reduction = 1  # Moins nécessaire
	
	GameState.adjust_crime_level(-crime_reduction)
	GameState.adjust_town_morale(2)
	
	# Risque: confrontation avec des brigands
	if randf() < 0.25 and GameState.crime_level > 40:
		var brigand = GameState.get_random_character_by_role("brigand")
		if not brigand.is_empty() and brigand.get("state", "alive") != "dead":
			var brigand_name = brigand.get("name", "un brigand")
			GameState.add_event("%s tombe sur %s pendant sa patrouille!" % [actor_name, brigand_name], "danger")
			
			if randf() < 0.60:
				# Le sheriff capture le brigand
				GameState.mark_prisoner(brigand_name)
				ReputationManager.add_reputation(actor, "law", 4)
				ReputationManager.add_reputation(actor, "combat", 2)
				GameState.add_event("%s arrête %s pendant sa patrouille." % [actor_name, brigand_name])
				GameState.adjust_crime_level(-3)
				GameState.adjust_town_morale(3)
			else:
				# Le brigand s'échappe ou blesse le sheriff
				if randf() < 0.50:
					InjuryManager.harm_character(actor_name, "affrontement en patrouille", 1)
					GameState.add_event("%s est blesse par %s pendant la patrouille." % [actor_name, brigand_name])
					GameState.adjust_town_morale(-2)
				else:
					GameState.add_event("%s s'echappe de %s." % [brigand_name, actor_name])
					GameState.adjust_crime_level(1)
	
	ReputationManager.add_reputation(actor, "law", 2)
	MissionManager.record_progress(actor_name, "patrol")


func interrogate_witness(actor: Dictionary) -> void:
	"""
	Interroge des témoins pour résoudre des crimes.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Faux témoignages peuvent induire en erreur.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s interroge des temoins au bureau du sheriff." % actor_name, "player" if is_player else "law")
	
	# Effet de base
	var crime_info_gained = randi_range(1, 3)
	GameState.adjust_crime_level(-crime_info_gained)
	
	# Bonus si moral est bon (les gens coopèrent plus)
	if GameState.town_morale > 60:
		GameState.adjust_crime_level(-1)
		GameState.add_event("Les temoins sont coopératifs grâce au bon moral de la ville.")
	
	# Risque: faux témoignage
	if randf() < 0.15:
		GameState.add_event("Un temoin donne de fausses informations!")
		GameState.adjust_crime_level(1)  # Perte de temps
		GameState.adjust_town_morale(-1)
	else:
		GameState.adjust_town_morale(2)
		ReputationManager.add_reputation(actor, "law", 3)
		ReputationManager.add_reputation(actor, "reliability", 1)
	
	MissionManager.record_progress(actor_name, "investigation")


func organize_posse(actor: Dictionary) -> void:
	"""
	Organise une milice citoyenne pour aider à maintenir l'ordre.
	Impact: Réduit crime_level, améliore town_morale et economy_stability.
	Risque: Les citoyens peuvent être blessés.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s organise une posse pour patrouiller ensemble." % actor_name, "player" if is_player else "law")
	
	# Effet de base
	var posse_size = randi_range(3, 6)
	var crime_reduction = posse_size  # Chaque membre réduit le crime
	
	GameState.adjust_crime_level(-crime_reduction)
	GameState.adjust_town_morale(3)
	
	# Bonus économique si stabilité est bonne
	if GameState.economy_stability > 60:
		GameState.adjust_economy_stability(1)
	
	# Risque: affrontement
	if randf() < 0.30 and GameState.crime_level > 50:
		var brigands = GameState.get_characters_by_role("brigand")
		if brigands.size() > 0:
			var brigand = brigands.pick_random()
			var brigand_name = brigand.get("name", "un brigand")
			
			GameState.add_event("La posse de %s affronte %s!" % [actor_name, brigand_name], "danger")
			
			if randf() < 0.70:
				# La posse gagne
				GameState.mark_prisoner(brigand_name)
				GameState.add_event("La posse capture %s!" % brigand_name)
				GameState.adjust_crime_level(-4)
				GameState.adjust_town_morale(4)
				ReputationManager.add_reputation(actor, "law", 5)
				ReputationManager.add_reputation(actor, "combat", 3)
			else:
				# La posse perd des membres
				var casualties = randi_range(1, min(posse_size, 3))
				GameState.add_event("La posse perd %d membres dans l'affrontement." % casualties)
				GameState.adjust_town_morale(-casualties * 2)
				GameState.adjust_crime_level(2)
	
	ReputationManager.add_reputation(actor, "law", 3)
	ReputationManager.add_reputation(actor, "reliability", 2)
	MissionManager.record_progress(actor_name, "posse")


func enforce_curfew(actor: Dictionary) -> void:
	"""
	Impose un couvre-feu pour réduire la criminalité nocturne.
	Impact: Réduit fortement crime_level, mais peut affecter economy_stability.
	Risque: Impopularité si le moral est déjà bas.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s impose un couvre-feu a Frontier Town." % actor_name, "player" if is_player else "law")
	
	# Effet de base: réduction significative de la criminalité
	var crime_reduction = 5
	if GameState.crime_level > 80:
		crime_reduction = 8
	
	GameState.adjust_crime_level(-crime_reduction)
	
	# Impact économique négatif (moins d'activité nocturne)
	GameState.adjust_economy_stability(-2)
	
	# Impact sur le moral dépend du contexte
	if GameState.town_morale > 50:
		# Si moral est bon, les gens acceptent
		GameState.adjust_town_morale(1)
		GameState.add_event("Les habitants acceptent le couvre-feu pour leur securite.")
	else:
		# Si moral est bas, les gens sont mécontents
		GameState.adjust_town_morale(-3)
		GameState.add_event("Le couvre-feu est impopulaire. Les habitants murmurent contre %s." % actor_name)
	
	# Bonus de réputation loi
	ReputationManager.add_reputation(actor, "law", 4)
	
	MissionManager.record_progress(actor_name, "curfew")
