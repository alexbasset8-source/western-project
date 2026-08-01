extends RefCounted

## Actions du role Habitant (Citizen/Townfolk). Extrait de TownActions.gd
## (dette technique BG-001, voir docs/BACKLOG.md). Instancie et expose par
## TownActions.gd (TownActions.citizen.<action>()).

func report_crime(actor: Dictionary) -> void:
	"""
	Signale un crime aux autorités.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Peut être ignoré ou mal interprété.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un habitant")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s signale un crime aux autorites." % actor_name, "player" if is_player else "")
	
	# Effet de base
	if randf() < 0.80:
		# Le rapport est pris au sérieux
		GameState.add_event("Les autorites enquêtent sur le signalement de %s." % actor_name)
		
		# Impacts positifs
		GameState.adjust_crime_level(-2)
		GameState.adjust_town_morale(2)
		
		ReputationManager.add_reputation(actor, "law", 2)
		ReputationManager.add_reputation(actor, "reliability", 2)
		
		# Récompense potentielle
		if randf() < 0.30:
			var reward = randi_range(5, 15)
			GameState.adjust_money(actor_name, reward)
			GameState.add_event("%s recoit une recompense de $%d pour son signalement." % [actor_name, reward])
		
	else:
		# Le rapport est ignoré
		GameState.add_event("Le signalement de %s est ignore par les autorites." % actor_name)
		GameState.adjust_town_morale(-1)
		ReputationManager.add_reputation(actor, "reliability", -1)
	
	MissionManager.record_progress(actor_name, "report")


func gossip(actor: Dictionary) -> void:
	"""
	Propage des rumeurs dans la ville.
	Impact: Peut améliorer ou réduire town_morale selon la nature des rumeurs.
	Risque: Peut créer des tensions ou attirer l'attention des criminels.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un habitant")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s propage des rumeurs au saloon." % actor_name, "player" if is_player else "")
	
	# Type de rumeur (aléatoire)
	var rumor_type = randi_range(1, 3)
	
	match rumor_type:
		1:  # Bonne rumeur (positive)
			GameState.add_event("%s raconte de bonnes nouvelles sur la ville." % actor_name)
			GameState.adjust_town_morale(3)
			ReputationManager.add_reputation(actor, "reliability", 1)
		2:  # Mauvaise rumeur (négative)
			GameState.add_event("%s propage de mauvaises rumeurs sur les autorites." % actor_name)
			GameState.adjust_town_morale(-2)
			ReputationManager.add_reputation(actor, "reliability", -1)
		3:  # Rumeur neutre ou drôle
			GameState.add_event("%s raconte une histoire amusante." % actor_name)
			GameState.adjust_town_morale(1)
	
	# Risque: attirer l'attention des criminels
	if randf() < 0.15 and GameState.crime_level > 50:
		var brigands = GameState.get_characters_by_role("brigand")
		if brigands.size() > 0:
			var brigand = brigands.pick_random()
			var brigand_name = brigand.get("name", "un brigand")
			
			GameState.add_event("%s attire l'attention de %s avec ses rumeurs." % [actor_name, brigand_name])
			
			if randf() < 0.50:
				# Le brigand menace l'habitant
				GameState.add_event("%s menace %s pour qu'il se taise." % [brigand_name, actor_name])
				GameState.adjust_town_morale(-2)
				ReputationManager.add_reputation(actor, "reliability", -2)
			else:
				# Le brigand ignore
				GameState.add_event("%s ignore les rumeurs de %s." % [brigand_name, actor_name])
	
	MissionManager.record_progress(actor_name, "gossip")


