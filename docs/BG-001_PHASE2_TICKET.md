# **Ticket BG-001-P2 : Actions variées par rôle (Phase 2)**

---

## **📍 Métadonnées**
- **ID** : BG-001-P2
- **Parent** : BG-001 (Équilibrer les rôles de Frontier Town)
- **Phase** : 2/6 (Actions variées)
- **Priorité** : P1 (Important)
- **Statut** : Prêt pour développement
- **Estimation** : 8-12 heures
- **Assigné à** : IA (avec validation humaine)
- **Date de création** : 26 juillet 2026
- **Dépendance** : BG-001-P1 (Fondations)

---

## **🎯 Objectif**
Ajouter **5+ actions par rôle** pour offrir une **profondeur stratégique** et éviter la répétitivité. Chaque rôle doit avoir des actions **variées, utiles et complémentaires** pour maintenir l'engagement du joueur pendant des sessions de 2 heures.

**Objectif final de la Phase 2** :
> *Un joueur peut choisir parmi plusieurs actions selon son rôle, avec des impacts différents sur le monde et des risques/récompenses variés.*

---

## **📜 Contexte**
Ce ticket fait partie de la **solution révisée pour BG-001**, qui vise à rendre chaque rôle **intéressant pendant des sessions de 2 heures** (et non 30 minutes).

**Problème actuel** (après Phase 1) :
- Chaque rôle n'a qu'**une seule action principale** (ex : Sheriff = arrêter, Brigand = attaquer).
- Les joueurs **s'ennuient rapidement** car les actions sont répétitives.
- Les rôles manquent de **profondeur tactique** et de **choix stratégiques**.

**Solution** :
- Ajouter **5+ actions par rôle** avec des mécaniques différentes.
- Chaque action doit avoir un **impact unique** sur les variables globales (moral, criminalité, économie).
- Les actions doivent offrir des **risques/récompenses variés**.

---

## **✅ Portée du Ticket**

### **Inclus dans ce ticket**
1. **Ajout de 5+ actions pour chaque rôle** (Sheriff, Marchand, Chasseur de primes, Brigand).
2. **Intégration avec les variables globales** (Phase 1) : chaque action impacte `town_morale`, `crime_level`, `economy_stability`, ou `goods_price`.
3. **Système de cooldown** pour éviter le spam d'actions.
4. **Affichage des actions disponibles** dans l'UI (raccourcis clavier 1-5).
5. **Messages de feedback** clairs pour chaque action.
6. **Tests unitaires** pour valider les nouvelles actions.

### **Exclu de ce ticket**
- **Événements dynamiques** (Phase 3).
- **Interface utilisateur avancée** (HUD redessiné).
- **Équilibrage fin** des valeurs (Phase 6).
- **Nouveaux rôles** (hors scope de BG-001).

---

## **📁 Fichiers à modifier**

| **Fichier** | **Type** | **Modifications** | **Lignes estimées** | **Risque** |
|-------------|----------|-------------------|---------------------|------------|
| `scripts/TownActions.gd` | Script | Ajout de 20+ nouvelles actions | +200 | Moyen |
| `scripts/PlayerActionManager.gd` | Script | Gestion des raccourcis clavier | +50 | Moyen |
| `scripts/UIController.gd` | Script | Affichage des actions disponibles | +30 | Faible |
| `scripts/GameState.gd` | Script | Système de cooldown | +20 | Faible |
| `docs/CHANGELOG.md` | Documentation | Journal des modifications | +15 | Aucun |

---

## **🔨 Implémentation Détaillée**

---

### **1. Nouveau système de cooldown dans `GameState.gd`**

#### **1.1. Ajout des variables de cooldown**
Ajouter à la racine de la classe :
```gdscript
# Système de cooldown pour les actions (en tours)
var action_cooldowns := {}
const ACTION_COOLDOWN_DEFAULT := 3  # Cooldown par défaut en tours
```

#### **1.2. Ajout des fonctions de gestion des cooldowns**
```gdscript
# Vérifie si une action est en cooldown pour un personnage
func is_action_on_cooldown(character_name: String, action_name: String) -> bool:
	var key = "%s_%s" % [character_name, action_name]
	return action_cooldowns.get(key, 0) > 0

# Réduit les cooldowns de tous les personnages d'un tour
func reduce_all_cooldowns() -> void:
	for key in action_cooldowns.keys():
		var remaining = action_cooldowns[key]
		if remaining > 0:
			action_cooldowns[key] = remaining - 1
		if action_cooldowns[key] <= 0:
			action_cooldowns.erase(key)

# Réinitialise le cooldown pour une action
func set_action_cooldown(character_name: String, action_name: String, turns: int = ACTION_COOLDOWN_DEFAULT) -> void:
	var key = "%s_%s" % [character_name, action_name]
	action_cooldowns[key] = turns
```

---

### **2. Nouvelles actions par rôle dans `TownActions.gd`**

#### **2.1. Actions pour le Sheriff**

**Actions existantes** :
- `attempt_arrest()` : Tenter d'arrêter un brigand recherché.

