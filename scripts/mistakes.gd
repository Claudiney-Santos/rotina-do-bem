extends RefCounted

class_name Mistakes

var _classify_mistakes: Array[ClassifyMistake] = []
var _typing_mistakes: Array[TypingMistake] = []

var classify_mistakes: Array[ClassifyMistake]:
	get:
		return _classify_mistakes.duplicate_deep()
var typing_mistakes: Array[TypingMistake]:
	get:
		return _typing_mistakes.duplicate_deep()

func add_classify_mistake(cm: ClassifyMistake) -> void:
	_classify_mistakes.push_back(cm)
	
func add_typing_mistake(tm: TypingMistake) -> void:
	_typing_mistakes.push_back(tm)

func reset() -> void:
	_classify_mistakes = []
	_typing_mistakes = []

func reset_difficulty(difficulty: GameManager.Difficulty) -> void:
	var fn = func(m):
		return m.difficulty != difficulty
	_classify_mistakes = _classify_mistakes.filter(fn)
	_typing_mistakes = _typing_mistakes.filter(fn)

class ClassifyMistake:
	var word: String = ""
	var difficulty: GameManager.Difficulty = GameManager.Difficulty.EASY
	var round: int = 0

	func _init(word: String, difficulty: GameManager.Difficulty, round: int):
		self.word = word
		self.difficulty = difficulty
		self.round = round

class TypingMistake:
	var word: String = ""
	var difficulty: GameManager.Difficulty = GameManager.Difficulty.EASY
	var position: int = 0
	var round: int = 0

	var has_accent: bool:
		get:
			var character: String = word[position]
			var is_any_letter: bool = RegEx.create_from_string("^\\p{L}$").search(character) != null
			var is_basic_ascii: bool = RegEx.create_from_string("^[a-zA-Z]$").search(character) != null
			return is_any_letter and not is_basic_ascii

	func _init(word: String, position: int, difficulty: GameManager.Difficulty, round: int):
		self.word = word
		self.position = position
		self.difficulty = difficulty
		self.round = round
