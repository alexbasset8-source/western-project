# BG-001-P3: Système de réputation dynamique

**Priorité**: P0
**Phase**: 3/6 (BG-001)
**Dépendance**: BG-001-P2 validé

### Objectif
Implémenter un système de réputation qui influence les interactions entre rôles et les actions disponibles.

### Critères d'acceptation
- [ ] Chaque rôle a une valeur de réputation par faction (ex: Sheriff a réputation auprès des Townfolks, des Brigands)
- [ ] Les actions modifient la réputation (ex: `attempt_arrest` +10 avec Townfolks, -15 avec Brigands)
- [ ] La réputation affecte :
  - Les récompenses des actions (bonus/malus)
  - Les actions disponibles (ex: `extort_protection_money` impossible si réputation < 30 avec les Marchands)
  - Les interactions entre joueurs (ex: Townfolks fuient si réputation du Sheriff < 20)
- [ ] La réputation se dégrade naturellement sur 24h (décroissance de 1 point/heure)
- [ ] La réputation est sauvegardée et restaurée avec la partie
- [ ] Affichage de la réputation dans l'UI (icône + valeur)

### Implémentation
- Ajouter `reputation` (dictionnaire: `{faction: valeur}`) dans `Player.gd`
- Modifier `TownActions.gd` pour appliquer les bonus/malus de réputation
- Créer `ReputationManager.gd` pour gérer les calculs et la décroissance
- Mettre à jour `UIController.gd` pour afficher la réputation
- Intégrer dans `GameState.gd` pour la sauvegarde