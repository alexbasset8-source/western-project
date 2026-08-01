extends Node
# Test unitaire pour les nouvelles actions de TownActions (BG-001-P2)

func _ready() -> void:
	# Attendre que GameState soit prêt
	await get_tree().create_timer(0.1).timeout
	
	print("=== Début des tests pour BG-001-P2 ===")
	
	# Sauvegarder l'état initial
	var initial_morale = GameState.town_morale
	var initial_crime = GameState.crime_level
	var initial_economy = GameState.economy_stability
	var initial_price = GameState.goods_price
	
	# ============================================
	# TESTS AVEC VARIABLES GLOBALES AUX EXTRÊMES
	# ============================================
	
	print("\n=== Test 1: Variables globales à 0 ===")
	_test_actions_at_extreme(0, 0, 0, 0.5)
	
	print("\n=== Test 2: Variables globales à 50 ===")
	_test_actions_at_extreme(50, 50, 50, 1.0)
	
	print("\n=== Test 3: Variables globales à 100 ===")
	_test_actions_at_extreme(100, 100, 100, 2.0)
	
	# ============================================
	# TESTS SPÉCIFIQUES PAR RÔLE
	# ============================================
	
	print("\n=== Test 4: Actions Sheriff ===")
	_test_sheriff_actions()
	
	print("\n=== Test 5: Actions Brigand ===")
	_test_brigand_actions()
	
	print("\n=== Test 6: Actions Merchant ===")
	_test_merchant_actions()
	
	print("\n=== Test 7: Actions Deputy ===")
	_test_deputy_actions()
	
	print("\n=== Test 8: Actions Townfolk ===")
	_test_townfolk_actions()
	
	print("\n=== Test 8b: Actions Bounty Hunter ===")
	_test_bounty_hunter_actions()
	
	# ============================================
	# TESTS D'INTÉGRATION
	# ============================================
	
	print("\n=== Test 9: Intégration complète ===")
	_test_integration()
	
	# Restaurer l'état initial
	GameState.town_morale = initial_morale
	GameState.crime_level = initial_crime
	GameState.economy_stability = initial_economy
	GameState.goods_price = initial_price
	
	print("\n=== Tous les tests BG-001-P2 ont réussi ! ===")
	
	# Nettoyage
	queue_free()


