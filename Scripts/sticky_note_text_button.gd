extends Button

@export var note_text: String 

func _ready() -> void:
	$Text.text = note_text
