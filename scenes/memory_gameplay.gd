extends Control

signal win

@onready var memory_card = $FlowContainer/MemoryCard
@onready var flow_container = $FlowContainer
@onready var correct_panel = $CorrectPanelContainer

var _revealed_cards: Array = []
var _correct_matches: Array = []
var _wrong_matches: int = 0
var _start_time_ms: int = 0
var _win_recorded: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_time_ms = Time.get_ticks_msec()
	var cards_qnt: int = GameManager.qnt_half_habits[GameManager.selected_difficulty]*4
	var idx: Array = range(cards_qnt)
	idx.shuffle()
	var cards: Array[Node] = flow_container.get_children()
	var habits: Array = GameManager.selected_habits

	for i in range(len(habits)):
		var card1 = cards[idx[2*i]]
		var card2 = cards[idx[2*i+1]]
		card1.set_habit(habits[i], true)
		card2.set_habit(habits[i], false)
		card1.show()
		card2.show()
		#card1.reveal()
		#card2.reveal()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_memory_card_reveal_card(source) -> void:
	if _correct_matches.has(source):
		return
	_revealed_cards.push_back(source)
	if len(_revealed_cards) > 0 and len(_revealed_cards) % 2 == 0:
		await get_tree().create_timer(1.0).timeout
		_on_timer_timeout()

func _on_timer_timeout() -> void:
	var card1 = _revealed_cards.pop_front()
	var card2 = _revealed_cards.pop_front()

	if card1.equals(card2):
		card1.reveal(false, false)
		card2.reveal(false, false)
		_correct_matches.push_back(card1)
		_correct_matches.push_back(card2)
		if len(_correct_matches) >= 4*GameManager.qnt_half_habits[GameManager.selected_difficulty]:
			if not _win_recorded:
				_win_recorded = true
				GameManager.push_memory_mistake(Mistakes.MemoryMistake.new(
					_wrong_matches,
					(Time.get_ticks_msec() - _start_time_ms)/1000.0,
					GameManager.selected_difficulty
				))
			emit_signal("win")
	else:
		_wrong_matches += 1
		card1.conceal()
		card2.conceal()
	


func _on_continue_button_pressed() -> void:
	if GameManager.completed_activity == 1:
		GameManager.unlock_next_activity()
	get_tree().change_scene_to_file("res://scenes/difficulty.tscn")


func _on_win() -> void:
	correct_panel.show()
