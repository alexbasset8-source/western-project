extends Node

const ROUTES := ["route sud", "canyon", "route commerciale Est"]

# ============================================
# ACTIONS EXISTANTES (BG-001-P1)
# ============================================

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


# ============================================
# NOUVELLES ACTIONS BG-001-P2
# ============================================

# --- SHERIFF ACTIONS ---

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
				GameState.add_event("La posse capture %s!")
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


# --- BRIGAND ACTIONS ---

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
	"""
	if actor.is_empty() or actor.get("state", "alive") == "dead":
		return
	var actor_name = actor.get("name", "Un brigand")
	var is_player = GameState.is_player_character(actor_name)
	
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


# --- MERCHANT ACTIONS ---

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


# --- DEPUTY ACTIONS ---

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
		target = _find_wanted_brigand()
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
				PrisonManager.release_prisoner(escapee_name)
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


# --- TOWNFOLK ACTIONS ---

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
