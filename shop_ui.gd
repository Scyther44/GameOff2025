extends Control
signal shop_closed
@export var night_num = 1
@export var sticky_note_scene: PackedScene
@export var player_money := 0
@onready var grid := $VBoxContainer/GridContainer
@onready var money_label := $VBoxContainer/MoneyLabel
const SHOP_LIMIT = 6
signal upgrade_purchased
signal money_changed
var rifle_purchased = false
var cannon_purchased = false
var shop_items = [
	{"name": "Bow Multishot", "price": 200, "id": "bow_multishot"},
	{"name": "Bow Fire Rate", "price": 10, "id": "bow_fire_rate"},
	{"name": "Bow Damage", "price": 50, "id": "bow_damage"},
	{"name": "Buy Rifle", "price": 10, "id": "buy_rifle"},
	#{"name": "Rifle Multishot", "price": 250, "id": "reload"},
	#{"name": "Rifle Fire Rate", "price": 400, "id": "shield"},
	#{"name": "Rifle Damage", "price": 500, "id": "jump"},
	#{"name": "Buy Rifle", "price": 1000, "id": "buy_rifle"},
	#{"name": "Buy Cannon", "price": 2000, "id": "jump"},
]

var all_shop_items = [
	{"name": "Bow Multishot", "price": 20, "id": "bow_multishot"},
	{"name": "Bow Fire Rate", "price": 10, "id": "bow_fire_rate"},
	{"name": "Bow Damage", "price": 30, "id": "bow_damage"},
	{"name": "Buy Rifle", "price": 10, "id": "buy_rifle"},
	{"name": "Rifle Multishot", "price": 25, "id": "rifle_multishot"},
	{"name": "Rifle Fire Rate", "price": 40, "id": "rifle_fire_rate"},
	{"name": "Rifle Damage", "price": 50, "id": "rifle_damage"},
	{"name": "Buy Cannon", "price": 200, "id": "buy_cannon"},
	{"name": "Cannon Multishot", "price": 25, "id": "cannon_multishot"},
	{"name": "Cannon Fire Rate", "price": 40, "id": "cannon_fire_rate"},
	{"name": "Cannon Damage", "price": 50, "id": "cannon_damage"},
]

var presses = 0

func _ready() -> void:
	setup_grid()
	update_money()

func _process(_delta: float) -> void:
	$VBoxContainer/Shop.text = "Wave " + str(night_num + 1)
	$VBoxContainer/MoneyLabel.text = "Current Money = $" + str(player_money)

func _on_button_pressed() -> void:
	presses += 1
	match presses:
		1:
			#tutorial 1
			$TextSticky.texture = preload("res://resource/stickynote2.png")
		2:
			#tutorial 2
			$TextSticky.texture = preload("res://resource/stickynote3.png")
		_:
			$TextSticky.visible = false
			$Button.disabled = true
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 3)
			await tween.finished
			emit_signal("shop_closed")
			$Button.disabled = false
			$VBoxContainer.visible = true
			$VBoxContainer.process_mode = Node.PROCESS_MODE_DISABLED
			update_grid()
			
func setup_grid():
	populate_shop_items(shop_items)
		
func populate_shop_items(items: Array) -> void:
	for child in $VBoxContainer/GridContainer.get_children():
		child.queue_free()  # clear old buttons
	for item in items:
		var sticky = sticky_note_scene.instantiate()
		sticky.item_name = item.name
		sticky.price = item.price
		sticky.upgrade_id = item.id
		sticky.connect("item_purchased", Callable(self, "_on_item_purchased"))
		grid.add_child(sticky)


func update_grid():
	if shop_items.size() > SHOP_LIMIT:
		print("too many shop items")
	var items = []
	match night_num:
		0:
			items = [
				all_shop_items[0], # Bow Multishot
				all_shop_items[1], # Bow Fire Rate
				all_shop_items[2], # Bow Damage
				all_shop_items[3], # Buy Rifle
			]
		1:
			items = [
				all_shop_items[0], # Bow Multishot
				all_shop_items[1], # Bow Fire Rate
				all_shop_items[2], # Bow Damage
				all_shop_items[3], # Buy Rifle
			]
		2:
			items = [
				all_shop_items[5],
				all_shop_items[6],
				all_shop_items[7],
			]
		_:
			# fallback for later waves 
			items = all_shop_items.slice(0, min(SHOP_LIMIT, all_shop_items.size()))
	populate_shop_items(items)

func _on_item_purchased(upgrade_id: String, cost: int):
	if player_money >= cost:
		player_money -= cost
		update_money()
		print("Bought:", upgrade_id)
		emit_signal("upgrade_purchased", upgrade_id)
		if (upgrade_id == "buy_rifle"):
			rifle_purchased = true
		elif (upgrade_id == "buy_cannon"):
			cannon_purchased = true
	else:
		print("Not enough money!")

func update_money():
	money_label.text = "Money: $" + str(player_money)
	emit_signal("money_changed")

func _on_main_shop_phase() -> void:
	$VBoxContainer.process_mode = Node.PROCESS_MODE_INHERIT
