# BG-001-P2: Ajouter 4 actions par rôle

**Priorité**: P0
**Phase**: 2/6 (BG-001)
**Dépendance**: BG-001-P1 validé

## Objectif
Ajouter **4 nouvelles actions par rôle** (Sheriff, Brigand, Merchant, Deputy, Townfolk) pour atteindre 5+ actions variées, équilibrées et engageantes pour des sessions de 2h+.

## Actions à implémenter
- **Sheriff**: `patrol_town`, `interrogate_witness`, `organize_posse`, `enforce_curfew`
- **Brigand**: `ambush_merchants`, `sabotage_town_infrastructure`, `extort_protection_money`, `hide_loot`
- **Merchant**: `negotiate_prices`, `bribe_officials`, `smuggle_contraband`, `setup_trade_stand`
- **Deputy**: `assist_arrest`, `scout_perimeter`, `deliver_warrant`, `guard_prisoner`
- **Townfolk**: `report_crime`, `gossip`, `form_militia`, `protest`

## Critères d'acceptation
- [ ] 4 actions implémentées par rôle dans `TownActions.gd`
- [ ] Chaque action intègre au moins 1 variable globale (`town_morale`, `crime_level`, `economy_stability`, `goods_price`)
- [ ] Équilibrage validé : récompenses/risques/cooldowns cohérents
- [ ] Tests passés avec variables globales aux extrêmes (0, 50, 100)
- [ ] Documentation mise à jour dans `GAME_DESIGN_DOCUMENT.md`
