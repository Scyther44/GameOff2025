extends Control

@export var icon = Texture2D
func _ready() -> void:
	$Icon.texture = icon
func show_highlight():
	$HighlightFrame.visible = true
	
func hide_highlight():
	$HighlightFrame.visible = false
