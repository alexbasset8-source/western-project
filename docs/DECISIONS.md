# DECISIONS.md

# Frontier Town - Registre des Décisions

> Ce document centralise toutes les décisions importantes du projet.
>
> Aucune décision validée ne doit être supprimée.
> Si une décision évolue, elle est remplacée par une nouvelle entrée qui référence l'ancienne.

---

# Format

## DEC-XXX

**Date :**

**Statut :**
- Proposée
- Validée
- Remplacée
- Abandonnée

**Décision :**

**Contexte :**

**Conséquences :**

**Alternative(s) étudiée(s) :**

---

# Décisions validées

---

## DEC-001

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Le jeu est un MMORPG 2D top-down en pixel art dans un univers western réaliste.

**Contexte :**

Définition de la vision globale.

**Conséquences :**

Toutes les mécaniques doivent respecter cette direction artistique et ludique.

---

## DEC-002

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

La mort des personnages est permanente.

**Contexte :**

La conséquence est le pilier principal du gameplay.

**Conséquences :**

- Aucun système de résurrection.
- Le monde continue sans le personnage.
- Les rôles sont libérés automatiquement.

---

## DEC-003

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Les rôles importants sont limités.

**Contexte :**

Créer de la rareté et des enjeux sociaux.

**Conséquences :**

Les joueurs doivent attendre qu'une place se libère.

---

## DEC-004

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Les rôles sont attribués par file d'attente.

**Contexte :**

Éviter les systèmes arbitraires.

**Conséquences :**

Chaque joueur connaît sa position et peut anticiper une promotion.

---

## DEC-005

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Frontier Town est la ville d'introduction.

**Contexte :**

Permettre aux nouveaux joueurs d'apprendre les mécaniques.

**Conséquences :**

Aucun prérequis de réputation.

---

## DEC-006

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Les villes avancées utilisent la réputation comme condition d'accès aux rôles.

**Contexte :**

Créer une progression horizontale.

**Conséquences :**

La réputation devient un véritable historique du personnage.

---

## DEC-007

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Le prototype est développé en solo avec des joueurs simulés.

**Contexte :**

Valider le gameplay avant le développement réseau.

**Conséquences :**

Le multijoueur est reporté après validation de la boucle de jeu.

---

## DEC-008

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Le serveur sera autoritaire.

**Contexte :**

Préparer le MMO dès la conception.

**Conséquences :**

Le client ne décide jamais d'une action critique.

---

## DEC-009

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Les données de gameplay doivent être séparées du code lorsque cela est pertinent.

**Contexte :**

Faciliter l'équilibrage et la maintenance.

**Conséquences :**

Les rôles, paramètres et équilibrages devront progressivement être externalisés.

---

## DEC-010

**Date :**
2026-07

**Statut :**
Validée

**Décision :**

Chaque nouvelle fonctionnalité doit renforcer au moins un pilier du jeu.

**Contexte :**

Éviter l'ajout de fonctionnalités sans impact sur l'identité du projet.

**Conséquences :**

Toute proposition devra justifier sa contribution au gameplay.

---

## DEC-011

**Date :**
2026-07-31

**Statut :**
Validée

**Décision :**

Les actions de rôle (BG-001-P2) utilisent un cooldown global de 4 secondes réelles par joueur, partagé entre toutes ses actions, et un menu cliquable pour choisir une action — plutôt qu'un cooldown par action/personnage en tours (3-10) et des raccourcis clavier 1-5, comme le prévoyait `BG-001_PHASE2_TICKET.md`.

**Contexte :**

Le système de cooldown par action et par personnage (stocké en tours dans `GameState`) n'a jamais été implémenté, alors que les fonctions d'action elles-mêmes existaient déjà (`TownActions.gd`). Combler cet écart en plus de rendre les actions accessibles (TCK4/TCK5) aurait mélangé deux fonctionnalités dans un même ticket.

**Conséquences :**

- Le cooldown ne varie pas selon la puissance de l'action (contrairement à l'intention initiale de 3-10 tours).
- Un joueur ne peut pas déclencher une action au clavier seul ; il doit ouvrir le menu puis cliquer.
- Documenté comme dette technique dans `BACKLOG.md`, à traiter dans un ticket dédié.

**Alternative(s) étudiée(s) :**

Implémenter immédiatement le système complet `action_cooldowns` par personnage/action décrit dans `BG-001_PHASE2_TICKET.md`. Écartée pour garder chaque ticket focalisé sur une seule fonctionnalité (accessibilité des actions), conformément à `AI_RULES.md`.

---

Aucune.

---

# Décisions abandonnées

Aucune.

---

# Historique

Aucune décision n'a encore été remplacée.