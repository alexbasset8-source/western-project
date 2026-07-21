extends Node

# Noms génériques pour les remplaçants
const FIRST_NAMES := [
	"Ray", "Sam", "Buck", "Walt", "Cal", "Hank", "Lou", "Clem", "Burt", "Zeb",
	"Ida", "Mae", "Pearl", "Ruth", "Nell", "Ada", "Fern", "Cora", "Dot", "Bea"
]
const LAST_NAMES := [
	"Stone", "Thorn", "Clay", "Holt", "Vane", "Ash", "Dunn", "Fitch", "Gale", "Marsh",
	"Crane", "Drake", "Ford", "Grant", "Hayes", "Knox", "Lane", "Miles", "Nash", "Price"
]

const RESPAWN_DELAY := 15.0
const MAX_NPC_COUNT := 14

var _pending_respawns: Array[Dictionary] = []
var _elapsed_since_last_check := 0.0

func _process(delta: float) -> void:
	_elapsed_since_last_check += delta
	if _elapsed_since_last_check < 5.0:
		return
	_elapsed_since_last_check = 0.0
	_check_pending_respawns()
	_queue_replacements_if_needed()

func _queue_replacements_if_needed() -> void:
	var living_npc_count = 0
	for character in GameState.characters:
		if character.get("name", "") == GameState.player_name:
			continue
		if character.get("state", "alive") != "dead":
			living_npc_count += 1

	if living_npc_count >= MAX_NPC_COUNT:
		return

	# Trouver les rôles sous-peuplés pour orienter les remplaçants
	var roles_needing = _find_vacant_or_queued_roles()
	var role_id = roles_needing[0] if not roles_needing.is_empty() else ""

	var delay = randf_range(RESPAWN_DELAY * 0.8, RESPAWN_DELAY * 1.4)
	_pending_respawns.append({
		"role_id": role_id,
		"delay": delay,
		"elapsed": 0.0
	})

func _check_pending_respawns() -> void:
	var still_pending: Array[Dictionary] = []
	for entry in _pending_respawns:
		entry["elapsed"] += _elapsed_since_last_check + 5.0
		if entry["elapsed"] >= entry["delay"]:
			_spawn_replacement(entry.get("role_id", ""))
		else:
			still_pending.append(entry)
	_pending_respawns = still_pending

func _spawn_replacement(preferred_role: String) -> void:
	var new_name = _generate_name()
	var role_id = preferred_role if preferred_role != "" else ""

	var new_char: Dictionary = {
		"name": new_name,
		"role_id": "",
		"state": "alive",
		"temperament": _random_temperament(),
		"objective": _objective_for_role(role_id),
		"caution": randi_range(25, 85),
		"aggression": randi_range(15, 85),
		"money": randi_range(5, 30),
		"bounty": 0,
		"wounds": 0,
		"prison_remaining": 0,
		"mission": {},
		"is_player": false,
		"reputation": {"law": randi_range(0, 30), "crime": randi_range(0, 30),
			"commerce": randi_range(0, 30), "reliability": randi_range(0, 30),
			"combat": randi_range(0, 30)}
	}
	GameState.characters.append(new_char)
	GameState.add_event("%s arrive a Frontier Town." % new_name)

	# Candidater au rôle souhaité si une place existe ou pour la file
	if role_id != "":
		RoleManager.apply_for_role(new_name, role_id)

	# Notifier World pour spawn le nœud visuel
	_spawn_visual_node(new_char)
	SaveManager.save_game()

func _spawn_visual_node(character_data: Dictionary) -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null or tree.current_scene == null:
		return
	var world = tree.current_scene.get_node_or_null("World")
	if world == null or not world.has_method("spawn_one_character"):
		return
	world.spawn_one_character(character_data)

func _find_vacant_or_queued_roles() -> Array:
	var result: Array = []
	for role_id in GameState.roles.keys():
		if RoleManager.has_vacancy(role_id):
			result.push_front(role_id)  # priorité aux places vacantes
		elif RoleManager.queues.get(role_id, []).is_empty():
			result.append(role_id)
	return result

func _generate_name() -> String:
	var first = FIRST_NAMES.pick_random()
	var last = LAST_NAMES.pick_random()
	# Éviter les doublons
	var candidate = "%s %s" % [first, last]
	var attempt = 0
	while not GameState.find_character(candidate).is_empty() and attempt < 20:
		first = FIRST_NAMES.pick_random()
		last = LAST_NAMES.pick_random()
		candidate = "%s %s" % [first, last]
		attempt += 1
	return candidate

func _random_temperament() -> String:
	var traits = ["courageux", "prudent", "ambitieux", "discret", "brutal",
		"calme", "nerveux", "opportuniste", "loyal", "independant"]
	return "%s, %s" % [traits.pick_random(), traits.pick_random()]

func _objective_for_role(role_id: String) -> String:
	match role_id:
		"sheriff":
			return "maintenir l'ordre a Frontier Town"
		"merchant":
			return "commerce et routes de livraison"
		"bounty_hunter":
			return "traque les criminels recherches"
		"brigand":
			return "piller et survivre"
		_:
			return "trouver sa place dans Frontier Town"
