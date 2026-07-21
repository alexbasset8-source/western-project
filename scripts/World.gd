extends Node2D

@export var simulated_character_scene: PackedScene

@onready var map_root = $Map
@onready var zones_root = $Zones
@onready var collisions_root = $Collisions
@onready var characters_root = $Characters

const MAP_SIZE := Vector2(1800, 1200)

const ROAD_CONNECTORS := [
	{"x": 700, "y": 740, "w": 40, "h": 70, "color": [0.45, 0.34, 0.22, 1]},
	{"x": 900, "y": 595, "w": 50, "h": 50, "color": [0.45, 0.34, 0.22, 1]},
	{"x": 300, "y": 360, "w": 120, "h": 50, "color": [0.45, 0.34, 0.22, 1]}
]

const CANYON_WALLS := [
	{"x": 180, "y": 300, "w": 30, "h": 170},
	{"x": 390, "y": 300, "w": 30, "h": 170},
	{"x": 180, "y": 300, "w": 240, "h": 24}
]

var role_positions = {
	"sheriff": Vector2(600, 500),
	"merchant": Vector2(820, 750),
	"bounty_hunter": Vector2(960, 610),
	"brigand": Vector2(300, 380),
	"": Vector2(700, 660)
}

var role_offsets = {
	"sheriff": 0,
	"merchant": 0,
	"bounty_hunter": 0,
	"brigand": 0,
	"": 0
}

func _ready() -> void:
	_build_map()
	spawn_simulated_characters()
	GameState.add_event("La carte de Frontier Town est chargee.")

func _build_map() -> void:
	_create_ground()
	_create_road_connectors()
	for location_data in GameState.locations:
		_create_location_visual(location_data)
		_create_interaction_zone(location_data)
		if location_data.get("solid", false):
			_create_solid_block(location_data)
	_create_canyon_walls()
	_create_boundary_walls()

func _create_ground() -> void:
	var ground = ColorRect.new()
	ground.name = "Ground"
	ground.size = MAP_SIZE
	ground.color = Color(0.58, 0.43, 0.27, 1)
	map_root.add_child(ground)

func _create_road_connectors() -> void:
	for connector in ROAD_CONNECTORS:
		var road = ColorRect.new()
		road.position = Vector2(connector.x, connector.y)
		road.size = Vector2(connector.w, connector.h)
		var color_array: Array = connector.color
		road.color = Color(color_array[0], color_array[1], color_array[2], color_array[3])
		map_root.add_child(road)

func _create_location_visual(location_data: Dictionary) -> void:
	var rect = ColorRect.new()
	rect.position = Vector2(location_data.get("x", 0), location_data.get("y", 0))
	rect.size = Vector2(location_data.get("w", 32), location_data.get("h", 32))
	var color_array: Array = location_data.get("color", [0.4, 0.4, 0.4, 1])
	rect.color = Color(color_array[0], color_array[1], color_array[2], color_array[3])
	rect.name = location_data.get("id", "location")
	map_root.add_child(rect)

	var label = Label.new()
	label.text = location_data.get("name", "")
	label.position = rect.position + Vector2(8, rect.size.y * 0.5 - 12)
	label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.82, 1))
	label.add_theme_font_size_override("font_size", 13)
	map_root.add_child(label)

	var tags: Array = location_data.get("tags", [])
	if "road" in tags:
		var road_mark = Label.new()
		road_mark.text = "— route —"
		road_mark.position = rect.position + Vector2(rect.size.x * 0.5 - 36, rect.size.y * 0.5 - 28)
		road_mark.add_theme_color_override("font_color", Color(0.78, 0.68, 0.5, 0.9))
		road_mark.add_theme_font_size_override("font_size", 11)
		map_root.add_child(road_mark)

func _create_interaction_zone(location_data: Dictionary) -> void:
	var zone = Area2D.new()
	zone.position = Vector2(location_data.get("x", 0), location_data.get("y", 0))
	zone.set_script(load("res://scripts/LocationZone.gd"))
	var zone_data = location_data.duplicate()
	zone_data["priority"] = _zone_priority(location_data)
	zone.setup(zone_data)
	zones_root.add_child(zone)

func _zone_priority(location_data: Dictionary) -> int:
	if location_data.get("solid", false):
		return 3
	var tags: Array = location_data.get("tags", [])
	if "town" in tags and location_data.get("id", "") != "town_square":
		return 2
	if "road" in tags:
		return 1
	return 2

func _create_solid_block(location_data: Dictionary) -> void:
	_add_static_rect(
		Vector2(location_data.get("x", 0), location_data.get("y", 0)),
		Vector2(location_data.get("w", 32), location_data.get("h", 32))
	)

func _create_canyon_walls() -> void:
	for wall in CANYON_WALLS:
		_add_static_rect(Vector2(wall.x, wall.y), Vector2(wall.w, wall.h))

func _create_boundary_walls() -> void:
	var thickness = 24.0
	_add_static_rect(Vector2(0, 0), Vector2(MAP_SIZE.x, thickness))
	_add_static_rect(Vector2(0, MAP_SIZE.y - thickness), Vector2(MAP_SIZE.x, thickness))
	_add_static_rect(Vector2(0, 0), Vector2(thickness, MAP_SIZE.y))
	_add_static_rect(Vector2(MAP_SIZE.x - thickness, 0), Vector2(thickness, MAP_SIZE.y))

func _add_static_rect(origin: Vector2, size: Vector2) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	var shape = RectangleShape2D.new()
	shape.size = size
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = origin + size * 0.5
	body.add_child(collision)
	collisions_root.add_child(body)

func spawn_simulated_characters() -> void:
	if simulated_character_scene == null:
		push_warning("Scene de personnage simule manquante.")
		return
	for character_data in GameState.characters:
		if character_data.get("name", "") == GameState.player_name:
			continue
		spawn_one_character(character_data)

func spawn_one_character(character_data: Dictionary) -> void:
	if simulated_character_scene == null:
		return
	var character_node = simulated_character_scene.instantiate()
	characters_root.add_child(character_node)
	var role_id = character_data.get("role_id", "")
	character_node.setup(character_data, _get_spawn_position(role_id))

func _get_spawn_position(role_id: String) -> Vector2:
	var base_position = role_positions.get(role_id, role_positions[""])
	var index = int(role_offsets.get(role_id, 0))
	role_offsets[role_id] = index + 1
	var column = index % 3
	var row = int(index / 3)
	return base_position + Vector2(column * 46, row * 42)
