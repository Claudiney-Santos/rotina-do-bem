extends Control

signal finished_answer
signal dead_key_mistake

@onready var habit_node: Habit = $VBoxContainer/Habit
@onready var rich_text: RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel
@onready var line_edit: LineEdit = $VBoxContainer/PanelContainer/LineEdit
@onready var correct_panel: PanelContainer = $CorrectPanelContainer
@onready var timer: Timer = $Timer

var written_len: int = 0
var habit_description: String = ""
var dead_key_mistake_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_habit = GameManager.selected_habits[GameManager.current_round]
	habit_node.set_habit(current_habit, true)
	habit_node.update_correct_typing(0)
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
		dead_key_mistake_counter = 0
	else:
		var mistake: Mistakes.TypingMistake = Mistakes.TypingMistake.new(habit_description, written_len, GameManager.selected_difficulty, GameManager.current_round)
		GameManager.mistakes.add_typing_mistake(mistake)
		if answer[len(answer)-1] == remove_accents(habit_description)[len(answer)-1]:
			dead_key_mistake_counter += 1
		if dead_key_mistake_counter >= 3:
			emit_signal("dead_key_mistake")
		habit_node.update_correct_typing(written_len, answer[written_len])
		timer.start()
	line_edit.text = habit_description.substr(0, written_len)
	line_edit.caret_column = written_len
	if len(habit_description) == written_len:
		emit_signal("finished_answer")

## Removes common Western/Latin accents/diacritics from a string.
func remove_accents(text: String) -> String:
	var accented   = "àáâãäåçèéêëìíîïñòóôõöùúûüýÿÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝ"
	var unaccented = "aaaaaaceeeeiiiinooooouuuuyyAAAAAACEEEEIIIINOOOOOUUUUY"
	
	for i in range(accented.length()):
		text = text.replace(accented[i], unaccented[i])
		
	return text

func _on_finished_answer() -> void:
	correct_panel.show()


func _on_continue_button_pressed() -> void:
	GameManager.current_round += 1
	if GameManager.current_round == len(GameManager.selected_habits):
		if not GameManager.unlock_next_level() and GameManager.selected_difficulty == GameManager.Difficulty.HARD:
			get_tree().change_scene_to_file("res://scenes/report.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/difficulty.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/classify-gameplay.tscn")


func _on_dead_key_mistake() -> void:
	print("dead key mistake!")


func _on_timer_timeout() -> void:
	habit_node.update_correct_typing(written_len)
