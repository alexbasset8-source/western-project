extends Node

var elapsed = 0.0
var event_interval = 8.0

func _process(delta):
	if GameState.simulation_paused:
		return
	elapsed += delta
	if elapsed >= event_interval:
		elapsed = 0.0
		trigger_simulated_event()

func trigger_simulated_event():
	GameState.advance_world_day()
	PrisonManager.tick_sentences()
	var event_types = ["transport_goods", "convoy_attack", "bounty_posted", "duel", "arrest", "death"]
	var event_type = event_types.pick_random()
	match event_type:
		"transport_goods":
			var merchant = GameState.get_random_character_by_role("merchant")
			TownActions.transport_goods(merchant)
		"convoy_attack":
			var brigand = GameState.get_random_character_by_role("brigand")
			var merchant = GameState.get_random_character_by_role("merchant")
			TownActions.attack_convoy(brigand, merchant)
		"bounty_posted":
			TownActions.post_bounty_on_brigand()
		"duel":
			var a = _random_non_prisoner()
			var b = _random_non_prisoner()
			TownActions.duel(a, b)
		"arrest":
			var hunter = GameState.get_random_character_by_role("bounty_hunter")
			var target = _random_wanted_brigand()
			TownActions.track_bounty(hunter, target)
		"death":
			TownActions.deadly_incident()
	SaveManager.save_game()

func _random_wanted_brigand():
	var candidates = []
	for character in GameState.get_characters_by_role("brigand"):
		if character.get("state", "alive") == "wanted":
			candidates.append(character)
	if candidates.is_empty():
		return GameState.get_random_character_by_role("brigand")
	return candidates.pick_random()

func _random_non_prisoner():
	var candidates = []
	for character in GameState.get_alive_characters():
		if character.get("state", "alive") != "prisoner":
			candidates.append(character)
	if candidates.is_empty():
		return {}
	return candidates.pick_random()
