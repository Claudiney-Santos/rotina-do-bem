extends Control

signal finished_answer

@onready var habit_node: Habit = $VBoxContainer/Habit
@onready var rich_text: RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel
@onready var line_edit: LineEdit = $VBoxContainer/PanelContainer/LineEdit
@onready var correct_panel: PanelContainer = $CorrectPanelContainer

var written_len: int = 0
var habit_description: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_habit = GameManager.selected_habits[GameManager.current_round]
	habit_node.set_habit(current_habit, true)
	habit_description = current_habit.description.to_upper().strip_edges()
	rich_text.text = habit_description
	line_edit.grab_focus(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty.tscn")


func _on_line_edit_text_changed(new_text: String) -> void:
	var answer: String = new_text.to_upper().strip_edges(true, false)
	if habit_description.find(answer) == 0 and len(answer) > written_len:
		written_len = len(answer)
		habit_node.update_correct_typing(written_len)
		print(answer)
	line_edit.text = habit_description.substr(0, written_len)
	line_edit.caret_column = written_len
	if len(habit_description) == written_len:
		emit_signal("finished_answer")


func _on_finished_answer() -> void:
	correct_panel.show()


func _on_continue_button_pressed() -> void:
	GameManager.current_round += 1
	if GameManager.current_round == len(GameManager.selected_habits):
		GameManager.unlock_next_level()
		get_tree().change_scene_to_file("res://scenes/difficulty.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")
