# Frontier Town 0.4

## Objectif

Donner du poids aux consequences : blessures avant la mort, prison jouable, nouvelle vie apres la mort, et persistance locale.

## Blessures

- Chaque personnage a **0 a 3 blessures** (`InjuryManager`)
- Les evenements dangereux infligent des blessures avant la mort
- A **3 blessures** : mort definitive
- Effets :
  - Journal detaille (legere / grave / critique)
  - Ralentissement du joueur (-15 % par blessure)
  - Affichage sur les PNJ simules

## Prison

- Arrestation = **4 tours** de peine par defaut
- Le joueur est teleporte en cellule et ne peut plus se deplacer
- **E** : attendre un tour (reduit la peine)
- **R** : tenter une evasion (35 % de reussite, sinon blessure + peine allongee)
- Chaque evenement simule reduit aussi la peine de tous les prisonniers
- Liberation automatique a 0 tour

## Mort et nouveau personnage

- Mort definitive enregistree dans **l'historique** (nom, role, cause, jour, argent)
- Ecran de mort avec resume et historique complet
- Saisie du nom du nouveau personnage (defaut : Voyageur 2, 3…)
- Le nouveau personnage repart de la place centrale, sans role, $25

## Sauvegarde locale

Fichier `user://frontier_town_save.json` :

- Personnages, files d'attente, journal, historique des morts
- Sauvegarde automatique : mort, prison, evenements, respawn

## Touches

- **E** : action de role / attendre en prison
- **R** : evasion (en prison)
- **1-4** : rejoindre une file
- **K** : blesser/mort debug sur le sheriff
- **L** : evenement simule

## Herite de 0.3

- Carte avec zones, collisions, actions liees au lieu
- Argent, reputation, journal partages avec la simulation

## Prochaines etapes (0.5+)

- Files d'attente visuelles et selectionnables
- Missions simples par role
- Pixel art propre
- Systeme de soin (medecin, repos au saloon)
