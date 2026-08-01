# GAME_DESIGN_DOCUMENT.md

# Frontier Town - Game Design Document

Version : 0.3

---

# Présentation

Frontier Town est un MMORPG 2D top-down dans un univers western réaliste.

Le jeu repose sur un monde vivant où les joueurs créent leurs propres histoires grâce à leurs interactions.

Le joueur n'est jamais le héros du monde.

Il est un habitant parmi les autres.

---

# Les piliers du gameplay

## Mort permanente

La mort est définitive.

Le personnage disparaît définitivement.

Toutes ses responsabilités sont perdues.

Un nouveau personnage doit être créé.

---

## Rôles limités

Chaque ville possède un nombre limité de postes.

Exemple :

- Sheriff
- Marchands
- Chasseurs de primes
- Brigands
- Adjoints (Deputy)
- Habitants (Townfolk)

Un rôle occupé ne peut pas être obtenu immédiatement.

---

## Succession

Lorsqu'un titulaire disparaît :

- son poste devient vacant
- le premier joueur de la file d'attente obtient automatiquement le rôle

La succession fait partie intégrante du gameplay.

---

## Réputation

La réputation représente l'histoire du personnage.

Elle évolue selon les actions réalisées.

Elle permet progressivement d'accéder à des rôles et à des villes plus importantes.

---

# Boucle de jeu

```
Créer un personnage

↓

Explorer la ville

↓

Choisir une orientation

↓

Intégrer une file d'attente

↓

Obtenir un rôle

↓

Exercer ce rôle

↓

Influencer le monde

↓

Construire une réputation

↓

Prendre des risques

↓

Mourir

↓

Créer un nouveau personnage
```

---

# Frontier Town

Première ville du jeu.

Objectifs :

- apprendre les mécaniques
- comprendre les rôles
- découvrir les conséquences de la mort

Aucun prérequis de réputation.

---

# Rôles

## Sheriff

Mission :

Maintenir l'ordre.

Responsabilités :

- arrêter les criminels
- protéger les marchands
- intervenir lors des attaques
- patrouiller dans la ville
- interroger des témoins
- organiser une milice citoyenne
- imposer un couvre-feu

Objectif :

Limiter la criminalité.

**Actions disponibles (BG-001-P2) :**
- `attempt_arrest` : Tenter d'arrêter un criminel recherché
- `track_bounty` : Traquer un criminel avec une prime
- `patrol_town` : Patrouiller dans la ville pour dissuader les criminels
- `interrogate_witness` : Interroger des témoins pour résoudre des crimes
- `organize_posse` : Organiser une milice citoyenne pour aider à maintenir l'ordre
- `enforce_curfew` : Imposer un couvre-feu pour réduire la criminalité nocturne

---

## Marchand

Mission :

Faire circuler les marchandises.

Responsabilités :

- organiser des convois
- vendre des ressources
- générer de l'activité économique
- négocier avec les fournisseurs
- corrompre des officiels
- faire passer de la contrebande
- installer des stands temporaires

Objectif :

S'enrichir.

**Actions disponibles (BG-001-P2) :**
- `transport_goods` : Transporter des marchandises entre les villes
- `attack_convoy` : Attaquer un convoi de marchandises (réservé aux brigands)
- `negotiate_prices` : Négocier les prix avec les fournisseurs
- `bribe_officials` : Corrompre des officiels pour faciliter les affaires
- `smuggle_contraband` : Faire passer de la contrebande en ville
- `setup_trade_stand` : Installer un stand de commerce temporaire

---

## Chasseur de primes

Mission :

Capturer ou éliminer des criminels recherchés.

Responsabilités :

- suivre les avis de recherche
- retrouver les fugitifs

Objectif :

Gagner de l'argent.

**Actions disponibles (BG-001-P2) :**
- `track_bounty` : Traquer un criminel avec une prime
- `investigate_bounty` : Enquêter sur une prime pour réunir des informations
- `set_trap` : Poser un piège pour capturer automatiquement un criminel recherché
- `follow_trail` : Suivre une piste pour localiser un criminel recherché
- `negotiate_surrender` : Négocier la reddition d'un criminel plutôt que l'affronter

---

## Brigand

Mission :

Profiter des faiblesses du système.

Responsabilités :

- attaquer les convois
- voler
- échapper aux autorités
- tendre des embuscades
- saboter les infrastructures
- extorquer de l'argent de protection
- cacher le butin

Objectif :

Faire fortune malgré les risques.

**Actions disponibles (BG-001-P2) :**
- `attack_convoy` : Attaquer un convoi de marchandises
- `ambush_merchants` : Tendre une embuscade aux marchands sur les routes
- `sabotage_town_infrastructure` : Saboter les infrastructures de la ville
- `extort_protection_money` : Extorquer de l'argent de protection aux commerçants
- `hide_loot` : Cacher le butin dans des cachettes secrètes

