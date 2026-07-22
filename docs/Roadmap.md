# Roadmap - Frontier Town

## Vision

Créer un MMORPG 2D top-down en pixel art, inspiré par la lisibilité des anciens jeux Pokemon, dans un univers western réaliste et sérieux.

Le jeu repose sur quatre piliers :
- Mort définitive pour tous les personnages.
- Rôles limités dans chaque ville.
- Succession par file d'attente quand un rôle se libère.
- Réputation utilisée progressivement pour accéder aux villes et rôles avancés.

## Phase 0 - Cadrage

Statut : validé.

Décisions prises :
- Univers western réaliste.
- Ton sérieux.
- Mort définitive pour tous.
- Première ville sans prérequis de réputation.
- Rôles de la première ville attribués par ordre d'inscription.
- Prototype initial solo avec joueurs simulés.

Rôles validés pour Frontier Town :
- 1 sheriff.
- 2 marchands.
- 2 chasseurs de primes.
- 5 brigands.

Événements validés :
- Transport de marchandises.
- Attaque de convoi.
- Prime placée.
- Duel.
- Arrestation.
- Mort.
- Promotion.

## Phase 1 - Prototype Frontier Town 0.1

Statut : validé.

Objectif :
Créer une première version jouable qui prouve le coeur du concept : rôles limités, files d'attente, mort définitive et succession.

Déjà fait :
- Projet Godot créé.
- Scène principale créée.
- Carte simple de Frontier Town.
- Joueur contrôlable.
- 10 personnages simulés.
- Rôles et données de personnages en JSON.
- Journal de ville.
- Événements simulés.
- Personnages visibles sur la carte.
- États de personnage : vivant, recherché, prisonnier, mort.
- Mort définitive.
- Libération de rôle après la mort.
- Promotion automatique depuis la file d'attente.

À faire :
- Ajouter une action principale pour le joueur selon son rôle.
- Améliorer l'interface du joueur.
- Afficher argent, rôle, état et prime.
- Rendre les routes plus lisibles sur la carte.
- Ajouter les noms des bâtiments.
- Ajouter une première boucle économique simple.

## Phase 2 - Frontier Town 0.2 : actions de rôle

Statut : validé.

Objectif :
Faire en sorte que le joueur influence directement la simulation.

Actions prévues :
- Sans rôle : consulter les files et demander un rôle.
- Sheriff : tenter d'arrêter un brigand recherché.
- Chasseur de primes : traquer une prime.
- Marchand : lancer un transport de marchandises.
- Brigand : attaquer un convoi.

Résultat attendu :
Le joueur peut agir sur le journal de ville, provoquer des conséquences et participer à l'équilibre local.

## Phase 3 - Frontier Town 0.3 : conséquences et économie

Statut : validé.

Objectif :
Donner plus de poids aux actions.

Fonctionnalités :
- Argent du joueur.
- Gains et pertes selon les événements.
- Prime monétaire sur les criminels.
- Récompense pour arrestation ou neutralisation.
- Pertes pour les marchands attaqués.
- Début de réputation dynamique.

Réputations à suivre :
- Loi.
- Crime.
- Commerce.
- Fiabilité.
- Combat.

Note :
Dans Frontier Town, la réputation ne bloque pas encore les rôles. Elle sert à observer le comportement et préparer les villes avancées.

## Phase 4 - Frontier Town 0.4 : danger, blessure et prison

Statut : validé.

Objectif :
Rendre la mort définitive sérieuse sans être trop arbitraire.

Fonctionnalités :
- Système de blessure.
- Ralentissement ou vulnérabilité quand blessé.
- Prison fonctionnelle.
- Libération après un délai.
- Possibilité de mourir lors d'un duel ou d'une attaque.
- Meilleure distinction entre arrestation, capture et mort.

## Phase 5 - Frontier Town 0.5 : boucle jouable complète

Statut : validé.

Objectif :
Obtenir une mini-démo solo cohérente.

Critères de réussite :
- Le joueur comprend les rôles en moins de 5 minutes.
- Le joueur peut obtenir un rôle via une file d'attente.
- Une mort définitive peut changer l'équilibre de la ville.
- Une succession de rôle est visible.
- Les marchands, brigands, sheriffs et chasseurs de primes ont tous une utilité.
- Le journal raconte une histoire compréhensible.

## Phase 6 - Vertical Slice

Objectif :
Créer une version présentable du jeu final, toujours limitée à Frontier Town.

Chantiers :
- Carte plus propre.
- Pixel art temporaire cohérent.
- Interface plus lisible.
- Bâtiments interactifs.
- Routes et zones de danger claires.
- Événements mieux équilibrés.
- Historique des morts.
- Création d'un nouveau personnage après mort.
- Sauvegarde locale.

## Phase 7 - Multijoueur local

Objectif :
Remplacer progressivement les joueurs simulés par de vrais joueurs.

Fonctionnalités :
- Connexion de plusieurs clients.
- Synchronisation des déplacements.
- Rôles gérés côté serveur.
- Files d'attente gérées côté serveur.
- Mort et succession synchronisées.
- Chat local basique.

## Phase 8 - Base MMO

Objectif :
Construire une architecture durable pour un monde persistant.

Chantiers techniques :
- Serveur autoritaire.
- Comptes joueurs.
- Personnages persistants.
- Base de données.
- Gestion des déconnexions.
- Logs d'actions.
- Protection anti-triche.
- Outils de modération.

## Phase 9 - Villes avancées

Objectif :
Introduire des villes où la réputation devient nécessaire pour accéder aux rôles.

Exemples :
- Ville de loi : réputation Loi requise pour devenir sheriff ou adjoint.
- Ville commerciale : réputation Commerce requise pour obtenir une boutique.
- Ville dangereuse : réputation Crime utile pour rejoindre certains réseaux hors-la-loi.

Différence avec Frontier Town :
- Frontier Town reste la ville d'entrée simple.
- Les villes avancées filtrent les rôles par réputation.

## Phase 10 - Alpha fermée

Objectif :
Tester le jeu avec une petite communauté.

À tester :
- Frustration liée à la mort définitive.
- Abus possibles des rôles d'autorité.
- Équilibrage entre loi, commerce et criminalité.
- Fluidité des files d'attente.
- Intérêt des joueurs pour les rôles non-combat.
- Besoin réel de modération.

## Priorité immédiate

La prochaine étape recommandée est :

Phase 6



