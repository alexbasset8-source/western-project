extends CharacterBody2D

@export var speed := 180.0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	GameState.player_respawned.connect(_on_player_respawned)
	call_deferred("_sync_starting_zone")

func _on_player_respawned(_character_name: String) -> void:
	global_position = GameState.PLAYER_SPAWN
	call_deferred("_sync_starting_zone")

func _sync_starting_zone() -> void:
	ZoneManager.sync_player_zones(self)

func _physics_process(_delta: float) -> void:
	if GameState.simulation_paused:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var player = GameState.get_player()
	if player.is_empty():
		return
	var player_state = player.get("state", "alive")
	if player_state == "dead" or player_state == "prisoner":
		velocity = Vector2.ZERO
		if player_state == "prisoner":
			global_position = PrisonManager.PRISON_CELL
		move_and_slide()
		return

	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	var wounds = InjuryManager.get_wounds(GameState.player_name)
	var move_speed = speed * (1.0 - wounds * 0.15)
	velocity = input_vector.normalized() * move_speed if input_vector != Vector2.ZERO else Vector2.ZERO
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if GameState.simulation_paused:
		return
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	var player = GameState.get_player()
	if not player.is_empty() and player.get("state", "alive") == "dead":
		return
	if event.keycode == KEY_E:
		PlayerActionManager.perform_role_action()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_R:
		PlayerActionManager.attempt_escape()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_H:
		HealManager.try_heal(GameState.player_name)
		get_viewport().set_input_as_handled()
