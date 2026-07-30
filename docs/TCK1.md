# BG-002: Menu de sélection de sauvegarde au lancement

**Priorité**: P1
**Type**: Feature

### Objectif
Ajouter un écran au lancement du jeu permettant de :
- Continuer la partie existante
- Écraser la sauvegarde et démarrer une nouvelle partie

### Critères d'acceptation
- [ ] Écran modal affiché au démarrage avec 2 options : "Continuer" et "Nouvelle Partie"
- [ ] Option "Continuer" charge la dernière sauvegarde
- [ ] Option "Nouvelle Partie" affiche une confirmation : "Cela écrasera votre sauvegarde actuelle. Êtes-vous sûr ?"
- [ ] Bouton "Annuler" retourne au menu principal sans action
- [ ] Bouton "Confirmer" supprime l'ancienne sauvegarde et lance une nouvelle partie
- [ ] Si aucune sauvegarde n'existe, seul le bouton "Nouvelle Partie" est visible

### Implémentation
- Modifier `Main.gd` ou `GameManager.gd` pour détecter l'existence de sauvegardes
- Créer une scène `SaveSelectionMenu.tscn`
- Intégrer la logique de chargement/suppression de sauvegardes
