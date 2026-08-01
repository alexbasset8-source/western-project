extends RefCounted

## Actions du role Marchand. Extrait de TownActions.gd (dette technique BG-001,
## voir docs/BACKLOG.md) : le fichier faisait 1419 lignes, largement au-dessus
## du seuil de 600 lignes fixe par TECHNICAL_ARCHITECTURE.md.
## Instancie et expose par TownActions.gd (TownActions.merchant.<action>()).

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
			TownActions.brigand.attack_convoy(brigand, actor)
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


func negotiate_prices(actor: Dictionary) -> void:
	"""
	Négocie les prix avec les fournisseurs.
	Impact: Améliore economy_stability, réduit goods_price.
	Risque: Peut échouer et augmenter les prix.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un marchand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s negocie les prix avec les fournisseurs." % actor_name, "player" if is_player else "commerce")
	
	# Effet de base
	var negotiation_skill = randi_range(1, 5)
	
	if randf() < 0.70:
		# Succès de la négociation
		var price_reduction = 0.05 * negotiation_skill
		GameState.adjust_goods_price(1.0 - price_reduction)
		
		GameState.add_event("%s reussit a reduire les prix de %d%%!" % [actor_name, int(price_reduction * 100)])
		GameState.adjust_economy_stability(2)
		GameState.adjust_town_morale(1)
		
		ReputationManager.add_reputation(actor, "commerce", 4)
		ReputationManager.add_reputation(actor, "reliability", 2)
		
		# Gain financier
		var profit = randi_range(20, 40)
		GameState.adjust_money(actor_name, profit)
		
	else:
		# Échec: les prix augmentent
		GameState.add_event("Les negociations de %s echouent, les prix augmentent." % actor_name)
		GameState.adjust_goods_price(1.10)
		GameState.adjust_economy_stability(-1)
		
		ReputationManager.add_reputation(actor, "commerce", -1)
	
	MissionManager.record_progress(actor_name, "negotiation")


func bribe_officials(actor: Dictionary) -> void:
	"""
	Corrompt des officiels pour faciliter les affaires.
	Impact: Améliore economy_stability, réduit crime_level (moins de contrôles).
	Risque: Peut être découvert et entraîner des conséquences graves.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un marchand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s tente de corrompre des officiels." % actor_name, "player" if is_player else "commerce")
	
	var bribe_amount = randi_range(30, 60)
	
	# Si l'économie est instable, les officiels demandent plus
	if GameState.economy_stability < 50:
		bribe_amount = int(bribe_amount * 1.5)
	
	if GameState.get_money(actor_name) >= bribe_amount:
		GameState.adjust_money(actor_name, -bribe_amount)
		
		if randf() < 0.65:
			# Succès de la corruption
			GameState.add_event("%s reussit a corrompre des officiels avec $%d." % [actor_name, bribe_amount])
			
			# Impacts positifs
			GameState.adjust_economy_stability(3)
			GameState.adjust_crime_level(-2)  # Moins de contrôles = moins de crimes détectés
			GameState.adjust_goods_price(0.95)  # Meilleure fluidité commerciale
			
			ReputationManager.add_reputation(actor, "commerce", 5)
			# Mais impact négatif sur la réputation loi
			ReputationManager.add_reputation(actor, "law", -3)
			
			# Gain à long terme
			var long_term_profit = randi_range(50, 80)
			GameState.adjust_money(actor_name, long_term_profit)
			
		else:
			# Échec: découvert
			GameState.add_event("La tentative de corruption de %s est decouverte!" % actor_name)
			
			# Conséquences graves
			GameState.adjust_town_morale(-5)
			GameState.mark_wanted(actor_name, 40)
			
			ReputationManager.add_reputation(actor, "commerce", -3)
			ReputationManager.add_reputation(actor, "crime", 4)
			
			# Perte supplémentaire
			var fine = randi_range(20, 40)
			GameState.adjust_money(actor_name, -fine)
		
	else:
		# Pas assez d'argent
		GameState.add_event("%s n'a pas assez d'argent pour corrompre les officiels." % actor_name)
		ReputationManager.add_reputation(actor, "commerce", -1)
	
	MissionManager.record_progress(actor_name, "bribe")


