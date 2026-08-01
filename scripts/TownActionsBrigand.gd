extends RefCounted

## Actions du role Brigand. Extrait de TownActions.gd (dette technique BG-001,
## voir docs/BACKLOG.md). Instancie et expose par TownActions.gd
## (TownActions.brigand.<action>()).

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
	ReputationManager.add_reputation(brigand, "law", -15)
	ReputationManager.add_reputation(brigand, "crime", 10)
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


func ambush_merchants(actor: Dictionary) -> void:
	"""
	Tend une embuscade aux marchands sur les routes.
	Impact: Augmente crime_level et goods_price, réduit town_morale et economy_stability.
	Risque: Peut être capturé ou blessé.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un brigand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s tend une embuscade sur la route commerciale." % actor_name, "player" if is_player else "danger")
	
	var merchants = GameState.get_characters_by_role("merchant")
	if merchants.is_empty():
		GameState.add_event("Aucun marchand a attaquer.")
		return
	
	var target = merchants.pick_random()
	var target_name = target.get("name", "un marchand")
	
	# Effet de base
	GameState.mark_wanted(actor_name, 20)
	
	if randf() < 0.60:
		# Succès de l'embuscade
		var loot = randi_range(20, 40)
		# Bonus si prix des marchandises est élevé
		if GameState.goods_price > 1.5:
			loot = int(loot * 1.5)
		
		GameState.adjust_money(actor_name, loot)
		GameState.add_event("%s vole $%d a %s." % [actor_name, loot, target_name])
		
		# Impacts globaux
		GameState.adjust_crime_level(4)
		GameState.adjust_town_morale(-3)
		GameState.adjust_economy_stability(-2)
		GameState.adjust_goods_price(1.15)  # Pénurie
		
		ReputationManager.add_reputation(actor, "crime", 5)
		ReputationManager.add_reputation(actor, "combat", 2)
		
		# Risque: le marchand peut être blessé ou tué
		if randf() < 0.30:
			InjuryManager.harm_character(target_name, "embuscade", 1)
			GameState.add_event("%s blesse %s pendant l'embuscade." % [actor_name, target_name])
		
	else:
		# Échec: le marchand résiste ou s'échappe
		GameState.add_event("%s echappe a l'embuscade de %s." % [target_name, actor_name])
		
		if randf() < 0.40:
			# Le brigand est blessé
			InjuryManager.harm_character(actor_name, "resistance du marchand", 1)
			GameState.add_event("%s est blesse en tentant de voler %s." % [actor_name, target_name])
		
		# Impact négatif sur la réputation crime (échec)
		ReputationManager.add_reputation(actor, "crime", -1)
	
	MissionManager.record_progress(actor_name, "ambush")


func sabotage_town_infrastructure(actor: Dictionary) -> void:
	"""
	Sabote les infrastructures de la ville (bâtiments, routes).
	Impact: Réduit economy_stability, town_morale, augmente crime_level et goods_price.
	Risque: Détecté et poursuivi.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un brigand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s sabote les infrastructures de la ville." % actor_name, "player" if is_player else "danger")
	
	# Effet de base
	GameState.mark_wanted(actor_name, 30)
	
	var sabotage_success = randf() < 0.70
	
	if sabotage_success:
		# Réussite du sabotage
		var economy_impact = randi_range(3, 5)
		GameState.adjust_economy_stability(-economy_impact)
		GameState.adjust_town_morale(-4)
		GameState.adjust_crime_level(5)
		GameState.adjust_goods_price(1.20)  # Pénurie due aux infrastructures endommagées
		
		GameState.add_event("%s cause des degats considerables aux infrastructures!" % actor_name)
		ReputationManager.add_reputation(actor, "crime", 6)
		
		# Risque: détection
		if randf() < 0.50:
			GameState.add_event("Les autorites identifient %s comme responsable!" % actor_name)
			# Prime supplémentaire
			var current_bounty = GameState.get_bounty(actor_name)
			GameState.mark_wanted(actor_name, current_bounty + 25)
		
	else:
		# Échec du sabotage
		GameState.add_event("%s echoue a saboter les infrastructures." % actor_name)
		
		if randf() < 0.30:
			# Détecté pendant la tentative
			GameState.add_event("%s est repere en train de saboter!" % actor_name)
			GameState.mark_wanted(actor_name, 15)
		
		# Impact minimal
		GameState.adjust_economy_stability(-1)
	
	MissionManager.record_progress(actor_name, "sabotage")


