extends Control

func _ready() -> void:
	$HBoxContainer/WeaponSlot.show_highlight()
	
#func _input(event: InputEvent) -> void:
#	if event.is_action("weaponkey1"):
#		$HBoxContainer/WeaponSlot.show_highlight()
#		$HBoxContainer/WeaponSlot2.hide_highlight()
#	if event.is_action("weaponkey2"):
#		$HBoxContainer/WeaponSlot2.show_highlight()
#		$HBoxContainer/WeaponSlot.hide_highlight()


func _on_player_weapon_changed(weapon_num : int) -> void:
	match weapon_num:
		0:
			$HBoxContainer/WeaponSlot.show_highlight()
			$HBoxContainer/WeaponSlot2.hide_highlight()
		1:
			$HBoxContainer/WeaponSlot2.show_highlight()
			$HBoxContainer/WeaponSlot.hide_highlight()


func _on_player_weapon_bought(name : String) -> void:
	match name:
		"rifle":
			$HBoxContainer/WeaponSlot2.visible = true
		#"cannon":
			#$HBoxContainer/WeaponSlot3.visible = true
			
func update_gold(amount : int):
	$Money.text = "Money = $" + str(amount)
	
