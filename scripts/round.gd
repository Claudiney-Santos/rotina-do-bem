extends RefCounted

class_name Round

var word: String = ""

var mistakes: Dictionary[String, Array] = {
	classify = [],
	typing = [],
}

func _init(word: String) -> void:
	self.word = word

func push_classify_mistake(cm: Mistakes.ClassifyMistake) -> void:
	mistakes.classify.push_back(cm)
	
func push_typing_mistake(tm: Mistakes.TypingMistake) -> void:
	mistakes.typing.push_back(tm)
