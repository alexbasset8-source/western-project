extends Panel
class_name WindowFrame

## Fenetre generique deplacable, redimensionnable, minimisable et fermable.
## Utilisee pour les panneaux HUD/Roles/Journal (TCK3).
## Le chevauchement entre fenetres est empeche par WindowManager.rect_overlaps_other().

signal closed(window)
signal focused(window)
signal moved(window)

@export var window_id: String = ""
@export var window_title: String = "Fenetre"
@export var min_window_size := Vector2(220, 140)

# Assigne par WindowManager.register(). Reste nul si la fenetre n'est pas geree.
var window_manager: WindowManager = null

var _is_minimized := false
var _dragging := false
var _drag_offset := Vector2.ZERO
var _resizing := false
var _resize_start_mouse := Vector2.ZERO
var _resize_start_size := Vector2.ZERO
var _expanded_size := Vector2.ZERO

@onready var title_bar: Control = $TitleBar
@onready var title_label: Label = $TitleBar/TitleRow/TitleLabel
@onready var minimize_button: Button = $TitleBar/TitleRow/MinimizeButton
@onready var close_button: Button = $TitleBar/TitleRow/CloseButton
@onready var content: Control = $Content
@onready var resize_handle: Control = $ResizeHandle


func _ready() -> void:
	title_label.text = window_title
	title_bar.gui_input.connect(_on_title_bar_input)
	minimize_button.pressed.connect(_on_minimize_pressed)
	close_button.pressed.connect(_on_close_pressed)
	resize_handle.gui_input.connect(_on_resize_handle_input)
	_expanded_size = size


func _on_title_bar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_global_mouse_position() - global_position
			focus_window()
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_try_move(get_global_mouse_position() - _drag_offset)


func _try_move(candidate_position: Vector2) -> void:
	var viewport_size = get_viewport_rect().size
	candidate_position.x = clamp(candidate_position.x, 0, max(0, viewport_size.x - size.x))
	candidate_position.y = clamp(candidate_position.y, 0, max(0, viewport_size.y - size.y))

	if window_manager == null:
		position = candidate_position
		moved.emit(self)
		return

	var candidate_rect := Rect2(candidate_position, size)
	if not window_manager.rect_overlaps_other(self, candidate_rect):
		position = candidate_position
	else:
		# Empeche le chevauchement : on autorise le mouvement uniquement sur
		# l'axe qui reste libre, la fenetre "bute" contre l'autre sinon.
		var horizontal_rect := Rect2(Vector2(candidate_position.x, position.y), size)
		var vertical_rect := Rect2(Vector2(position.x, candidate_position.y), size)
		if not window_manager.rect_overlaps_other(self, horizontal_rect):
			position.x = candidate_position.x
		elif not window_manager.rect_overlaps_other(self, vertical_rect):
			position.y = candidate_position.y
	moved.emit(self)


func _on_resize_handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_resizing = true
			_resize_start_mouse = get_global_mouse_position()
			_resize_start_size = size
			focus_window()
		else:
			_resizing = false
	elif event is InputEventMouseMotion and _resizing:
		_try_resize(_resize_start_size + (get_global_mouse_position() - _resize_start_mouse))


func _try_resize(candidate_size: Vector2) -> void:
	var viewport_size = get_viewport_rect().size
	candidate_size.x = clamp(candidate_size.x, min_window_size.x, max(min_window_size.x, viewport_size.x - position.x))
	candidate_size.y = clamp(candidate_size.y, min_window_size.y, max(min_window_size.y, viewport_size.y - position.y))

	if window_manager != null:
		var candidate_rect := Rect2(position, candidate_size)
		if window_manager.rect_overlaps_other(self, candidate_rect):
			# Empeche le chevauchement : la fenetre ne peut pas grandir par dessus une autre.
			return

	size = candidate_size
	if not _is_minimized:
		_expanded_size = candidate_size
	moved.emit(self)


func _on_minimize_pressed() -> void:
	set_minimized(not _is_minimized)


## Reduit la fenetre a sa seule barre de titre (ou la restaure).
func set_minimized(minimized: bool) -> void:
	_is_minimized = minimized
	content.visible = not _is_minimized
	resize_handle.visible = not _is_minimized
	if _is_minimized:
		_expanded_size = size
		size = Vector2(size.x, title_bar.size.y)
		minimize_button.text = "▢"
	else:
		size = Vector2(size.x, _expanded_size.y)
		minimize_button.text = "_"
	moved.emit(self)


func is_minimized() -> bool:
	return _is_minimized


func _on_close_pressed() -> void:
	close()


func close() -> void:
	visible = false
	closed.emit(self)


func open() -> void:
	visible = true
	focus_window()


## Amene la fenetre au premier plan parmi ses soeurs.
func focus_window() -> void:
	var parent = get_parent()
	if parent:
		parent.move_child(self, parent.get_child_count() - 1)
	focused.emit(self)


## Disposition serialisable pour la persistance entre sessions (BG-002/TCK3).
func get_layout() -> Dictionary:
	return {
		"position_x": position.x,
		"position_y": position.y,
		"size_x": _expanded_size.x if _is_minimized else size.x,
		"size_y": _expanded_size.y if _is_minimized else size.y,
		"minimized": _is_minimized,
		"visible": visible,
	}


func apply_layout(layout: Dictionary) -> void:
	if layout.is_empty():
		return
	var viewport_size = get_viewport_rect().size
	var new_position = Vector2(layout.get("position_x", position.x), layout.get("position_y", position.y))
	var new_size = Vector2(layout.get("size_x", size.x), layout.get("size_y", size.y))
	new_position.x = clamp(new_position.x, 0, max(0, viewport_size.x - new_size.x))
	new_position.y = clamp(new_position.y, 0, max(0, viewport_size.y - new_size.y))
	position = new_position
	size = new_size
	_expanded_size = new_size
	visible = layout.get("visible", true)
	if layout.get("minimized", false):
		set_minimized(true)
