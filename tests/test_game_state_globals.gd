extends Node
# Test unitaire pour les variables globales de GameState (BG-001-P1)

async func _ready() -> void:
	# Attendre que GameState soit prêt
	await get_tree().create_timer(0.1).timeout
	
	print("=== Début des tests pour BG-001-P1 ===")
	
	# Test 1 : Vérification des valeurs initiales
	print("\n--- Test 1 : Valeurs initiales ---")
	var initial_morale = GameState.town_morale
	var initial_crime = GameState.crime_level
	var initial_economy = GameState.economy_stability
	var initial_price = GameState.goods_price
	
	print("Moral initial: %d (attendu: 50)" % initial_morale)
	print("Criminalité initiale: %d (attendu: 30)" % initial_crime)
	print("Stabilité économique initiale: %d (attendu: 70)" % initial_economy)
	print("Prix des marchandises initial: %f (attendu: 1.0)" % initial_price)
	
	assert(initial_morale == 50, "Le moral initial devrait être 50")
	assert(initial_crime == 30, "La criminalité initiale devrait être 30")
	assert(initial_economy == 70, "La stabilité économique initiale devrait être 70")
	assert(initial_price == 1.0, "Le prix initial devrait être 1.0")
	
	# Test 2 : Modification du moral avec clamp
	print("\n--- Test 2 : Modification du moral ---")
	GameState.adjust_town_morale(10)
	print("Moral après +10: %d (attendu: 60)" % GameState.town_morale)
	assert(GameState.town_morale == 60, "Le moral devrait être 60")
	
	GameState.adjust_town_morale(-70)
	print("Moral après -70: %d (attendu: 0, clamp à 0)" % GameState.town_morale)
	assert(GameState.town_morale == 0, "Le moral ne devrait pas descendre sous 0")
	
	GameState.adjust_town_morale(200)
	print("Moral après +200: %d (attendu: 100, clamp à 100)" % GameState.town_morale)
	assert(GameState.town_morale == 100, "Le moral ne devrait pas dépasser 100")
	
	# Réinitialiser pour les tests suivants
	GameState.town_morale = 50
	
	# Test 3 : Modification de la criminalité
	print("\n--- Test 3 : Modification de la criminalité ---")
	GameState.adjust_crime_level(20)
	print("Criminalité après +20: %d (attendu: 50)" % GameState.crime_level)
	assert(GameState.crime_level == 50, "La criminalité devrait être 50")
	
	GameState.adjust_crime_level(-100)
	print("Criminalité après -100: %d (attendu: 0, clamp à 0)" % GameState.crime_level)
	assert(GameState.crime_level == 0, "La criminalité ne devrait pas descendre sous 0")
	
	# Réinitialiser
	GameState.crime_level = 30
	
	# Test 4 : Modification de la stabilité économique
	print("\n--- Test 4 : Modification de la stabilité économique ---")
	GameState.adjust_economy_stability(-10)
	print("Stabilité après -10: %d (attendu: 60)" % GameState.economy_stability)
	assert(GameState.economy_stability == 60, "La stabilité devrait être 60")
	
	GameState.adjust_economy_stability(50)
	print("Stabilité après +50: %d (attendu: 100, clamp à 100)" % GameState.economy_stability)
	assert(GameState.economy_stability == 100, "La stabilité ne devrait pas dépasser 100")
	
	# Réinitialiser
	GameState.economy_stability = 70
	
	# Test 5 : Modification du prix des marchandises
	print("\n--- Test 5 : Modification du prix des marchandises ---")
	GameState.adjust_goods_price(1.5)
	print("Prix après *1.5: %f (attendu: 1.5)" % GameState.goods_price)
	assert(GameState.goods_price == 1.5, "Le prix devrait être 1.5")
	
	GameState.adjust_goods_price(0.1)
	print("Prix après *0.1: %f (attendu: 0.5, clamp à 0.5)" % GameState.goods_price)
	assert(GameState.goods_price == 0.5, "Le prix ne devrait pas descendre sous 0.5")
	
	GameState.adjust_goods_price(10.0)
	print("Prix après *10: %f (attendu: 2.0, clamp à 2.0)" % GameState.goods_price)
	assert(GameState.goods_price == 2.0, "Le prix ne devrait pas dépasser 2.0")
	
	# Réinitialiser
	GameState.goods_price = 1.0
	
	# Test 6 : Vérification de get_goods_price
	print("\n--- Test 6 : Fonction get_goods_price ---")
	var price = GameState.get_goods_price()
	print("Prix retourné: %f (attendu: 1.0)" % price)
	assert(price == 1.0, "get_goods_price devrait retourner 1.0")
	
	# Test 7 : Intégration avec les actions (simulation)
	print("\n--- Test 7 : Intégration avec TownActions ---")
	# Créer un personnage de test
	var test_sheriff = {
		"name": "TestSheriff",
		"role_id": "sheriff",
		"state": "alive",
		"money": 0,
		"bounty": 0,
		"wounds": 0
	}
	var test_brigand = {
		"name": "TestBrigand",
		"role_id": "brigand",
		"state": "wanted",
		"money": 0,
		"bounty": 25,
		"wounds": 0
	}
	
	# Sauvegarder les valeurs actuelles
	var morale_before = GameState.town_morale
	var crime_before = GameState.crime_level
	
	# Simuler une arrestation
	GameState.mark_prisoner("TestBrigand")
	GameState.adjust_town_morale(3)
	GameState.adjust_crime_level(-5)
	
	print("Moral après arrestation: %d (attendu: %d)" % [GameState.town_morale, morale_before + 3])
	print("Criminalité après arrestation: %d (attendu: %d)" % [GameState.crime_level, crime_before - 5])
	
	assert(GameState.town_morale == morale_before + 3, "Le moral devrait avoir augmenté de 3")
	assert(GameState.crime_level == crime_before - 5, "La criminalité devrait avoir diminué de 5")
	
	print("\n=== Tous les tests ont réussi ! ===")
	
	# Nettoyage
	queue_free()