func form_militia(actor: Dictionary) -> void:
	"""
	Organise une milice citoyenne pour se protéger.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Peut provoquer des conflits ou être inefficace.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un habitant")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s organise une milice citoyenne." % actor_name, "player" if is_player else "")
	
	# Taille de la milice
	var militia_size = randi_range(3, 8)
	
	# Effet de base
	GameState.adjust_crime_level(-militia_size)
	GameState.adjust_town_morale(2)
	
	ReputationManager.add_reputation(actor, "law", 2)
	ReputationManager.add_reputation(actor, "reliability", 3)
	
	# Risque: conflit avec les autorités
	if randf() < 0.20:
		GameState.add_event("La milice de %s entre en conflit avec les autorites locales." % actor_name)
		GameState.adjust_town_morale(-3)
		ReputationManager.add_reputation(actor, "law", -2)
	
	# Risque: inefficacité
	if randf() < 0.15:
		GameState.add_event("La milice de %s s'avere inefficace." % actor_name)
		GameState.adjust_crime_level(1)  # Pas de réduction
		ReputationManager.add_reputation(actor, "reliability", -1)
	
	# Risque: affrontement avec des brigands
	if randf() < 0.25 and GameState.crime_level > 40:
		var brigands = GameState.get_characters_by_role("brigand")
		if brigands.size() > 0:
			var brigand = brigands.pick_random()
			var brigand_name = brigand.get("name", "un brigand")
			
			GameState.add_event("La milice de %s affronte %s!" % [actor_name, brigand_name], "danger")
			
			if randf() < 0.60:
				# La milice gagne
				GameState.add_event("La milice capture %s!" % brigand_name)
				GameState.mark_prisoner(brigand_name)
				GameState.adjust_crime_level(-4)
				GameState.adjust_town_morale(4)
				ReputationManager.add_reputation(actor, "law", 4)
				ReputationManager.add_reputation(actor, "combat", 2)
			else:
				# La milice perd
				GameState.add_event("La milice est defaite par %s." % brigand_name)
				GameState.adjust_crime_level(3)
				GameState.adjust_town_morale(-3)
				ReputationManager.add_reputation(actor, "law", -1)
	
	MissionManager.record_progress(actor_name, "militia")


func protest(actor: Dictionary) -> void:
	"""
	Organise une protestation contre les autorités ou les conditions de vie.
	Impact: Peut améliorer ou réduire town_morale selon le contexte.
	Risque: Peut attirer la répression ou être ignoré.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un habitant")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s organise une protestation." % actor_name, "player" if is_player else "")
	
	# Type de protestation (dépend du contexte)
	var protest_type = "generale"
	
	if GameState.town_morale < 30:
		protest_type = "colere"
		GameState.add_event("Les habitants expriment leur colere contre les conditions de vie!")
	elif GameState.crime_level > 70:
		protest_type = "securite"
		GameState.add_event("Les habitants protestent contre l'insécurité!")
	elif GameState.economy_stability < 40:
		protest_type = "economie"
		GameState.add_event("Les habitants protestent contre la crise économique!")
	else:
		GameState.add_event("Les habitants manifestent pour de meilleures conditions.")
	
	# Effet selon le type et le contexte
	match protest_type:
		"colere":
			if randf() < 0.60:
				# Les autorités cèdent
				GameState.add_event("Les autorites cedent aux revendications.")
				GameState.adjust_town_morale(5)
				GameState.adjust_economy_stability(2)
				ReputationManager.add_reputation(actor, "reliability", 3)
			else:
				# Répression
				GameState.add_event("Les autorites repriment la protestation!")
				GameState.adjust_town_morale(-4)
				
				if randf() < 0.30:
					InjuryManager.harm_character(actor_name, "repression", 1)
					GameState.add_event("%s est blesse pendant la repression." % actor_name)
				
				ReputationManager.add_reputation(actor, "law", -3)
				ReputationManager.add_reputation(actor, "reliability", -1)
			
		"securite":
			if randf() < 0.70:
				GameState.add_event("La protestation pousse les autorites a agir.")
				GameState.adjust_crime_level(-3)
				GameState.adjust_town_morale(3)
				ReputationManager.add_reputation(actor, "reliability", 2)
			else:
				GameState.add_event("La protestation est ignoree.")
				GameState.adjust_town_morale(-2)
			
		"economie":
			if randf() < 0.65:
				GameState.add_event("La protestation economique porte ses fruits.")
				GameState.adjust_economy_stability(3)
				GameState.adjust_town_morale(2)
				ReputationManager.add_reputation(actor, "reliability", 2)
			else:
				GameState.add_event("La protestation economique echoue.")
				GameState.adjust_town_morale(-1)
			
		_:  # générale
			if randf() < 0.50:
				GameState.adjust_town_morale(2)
				ReputationManager.add_reputation(actor, "reliability", 1)
			else:
				GameState.adjust_town_morale(-1)
	
	MissionManager.record_progress(actor_name, "protest")
