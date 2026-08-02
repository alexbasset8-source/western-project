# BG-001-P4: Impact des variables globales sur le gameplay

**Priorité**: P2
**Phase**: 4/6 (BG-001)
**Dépendance**: BG-001-P3 validé

### Objectif
Implémenter les **effets durables** des variables globales (`town_morale`, `crime_level`, `economy_stability`, `goods_price`) sur le gameplay.

### Critères d'acceptation
- [ ] `town_morale` affecte la vitesse de décroissance de la réputation
- [ ] `crime_level` influence la fréquence des événements criminels
- [ ] `economy_stability` modifie les prix et les gains des actions
- [ ] `goods_price` impacte le coût des actions commerciales
- [ ] Tous les effets sont sauvegardés et restaurés avec la partie
- [ ] Tests : vérifier que les modifications des variables globales ont bien l'impact attendu

### Implémentation
- Modifier `ReputationManager.gd` pour intégrer `town_morale`
- Modifier `EventManager.gd` pour utiliser `crime_level`
- Modifier `TownActions.gd` pour appliquer les bonus/malus de `economy_stability` et `goods_price`
- Mettre à jour `GameState.gd` si nécessaire