# CHANGELOG.md

# Frontier Town - Historique des modifications

> Ce document recense toutes les modifications apportées au projet, classées par version.
> Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

---

## [0.6.2] - 2026-07-31

### 🐛 Corrigé
- Erreur de parsing bloquant le chargement de `tests/test_town_actions_p2.gd` et `tests/test_game_state_globals.gd` : `async func _ready()` n'est pas une syntaxe valide en GDScript 4 (Godot 4 n'a pas de mot-clé `async` ; il suffit d'utiliser `await` directement dans une fonction normale). Les deux fichiers empêchaient le chargement du projet.

---

## [0.6.1] - 2026-07-31

### 📦 Ajouté
- **[BG-001-P2]** 4 actions manquantes pour le **Chasseur de primes**, qui n'avait que `track_bounty` alors que la spec en prévoyait 5 comme les autres rôles : `investigate_bounty` (enquêter sur une prime), `set_trap` (poser un piège, capture automatique 40%), `follow_trail` (suivre une piste), `negotiate_surrender` (négocier une reddition, 80% de la prime). Adaptées de `docs/BG-001_PHASE2_TICKET.md` à l'architecture réelle du projet (pas de cooldown par action/personnage, réutilisation du cooldown global existant).
- **[BG-001-P2]** Test unitaire `_test_bounty_hunter_actions()` dans `tests/test_town_actions_p2.gd`, qui manquait alors que les 5 autres rôles (Sheriff, Marchand, Brigand, Adjoint, Habitant) étaient déjà couverts.

### 🔧 Modifié
- `scripts/PlayerActionManager.gd` : le Chasseur de primes passe de 1 à 5 actions dans son menu (`ROLE_ACTIONS`).

### 📝 Statut BG-001-P2
Avec ce correctif, les 6 rôles (Sheriff, Marchand, Chasseur de primes, Brigand, Adjoint, Habitant) ont chacun 4 ou 5 actions accessibles en jeu et testées. Écarts connus et assumés par rapport à la spec initiale : cooldown global (par joueur) plutôt que par action/personnage en tours, pas de raccourcis clavier 1-5 dédiés (menu cliquable à la place), les PNJ simulés n'utilisent que les actions historiques (Phase 1).

---

## [0.6.0] - 2026-07-31

### 📦 Ajouté
- **[BG-002]** Écran de sélection de sauvegarde au démarrage : boutons "Continuer" / "Nouvelle Partie", confirmation obligatoire avant d'écraser une sauvegarde existante ("Cela écrasera votre sauvegarde actuelle. Êtes-vous sûr ?").
- **[BG-003]** Suppression automatique des cadavres (joueurs et PNJ) de la carte et de la mémoire 2 jours après leur mort.
- **[TCK3]** Système de fenêtres pour le HUD (Statut), les Rôles et le Journal : déplacement, redimensionnement, minimisation, fermeture, anti-chevauchement, cycle `TAB`, menu de réouverture (`CTRL+TAB` ou bouton "Fenêtres"), disposition persistée entre sessions.
- **[TCK4]** Nouveaux rôles jouables **Adjoint** (Deputy) et **Habitant** (Citizen), sélectionnables comme les autres rôles, avec 4 actions chacun accessibles via un menu d'actions.
- **[TCK5]** Menu d'actions généralisé à Sheriff, Marchand, Chasseur de primes et Brigand : les actions de BG-001-P2 déjà écrites dans `TownActions.gd` mais jamais reliées à l'UI (15 actions au total) sont désormais toutes accessibles et filtrées par rôle.

### 🔧 Modifié
- `scripts/GameState.gd` : `restart_new_game()`, `loaded_from_save`, `time_of_death` et nettoyage des cadavres expirés, signal `character_removed`.
- `scripts/RoleManager.gd` : files d'attente `deputy` et `citizen`, fonction `reset_queues()`.
- `scripts/World.gd` : respawn des PNJ sur nouvelle partie, suppression du nœud visuel des cadavres expirés.
- `scripts/Player.gd` : joueur gelé pendant l'écran de sélection de sauvegarde et le menu de fenêtres.
- `scripts/ZoneManager.gd` : zones autorisées et indices pour `citizen` et `deputy`.
- `scripts/PlayerActionManager.gd` : réécriture du dispatch des actions — table `ROLE_ACTIONS` centralisée par rôle, actions indisponibles (cooldown, mauvaise zone) affichées grisées avec leur raison dans le menu au lieu d'un simple message dans le journal.
- `scripts/UIController.gd` : panneaux de sélection de sauvegarde, de confirmation, de gestion de fenêtres et de menu d'actions ; chemins des nœuds HUD/Rôles/Journal mis à jour pour la nouvelle structure de fenêtres.
- `scenes/UI.tscn` : panneaux HUD/Rôles/Journal transformés en fenêtres déplaçables ; ajout des panneaux de sélection de sauvegarde, de confirmation, de gestion de fenêtres et de menu d'actions.
- `data/roles.json` : ajout des rôles `deputy` et `citizen`.

