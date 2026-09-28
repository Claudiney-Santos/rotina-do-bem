extends Control

@onready var easy_classify_stars: Label = %EasyClassifyStars
@onready var easy_typing_stars: Label = %EasyTypingStars
@onready var medium_classify_stars: Label = %MediumClassifyStars
@onready var medium_typing_stars: Label = %MediumTypingStars
@onready var hard_classify_stars: Label = %HardClassifyStars
@onready var hard_typing_stars: Label = %HardTypingStars
@onready var easy_classify_info: Label = %EasyClassifyInfo
@onready var easy_typing_info: Label = %EasyTypingInfo
@onready var easy_memory_stars: Label = %EasyMemoryStars
@onready var easy_memory_info: Label = %EasyMemoryInfo
@onready var easy_quiz_stars: Label = %EasyQuizStars
@onready var easy_quiz_info: Label = %EasyQuizInfo
@onready var medium_classify_info: Label = %MediumClassifyInfo
@onready var medium_typing_info: Label = %MediumTypingInfo
@onready var medium_memory_stars: Label = %MediumMemoryStars
@onready var medium_memory_info: Label = %MediumMemoryInfo
@onready var medium_quiz_stars: Label = %MediumQuizStars
@onready var medium_quiz_info: Label = %MediumQuizInfo
@onready var hard_classify_info: Label = %HardClassifyInfo
@onready var hard_typing_info: Label = %HardTypingInfo
@onready var hard_memory_stars: Label = %HardMemoryStars
@onready var hard_memory_info: Label = %HardMemoryInfo
@onready var hard_quiz_stars: Label = %HardQuizStars
@onready var hard_quiz_info: Label = %HardQuizInfo

const star_limit: int = 5
const full_star: String = "★"
const empty_star: String = "☆"
const no_data: String = "—"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var classify_stars: Array[Label] = [easy_classify_stars, medium_classify_stars, hard_classify_stars]
	var typing_stars: Array[Label] = [easy_typing_stars, medium_typing_stars, hard_typing_stars]
	var memory_stars: Array[Label] = [easy_memory_stars, medium_memory_stars, hard_memory_stars]
	var quiz_stars: Array[Label] = [easy_quiz_stars, medium_quiz_stars, hard_quiz_stars]
	var classify_info: Array[Label] = [easy_classify_info, medium_classify_info, hard_classify_info]
	var typing_info: Array[Label] = [easy_typing_info, medium_typing_info, hard_typing_info]
	var memory_info: Array[Label] = [easy_memory_info, medium_memory_info, hard_memory_info]
	var quiz_info: Array[Label] = [easy_quiz_info, medium_quiz_info, hard_quiz_info]
	var score: Dictionary[String, Dictionary] = GameManager.score
	var counts: Dictionary[String, Dictionary] = GameManager.mistake_counts
	for diff in [GameManager.Difficulty.EASY, GameManager.Difficulty.MEDIUM, GameManager.Difficulty.HARD]:
		var i: int = int(diff)
		var has_rounds: bool = len(GameManager.rounds[diff]) > 0
		set_stars(classify_stars[i], floorf(5*score.classify[diff]))
		set_stars(typing_stars[i], floorf(5*score.typing[diff]))
		set_stars(memory_stars[i], floorf(5*score.memory[diff]))
		set_stars(quiz_stars[i], floorf(5*score.quiz[diff]))
		classify_info[i].text = mistake_info(counts.classify[diff].mistakes, has_rounds)
		typing_info[i].text = mistake_info(counts.typing[diff].mistakes, has_rounds)
		memory_info[i].text = memory_info_text(diff)
		quiz_info[i].text = quiz_info_text(diff)

func set_stars(label: Label, number: int) -> void:
	label.text = star_text(number)

func star_text(number: int) -> String:
	var clamped: int = clampi(number, 0, star_limit)
	return full_star.repeat(clamped) + empty_star.repeat(star_limit - clamped)

func mistake_info(mistakes: int, has_data: bool) -> String:
	if not has_data:
		return no_data
	return "ERROS: %d" % mistakes

func memory_info_text(diff: GameManager.Difficulty) -> String:
	var sessions: Array = GameManager.memory_mistakes[diff]
	if len(sessions) == 0:
		return no_data
	var latest: Mistakes.MemoryMistake = sessions.back()
	var minutes: int = int(latest.time_seconds) / 60
	var seconds: int = int(latest.time_seconds) % 60
	return "ERROS: %d • TEMPO: %02d:%02d" % [latest.wrong_matches, minutes, seconds]

func quiz_info_text(diff: GameManager.Difficulty) -> String:
	var first: int = 0
	var second: int = 0
	var last: int = 0
	for round in GameManager.rounds[diff]:
		for qm in round.mistakes.quiz_mistakes:
			match qm.attempts:
				1:
					first += 1
				2:
					second += 1
				_:
					last += 1
	if first + second + last == 0:
		return no_data
	return "1ª: %d • 2ª: %d • 3ª: %d" % [first, second, last]

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
