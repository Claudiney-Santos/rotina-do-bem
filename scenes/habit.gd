extends Control

@onready var node = $"."
@onready var description_label = $Panel/VBoxContainer/Label
@onready var image_texturerect = $Panel/VBoxContainer/ScrollContainer/TextureRect

var draggable = false
var down_and_drag = false

var _mouse_down_position: Vector2
var _node_down_position: Vector2
var _node_anchor_position: Vector2
var _mouse_status: int = 0
var _is_holding: bool = false
var _is_hovering: bool = false
var _scale: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	description_label.text = node.get_meta("description")
	image_texturerect.texture = node.get_meta("image")
	draggable = not node.get_meta("typing")
	down_and_drag = node.get_meta("down_and_drag") and draggable

func _input(event: InputEvent) -> void:
	if draggable and event is InputEventMouse:
		var was_holding = _is_holding
		is_holding(event)
		
		if was_holding != _is_holding:
			if down_and_drag:
				print("Segura e arrasta")
			else:
				print("Clica e solta, então arrasta")
		
		if was_holding and not _is_holding:
			print("soltou")
		if not was_holding and _is_holding:
			print("segurou")
		
		if not was_holding and _is_holding:
			_mouse_down_position = event.position
			_node_down_position = node.position
			_node_anchor_position = event.position
			_scale = 1.2
			node.set_position(_node_down_position*_scale + _node_anchor_position*(1-_scale))
		elif _is_holding:
			var delta: Vector2 = (event.position - _mouse_down_position)
			node.set_position(_node_down_position*_scale + _node_anchor_position*(1-_scale) + delta)
		elif was_holding and not _is_holding:
			node.set_position(_node_down_position)
			_scale = 1

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
			_is_holding = true
			_mouse_status ^= is_down_mask
		elif not is_mouse_down and is_down:
			_is_holding = false
			_mouse_status ^= is_down_mask
	else:
		if not is_down and not was_up and is_mouse_down:
			_mouse_status ^= is_down_mask
		elif is_down and not was_up and not is_mouse_down:
			_mouse_status ^= is_down_mask | was_up_mask
			_is_holding = true
		elif not is_down and was_up and is_mouse_down:
			_mouse_status ^= is_down_mask
		elif is_down and was_up and not is_mouse_down:
			_mouse_status = 0
			_is_holding = false
	return _is_holding

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	node.scale = Vector2(_scale, _scale)
