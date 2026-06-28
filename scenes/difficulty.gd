extends Control


@onready var medium_button: Button = $PanelContainer/ButtonsVBoxContainer/MediumButton
@onready var hard_button: Button = $PanelContainer/ButtonsVBoxContainer/HardButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Completo: %d" % GameManager.completed_level)
	match GameManager.completed_level:
		0:
			hard_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			medium_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			print("Fácil")
		1:
			hard_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			medium_button.disabled = false
			print("Médio")
		_:
			hard_button.disabled = false
			medium_button.disabled = false
			print("Difícil")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_easy_button_pressed() -> void:
	GameManager.load_game(GameManager.Difficulty.EASY)
	GameManager.reset_rounds(GameManager.selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")


func _on_medium_button_pressed() -> void:
	GameManager.load_game(GameManager.Difficulty.MEDIUM)
	GameManager.reset_rounds(GameManager.selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")


func _on_hard_button_pressed() -> void:
	GameManager.load_game(GameManager.Difficulty.HARD)
	GameManager.reset_rounds(GameManager.selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
