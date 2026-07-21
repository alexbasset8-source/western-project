extends Node2D
class_name FrontierCharacter

@export var character_name := ""
@export var role_id := ""
@export var state := "alive"
@export var caution := 50
@export var aggression := 50

func is_alive() -> bool:
	return state != "dead"