**Nouvelles actions** :
```gdscript
# 1. Patrouiller dans la ville (réduit la criminalité, augmente le moral)
func patrol_town(officer: Dictionary) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	var officer_name = officer.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(officer_name)
	
	if GameState.is_action_on_cooldown(officer_name, "patrol_town"):
		GameState.add_event("%s est encore en patrouille." % officer_name)
		return
	
	GameState.add_event("%s patrouille dans les rues de Frontier Town." % officer_name, "player" if is_player else "")
	
	# Impact sur les variables globales
	GameState.adjust_crime_level(-2)
	GameState.adjust_town_morale(1)
	
	# Cooldown
	GameState.set_action_cooldown(officer_name, "patrol_town", 4)
	ReputationManager.add_reputation(officer, "law", 2)
	MissionManager.record_progress(officer_name, "patrol")

# 2. Interroger un suspect (peut révéler des informations)
func interrogate_suspect(officer: Dictionary, target: Dictionary = {}) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = GameState.get_random_character_by_role("brigand")
	if target.is_empty() or target.get("state", "alive") == "dead":
		GameState.add_event("Aucun suspect disponible pour interrogatoire.")
		return
	
	var officer_name = officer.get("name", "Le sheriff")
	var target_name = target.get("name", "un suspect")
	var is_player = GameState.is_player_character(officer_name)
	
	if GameState.is_action_on_cooldown(officer_name, "interrogate_suspect"):
		GameState.add_event("%s ne peut pas interroger pour l'instant." % officer_name)
		return
	
	GameState.add_event("%s interroge %s au bureau du sheriff." % [officer_name, target_name], "player" if is_player else "")
	
	# 60% de chance de succès
	if randf() < 0.60:
		# Révèle un brigand recherché
		var wanted = _find_wanted_brigand()
		if not wanted.is_empty():
			GameState.add_event("%s a obtenu des informations sur %s !" % [officer_name, wanted.get("name", "un criminel")])
			ReputationManager.add_reputation(officer, "law", 3)
		else:
			GameState.add_event("%s a obtenu des informations utiles." % officer_name)
			ReputationManager.add_reputation(officer, "law", 2)
	else:
		GameState.add_event("%s n'a rien obtenu de %s." % [officer_name, target_name])
	
	# Cooldown
	GameState.set_action_cooldown(officer_name, "interrogate_suspect", 5)
	MissionManager.record_progress(officer_name, "interrogation")

# 3. Organiser une battue (augmente les chances d'arrestation)
func organize_manhunt(officer: Dictionary) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	var officer_name = officer.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(officer_name)
	
	if GameState.is_action_on_cooldown(officer_name, "organize_manhunt"):
		GameState.add_event("%s ne peut pas organiser de battue pour l'instant." % officer_name)
		return
	
	GameState.add_event("%s organise une battue pour traquer les criminels." % officer_name, "player" if is_player else "")
	
	# Impact temporaire : augmente les chances d'arrestation pour les prochains tours
	# (À implémenter dans une future phase)
	GameState.adjust_crime_level(-3)
	GameState.adjust_town_morale(2)
	
	# Cooldown long
	GameState.set_action_cooldown(officer_name, "organize_manhunt", 8)
	ReputationManager.add_reputation(officer, "law", 4)
	ReputationManager.add_reputation(officer, "combat", 2)
	MissionManager.record_progress(officer_name, "manhunt")

# 4. Poster des avis de recherche (augmente les primes)
func post_wanted_posters(officer: Dictionary) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	var officer_name = officer.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(officer_name)
	
	if GameState.is_action_on_cooldown(officer_name, "post_wanted_posters"):
		GameState.add_event("%s ne peut pas poster d'avis pour l'instant." % officer_name)
		return
	
	GameState.add_event("%s poste des avis de recherche dans la ville." % officer_name, "player" if is_player else "")
	
	# Augmente les primes des brigands recherchés
	var brigands = GameState.get_characters_by_role("brigand")
	for brigand in brigands:
		if brigand.get("state", "alive") == "wanted":
			brigand["bounty"] = int(brigand.get("bounty", 0)) + 5
			GameState.add_event("La prime sur %s augmente de $5." % brigand.get("name", "un brigand"))
	
	# Impact sur le moral
	GameState.adjust_town_morale(1)
	
	# Cooldown
	GameState.set_action_cooldown(officer_name, "post_wanted_posters", 6)
	ReputationManager.add_reputation(officer, "law", 3)
	MissionManager.record_progress(officer_name, "wanted")

# 5. Inspecter les lieux suspects (peut trouver des preuves)
func inspect_location(officer: Dictionary) -> void:
	if officer.is_empty() or officer.get("state", "alive") == "dead":
		return
	var officer_name = officer.get("name", "Le sheriff")
	var is_player = GameState.is_player_character(officer_name)
	
	if GameState.is_action_on_cooldown(officer_name, "inspect_location"):
		GameState.add_event("%s ne peut pas inspecter pour l'instant." % officer_name)
		return
	
	GameState.add_event("%s inspecte les lieux suspects en ville." % officer_name, "player" if is_player else "")
	
	# 50% de chance de trouver quelque chose
	if randf() < 0.50:
		# Trouve un indice ou un objet illégal
		if randf() < 0.70:
			GameState.add_event("%s a trouvé des indices compromettants !" % officer_name)
			ReputationManager.add_reputation(officer, "law", 4)
		else:
			GameState.add_event("%s a saisi des marchandises illégales !" % officer_name)
			GameState.adjust_money(officer_name, 10)
			GameState.adjust_economy_stability(1)
			ReputationManager.add_reputation(officer, "law", 3)
			ReputationManager.add_reputation(officer, "commerce", 1)
		else:
			GameState.add_event("%s n'a rien trouvé d'intéressant." % officer_name)
	
	# Cooldown
	GameState.set_action_cooldown(officer_name, "inspect_location", 5)
	MissionManager.record_progress(officer_name, "inspection")
```

