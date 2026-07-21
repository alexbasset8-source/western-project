extends CanvasLayer

const ROLE_ORDER := ["sheriff", "merchant", "bounty_hunter", "brigand"]

@onready var title_label = $Root/HudPanel/HudMargin/HudVBox/TitleLabel
@onready var role_label = $Root/HudPanel/HudMargin/HudVBox/RoleLabel
@onready var mission_label = $Root/HudPanel/HudMargin/HudVBox/MissionLabel
@onready var state_label = $Root/HudPanel/HudMargin/HudVBox/StateLabel
@onready var wounds_label = $Root/HudPanel/HudMargin/HudVBox/WoundsLabel
@onready var money_label = $Root/HudPanel/HudMargin/HudVBox/MoneyLabel
@onready var bounty_label = $Root/HudPanel/HudMargin/HudVBox/BountyLabel
@onready var zone_label = $Root/HudPanel/HudMargin/HudVBox/ZoneLabel
@onready var day_label = $Root/HudPanel/HudMargin/HudVBox/DayLabel
@onready var action_label = $Root/HudPanel/HudMargin/HudVBox/ActionLabel
@onready var help_label = $Root/HudPanel/HudMargin/HudVBox/HelpLabel
@onready var roles_vbox = $Root/RolesPanel/RolesMargin/RolesVBox
@onready var log = $Root/LogPanel/LogMargin/Log
@onready var death_panel = $Root/DeathPanel
@onready var death_summary = $Root/DeathPanel/DeathMargin/DeathVBox/DeathSummary
@onready var death_history = $Root/DeathPanel/DeathMargin/DeathVBox/DeathHistory
@onready var name_input = $Root/DeathPanel/DeathMargin/DeathVBox/NameInput
@onready var respawn_button = $Root/DeathPanel/DeathMargin/DeathVBox/RespawnButton

var queue_rows: Dictionary = {}

func _ready() -> void:
	GameState.state_changed.connect(refresh)
	GameState.player_died.connect(_on_player_died)
	GameState.player_respawned.connect(_on_player_respawned)
	ZoneManager.zone_changed.connect(func(_zone_id, _zone_data): refresh())
	RoleManager.queue_changed.connect(_refresh_queue_ui)
	MissionManager.mission_updated.connect(func(_name): refresh())
	respawn_button.pressed.connect(_on_respawn_pressed)
	name_input.text_submitted.connect(func(_text): _on_respawn_pressed())
	_build_queue_ui()
	refresh()
	call_deferred("_ensure_respawn_panel_state")

func _unhandled_input(event: InputEvent) -> void:
	if death_panel.visible:
		return
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			RoleManager.apply_for_role(GameState.player_name, "sheriff")
		KEY_2:
			RoleManager.apply_for_role(GameState.player_name, "merchant")
		KEY_3:
			RoleManager.apply_for_role(GameState.player_name, "bounty_hunter")
		KEY_4:
			RoleManager.apply_for_role(GameState.player_name, "brigand")
		KEY_K:
			GameState.kill_first_holder("sheriff")
		KEY_L:
			EventManager.trigger_simulated_event()

func _build_queue_ui() -> void:
	var header = Label.new()
	header.text = "Files d'attente — cliquez pour rejoindre / quitter"
	header.add_theme_font_size_override("font_size", 13)
	roles_vbox.add_child(header)

	for role_id in ROLE_ORDER:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var info = Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		var join_button = Button.new()
		join_button.text = "Rejoindre"
		join_button.pressed.connect(_on_join_queue.bind(role_id))

		var leave_button = Button.new()
		leave_button.text = "Quitter"
		leave_button.pressed.connect(_on_leave_queue.bind(role_id))

		row.add_child(info)
		row.add_child(join_button)
		row.add_child(leave_button)
		roles_vbox.add_child(row)

		queue_rows[role_id] = {
			"info": info,
			"join": join_button,
			"leave": leave_button
		}

func _on_join_queue(role_id: String) -> void:
	RoleManager.apply_for_role(GameState.player_name, role_id)
	SaveManager.save_game()
	_refresh_queue_ui()

func _on_leave_queue(role_id: String) -> void:
	RoleManager.leave_queue(GameState.player_name, role_id)
	SaveManager.save_game()
	_refresh_queue_ui()

func _refresh_queue_ui() -> void:
	var player = GameState.get_player()
	var player_name = GameState.player_name
	var player_role = player.get("role_id", "")
	var can_queue = not player.is_empty() and player.get("state", "alive") not in ["dead", "prisoner"]

	for role_id in ROLE_ORDER:
		var row: Dictionary = queue_rows.get(role_id, {})
		if row.is_empty():
			continue
		var holder_names: Array[String] = []
		for character in GameState.get_role_holders(role_id):
			holder_names.append(character.get("name", "?"))
		var holder_text = "vacant"
		if not holder_names.is_empty():
			holder_text = ", ".join(holder_names)
		var queue: Array = RoleManager.queues.get(role_id, [])
		var queue_text = "vide"
		if not queue.is_empty():
			queue_text = ", ".join(queue)
		var position = RoleManager.get_queue_position(player_name, role_id)
		var position_text = ""
		if position >= 0:
			position_text = " | Vous : #%d" % (position + 1)
		elif player_role == role_id:
			position_text = " | Vous : titulaire"

		row["info"].text = "%s — %s\nFile : %s%s" % [
			RoleManager.get_role_name(role_id),
			holder_text,
			queue_text,
			position_text
		]
		var in_this_queue = RoleManager.is_in_queue(player_name, role_id)
		row["join"].disabled = not can_queue or player_role != "" or in_this_queue
		row["leave"].disabled = not in_this_queue

