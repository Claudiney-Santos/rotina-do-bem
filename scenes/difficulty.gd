extends Control


@onready var easy_classify_button: Button = $%EasyClassifyButton
@onready var easy_memory_button: Button = $%EasyMemoryButton
@onready var easy_quiz_button: Button = $%EasyQuizButton
@onready var medium_classify_button: Button = $%MediumClassifyButton
@onready var medium_memory_button: Button = $%MediumMemoryButton
@onready var medium_quiz_button: Button = $%MediumQuizButton
@onready var hard_classify_button: Button = $%HardClassifyButton
@onready var hard_memory_button: Button = $%HardMemoryButton
@onready var hard_quiz_button: Button = $%HardQuizButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var btns: Array[Button] = [
		easy_classify_button, easy_memory_button, easy_quiz_button,
		medium_classify_button, medium_memory_button, medium_quiz_button,
		hard_classify_button, hard_memory_button, hard_quiz_button,
	]
	var activities = 1 + GameManager.completed_level*3 + GameManager.completed_activity
	for btn in btns.slice(0, activities):
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.disabled = false
	for btn in btns.slice(activities):
		btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
		btn.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_easy_classify_button_pressed() -> void:
	GameManager.load_game(GameManager.Difficulty.EASY)
	GameManager.reset_rounds(GameManager.selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")

func _on_easy_memory_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/memory-gameplay.tscn")
	pass

func _on_easy_quiz_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/quiz-gameplay.tscn")
	pass

func _on_medium_classify_button_pressed() -> void:
	GameManager.load_game(GameManager.Difficulty.MEDIUM)
	GameManager.reset_rounds(GameManager.selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")

func _on_medium_memory_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/memory-gameplay.tscn")
	pass

func _on_medium_quiz_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/quiz-gameplay.tscn")
	pass

func _on_hard_classify_button_pressed() -> void:
	GameManager.load_game(GameManager.Difficulty.HARD)
	GameManager.reset_rounds(GameManager.selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")

func _on_hard_memory_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/memory-gameplay.tscn")
	pass

func _on_hard_quiz_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/quiz-gameplay.tscn")
	pass