#### **2.2. Actions pour le Marchand**

**Actions existantes** :
- `transport_goods()` : Transporter des marchandises.

**Nouvelles actions** :
```gdscript
# 1. Acheter des marchandises (réduit le prix, augmente la stabilité économique)
func buy_goods(merchant: Dictionary) -> void:
	if merchant.is_empty() or merchant.get("state", "alive") == "dead":
		return
	var merchant_name = merchant.get("name", "Un marchand")
	var is_player = GameState.is_player_character(merchant_name)
	
	if GameState.is_action_on_cooldown(merchant_name, "buy_goods"):
		GameState.add_event("%s ne peut pas acheter pour l'instant." % merchant_name)
		return
	
	# Coût de l'achat
	var cost = randi_range(10, 20)
	if GameState.get_money(merchant_name) < cost:
		GameState.add_event("%s n'a pas assez d'argent pour acheter des marchandises ($%d nécessaires)." % [merchant_name, cost])
		return
	
	GameState.adjust_money(merchant_name, -cost)
	GameState.add_event("%s achète des marchandises pour $%d." % [merchant_name, cost], "player" if is_player else "")
	
	# Impact : réduit le prix des marchandises (plus d'offre)
	GameState.adjust_goods_price(0.95)
	GameState.adjust_economy_stability(1)
	
	# Cooldown
	GameState.set_action_cooldown(merchant_name, "buy_goods", 4)
	ReputationManager.add_reputation(merchant, "commerce", 2)
	MissionManager.record_progress(merchant_name, "purchase")

# 2. Vendre des marchandises (augmente le prix, gains importants)
func sell_goods(merchant: Dictionary) -> void:
	if merchant.is_empty() or merchant.get("state", "alive") == "dead":
		return
	var merchant_name = merchant.get("name", "Un marchand")
	var is_player = GameState.is_player_character(merchant_name)
	
	if GameState.is_action_on_cooldown(merchant_name, "sell_goods"):
		GameState.add_event("%s ne peut pas vendre pour l'instant." % merchant_name)
		return
	
	# Gains de la vente (utilise goods_price)
	var base_profit = randi_range(20, 40)
	var final_profit = int(base_profit * GameState.get_goods_price())
	GameState.adjust_money(merchant_name, final_profit)
	GameState.add_event("%s vend des marchandises et gagne $%d." % [merchant_name, final_profit], "player" if is_player else "")
	
	# Impact : augmente le prix (moins de stock)
	GameState.adjust_goods_price(1.05)
	GameState.adjust_economy_stability(1)
	
	# Cooldown
	GameState.set_action_cooldown(merchant_name, "sell_goods", 4)
	ReputationManager.add_reputation(merchant, "commerce", 3)
	MissionManager.record_progress(merchant_name, "sale")

# 3. Négocier avec les fournisseurs (réduit les coûts futurs)
func negotiate_with_suppliers(merchant: Dictionary) -> void:
	if merchant.is_empty() or merchant.get("state", "alive") == "dead":
		return
	var merchant_name = merchant.get("name", "Un marchand")
	var is_player = GameState.is_player_character(merchant_name)
	
	if GameState.is_action_on_cooldown(merchant_name, "negotiate_with_suppliers"):
		GameState.add_event("%s ne peut pas négocier pour l'instant." % merchant_name)
		return
	
	GameState.add_event("%s négocie avec les fournisseurs." % merchant_name, "player" if is_player else "")
	
	# 70% de chance de succès
	if randf() < 0.70:
		# Réduit le prix des marchandises pour les prochains achats
		GameState.adjust_goods_price(0.90)
		GameState.add_event("%s a obtenu de meilleurs tarifs !" % merchant_name)
		ReputationManager.add_reputation(merchant, "commerce", 4)
		ReputationManager.add_reputation(merchant, "reliability", 2)
	else:
		GameState.add_event("%s n'a pas réussi à négocier." % merchant_name)
	
	# Cooldown
	GameState.set_action_cooldown(merchant_name, "negotiate_with_suppliers", 6)
	MissionManager.record_progress(merchant_name, "negotiation")

# 4. Organiser un convoi protégé (moins de risques, gains modérés)
func organize_protected_convoy(merchant: Dictionary) -> void:
	if merchant.is_empty() or merchant.get("state", "alive") == "dead":
		return
	var merchant_name = merchant.get("name", "Un marchand")
	var is_player = GameState.is_player_character(merchant_name)
	
	if GameState.is_action_on_cooldown(merchant_name, "organize_protected_convoy"):
		GameState.add_event("%s ne peut pas organiser de convoi protégé pour l'instant." % merchant_name)
		return
	
	GameState.add_event("%s organise un convoi protégé." % merchant_name, "player" if is_player else "")
	
	# Moins de risques d'être attaqué
	if randf() < 0.15:  # 15% de chance d'être attaqué (vs 30% normalement)
		var brigand = GameState.get_random_character_by_role("brigand")
		if not brigand.is_empty() and brigand.get("state", "alive") != "dead":
			attack_convoy(brigand, merchant)
			return
	
	# Gains modérés mais sûrs
	var profit = randi_range(20, 35)
	GameState.adjust_money(merchant_name, profit)
	GameState.add_event("%s livre son convoi protégé et gagne $%d." % [merchant_name, profit])
	GameState.adjust_economy_stability(2)
	
	# Cooldown
	GameState.set_action_cooldown(merchant_name, "organize_protected_convoy", 5)
	ReputationManager.add_reputation(merchant, "commerce", 2)
	ReputationManager.add_reputation(merchant, "reliability", 3)
	MissionManager.record_progress(merchant_name, "protected_convoy")

# 5. Investir dans l'infrastructure (améliore la stabilité économique à long terme)
func invest_in_infrastructure(merchant: Dictionary) -> void:
	if merchant.is_empty() or merchant.get("state", "alive") == "dead":
		return
	var merchant_name = merchant.get("name", "Un marchand")
	var is_player = GameState.is_player_character(merchant_name)
	
	if GameState.is_action_on_cooldown(merchant_name, "invest_in_infrastructure"):
		GameState.add_event("%s ne peut pas investir pour l'instant." % merchant_name)
		return
	
	# Coût de l'investissement
	var investment = 50
	if GameState.get_money(merchant_name) < investment:
		GameState.add_event("%s n'a pas assez d'argent pour investir ($%d nécessaires)." % [merchant_name, investment])
		return
	
	GameState.adjust_money(merchant_name, -investment)
	GameState.add_event("%s investit $%d dans l'infrastructure de la ville." % [merchant_name, investment], "player" if is_player else "")
	
	# Impact à long terme
	GameState.adjust_economy_stability(5)
	GameState.adjust_town_morale(2)
	
	# Cooldown long
	GameState.set_action_cooldown(merchant_name, "invest_in_infrastructure", 10)
	ReputationManager.add_reputation(merchant, "commerce", 5)
	ReputationManager.add_reputation(merchant, "reliability", 3)
	MissionManager.record_progress(merchant_name, "investment")
```

