extends Node

enum Difficulty { EASY, MEDIUM, HARD }

const qnt_half_habits = {
	Difficulty.EASY: 2,
	Difficulty.MEDIUM: 3,
	Difficulty.HARD: 4,
}

var selected_difficulty: Difficulty = Difficulty.MEDIUM
var _unlocked_level: Difficulty = Difficulty.EASY

var unlocked_level: Difficulty:
	get: return _unlocked_level

var selected_habits: Array = []
var current_round: int = 0

var mistakes: Mistakes = Mistakes.new()

var mistakes_count: Dictionary[String, Dictionary]:
	get:
		var count: Dictionary[String, Dictionary] = {
			classify = {},
			typing = {}
		}
		for type in count:
			count[type][Difficulty.EASY] = 0
			count[type][Difficulty.MEDIUM] = 0
			count[type][Difficulty.HARD] = 0
		for cm in mistakes.classify_mistakes:
			count.classify[cm.difficulty] += 1
		for tm in mistakes.typing_mistakes:
			count.typing[tm.difficulty] += 1
		return count

func unlock_next_level() -> bool:
	match _unlocked_level:
		Difficulty.EASY:
			_unlocked_level = Difficulty.MEDIUM
			return true
		Difficulty.MEDIUM:
			_unlocked_level = Difficulty.HARD
			return true
		Difficulty.HARD:
			_unlocked_level = Difficulty.HARD
			return false
	return false

func load_game(difficulty: Difficulty) -> void:
	current_round = 0
	selected_difficulty = difficulty
	var diff: String = ""
	match difficulty:
		Difficulty.EASY:
			diff = "easy"
		Difficulty.MEDIUM:
			diff = "medium"
		Difficulty.HARD:
			diff = "hard"
	var qnt_half_habits: int = qnt_half_habits[difficulty]
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
