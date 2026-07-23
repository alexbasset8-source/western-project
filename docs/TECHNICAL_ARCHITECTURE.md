# TECHNICAL_ARCHITECTURE.md

# Frontier Town - Architecture Technique

> Ce document décrit l'architecture cible du projet.
>
> Toute IA doit le consulter avant de modifier le code.

---

# Principes

Le projet suit une architecture orientée systèmes.

Chaque système possède une responsabilité unique.

Les systèmes communiquent entre eux mais ne doivent pas être fortement couplés.

Le gameplay doit être indépendant de l'interface.

---

# Organisation du projet

```
res://
│
├── data/
├── docs/
├── outputs/
├── scenes/
├── scripts/
└── work/
```

---

# data/

Contient les données du jeu.

Exemples :

- rôles
- PNJ
- villes
- missions
- réputation
- équilibrage

Les données doivent être modifiables sans changer le code.

---

# docs/

Documentation du projet.

Ne contient jamais de code.

La documentation est considérée comme la source de vérité fonctionnelle.

---

# outputs/

Fichiers générés automatiquement.

Ne doivent pas contenir de logique métier.

---

# scenes/

Contient uniquement les scènes Godot.

Chaque scène représente un objet clairement identifiable.

Exemples :

- Main
- Town
- NPC
- Player
- Building
- UI

Une scène ne doit pas connaître toute l'application.

---

# scripts/

Contient toute la logique.

Les scripts sont organisés par responsabilité.

Exemple :

```
scripts/

managers/
entities/
ui/
simulation/
utils/
```

(Cette organisation pourra évoluer.)

---

# work/

Zone de travail temporaire.

Ne doit jamais contenir de logique définitive.

---

# Architecture générale

Le jeu est découpé en couches.

```
Joueur
        │
        ▼

Interface (UI)

        │
        ▼

Gameplay

        │
        ▼

Managers

        │
        ▼

Données
```

Une couche ne doit jamais contourner une autre.

---

# Managers

Les managers représentent les systèmes globaux.

Ils sont chargés de maintenir l'état du monde.

Ils ne doivent jamais afficher d'interface.

Ils ne doivent jamais contenir de code graphique.

Exemples :

- GameState
- SaveManager
- MissionManager
- ReputationManager
- RoleManager

---

# Gameplay

Le gameplay contient les règles.

Exemples :

- attribution d'un rôle
- arrestation
- succession
- combat
- économie

Le gameplay ne connaît jamais l'interface utilisateur.

---

# Interface

L'interface affiche les informations.

Elle ne décide jamais des règles du jeu.

Elle ne modifie jamais directement les données.

---

# Données

Les données sont séparées du comportement.

Les rôles, villes, missions et paramètres doivent être définis dans des fichiers de données lorsque cela est pertinent.

Objectif :

Pouvoir équilibrer le jeu sans modifier le code.

---

# Événements

Les systèmes doivent communiquer via des événements lorsque cela est possible.

Éviter les dépendances directes.

Exemple :

```
Brigand attaque un convoi

↓

EventManager publie un événement

↓

Journal de ville

↓

Réputation

↓

Prime

↓

Économie
```

Chaque système réagit indépendamment.

---

# Mort

La mort est un événement majeur.

Lorsqu'un personnage meurt :

1. son état devient définitif
2. son rôle est libéré
3. la succession est déclenchée
4. les systèmes concernés sont notifiés

Aucun système ne doit ressusciter un personnage.

---

# Sauvegarde

Le système de sauvegarde est indépendant.

Les managers fournissent leurs données.

Le SaveManager orchestre la sauvegarde.

Les managers ne doivent jamais écrire directement sur le disque.

---

# Réseau (objectif futur)

Le serveur sera autoritaire.

Le client ne prend jamais de décision critique.

Le client :

- affiche
- envoie des intentions

Le serveur :

- valide
- applique
- synchronise

Cette règle doit être respectée dès maintenant afin d'éviter une réécriture lors du passage au multijoueur.

---

# Dépendances

Toujours préférer :

```
A

↓

B

↓

C
```

Plutôt que :

```
A ↔ B ↔ C
```

Les dépendances circulaires sont interdites.

---

# Taille des scripts

Objectif :

- <300 lignes : idéal
- 300–600 : acceptable
- >600 : à découper

---

# Dette technique

Toute dette technique connue doit être documentée dans `BACKLOG.md`.

Aucune IA ne doit masquer une dette technique.

---

# Évolutions

Toute nouvelle fonctionnalité doit répondre aux questions suivantes :

- Quel système est concerné ?
- Quel manager est responsable ?
- Quelles données évoluent ?
- Quels événements sont déclenchés ?
- Quels tests sont nécessaires ?

Si ces réponses ne sont pas claires, la fonctionnalité doit être conçue avant d'être développée.

---

# Objectif de l'architecture

L'objectif n'est pas de créer l'architecture la plus complexe.

L'objectif est de permettre au projet d'évoluer pendant plusieurs années sans nécessiter de réécriture majeure.