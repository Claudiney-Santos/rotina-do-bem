extends Node

const view_height: int = 1027

func _ready() -> void:
	print(Database.data)
	GameManager.on_resize()

func _on_resized() -> void:
	GameManager.on_resize()
