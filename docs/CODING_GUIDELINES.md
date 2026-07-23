# CODING_GUIDELINES.md

# Frontier Town - Coding Guidelines

Version : 1.0

Ce document définit les conventions de développement du projet.

Toute contribution doit respecter ces règles.

---

# Philosophie

Le code doit être :

- lisible
- simple
- prévisible
- testable
- facilement modifiable

La lisibilité est prioritaire sur la performance tant qu'aucun problème de performances n'a été identifié.

---

# Langage

- Godot 4.x
- GDScript 2.0

Utiliser les fonctionnalités modernes de GDScript.

---

# Convention de nommage

## Classes

PascalCase

Exemples :

```
Player
Npc
RoleManager
MissionManager
TownEvent
```

---

## Scènes

PascalCase

```
Player.tscn
SheriffOffice.tscn
FrontierTown.tscn
```

---

## Scripts

Même nom que la scène lorsqu'ils sont liés.

```
Player.gd
Player.tscn
```

---

## Variables

snake_case

```
current_role
player_money
is_dead
wanted_level
```

---

## Constantes

UPPER_SNAKE_CASE

```
MAX_HEALTH
MAX_BOUNTY
DEFAULT_SPEED
```

---

## Fonctions

snake_case

```
take_damage()
join_role_queue()
release_role()
spawn_character()
```

Les noms doivent commencer par un verbe.

---

## Signaux

snake_case

```
player_died
role_changed
money_updated
```

---

# Taille des scripts

Objectif :

- idéal : moins de 300 lignes
- acceptable : moins de 500 lignes

Au-delà :

Réévaluer la responsabilité du script.

---

# Taille des fonctions

Objectif :

20 lignes maximum.

Exception :

Les algorithmes complexes.

---

# Responsabilité unique

Chaque classe possède une seule responsabilité.

Exemple :

```
RoleManager

✓ attribution
✓ succession

✗ interface
✗ sauvegarde
✗ affichage
```

---

# Composition

Préférer :

plusieurs petits composants

plutôt que

une grosse classe.

---

# Héritage

Limiter l'héritage.

Préférer :

Node

CharacterBody2D

Resource

avant de créer des hiérarchies profondes.

---

# Singleton (Autoload)

Réservés aux systèmes globaux.

Exemples :

- SaveManager
- EventManager
- GameState

Ils ne doivent jamais contenir de logique d'interface.

---

# Données

Les données configurables doivent être externalisées.

Exemples :

- JSON
- Resource
- Config

Éviter les constantes codées dans les scripts.

---

# Magic Numbers

Interdits.

Toujours utiliser une constante.

Mauvais :

```
speed = 175
```

Bon :

```
const WALK_SPEED = 175
speed = WALK_SPEED
```

---

# Duplication

Interdite.

Si du code est copié plus d'une fois :

extraire une fonction.

---

# Commentaires

Les commentaires expliquent le "pourquoi".

Jamais le "quoi".

Mauvais :

```
player.position = target
```

```
# Déplace le joueur
```

Bon :

```
# Téléporte le joueur afin d'éviter une collision pendant la promotion de rôle.
```

---

# Logs

Utiliser :

```
print_debug()
push_warning()
push_error()
```

Éviter les print() permanents.

---

# Gestion des erreurs

Toujours vérifier :

- null
- ressources absentes
- données invalides
- fichiers manquants

Le jeu ne doit jamais planter pour une erreur prévisible.

---

# Signaux

Préférer les signaux aux références directes lorsque plusieurs systèmes communiquent.

---

# Interface

La logique métier est interdite dans l'UI.

L'UI :

- affiche
- demande une action

Elle ne décide jamais des règles.

---

# Managers

Les managers orchestrent les systèmes.

Ils ne dessinent rien.

Ils n'accèdent jamais directement aux contrôles de l'interface.

---

# Sauvegarde

Aucun système ne sauvegarde directement.

Le SaveManager centralise les opérations.

---

# Performance

Avant toute optimisation :

1. mesurer
2. identifier le problème
3. optimiser uniquement la partie concernée

---

# Tests manuels

Toute fonctionnalité doit pouvoir être testée indépendamment.

Le développeur doit toujours fournir :

- scénario de test
- résultat attendu
- cas limites

---

# Git

Un commit = une fonctionnalité.

Éviter les commits mélangeant :

- refactoring
- correction
- nouvelle fonctionnalité

---

# Pull Requests

Chaque PR doit contenir :

- objectif
- fichiers modifiés
- impact
- procédure de test
- risques éventuels

---

# Documentation

Toute évolution importante doit mettre à jour :

- GAME_DESIGN_DOCUMENT.md
- TECHNICAL_ARCHITECTURE.md
- DECISIONS.md
- BACKLOG.md

La documentation fait partie du code.

Une fonctionnalité non documentée est considérée comme incomplète.

---

# Définition de terminé (Definition of Done)

Une tâche est terminée lorsque :

- le code compile
- les tests passent
- aucun bug connu n'est introduit
- la documentation est mise à jour
- les logs temporaires sont supprimés
- le code respecte les conventions de ce document
- la fonctionnalité est validée fonctionnellement