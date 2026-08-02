# BG-001-P3: Système de réputation dynamique

**Priorité**: P0
**Phase**: 3/6 (BG-001)
**Dépendance**: BG-001-P2 validé
**Statut**: ✅ Terminé

### Objectif
Implémenter un système de réputation qui influence les interactions entre rôles et les actions disponibles.

### Critères d'acceptation
- [x] Chaque rôle a une valeur de réputation par faction (ex: Sheriff a réputation auprès des Townfolks, des Brigands)
- [x] Les actions modifient la réputation (ex: `attempt_arrest` +5 law, -10 crime)
- [x] La réputation affecte :
  - Les récompenses des actions (bonus/malus)
  - Les actions disponibles (ex: `extort_protection_money` impossible si réputation crime < 30)
  - Les interactions entre joueurs (via les variables globales)
- [x] La réputation se dégrade naturellement sur 24h (décroissance de 1 point/heure)
- [x] La réputation est sauvegardée et restaurée avec la partie
- [x] Affichage de la réputation dans l'UI (icône + valeur)

### Implémentation
- Ajouter `reputation` (dictionnaire: `{faction: valeur}`) dans `Player.gd`
- Modifier `TownActions.gd` pour appliquer les bonus/malus de réputation
- Créer `ReputationManager.gd` pour gérer les calculs et la décroissance
- Mettre à jour `UIController.gd` pour afficher la réputation
- Intégrer dans `GameState.gd` pour la sauvegarde