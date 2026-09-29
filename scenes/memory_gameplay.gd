extends Control

signal win

const MEMORY_CARD_HEIGHT: float = 208.0
const TITLE_BOTTOM_Y: float = 138.0
const GRID_TITLE_GAP: float = 16.0
const GRID_BOTTOM_MARGIN: float = 24.0

@onready var memory_card = $FlowContainer/MemoryCard
@onready var flow_container = $FlowContainer
@onready var correct_panel = $CorrectPanelContainer

var _revealed_cards: Array = []
var _correct_matches: Array = []
var _wrong_matches: int = 0
var _start_time_ms: int = 0
var _win_recorded: bool = false
var hint_delay_seconds: float = 30.0
var _last_match_time_ms: int = 0
var _hinted_cards: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_time_ms = Time.get_ticks_msec()
	_last_match_time_ms = _start_time_ms
	var cards_qnt: int = GameManager.qnt_half_habits[GameManager.selected_difficulty]*4
	var idx: Array = range(cards_qnt)
	idx.shuffle()
	var cards: Array[Node] = flow_container.get_children()
	var habits: Array = GameManager.selected_habits
	if len(habits) != cards_qnt/2:
		GameManager.load_habits(GameManager.selected_difficulty)
		habits = GameManager.selected_habits

	for i in range(len(habits)):
		var card1 = cards[idx[2*i]]
		var card2 = cards[idx[2*i+1]]
		card1.set_habit(habits[i], true)
		card2.set_habit(habits[i], false)
		card1.show()
		card2.show()
		#card1.reveal()
		#card2.reveal()
	_center_grid(cards_qnt)

func _center_grid(cards_qnt: int) -> void:
	var view: Rect2 = get_viewport_rect()
	var rows: int = ceili(cards_qnt/4.0)
	var vsep: int = flow_container.get_theme_constant("v_separation")
	var grid_height: float = rows*MEMORY_CARD_HEIGHT + (rows-1)*vsep
	var top_limit: float = TITLE_BOTTOM_Y + GRID_TITLE_GAP
	var available: float = view.size.y - GRID_BOTTOM_MARGIN - top_limit
	var grid_top: float = top_limit
	if grid_height < available:
		grid_top += (available - grid_height)/2.0
	var center_y: float = view.size.y/2.0
	flow_container.offset_top = grid_top - center_y
	flow_container.offset_bottom = flow_container.offset_top + grid_height

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _win_recorded:
		return
	if Time.get_ticks_msec() - _last_match_time_ms >= int(hint_delay_seconds*1000.0):
		_last_match_time_ms = Time.get_ticks_msec()
		_show_hint()

func _show_hint() -> void:
	var groups: Dictionary = {}
	for card in flow_container.get_children():
		if not card.visible or card._is_revealed:
			continue
		if _correct_matches.has(card) or _hinted_cards.has(card):
			continue
		var desc: String = card.get_meta("description")
		groups[desc] = groups.get(desc, []) + [card]
	var candidates: Array = []
	for desc in groups:
		if len(groups[desc]) == 2:
			candidates.push_back(groups[desc])
	if candidates.is_empty():
		return
	candidates.shuffle()
	for card in candidates[0]:
		card.set_hint(true)
		_hinted_cards.push_back(card)

func _clear_hint_for(card: Node) -> void:
	if _hinted_cards.has(card):
		_hinted_cards.erase(card)
		card.set_hint(false)

func _clear_all_hints() -> void:
	for card in _hinted_cards:
		card.set_hint(false)
	_hinted_cards = []


func _on_memory_card_reveal_card(source) -> void:
	if _correct_matches.has(source):
		return
	_revealed_cards.push_back(source)
	if len(_revealed_cards) > 0 and len(_revealed_cards) % 2 == 0:
		await get_tree().create_timer(1.0).timeout
		_on_timer_timeout()

func _on_timer_timeout() -> void:
	if len(_revealed_cards) < 2:
		return
	var card1 = _revealed_cards.pop_front()
	var card2 = _revealed_cards.pop_front()

	if card1.equals(card2):
		card1.reveal(false, false)
		card2.reveal(false, false)
		_correct_matches.push_back(card1)
		_correct_matches.push_back(card2)
		_last_match_time_ms = Time.get_ticks_msec()
		_clear_hint_for(card1)
		_clear_hint_for(card2)
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
	_clear_all_hints()
	correct_panel.show()