func refresh() -> void:
	var player = GameState.get_player()
	var player_role = "Aucun"
	if not player.is_empty() and player.get("role_id", "") != "":
		player_role = RoleManager.get_role_name(player.get("role_id", ""))
	var player_state = player.get("state", "alive")
	var wounds = InjuryManager.get_wounds(GameState.player_name)

	title_label.text = "Frontier Town 0.5"
	role_label.text = "Role : %s" % player_role
	mission_label.text = "Mission : %s" % MissionManager.get_mission_text(GameState.player_name)
	state_label.text = "Etat : %s" % _state_label(player_state, wounds)
	state_label.add_theme_color_override("font_color", _state_color(player_state))
	wounds_label.text = "Blessures : %d/%d" % [wounds, InjuryManager.MAX_WOUNDS]
	wounds_label.add_theme_color_override(
		"font_color",
		Color(0.85, 0.25, 0.2, 1) if wounds > 0 else Color(0.85, 0.85, 0.85, 1)
	)
	money_label.text = "Argent : $%d" % GameState.get_money(GameState.player_name)
	bounty_label.text = "Prime : $%d" % GameState.get_bounty(GameState.player_name)
	bounty_label.add_theme_color_override(
		"font_color",
		Color(0.95, 0.68, 0.05, 1) if GameState.get_bounty(GameState.player_name) > 0 else Color(0.85, 0.85, 0.85, 1)
	)
	zone_label.text = "Zone : %s" % ZoneManager.get_zone_name()
	day_label.text = "Jour : %d" % GameState.world_day
	if player_state == "prisoner":
		day_label.text += " | Prison : %d tours" % PrisonManager.get_sentence_remaining(GameState.player_name)
	action_label.text = PlayerActionManager.get_action_hint()
	help_label.text = "Fleches : deplacer | E : action | H : %s | 1-4 : raccourcis" % HealManager.get_heal_hint()
	log.text = _build_log_text()
	_refresh_queue_ui()
	_ensure_respawn_panel_state()

func _on_player_died(death_record: Dictionary) -> void:
	GameState.simulation_paused = true
	_show_respawn_panel(death_record)
	refresh()

func _on_player_respawned(_character_name: String) -> void:
	GameState.simulation_paused = false
	death_panel.visible = false
	refresh()

func _on_respawn_pressed() -> void:
	GameState.create_new_player(name_input.text)

func _ensure_respawn_panel_state() -> void:
	var player = GameState.get_player()
	if player.is_empty():
		return
	if player.get("state", "alive") == "dead":
		if death_panel.visible:
			return
		var death_record = {}
		if not GameState.death_history.is_empty():
			death_record = GameState.death_history[0]
		else:
			death_record = {
				"name": GameState.player_name,
				"world_day": GameState.world_day,
				"role": "Aucun",
				"cause": "mort inconnue",
				"money": 0
			}
		_show_respawn_panel(death_record)
	else:
		death_panel.visible = false

func _show_respawn_panel(death_record: Dictionary) -> void:
	death_summary.text = "[b]%s[/b] est mort au jour %d.\nRole : %s\nCause : %s\nArgent perdu : $%d" % [
		death_record.get("name", "?"),
		death_record.get("world_day", 0),
		death_record.get("role", "Aucun"),
		death_record.get("cause", "?"),
		death_record.get("money", 0)
	]
	death_history.text = _build_death_history_text()
	name_input.text = GameState._default_player_name()
	death_panel.visible = true
	name_input.call_deferred("grab_focus")

func _build_death_history_text() -> String:
	if GameState.death_history.is_empty():
		return "Aucune mort precedente."
	var lines: Array[String] = []
	for record in GameState.death_history:
		lines.append(
			"- Jour %d : %s (%s) — %s" % [
				record.get("world_day", 0),
				record.get("name", "?"),
				record.get("role", "Aucun"),
				record.get("cause", "?")
			]
		)
	return "
".join(lines)

func _state_label(current_state: String, wounds: int = 0) -> String:
	match current_state:
		"wanted":
			return "recherche"
		"prisoner":
			return "prisonnier"
		"dead":
			return "mort"
		_:
			if wounds > 0:
				return "blesse"
			return "vivant"

func _state_color(current_state: String) -> Color:
	match current_state:
		"wanted":
			return Color(0.95, 0.68, 0.05, 1)
		"prisoner":
			return Color(0.65, 0.65, 0.65, 1)
		"dead":
			return Color(0.85, 0.2, 0.2, 1)
		_:
			return Color(0.45, 0.9, 0.5, 1)

func _build_log_text() -> String:
	var lines = ["[b]Journal de ville[/b]"]
	for entry in GameState.event_log:
		var text: String
		var event_type: String
		if typeof(entry) == TYPE_DICTIONARY:
			text = entry.get("text", "")
			event_type = entry.get("type", "")
		else:
			text = str(entry)
			event_type = ""
		match event_type:
			"death":
				lines.append("[color=#e05555]✗ %s[/color]" % text)
			"promotion":
				lines.append("[color=#55c46e]★ %s[/color]" % text)
			"player":
				lines.append("[color=#e8c84a]▶ %s[/color]" % text)
			"danger":
				lines.append("[color=#e08030]! %s[/color]" % text)
			_:
				lines.append("- %s" % text)
	return "
".join(lines)