---

## Adjoint (Deputy)

Mission :

Assister le shérif dans le maintien de l'ordre.

Responsabilités :

- assister aux arrestations
- patrouiller à la périphérie
- remettre des mandats
- surveiller les prisonniers

Objectif :

Aider le shérif et maintenir la loi.

**Actions disponibles (BG-001-P2) :**
- `assist_arrest` : Assister le shérif dans une arrestation
- `scout_perimeter` : Patrouiller à la périphérie de la ville pour détecter les menaces
- `deliver_warrant` : Remettre un mandat d'arrêt à un criminel
- `guard_prisoner` : Surveiller les prisonniers pour empêcher les évasions

---

## Habitant (Townfolk)

Mission :

Vivre dans la ville et contribuer à la communauté.

Responsabilités :

- signaler des crimes
- propager des rumeurs
- organiser des milices citoyennes
- protester contre les conditions de vie

Objectif :

Survivre et influencer la vie de la communauté.

**Actions disponibles (BG-001-P2) :**
- `report_crime` : Signaler un crime aux autorités
- `gossip` : Propager des rumeurs dans la ville
- `form_militia` : Organiser une milice citoyenne pour se protéger
- `protest` : Organiser une protestation contre les autorités ou les conditions de vie

---

# Réputation

Dimensions prévues :

- Loi
- Crime
- Commerce
- Fiabilité
- Combat

Chaque réputation évolue indépendamment.

---

# Argent

L'argent est obtenu grâce aux activités du personnage.

Il ne constitue pas un niveau.

Il sert à créer des opportunités et des risques.

---

# Prison

Un personnage arrêté est temporairement privé d'action.

La prison est une alternative à la mort.

---

# Blessures

Une blessure diminue temporairement les capacités du personnage.

Elle augmente le risque de mourir.

---

# Journal de ville

Le journal retrace les événements importants.

Exemples :

- arrestation
- promotion
- duel
- décès
- attaque
- transport
- succession

Le journal constitue la mémoire publique de la ville.

---

# Économie

L'économie doit être principalement alimentée par les joueurs.

Les PNJ servent uniquement à soutenir le fonctionnement du monde.

---

# Monde

Le monde continue d'évoluer même sans intervention du joueur.

Les événements peuvent modifier durablement l'équilibre d'une ville.

---

# Variables Globales (BG-001-P1)

Le jeu utilise quatre variables globales pour équilibrer le monde :

- **town_morale** (0-100) : Moral général de la ville. Affecte la coopération des habitants et la stabilité.
- **crime_level** (0-100) : Niveau de criminalité. Influence la fréquence des crimes et la sécurité.
- **economy_stability** (0-100) : Stabilité économique. Impacte les prix et les opportunités commerciales.
- **goods_price** (0.5-2.0) : Multiplicateur de prix des marchandises. Affecte les coûts et les profits.

Chaque action des personnages peut influencer une ou plusieurs de ces variables.

---

# Actions par Rôle (BG-001-P2)

## Vue d'ensemble

Chaque rôle dispose de 5+ actions variées, équilibrées et engageantes pour des sessions de 2h+.

### Sheriff (5 actions)
| Action | Impact Principal | Risque | Récompense |
|--------|------------------|--------|------------|
| attempt_arrest | ✓ crime_level, ✓ town_morale | Échec de l'arrestation | Réputation loi +5 |
| track_bounty | ✓ crime_level, ✓ town_morale | Cible s'échappe | Prime + réputation |
| patrol_town | ✓ crime_level, ✓ town_morale | Affrontement | Réputation loi +2-4 |
| interrogate_witness | ✓ crime_level | Faux témoignage | Réputation loi +3 |
| organize_posse | ✓ crime_level, ✓ town_morale | Affrontement | Réputation loi +3-5 |
| enforce_curfew | ✗ crime_level (fort) | Impopularité | Réputation loi +4 |

### Brigand (5 actions)
| Action | Impact Principal | Risque | Récompense |
|--------|------------------|--------|------------|
| attack_convoy | ✗ crime_level, ✗ town_morale, ✗ economy | Contre-attaque | Butin $10-25 |
| ambush_merchants | ✗ crime_level, ✗ town_morale, ✗ economy | Détection | Butin $20-40 |
| sabotage_town_infrastructure | ✗ economy, ✗ town_morale, ✗ crime | Détection | Réputation crime +6 |
| extort_protection_money | ✗ crime_level, ✗ town_morale | Résistance | Argent $15-35 |
| hide_loot | ✓ crime_level (indirect) | Découverte | Sécurité du butin |