#### **2.3. Actions pour le Chasseur de primes**

**Actions existantes** :
- `track_bounty()` : Traquer une prime.

**Nouvelles actions** :
```gdscript
# 1. Enquêter sur une prime (augmente les chances de succès)
func investigate_bounty(hunter: Dictionary, target: Dictionary = {}) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = _find_bounty_target()
	if target.is_empty():
		GameState.add_event("Aucune prime active à enquêter.")
		return
	
	var hunter_name = hunter.get("name", "Un chasseur")
	var target_name = target.get("name", "un criminel")
	var is_player = GameState.is_player_character(hunter_name)
	
	if GameState.is_action_on_cooldown(hunter_name, "investigate_bounty"):
		GameState.add_event("%s ne peut pas enquêter pour l'instant." % hunter_name)
		return
	
	GameState.add_event("%s enquête sur %s." % [hunter_name, target_name], "player" if is_player else "")
	
	# Augmente temporairement les chances de succès pour la prochaine traque
	# (À implémenter : stocker un bonus dans GameState)
	GameState.adjust_town_morale(1)
	
	# Cooldown
	GameState.set_action_cooldown(hunter_name, "investigate_bounty", 3)
	ReputationManager.add_reputation(hunter, "combat", 2)
	ReputationManager.add_reputation(hunter, "law", 1)
	MissionManager.record_progress(hunter_name, "investigation")

# 2. Poser un piège (peut capturer automatiquement un criminel)
func set_trap(hunter: Dictionary) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	var hunter_name = hunter.get("name", "Un chasseur")
	var is_player = GameState.is_player_character(hunter_name)
	
	if GameState.is_action_on_cooldown(hunter_name, "set_trap"):
		GameState.add_event("%s ne peut pas poser de piège pour l'instant." % hunter_name)
		return
	
	GameState.add_event("%s pose un piège pour les criminels." % hunter_name, "player" if is_player else "")
	
	# 40% de chance de capturer un brigand recherché
	if randf() < 0.40:
		var wanted = _find_wanted_brigand()
		if not wanted.is_empty():
			GameState.mark_prisoner(wanted.get("name", ""))
			var reward = int(wanted.get("bounty", 0))
			if reward > 0:
				GameState.adjust_money(hunter_name, reward)
				wanted["bounty"] = 0
			GameState.add_event("%s a capturé %s avec son piège et encaisse $%d !" % [hunter_name, wanted.get("name", "un criminel"), reward])
			GameState.adjust_town_morale(3)
			GameState.adjust_crime_level(-3)
			ReputationManager.add_reputation(hunter, "combat", 4)
			ReputationManager.add_reputation(hunter, "law", 3)
			MissionManager.record_progress(hunter_name, "trap")
		else:
			GameState.add_event("Le piège de %s n'a rien attrapé." % hunter_name)
	
	# Cooldown
	GameState.set_action_cooldown(hunter_name, "set_trap", 6)

# 3. Suivre une piste (trouve un criminel caché)
func follow_trail(hunter: Dictionary) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	var hunter_name = hunter.get("name", "Un chasseur")
	var is_player = GameState.is_player_character(hunter_name)
	
	if GameState.is_action_on_cooldown(hunter_name, "follow_trail"):
		GameState.add_event("%s ne peut pas suivre de piste pour l'instant." % hunter_name)
		return
	
	GameState.add_event("%s suit une piste de criminel." % hunter_name, "player" if is_player else "")
	
	# 60% de chance de trouver un criminel
	if randf() < 0.60:
		var target = _find_bounty_target()
		if not target.is_empty():
			GameState.add_event("%s a trouvé la cachette de %s !" % [hunter_name, target.get("name", "un criminel")])
			# La prochaine traque contre cette cible a +20% de chances de succès
			ReputationManager.add_reputation(hunter, "combat", 3)
			ReputationManager.add_reputation(hunter, "law", 2)
		else:
			GameState.add_event("%s a trouvé des indices, mais pas de criminel." % hunter_name)
			ReputationManager.add_reputation(hunter, "combat", 2)
	else:
		GameState.add_event("%s a perdu la piste." % hunter_name)
	
	# Cooldown
	GameState.set_action_cooldown(hunter_name, "follow_trail", 4)
	MissionManager.record_progress(hunter_name, "trail")

# 4. Négocier une reddition (peut éviter un combat)
func negotiate_surrender(hunter: Dictionary, target: Dictionary = {}) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	if target.is_empty():
		target = _find_bounty_target()
	if target.is_empty():
		GameState.add_event("Aucune cible à négocier.")
		return
	
	var hunter_name = hunter.get("name", "Un chasseur")
	var target_name = target.get("name", "un criminel")
	var is_player = GameState.is_player_character(hunter_name)
	
	if GameState.is_action_on_cooldown(hunter_name, "negotiate_surrender"):
		GameState.add_event("%s ne peut pas négocier pour l'instant." % hunter_name)
		return
	
	GameState.add_event("%s tente de négocier la reddition de %s." % [hunter_name, target_name], "player" if is_player else "")
	
	# 50% de chance de succès
	if randf() < 0.50:
		GameState.mark_prisoner(target_name)
		var reward = int(target.get("bounty", 0) * 0.8)  # 80% de la prime
		if reward > 0:
			GameState.adjust_money(hunter_name, reward)
			target["bounty"] = 0
		GameState.add_event("%s a négocié la reddition de %s et encaisse $%d !" % [hunter_name, target_name, reward])
		GameState.adjust_town_morale(2)
		GameState.adjust_crime_level(-2)
		ReputationManager.add_reputation(hunter, "combat", 2)
		ReputationManager.add_reputation(hunter, "law", 4)
		ReputationManager.add_reputation(hunter, "reliability", 2)
		MissionManager.record_progress(hunter_name, "negotiation")
	else:
		GameState.add_event("%s a refusé de se rendre." % target_name)
		# Le criminel peut s'enfuir ou attaquer
		if randf() < 0.50:
			GameState.add_event("%s s'enfuit !" % target_name)
		else:
			InjuryManager.harm_character(hunter_name, "négociation échouée", 1)
			GameState.add_event("%s attaque %s par surprise !" % [target_name, hunter_name])
	
	# Cooldown
	GameState.set_action_cooldown(hunter_name, "negotiate_surrender", 5)

# 5. Former un possee (recrute temporairement des citoyens pour traquer)
func form_posse(hunter: Dictionary) -> void:
	if hunter.is_empty() or hunter.get("state", "alive") == "dead":
		return
	var hunter_name = hunter.get("name", "Un chasseur")
	var is_player = GameState.is_player_character(hunter_name)
	
	if GameState.is_action_on_cooldown(hunter_name, "form_posse"):
		GameState.add_event("%s ne peut pas former de possee pour l'instant." % hunter_name)
		return
	
	GameState.add_event("%s recrute des citoyens pour former une possee." % hunter_name, "player" if is_player else "")
	
	# La prochaine action de traque a +30% de chances de succès
	# (À implémenter : stocker un bonus dans GameState)
	GameState.adjust_town_morale(2)
	GameState.adjust_crime_level(-1)
	
	# Cooldown long
	GameState.set_action_cooldown(hunter_name, "form_posse", 8)
	ReputationManager.add_reputation(hunter, "combat", 3)
	ReputationManager.add_reputation(hunter, "law", 2)
	ReputationManager.add_reputation(hunter, "reliability", 1)
	MissionManager.record_progress(hunter_name, "posse")
```

