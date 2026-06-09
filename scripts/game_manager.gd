extends Node

enum Difficulty { EASY, MEDIUM, HARD }

var selected_difficulty: Difficulty = Difficulty.MEDIUM
var _unlocked_level: Difficulty = Difficulty.EASY

var unlocked_level: Difficulty:
	get: return _unlocked_level

var selected_habits: Array = []
var current_round: int = 0

func unlock_next_level() -> void:
	match _unlocked_level:
		Difficulty.EASY:
			_unlocked_level = Difficulty.MEDIUM
		Difficulty.MEDIUM:
			_unlocked_level = Difficulty.HARD
		Difficulty.HARD:
			_unlocked_level = Difficulty.HARD

func load_game(difficulty: Difficulty) -> void:
	current_round = 0
	selected_difficulty = difficulty
	var qnt_half_habits: int = 0
	var diff: String = ""
	match difficulty:
		Difficulty.EASY:
			diff = "easy"
			qnt_half_habits = 2
		Difficulty.MEDIUM:
			diff = "medium"
			qnt_half_habits = 3
		Difficulty.HARD:
			diff = "hard"
			qnt_half_habits = 4
	var healthy_habits: Array = Database.data[diff].healthy.duplicate()
	var unhealthy_habits: Array = Database.data[diff].unhealthy.duplicate()
	if len(healthy_habits) < qnt_half_habits:
		push_error("Expected at least %d healthy habits, but there are only %d" % [qnt_half_habits, len(healthy_habits)])
	if len(unhealthy_habits) < qnt_half_habits:
		push_error("Expected at least %d unhealthy habits, but there are only %d" % [qnt_half_habits, len(unhealthy_habits)])
	healthy_habits.shuffle()
	unhealthy_habits.shuffle()
	selected_habits = []
	for i in range(qnt_half_habits):
		var healthy: Dictionary = healthy_habits.pop_back()
		healthy.set("is_healthy", true)
		selected_habits.push_back(healthy)
		var unhealthy: Dictionary = unhealthy_habits.pop_back()
		unhealthy.set("is_healthy", false)
		selected_habits.push_back(unhealthy)
	selected_habits.shuffle()
