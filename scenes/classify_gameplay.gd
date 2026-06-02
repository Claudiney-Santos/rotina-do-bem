extends Control

signal player_choose_right
signal player_choose_wrong

@onready var habit_node: Habit = $Habit
@onready var negative_vbox = $NegativePanel/VBoxContainer/NegativeVBoxContainer
@onready var positive_vbox = $PositivePanel/VBoxContainer/PositiveVBoxContainer
@onready var habit_panel = $NegativePanel/VBoxContainer/NegativeVBoxContainer/HabitPanel
@onready var wrong_panel = $WrongPanelContainer
@onready var correct_panel = $CorrectPanelContainer

func reset_vboxes() -> void:
	for child in negative_vbox.get_children():
		negative_vbox.remove_child(child)
	for child in positive_vbox.get_children():
		positive_vbox.remove_child(child)
	var selected_habits: Array = GameManager.selected_habits
	var selected_healthy_habits: Array = []
	var selected_unhealthy_habits: Array = []

	for i in range(GameManager.current_round):
		if selected_habits[i].is_healthy:
			selected_healthy_habits.push_back(selected_habits[i])
		else:
			selected_unhealthy_habits.push_back(selected_habits[i])

	for i in range(len(selected_habits)/2):
		var healthy_habit_panel = habit_panel.duplicate()
		if len(selected_healthy_habits) > 0:
			var healthy_image: TextureRect = healthy_habit_panel.get_child(0)
			healthy_image.texture = selected_healthy_habits.pop_front().image_resource
		positive_vbox.add_child(healthy_habit_panel)
		var unhealthy_habit_panel = habit_panel.duplicate()
		if len(selected_unhealthy_habits) > 0:
			var unhealthy_image: TextureRect = unhealthy_habit_panel.get_child(0)
			unhealthy_image.texture = selected_unhealthy_habits.pop_front().image_resource
		negative_vbox.add_child(unhealthy_habit_panel)
		healthy_habit_panel.show()
		unhealthy_habit_panel.show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_habit = GameManager.selected_habits[GameManager.current_round]
	habit_node.set_habit(current_habit)
	var qnt_half_habits = len(GameManager.selected_habits)/2
	if qnt_half_habits != negative_vbox.get_child_count():
		reset_vboxes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if habit_node.is_over_panel($NegativePanel):
		habit_node.set_hovering_negative()
	elif habit_node.is_over_panel($PositivePanel):
		habit_node.set_hovering_positive()
	else:
		habit_node.set_hovering_reset()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty.tscn")


func _on_habit_put_down() -> void:
	var current_habit = GameManager.selected_habits[GameManager.current_round]
	var choose_negative: bool = habit_node.is_over_panel($NegativePanel)
	var choose_positive: bool = habit_node.is_over_panel($PositivePanel)
	if choose_negative:
		print("escolheu negativo")
	if choose_positive:
		print("escolheu positivo")
	if (choose_negative && !current_habit.is_healthy) || (choose_positive && current_habit.is_healthy):
		emit_signal("player_choose_right")
	elif choose_negative || choose_positive:
		emit_signal("player_choose_wrong")


func _on_player_choose_right() -> void:
	correct_panel.show()
	print("Jogador acertou")


func _on_player_choose_wrong() -> void:
	wrong_panel.show()
	print("Jogador errou")


func _on_try_again_button_pressed() -> void:
	wrong_panel.hide()


func _on_continue_button_pressed() -> void:
	correct_panel.hide()
	get_tree().change_scene_to_file("res://scenes/type-gameplay.tscn")