func extort_protection_money(actor: Dictionary) -> void:
	"""
	Extorque de l'argent de protection aux commerçants.
	Impact: Augmente crime_level, réduit town_morale et economy_stability.
	Risque: Les commerçants peuvent résister ou alerter les autorités.
	Requiert: réputation crime >= 30
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un brigand")
	var is_player = GameState.is_player_character(actor_name)
	
	# Check reputation requirement
	if not ReputationManager.can_perform_action(actor, "extort_protection_money"):
		var missing = ReputationManager.get_missing_requirements(actor, "extort_protection_money")
		if missing.has("crime"):
			GameState.add_event("%s n'a pas assez de reputation crime (nécessite %d, a %d) pour extorquer." % [
				actor_name,
				missing["crime"].get("required", 30),
				missing["crime"].get("current", 0)
			])
		return
	
	GameState.add_event("%s extorque de l'argent de protection aux commerçants." % actor_name, "player" if is_player else "danger")
	
	var merchants = GameState.get_characters_by_role("merchant")
	if merchants.is_empty():
		GameState.add_event("Aucun commerçant a extorquer.")
		return
	
	var target = merchants.pick_random()
	var target_name = target.get("name", "un marchand")
	
	# Montant de l'extorsion
	var extortion_amount = randi_range(15, 35)
	
	# Si l'économie est stable, les commerçants ont plus d'argent
	if GameState.economy_stability > 70:
		extortion_amount = int(extortion_amount * 1.5)
	
	if randf() < 0.75:
		# Succès: le commerçant paie
		GameState.adjust_money(actor_name, extortion_amount)
		GameState.adjust_money(target_name, -extortion_amount)
		GameState.add_event("%s extorque $%d a %s." % [actor_name, extortion_amount, target_name])
		
		# Impacts globaux
		GameState.adjust_crime_level(3)
		GameState.adjust_town_morale(-2)
		GameState.adjust_economy_stability(-1)
		
		ReputationManager.add_reputation(actor, "crime", 4)
		
		# Risque: le commerçant alerte les autorités
		if randf() < 0.25:
			GameState.add_event("%s alerte les autorites!" % target_name)
			GameState.mark_wanted(actor_name, 20)
		
	else:
		# Échec: le commerçant résiste
		GameState.add_event("%s refuse de payer et resiste a %s." % [target_name, actor_name])
		
		if randf() < 0.50:
			# Le brigand est blessé
			InjuryManager.harm_character(actor_name, "resistance du marchand", 1)
			GameState.add_event("%s est blesse par %s." % [actor_name, target_name])
		
		# Impact sur la réputation
		ReputationManager.add_reputation(actor, "crime", -1)
	
	MissionManager.record_progress(actor_name, "extortion")


func hide_loot(actor: Dictionary) -> void:
	"""
	Cache le butin dans des cachettes secrètes.
	Impact: Réduit temporairement crime_level (moins de butin visible = moins de vols).
	Risque: Peut être découvert par les autorités.
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un brigand")
	var is_player = GameState.is_player_character(actor_name)
	
	GameState.add_event("%s cache son butin dans une cachette secrète." % actor_name, "player" if is_player else "")
	
	# Effet de base: le brigand sécurise ses gains
	var loot_to_hide = randi_range(10, 50)
	
	# Si le prix des marchandises est élevé, le butin est plus précieux
	if GameState.goods_price > 1.3:
		loot_to_hide = int(loot_to_hide * GameState.goods_price)
	
	# Le brigand « économise » son butin (n'est pas perdu, juste caché)
	# On simule cela par un gain d'argent
	GameState.adjust_money(actor_name, loot_to_hide)
	
	# Impact positif: moins de butin visible = moins de tentations
	GameState.adjust_crime_level(-2)
	
	ReputationManager.add_reputation(actor, "crime", 3)
	ReputationManager.add_reputation(actor, "reliability", 1)
	
	# Risque: découverte par les autorités
	if randf() < 0.20:
		GameState.add_event("Les autorites decouvrent une partie de la cachette de %s!" % actor_name)
		
		# Perte d'une partie du butin
		var discovered_amount = int(loot_to_hide * 0.3)
		GameState.adjust_money(actor_name, -discovered_amount)
		
		# Impact négatif
		GameState.adjust_crime_level(2)
		GameState.mark_wanted(actor_name, 15)
		
		ReputationManager.add_reputation(actor, "crime", -2)
	else:
		GameState.add_event("%s a cache son butin en securite." % actor_name)
	
	MissionManager.record_progress(actor_name, "hide_loot")