#### **2.4. Actions pour le Brigand**

**Actions existantes** :
- `attack_convoy()` : Attaquer un convoi.

**Nouvelles actions** :
```gdscript
# 1. Voler un magasin (gains élevés, risque élevé)
func rob_store(brigand: Dictionary) -> void:
	if brigand.is_empty() or brigand.get("state", "alive") == "dead":
		return
	var brigand_name = brigand.get("name", "Un brigand")
	var is_player = GameState.is_player_character(brigand_name)
	
	if GameState.is_action_on_cooldown(brigand_name, "rob_store"):
		GameState.add_event("%s ne peut pas voler pour l'instant." % brigand_name)
		return
	
	GameState.add_event("%s tente de voler le magasin général." % brigand_name, "player" if is_player else "danger")
	
	# 60% de chance de succès
	if randf() < 0.60:
		var loot = randi_range(30, 50)
		GameState.adjust_money(brigand_name, loot)
		GameState.add_event("%s a dévalisé le magasin et s'enfuit avec $%d !" % [brigand_name, loot])
		GameState.mark_wanted(brigand_name, 30)
		GameState.adjust_crime_level(5)
		GameState.adjust_town_morale(-3)
		GameState.adjust_economy_stability(-2)
		ReputationManager.add_reputation(brigand, "crime", 5)
		MissionManager.record_progress(brigand_name, "robbery")
	else:
		# Échec : le brigand est repéré
		GameState.add_event("%s a été repéré en train de voler !" % brigand_name)
		GameState.mark_wanted(brigand_name, 15)
		GameState.adjust_crime_level(2)
		GameState.adjust_town_morale(-1)
	
	# Cooldown
	GameState.set_action_cooldown(brigand_name, "rob_store", 6)

# 2. Kidnapper un citoyen (pour rançon ou distraction)
func kidnap_citizen(brigand: Dictionary) -> void:
	if brigand.is_empty() or brigand.get("state", "alive") == "dead":
		return
	var brigand_name = brigand.get("name", "Un brigand")
	var is_player = GameState.is_player_character(brigand_name)
	
	if GameState.is_action_on_cooldown(brigand_name, "kidnap_citizen"):
		GameState.add_event("%s ne peut pas kidnapper pour l'instant." % brigand_name)
		return
	
	# Trouver une cible (n'importe quel personnage non-brigand)
	var candidates = []
	for character in GameState.get_alive_characters():
		if character.get("role_id", "") != "brigand" and character.get("state", "alive") != "wanted":
			candidates.append(character)
	
	if candidates.is_empty():
		GameState.add_event("Aucune cible disponible pour kidnapping.")
		return
	
	var target = candidates.pick_random()
	var target_name = target.get("name", "un citoyen")
	
	GameState.add_event("%s kidnappe %s !" % [brigand_name, target_name], "player" if is_player else "danger")
	
	# 70% de chance de succès
	if randf() < 0.70:
		# Le citoyen est "capturé" (marqué comme prisonnier temporairement)
		# (À implémenter : état "kidnapped")
		GameState.mark_wanted(brigand_name, 20)
		GameState.adjust_crime_level(4)
		GameState.adjust_town_morale(-4)
		ReputationManager.add_reputation(brigand, "crime", 4)
		ReputationManager.add_reputation(brigand, "combat", 2)
		MissionManager.record_progress(brigand_name, "kidnapping")
	else:
		# Échec : le citoyen résiste
		GameState.add_event("%s a résisté à %s !" % [target_name, brigand_name])
		GameState.mark_wanted(brigand_name, 10)
		GameState.adjust_crime_level(2)
	
	# Cooldown long
	GameState.set_action_cooldown(brigand_name, "kidnap_citizen", 8)

# 3. Corrompre un officiel (réduit la recherche, mais coûte cher)
func bribe_official(brigand: Dictionary) -> void:
	if brigand.is_empty() or brigand.get("state", "alive") == "dead":
		return
	var brigand_name = brigand.get("name", "Un brigand")
	var is_player = GameState.is_player_character(brigand_name)
	
	if GameState.is_action_on_cooldown(brigand_name, "bribe_official"):
		GameState.add_event("%s ne peut pas corrompre pour l'instant." % brigand_name)
		return
	
	# Coût de la corruption
	var bribe_cost = 40
	if GameState.get_money(brigand_name) < bribe_cost:
		GameState.add_event("%s n'a pas assez d'argent pour corrompre ($%d nécessaires)." % [brigand_name, bribe_cost])
		return
	
	GameState.adjust_money(brigand_name, -bribe_cost)
	GameState.add_event("%s corrompt un officiel pour réduire la pression." % brigand_name, "player" if is_player else "danger")
	
	# Réduit temporairement les chances d'être repéré
	# (À implémenter : bonus de furtivité)
	GameState.adjust_crime_level(-2)
	ReputationManager.add_reputation(brigand, "crime", 3)
	ReputationManager.add_reputation(brigand, "reliability", -1)  # La corruption a un coût moral
	
	# Cooldown
	GameState.set_action_cooldown(brigand_name, "bribe_official", 7)
	MissionManager.record_progress(brigand_name, "bribe")

# 4. Organiser une embuscade (attaque surprise avec bonus)
func setup_ambush(brigand: Dictionary) -> void:
	if brigand.is_empty() or brigand.get("state", "alive") == "dead":
		return
	var brigand_name = brigand.get("name", "Un brigand")
	var is_player = GameState.is_player_character(brigand_name)
	
	if GameState.is_action_on_cooldown(brigand_name, "setup_ambush"):
		GameState.add_event("%s ne peut pas organiser d'embuscade pour l'instant." % brigand_name)
		return
	
	GameState.add_event("%s prépare une embuscade dans le canyon." % brigand_name, "player" if is_player else "danger")
	
	# La prochaine attaque de convoi a +25% de chances de succès
	# (À implémenter : stocker un bonus dans GameState)
	GameState.adjust_crime_level(2)
	
	# Cooldown
	GameState.set_action_cooldown(brigand_name, "setup_ambush", 5)
	ReputationManager.add_reputation(brigand, "crime", 2)
	ReputationManager.add_reputation(brigand, "combat", 3)
	MissionManager.record_progress(brigand_name, "ambush")

# 5. Cacher du butin (sécurise l'argent, mais réduit la liquidité)
func stash_loot(brigand: Dictionary) -> void:
	if brigand.is_empty() or brigand.get("state", "alive") == "dead":
		return
	var brigand_name = brigand.get("name", "Un brigand")
	var is_player = GameState.is_player_character(brigand_name)
	
	if GameState.is_action_on_cooldown(brigand_name, "stash_loot"):
		GameState.add_event("%s ne peut pas cacher de butin pour l'instant." % brigand_name)
		return
	
	# Montant à cacher (50% de l'argent du brigand)
	var money = GameState.get_money(brigand_name)
	var stash_amount = max(5, money / 2)
	
	if money < 5:
		GameState.add_event("%s n'a pas assez d'argent à cacher." % brigand_name)
		return
	
	GameState.adjust_money(brigand_name, -stash_amount)
	GameState.add_event("%s cache $%d de butin." % [brigand_name, stash_amount], "player" if is_player else "")
	
	# L'argent caché est stocké séparément (à implémenter : variable stashed_money)
	# Pour maintenant, on simule juste l'action
	ReputationManager.add_reputation(brigand, "crime", 2)
	ReputationManager.add_reputation(brigand, "reliability", 1)
	
	# Cooldown
	GameState.set_action_cooldown(brigand_name, "stash_loot", 4)
	MissionManager.record_progress(brigand_name, "stash")
```

