# TCK4: Implémentation des rôles Citoyen et Adjoint

**Priorité**: P1
**Type**: Feature
**Dépendance**: BG-001-P2 (actions par rôle)

### Problème
Les rôles **Citoyen** (Townfolk) et **Adjoint** (Deputy) sont définis dans le design mais n'ont pas de fichiers d'implémentation dédiés.

### Objectif
Créer et intégrer les fichiers nécessaires pour ces deux rôles.

### Critères d'acceptation
- [ ] Fichier `Citoyen.gd` créé dans `/scripts/roles/`
- [ ] Fichier `Adjoint.gd` créé dans `/scripts/roles/`
- [ ] Chaque rôle a :
  - Ses 4 actions spécifiques implémentées
  - Ses propriétés uniques (ex: `reputation` pour Adjoint)
  - Son intégration dans `RoleManager.gd`
- [ ] Les rôles sont sélectionnables dans l'UI de création de personnage
- [ ] Les actions apparaissent dans le menu d'actions du joueur
- [ ] Tests : chaque action fonctionne sans erreur

### Actions à implémenter
**Citoyen** :
- `report_crime`
- `gossip`
- `form_militia`
- `protest`

**Adjoint** :
- `assist_arrest`
- `scout_perimeter`
- `deliver_warrant`
- `guard_prisoner`
