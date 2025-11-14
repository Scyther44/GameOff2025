extends Control


func _on_button_pressed() -> void:
	$Button.visible = false
	$Transition.play_animation()
	await get_tree().create_timer(4).timeout
	queue_free()
