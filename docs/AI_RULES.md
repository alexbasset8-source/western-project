# AI_RULES.md

# Frontier Town - AI Development Rules

Ce document définit les règles que toute IA (Claude, ChatGPT, Gemini, Codex, Cursor...) doit respecter lorsqu'elle contribue au projet.

Le non-respect de ces règles est considéré comme une régression du projet.

---

# 1. Objectif

L'objectif n'est pas de produire le plus de code possible.

L'objectif est de construire un MMORPG maintenable, cohérent et publiable.

Chaque modification doit renforcer la vision du jeu.

---

# 2. Les 4 piliers du jeu

Aucune fonctionnalité ne doit affaiblir ces piliers.

## Mort définitive

La mort est irréversible.

Aucune mécanique ne doit permettre de restaurer un personnage décédé.

---

## Rôles limités

Les rôles sont rares.

Ils doivent rester désirables.

Ils ne doivent jamais devenir accessibles à tout le monde.

---

## Succession

La succession automatique est un mécanisme central.

Elle ne doit jamais être contournée.

---

## Réputation

La réputation représente l'histoire du personnage.

Elle ne doit jamais devenir un simple système de niveau.

---

# 3. Avant toute modification

Avant d'écrire du code, l'IA doit toujours :

- comprendre la fonctionnalité demandée ;
- identifier les systèmes concernés ;
- limiter les impacts ;
- éviter toute régression.

---

# 4. Ce qu'une IA NE DOIT PAS faire

Interdictions absolues :

- modifier l'architecture globale sans demande explicite ;
- déplacer des fichiers sans justification ;
- renommer des classes publiques sans nécessité ;
- supprimer un système existant ;
- modifier plusieurs systèmes lorsqu'un seul est concerné ;
- réécrire entièrement un script pour une petite évolution ;
- introduire une nouvelle dépendance externe sans validation.

---

# 5. Principe de modification minimale

Toute évolution doit modifier le moins de fichiers possible.

Après avoir traité un ticket (implémentation, correction, refactorisation), **l'IA doit mettre à jour le fichier CHANGELOG.md** avant de considérer le ticket comme terminé.
- Format obligatoire :
  ```markdown
  ## [X.X.X] - AAAA-MM-JJ
  ### Ajouté/Modifié/Corrigé
  - [ID_TICKET] : Description concise des changements

Toujours privilégier :

une petite modification propre

plutôt que

une grosse refonte.

---

# 6. Refactoring

Le refactoring est interdit sauf si :

- il est explicitement demandé ;
- il corrige une dette technique identifiée ;
- il réduit réellement la complexité.

Le refactoring ne doit jamais modifier le comportement du jeu.

---

# 7. Taille des tâches

Une IA ne travaille que sur UNE fonctionnalité à la fois.

Une tâche doit être :

- autonome ;
- testable ;
- terminable en quelques heures.

---

# 8. Architecture

Toujours respecter les responsabilités.

Un manager ne doit pas contenir de logique d'interface.

Une interface ne doit pas contenir de logique métier.

Les données doivent rester séparées des comportements.

---

# 9. Scripts

Préférer plusieurs petits scripts.

Éviter les scripts géants.

Objectif indicatif :

- moins de 300 lignes : idéal
- 300 à 600 lignes : acceptable
- plus de 600 lignes : à analyser

---

# 10. Duplication

Ne jamais copier du code.

Si une logique est utilisée plusieurs fois :

extraire une fonction.

---

# 11. Variables

Utiliser des noms explicites.

Interdit :

tmp

var1

test

ok

Préférer :

current_role

bounty_amount

is_prisoner

next_role_holder

---

# 12. Fonctions

Une fonction doit faire une seule chose.

Elle doit être courte.

Elle doit être lisible.

---

# 13. Commentaires

Ne jamais commenter une évidence.

Mauvais :

player.move()

// Déplace le joueur

Bon :

// Le joueur ne peut plus se déplacer lorsqu'il est emprisonné.

---

# 14. Gameplay

Avant d'ajouter une fonctionnalité, l'IA doit se demander :

Cette fonctionnalité renforce-t-elle au moins un de ces éléments ?

- tension
- conséquences
- interactions sociales
- conflits
- coopération

Si la réponse est non :

la fonctionnalité doit être remise en question.

---

# 15. Interface

L'interface doit informer.

Elle ne doit jamais masquer les conséquences.

Le joueur doit toujours comprendre :

- son rôle
- son état
- sa réputation
- son argent
- son statut juridique
- sa prime éventuelle

---

# 16. Sauvegarde

Toute donnée importante doit pouvoir être sauvegardée.

Éviter les données cachées uniquement en mémoire.

---

# 17. Performances

Ne jamais optimiser prématurément.

Privilégier :

lisibilité

maintenabilité

simplicité

avant la micro-optimisation.

---

# 18. Tests

Chaque nouvelle fonctionnalité doit être testable indépendamment.

Une IA doit toujours expliquer :

- comment tester ;
- quel résultat est attendu ;
- quels cas limites vérifier.

---

# 19. Livraison

Chaque livraison doit comprendre :

- objectif ;
- fichiers modifiés ;
- impact ;
- procédure de test ;
- risques éventuels.

---

# 20. Si un doute existe

L'IA ne doit jamais inventer.

Elle doit :

- poser une question ;
ou
- proposer plusieurs solutions avec leurs avantages et inconvénients.

---

# 21. Priorité absolue

Toujours privilégier :

1. la cohérence du gameplay
2. la stabilité de l'architecture
3. la lisibilité du code
4. les performances
5. les nouvelles fonctionnalités

Dans cet ordre.
