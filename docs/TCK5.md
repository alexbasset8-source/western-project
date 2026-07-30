# TCK5: Corrections - Actions non accessibles en jeu

**Priorité**: P0
**Type**: Bug
**Dépendance**: BG-001-P2, BG-005

### Problème
Les actions des rôles (Citoyen, Adjoint, Sheriff, etc.) sont implémentées dans `TownActions.gd` mais **n'apparaissent pas dans l'UI** et ne sont pas accessibles en jeu.

### Objectif
Rendre toutes les actions des rôles accessibles via l'interface utilisateur.

### Critères d'acceptation
- [ ] Les actions du rôle actuel s'affichent dans le menu d'actions
- [ ] Chaque bouton d'action déclenche la bonne fonction dans `TownActions.gd`
- [ ] Les actions indisponibles (cooldown, prérequis non remplis) sont grisées
- [ ] Les actions sont filtrées par rôle : un Sheriff ne voit pas les actions de Brigand

### Causes probables à vérifier
1. **`PlayerActionManager.gd`** :
   - Vérifier que `get_available_actions()` retourne bien les actions du rôle actuel
   - Vérifier que le rôle est correctement passé à `TownActions.gd`

2. **`UIController.gd`** :
   - Vérifier que `update_action_buttons()` est appelé après le chargement du joueur
   - Vérifier que les boutons sont créés dynamiquement à partir de `get_available_actions()`

3. **`RoleManager.gd`** :
   - Vérifier que `current_role` est bien défini pour le joueur
   - Vérifier que les permissions des actions sont correctement configurées

### Implémentation
- Corriger le lien entre `RoleManager.gd` et `PlayerActionManager.gd`
- Mettre à jour `UIController.gd` pour afficher uniquement les actions du rôle actuel
- Ajouter des logs de debug pour tracer le chargement des actions
