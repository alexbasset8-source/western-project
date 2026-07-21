extends FrontierCharacter

@onready var body = $Body
@onready var name_label = $NameLabel
@onready var state_dot = $StateDot

var objective = ""
var home_position = Vector2.ZERO
var wander_target = Vector2.ZERO
var wander_timer = 0.0
var move_speed = 28.0

func _ready():
	GameState.state_changed.connect(refresh_from_state)
	_choose_new_target()

func setup(data, start_position):
	character_name = data.get("name", "")
	role_id = data.get("role_id", "")
	state = data.get("state", "alive")
	caution = int(data.get("caution", 50))
	aggression = int(data.get("aggression", 50))
	objective = data.get("objective", "")
	home_position = start_position
	position = start_position
	refresh_visuals()

func _process(delta):
	if state == "dead" or state == "prisoner":
		return
	wander_timer -= delta
	if wander_timer <= 0.0 or position.distance_to(wander_target) < 4.0:
		_choose_new_target()
	var direction = position.direction_to(wander_target)
	position += direction * move_speed * delta

func refresh_from_state():
	var data = GameState.find_character(character_name)
	if data.is_empty():
		return
	role_id = data.get("role_id", "")
	state = data.get("state", "alive")
	refresh_visuals()

func refresh_visuals():
	var data = GameState.find_character(character_name)
	var wounds = int(data.get("wounds", 0)) if not data.is_empty() else 0
	var state_label = _state_label(state, wounds)
	name_label.text = "%s
%s - %s" % [character_name, RoleManager.get_role_name(role_id) if role_id != "" else "Sans role", state_label]
	body.color = _role_color(role_id)
	visible = true
	if state == "dead":
		body.color = Color(0.08, 0.08, 0.08, 1)
		state_dot.color = Color(0.5, 0.0, 0.0, 1)
		name_label.modulate = Color(0.7, 0.7, 0.7, 1)
		return
	if state == "prisoner":
		body.color = Color(0.16, 0.16, 0.16, 1)
		state_dot.color = Color(0.55, 0.55, 0.55, 1)
		name_label.modulate = Color(0.8, 0.8, 0.8, 1)
		return
	if state == "wanted":
		state_dot.color = Color(0.95, 0.68, 0.05, 1)
	elif wounds > 0:
		state_dot.color = Color(0.85, 0.25, 0.2, 1)
		body.modulate = Color(1, 0.75, 0.75, 1)
	else:
		state_dot.color = Color(0.1, 0.65, 0.2, 1)
		body.modulate = Color(1, 1, 1, 1)
	name_label.modulate = Color(1, 1, 1, 1)

func _state_label(current_state, wounds := 0):
	match current_state:
		"wanted":
			return "recherche"
		"prisoner":
			return "prisonnier"
		"dead":
			return "mort"
		_:
			if wounds > 0:
				return "blesse (%d)" % wounds
			return "vivant"

func _choose_new_target():
	wander_timer = randf_range(2.0, 5.0)
	wander_target = home_position + Vector2(randf_range(-60.0, 60.0), randf_range(-40.0, 40.0))

func _role_color(current_role):
	match current_role:
		"sheriff":
			return Color(0.08, 0.18, 0.42, 1)
		"merchant":
			return Color(0.15, 0.42, 0.23, 1)
		"bounty_hunter":
			return Color(0.42, 0.30, 0.12, 1)
		"brigand":
			return Color(0.45, 0.12, 0.10, 1)
		_:
			return Color(0.30, 0.30, 0.30, 1)
