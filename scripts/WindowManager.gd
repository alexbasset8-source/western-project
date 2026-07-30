extends Node
class_name WindowManager

## Registre des fenetres HUD (Statut, Roles, Journal). Gere :
## - le cycle au clavier (TAB)
## - le menu de reouverture (CTRL+TAB / bouton "Fenetres")
## - la sauvegarde de la disposition entre sessions (TCK3)

const LAYOUT_PATH := "user://window_layout.cfg"

var windows: Array[WindowFrame] = []
var _focus_index := -1


func register(window: WindowFrame) -> void:
	windows.append(window)
	window.window_manager = self
	window.closed.connect(func(_w): save_layout())
	window.moved.connect(func(_w): save_layout())


## Vrai si candidate_rect chevauche une autre fenetre visible que "window".
func rect_overlaps_other(window: WindowFrame, candidate_rect: Rect2) -> bool:
	for other in windows:
		if other == window or not is_instance_valid(other):
			continue
		if not other.visible:
			continue
		if candidate_rect.intersects(Rect2(other.position, other.size)):
			return true
	return false


## Touche TAB : passe a la fenetre ouverte suivante et la met au premier plan.
func cycle_windows() -> void:
	var visible_windows: Array[WindowFrame] = []
	for window in windows:
		if window.visible:
			visible_windows.append(window)
	if visible_windows.is_empty():
		return
	_focus_index = (_focus_index + 1) % visible_windows.size()
	var target = visible_windows[_focus_index]
	if target.is_minimized():
		target.set_minimized(false)
	target.focus_window()


## Reouvre (ou met au premier plan) une fenetre fermee.
func reopen(window: WindowFrame) -> void:
	window.open()
	save_layout()


func save_layout() -> void:
	var config := ConfigFile.new()
	for window in windows:
		if window.window_id == "":
			continue
		config.set_value("windows", window.window_id, window.get_layout())
	config.save(LAYOUT_PATH)


func load_layout() -> void:
	var config := ConfigFile.new()
	if config.load(LAYOUT_PATH) != OK:
		return
	for window in windows:
		if window.window_id != "" and config.has_section_key("windows", window.window_id):
			window.apply_layout(config.get_value("windows", window.window_id, {}))
