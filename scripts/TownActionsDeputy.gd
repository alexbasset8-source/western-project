extends RefCounted

## Actions du role Adjoint (Deputy). Extrait de TownActions.gd (dette
## technique BG-001, voir docs/BACKLOG.md). Instancie et expose par
## TownActions.gd (TownActions.deputy.<action>()).

func assist_arrest(actor: Dictionary, target: Dictionary = {}) -> void:
	"""
	Assiste le shérif dans une arrestation.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Peut être blessé ou échouer.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un adjoint")
	var is_player = GameState.is_player_character(actor_name)
	
	if target.is_empty():
		target = TownActions.find_wanted_brigand()
	if target.is_empty():
		GameState.add_event("%s cherche un criminel a arreter mais n'en trouve pas." % actor_name)
		return
	
	var target_name = target.get("name", "un criminel")
	
	GameState.add_event("%s assiste a l'arrestation de %s." % [actor_name, target_name], "player" if is_player else "law")
	
	if randf() < 0.75:
		# Succès de l'arrestation
		GameState.mark_prisoner(target_name)
		GameState.add_event("%s aide a capturer %s." % [actor_name, target_name])
		
		# Impacts positifs
		GameState.adjust_crime_level(-4)
		GameState.adjust_town_morale(3)
		
		ReputationManager.add_reputation(actor, "law", 4)
		ReputationManager.add_reputation(actor, "combat", 2)
		ReputationManager.add_reputation(actor, "reliability", 2)
		
	else:
		# Échec
		if randf() < 0.40:
			# Le deputy est blessé
			InjuryManager.harm_character(actor_name, "arrestation ratee", 1)
			GameState.add_event("%s est blesse en tentant d'arreter %s." % [actor_name, target_name])
			GameState.adjust_town_morale(-2)
		else:
			GameState.add_event("%s echappe a %s." % [target_name, actor_name])
			GameState.adjust_crime_level(1)
			GameState.adjust_town_morale(-1)
	
	MissionManager.record_progress(actor_name, "assist_arrest")


func scout_perimeter(actor: Dictionary) -> void:
	"""
	Patrouille à la périphérie de la ville pour détecter les menaces.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Peut tomber sur des brigands en embuscade.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un adjoint")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s patrouille a la peripherie de Frontier Town." % actor_name, "player" if is_player else "law")
	
	# Effet de base: détection préventive
	GameState.adjust_crime_level(-2)
	GameState.adjust_town_morale(1)
	
	# Risque: embuscade
	if randf() < 0.30 and GameState.crime_level > 50:
		var brigands = GameState.get_characters_by_role("brigand")
		if brigands.size() > 0:
			var brigand = brigands.pick_random()
			var brigand_name = brigand.get("name", "un brigand")
			
			GameState.add_event("%s tombe sur une embuscade de %s!" % [actor_name, brigand_name], "danger")
			
			if randf() < 0.60:
				# Le deputy repousse l'attaque
				GameState.add_event("%s repousse l'embuscade et fait fuir %s." % [actor_name, brigand_name])
				GameState.adjust_crime_level(-3)
				GameState.adjust_town_morale(2)
				
				ReputationManager.add_reputation(actor, "law", 3)
				ReputationManager.add_reputation(actor, "combat", 3)
			else:
				# Le deputy est blessé
				InjuryManager.harm_character(actor_name, "embuscade", 1)
				GameState.add_event("%s est blesse dans l'embuscade." % actor_name)
				GameState.adjust_town_morale(-2)
				
				# Le brigand peut s'échapper avec du butin
				if randf() < 0.50:
					var loot = randi_range(10, 20)
					GameState.adjust_money(brigand_name, loot)
					GameState.add_event("%s s'echappe avec $%d." % [brigand_name, loot])
					GameState.adjust_crime_level(2)
	
	ReputationManager.add_reputation(actor, "law", 2)
	ReputationManager.add_reputation(actor, "reliability", 1)
	MissionManager.record_progress(actor_name, "scout")


