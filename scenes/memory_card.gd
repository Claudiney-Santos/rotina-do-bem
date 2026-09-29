extends Control

signal reveal_card
signal conceal_card

const MAX_DESCRIPTION_FONT_SIZE: int = 40
const MIN_DESCRIPTION_FONT_SIZE: int = 24
const DESCRIPTION_TEXT_WIDTH: float = 194.0

@onready var node: Control = $"."
@onready var panel = $Panel
@onready var description_rich_label = $Panel/LabelScrollContainer/RichTextLabel
@onready var image_texturerect = $Panel/TextureScrollContainer/TextureRect

var _is_revealed = false

var is_image: bool:
	get:
		return get_meta("is_image")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.load()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load() -> void:
	if node.has_meta("image"):
		image_texturerect.texture = node.get_meta("image")
	description_rich_label.text = node.get_meta("description")
	image_texturerect.visible = false
	description_rich_label.visible = false

func set_habit(habit: Dictionary, is_image: bool = false) -> void:
	set_meta("description", habit.description.to_upper())
	set_meta("image", habit.image_resource)
	set_meta("is_healthy", habit.is_healthy)
	set_meta("is_image", is_image)
	self.load()
	_fit_description_font()

func _fit_description_font() -> void:
	var font: Font = description_rich_label.get_theme_font("normal_font")
	var words: PackedStringArray = description_rich_label.text.split(" ")
	for size in range(MAX_DESCRIPTION_FONT_SIZE, MIN_DESCRIPTION_FONT_SIZE - 1, -1):
		var fits: bool = true
		for word in words:
			if font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > DESCRIPTION_TEXT_WIDTH:
				fits = false
				break
		if fits:
			description_rich_label.add_theme_font_size_override("normal_font_size", size)
			return
	description_rich_label.add_theme_font_size_override("normal_font_size", MIN_DESCRIPTION_FONT_SIZE)

func conceal() -> void:
	if _is_revealed:
		emit_signal("conceal_card")
		_is_revealed = false
	panel.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	image_texturerect.visible = false
	description_rich_label.visible = false
	var theme: StyleBox = panel.get_theme_stylebox("panel").duplicate()
	theme.bg_color = Color("#69a0ba")
	theme.border_color = theme.bg_color
	panel.add_theme_stylebox_override("panel", theme)

func reveal(colorize: bool = false, signalize: bool = true) -> void:
	if not _is_revealed:
		if signalize:
			emit_signal("reveal_card")
		_is_revealed = true
	if is_image:
		image_texturerect.visible = true
		description_rich_label.visible = false
	else:
		image_texturerect.visible = false
		description_rich_label.visible = true
	panel.mouse_default_cursor_shape = CURSOR_ARROW
	var color: String = "#69a0ba"
	if colorize:
		color = String.num_int64(hash([get_meta("description"), get_meta("image")]) & 0xFFFFFF, 16)
	elif _is_revealed:
		color = "#92d291"
	var theme: StyleBox = panel.get_theme_stylebox("panel").duplicate()
	theme.bg_color = Color(color)
	theme.border_color = theme.bg_color
	panel.add_theme_stylebox_override("panel", theme)

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_pressed() and not _is_revealed:
		reveal(true)

func equals(card: Node) -> bool:
	if !card.has_meta("image") or !card.has_meta("description") \
		or !card.has_meta("is_revealed"):
			return false
	return get_meta("image") == card.get_meta("image") and \
		get_meta("description") == card.get_meta("description")
	


func _on_conceal_card() -> void:
	pass


func _on_reveal_card() -> void:
	pass
