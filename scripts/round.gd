extends RefCounted

class_name Round

var word: String = ""

var mistakes: Mistakes = Mistakes.new()

func _init(word: String) -> void:
	self.word = word

func push_classify_mistake(cm: Mistakes.ClassifyMistake) -> void:
	mistakes.add_classify_mistake(cm)
	
func push_typing_mistake(tm: Mistakes.TypingMistake) -> void:
	mistakes.add_typing_mistake(tm)

func push_quiz_mistake(qm: Mistakes.QuizMistake) -> void:
	mistakes.add_quiz_mistake(qm)

func clear_quiz_mistakes() -> void:
	mistakes.reset_quiz()
