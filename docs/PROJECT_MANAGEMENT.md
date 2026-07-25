# PROJECT_MANAGEMENT.md

# Frontier Town - Project Management

Version : 1.0

Ce document définit les responsabilités du chef de projet technique et la manière dont les évolutions sont pilotées.

---

# Objectif

Garantir que Frontier Town reste :

- cohérent
- maintenable
- testable
- publiable

Le développement doit toujours être guidé par la qualité du produit et non par la quantité de fonctionnalités.

---

# Responsabilités

## Architecture

- Vérifier que toute évolution respecte l'architecture.
- Refuser les modifications qui augmentent inutilement le couplage.
- Identifier les dettes techniques.
- Proposer des améliorations d'architecture.

---

## Game Design

- Vérifier que chaque fonctionnalité renforce les piliers du jeu.
- Refuser les fonctionnalités qui diluent l'identité du projet.
- Maintenir le GAME_DESIGN_DOCUMENT.md.

---

## Backlog

Maintenir le BACKLOG.md.

Pour chaque demande :

- définir la priorité
- estimer la complexité
- identifier les dépendances
- proposer un ordre de réalisation

---

## Roadmap

Maintenir la ROADMAP.md.

S'assurer que :

- les phases restent cohérentes
- les objectifs sont réalistes
- aucune fonctionnalité n'est développée prématurément

---

## Documentation

Toute évolution importante doit mettre à jour :

- GAME_DESIGN_DOCUMENT.md
- TECHNICAL_ARCHITECTURE.md
- DECISIONS.md
- BACKLOG.md
- CHANGELOG.md

Aucune fonctionnalité n'est considérée comme terminée sans documentation.

---

## Audit

Réaliser régulièrement un audit du projet.

Points vérifiés :

- architecture
- dette technique
- duplication
- qualité du code
- lisibilité
- documentation
- cohérence du gameplay

---

## Revues de code

Chaque livraison est contrôlée.

Vérifications :

- respect des conventions
- complexité
- duplication
- impacts
- risques
- documentation
- tests

---

## Tickets

Avant toute implémentation :

Créer un ticket contenant :

- objectif
- contexte
- description
- fichiers concernés
- contraintes
- critères d'acceptation
- procédure de test

Une IA ne reçoit jamais une demande vague.

---

## Priorisation

Ordre de priorité :

1. Correction de bug critique
2. Régression
3. Dette technique bloquante
4. Gameplay
5. Architecture
6. Interface
7. Contenu
8. Optimisation

---

## Dette technique

Toute dette technique doit être :

- documentée
- priorisée
- suivie

Aucune dette technique connue ne doit être ignorée.

---

## Gestion des risques

Maintenir une liste des risques du projet.

Exemples :

- architecture fragile
- système trop complexe
- dépendance forte entre managers
- gameplay non validé
- performances
- manque de tests

---

## Fin de tâche

Avant de clôturer une tâche :

- vérifier le fonctionnement
- mettre à jour la documentation
- supprimer le code mort
- supprimer les logs temporaires
- vérifier l'absence de régression

---

# Workflow

Nouvelle idée

↓

Analyse

↓

Ajout au BACKLOG

↓

Priorisation

↓

Création d'un ticket

↓

Développement

↓

Revue de code

↓

Tests

↓

Validation

↓

Documentation

↓

CHANGELOG

---

# Livrables attendus pour chaque fonctionnalité

- Ticket
- Code
- Tests
- Documentation
- Validation

---

# Objectif final

Construire un projet qui puisse être repris à tout moment par un autre développeur ou une autre IA sans perte de compréhension ni de qualité.