extends Node

enum Difficulty { EASY, MEDIUM, HARD }

const qnt_half_habits = {
	Difficulty.EASY: 2,
	Difficulty.MEDIUM: 3,
	Difficulty.HARD: 4,
}

var selected_difficulty: Difficulty = Difficulty.MEDIUM
var _completed_level: int = 0

var completed_level: int:
	get: return _completed_level

var selected_habits: Array = []
var current_round_index: int:
	get:
		return len(rounds[selected_difficulty])-1
var current_round: Round:
	get:
		return rounds[selected_difficulty][current_round_index]

var rounds: Dictionary[Difficulty, Array] = {
	Difficulty.EASY: [],
	Difficulty.MEDIUM: [],
	Difficulty.HARD: [],
}

func new_round(word: String) -> void:
	rounds[selected_difficulty].push_back(Round.new(word))

func reset_rounds(diff: Difficulty) -> void:
	rounds[diff] = []

var score: Dictionary[String, Dictionary]:
	get:
		var count: Dictionary[String, Dictionary] = {
			classify = {},
			typing = {}
		}
		for type in count:
			count[type][Difficulty.EASY] = {
				total = 0,
				mistakes = 0,
			}
			count[type][Difficulty.MEDIUM] = {
				total = 0,
				mistakes = 0,
			}
			count[type][Difficulty.HARD] = {
				total = 0,
				mistakes = 0,
			}
		var score: Dictionary[String, Dictionary] = {
			classify = {
				Difficulty.EASY: 0.0,
				Difficulty.MEDIUM: 0.0,
				Difficulty.HARD: 0.0,
			},
			typing = {
				Difficulty.EASY: 0.0,
				Difficulty.MEDIUM: 0.0,
				Difficulty.HARD: 0.0,
			},
		}
		for diff in [Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD]:
			count.classify[diff].total = 2*qnt_half_habits[diff]
			for round in rounds[diff]:
				count.typing[diff].total += len(round.word)
				for cm in round.mistakes.classify:
					count.classify[cm.difficulty].mistakes += 1
				for tm in round.mistakes.typing:
					count.typing[tm.difficulty].mistakes += 1
			score.classify[diff] = ((count.classify[diff].total - count.classify[diff].mistakes) as float)/(count.classify[diff].total as float)
			score.typing[diff] = (count.typing[diff].total - count.typing[diff].mistakes as float)/(count.typing[diff].total as float)
		var completed_levels: int = 0
		if completed_level < 3:
			score.classify[Difficulty.HARD] = 0
			if completed_level < 2:
				score.classify[Difficulty.MEDIUM] = 0
				if completed_level < 1:
					score.classify[Difficulty.EASY] = 0
		return score

func unlock_next_level() -> bool:
	match _completed_level:
		0:
			_completed_level = 1
			return true
		1:
			_completed_level = 2
			return true
		2:
			_completed_level = 3
			return false
	return false

func load_game(difficulty: Difficulty) -> void:
	selected_difficulty = difficulty
	rounds[selected_difficulty] = []
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
