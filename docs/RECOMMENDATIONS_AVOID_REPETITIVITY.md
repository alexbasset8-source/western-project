# **RECOMMENDATIONS_POUR_EVITER_LA_REPETITIVITE.md**

# Frontier Town - Recommandations pour éviter la répétitivité et favoriser l'immersion

**Version** : 1.0
**Date** : 26 juillet 2026
**Auteur** : IA (Chef de projet technique)
**Statut** : Validé

---
## **🎯 Objectif de ce document**
Ce document centralise **toutes les recommandations** pour concevoir des mécaniques qui :
1. **Évitent la répétitivité** (le joueur ne s'ennuie pas après 30 minutes).
2. **Favorisent l'immersion** (le joueur oublie qu'il joue à un jeu).
3. **Créent des histoires émergentes** (le joueur raconte ce qui lui est arrivé).
4. **Respectent les 4 piliers** (mort définitive, rôles limités, succession, réputation).

**À utiliser** : Par toute IA ou développeur travaillant sur le projet.

---
## **📌 Principes fondamentaux**

### **1. La Règle des 5C**
Toute mécanique ou système doit renforcer au moins **un des 5C** :
- **Choix** : Le joueur a plusieurs options stratégiques.
- **Conséquences** : Les actions ont un impact durable sur le monde.
- **Conflits** : Les rôles et les joueurs sont en tension.
- **Coopération** : Les joueurs peuvent (ou doivent) collaborer.
- **Complexité** : Les mécaniques ont de la profondeur.

> *Si une mécanique ne renforce aucun des 5C, elle doit être remise en question.*

---
### **2. La Règle des 3V**
Pour éviter la répétitivité, chaque rôle doit offrir :
- **Variété** : Plusieurs actions possibles.
- **Variabilité** : Les résultats des actions ne sont pas prévisibles.
- **Variation** : Le monde change au fil du temps.

---
### **3. La Règle du "Pourquoi"**
Le joueur doit toujours pouvoir répondre à :
- **Pourquoi** est-ce que je fais cette action ? (Objectif clair)
- **Pourquoi** est-ce que cette action est intéressante ? (Récompense ou risque)
- **Pourquoi** est-ce que ça compte ? (Impact sur le monde)

> *Si le joueur ne peut pas répondre à ces questions, la mécanique est mal conçue.*

---
## **🛠️ Recommandations par Système**

---
### **1️⃣ Rôles et Actions**

#### **✅ À faire**
- **5+ actions par rôle** : Chaque rôle doit avoir au moins 5 actions distinctes.
- **Actions avec coûts et bénéfices** : Chaque action doit avoir un coût (temps, argent, risque), un bénéfice (argent, réputation), et un impact (modification du monde).
- **Actions chaînables** : Les actions doivent pouvoir être combinées pour créer des stratégies.
- **Actions contextuelles** : Les actions disponibles dépendent de l'état du monde.

#### **❌ À éviter**
- Actions répétitives (1 seule action par rôle).
- Actions sans coût.
- Actions sans impact.
- Actions aléatoires.

---
### **2️⃣ Événements Dynamiques**

#### **✅ À faire**
- **Événements déclenchés par les joueurs** (80% des événements).
- **Événements avec conséquences durables**.
- **Événements en cascade**.
- **Événements avec choix**.
- **Événements rares mais marquants**.

#### **❌ À éviter**
- Événements purement aléatoires.
- Événements sans conséquence.
- Événements trop fréquents.
- Événements sans choix.

---
### **3️⃣ Variables Globales et État du Monde**

#### **✅ À faire**
- **Variables visibles** (afficher dans le HUD).
- **Variables avec seuils** (déclenchent des événements).
- **Variables interconnectées**.
- **Variables avec inertie**.

#### **❌ À éviter**
- Variables cachées.
- Variables sans impact.
- Variables trop volatiles.

---
### **4️⃣ Réputation et Progression**

#### **✅ À faire**
- **Réputation multidimensionnelle** (Loi, Crime, Commerce, Fiabilité, Combat).
- **Réputation avec conséquences** (déverrouille/bloque des actions).
- **Réputation dynamique**.
- **Réputation visible**.

#### **❌ À éviter**
- Réputation unidimensionnelle.
- Réputation sans conséquence.

---
### **5️⃣ Économie et Gains**

#### **✅ À faire**
- **Économie dynamique**.
- **Gains proportionnels aux risques**.
- **Gains variés**.
- **Gains avec conséquences**.

#### **❌ À éviter**
- Économie statique.
- Gains déséquilibrés.

---
### **6️⃣ Interface et Feedback**

#### **✅ À faire**
- **Feedback immédiat**.
- **Feedback visuel**.
- **Feedback contextuel**.
- **Journal détaillé**.

#### **❌ À éviter**
- Feedback absent.
- Feedback flou.

---
## **📊 Métriques pour Mesurer la Réussite**
   **Métrique** | **Objectif** | **Seuil de succès** |
 |--------------|--------------|---------------------|
 | Temps moyen par session | 2 heures | ≥ 120 min |
 | Nombre d'actions uniques | 5+ par rôle | ≥ 5 |
 | Taux de répétition | Éviter lassitude | ≤ 20% |

---
## **🎯 Checklist pour les Développeurs/IA**

### **Avant d'implémenter**
- [ ] Renforce au moins un des 5C ?
- [ ] Offre de la variété ?
- [ ] A des conséquences durables ?

### **Avant de valider**
- [ ] Testé en session de 2 heures ?
- [ ] Variables globales mises à jour ?

---
## **💡 Conseils Finaux**
1. **Pensez "histoire"**.
2. **Pensez "conséquences"**.
3. **Pensez "choix"**.
4. **Pensez "long terme"**.

---
**"Un bon jeu, c'est un jeu où le joueur oublie qu'il joue."**
