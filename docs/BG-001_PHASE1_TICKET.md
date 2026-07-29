# **Ticket BG-001-P1 : Fondations pour l'équilibrage des rôles (Phase 1)**

---

## **📌 Métadonnées**
- **ID** : BG-001-P1
- **Parent** : BG-001 (Équilibrer les rôles de Frontier Town)
- **Phase** : 1/6 (Fondations)
- **Priorité** : P0 (Bloquant)
- **Statut** : Prêt pour développement
- **Estimation** : 4-6 heures
- **Assigné à** : IA (avec validation humaine)
- **Date de création** : 26 juillet 2026

---
## **🎯 Objectif**
Poser les **fondations techniques** pour l'équilibrage long terme des rôles en :
1. Ajoutant des **variables globales** pour suivre l'état du monde.
2. Préparant l'architecture pour des **actions variées par rôle**.
3. Permettant un **impact mesurable** des actions du joueur sur l'environnement.

**Objectif final de la Phase 1** :
> *Un joueur peut voir que ses actions (ex : arrêter un brigand) ont un impact visible sur le monde (ex : moral de la ville augmente, criminalité diminue).*

---
## **📋 Contexte**
Ce ticket fait partie de la **solution révisée pour BG-001**, qui vise à rendre chaque rôle **intéressant pendant des sessions de 2 heures** (et non 30 minutes).

**Problème actuel** :
- Les actions des joueurs **n'ont pas d'impact durable** sur le monde.
- Le monde semble **statique** et **peu réactif**.
- Les rôles manquent de **profondeur stratégique**.

**Solution** :
- Ajouter des **variables globales** (moral, criminalité, économie).
- Lier ces variables aux **actions existantes** (ex : une arrestation → moral ↑, criminalité ↓).
- Préparer l'architecture pour des **actions futures** (Phase 2).

---
## **🔧 Portée du Ticket**

### **✅ Inclus dans ce ticket**
1. Ajout de **4 variables globales** dans `GameState.gd` :
   - `town_morale` (0-100)
   - `crime_level` (0-100)
   - `economy_stability` (0-100)
   - `goods_price` (multiplicateur de prix)
2. Ajout de **4 fonctions de modification** pour ces variables (avec clamp et effets de seuil).
3. **Intégration basique** avec les actions existantes :
   - `attempt_arrest()` (Sheriff) → impact sur `town_morale` et `crime_level`.
   - `attack_convoy()` (Brigand) → impact sur `crime_level` et `town_morale`.
   - `transport_goods()` (Marchand) → impact sur `economy_stability`.
   - `track_bounty()` (Chasseur de primes) → impact sur `town_morale`.
4. **Affichage basique** dans le journal de ville (ex : "Le moral de la ville augmente !").
5. **Tests unitaires** pour valider les modifications.

### **❌ Exclu de ce ticket**
- Ajout de **nouvelles actions** (Phase 2).
- Ajout d'**événements dynamiques** (Phase 3).
- **Interface utilisateur** avancée (affichage des variables dans le HUD).
- **Équilibrage fin** des valeurs (sera fait en Phase 6).

---
## **📁 Fichiers à modifier**
   **Fichier** | **Type** | **Modifications** | **Lignes estimées** | **Risque** |
 |-------------|----------|-------------------|---------------------|------------|
 | `scripts/GameState.gd` | Script | Ajout variables globales + fonctions | +50 | Faible |
 | `scripts/TownActions.gd` | Script | Appels aux nouvelles fonctions | +20 | Moyen |
 | `scripts/UIController.gd` | Script | Affichage basique des événements | +10 | Faible |
 | `docs/CHANGELOG.md` | Documentation | Journal des modifications | +10 | Aucun |

---
## **🛠️ Implémentation Détaillée**

---
### **1. Modifications de `GameState.gd`**

#### **1.1. Ajout des variables globales**
Ajouter **à la racine de la classe** (après les autres variables) :
```gdscript
# Variables globales pour l'équilibrage du monde
var town_morale := 50  # 0-100 : Moral général de la ville
var crime_level := 30  # 0-100 : Niveau de criminalité
var economy_stability := 70  # 0-100 : Stabilité économique
var goods_price := 1
