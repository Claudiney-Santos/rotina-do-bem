extends Node

enum Difficulty { EASY, MEDIUM, HARD }

const qnt_half_habits = {
	Difficulty.EASY: 2,
	Difficulty.MEDIUM: 3,
	Difficulty.HARD: 4,
}

var selected_difficulty: Difficulty = Difficulty.EASY
var _completed_level: int = 0
var _completed_activity: int = 0

var completed_level: int:
	get: return _completed_level
	
var completed_activity: int:
	get: return _completed_activity

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

var memory_mistakes: Dictionary[Difficulty, Array] = {
	Difficulty.EASY: [],
	Difficulty.MEDIUM: [],
	Difficulty.HARD: [],
}

func new_round(word: String) -> void:
	rounds[selected_difficulty].push_back(Round.new(word))

func reset_rounds(diff: Difficulty) -> void:
	rounds[diff] = []

func push_memory_mistake(m: Mistakes.MemoryMistake) -> void:
	memory_mistakes[selected_difficulty].push_back(m)

func push_quiz_mistake(qm: Mistakes.QuizMistake) -> void:
	var diff_rounds: Array = rounds[selected_difficulty]
	if qm.round < len(diff_rounds):
		diff_rounds[qm.round].push_quiz_mistake(qm)

func reset_quiz_mistakes(diff: Difficulty) -> void:
	for round in rounds[diff]:
		round.clear_quiz_mistakes()

func _build_counts() -> Dictionary[String, Dictionary]:
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
	for diff in [Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD]:
		count.classify[diff].total = 2*qnt_half_habits[diff]
		for round in rounds[diff]:
			count.typing[diff].total += len(round.word)
			for cm in round.mistakes.classify_mistakes:
				count.classify[cm.difficulty].mistakes += 1
			for tm in round.mistakes.typing_mistakes:
				count.typing[tm.difficulty].mistakes += 1
	return count

var mistake_counts: Dictionary[String, Dictionary]:
	get:
		return _build_counts()

var play_times: Dictionary[String, Dictionary]:
	get:
		var times: Dictionary[String, Dictionary] = {
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
			for round in rounds[diff]:
				times.classify[diff] += round.classify_time_seconds
				times.typing[diff] += round.typing_time_seconds
		return times

func _memory_score(diff: Difficulty) -> float:
	var sessions: Array = memory_mistakes[diff]
	if len(sessions) == 0:
		return 0.0
	var latest: Mistakes.MemoryMistake = sessions.back()
	var total_pairs: int = 2*qnt_half_habits[diff]
	return maxf(0.0, 1.0 - float(latest.wrong_matches)/float(2*total_pairs))

func _quiz_score(diff: Difficulty) -> float:
	var answered: int = 0
	var extra_attempts: int = 0
	for round in rounds[diff]:
		for qm in round.mistakes.quiz_mistakes:
			answered += 1
			extra_attempts += qm.attempts - 1
	if answered == 0:
		return 0.0
	return (2.0*answered - extra_attempts)/(2.0*answered)

var score: Dictionary[String, Dictionary]:
	get:
		var count: Dictionary[String, Dictionary] = _build_counts()
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
			memory = {
				Difficulty.EASY: 0.0,
				Difficulty.MEDIUM: 0.0,
				Difficulty.HARD: 0.0,
			},
			quiz = {
				Difficulty.EASY: 0.0,
				Difficulty.MEDIUM: 0.0,
				Difficulty.HARD: 0.0,
			},
		}
		for diff in [Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD]:
			if len(rounds[diff]) > 0:
				score.classify[diff] = ((count.classify[diff].total - count.classify[diff].mistakes) as float)/(count.classify[diff].total as float)
				if count.typing[diff].total > 0:
					score.typing[diff] = (count.typing[diff].total - count.typing[diff].mistakes as float)/(count.typing[diff].total as float)
			score.memory[diff] = _memory_score(diff)
			score.quiz[diff] = _quiz_score(diff)
		return score

func unlock_next_activity() -> bool:
	if _completed_level >= 3:
		return false

	_completed_activity += 1

	if _completed_activity >= 3:
		_completed_activity = 0
		match selected_difficulty:
			Difficulty.EASY:
				_completed_level = 1
			Difficulty.MEDIUM:
				_completed_level = 2
			Difficulty.HARD:
				_completed_level = 3

	if _completed_level >= 3:
		_completed_level = 3
		_completed_activity = 3
		return false

	return true

func load_game(difficulty: Difficulty) -> void:
	load_habits(difficulty)
	rounds[selected_difficulty] = []
	memory_mistakes[selected_difficulty] = []

func load_habits(difficulty: Difficulty) -> void:
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