---

### **3. Modifications de `PlayerActionManager.gd`**

#### **3.1. Gestion des raccourcis clavier**
```gdscript
# Dans _unhandled_input, ajouter :
match event.keycode:
	KEY_1:
		if GameState.get_player().get("role_id", "") == "sheriff":
			TownActions.attempt_arrest(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "merchant":
			TownActions.transport_goods(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "bounty_hunter":
			TownActions.track_bounty(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "brigand":
			TownActions.attack_convoy(GameState.get_player())
	KEY_2:
		if GameState.get_player().get("role_id", "") == "sheriff":
			TownActions.patrol_town(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "merchant":
			TownActions.buy_goods(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "bounty_hunter":
			TownActions.investigate_bounty(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "brigand":
			TownActions.rob_store(GameState.get_player())
	KEY_3:
		if GameState.get_player().get("role_id", "") == "sheriff":
			TownActions.interrogate_suspect(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "merchant":
			TownActions.sell_goods(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "bounty_hunter":
			TownActions.set_trap(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "brigand":
			TownActions.kidnap_citizen(GameState.get_player())
	KEY_4:
		if GameState.get_player().get("role_id", "") == "sheriff":
			TownActions.organize_manhunt(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "merchant":
			TownActions.negotiate_with_suppliers(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "bounty_hunter":
			TownActions.follow_trail(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "brigand":
			TownActions.bribe_official(GameState.get_player())
	KEY_5:
		if GameState.get_player().get("role_id", "") == "sheriff":
			TownActions.post_wanted_posters(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "merchant":
			TownActions.organize_protected_convoy(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "bounty_hunter":
			TownActions.negotiate_surrender(GameState.get_player())
		elif GameState.get_player().get("role_id", "") == "brigand":
			TownActions.setup_ambush(GameState.get_player())
```

