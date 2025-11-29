extends Control
var presses = 0

func _ready() -> void:
	$StickyNoteTextButton.connect("pressed", Callable(self, "_next_button_pressed"))
	
func _on_button_pressed() -> void:
	$Button.visible = false
	$Title.visible = false
	$Highscore.visible = false
	$TextSticky.visible = true
	$StickyNoteTextButton.visible = true
	
func _next_button_pressed() -> void:
	presses += 1
	match presses:
		1:
			#tutorial 1
			$TextSticky.texture = preload("res://Assets/stickynote2.png")
		2:
			#tutorial 2
			$TextSticky.texture = preload("res://Assets/stickynote3.png")
		_:
			$Transition.visible = true
			$TextSticky.visible = false
			$StickyNoteTextButton.visible = false
			$Transition.play_animation()
			await get_tree().create_timer(4).timeout
			queue_free()
	