func deliver_warrant(actor: Dictionary, target: Dictionary = {}) -> void:
	"""
	Remet un mandat d'arrêt à un criminel.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Le criminel peut résister violemment.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un adjoint")
	var is_player = GameState.is_player_character(actor_name)
	
	if target.is_empty():
		# Trouver un criminel recherché
		var wanted_chars = []
		for character in GameState.get_alive_characters():
			if character.get("state", "alive") == "wanted":
				wanted_chars.append(character)
		
		if wanted_chars.is_empty():
			GameState.add_event("%s n'a pas de mandat a remettre." % actor_name)
			return
		
		target = wanted_chars.pick_random()
	
	var target_name = target.get("name", "un criminel")
	
	GameState.add_event("%s remet un mandat a %s." % [actor_name, target_name], "player" if is_player else "law")
	
	if randf() < 0.80:
		# Succès: le criminel se rend
		GameState.mark_prisoner(target_name)
		GameState.add_event("%s se rend a %s." % [target_name, actor_name])
		
		# Impacts positifs
		GameState.adjust_crime_level(-5)
		GameState.adjust_town_morale(4)
		
		ReputationManager.add_reputation(actor, "law", 5)
		ReputationManager.add_reputation(actor, "reliability", 2)
		
		# Récompense
		var reward = randi_range(10, 25)
		GameState.adjust_money(actor_name, reward)
		
	else:
		# Échec: le criminel résiste
		GameState.add_event("%s resiste au mandat de %s!" % [target_name, actor_name])
		
		if randf() < 0.50:
			# Combat
			InjuryManager.harm_character(target_name, "resistance au mandat", 1)
			InjuryManager.harm_character(actor_name, "resistance au mandat", 1)
			
			if GameState.find_character(target_name).get("state", "alive") == "dead":
				GameState.add_event("%s abat %s en resistance." % [actor_name, target_name])
				GameState.adjust_crime_level(-3)
				GameState.adjust_town_morale(1)
				ReputationManager.add_reputation(actor, "law", 3)
				ReputationManager.add_reputation(actor, "combat", 3)
			else:
				GameState.add_event("Les deux sont blesses dans l'affrontement.")
				GameState.adjust_town_morale(-2)
			
		else:
			# Le criminel s'échappe
			GameState.add_event("%s s'echappe de %s." % [target_name, actor_name])
			GameState.adjust_crime_level(2)
			GameState.adjust_town_morale(-2)
	
	MissionManager.record_progress(actor_name, "warrant")


func guard_prisoner(actor: Dictionary) -> void:
	"""
	Surveille les prisonniers pour empêcher les évasions.
	Impact: Réduit crime_level, améliore town_morale.
	Risque: Une évasion peut se produire.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un adjoint")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s surveille les prisonniers." % actor_name, "player" if is_player else "law")
	
	# Effet de base: prévention des évasions
	GameState.adjust_crime_level(-1)
	GameState.adjust_town_morale(1)
	
	# Risque: tentative d'évasion
	if randf() < 0.20:
		var prisoners = []
		for character in GameState.get_alive_characters():
			if character.get("state", "alive") == "prisoner":
				prisoners.append(character)
		
		if prisoners.is_empty():
			GameState.add_event("Aucun prisonnier a surveiller.")
		else:
			var escapee = prisoners.pick_random()
			var escapee_name = escapee.get("name", "un prisonnier")
			
			GameState.add_event("%s tente de s'echapper!" % escapee_name, "danger")
			
			if randf() < 0.70:
				# Le deputy empêche l'évasion
				GameState.add_event("%s empeche %s de s'echapper." % [actor_name, escapee_name])
				GameState.adjust_town_morale(2)
				ReputationManager.add_reputation(actor, "law", 3)
				ReputationManager.add_reputation(actor, "combat", 1)
			else:
				# Évasion réussie
				PrisonManager.release(escapee_name)
				GameState.add_event("%s s'echappe malgré %s!" % [escapee_name, actor_name])
				GameState.adjust_crime_level(3)
				GameState.adjust_town_morale(-3)
				
				# Le prisonnier devient recherché
				GameState.mark_wanted(escapee_name, 30)
				
				# Impact sur la réputation du deputy
				ReputationManager.add_reputation(actor, "law", -2)
	
	ReputationManager.add_reputation(actor, "law", 2)
	ReputationManager.add_reputation(actor, "reliability", 1)
	MissionManager.record_progress(actor_name, "guard")
