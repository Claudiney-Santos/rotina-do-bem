extends Control

@onready var easy_classify_stars: Label = %EasyClassifyStars
@onready var easy_typing_stars: Label = %EasyTypingStars
@onready var medium_classify_stars: Label = %MediumClassifyStars
@onready var medium_typing_stars: Label = %MediumTypingStars
@onready var hard_classify_stars: Label = %HardClassifyStars
@onready var hard_typing_stars: Label = %HardTypingStars

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mistakes_count = GameManager.mistakes_count
	for diff in [GameManager.Difficulty.EASY, GameManager.Difficulty.MEDIUM, GameManager.Difficulty.HARD]:
		var qnt_habits: int = 2*GameManager.qnt_half_habits[diff];
		var wrong_typing: int = mistakes_count.typing[diff];
		var wrong_classify: int = mistakes_count.classify[diff];
		set_stars((5*(qnt_habits-wrong_classify))/qnt_habits, diff, false)
		set_stars((5*(qnt_habits-wrong_typing))/qnt_habits, diff, true)

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