### 🐛 Corrigé
- **[TCK4]** `guard_prisoner()` appelait une méthode inexistante `PrisonManager.release_prisoner()` au lieu de `release()` : aurait fait planter le jeu lors d'une évasion de prisonnier réussie.
- **[TCK5]** `organize_posse()` affichait littéralement `%s` au lieu du nom du brigand capturé (substitution de format manquante).

### 📄 Nouveaux fichiers
- `scripts/WindowFrame.gd`, `scripts/WindowManager.gd` (TCK3).

---

## **[Non publié]** *(En développement - Phase 1 BG-001)*

### **📦 Ajouté**
- **Système de variables globales** :
  - Ajout de `town_morale` (0-100) pour suivre le moral général de la ville.
  - Ajout de `crime_level` (0-100) pour suivre le niveau de criminalité.
  - Ajout de `economy_stability` (0-100) pour suivre la stabilité économique.
  - Ajout de `goods_price` (multiplicateur de prix) pour ajuster les prix en fonction de l'offre/demande.
  - Fonctions de modification : `adjust_town_morale()`, `adjust_crime_level()`, `adjust_economy_stability()`, `adjust_goods_price()`, `get_goods_price()`.

- **Intégration des variables globales** :
  - `attempt_arrest()` (Sheriff) impacte maintenant `town_morale` (+3) et `crime_level` (-5).
  - `attack_convoy()` (Brigand) impacte maintenant `crime_level` (+3) et `town_morale` (-2), et augmente `goods_price` (x1.1).
  - `transport_goods()` (Marchand) impacte maintenant `economy_stability` (+2) et utilise `goods_price` pour calculer les gains.
  - `track_bounty()` (Chasseur de primes) impacte maintenant `town_morale` (+4) et `crime_level` (-4).

- **Feedback utilisateur** : Messages dans le journal pour les changements de seuils (ex : "La ville est en colère ! Moral : 15").

- **Sauvegarde des variables globales** : Les variables `town_morale`, `crime_level`, `economy_stability` et `goods_price` sont maintenant sauvegardées et chargées.

- **Tests unitaires** :
  - `tests/test_game_state_globals.gd` : Tests pour valider les fonctions de modification des variables globales.

- **Documentation** :
  - `BG-001_PHASE1_TICKET.md` : Ticket détaillé pour la Phase 1 (Fondations).
  - `RECOMMENDATIONS_AVOID_REPETITIVITY.md` : Recommandations pour éviter la répétitivité.

### **🔧 Modifié**
- `scripts/GameState.gd` : Ajout des variables globales, fonctions de modification, et vérification des seuils.
- `scripts/TownActions.gd` : Intégration avec les variables globales pour toutes les actions existantes.
- `scripts/UIController.gd` : Affichage des événements liés aux variables globales avec couleurs spécifiques.
- `scripts/SaveManager.gd` : Sauvegarde et chargement des variables globales.
- `docs/BACKLOG.md` : Mise à jour de BG-001 et ajout des sous-tâches.

### **📝 Documentation**
- Création de `BG-001_PHASE1_TICKET.md` (détail technique pour les développeurs/IA).
- Création de `RECOMMENDATIONS_AVOID_REPETITIVITY.md` (bonnes pratiques anti-répétitivité).

---
## **[0.5.0]** *(Validé - 25 juillet 2026)*

### **📦 Ajouté**
- **Files d'attente sélectionnables** : Panneau interactif pour rejoindre/quitter les files de rôle.
- **Missions par rôle** : Système de missions automatiques (ex : "Arrêter 2 brigands" pour le Sheriff).
- **Système de soins** : Soins au saloon ($10) et à la boutique ($15) pour réduire les blessures.
- **Blessures avant la mort** : 0-3 blessures par personnage (ralentissement, vulnérabilité).
- **Prison fonctionnelle** : 4 tours de peine par défaut, avec options d'évasion (35% de réussite).
- **Nouveau personnage après mort** : Écran de mort avec historique + création d'un nouveau personnage ($25, sans rôle).
- **Sauvegarde locale** : Fichier `user://frontier_town_save.json` (personnages, files, journal, historique).

### **🔧 Modifié**
- `scripts/PrisonManager.gd` : Ajout de la gestion des peines et de l'évasion.
- `scripts/InjuryManager.gd` : Système de blessures (0-3) avec effets sur les déplacements.
- `scripts/MissionManager.gd` : Génération et suivi des missions par rôle.
- `scripts/HealManager.gd` : Logique de soins (saloon, boutique).
- `scripts/Player.gd` : Gestion de la création de nouveau personnage.
- `scripts/SaveManager.gd` : Sauvegarde des nouvelles données (blessures, missions, etc.).

### **🎉 Nouveaux événements**
- **Blessures** : Messages détaillés (légère/grave/critique) dans le journal.
- **Prison** : Notifications de début/fin de peine.
- **Mort** : Écran de résumé + historique des morts.

---
## **[0.4.0]** *(Validé - 20 juillet 2026)*

