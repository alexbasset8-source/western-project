extends Area2D

var location_id := ""
var location_data: Dictionary = {}
var zone_size := Vector2(32, 32)

func setup(data: Dictionary) -> void:
	location_data = data
	location_id = data.get("id", "")
	zone_size = Vector2(float(data.get("w", 32)), float(data.get("h", 32)))
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false
	add_to_group("location_zones")
	var shape = RectangleShape2D.new()
	shape.size = zone_size
	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.position = zone_size * 0.5
	add_child(collision)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func contains_global_point(point: Vector2) -> bool:
	var local_point = to_local(point)
	return Rect2(Vector2.ZERO, zone_size).has_point(local_point)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	ZoneManager.register_overlap(location_id, location_data)

func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return
	ZoneManager.unregister_overlap(location_id)
