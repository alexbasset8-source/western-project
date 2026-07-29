# BACKLOG.md

# Frontier Town - Product Backlog

> Ce document contient toutes les évolutions envisagées pour le projet.
>
> Une idée n'est jamais supprimée.
> Lorsqu'elle est réalisée, elle est déplacée dans le CHANGELOG.
>
> Priorité :
>
> - P0 : Bloquant
> - P1 : Important
> - P2 : Amélioration
> - P3 : Idée

---

# P0 - Gameplay critique

## BG-001

**Titre**

Équilibrer les rôles de Frontier Town pour une expérience immersive et durable.

**Description**

Chaque rôle doit offrir une expérience de jeu suffisamment riche, variée et stratégique pour maintenir l'engagement du joueur sur des **sessions de plusieurs heures** (objectif révisé : 2 heures minimum par rôle).

**Statut**

En cours (Phase 1/6)

**Sous-tâches** :
- [ ] **BG-001-P1** : Fondations (variables globales + intégration basique) [P0] - Ticket créé dans `BG-001_PHASE1_TICKET.md`
- [ ] BG-001-P2 : Ajout d'actions variées par rôle (5+ actions par rôle) [P1]
- [ ] BG-001-P3 : Événements dynamiques (10+ nouveaux événements réactifs) [P1]
- [ ] BG-001-P4 : Impact des variables globales sur le gameplay (effets durables) [P2]
- [ ] BG-001-P5 : Tests et ajustements finaux [P2]
- [ ] BG-001-P6 : Validation utilisateur (sessions de 2 heures) [P2]

**Voir** : `BG-001_PHASE1_TICKET.md` pour le détail de la Phase 1.

---

## BG-002

**Titre**

Revoir la boucle de progression.

**Description**

Valider que la succession, la réputation et la mort créent une boucle motivante **sur le long terme** (plusieurs sessions de jeu).

**Statut**

À faire

**Dépendances** : BG-001 (nécessite un équilibrage de base des rôles).

---

## BG-003

**Titre**

Équilibrer les gains économiques.

**Description**

Aucun rôle ne doit devenir systématiquement le plus rentable. Les gains doivent être **proportionnels aux risques et à la complexité** de chaque rôle.

**Statut**

À faire

**Dépendances** : BG-001 (intégration des variables globales).

---

## BG-004

**Titre**

Créer des événements dynamiques.

**Description**

Introduire davantage de situations imprévues afin d'éviter une simulation répétitive. Les événements doivent être **déclenchés par les actions des joueurs** et avoir des **conséquences durables**.

**Statut**

À faire

**Dépendances** : BG-001-P3 (cadre pour les événements dynamiques).

**Lien** : Fait partie de BG-001-P3.

---

# P1 - Gameplay

## BG-005

Améliorer le système de prison (ajouter des choix stratégiques : évasion, corruption, réhabilitation).

---

## BG-006

Créer plusieurs types de convois (rapides/lents, protégés/non protégés).

---

## BG-007

Ajouter différentes primes (petites/grandes, temporaires/permanentes).

---

## BG-008

Créer des niveaux de recherche (facile/difficile, local/régional).

---

## BG-009

Ajouter différents types de marchandises (légales/illégales, périssables/durables).

---

## BG-010

Permettre plusieurs méthodes d'arrestation (négociation, piège, poursuite).

---

## BG-011

Créer plusieurs causes de décès (maladie, accident, duel, exécution).

---

## BG-012

Ajouter des événements météo ayant un impact sur les déplacements (pluie, brouillard, tempête).

---

## BG-013

Créer un système de rumeurs (informations partielles, désinformation).

---

## BG-014

Créer un historique des anciens shérifs (statistiques, durée de mandat).

---

## BG-015

Créer un historique des personnages morts (cause, date, impact).

---

## BG-016

Ajouter des statistiques globales de la ville (population, richesse, criminalité).

---

# P1 - Interface

## BG-017

Refonte complète de l'interface (affichage des variables globales, réputation, argent).

---

## BG-018

Journal filtrable (par type, date, rôle).

---

## BG-019

Carte plus lisible (zones, routes, bâtiments nommés).

---

## BG-020

Indicateurs visuels des rôles (couleurs, icônes, états).

---

## BG-021

Amélioration des notifications (priorisation, durée, clarté).

---
# P1 - Technique

## BG-022

Mettre en place un système de sauvegarde robuste (inclure les variables globales).

---

## BG-023

Préparer les managers au futur serveur autoritaire.

---

## BG-024

Externaliser progressivement les paramètres d'équilibrage (dans `data/`).

---

## BG-025

Créer des tests automatisés pour les systèmes critiques.

**Lien** : Voir `BG-001_PHASE1_TICKET.md` pour les tests de la Phase 1.

---

## BG-026

Documenter l'ensemble des managers.

---

# P2 - Contenu

## BG-027

Ajouter de nouveaux bâtiments (hôpital, école, saloon amélioré).

---

## BG-028

Ajouter une deuxième ville (avec prérequis de réputation).

**Dépendances** : BG-006 (réputation comme condition d'accès).

---
## BG-029

Créer des commerces spécialisés (armurerie, pharmacie, stable).

---
## BG-030

Ajouter plusieurs types de prisons (locale, régionale, haute sécurité).

---
## BG-031

Créer différents modèles de diligences (rapides, blindées, discrètes).

---
## BG-032

Ajouter des animaux (chevaux, chiens, loups).

---
## BG-033

Créer plusieurs régions (plaine, montagne, désert).

---
## BG-034

Créer plusieurs biomes (forêt, prairie, canyon).

---
# P2 - MMO

## BG-035

Prototype de synchronisation réseau.

---
## BG-036

Serveur autoritaire.

---
## BG-037

Gestion des comptes.

---
## BG-038

Persistance des personnages.

---
## BG-039

Chat local.

---
## BG-040

Journal mondial.

---
## BG-041

Outils de modération.

---
# P3 - Idées

## BG-042

Élections du sheriff (campagne, votes, mandats limités).

---
## BG-043

Journal imprimé de la ville (actualités, avis de recherche).

---
## BG-044

Avis de recherche affichés dans les bâtiments (bureau du sheriff, saloon).

---
## BG-045

Banque (prêts, dépôts, intérêts).

---
## BG-046

Compagnies commerciales (monopoles, concurrence).

---
## BG-047

Système de propriétés (achat/vente de bâtiments, terres).

---
## BG-048

Mariage (alliances, héritage).

---
## BG-049

Héritage (transmission de biens à la mort).

---
## BG-050

Cimetière consultable (histoire des morts, épitaphes).

---
## BG-051

Statues des anciens héros locaux (commémoration).

---
## BG-052

Musée de la ville retraçant son histoire (objets, événements).

---
# Dette technique

Aucune dette technique documentée.

---
# Bugs connus

Aucun bug documenté.

---
# Notes

Une tâche ne peut entrer dans un sprint que si :

- son objectif est clairement défini ;
- ses critères d'acceptation sont connus ;
- son impact est identifié ;
- elle est réalisable indépendamment.

---
## **📌 Historique des modifications**

- **26/07/2026** : Révision de BG-001 pour aligner sur une vision long terme (2 heures par rôle au lieu de 30 minutes). Ajout des sous-tâches BG-001-P1 à BG-001-P6. Mise à jour de BG-004 pour clarifier son lien avec BG-001-P3.
