extends Control
signal shop_closed
@export var night_num = 1
@export var sticky_note_scene: PackedScene
@export var player_money := 0
@onready var grid := $VBoxContainer/GridContainer
@onready var money_label := $VBoxContainer/MoneyLabel
var buycannonicon = preload("res://Assets/buycannonicon.png")
var buyrilfeicon = preload("res://Assets/buyrifleicon.png")
var upgradecannonicon = preload("res://Assets/upgradecannonicon.png")
var upgraderifleicon = preload("res://Assets/upgraderifleicon.png")
var upgradebowicon = preload("res://Assets/upgradebowicon.png")

signal upgrade_purchased
signal money_changed
var rifle_purchased = false
var cannon_purchased = false
var rifle_fire_rate_purchased_count = 0
var bow_fire_rate_purchased_count = 0
var cannon_fire_rate_purchased_count = 0
var bow_damage_purchased_count = 0
var bow_multishot_purchased_count = 0
var rifle_damage_purchased_count = 0
var cannon_damage_purchased_count = 0
var cannon_punchthrough_purchased_count = 0
var items = []
var all_shop_items = [
	{"name": "Bow Multishot", "price": 100, "id": "bow_multishot", "item_icon" : upgradebowicon},
	{"name": "Bow Fire Rate", "price": 25, "id": "bow_fire_rate", "item_icon" : upgradebowicon},
	{"name": "Bow Damage", "price": 50, "id": "bow_damage", "item_icon" : upgradebowicon},
	{"name": "Buy Rifle", "price": 200, "id": "buy_rifle", "item_icon" : buyrilfeicon},
	{"name": "Rifle Fire Rate", "price": 25, "id": "rifle_fire_rate", "item_icon" : upgraderifleicon},
	{"name": "Rifle Damage", "price": 50, "id": "rifle_damage", "item_icon" : upgraderifleicon},
	{"name": "Buy Cannon", "price": 300, "id": "buy_cannon", "item_icon" : buycannonicon},
	{"name": "Cannon Multishot", "price": 25, "id": "cannon_multishot", "item_icon" : upgradecannonicon},
	{"name": "Cannon Fire Rate", "price": 40, "id": "cannon_fire_rate", "item_icon" : upgradecannonicon},
	{"name": "Cannon Damage", "price": 50, "id": "cannon_damage", "item_icon" : upgradecannonicon},
]

var presses = 0

func _ready() -> void:
	update_money()
	$StickyNoteTextButton.connect("pressed", Callable(self, "_on_button_pressed"))

func _process(_delta: float) -> void:
	$VBoxContainer/Shop.text = "Wave " + str(night_num + 1)
	$VBoxContainer/MoneyLabel.text = "Current Money = $" + str(player_money)

func _on_button_pressed() -> void:
	$StickyNoteTextButton.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 3)
	await tween.finished
	emit_signal("shop_closed")
	$StickyNoteTextButton.disabled = false
	$VBoxContainer.visible = true
	$VBoxContainer.process_mode = Node.PROCESS_MODE_DISABLED
	update_grid()
		
func populate_shop_items(items: Array) -> void:
	for child in $VBoxContainer/GridContainer.get_children():
		child.queue_free()  # clear old buttons
	for item in items:
		var sticky = sticky_note_scene.instantiate()
		sticky.item_name = item.name
		sticky.price = item.price
		sticky.upgrade_id = item.id
		sticky.item_icon = item.item_icon
		sticky.connect("item_purchased", Callable(self, "_on_item_purchased"))
		grid.add_child(sticky)


func update_grid():		
	var items: Array = []

	for i in range(6):	# max 6 slots
		if i < all_shop_items.size():
			items.append(all_shop_items[i])
		else:
			break	# no more items available
	
	populate_shop_items(items)

func _on_item_purchased(upgrade_id: String, cost: int):
	if player_money >= cost:
		player_money -= cost
		update_money()
		print("Bought:", upgrade_id)
		emit_signal("upgrade_purchased", upgrade_id)
		if (upgrade_id == "buy_rifle"):
			rifle_purchased = true
			remove_item_by_id("buy_rifle")
			update_grid()
		elif (upgrade_id == "buy_cannon"):
			cannon_purchased = true
			remove_item_by_id("buy_cannon")
			update_grid()
		elif(upgrade_id == "bow_multishot"):
			bow_multishot_purchased_count += 1
			if bow_multishot_purchased_count >= 2:
				remove_item_by_id("bow_multishot")
				update_grid()
		elif(upgrade_id == "bow_damage"):
			bow_damage_purchased_count += 1
			if bow_damage_purchased_count >= 2:
				remove_item_by_id("bow_damage")
				update_grid()
		elif(upgrade_id == "rifle_damage"):
			bow_damage_purchased_count += 1
			if bow_damage_purchased_count >= 2:
				remove_item_by_id("rifle_damage")
				update_grid()
		elif(upgrade_id == "bow_fire_rate"):
			bow_fire_rate_purchased_count += 1
			if bow_fire_rate_purchased_count >= 7:
				remove_item_by_id("bow_fire_rate")
				update_grid()
				print("Max bow fire rate reached")
		elif(upgrade_id == "rifle_fire_rate"):
			rifle_fire_rate_purchased_count += 1
			if rifle_fire_rate_purchased_count >= 7:
				remove_item_by_id("rifle_fire_rate")
				update_grid()
				print("Max rifle fire rate reached")
	else:
		print("Not enough money!")

func remove_item_by_id(target_id):
	for item in all_shop_items:
		if item.id == target_id:
			all_shop_items.erase(item)
			break
			
func get_item_by_id(target_id):
	for item in all_shop_items:
		if item.id == target_id:
			return item

func update_money():
	money_label.text = "Money: $" + str(player_money)
	emit_signal("money_changed")

func _on_main_shop_phase() -> void:
	$VBoxContainer.process_mode = Node.PROCESS_MODE_INHERIT
