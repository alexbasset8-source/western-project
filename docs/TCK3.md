# TCK3: Refactorisation de l'UI - Gestion des fenêtres

**Priorité**: P0
**Type**: Bug/UX

### Problème
Les fenêtres se chevauchent, deviennent illisibles et la fenêtre du journal est tronquée.

### Objectif
Implémenter un système de gestion des fenêtres qui :
- Empêche le chevauchement
- Rend toutes les fenêtres entièrement visibles
- Permet de redimensionner/minimiser/fermer/réouvrir les fenêtres

### Critères d'acceptation
- [ ] Aucune fenêtre ne chevauche une autre
- [ ] La fenêtre du journal est entièrement visible et lisible
- [ ] Chaque fenêtre a :
  - Un bouton de fermeture (X)
  - Un bouton de minimisation (_)
  - Une barre de titre pour déplacer la fenêtre
  - Un redimensionnement possible (drag des bords)
- [ ] **Touche `TAB`** : Cycle entre les fenêtres ouvertes
- [ ] **Touche `CTRL+TAB`** : Affiche un menu des fenêtres fermées pour réouverture
- [ ] **Bouton "Fenêtres"** dans l'UI principale : Liste toutes les fenêtres (ouvertes/fermées) avec option de réouverture
- [ ] Les fenêtres restent dans les limites de l'écran
- [ ] Position par défaut sauvegardée entre les sessions

### Implémentation
- Créer un nœud parent `WindowManager` dans `UIController.gd`
- Ajouter un système de "docking" ou de tuilage automatique
- Implémenter la logique de drag-and-drop pour les fenêtres
- Ajouter des boutons de contrôle (fermer, minimiser) sur chaque fenêtre
- Limiter la taille minimale des fenêtres pour garantir la lisibilité
- Stocker l'état (ouvert/fermé) et la position de chaque fenêtre
- Implémenter la touche `TAB` pour le cycle
- Implémenter `CTRL+TAB` pour le menu de réouverture
