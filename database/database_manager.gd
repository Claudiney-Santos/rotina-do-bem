extends Node

const DB_RESOURCE = preload("res://database/database.json")
var data: Dictionary = {}

func _ready() -> void:
	if DB_RESOURCE and DB_RESOURCE.data is Dictionary:
		data = DB_RESOURCE.data
		_load_images()
	else:
		push_error("Database failed to initialize or JSON is not a Dictionary.")

# Helper function to get data safely
func get_item(item_id: String) -> Dictionary:
	return data.get(item_id, {})

func _load_images() -> void:
	for difficulty in data:
		for healthiness in data[difficulty]:
			for habit in data[difficulty][healthiness]:
				var image_resource: CompressedTexture2D = load("res://images/%s" % habit.image)
				habit.set("image_resource", image_resource)
