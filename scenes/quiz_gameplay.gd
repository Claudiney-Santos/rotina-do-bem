extends Control

@onready var habit_node: Habit = $Habit
@onready var buttons: Array[Button] = [
	$VBoxContainer/Button,
	$VBoxContainer/Button2,
	$VBoxContainer/Button3
]
@onready var wrong_panel: PanelContainer = $WrongPanelContainer

var _habits: Array[Dictionary] = []
var _healthy_habits: Array[Dictionary] = []
var _unhealthy_habits: Array[Dictionary] = []
var _options: Array[Dictionary] = []
var _habit = null
var _current_round: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for habit in GameManager.selected_habits:
		if habit.get("is_healthy"):
			_healthy_habits.push_back(habit)
		else:
			_unhealthy_habits.push_back(habit)
	load_current_round()

func load_current_round() -> void:
	wrong_panel.hide()
	for button in buttons:
		button.disabled = false
	_habit = GameManager.selected_habits[_current_round]
	habit_node.set_habit(_habit, true)
	_options = [_habit]
	if _habit.get("is_healthy"):
		_unhealthy_habits.shuffle()
		_options.push_back(_unhealthy_habits[0])
		_options.push_back(_unhealthy_habits[1])
	else:
		_healthy_habits.shuffle()
		_options.push_back(_healthy_habits[0])
		_options.push_back(_healthy_habits[1])
	_options.shuffle()
	for i in range(len(_options)):
		buttons[i].text = _options[i].get("explanation").to_upper()

func load_next_round() -> void:
	_current_round += 1
	if _current_round == len(GameManager.selected_habits):
		if GameManager.completed_activity == 2:
			GameManager.unlock_next_activity()
			get_tree().change_scene_to_file("res://scenes/difficulty.tscn")
	else:
		load_current_round()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty.tscn")


func _on_quiz_answer(answer: int) -> void:
	if _options[answer] == GameManager.selected_habits[_current_round]:
		load_next_round()
	else:
		buttons[answer].disabled = true
		wrong_panel.show()


func _on_try_again_button_pressed() -> void:
	wrong_panel.hide()