#### **3.2. Fonction pour obtenir les actions disponibles**
```gdscript
func get_available_actions(role_id: String) -> Array:
	var actions = []
	match role_id:
		"sheriff":
			actions = [
				{"name": "attempt_arrest", "display": "Arrêter un brigand", "key": "1"},
				{"name": "patrol_town", "display": "Patrouiller en ville", "key": "2"},
				{"name": "interrogate_suspect", "display": "Interroger un suspect", "key": "3"},
				{"name": "organize_manhunt", "display": "Organiser une battue", "key": "4"},
				{"name": "post_wanted_posters", "display": "Poster des avis", "key": "5"}
			]
		"merchant":
			actions = [
				{"name": "transport_goods", "display": "Transporter marchandises", "key": "1"},
				{"name": "buy_goods", "display": "Acheter marchandises", "key": "2"},
				{"name": "sell_goods", "display": "Vendre marchandises", "key": "3"},
				{"name": "negotiate_with_suppliers", "display": "Négocier avec fournisseurs", "key": "4"},
				{"name": "organize_protected_convoy", "display": "Convoi protégé", "key": "5"}
			]
		"bounty_hunter":
			actions = [
				{"name": "track_bounty", "display": "Traquer une prime", "key": "1"},
				{"name": "investigate_bounty", "display": "Enquêter sur une prime", "key": "2"},
				{"name": "set_trap", "display": "Poser un piège", "key": "3"},
				{"name": "follow_trail", "display": "Suivre une piste", "key": "4"},
				{"name": "negotiate_surrender", "display": "Négocier reddition", "key": "5"}
			]
		"brigand":
			actions = [
				{"name": "attack_convoy", "display": "Attaquer un convoi", "key": "1"},
				{"name": "rob_store", "display": "Voler un magasin", "key": "2"},
				{"name": "kidnap_citizen", "display": "Kidnapper un citoyen", "key": "3"},
				{"name": "bribe_official", "display": "Corrompre un officiel", "key": "4"},
				{"name": "setup_ambush", "display": "Préparer une embuscade", "key": "5"}
			]
		_:
			actions = []
	return actions
```

---

### **4. Modifications de `UIController.gd`**

#### **4.1. Affichage des actions disponibles**
Ajouter dans la fonction `refresh()` :
```gdscript
# Afficher les actions disponibles
var player = GameState.get_player()
var player_role = player.get("role_id", "")
if player_role != "":
	var actions = PlayerActionManager.get_available_actions(player_role)
	var action_texts = []
	for action in actions:
		var cooldown_remaining = 0
		if GameState.action_cooldowns.has("%s_%s" % [GameState.player_name, action.get("name", "")]):
			cooldown_remaining = GameState.action_cooldowns["%s_%s" % [GameState.player_name, action.get("name", "")]]
		var action_display = action.get("display", "")
		if cooldown_remaining > 0:
			action_display += " (CD: %d)" % cooldown_remaining
		action_texts.append("%s: %s" % [action.get("key", ""), action_display])
	action_label.text = "Actions: %s" % ", ".join(action_texts)
else:
	action_label.text = PlayerActionManager.get_action_hint()
```

