# GAME_DESIGN_DOCUMENT.md

# Frontier Town - Game Design Document

Version : 0.1

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

Objectif :

Limiter la criminalité.

---

## Marchand

Mission :

Faire circuler les marchandises.

Responsabilités :

- organiser des convois
- vendre des ressources
- générer de l'activité économique

Objectif :

S'enrichir.

---

## Chasseur de primes

Mission :

Capturer ou éliminer des criminels recherchés.

Responsabilités :

- suivre les avis de recherche
- retrouver les fugitifs

Objectif :

Gagner de l'argent.

---

## Brigand

Mission :

Profiter des faiblesses du système.

Responsabilités :

- attaquer les convois
- voler
- échapper aux autorités

Objectif :

Faire fortune malgré les risques.

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