### **📦 Ajouté**
- **Système de blessures** : 0-3 blessures par personnage (effets : ralentissement, vulnérabilité).
- **Prison fonctionnelle** : Incarcération pour 4 tours, avec mécaniques d'évasion.
- **Mort et nouveau personnage** : Historique des morts + écran de création.
- **Sauvegarde locale** : Persistance des personnages, files d'attente, journal, et historique.

### **🔧 Modifié**
- `scripts/InjuryManager.gd` : Gestion des blessures et de leurs effets.
- `scripts/PrisonManager.gd` : Logique de prison et d'évasion.
- `scripts/GameState.gd` : Ajout de l'historique des morts.

---
## **[0.3.0]** *(Validé - 15 juillet 2026)*

### **📦 Ajouté**
- **Carte avec routes et bâtiments nommés** : Génération procédurale depuis `data/locations.json`.
- **Collisions** : Murs aux limites, parois du canyon, bâtiments.
- **Interactions de zone** : Messages dans le journal à l'entrée/sortie des zones.
- **Actions liées aux zones** : Chaque rôle ne peut agir que dans des zones spécifiques.
- **Interface améliorée** : HUD avec rôle, état, argent, prime, zone actuelle.

### **🔧 Modifié**
- `scripts/World.gd` : Construction de la carte et gestion des collisions.
- `scripts/ZoneManager.gd` : Détection des zones et gestion des priorités.
- `scripts/LocationZone.gd` : Logique d'entrée/sortie des zones.
- `scripts/UIController.gd` : Amélioration du HUD.

---
## **[0.2.0]** *(Validé - 10 juillet 2026)*

### **📦 Ajouté**
- **Actions de rôle** : Touche **E** pour agir selon son rôle.
  - Sheriff : Tenter une arrestation.
  - Chasseur de primes : Traquer une prime.
  - Marchand : Lancer un transport.
  - Brigand : Attaquer un convoi.
  - Sans rôle : Consulter les files (1-4 pour rejoindre).
- **Impact sur le journal** : Toutes les actions du joueur apparaissent dans le journal de ville.
- **Gains économiques** : Argent et réputation ajustés selon les actions.

### **🔧 Modifié**
- `scripts/PlayerActionManager.gd` : Dispatch des actions selon le rôle.
- `scripts/TownActions.gd` : Logique partagée entre joueur et PNJ.
- `scripts/EventManager.gd` : Événements automatiques utilisant les mêmes actions.

---
## **[0.1.0]** *(Validé - 5 juillet 2026)*

### **📦 Ajouté**
- **Prototype solo avec joueurs simulés** : 10 personnages simulés sur la carte.
- **Rôles et files d'attente** : 1 Sheriff, 2 Marchands, 2 Chasseurs de primes, 5 Brigands.
- **Événements simulés** : Transport de marchandises, attaque de convoi, prime placée, duel, arrestation, mort, promotion.
- **Carte de Frontier Town** : Bureau du Sheriff, banque, saloon, boutique, écurie, entrepôt, place centrale.
- **Extérieurs** : Route sud, ranch/dépôt, mine abandonnée, canyon/embuscade, route commerciale Est, camp brigand.

### **🎨 Visuel**
- Personnages affichés sur la carte avec **couleurs par rôle**.
- **État visible** : Vivant, recherché, prisonnier, mort.
- **Comportement** : Personnages errent autour de leur zone de départ.

---
## **[0.0.1]** *(Prototype initial - 1 juillet 2026)*

### **📦 Ajouté**
- Projet Godot créé.
- Scène principale et carte simple de Frontier Town.
- Joueur contrôlable (déplacements).
- Système de rôles et données de personnages en JSON.
- Journal de ville basique.

---
## **📜 Conventions pour ce fichier**

### **Format des versions**
- **`[X.Y.Z]`** : Version majeure.mineure.correctif.
  - `X` : Changements majeurs (nouvelle ville, multijoueur).
  - `Y` : Ajouts de fonctionnalités (nouveaux rôles, systèmes).
  - `Z` : Corrections et ajustements mineurs.

### **Catégories**
- **📦 Ajouté** : Nouvelles fonctionnalités.
- **🔧 Modifié** : Changements dans des fonctionnalités existantes.
- **🗑️ Supprimé** : Fonctionnalités retirées.
- **🐛 Corrigé** : Bugs fixés.
- **📝 Documentation** : Mises à jour de documentation.

### **Ordre chronologique**
- Les versions sont **classées du plus récent au plus ancien**.
- Chaque version a une **date de sortie** et une **liste de modifications**.

---
## **📅 Roadmap des prochaines versions**
   **Version** | **Date prévue** | **Contenu principal** | **Statut** |
 |-------------|-----------------|-----------------------|------------|
 | 0.5.1 | 27 juillet 2026 | Intégration des variables globales (Phase 1 BG-001) | 🟡 En développement |
 | 0.6.0 | Août 2026 | Actions variées par rôle (Phase 2 BG-001) | 📅 Planifié |
 | 0.7.0 | Août 2026 | Événements dynamiques (Phase 3 BG-001) | 📅 Planifié |
 | 0.8.0 | Septembre 2026 | Vertical Slice (Phase 6 Roadmap) | 📅 Planifié |

---
*Dernière mise à jour : 31 juillet 2026*
