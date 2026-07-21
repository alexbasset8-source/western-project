# Frontier Town 0.3

## Objectif

Ancrer le joueur dans un monde lisible : carte avec routes et batiments nommes, collisions, interactions de zone, et interface clarifiee.

## Carte

- Generation procedurale depuis `data/locations.json`
- Batiments nommes (sheriff, banque, saloon, boutique, ecurie, entrepot)
- Routes visibles : route sud, route commerciale Est, connecteurs
- Zones exterieures : place centrale, ranch, mine, canyon, camp brigand

## Collisions

- Murs aux limites de la carte (1800x1200)
- Parois du canyon (passage central libre)
- Joueur avec `CollisionShape2D` et camera limitee a la carte

## Interactions de zone

Chaque lieu possede une `Area2D` (`LocationZone.gd`). A l'entree :

- Message dans le journal de ville
- Mise a jour du HUD (zone actuelle)
- Les actions de role (E) exigent d'etre dans une zone compatible

| Role | Zones valides |
|------|---------------|
| Sheriff | law, town |
| Marchand | commerce, road |
| Chasseur de primes | road, danger |
| Brigand | danger, road |
| Sans role | town |

## Interface

HUD structure en labels separes :

- Role, etat (couleur), argent, prime, zone actuelle
- Hint d'action dynamique (inclut rappel de zone si necessaire)
- Panneau roles/files + journal de ville

## Architecture

- `ZoneManager.gd` : suivi des zones actives, priorite en cas de chevauchement
- `LocationZone.gd` : detection entree/sortie joueur
- `World.gd` : construction carte, visuels, zones, collisions

## Herite de 0.2

- Touche E : actions de role
- Argent, reputation, journal partages avec la simulation NPC

## Prochaines etapes (0.4+)

- Systeme de blessure avant mort
- Prison fonctionnelle pour le joueur
- Creation d'un nouveau personnage apres mort
- Files d'attente visuelles et selectionnables
- Missions simples par role
- Pixel art propre
- Sauvegarde locale
