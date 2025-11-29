extends Node

const SAVE_PATH := "user://save_data.json"

var high_score: int = 0

func _ready():
	load_save()

func load_save():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			high_score = data.get("high_score", 0)
	else:
		high_score = 0

func save_score(new_score: int):
	if new_score > high_score:
		high_score = new_score
		var data = {"high_score": high_score}
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
