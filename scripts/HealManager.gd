extends Node

const HEAL_ZONES := {
	"saloon": 10,
	"store": 15
}

func try_heal(character_name: String) -> void:
	var character = GameState.find_character(character_name)
	if character.is_empty() or character.get("state", "alive") == "dead":
		return
	if character.get("state", "alive") == "prisoner":
		GameState.add_event("Impossible de se soigner en prison.")
		return
	var wounds = InjuryManager.get_wounds(character_name)
	if wounds <= 0:
		GameState.add_event("Vous n'avez pas besoin de soins.")
		return
	var zone_id = ZoneManager.current_zone_id
	if not HEAL_ZONES.has(zone_id):
		GameState.add_event("Rendez-vous au saloon ($10) ou a la boutique ($15) pour vous soigner.")
		return
	var cost = HEAL_ZONES[zone_id]
	var money = GameState.get_money(character_name)
	if money < cost:
		GameState.add_event("Soins refuses : il faut $%d." % cost)
		return
	GameState.adjust_money(character_name, -cost)
	InjuryManager.heal_character(character_name, 1)
	var place = "saloon" if zone_id == "saloon" else "boutique"
	GameState.add_event("%s se fait soigner au %s (-$%d)." % [character_name, place, cost])
	SaveManager.save_game()

func get_heal_hint() -> String:
	if ZoneManager.current_zone_id in HEAL_ZONES:
		var cost = HEAL_ZONES[ZoneManager.current_zone_id]
		return "H : se soigner (-$%d)" % cost
	return "H : soins au saloon ($10) ou boutique ($15)"
