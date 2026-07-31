extends Node

signal zone_changed(zone_id, zone_data)

var overlapping_zones: Dictionary = {}
var current_zone_id := ""
var current_zone_data: Dictionary = {}

const ROLE_TAGS := {
	"sheriff": ["law", "town"],
	"deputy": ["law", "town"],
	"merchant": ["commerce", "road"],
	"bounty_hunter": ["road", "danger"],
	"brigand": ["danger", "road"],
	"citizen": ["town"],
	"": ["town"]
}

func register_overlap(zone_id: String, zone_data: Dictionary) -> void:
	overlapping_zones[zone_id] = zone_data
	_update_current_zone()

func unregister_overlap(zone_id: String) -> void:
	overlapping_zones.erase(zone_id)
	_update_current_zone()

func _update_current_zone() -> void:
	var next_id := ""
	var next_data: Dictionary = {}
	var best_priority := -1
	for zone_id in overlapping_zones.keys():
		var zone_data: Dictionary = overlapping_zones[zone_id]
		var priority = int(zone_data.get("priority", 0))
		if priority > best_priority:
			best_priority = priority
			next_id = zone_id
			next_data = zone_data
	var zone_changed_flag = next_id != current_zone_id
	current_zone_id = next_id
	current_zone_data = next_data
	if zone_changed_flag and next_id != "":
		var message = next_data.get("enter_message", "")
		if message != "":
			GameState.add_event(message)
	if zone_changed_flag:
		zone_changed.emit(current_zone_id, current_zone_data)
		GameState.state_changed.emit()

func get_zone_name() -> String:
	if current_zone_id == "":
		return "Prairies"
	return current_zone_data.get("name", "Inconnu")

func has_tag(tag: String) -> bool:
	if current_zone_id == "":
		return false
	var tags: Array = current_zone_data.get("tags", [])
	return tag in tags

func can_perform_role_action(role_id: String) -> bool:
	var required_tags: Array = ROLE_TAGS.get(role_id, ROLE_TAGS[""])
	for tag in required_tags:
		if has_tag(tag):
			return true
	return false

func get_zone_requirement_hint(role_id: String) -> String:
	match role_id:
		"sheriff":
			return "Rendez-vous au bureau du sheriff ou en ville."
		"deputy":
			return "Rendez-vous au bureau du sheriff ou en ville."
		"merchant":
			return "Allez a l'entrepot, la boutique ou une route."
		"bounty_hunter":
			return "Patrouillez sur une route ou dans une zone a risque."
		"brigand":
			return "Gagnez le canyon, le camp brigand ou une route."
		"citizen":
			return "Explorez la ville pour agir."
		_:
			return "Explorez la ville pour consulter les files."

func sync_player_zones(player: Node2D) -> void:
	overlapping_zones.clear()
	for zone in player.get_tree().get_nodes_in_group("location_zones"):
		if zone.has_method("contains_global_point") and zone.contains_global_point(player.global_position):
			overlapping_zones[zone.location_id] = zone.location_data
	_update_current_zone()