---

### **5. Tests unitaires**

Créer un fichier `tests/test_town_actions_phase2.gd` avec des tests pour :
- Chaque nouvelle action (vérification des impacts sur les variables globales)
- Le système de cooldown
- L'intégration avec les raccourcis clavier

---

## **📋 Critères d'acceptation**

- [ ] Chaque rôle a **5+ actions disponibles**
- [ ] Chaque action a un **impact unique** sur les variables globales
- [ ] Les actions ont des **cooldowns appropriés** (3-10 tours)
- [ ] Les actions sont **accessibles via raccourcis clavier** (1-5)
- [ ] Les actions affichent des **messages de feedback clairs**
- [ ] Les actions respectent les **règles du jeu** (ex : besoin d'argent pour certaines actions)
- [ ] Les **tests unitaires** passent
- [ ] Le code est **documenté** et suit les conventions du projet

---

## **⚠️ Risques et dépendances**

### **Dépendances**
- **BG-001-P1** : Les variables globales doivent être implémentées
- **GameState.gd** : Doit avoir les fonctions de modification des variables globales
- **MissionManager.gd** : Doit avoir `record_progress()`
- **ReputationManager.gd** : Doit avoir `add_reputation()`

### **Risques**
- **Complexité accrue** : Beaucoup de nouvelles fonctions à tester
- **Déséquilibre** : Certaines actions pourraient être trop puissantes
- **Répétitivité** : Même avec 5 actions, les joueurs pourraient trouver un pattern optimal

### **Atténuation**
- **Tests unitaires** pour chaque action
- **Équilibrage initial** basé sur les valeurs de la Phase 1
- **Feedback utilisateur** pour ajuster les valeurs

---

## **📅 Planning estimé**

| **Tâche** | **Durée** | **Priorité** |
|-----------|-----------|--------------|
| Implémentation des actions Sheriff | 2-3 heures | Haute |
| Implémentation des actions Marchand | 2-3 heures | Haute |
| Implémentation des actions Chasseur de primes | 2-3 heures | Haute |
| Implémentation des actions Brigand | 2-3 heures | Haute |
| Système de cooldown | 1-2 heures | Moyenne |
| Intégration UI (raccourcis) | 1-2 heures | Moyenne |
| Tests unitaires | 1-2 heures | Moyenne |
| Documentation | 1 heure | Faible |

---

## **📝 Notes supplémentaires**

### **Équilibrage initial suggéré**
| **Action** | **Impact Moral** | **Impact Criminalité** | **Impact Économie** | **Cooldown** | **Récompense** |
|-----------|------------------|------------------------|---------------------|--------------|---------------|
| patrol_town | +1 | -2 | 0 | 4 | Réputation +2 |
| interrogate_suspect | 0 | 0 | 0 | 5 | Réputation +2-3 |
| organize_manhunt | +2 | -3 | 0 | 8 | Réputation +4-2 |
| post_wanted_posters | +1 | 0 | 0 | 6 | Réputation +3 |
| inspect_location | 0 | 0 | +1 | 5 | Réputation +2-4 |
| buy_goods | 0 | 0 | +1 | 4 | Prix ×0.95 |
| sell_goods | 0 | 0 | +1 | 4 | Prix ×1.05 |
| negotiate_with_suppliers | 0 | 0 | 0 | 6 | Prix ×0.90 |
| organize_protected_convoy | 0 | 0 | +2 | 5 | Réputation +2-3 |
| invest_in_infrastructure | +2 | 0 | +5 | 10 | Réputation +5-3 |
| investigate_bounty | +1 | 0 | 0 | 3 | Réputation +2-1 |
| set_trap | +3 | -3 | 0 | 6 | Récompense +3-3 |
| follow_trail | 0 | 0 | 0 | 4 | Réputation +2-3 |
| negotiate_surrender | +2 | -2 | 0 | 5 | Récompense 80% |
| form_posse | +2 | -1 | 0 | 8 | Réputation +3-2-1 |
| rob_store | -3 | +5 | -2 | 6 | $30-50 |
| kidnap_citizen | -4 | +4 | 0 | 8 | Réputation +4-2 |
| bribe_official | 0 | -2 | 0 | 7 | Réputation +3-1 |
| setup_ambush | 0 | +2 | 0 | 5 | Réputation +2-3 |
| stash_loot | 0 | 0 | 0 | 4 | Réputation +2-1 |

### **Améliorations futures (Phase 3+)**
- **Bonus temporaires** : Implémenter les bonus de succès temporaires (ex : +20% de chances après enquête)
- **Effets durables** : Ajouter des effets qui persistent plusieurs tours
- **Interactions entre actions** : Certaines actions pourraient se combiner (ex : embuscade + attaque de convoi)
- **Actions de groupe** : Permettre à plusieurs joueurs de coopérer sur une action

---

## **🎯 Prochaines étapes**
1. **Phase 3 (BG-001-P3)** : Ajouter des événements dynamiques déclenchés par les actions
2. **Phase 4 (BG-001-P4)** : Implémenter les effets durables des variables globales
3. **Phase 5 (BG-001-P5)** : Tests et ajustements finaux
4. **Phase 6 (BG-001-P6)** : Validation utilisateur (sessions de 2 heures)
