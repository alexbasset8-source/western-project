extends Node

## Façade légère pour les actions de rôle (BG-001-P1/P2).
##
## Ce fichier faisait 1419 lignes avant refactorisation (dette technique,
## voir docs/BACKLOG.md et docs/DECISIONS.md). Les actions propres à chaque
## rôle ont été déplacées dans des modules dédiés (TownActionsSheriff.gd,
## TownActionsDeputy.gd, TownActionsMerchant.gd, TownActionsBountyHunter.gd,
## TownActionsBrigand.gd, TownActionsCitizen.gd), instanciés ci-dessous et
## exposés via des propriétés (TownActions.sheriff, TownActions.deputy, ...).
##
## Ne restent ici que :
## - les événements mondiaux génériques déclenchés par EventManager.gd
##   (duel, post_bounty_on_brigand, deadly_incident)
## - les fonctions de recherche de cible partagées entre plusieurs rôles
##   (find_wanted_brigand, find_bounty_target)
## - le registre des modules par rôle (get_module)

var sheriff := preload("res://scripts/TownActionsSheriff.gd").new()
var deputy := preload("res://scripts/TownActionsDeputy.gd").new()
var merchant := preload("res://scripts/TownActionsMerchant.gd").new()
var bounty_hunter := preload("res://scripts/TownActionsBountyHunter.gd").new()
var brigand := preload("res://scripts/TownActionsBrigand.gd").new()
var citizen := preload("res://scripts/TownActionsCitizen.gd").new()

## Retourne le module d'actions du role donne, ou null si le role n'en a pas
## (ex: role_id == ""). Utilise par PlayerActionManager.perform_named_action().
func get_module(role_id: String) -> RefCounted:
	match role_id:
		"sheriff":
			return sheriff
		"deputy":
			return deputy
		"merchant":
			return merchant
		"bounty_hunter":
			return bounty_hunter
		"brigand":
			return brigand
		"citizen":
			return citizen
		_:
			return null


# ============================================
# ÉVÉNEMENTS MONDIAUX GÉNÉRIQUES (déclenchés par EventManager.gd)
# ============================================

func duel(a: Dictionary, b: Dictionary) -> void:
	if a.is_empty() or b.is_empty() or a.get("name", "") == b.get("name", ""):
		return
	GameState.add_event("Un duel oppose %s et %s pres du saloon." % [a.get("name", "?"), b.get("name", "?")])
	if randf() < 0.35:
		var loser = [a, b].pick_random()
		InjuryManager.harm_character(loser.get("name", ""), "duel au saloon", 2)
	elif randf() < 0.50:
		InjuryManager.harm_character(a.get("name", ""), "duel au saloon", 1)
		InjuryManager.harm_character(b.get("name", ""), "duel au saloon", 1)

func post_bounty_on_brigand() -> void:
	var brigand_target = GameState.get_random_character_by_role("brigand")
	if brigand_target.is_empty():
		return
	GameState.mark_wanted(brigand_target.get("name", ""), 15)

func deadly_incident() -> void:
	var candidates = GameState.get_alive_characters()
	if candidates.is_empty():
		return
	var character = candidates.pick_random()
	GameState.add_event("Un incident tourne mal a Frontier Town.")
	InjuryManager.harm_character(character.get("name", ""), "incident de ville", 2)


# ============================================
# RECHERCHE DE CIBLE PARTAGÉE (Sheriff, Adjoint, Chasseur de primes)
# ============================================

func find_wanted_brigand() -> Dictionary:
	var candidates = []
	for character in GameState.get_characters_by_role("brigand"):
		if character.get("state", "alive") == "wanted":
			candidates.append(character)
	if candidates.is_empty():
		return GameState.get_random_character_by_role("brigand")
	return candidates.pick_random()

func find_bounty_target() -> Dictionary:
	var candidates = []
	for character in GameState.get_alive_characters():
		if character.get("state", "alive") == "wanted" and int(character.get("bounty", 0)) > 0:
			candidates.append(character)
	if candidates.is_empty():
		return find_wanted_brigand()
	return candidates.pick_random()