### Merchant (5 actions)
| Action | Impact Principal | Risque | Récompense |
|--------|------------------|--------|------------|
| transport_goods | ✓ economy, ✓ town_morale | Attaque | Profit $15-30 |
| negotiate_prices | ✓ economy, ✗ goods_price | Échec | Réputation commerce +4 |
| bribe_officials | ✓ economy, ✗ crime | Découverte | Accès privilégié |
| smuggle_contraband | ✓ economy, ✗ goods_price | Confiscation | Profit $40-80 |
| setup_trade_stand | ✓ economy, ✓ town_morale | Vol | Profit $25-50 |

### Chasseur de primes (5 actions)
| Action | Impact Principal | Risque | Récompense |
|--------|------------------|--------|------------|
| track_bounty | ✓ crime_level, ✓ town_morale | Cible s'échappe | Prime + réputation |
| investigate_bounty | ✓ town_morale (léger) | Aucun | Réputation combat/loi |
| set_trap | ✓ crime_level, ✓ town_morale | Piège vide (60%) | Prime + réputation |
| follow_trail | Aucun impact global direct | Piste perdue (40%) | Réputation combat/loi |
| negotiate_surrender | ✓ crime_level, ✓ town_morale | Refus, fuite ou attaque | 80% de la prime + réputation |

### Deputy (4 actions)
| Action | Impact Principal | Risque | Récompense |
|--------|------------------|--------|------------|
| assist_arrest | ✓ crime_level, ✓ town_morale | Blessure | Réputation loi +4 |
| scout_perimeter | ✓ crime_level, ✓ town_morale | Embuscade | Réputation loi +2-3 |
| deliver_warrant | ✓ crime_level, ✓ town_morale | Résistance | Réputation loi +5 |
| guard_prisoner | ✓ crime_level, ✓ town_morale | Évasion | Réputation loi +2-3 |

### Townfolk (4 actions)
| Action | Impact Principal | Risque | Récompense |
|--------|------------------|--------|------------|
| report_crime | ✓ crime_level, ✓ town_morale | Ignoré | Réputation fiabilité +2 |
| gossip | ✓/✗ town_morale | Conflit | Réputation variable |
| form_militia | ✓ crime_level, ✓ town_morale | Conflit/inefficacité | Réputation +2-4 |
| protest | ✓/✗ town_morale | Répression | Réputation variable |

---

# Progression

Le personnage ne progresse pas grâce à des niveaux.

Il progresse grâce à :

- sa réputation
- ses relations
- son expérience du jeu
- les opportunités disponibles

---

# Conditions de victoire

Il n'existe pas de victoire finale.

Chaque personnage poursuit ses propres objectifs.

La réussite est définie par l'histoire qu'il laisse derrière lui.

---

# Philosophie

Chaque nouvelle mécanique doit répondre à au moins une des questions suivantes :

- Génère-t-elle des interactions entre joueurs ?
- Génère-t-elle des décisions intéressantes ?
- Génère-t-elle des conséquences visibles ?
- Génère-t-elle des histoires que les joueurs auront envie de raconter ?

Si la réponse est "non" aux quatre questions, la mécanique ne doit pas être ajoutée.

---

# Fonctionnalités volontairement exclues

Le jeu n'intègre pas :

- classes de personnages
- niveaux d'expérience
- compétences magiques
- objets légendaires
- quêtes scénarisées obligatoires
- résurrection
- progression verticale infinie

Ces exclusions permettent de préserver l'identité du projet.

---

# Historique des versions

## Version 0.3 (BG-001-P2 complet + TCK3/TCK4/TCK5)
- Complément du Chasseur de primes : 4 actions ajoutées (`investigate_bounty`, `set_trap`, `follow_trail`, `negotiate_surrender`), portant le rôle à 5 actions comme les autres.
- Toutes les actions de tous les rôles sont désormais accessibles en jeu via un menu d'actions filtré par rôle, avec affichage grisé (cooldown/zone) des actions indisponibles (TCK5).
- Deux nouveaux rôles jouables : Adjoint (Deputy) et Habitant (Townfolk), avec leurs 4 actions chacun (TCK4).
- Écarts assumés par rapport à la spec initiale : cooldown global par joueur (pas par action/tours), menu cliquable (pas de raccourcis 1-5). Voir `DECISIONS.md` DEC-011.

## Version 0.2 (BG-001-P2)
- Ajout de 4 nouvelles actions par rôle (Sheriff, Brigand, Merchant, Deputy, Townfolk)
- Intégration des variables globales dans toutes les actions
- Équilibrage des récompenses, risques et cooldowns
- Tests unitaires pour les valeurs extrêmes (0, 50, 100)
- Mise à jour de la documentation

## Version 0.1
- Version initiale du document
- Définition des piliers du gameplay
- Description des rôles de base
