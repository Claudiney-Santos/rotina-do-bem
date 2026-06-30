class_name Habit

extends Control

signal put_up
signal put_down

@onready var node: Control = $"."
@onready var panel: VBoxContainer = $Panel/VBoxContainer
@onready var description_rich_label = $Panel/VBoxContainer/RichTextLabel
@onready var image_texturerect = $Panel/VBoxContainer/ScrollContainer/TextureRect

var neutral_stylebox: StyleBoxFlat = preload("res://styles/style-boxes/neutral_box_habit.tres")
var positive_stylebox: StyleBoxFlat = preload("res://styles/style-boxes/positive_box_habit.tres")
var negative_stylebox: StyleBoxFlat = preload("res://styles/style-boxes/negative_box_habit.tres")

var draggable: bool:
	get:
		return not node.get_meta("typing")
var down_and_drag: bool:
	get:
		return node.get_meta("down_and_drag") and draggable
var is_healthy: bool:
	get:
		return node.get_meta("is_healthy")

var description: String:
	get:
		return get_meta("description")

var is_immovable: bool:
	get:
		return _is_immovable

var _mouse_down_position: Vector2
var _node_down_position: Vector2
var _node_anchor_position: Vector2
var _mouse_status: int = 0
var _is_immovable: bool = false
var _is_holding: bool = false
var _is_hovering: bool = false
var _scale: float = 1

func update_correct_typing(len: int, typo: String = "") -> void:
	var correct: String = description.substr(0, len)
	var rest: String = description.substr(len+1)
	var current_letter_rt: String = ""
	var show_rt = func(letter: String, is_typo: bool = false) -> String:
		var tag: String = "color"
		var color: String = "faf887"
		if is_typo:
			color = "f16a6a"
		if letter == " ":
			tag = "bgcolor"
		return "[%s=#%s]%s[/%s]" % [tag, color, letter, tag]
		
	if typo == "":
		current_letter_rt = show_rt.call(description.substr(len, 1))
	else:
		current_letter_rt = show_rt.call(typo, true)
	description_rich_label.text = "[color=#92d291]%s[/color]%s%s" % [correct, current_letter_rt, rest]

func load() -> void:
	if node.has_meta("image"):
		image_texturerect.texture = node.get_meta("image")
	description_rich_label.text = node.get_meta("description")

func set_habit(habit: Dictionary, typing: bool = false) -> void:
	set_meta("description", habit.description.to_upper())
	set_meta("image", habit.image_resource)
	set_meta("is_healthy", habit.is_healthy)
	set_meta("typing", typing)
	panel.mouse_default_cursor_shape = Control.CURSOR_ARROW
	self.load()

func set_hovering_positive() -> void:
	$Panel.remove_theme_stylebox_override("panel")
	$Panel.add_theme_stylebox_override("panel", positive_stylebox)

func set_hovering_negative() -> void:
	$Panel.remove_theme_stylebox_override("panel")
	$Panel.add_theme_stylebox_override("panel", negative_stylebox)

func set_hovering_reset() -> void:
	$Panel.remove_theme_stylebox_override("panel")
	$Panel.add_theme_stylebox_override("panel", neutral_stylebox)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.load()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and _is_holding:
		cancel_drag()
		return

	if draggable and not _is_immovable and _is_hovering and event is InputEventMouse:
		var was_holding = _is_holding
		is_holding(event)

		if was_holding and not _is_holding:
			emit_signal("put_down")
		if not was_holding and _is_holding:
			emit_signal("put_up")

		if not was_holding and _is_holding:
			_mouse_down_position = event.position
			_node_down_position = node.position
			_node_anchor_position = event.position
			node.set_position(_node_down_position*_scale + _node_anchor_position*(1-_scale))
		elif _is_holding:
			var delta: Vector2 = (event.position - _mouse_down_position)
			node.set_position(_node_down_position*_scale + _node_anchor_position*(1-_scale) + delta)
		elif was_holding and not _is_holding:
			node.set_position(_node_down_position)

func is_holding(event: InputEventMouse) -> bool:
	if not draggable:
		return false
	var is_mouse_down: bool = event.button_mask&1 == 1
	var is_down_mask: int = 1
	var was_up_mask: int = 2
	var is_down: bool = _mouse_status&is_down_mask != 0
	var was_up: bool = _mouse_status&was_up_mask != 0
	if down_and_drag:
		if is_mouse_down and not is_down:
			if _is_hovering:
				_is_holding = true
			_mouse_status |= is_down_mask
		elif not is_mouse_down and is_down:
			_is_holding = false
			_mouse_status &= ~is_down_mask
	else:
		if not is_down and not was_up and is_mouse_down:
			_mouse_status |= is_down_mask
		elif is_down and not was_up and not is_mouse_down:
			if _is_hovering:
				_mouse_status &= ~is_down_mask
				_mouse_status |= was_up_mask
				_is_holding = true
			else:
				_mouse_status = 0
		elif not is_down and was_up and is_mouse_down:
			_mouse_status |= is_down_mask
		elif is_down and was_up and not is_mouse_down:
			_mouse_status = 0
			_is_holding = false
	return _is_holding

func cancel_drag() -> void:
	_is_holding = false
	_mouse_status = 0
	_scale = 1
	node.set_position(_node_down_position)
	emit_signal("put_down")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	node.scale = Vector2(_scale, _scale)

func is_over_panel(p: PanelContainer) -> bool:
	if _is_immovable:
		panel.mouse_default_cursor_shape = Control.CURSOR_ARROW
		return $Panel.get_global_rect().intersects(p.get_global_rect(), true)
	var is_over: bool = $Panel.get_global_rect().intersects(p.get_global_rect(), true)
	if is_over:
		panel.mouse_default_cursor_shape = Control.CURSOR_CAN_DROP
	else:
		panel.mouse_default_cursor_shape = Control.CURSOR_MOVE
	return is_over

func _on_mouse_entered() -> void:
	_is_hovering = true


func _on_mouse_exited() -> void:
	if not _is_holding:
		_is_hovering = false


func _on_put_down() -> void:
	_scale = 1
	make_immovable()


func _on_put_up() -> void:
	_scale = 1.2

func make_immovable() -> void:
	_is_immovable = true
	panel.mouse_default_cursor_shape = Control.CURSOR_ARROW

func make_movable() -> void:
	_is_immovable = false
	panel.mouse_default_cursor_shape = Control.CURSOR_MOVE