func smuggle_contraband(actor: Dictionary) -> void:
	"""
	Fait passer de la contrebande en ville.
	Impact: Augmente goods_price (rareté), améliore economy_stability (marché noir).
	Risque: Confiscation et amende.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un marchand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s tente de faire passer de la contrebande." % actor_name, "player" if is_player else "commerce")
	
	var contraband_value = randi_range(40, 80)
	
	# Si le prix des marchandises est élevé, la contrebande est plus rentable
	if GameState.goods_price > 1.5:
		contraband_value = int(contraband_value * GameState.goods_price)
	
	if randf() < 0.70:
		# Succès
		GameState.adjust_money(actor_name, contraband_value)
		GameState.add_event("%s reussit a vendre de la contrebande pour $%d." % [actor_name, contraband_value])
		
		# Impacts globaux
		GameState.adjust_economy_stability(2)  # L'argent circule
		GameState.adjust_goods_price(1.05)  # La contrebande crée de la rareté
		
		ReputationManager.add_reputation(actor, "commerce", 4)
		# Impact négatif sur la réputation loi
		ReputationManager.add_reputation(actor, "law", -2)
		
	else:
		# Échec: confisqué
		GameState.add_event("La contrebande de %s est confisquee par les autorites!" % actor_name)
		
		# Conséquences
		GameState.mark_wanted(actor_name, 25)
		GameState.adjust_town_morale(-2)
		
		ReputationManager.add_reputation(actor, "commerce", -2)
		ReputationManager.add_reputation(actor, "crime", 3)
		
		# Amende
		var fine = randi_range(20, 50)
		GameState.adjust_money(actor_name, -fine)
	
	MissionManager.record_progress(actor_name, "smuggle")


func setup_trade_stand(actor: Dictionary) -> void:
	"""
	Installe un stand de commerce temporaire.
	Impact: Améliore economy_stability et town_morale.
	Risque: Peut attirer des voleurs.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un marchand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s installe un stand de commerce temporaire." % actor_name, "player" if is_player else "commerce")
	
	# Effet de base
	var base_profit = randi_range(25, 50)
	
	# Bonus si l'économie est stable
	if GameState.economy_stability > 60:
		base_profit = int(base_profit * 1.3)
	
	# Bonus si le moral est bon
	if GameState.town_morale > 60:
		base_profit = int(base_profit * 1.2)
	
	GameState.adjust_money(actor_name, base_profit)
	GameState.add_event("%s gagne $%d avec son stand." % [actor_name, base_profit])
	
	# Impacts globaux positifs
	GameState.adjust_economy_stability(3)
	GameState.adjust_town_morale(2)
	
	ReputationManager.add_reputation(actor, "commerce", 3)
	ReputationManager.add_reputation(actor, "reliability", 2)
	
	# Risque: attirer des voleurs
	if randf() < 0.25 and GameState.crime_level > 40:
		var brigands = GameState.get_characters_by_role("brigand")
		if brigands.size() > 0:
			var brigand = brigands.pick_random()
			var brigand_name = brigand.get("name", "un brigand")
			
			GameState.add_event("%s est victime d'un vol par %s!" % [actor_name, brigand_name], "danger")
			
			# Perte d'une partie des gains
			var stolen_amount = int(base_profit * 0.4)
			GameState.adjust_money(actor_name, -stolen_amount)
			GameState.adjust_money(brigand_name, stolen_amount)
			
			# Impacts négatifs
			GameState.adjust_crime_level(2)
			GameState.adjust_town_morale(-1)
			
			ReputationManager.add_reputation(actor, "commerce", -1)
			ReputationManager.add_reputation(brigand, "crime", 2)
	
	MissionManager.record_progress(actor_name, "trade_stand")
