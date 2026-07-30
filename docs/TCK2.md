# BG-003: Suppression des cadavres après 2 jours

**Priorité**: P1
**Type**: Feature

### Objectif
Les entités mortes (joueurs et PNJ) doivent disparaître de la carte après 2 jours de jeu.

### Critères d'acceptation
- [ ] Chaque entité morte a un timer de 48 heures (2 jours)
- [ ] Le timer commence dès la mort de l'entité
- [ ] Après expiration, l'entité est supprimée de la carte et de la mémoire
- [ ] Le timer est sauvegardé et restauré avec la partie
- [ ] Aucun impact sur les entités vivantes

### Implémentation
- Ajouter une propriété `time_of_death` dans `Entity.gd` ou classe parente
- Créer un système de nettoyage dans `GameState.gd` qui vérifie les entités mortes
- Supprimer les entités dont `current_time - time_of_death > 48h`
- Mettre à jour la logique de sauvegarde/chargement
