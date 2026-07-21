# Frontier Town 0.2

## Objectif

Le joueur ne se contente plus d'observer la simulation. Il peut agir selon son role et influencer le journal de ville.

## Action principale

Touche **E** : action de role.

| Role | Action |
|------|--------|
| Sheriff | Tenter une arrestation de brigand recherche |
| Chasseur de primes | Traquer une prime active |
| Marchand | Lancer un transport de marchandises |
| Brigand | Attaquer un convoi |
| Sans role | Consulter les files (1-4 pour rejoindre) |

## Consequences

- **Argent** : gains ou pertes selon le resultat des actions.
- **Reputation** : evolue via `ReputationManager` (law, crime, commerce, reliability, combat).
- **Journal** : chaque action du joueur apparait dans le journal de ville.

## Architecture

- `TownActions.gd` : logique partagee entre joueur et simulation NPC.
- `PlayerActionManager.gd` : dispatch de l'action E selon le role du joueur.
- `EventManager.gd` : evenements automatiques utilisent les memes actions.

## Touches

- Fleches : deplacement
- E : action de role
- 1-4 : rejoindre une file (Sheriff, Marchand, Chasseur, Brigand)
- K : tuer le sheriff actuel (debug)
- L : declencher un evenement simule (debug)

## Herite de 0.1

- Mort definitive pour tous.
- Roles limites avec files d'attente FIFO.
- Premiere ville sans prerequis de reputation.
- 10 personnages simules + joueur sur la carte.

## Prochaines etapes (0.3+)

- Interface plus claire (argent, prime, etat, role)
- Carte avec routes visibles et collisions
- Bâtiments avec noms et interactions de zone
- Systeme de blessure avant mort
- Prison fonctionnelle pour le joueur
- Creation d'un nouveau personnage apres mort
