extends Control

@onready var easy_classify_stars: Label = %EasyClassifyStars
@onready var easy_typing_stars: Label = %EasyTypingStars
@onready var medium_classify_stars: Label = %MediumClassifyStars
@onready var medium_typing_stars: Label = %MediumTypingStars
@onready var hard_classify_stars: Label = %HardClassifyStars
@onready var hard_typing_stars: Label = %HardTypingStars

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var score: Dictionary[String, Dictionary] = GameManager.score
	for diff in [GameManager.Difficulty.EASY, GameManager.Difficulty.MEDIUM, GameManager.Difficulty.HARD]:
		set_stars(floorf(5*score.classify[diff]), diff, false)
		set_stars(floorf(5*score.typing[diff]), diff, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_stars(number: int, difficulty: GameManager.Difficulty, is_typing: bool = false) -> void:
	const star_limit: int = 5
	const full_star: String = "★"
	const empty_star: String = "☆"
	if number > star_limit:
		number = star_limit
	elif number < 0:
		number = 0
	var label: Label
	match difficulty:
		GameManager.Difficulty.EASY:
			if is_typing:
				label = easy_typing_stars
			else:
				label = easy_classify_stars
		GameManager.Difficulty.MEDIUM:
			if is_typing:
				label = medium_typing_stars
			else:
				label = medium_classify_stars
		GameManager.Difficulty.HARD:
			if is_typing:
				label = hard_typing_stars
			else:
				label = hard_classify_stars
	label.text = full_star.repeat(number) + empty_star.repeat(star_limit - number)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
