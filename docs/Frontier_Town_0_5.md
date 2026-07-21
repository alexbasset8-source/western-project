# Frontier Town 0.5

## Objectif

Donner des objectifs clairs au joueur et rendre les files d'attente interactives, avec un systeme de soins.

## Files d'attente selectionnables

Panneau en bas a gauche avec une ligne par role :

- Titulaire actuel et contenu de la file
- Position du joueur (#1, #2… ou titulaire)
- Boutons **Rejoindre** / **Quitter**
- Raccourcis clavier 1-4 toujours actifs

## Missions par role

A l'obtention d'un role, une mission est assignee (`MissionManager`).

| Role | Exemples de missions |
|------|---------------------|
| Sheriff | Arreter 2-3 brigands |
| Marchand | Livrer 2-3 convois |
| Chasseur de primes | Encaisser 2-3 primes |
| Brigand | Reussir 2-3 attaques de convoi |

- Progression via les actions **E** habituelles
- Recompense : argent + reputation
- Nouvelle mission automatique a la completion

## Soins

- **H** au **saloon** : -1 blessure pour **$10**
- **H** a la **boutique** : -1 blessure pour **$15**
- Impossible en prison ou sans blessure

## Interface

- Ligne **Mission** dans le HUD
- Hint de soins dynamique selon la zone
- Version **0.5**

## Herite de 0.4

- Blessures, prison, mort, nouveau personnage, sauvegarde locale

## Prochaines etapes (0.6+)

- Pixel art propre pour personnages et batiments
- Missions en chaine / quetes narratives
- Reputation comme prerequis (villes avancees)
- Multijoueur