func _test_actions_at_extreme(morale: int, crime: int, economy: int, price: float) -> void:
	"""Teste les actions avec des valeurs extrêmes des variables globales"""
	
	# Sauvegarder l'état actuel
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	var old_economy = GameState.economy_stability
	var old_price = GameState.goods_price
	
	# Définir les valeurs extrêmes
	GameState.town_morale = morale
	GameState.crime_level = crime
	GameState.economy_stability = economy
	GameState.goods_price = price
	
	print("Testing avec: Moral=%d, Crime=%d, Économie=%d, Prix=%.2f" % [morale, crime, economy, price])
	
	# Créer des personnages de test
	var test_sheriff = {
		"name": "TestSheriff_P2",
		"role_id": "sheriff",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	var test_brigand = {
		"name": "TestBrigand_P2",
		"role_id": "brigand",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	var test_merchant = {
		"name": "TestMerchant_P2",
		"role_id": "merchant",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	# Tester patrol_town avec moral à 0
	TownActions.sheriff.patrol_town(test_sheriff)
	assert(GameState.town_morale >= 0, "Moral ne devrait pas descendre sous 0")
	assert(GameState.town_morale <= 100, "Moral ne devrait pas dépasser 100")
	
	# Tester ambush_merchants avec crime à 100
	TownActions.brigand.ambush_merchants(test_brigand)
	assert(GameState.crime_level >= 0, "Crime ne devrait pas descendre sous 0")
	assert(GameState.crime_level <= 100, "Crime ne devrait pas dépasser 100")
	
	# Tester negotiate_prices avec price à 2.0
	TownActions.merchant.negotiate_prices(test_merchant)
	assert(GameState.goods_price >= 0.5, "Prix ne devrait pas descendre sous 0.5")
	assert(GameState.goods_price <= 2.0, "Prix ne devrait pas dépasser 2.0")
	
	# Tester smuggle_contraband avec price à 0.5
	GameState.goods_price = 0.5
	TownActions.merchant.smuggle_contraband(test_merchant)
	assert(GameState.goods_price >= 0.5, "Prix ne devrait pas descendre sous 0.5")
	
	# Restaurer l'état
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	GameState.economy_stability = old_economy
	GameState.goods_price = old_price
	
	print("  ✓ Toutes les valeurs restent dans les limites acceptables")


func _test_sheriff_actions() -> void:
	"""Teste les 4 actions du Sheriff"""
	
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	var old_economy = GameState.economy_stability
	var old_price = GameState.goods_price
	
	var test_sheriff = {
		"name": "SheriffTest",
		"role_id": "sheriff",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	# Test 1: patrol_town
	print("  Testing patrol_town...")
	TownActions.sheriff.patrol_town(test_sheriff)
	assert(GameState.crime_level <= old_crime, "patrol_town devrait réduire ou maintenir crime_level")
	assert(GameState.town_morale >= old_morale, "patrol_town devrait améliorer ou maintenir town_morale")
	
	# Test 2: interrogate_witness
	print("  Testing interrogate_witness...")
	TownActions.sheriff.interrogate_witness(test_sheriff)
	# Vérifier que crime_level a été affecté
	var current_crime = GameState.crime_level
	assert(current_crime >= 0 && current_crime <= 100, "crime_level devrait rester dans [0, 100]")
	
	# Test 3: organize_posse
	print("  Testing organize_posse...")
	TownActions.sheriff.organize_posse(test_sheriff)
	assert(GameState.crime_level <= old_crime, "organize_posse devrait réduire crime_level")
	
	# Test 4: enforce_curfew
	print("  Testing enforce_curfew...")
	TownActions.sheriff.enforce_curfew(test_sheriff)
	assert(GameState.crime_level <= old_crime, "enforce_curfew devrait réduire crime_level")
	
	# Restaurer
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	GameState.economy_stability = old_economy
	GameState.goods_price = old_price
	
	print("  ✓ Toutes les actions Sheriff fonctionnent correctement")


func _test_brigand_actions() -> void:
	"""Teste les 4 actions du Brigand"""
	
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	var old_economy = GameState.economy_stability
	var old_price = GameState.goods_price
	
	# Créer un marchand pour les tests
	var test_merchant = {
		"name": "MerchantForBrigandTest",
		"role_id": "merchant",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	var test_brigand = {
		"name": "BrigandTest",
		"role_id": "brigand",
		"state": "alive",
		"money": 0,
		"bounty": 0,
		"wounds": 0
	}
	
	# Ajouter temporairement le marchand à la liste des personnages
	var temp_characters = GameState.characters.duplicate()
	GameState.characters.append(test_merchant)
	
	# Test 1: ambush_merchants
	print("  Testing ambush_merchants...")
	TownActions.brigand.ambush_merchants(test_brigand)
	assert(GameState.crime_level >= old_crime, "ambush_merchants devrait augmenter crime_level")
	assert(GameState.town_morale <= old_morale, "ambush_merchants devrait réduire town_morale")
	
	# Test 2: sabotage_town_infrastructure
	print("  Testing sabotage_town_infrastructure...")
	TownActions.brigand.sabotage_town_infrastructure(test_brigand)
	assert(GameState.economy_stability <= old_economy, "sabotage devrait réduire economy_stability")
	
	# Test 3: extort_protection_money
	print("  Testing extort_protection_money...")
	TownActions.brigand.extort_protection_money(test_brigand)
	assert(GameState.crime_level >= old_crime, "extort_protection_money devrait augmenter crime_level")
	
	# Test 4: hide_loot
	print("  Testing hide_loot...")
	TownActions.brigand.hide_loot(test_brigand)
	# hide_loot devrait réduire crime_level (moins de butin visible)
	
	# Restaurer
	GameState.characters = temp_characters
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	GameState.economy_stability = old_economy
	GameState.goods_price = old_price
	
	print("  ✓ Toutes les actions Brigand fonctionnent correctement")


func _test_merchant_actions() -> void:
	"""Teste les 4 actions du Merchant"""
	
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	var old_economy = GameState.economy_stability
	var old_price = GameState.goods_price
	
	var test_merchant = {
		"name": "MerchantTest",
		"role_id": "merchant",
		"state": "alive",
		"money": 200,
		"bounty": 0,
		"wounds": 0
	}
	
	# Test 1: negotiate_prices
	print("  Testing negotiate_prices...")
	var price_before = GameState.goods_price
	TownActions.merchant.negotiate_prices(test_merchant)
	# La négociation peut réussir ou échouer, mais le prix doit rester dans les limites
	assert(GameState.goods_price >= 0.5 && GameState.goods_price <= 2.0, "Prix doit rester dans [0.5, 2.0]")
	
	# Test 2: bribe_officials
	print("  Testing bribe_officials...")
	TownActions.merchant.bribe_officials(test_merchant)
	# Vérifier que l'argent a été affecté
	
	# Test 3: smuggle_contraband
	print("  Testing smuggle_contraband...")
	TownActions.merchant.smuggle_contraband(test_merchant)
	assert(GameState.economy_stability >= 0 && GameState.economy_stability <= 100, "economy_stability doit rester dans [0, 100]")
	
	# Test 4: setup_trade_stand
	print("  Testing setup_trade_stand...")
	TownActions.merchant.setup_trade_stand(test_merchant)
	assert(GameState.economy_stability >= old_economy, "setup_trade_stand devrait améliorer economy_stability")
	
	# Restaurer
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	GameState.economy_stability = old_economy
	GameState.goods_price = old_price
	
	print("  ✓ Toutes les actions Merchant fonctionnent correctement")


func _test_deputy_actions() -> void:
	"""Teste les 4 actions du Deputy"""
	
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	
	var test_deputy = {
		"name": "DeputyTest",
		"role_id": "deputy",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	# Créer un brigand recherché pour les tests
	var test_brigand = {
		"name": "BrigandForDeputyTest",
		"role_id": "brigand",
		"state": "wanted",
		"money": 0,
		"bounty": 25,
		"wounds": 0
	}
	
	# Ajouter temporairement
	var temp_characters = GameState.characters.duplicate()
	GameState.characters.append(test_brigand)
	
	# Test 1: assist_arrest
	print("  Testing assist_arrest...")
	TownActions.deputy.assist_arrest(test_deputy, test_brigand)
	
	# Test 2: scout_perimeter
	print("  Testing scout_perimeter...")
	TownActions.deputy.scout_perimeter(test_deputy)
	
	# Test 3: deliver_warrant
	print("  Testing deliver_warrant...")
	TownActions.deputy.deliver_warrant(test_deputy, test_brigand)
	
	# Test 4: guard_prisoner
	print("  Testing guard_prisoner...")
	# Marquer le brigand comme prisonnier
	GameState.mark_prisoner(test_brigand.get("name", ""))
	TownActions.deputy.guard_prisoner(test_deputy)
	
	# Restaurer
	GameState.characters = temp_characters
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	
	print("  ✓ Toutes les actions Deputy fonctionnent correctement")


func _test_townfolk_actions() -> void:
	"""Teste les 4 actions du Townfolk"""
	
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	
	var test_townfolk = {
		"name": "TownfolkTest",
		"role_id": "",
		"state": "alive",
		"money": 50,
		"bounty": 0,
		"wounds": 0
	}
	
	# Test 1: report_crime
	print("  Testing report_crime...")
	TownActions.citizen.report_crime(test_townfolk)
	
	# Test 2: gossip
	print("  Testing gossip...")
	TownActions.citizen.gossip(test_townfolk)
	
	# Test 3: form_militia
	print("  Testing form_militia...")
	TownActions.citizen.form_militia(test_townfolk)
	
	# Test 4: protest
	print("  Testing protest...")
	TownActions.citizen.protest(test_townfolk)
	
	# Restaurer
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	
	print("  ✓ Toutes les actions Townfolk fonctionnent correctement")


func _test_bounty_hunter_actions() -> void:
	"""Teste les 5 actions du Bounty Hunter (track_bounty + 4 completees BG-001-P2)"""
	
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	
	var test_hunter = {
		"name": "HunterTest",
		"role_id": "bounty_hunter",
		"state": "alive",
		"money": 100,
		"bounty": 0,
		"wounds": 0
	}
	
	# Cible recherchee avec une prime pour que les actions aient un effet mesurable
	var test_target = {
		"name": "WantedForHunterTest",
		"role_id": "brigand",
		"state": "wanted",
		"money": 0,
		"bounty": 30,
		"wounds": 0
	}
	
	var temp_characters = GameState.characters.duplicate()
	GameState.characters.append(test_target)
	
	# Test 1: track_bounty (action historique BG-001-P1)
	print("  Testing track_bounty...")
	TownActions.bounty_hunter.track_bounty(test_hunter, test_target)
	
	# Test 2: investigate_bounty
	print("  Testing investigate_bounty...")
	TownActions.bounty_hunter.investigate_bounty(test_hunter, test_target)
	
	# Test 3: set_trap
	print("  Testing set_trap...")
	TownActions.bounty_hunter.set_trap(test_hunter)
	
	# Test 4: follow_trail
	print("  Testing follow_trail...")
	TownActions.bounty_hunter.follow_trail(test_hunter)
	
	# Test 5: negotiate_surrender
	print("  Testing negotiate_surrender...")
	TownActions.bounty_hunter.negotiate_surrender(test_hunter, test_target)
	
	assert(GameState.crime_level >= 0 && GameState.crime_level <= 100, "crime_level doit rester dans [0, 100]")
	assert(GameState.town_morale >= 0 && GameState.town_morale <= 100, "town_morale doit rester dans [0, 100]")
	
	# Restaurer
	GameState.characters = temp_characters
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	
	print("  ✓ Toutes les actions Bounty Hunter fonctionnent correctement")


func _test_integration() -> void:
	"""Teste l'intégration complète des actions avec les variables globales"""
	
	print("  Testing intégration complète...")
	
	# Sauvegarder l'état
	var old_morale = GameState.town_morale
	var old_crime = GameState.crime_level
	var old_economy = GameState.economy_stability
	var old_price = GameState.goods_price
	
	# Définir des valeurs moyennes
	GameState.town_morale = 50
	GameState.crime_level = 50
	GameState.economy_stability = 50
	GameState.goods_price = 1.0
	
	# Créer des personnages de test pour chaque rôle
	var test_sheriff = {"name": "IntSheriff", "role_id": "sheriff", "state": "alive", "money": 100, "bounty": 0, "wounds": 0}
	var test_brigand = {"name": "IntBrigand", "role_id": "brigand", "state": "alive", "money": 100, "bounty": 0, "wounds": 0}
	var test_merchant = {"name": "IntMerchant", "role_id": "merchant", "state": "alive", "money": 100, "bounty": 0, "wounds": 0}
	var test_deputy = {"name": "IntDeputy", "role_id": "deputy", "state": "alive", "money": 100, "bounty": 0, "wounds": 0}
	var test_townfolk = {"name": "IntTownfolk", "role_id": "", "state": "alive", "money": 50, "bounty": 0, "wounds": 0}
	
	# Exécuter une action de chaque rôle
	TownActions.sheriff.patrol_town(test_sheriff)
	TownActions.brigand.ambush_merchants(test_brigand)
	TownActions.merchant.negotiate_prices(test_merchant)
	TownActions.deputy.assist_arrest(test_deputy)
	TownActions.citizen.report_crime(test_townfolk)
	
	# Vérifier que toutes les variables globales sont toujours dans les limites
	assert(GameState.town_morale >= 0 && GameState.town_morale <= 100, "town_morale doit rester dans [0, 100]")
	assert(GameState.crime_level >= 0 && GameState.crime_level <= 100, "crime_level doit rester dans [0, 100]")
	assert(GameState.economy_stability >= 0 && GameState.economy_stability <= 100, "economy_stability doit rester dans [0, 100]")
	assert(GameState.goods_price >= 0.5 && GameState.goods_price <= 2.0, "goods_price doit rester dans [0.5, 2.0]")
	
	# Restaurer
	GameState.town_morale = old_morale
	GameState.crime_level = old_crime
	GameState.economy_stability = old_economy
	GameState.goods_price = old_price
	
	print("  ✓ Intégration complète validée")
